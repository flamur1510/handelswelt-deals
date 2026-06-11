import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'firmen_profil_seite.dart';

class AdminBenutzerSeite extends StatefulWidget {
  const AdminBenutzerSeite({super.key});

  @override
  State<AdminBenutzerSeite> createState() => _AdminBenutzerSeiteState();
}

class _AdminBenutzerSeiteState extends State<AdminBenutzerSeite> {
  final sucheController = TextEditingController();
  String suche = '';
  String filter = 'Alle';

  final List<String> filterOptionen = const [
    'Alle',
    'Privat',
    'Firma',
    'Admins',
    'Gesperrt',
  ];

  @override
  void dispose() {
    sucheController.dispose();
    super.dispose();
  }

  Future<void> _benutzerSperren(
    BuildContext context,
    String userId,
    String name,
  ) async {
    final bestaetigt = await _bestaetigen(
      context: context,
      titel: 'Benutzer sperren?',
      text: '$name wird gesperrt und kann die App nicht mehr normal nutzen.',
      buttonText: 'Sperren',
      farbe: Colors.red,
    );

    if (!bestaetigt) return;

    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'gesperrt': true,
      'aktualisiertAm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name wurde gesperrt'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _benutzerEntsperren(
    BuildContext context,
    String userId,
    String name,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'gesperrt': false,
      'aktualisiertAm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name wurde entsperrt'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _benutzerLoeschen(
    BuildContext context,
    String userId,
    String name,
  ) async {
    final bestaetigt = await _bestaetigen(
      context: context,
      titel: 'Benutzer wirklich löschen?',
      text:
          '$name wird dauerhaft aus der Benutzerverwaltung entfernt. Zugehörige Inserate, Favoriten, Bewertungen und Meldungen werden ebenfalls gelöscht.',
      buttonText: 'Endgültig löschen',
      farbe: Colors.red,
    );

    if (!bestaetigt) return;

    try {
      await _sammlungNachFeldLoeschen(
        sammlung: 'inserate',
        feld: 'verkaeuferId',
        wert: userId,
      );

      await _sammlungNachFeldLoeschen(
        sammlung: 'favoriten',
        feld: 'userId',
        wert: userId,
      );

      await _sammlungNachFeldLoeschen(
        sammlung: 'favoriten',
        feld: 'verkaeuferId',
        wert: userId,
      );

      await _sammlungNachFeldLoeschen(
        sammlung: 'bewertungen',
        feld: 'verkaeuferId',
        wert: userId,
      );

      await _sammlungNachFeldLoeschen(
        sammlung: 'bewertungen',
        feld: 'bewerterId',
        wert: userId,
      );

      await _sammlungNachFeldLoeschen(
        sammlung: 'meldungen',
        feld: 'verkaeuferId',
        wert: userId,
      );

      await _sammlungNachFeldLoeschen(
        sammlung: 'meldungen',
        feld: 'melderId',
        wert: userId,
      );

      await _sammlungNachFeldLoeschen(
        sammlung: 'firmenmeldungen',
        feld: 'firmaId',
        wert: userId,
      );

      await _sammlungNachFeldLoeschen(
        sammlung: 'firmenmeldungen',
        feld: 'melderId',
        wert: userId,
      );

      await FirebaseFirestore.instance
          .collection('gesperrteUser')
          .doc(userId)
          .delete()
          .catchError((_) {});

      await FirebaseFirestore.instance.collection('adminLog').add({
        'aktion': 'benutzer_geloescht',
        'userId': userId,
        'name': name,
        'erstelltAm': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('users').doc(userId).delete();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name wurde gelöscht.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Benutzer konnte nicht gelöscht werden: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sammlungNachFeldLoeschen({
    required String sammlung,
    required String feld,
    required String wert,
  }) async {
    if (wert.trim().isEmpty) return;

    final snapshot = await FirebaseFirestore.instance
        .collection(sammlung)
        .where(feld, isEqualTo: wert)
        .get();

    if (snapshot.docs.isEmpty) return;

    const maxBatch = 450;
    var batch = FirebaseFirestore.instance.batch();
    var zaehler = 0;

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
      zaehler++;

      if (zaehler >= maxBatch) {
        await batch.commit();
        batch = FirebaseFirestore.instance.batch();
        zaehler = 0;
      }
    }

    if (zaehler > 0) {
      await batch.commit();
    }
  }

  Future<void> _adminMachen(
    BuildContext context,
    String userId,
    String name,
  ) async {
    final bestaetigt = await _bestaetigen(
      context: context,
      titel: 'Admin-Rechte vergeben?',
      text: '$name erhält Admin-Rechte. Nur vertrauenswürdige Benutzer sollten Admin sein.',
      buttonText: 'Admin machen',
      farbe: const Color(0xff5b2cff),
    );

    if (!bestaetigt) return;

    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'isAdmin': true,
      'aktualisiertAm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name wurde zum Admin gemacht'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _adminEntfernen(
    BuildContext context,
    String userId,
    String name,
  ) async {
    final bestaetigt = await _bestaetigen(
      context: context,
      titel: 'Admin-Rechte entfernen?',
      text: '$name verliert die Admin-Rechte.',
      buttonText: 'Entfernen',
      farbe: Colors.orange,
    );

    if (!bestaetigt) return;

    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'isAdmin': false,
      'aktualisiertAm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name ist kein Admin mehr'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  String _nameAusDaten(Map<String, dynamic> data) {
    final kontoTyp = (data['kontoTyp'] ?? data['typ'] ?? 'privat').toString();

    if (kontoTyp.toLowerCase() == 'firma' &&
        (data['firmenname'] ?? '').toString().trim().isNotEmpty) {
      return data['firmenname'].toString();
    }

    if ((data['benutzername'] ?? '').toString().trim().isNotEmpty) {
      return data['benutzername'].toString();
    }

    if ((data['name'] ?? '').toString().trim().isNotEmpty) {
      return data['name'].toString();
    }

    return data['email']?.toString() ?? 'Unbekannter Benutzer';
  }

  String _kontoTypAusDaten(Map<String, dynamic> data) {
    final kontoTyp = (data['kontoTyp'] ?? data['typ'] ?? 'privat').toString();
    if (kontoTyp.toLowerCase() == 'firma') return 'firma';
    if ((data['firmenname'] ?? '').toString().trim().isNotEmpty) return 'firma';
    return 'privat';
  }

  String _datumText(dynamic wert) {
    if (wert is! Timestamp) return '-';
    final datum = wert.toDate();
    final tag = datum.day.toString().padLeft(2, '0');
    final monat = datum.month.toString().padLeft(2, '0');
    final jahr = datum.year.toString();
    return '$tag.$monat.$jahr';
  }

  bool _passtZumFilter(Map<String, dynamic> data) {
    final kontoTyp = _kontoTypAusDaten(data);
    final istAdmin = data['isAdmin'] == true;
    final gesperrt = data['gesperrt'] == true;

    if (filter == 'Privat') return kontoTyp == 'privat';
    if (filter == 'Firma') return kontoTyp == 'firma';
    if (filter == 'Admins') return istAdmin;
    if (filter == 'Gesperrt') return gesperrt;
    return true;
  }

  bool _passtZurSuche(Map<String, dynamic> data) {
    final text = suche.trim().toLowerCase();
    if (text.isEmpty) return true;

    final suchText = [
      _nameAusDaten(data),
      data['email'] ?? '',
      data['firmenname'] ?? '',
      data['benutzername'] ?? '',
      data['telefon'] ?? '',
      data['ort'] ?? '',
    ].join(' ').toLowerCase();

    return suchText.contains(text);
  }

  void _detailsAnzeigen({
    required BuildContext context,
    required QueryDocumentSnapshot doc,
    required int inserateAnzahl,
    required int meldungenAnzahl,
  }) {
    final data = doc.data() as Map<String, dynamic>;
    final userId = doc.id;
    final name = _nameAusDaten(data);
    final email = (data['email'] ?? 'Keine E-Mail').toString();
    final kontoTyp = _kontoTypAusDaten(data);
    final istAdmin = data['isAdmin'] == true;
    final gesperrt = data['gesperrt'] == true;
    final telefon = (data['telefon'] ?? '-').toString();
    final ort = (data['ort'] ?? '-').toString();
    final registriert = _datumText(data['erstelltAm']);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
                  name,
                  style: const TextStyle(
                    color: Color(0xff050b2c),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                _detailZeile(Icons.badge_outlined, 'User-ID', userId),
                _detailZeile(Icons.email_outlined, 'E-Mail', email),
                _detailZeile(Icons.person_outline, 'Kontotyp', kontoTyp == 'firma' ? 'Firma' : 'Privat'),
                _detailZeile(Icons.phone_outlined, 'Telefon', telefon),
                _detailZeile(Icons.location_on_outlined, 'Ort', ort),
                _detailZeile(Icons.calendar_month_outlined, 'Registriert', registriert),
                _detailZeile(Icons.inventory_2_outlined, 'Inserate', inserateAnzahl.toString()),
                _detailZeile(Icons.report_outlined, 'Meldungen', meldungenAnzahl.toString()),
                _detailZeile(Icons.verified_user_outlined, 'Status', gesperrt ? 'Gesperrt' : 'Aktiv'),
                _detailZeile(Icons.admin_panel_settings_outlined, 'Admin', istAdmin ? 'Ja' : 'Nein'),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (kontoTyp == 'firma')
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff5b2cff),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FirmenProfilSeite(
                                userId: userId,
                                firmenname: name,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.business, color: Colors.white),
                        label: const Text(
                          'Firma öffnen',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: istAdmin ? Colors.orange : const Color(0xff5b2cff),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        if (istAdmin) {
                          _adminEntfernen(context, userId, name);
                        } else {
                          _adminMachen(context, userId, name);
                        }
                      },
                      icon: Icon(
                        istAdmin ? Icons.admin_panel_settings : Icons.security_outlined,
                        color: Colors.white,
                      ),
                      label: Text(
                        istAdmin ? 'Admin entfernen' : 'Admin machen',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gesperrt ? Colors.green : Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        if (gesperrt) {
                          _benutzerEntsperren(context, userId, name);
                        } else {
                          _benutzerSperren(context, userId, name);
                        }
                      },
                      icon: Icon(
                        gesperrt ? Icons.lock_open : Icons.block,
                        color: Colors.white,
                      ),
                      label: Text(
                        gesperrt ? 'Entsperren' : 'Sperren',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _benutzerLoeschen(context, userId, name);
                      },
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Benutzer löschen',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xff5b2cff), size: 21),
          const SizedBox(width: 10),
          SizedBox(
            width: 105,
            child: Text(
              '$titel:',
              style: const TextStyle(
                color: Color(0xff74788d),
                fontWeight: FontWeight.w800,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      appBar: AppBar(
        backgroundColor: const Color(0xff050b2c),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Benutzerverwaltung',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('erstelltAm', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Fehler beim Laden der Benutzer.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final alleDocs = snapshot.data?.docs ?? [];
          final docs = alleDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _passtZumFilter(data) && _passtZurSuche(data);
          }).toList();

          final firmenAnzahl = alleDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _kontoTypAusDaten(data) == 'firma';
          }).length;

          final gesperrtAnzahl = alleDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['gesperrt'] == true;
          }).length;

          final adminAnzahl = alleDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['isAdmin'] == true;
          }).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _kopfBereich(
                gesamt: alleDocs.length,
                firmen: firmenAnzahl,
                admins: adminAnzahl,
                gesperrt: gesperrtAnzahl,
              ),
              const SizedBox(height: 16),
              _filterBereich(),
              const SizedBox(height: 16),
              Text(
                '${docs.length} Benutzer gefunden',
                style: const TextStyle(
                  color: Color(0xff050b2c),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              if (docs.isEmpty)
                _leerKarte()
              else
                for (final doc in docs) _benutzerKarte(context, doc),
            ],
          );
        },
      ),
    );
  }

  Widget _kopfBereich({
    required int gesamt,
    required int firmen,
    required int admins,
    required int gesperrt,
  }) {
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
          const Icon(
            Icons.people_outline,
            color: Colors.white,
            size: 42,
          ),
          const SizedBox(height: 12),
          const Text(
            'Benutzer verwalten',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$gesamt Benutzer in deiner App',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _statChip('Firmen', firmen.toString(), Icons.business),
              _statChip('Admins', admins.toString(), Icons.admin_panel_settings),
              _statChip('Gesperrt', gesperrt.toString(), Icons.block),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(String titel, String wert, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(width: 7),
          Text(
            '$titel: $wert',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x0f000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
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
              labelText: 'Benutzer suchen',
              hintText: 'Name, Firma, E-Mail, Ort...',
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
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: filter,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Filter',
              prefixIcon: const Icon(
                Icons.filter_list,
                color: Color(0xff5b2cff),
              ),
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

  Widget _benutzerKarte(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final userId = doc.id;

    final name = _nameAusDaten(data);
    final email = (data['email'] ?? 'Keine E-Mail').toString();
    final kontoTyp = _kontoTypAusDaten(data);
    final istAdmin = data['isAdmin'] == true;
    final gesperrt = data['gesperrt'] == true;
    final registriert = _datumText(data['erstelltAm']);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('inserate')
          .where('verkaeuferId', isEqualTo: userId)
          .snapshots(),
      builder: (context, inserateSnapshot) {
        final inserateAnzahl = inserateSnapshot.data?.docs.length ?? 0;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('meldungen')
              .where('verkaeuferId', isEqualTo: userId)
              .snapshots(),
          builder: (context, meldungenSnapshot) {
            final meldungenAnzahl = meldungenSnapshot.data?.docs.length ?? 0;

            return InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                _detailsAnzeigen(
                  context: context,
                  doc: doc,
                  inserateAnzahl: inserateAnzahl,
                  meldungenAnzahl: meldungenAnzahl,
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: gesperrt ? Colors.red.shade200 : const Color(0xffececf4),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0f000000),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: const Color(0xff5b2cff).withOpacity(0.12),
                          child: Icon(
                            kontoTyp == 'firma' ? Icons.business : Icons.person,
                            color: const Color(0xff5b2cff),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xff050b2c),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xff74788d),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _statusChip(
                          gesperrt ? 'Gesperrt' : 'Aktiv',
                          gesperrt ? Colors.red : Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _statusChip(
                          istAdmin ? 'Admin' : (kontoTyp == 'firma' ? 'Firma' : 'Privat'),
                          istAdmin ? Colors.green : const Color(0xff5b2cff),
                        ),
                        _statusChip(
                          'Inserate: $inserateAnzahl',
                          Colors.blue,
                        ),
                        if (meldungenAnzahl > 0)
                          _statusChip(
                            'Meldungen: $meldungenAnzahl',
                            Colors.red,
                          ),
                        _statusChip(
                          'Seit: $registriert',
                          Colors.black87,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (kontoTyp == 'firma') ...[
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FirmenProfilSeite(
                                      userId: userId,
                                      firmenname: name,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.business_outlined),
                              label: const Text('Firma'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xff5b2cff),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              if (istAdmin) {
                                _adminEntfernen(context, userId, name);
                              } else {
                                _adminMachen(context, userId, name);
                              }
                            },
                            icon: Icon(
                              istAdmin ? Icons.admin_panel_settings : Icons.security_outlined,
                            ),
                            label: Text(
                              istAdmin ? 'Admin entfernen' : 'Admin machen',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: istAdmin ? Colors.orange : const Color(0xff5b2cff),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              if (gesperrt) {
                                _benutzerEntsperren(context, userId, name);
                              } else {
                                _benutzerSperren(context, userId, name);
                              }
                            },
                            icon: Icon(
                              gesperrt ? Icons.lock_open : Icons.block,
                            ),
                            label: Text(
                              gesperrt ? 'Entsperren' : 'Sperren',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: gesperrt ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _benutzerLoeschen(context, userId, name),
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Benutzer löschen'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
          Icon(
            Icons.people_outline,
            color: Color(0xff5b2cff),
            size: 46,
          ),
          SizedBox(height: 12),
          Text(
            'Keine passenden Benutzer gefunden.',
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(
          titel,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: farbe,
            ),
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
