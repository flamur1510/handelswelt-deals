// lib/seiten/admin_firmen_verifizierung_seite.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'firmen_profil_seite.dart';

class AdminFirmenVerifizierungSeite extends StatefulWidget {
  const AdminFirmenVerifizierungSeite({super.key});

  @override
  State<AdminFirmenVerifizierungSeite> createState() =>
      _AdminFirmenVerifizierungSeiteState();
}

class _AdminFirmenVerifizierungSeiteState
    extends State<AdminFirmenVerifizierungSeite> {
  final sucheController = TextEditingController();

  String suchtext = '';
  String statusFilter = 'Offen';

  final statusOptionen = const [
    'Alle',
    'Offen',
    'Genehmigt',
    'Abgelehnt',
  ];

  @override
  void dispose() {
    sucheController.dispose();
    super.dispose();
  }

  Future<void> _firmaGenehmigen(
    BuildContext context,
    String userId,
  ) async {
    final admin = FirebaseAuth.instance.currentUser;

    if (admin == null) {
      _meldung(context, 'Bitte zuerst einloggen.');
      return;
    }

    final bestaetigt = await _bestaetigen(
      context: context,
      titel: 'Firma genehmigen?',
      text: 'Diese Firma wird verifiziert und erhält ein Verifiziert-Abzeichen.',
      buttonText: 'Genehmigen',
      farbe: const Color(0xff5b2cff),
    );

    if (!bestaetigt) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'firmaVerifiziert': true,
        'firmaAbgelehnt': false,
        'verifizierungsStatus': 'genehmigt',
        'verifiziertAm': FieldValue.serverTimestamp(),
        'verifiziertVon': admin.uid,
        'aktualisiertAm': FieldValue.serverTimestamp(),
      });

      final inserate = await FirebaseFirestore.instance
          .collection('inserate')
          .where('verkaeuferId', isEqualTo: userId)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in inserate.docs) {
        batch.set(
          doc.reference,
          {'firmaVerifiziert': true},
          SetOptions(merge: true),
        );
      }
      await batch.commit();

      if (!context.mounted) return;
      _meldung(context, 'Firma wurde verifiziert.');
    } catch (e) {
      if (!context.mounted) return;
      _meldung(context, 'Fehler beim Genehmigen: $e');
    }
  }

  Future<void> _firmaAblehnen(
    BuildContext context,
    String userId,
    String grund,
  ) async {
    final admin = FirebaseAuth.instance.currentUser;

    if (admin == null) {
      _meldung(context, 'Bitte zuerst einloggen.');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'firmaVerifiziert': false,
        'firmaAbgelehnt': true,
        'verifizierungsStatus': 'abgelehnt',
        'verifizierungAbgelehntGrund': grund.trim(),
        'verifiziertAm': null,
        'verifiziertVon': admin.uid,
        'aktualisiertAm': FieldValue.serverTimestamp(),
      });

      final inserate = await FirebaseFirestore.instance
          .collection('inserate')
          .where('verkaeuferId', isEqualTo: userId)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in inserate.docs) {
        batch.set(
          doc.reference,
          {'firmaVerifiziert': false},
          SetOptions(merge: true),
        );
      }
      await batch.commit();

      if (!context.mounted) return;
      _meldung(context, 'Firma wurde abgelehnt.');
    } catch (e) {
      if (!context.mounted) return;
      _meldung(context, 'Fehler beim Ablehnen: $e');
    }
  }

  Future<void> _gewerbescheinOeffnen(
    BuildContext context,
    String url,
  ) async {
    final sauber = url.trim();

    if (sauber.isEmpty) {
      _meldung(context, 'Kein Gewerbeschein vorhanden.');
      return;
    }

    final uri = Uri.tryParse(sauber);
    if (uri == null) {
      _meldung(context, 'Ungültiger Link.');
      return;
    }

    final erfolg = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!erfolg && context.mounted) {
      _meldung(context, 'Gewerbeschein konnte nicht geöffnet werden.');
    }
  }

  void _meldung(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  void _ablehnenDialog(
    BuildContext context,
    String userId,
    String firmenname,
  ) {
    final grundController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            '$firmenname ablehnen',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: TextField(
            controller: grundController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Grund der Ablehnung',
              hintText: 'z.B. UID Nummer konnte nicht geprüft werden.',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                final grund = grundController.text.trim();

                if (grund.isEmpty) {
                  _meldung(context, 'Bitte einen Grund eingeben.');
                  return;
                }

                Navigator.pop(dialogContext);
                _firmaAblehnen(context, userId, grund);
              },
              child: const Text(
                'Ablehnen',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _passtZurSuche(Map<String, dynamic> data) {
    final text = suchtext.trim().toLowerCase();
    if (text.isEmpty) return true;

    final suchDaten = [
      data['firmenname'],
      data['rechtsform'],
      data['uidNummer'],
      data['ansprechpartner'],
      data['email'],
      data['telefon'],
      data['webseite'],
      data['strasse'],
      data['plz'],
      data['ort'],
      data['land'],
    ].join(' ').toLowerCase();

    return suchDaten.contains(text);
  }

  bool _passtZumStatus(Map<String, dynamic> data) {
    final status = (data['verifizierungsStatus'] ?? 'offen')
        .toString()
        .trim()
        .toLowerCase();

    if (statusFilter == 'Alle') return true;
    if (statusFilter == 'Offen') return status == 'offen' || status.isEmpty;
    if (statusFilter == 'Genehmigt') return status == 'genehmigt';
    if (statusFilter == 'Abgelehnt') return status == 'abgelehnt';

    return true;
  }

  String _statusVon(Map<String, dynamic> data) {
    final status = (data['verifizierungsStatus'] ?? 'offen')
        .toString()
        .trim()
        .toLowerCase();

    if (status == 'genehmigt') return 'Genehmigt';
    if (status == 'abgelehnt') return 'Abgelehnt';
    return 'Offen';
  }

  @override
  Widget build(BuildContext context) {
    final breit = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      appBar: AppBar(
        backgroundColor: const Color(0xff050b2c),
        foregroundColor: Colors.white,
        title: const Text(
          'Firmen verifizieren',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('kontoTyp', isEqualTo: 'firma')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _leer(
                'Firmen konnten nicht geladen werden. Eventuell muss in Firebase ein Index erstellt werden.',
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xff5b2cff),
                ),
              );
            }

            final alleFirmen = snapshot.data!.docs;

            final gefiltert = alleFirmen.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _passtZumStatus(data) && _passtZurSuche(data);
            }).toList();

            final offen = alleFirmen.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _statusVon(data) == 'Offen';
            }).length;

            final genehmigt = alleFirmen.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _statusVon(data) == 'Genehmigt';
            }).length;

            final abgelehnt = alleFirmen.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _statusVon(data) == 'Abgelehnt';
            }).length;

            return ListView(
              padding: EdgeInsets.fromLTRB(
                breit ? 46 : 16,
                18,
                breit ? 46 : 16,
                24,
              ),
              children: [
                _kopf(
                  offen: offen,
                  genehmigt: genehmigt,
                  abgelehnt: abgelehnt,
                ),
                const SizedBox(height: 14),
                _filterBereich(),
                const SizedBox(height: 16),
                if (gefiltert.isEmpty)
                  _leerKarte('Keine passenden Firmen gefunden.')
                else
                  ...gefiltert.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _firmaKarte(context, doc.id, data);
                  }),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _kopf({
    required int offen,
    required int genehmigt,
    required int abgelehnt,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff050b2c),
            Color(0xff11184f),
            Color(0xff5b2cff),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Firmen-Verifizierung',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Prüfe Firmen, UID/USt-ID und hochgeladene Unterlagen.',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _kopfChip('Offen', offen.toString(), Colors.orange),
              _kopfChip('Genehmigt', genehmigt.toString(), Colors.green),
              _kopfChip('Abgelehnt', abgelehnt.toString(), Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kopfChip(String titel, String wert, Color farbe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 5,
            backgroundColor: farbe,
          ),
          const SizedBox(width: 8),
          Text(
            '$titel: $wert',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterBereich() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffececf4)),
      ),
      child: Column(
        children: [
          TextField(
            controller: sucheController,
            onChanged: (value) {
              setState(() {
                suchtext = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Firma, UID, E-Mail oder Ort suchen',
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xff5b2cff),
              ),
              filled: true,
              fillColor: const Color(0xfff7f7fb),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: statusFilter,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Status filtern',
              prefixIcon: const Icon(
                Icons.tune,
                color: Color(0xff5b2cff),
              ),
              filled: true,
              fillColor: const Color(0xfff7f7fb),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            items: statusOptionen
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                statusFilter = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _firmaKarte(
    BuildContext context,
    String userId,
    Map<String, dynamic> data,
  ) {
    final firmenname = (data['firmenname'] ?? 'Firma').toString();
    final rechtsform = (data['rechtsform'] ?? '').toString();
    final uidNummer = (data['uidNummer'] ?? '').toString();
    final ansprechpartner = (data['ansprechpartner'] ?? '').toString();
    final email = (data['email'] ?? '').toString();
    final telefon = (data['telefon'] ?? '').toString();
    final webseite = (data['webseite'] ?? '').toString();
    final strasse = (data['strasse'] ?? '').toString();
    final plz = (data['plz'] ?? '').toString();
    final ort = (data['ort'] ?? '').toString();
    final land = (data['land'] ?? '').toString();
    final gewerbescheinUrl = (data['gewerbescheinUrl'] ?? '').toString();
    final ablehnGrund = (data['verifizierungAbgelehntGrund'] ?? '').toString();
    final status = _statusVon(data);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffececf4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0f000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xfff1edff),
                child: Icon(
                  Icons.business,
                  color: Color(0xff5b2cff),
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firmenname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff050b2c),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rechtsform.isEmpty ? 'Firma' : rechtsform,
                      style: const TextStyle(
                        color: Color(0xff74788d),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _statusChip(status),
            ],
          ),
          const SizedBox(height: 16),
          _info('UID / USt-ID', uidNummer),
          _info('Ansprechpartner', ansprechpartner),
          _info('E-Mail', email),
          _info('Telefon', telefon),
          _info('Webseite', webseite),
          _info('Adresse', '$strasse, $plz $ort, $land'),
          _info(
            'Gewerbeschein',
            gewerbescheinUrl.isEmpty ? 'Noch nicht hochgeladen' : gewerbescheinUrl,
          ),
          if (ablehnGrund.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            _ablehnGrundKarte(ablehnGrund),
          ],
          const SizedBox(height: 14),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('inserate')
                .where('verkaeuferId', isEqualTo: userId)
                .snapshots(),
            builder: (context, snapshot) {
              final anzahl = snapshot.data?.docs.length ?? 0;
              return _kleineInfoBox(
                icon: Icons.inventory_2_outlined,
                text: 'Aktive Inserate: $anzahl',
              );
            },
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xff5b2cff),
                  side: const BorderSide(color: Color(0xff5b2cff)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: gewerbescheinUrl.trim().isEmpty
                    ? null
                    : () => _gewerbescheinOeffnen(context, gewerbescheinUrl),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text(
                  'Gewerbeschein öffnen',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xff050b2c),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FirmenProfilSeite(
                        userId: userId,
                        firmenname: firmenname,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.business_outlined),
                label: const Text(
                  'Firma ansehen',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: status == 'Abgelehnt'
                      ? null
                      : () {
                          _ablehnenDialog(context, userId, firmenname);
                        },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Ablehnen',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5b2cff),
                    disabledBackgroundColor: const Color(0xffd6d6df),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: status == 'Genehmigt'
                      ? null
                      : () {
                          _firmaGenehmigen(context, userId);
                        },
                  icon: const Icon(
                    Icons.verified,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Genehmigen',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ablehnGrundKarte(String grund) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xfffff1f1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffffd0d0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Ablehnungsgrund: $grund',
              style: const TextStyle(
                color: Color(0xff050b2c),
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kleineInfoBox({
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xfff7f7fb),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffececf4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff5b2cff)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xff050b2c),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String text) {
    Color bg;
    Color fg;

    if (text == 'Genehmigt') {
      bg = const Color(0xffe8f8ee);
      fg = Colors.green;
    } else if (text == 'Abgelehnt') {
      bg = const Color(0xffffedf1);
      fg = Colors.red;
    } else {
      bg = const Color(0xfffff6df);
      fg = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _info(String titel, String wert) {
    final sauber = wert.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              '$titel:',
              style: const TextStyle(
                color: Color(0xff74788d),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              sauber.isEmpty ? '-' : sauber,
              style: const TextStyle(
                color: Color(0xff050b2c),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _leer(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: _leerKarte(text),
      ),
    );
  }

  Widget _leerKarte(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffececf4)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xff74788d),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

Future<bool> _bestaetigen({
  required BuildContext context,
  required String titel,
  required String text,
  required String buttonText,
  required Color farbe,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(
          titel,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: farbe),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              buttonText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      );
    },
  );

  return result == true;
}
