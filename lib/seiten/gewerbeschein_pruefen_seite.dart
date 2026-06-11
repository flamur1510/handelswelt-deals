import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GewerbescheinPruefenSeite extends StatelessWidget {
  final String userId;
  final String firmenname;
  final String gewerbescheinUrl;

  const GewerbescheinPruefenSeite({
    super.key,
    required this.userId,
    required this.firmenname,
    required this.gewerbescheinUrl,
  });

  Future<void> _verifizieren(BuildContext context) async {
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

    Navigator.pop(context);
  }

  Future<void> _ablehnen(BuildContext context) async {
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

    Navigator.pop(context);
  }

  bool get _hatGewerbeschein => gewerbescheinUrl.trim().isNotEmpty;

  bool get _istBild {
    final url = gewerbescheinUrl.toLowerCase();
    return url.endsWith(".jpg") ||
        url.endsWith(".jpeg") ||
        url.endsWith(".png") ||
        url.endsWith(".webp");
  }

  bool get _istPdf {
    final url = gewerbescheinUrl.toLowerCase();
    return url.endsWith(".pdf");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      appBar: AppBar(
        backgroundColor: const Color(0xff050b2c),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Gewerbeschein prüfen",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _kopfBereich(),
            const SizedBox(height: 20),
            _gewerbescheinBox(),
            const SizedBox(height: 24),
            _aktionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _kopfBereich() {
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
        borderRadius: BorderRadius.circular(24),
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
          Text(
            firmenname,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Prüfe den hochgeladenen Gewerbeschein und entscheide über die Verifizierung.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _gewerbescheinBox() {
    return Container(
      width: double.infinity,
      height: 360,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: !_hatGewerbeschein
            ? _platzhalter(
                icon: Icons.description_outlined,
                titel: "Kein Gewerbeschein",
                text:
                    "Für diese Firma wurde noch kein Gewerbeschein hochgeladen.",
              )
            : _istBild
                ? Image.network(
                    gewerbescheinUrl,
                    width: double.infinity,
                    height: 360,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _platzhalter(
                        icon: Icons.broken_image_outlined,
                        titel: "Bild konnte nicht geladen werden",
                        text:
                            "Prüfe später die Firebase-Storage-URL oder die Berechtigungen.",
                      );
                    },
                  )
                : _istPdf
                    ? _platzhalter(
                        icon: Icons.picture_as_pdf_outlined,
                        titel: "PDF-Gewerbeschein vorhanden",
                        text:
                            "PDF-Anzeige bauen wir im nächsten Schritt mit einem PDF-Viewer ein.",
                      )
                    : _platzhalter(
                        icon: Icons.description_outlined,
                        titel: "Datei vorhanden",
                        text:
                            "Diese Datei ist gespeichert, aber wird noch nicht direkt angezeigt.",
                      ),
      ),
    );
  }

  Widget _platzhalter({
    required IconData icon,
    required String titel,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 88,
            color: const Color(0xff5b2cff),
          ),
          const SizedBox(height: 16),
          Text(
            titel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xff050b2c),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xff74788d),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aktionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _verifizieren(context);
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text("Verifizieren"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              _ablehnen(context);
            },
            icon: const Icon(Icons.close),
            label: const Text("Ablehnen"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(
                color: Colors.red,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text("Zurück"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}