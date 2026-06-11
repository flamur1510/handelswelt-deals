import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'gewerbeschein_pruefen_seite.dart';

class FirmenVerifizierenSeite extends StatelessWidget {
  const FirmenVerifizierenSeite({super.key});

  Future<void> _firmaVerifizieren(
    BuildContext context,
    String userId,
    String firmenname,
  ) async {
    await FirebaseFirestore.instance.collection("users").doc(userId).set({
      "firmaVerifiziert": true,
      "verifizierungStatus": "verifiziert",
      "aktualisiertAm": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$firmenname wurde verifiziert"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _firmaAblehnen(
    BuildContext context,
    String userId,
    String firmenname,
  ) async {
    await FirebaseFirestore.instance.collection("users").doc(userId).set({
      "firmaVerifiziert": false,
      "verifizierungStatus": "abgelehnt",
      "aktualisiertAm": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$firmenname wurde abgelehnt"),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _gewerbescheinOeffnen(
    BuildContext context,
    String userId,
    String firmenname,
    String gewerbescheinUrl,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GewerbescheinPruefenSeite(
          userId: userId,
          firmenname: firmenname,
          gewerbescheinUrl: gewerbescheinUrl,
        ),
      ),
    );
  }

  String _text(Map<String, dynamic> data, String feld, String fallback) {
    final wert = data[feld];
    if (wert == null) return fallback;
    final text = wert.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String _firmenname(Map<String, dynamic> data) {
    final name = _text(data, "firmenname", "");
    if (name.isNotEmpty) return name;

    return _text(data, "benutzername", "Unbekannte Firma");
  }

  void _detailsAnzeigen({
    required BuildContext context,
    required String userId,
    required String firmenname,
    required String email,
    required String telefon,
    required String ansprechpartner,
    required String adresse,
    required String uidNummer,
    required String webseite,
    required String status,
    required String gewerbescheinUrl,
  }) {
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
                  firmenname,
                  style: const TextStyle(
                    color: Color(0xff050b2c),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                _detailZeile(Icons.email_outlined, "E-Mail", email),
                _detailZeile(Icons.phone_outlined, "Telefon", telefon),
                _detailZeile(
                  Icons.person_outline,
                  "Ansprechpartner",
                  ansprechpartner,
                ),
                _detailZeile(Icons.location_on_outlined, "Adresse", adresse),
                _detailZeile(Icons.badge_outlined, "UID/USt-ID", uidNummer),
                _detailZeile(Icons.language_outlined, "Webseite", webseite),
                _detailZeile(Icons.verified_outlined, "Status", status),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _gewerbescheinOeffnen(
                        context,
                        userId,
                        firmenname,
                        gewerbescheinUrl,
                      );
                    },
                    icon: const Icon(Icons.description_outlined),
                    label: const Text("Gewerbeschein prüfen"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff5b2cff),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _firmaVerifizieren(context, userId, firmenname);
                        },
                        icon: const Icon(Icons.check),
                        label: const Text("Verifizieren"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _firmaAblehnen(context, userId, firmenname);
                        },
                        icon: const Icon(Icons.close),
                        label: const Text("Ablehnen"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
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
                    text: "$titel: ",
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
    final query = FirebaseFirestore.instance
        .collection("users")
        .where("kontoTyp", isEqualTo: "firma")
        .where("firmaVerifiziert", isEqualTo: false)
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      appBar: AppBar(
        backgroundColor: const Color(0xff050b2c),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Firmen verifizieren",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Fehler beim Laden der Firmen."),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _kopfBereich(docs.length),
              const SizedBox(height: 16),
              if (docs.isEmpty)
                _leerKarte()
              else
                for (final doc in docs) _firmaKarte(context, doc),
            ],
          );
        },
      ),
    );
  }

  Widget _kopfBereich(int anzahl) {
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
            Icons.verified_user_outlined,
            color: Colors.white,
            size: 42,
          ),
          const SizedBox(height: 12),
          const Text(
            "Firmen-Verifizierung",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "$anzahl Firmen warten auf Prüfung",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _firmaKarte(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final userId = doc.id;

    final firmenname = _firmenname(data);
    final email = _text(data, "email", "Keine E-Mail");
    final telefon = _text(data, "telefon", "Keine Telefonnummer");
    final ansprechpartner =
        _text(data, "ansprechpartner", "Kein Ansprechpartner");
    final uidNummer = _text(data, "uidNummer", "Keine UID/USt-ID");
    final webseite = _text(data, "webseite", "Keine Webseite");
    final gewerbescheinUrl = _text(data, "gewerbescheinUrl", "");

    final strasse = _text(data, "strasse", "");
    final plz = _text(data, "plz", "");
    final ort = _text(data, "ort", "");
    final land = _text(data, "land", "Österreich");

    final adresse = [
      strasse,
      [plz, ort].where((e) => e.trim().isNotEmpty).join(" "),
      land,
    ].where((e) => e.trim().isNotEmpty).join(", ");

    final status = _text(data, "verifizierungStatus", "ausstehend");

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        _detailsAnzeigen(
          context: context,
          userId: userId,
          firmenname: firmenname,
          email: email,
          telefon: telefon,
          ansprechpartner: ansprechpartner,
          adresse: adresse.isEmpty ? "Keine Adresse" : adresse,
          uidNummer: uidNummer,
          webseite: webseite,
          status: status,
          gewerbescheinUrl: gewerbescheinUrl,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xffececf4),
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
                const Icon(
                  Icons.business,
                  color: Color(0xff5b2cff),
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    firmenname,
                    style: const TextStyle(
                      color: Color(0xff050b2c),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _statusChip("Ausstehend", Colors.orange),
              ],
            ),
            const SizedBox(height: 12),
            Text("E-Mail: $email"),
            const SizedBox(height: 4),
            Text("Telefon: $telefon"),
            const SizedBox(height: 4),
            Text("Ort: ${ort.isEmpty ? "Kein Ort" : ort}"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xfff4f4fb),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    color: Color(0xff5b2cff),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      gewerbescheinUrl.isEmpty
                          ? "Kein Gewerbeschein hochgeladen"
                          : "Gewerbeschein prüfen",
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xff050b2c),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _gewerbescheinOeffnen(
                        context,
                        userId,
                        firmenname,
                        gewerbescheinUrl,
                      );
                    },
                    child: const Text("Öffnen"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _firmaVerifizieren(context, userId, firmenname);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text("Verifizieren"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _firmaAblehnen(context, userId, firmenname);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text("Ablehnen"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
            Icons.verified_user_outlined,
            color: Color(0xff5b2cff),
            size: 46,
          ),
          SizedBox(height: 12),
          Text(
            "Keine Firmen warten auf Verifizierung.",
            textAlign: TextAlign.center,
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