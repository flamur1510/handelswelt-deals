import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firmen_profil_seite.dart';

class AdminFirmenSeite extends StatefulWidget {
  const AdminFirmenSeite({super.key});

  @override
  State<AdminFirmenSeite> createState() => _AdminFirmenSeiteState();
}

class _AdminFirmenSeiteState extends State<AdminFirmenSeite> {
  final TextEditingController sucheController = TextEditingController();

  String suche = '';
  String filter = 'Alle';

  final List<String> filterOptionen = const [
    'Alle',
    'In Prüfung',
    'Verifiziert',
    'Abgelehnt',
    'Gesperrt',
  ];

  @override
  void dispose() {
    sucheController.dispose();
    super.dispose();
  }

  Future<void> firmaFreigeben(BuildContext context, String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'firmaVerifiziert': true,
      'firmaAbgelehnt': false,
      'firmaGesperrt': false,
      'gesperrt': false,
      'firmaGeprueftAm': FieldValue.serverTimestamp(),
      'aktualisiertAm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final inserate = await FirebaseFirestore.instance
        .collection('inserate')
        .where('verkaeuferId', isEqualTo: userId)
        .get();

    final batch = FirebaseFirestore.instance.batch();

    for (final doc in inserate.docs) {
      batch.set(
        doc.reference,
        {
          'firmaVerifiziert': true,
          'aktualisiertAm': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Firma und alle Inserate wurden freigegeben.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> firmaAblehnen(BuildContext context, String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'firmaVerifiziert': false,
      'firmaAbgelehnt': true,
      'firmaGeprueftAm': FieldValue.serverTimestamp(),
      'aktualisiertAm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final inserate = await FirebaseFirestore.instance
        .collection('inserate')
        .where('verkaeuferId', isEqualTo: userId)
        .get();

    final batch = FirebaseFirestore.instance.batch();

    for (final doc in inserate.docs) {
      batch.set(
        doc.reference,
        {
          'firmaVerifiziert': false,
          'aktualisiertAm': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Firma wurde abgelehnt.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> firmaSperren(
    BuildContext context,
    String userId,
    String firmenname,
  ) async {
    final bestaetigt = await _bestaetigen(
      context: context,
      titel: 'Firma sperren?',
      text: 'Diese Firma wird gesperrt. Die Firma kann dann nicht mehr normal genutzt werden.',
      buttonText: 'Sperren',
      farbe: Colors.red,
    );

    if (!bestaetigt) return;

    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'firmaGesperrt': true,
      'gesperrt': true,
      'aktualisiertAm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection('gesperrteUser').doc(userId).set({
      'userId': userId,
      'firmenname': firmenname,
      'grund': 'Admin-Sperre',
      'erstelltAm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$firmenname wurde gesperrt.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> firmaEntsperren(
    BuildContext context,
    String userId,
    String firmenname,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'firmaGesperrt': false,
      'gesperrt': false,
      'aktualisiertAm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection('gesperrteUser').doc(userId).delete();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$firmenname wurde entsperrt.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _wert(Map<String, dynamic> data, String feld, String fallback) {
    final wert = data[feld];
    if (wert == null) return fallback;
    final text = wert.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  bool _passtZurSuche(Map<String, dynamic> data) {
    final text = suche.trim().toLowerCase();
    if (text.isEmpty) return true;

    final suchText = [
      data['firmenname'],
      data['uidNummer'],
      data['ansprechpartner'],
      data['email'],
      data['firmaEmail'],
      data['telefon'],
      data['webseite'],
      data['ort'],
      data['land'],
      data['strasse'],
      data['plz'],
    ].join(' ').toLowerCase();

    return suchText.contains(text);
  }

  bool _passtZumFilter(Map<String, dynamic> data) {
    final verifiziert = data['firmaVerifiziert'] == true;
    final abgelehnt = data['firmaAbgelehnt'] == true;
    final gesperrt = data['firmaGesperrt'] == true || data['gesperrt'] == true;

    if (filter == 'Alle') return true;
    if (filter == 'Verifiziert') return verifiziert && !gesperrt;
    if (filter == 'Abgelehnt') return abgelehnt && !gesperrt;
    if (filter == 'Gesperrt') return gesperrt;
    if (filter == 'In Prüfung') {
      return !verifiziert && !abgelehnt && !gesperrt;
    }

    return true;
  }

  String _statusText(Map<String, dynamic> data) {
    final verifiziert = data['firmaVerifiziert'] == true;
    final abgelehnt = data['firmaAbgelehnt'] == true;
    final gesperrt = data['firmaGesperrt'] == true || data['gesperrt'] == true;

    if (gesperrt) return 'Gesperrt';
    if (verifiziert) return 'Verifiziert';
    if (abgelehnt) return 'Abgelehnt';
    return 'In Prüfung';
  }

  Color _statusFarbe(String status) {
    if (status == 'Verifiziert') return Colors.green;
    if (status == 'Abgelehnt') return Colors.orange;
    if (status == 'Gesperrt') return Colors.red;
    return const Color(0xff5b2cff);
  }

  void _firmenProfilOeffnen(
    BuildContext context,
    String userId,
    String firmenname,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FirmenProfilSeite(
          userId: userId,
          firmenname: firmenname,
        ),
      ),
    );
  }

  void _detailsOeffnen({
    required BuildContext context,
    required String userId,
    required String firmenname,
    required String uidNummer,
    required String ansprechpartner,
    required String email,
    required String telefon,
    required String webseite,
    required String adresse,
    required String status,
    required int inserateAnzahl,
    required bool gesperrt,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xffd9d9e6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  firmenname,
                  style: const TextStyle(
                    color: Color(0xff050b2c),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                _detailZeile(Icons.verified_outlined, 'Status', status),
                _detailZeile(Icons.badge_outlined, 'UID Nummer', uidNummer),
                _detailZeile(Icons.person_outline, 'Ansprechpartner', ansprechpartner),
                _detailZeile(Icons.email_outlined, 'E-Mail', email),
                _detailZeile(Icons.phone_outlined, 'Telefon', telefon),
                _detailZeile(Icons.public_outlined, 'Webseite', webseite),
                _detailZeile(Icons.location_on_outlined, 'Adresse', adresse),
                _detailZeile(Icons.inventory_2_outlined, 'Inserate', '$inserateAnzahl'),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _aktionsButton(
                      icon: Icons.open_in_new,
                      text: 'Profil öffnen',
                      farbe: const Color(0xff5b2cff),
                      onPressed: () {
                        Navigator.pop(context);
                        _firmenProfilOeffnen(context, userId, firmenname);
                      },
                    ),
                    _aktionsButton(
                      icon: Icons.verified,
                      text: 'Freigeben',
                      farbe: Colors.green,
                      onPressed: () {
                        Navigator.pop(context);
                        firmaFreigeben(context, userId);
                      },
                    ),
                    _aktionsButton(
                      icon: Icons.close,
                      text: 'Ablehnen',
                      farbe: Colors.orange,
                      onPressed: () {
                        Navigator.pop(context);
                        firmaAblehnen(context, userId);
                      },
                    ),
                    _aktionsButton(
                      icon: gesperrt ? Icons.lock_open : Icons.block,
                      text: gesperrt ? 'Entsperren' : 'Sperren',
                      farbe: gesperrt ? Colors.green : Colors.red,
                      onPressed: () {
                        Navigator.pop(context);
                        if (gesperrt) {
                          firmaEntsperren(context, userId, firmenname);
                        } else {
                          firmaSperren(context, userId, firmenname);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailZeile(IconData icon, String titel, String wert) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xff5b2cff), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xff050b2c),
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: '$titel: ',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  TextSpan(
                    text: wert.trim().isEmpty ? '-' : wert,
                    style: const TextStyle(
                      color: Color(0xff74788d),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aktionsButton({
    required IconData icon,
    required String text,
    required Color farbe,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: farbe,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      appBar: AppBar(
        backgroundColor: const Color(0xff050b2c),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Firmenverwaltung',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('kontoTyp', isEqualTo: 'firma')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Fehler beim Laden der Firmen.'));
          }

          final alleFirmen = snapshot.data?.docs ?? [];

          final firmen = alleFirmen.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _passtZurSuche(data) && _passtZumFilter(data);
          }).toList();

          firmen.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aName = _wert(aData, 'firmenname', '').toLowerCase();
            final bName = _wert(bData, 'firmenname', '').toLowerCase();
            return aName.compareTo(bName);
          });

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _kopfBereich(alleFirmen.length, firmen.length),
              const SizedBox(height: 16),
              _filterBereich(),
              const SizedBox(height: 16),
              if (firmen.isEmpty)
                _leerKarte()
              else
                for (final doc in firmen) _firmaKarte(context, doc),
            ],
          );
        },
      ),
    );
  }

  Widget _kopfBereich(int gesamt, int sichtbar) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff070b2f),
            Color(0xff11184f),
            Color(0xff5b2cff),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.business_outlined, color: Colors.white, size: 42),
          const SizedBox(height: 12),
          const Text(
            'Firmen verwalten',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$sichtbar von $gesamt Firmen werden angezeigt',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
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
                suche = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Firma suchen',
              hintText: 'Firmenname, UID, E-Mail oder Ort',
              prefixIcon: const Icon(Icons.search, color: Color(0xff5b2cff)),
              filled: true,
              fillColor: const Color(0xfff7f7fb),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: filter,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Status filtern',
              prefixIcon: const Icon(Icons.filter_list, color: Color(0xff5b2cff)),
              filled: true,
              fillColor: const Color(0xfff7f7fb),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            items: filterOptionen
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
                filter = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _firmaKarte(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final userId = doc.id;

    final firmenname = _wert(data, 'firmenname', 'Keine Angabe');
    final uidNummer = _wert(data, 'uidNummer', 'Keine Angabe');
    final ansprechpartner = _wert(data, 'ansprechpartner', 'Keine Angabe');
    final email = _wert(data, 'email', _wert(data, 'firmaEmail', 'Keine Angabe'));
    final telefon = _wert(data, 'telefon', 'Keine Angabe');
    final webseite = _wert(data, 'webseite', 'Keine Angabe');
    final strasse = _wert(data, 'strasse', 'Keine Angabe');
    final plz = _wert(data, 'plz', '');
    final ort = _wert(data, 'ort', 'Keine Angabe');
    final land = _wert(data, 'land', 'Österreich');
    final status = _statusText(data);
    final statusFarbe = _statusFarbe(status);
    final gesperrt = status == 'Gesperrt';
    final adresse = '$strasse, $plz $ort, $land';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('inserate')
          .where('verkaeuferId', isEqualTo: userId)
          .snapshots(),
      builder: (context, inserateSnapshot) {
        final inserateAnzahl = inserateSnapshot.data?.docs.length ?? 0;

        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            _detailsOeffnen(
              context: context,
              userId: userId,
              firmenname: firmenname,
              uidNummer: uidNummer,
              ansprechpartner: ansprechpartner,
              email: email,
              telefon: telefon,
              webseite: webseite,
              adresse: adresse,
              status: status,
              inserateAnzahl: inserateAnzahl,
              gesperrt: gesperrt,
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: statusFarbe.withOpacity(0.35)),
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
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: statusFarbe.withOpacity(0.12),
                      child: Icon(Icons.business, color: statusFarbe),
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
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$ort • $email',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xff74788d),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _statusChip(status, statusFarbe),
                  ],
                ),
                const SizedBox(height: 14),
                _info('UID Nummer', uidNummer),
                _info('Ansprechpartner', ansprechpartner),
                _info('Adresse', adresse),
                _info('Inserate', '$inserateAnzahl'),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _miniButton(
                      icon: Icons.open_in_new,
                      text: 'Profil öffnen',
                      farbe: const Color(0xff5b2cff),
                      onPressed: () => _firmenProfilOeffnen(context, userId, firmenname),
                    ),
                    _miniButton(
                      icon: Icons.verified,
                      text: 'Freigeben',
                      farbe: Colors.green,
                      onPressed: () => firmaFreigeben(context, userId),
                    ),
                    _miniButton(
                      icon: Icons.close,
                      text: 'Ablehnen',
                      farbe: Colors.orange,
                      onPressed: () => firmaAblehnen(context, userId),
                    ),
                    _miniButton(
                      icon: gesperrt ? Icons.lock_open : Icons.block,
                      text: gesperrt ? 'Entsperren' : 'Sperren',
                      farbe: gesperrt ? Colors.green : Colors.red,
                      onPressed: () {
                        if (gesperrt) {
                          firmaEntsperren(context, userId, firmenname);
                        } else {
                          firmaSperren(context, userId, firmenname);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _miniButton({
    required IconData icon,
    required String text,
    required Color farbe,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        foregroundColor: farbe,
        side: BorderSide(color: farbe.withOpacity(0.65)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _statusChip(String text, Color farbe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: farbe.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: farbe,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _info(String titel, String wert) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$titel:',
              style: const TextStyle(
                color: Color(0xff74788d),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              wert.trim().isEmpty ? '-' : wert,
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

  Widget _leerKarte() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffececf4)),
      ),
      child: const Column(
        children: [
          Icon(Icons.business_outlined, color: Color(0xff5b2cff), size: 46),
          SizedBox(height: 12),
          Text(
            'Keine Firmen gefunden.',
            style: TextStyle(
              color: Color(0xff050b2c),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
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
