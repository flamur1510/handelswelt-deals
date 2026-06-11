import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/produkt.dart';
import 'detail_seite.dart';
import 'firmen_profil_seite.dart';

class AdminInserateSeite extends StatefulWidget {
  const AdminInserateSeite({super.key});

  @override
  State<AdminInserateSeite> createState() => _AdminInserateSeiteState();
}

class _AdminInserateSeiteState extends State<AdminInserateSeite> {
  final sucheController = TextEditingController();
  String statusFilter = 'Alle';

  final statusFilterItems = const [
    'Alle',
    'Aktiv',
    'Gesperrt',
    'Gemeldet',
  ];

  @override
  void dispose() {
    sucheController.dispose();
    super.dispose();
  }

  Future<void> _inseratSperren(
    BuildContext context,
    String inseratId,
    String titel,
  ) async {
    final bestaetigt = await _bestaetigen(
      context: context,
      titel: 'Inserat sperren?',
      text: 'Dieses Inserat wird für Nutzer gesperrt, bleibt aber im System erhalten.',
      buttonText: 'Sperren',
      farbe: Colors.orange,
    );

    if (!bestaetigt) return;

    await FirebaseFirestore.instance.collection('inserate').doc(inseratId).set({
      'status': 'gesperrt',
      'gesperrt': true,
      'aktualisiertAm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$titel wurde gesperrt.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _inseratFreigeben(
    BuildContext context,
    String inseratId,
    String titel,
  ) async {
    final bestaetigt = await _bestaetigen(
      context: context,
      titel: 'Inserat freigeben?',
      text: 'Dieses Inserat wird wieder für Nutzer sichtbar gemacht.',
      buttonText: 'Freigeben',
      farbe: Colors.green,
    );

    if (!bestaetigt) return;

    await FirebaseFirestore.instance.collection('inserate').doc(inseratId).set({
      'status': 'aktiv',
      'gesperrt': false,
      'gemeldet': false,
      'aktualisiertAm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$titel wurde wieder freigegeben.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _inseratLoeschen(
    BuildContext context,
    String inseratId,
    String titel,
  ) async {
    final bestaetigt = await _bestaetigen(
      context: context,
      titel: 'Inserat löschen?',
      text: 'Dieses Inserat wird dauerhaft gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.',
      buttonText: 'Löschen',
      farbe: Colors.red,
    );

    if (!bestaetigt) return;

    await FirebaseFirestore.instance.collection('inserate').doc(inseratId).delete();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$titel wurde gelöscht.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _text(Map<String, dynamic> data, String feld, String fallback) {
    final wert = data[feld];
    if (wert == null) return fallback;
    final text = wert.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  int _zahl(String text) {
    return int.tryParse(
          text
              .replaceAll('€', '')
              .replaceAll('.', '')
              .replaceAll(',', '')
              .replaceAll('km', '')
              .replaceAll('m²', '')
              .trim(),
        ) ??
        0;
  }

  bool _istGesperrt(Map<String, dynamic> data) {
    final status = _text(data, 'status', 'aktiv').toLowerCase();
    return data['gesperrt'] == true || status == 'gesperrt';
  }

  bool _istGemeldet(Map<String, dynamic> data) {
    final status = _text(data, 'status', 'aktiv').toLowerCase();
    return data['gemeldet'] == true || status == 'gemeldet';
  }

  bool _passtZumStatus(Map<String, dynamic> data) {
    final gesperrt = _istGesperrt(data);
    final gemeldet = _istGemeldet(data);

    if (statusFilter == 'Alle') return true;
    if (statusFilter == 'Aktiv') return !gesperrt && !gemeldet;
    if (statusFilter == 'Gesperrt') return gesperrt;
    if (statusFilter == 'Gemeldet') return gemeldet;

    return true;
  }

  bool _passtZurSuche(Map<String, dynamic> data) {
    final suche = sucheController.text.trim().toLowerCase();
    if (suche.isEmpty) return true;

    final suchText = [
      data['titel'],
      data['kategorie'],
      data['unterkategorie'],
      data['detailUnterkategorie'],
      data['ort'],
      data['preis'],
      data['typ'],
      data['verkaeuferEmail'],
      data['firmenname'],
      data['verkaeuferName'],
      data['marke'],
      data['modell'],
    ].whereType<Object>().join(' ').toLowerCase();

    return suchText.contains(suche);
  }

  void _inseratOeffnen(BuildContext context, QueryDocumentSnapshot doc) {
    final produkt = Produkt.fromFirestore(doc);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailSeite(produkt: produkt),
      ),
    );
  }

  void _verkaeuferOeffnen(BuildContext context, Map<String, dynamic> data) {
    final verkaeuferId = (data['verkaeuferId'] ?? '').toString().trim();
    if (verkaeuferId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verkäufer-ID fehlt.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final firmenname = (data['firmenname'] ?? data['verkaeuferName'] ?? 'Firma')
        .toString()
        .trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FirmenProfilSeite(
          userId: verkaeuferId,
          firmenname: firmenname.isEmpty ? 'Firma' : firmenname,
        ),
      ),
    );
  }

  void _detailsAnzeigen({
    required BuildContext context,
    required QueryDocumentSnapshot doc,
  }) {
    final data = doc.data() as Map<String, dynamic>;
    final inseratId = doc.id;

    final titel = _text(data, 'titel', 'Ohne Titel');
    final kategorie = _text(data, 'kategorie', 'Keine Kategorie');
    final unterkategorie = _text(data, 'unterkategorie', '-');
    final preis = _text(data, 'preis', 'Kein Preis');
    final ort = _text(data, 'ort', 'Kein Ort');
    final ersteller = _text(
      data,
      'firmenname',
      _text(data, 'verkaeuferEmail', _text(data, 'verkaeuferName', 'Unbekannt')),
    );

    final gesperrt = _istGesperrt(data);
    final gemeldet = _istGemeldet(data);
    final status = gesperrt ? 'Gesperrt' : (gemeldet ? 'Gemeldet' : 'Aktiv');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
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
                  titel,
                  style: const TextStyle(
                    color: Color(0xff050b2c),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                _detailZeile(Icons.category_outlined, 'Kategorie', kategorie),
                _detailZeile(Icons.account_tree_outlined, 'Unterkategorie', unterkategorie),
                _detailZeile(Icons.euro_outlined, 'Preis', preis),
                _detailZeile(Icons.location_on_outlined, 'Ort', ort),
                _detailZeile(Icons.verified_outlined, 'Status', status),
                _detailZeile(Icons.person_outline, 'Ersteller', ersteller),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _bottomButton(
                      icon: Icons.open_in_new,
                      text: 'Inserat öffnen',
                      farbe: const Color(0xff5b2cff),
                      onPressed: () {
                        Navigator.pop(context);
                        _inseratOeffnen(context, doc);
                      },
                    ),
                    _bottomButton(
                      icon: Icons.business_outlined,
                      text: 'Verkäufer öffnen',
                      farbe: const Color(0xff050b2c),
                      onPressed: () {
                        Navigator.pop(context);
                        _verkaeuferOeffnen(context, data);
                      },
                    ),
                    _bottomButton(
                      icon: gesperrt ? Icons.lock_open : Icons.block,
                      text: gesperrt ? 'Freigeben' : 'Sperren',
                      farbe: gesperrt ? Colors.green : Colors.orange,
                      onPressed: () {
                        Navigator.pop(context);
                        if (gesperrt) {
                          _inseratFreigeben(context, inseratId, titel);
                        } else {
                          _inseratSperren(context, inseratId, titel);
                        }
                      },
                    ),
                    _bottomButton(
                      icon: Icons.delete_outline,
                      text: 'Löschen',
                      farbe: Colors.red,
                      onPressed: () {
                        Navigator.pop(context);
                        _inseratLoeschen(context, inseratId, titel);
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

  Widget _bottomButton({
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
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
                    text: wert,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      appBar: AppBar(
        backgroundColor: const Color(0xff050b2c),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Inseratverwaltung',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('inserate')
            .orderBy('erstelltAm', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Fehler beim Laden der Inserate.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xff5b2cff),
              ),
            );
          }

          final alleDocs = snapshot.data?.docs ?? [];
          final docs = alleDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _passtZumStatus(data) && _passtZurSuche(data);
          }).toList();

          final gesperrtAnzahl = alleDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _istGesperrt(data);
          }).length;

          final gemeldetAnzahl = alleDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _istGemeldet(data);
          }).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _kopfBereich(
                gesamt: alleDocs.length,
                angezeigt: docs.length,
                gesperrt: gesperrtAnzahl,
                gemeldet: gemeldetAnzahl,
              ),
              const SizedBox(height: 16),
              _filterBereich(),
              const SizedBox(height: 16),
              if (docs.isEmpty)
                _leerKarte()
              else
                for (final doc in docs) _inseratKarte(context, doc),
            ],
          );
        },
      ),
    );
  }

  Widget _kopfBereich({
    required int gesamt,
    required int angezeigt,
    required int gesperrt,
    required int gemeldet,
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
            Icons.inventory_2_outlined,
            color: Colors.white,
            size: 42,
          ),
          const SizedBox(height: 12),
          const Text(
            'Inserate verwalten',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$angezeigt von $gesamt Inseraten angezeigt',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _kopfChip('Gesamt', '$gesamt'),
              _kopfChip('Gesperrt', '$gesperrt'),
              _kopfChip('Gemeldet', '$gemeldet'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kopfChip(String titel, String wert) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        '$titel: $wert',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _filterBereich() {
    return Container(
      padding: const EdgeInsets.all(16),
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
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Inserate suchen',
              hintText: 'Titel, Firma, Ort oder Kategorie',
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
            value: statusFilter,
            items: statusFilterItems.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                statusFilter = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Status filtern',
              prefixIcon: const Icon(
                Icons.filter_alt_outlined,
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
        ],
      ),
    );
  }

  Widget _inseratKarte(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final inseratId = doc.id;

    final titel = _text(data, 'titel', 'Ohne Titel');
    final kategorie = _text(data, 'kategorie', 'Keine Kategorie');
    final unterkategorie = _text(data, 'unterkategorie', '');
    final preis = _text(data, 'preis', 'Kein Preis');
    final ort = _text(data, 'ort', 'Kein Ort');
    final bild = _text(data, 'bild', '');
    final firma = _text(data, 'firmenname', _text(data, 'verkaeuferEmail', 'Unbekannter Verkäufer'));

    final gesperrt = _istGesperrt(data);
    final istGemeldet = _istGemeldet(data);

    final preisText = preis.endsWith('€') ? preis : '$preis €';

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        _detailsAnzeigen(context: context, doc: doc);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: istGemeldet || gesperrt
                ? Colors.red.shade200
                : const Color(0xffececf4),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: bild.isEmpty
                      ? Container(
                          width: 76,
                          height: 76,
                          color: const Color(0xfff1edff),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: Color(0xff5b2cff),
                          ),
                        )
                      : Image.network(
                          bild,
                          width: 76,
                          height: 76,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 76,
                              height: 76,
                              color: const Color(0xfff1edff),
                              child: const Icon(
                                Icons.inventory_2_outlined,
                                color: Color(0xff5b2cff),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xff050b2c),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        unterkategorie.isEmpty
                            ? '$ort • $kategorie'
                            : '$ort • $kategorie • $unterkategorie',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xff74788d),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        firma,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xff74788d),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _statusChip(
                      gesperrt ? 'Gesperrt' : (istGemeldet ? 'Gemeldet' : 'Aktiv'),
                      gesperrt || istGemeldet ? Colors.red : Colors.green,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      preisText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff5b2cff),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _aktionButton(
                  icon: Icons.open_in_new,
                  text: 'Öffnen',
                  farbe: const Color(0xff5b2cff),
                  onPressed: () => _inseratOeffnen(context, doc),
                ),
                _aktionButton(
                  icon: Icons.business_outlined,
                  text: 'Verkäufer',
                  farbe: const Color(0xff050b2c),
                  onPressed: () => _verkaeuferOeffnen(context, data),
                ),
                _aktionButton(
                  icon: gesperrt ? Icons.lock_open : Icons.block,
                  text: gesperrt ? 'Freigeben' : 'Sperren',
                  farbe: gesperrt ? Colors.green : Colors.orange,
                  onPressed: () {
                    if (gesperrt) {
                      _inseratFreigeben(context, inseratId, titel);
                    } else {
                      _inseratSperren(context, inseratId, titel);
                    }
                  },
                ),
                _aktionButton(
                  icon: Icons.delete_outline,
                  text: 'Löschen',
                  farbe: Colors.red,
                  onPressed: () => _inseratLoeschen(context, inseratId, titel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _aktionButton({
    required IconData icon,
    required String text,
    required Color farbe,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: farbe,
        side: BorderSide(color: farbe.withOpacity(0.45)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _statusChip(String status, Color farbe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: farbe.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
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
            Icons.inventory_2_outlined,
            color: Color(0xff5b2cff),
            size: 46,
          ),
          SizedBox(height: 12),
          Text(
            'Keine passenden Inserate gefunden.',
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
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: farbe,
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
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
