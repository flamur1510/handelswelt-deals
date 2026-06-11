import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirmaMeldenSeite extends StatefulWidget {
  final String firmaId;
  final String firmenname;

  const FirmaMeldenSeite({
    super.key,
    required this.firmaId,
    required this.firmenname,
  });

  @override
  State<FirmaMeldenSeite> createState() => _FirmaMeldenSeiteState();
}

class _FirmaMeldenSeiteState extends State<FirmaMeldenSeite> {
  final beschreibungController = TextEditingController();

  String grund = "Betrugsverdacht";
  bool wirdGespeichert = false;

  final gruende = [
    "Betrugsverdacht",
    "Fake Firma",
    "Falsche Angaben",
    "Spam",
    "Verbotener Inhalt",
    "Sonstiges",
  ];

  @override
  void dispose() {
    beschreibungController.dispose();
    super.dispose();
  }

  Future<void> meldungSenden() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bitte zuerst einloggen."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (user.uid == widget.firmaId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Du kannst deine eigene Firma nicht melden."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      wirdGespeichert = true;
    });

    try {
      await FirebaseFirestore.instance.collection("firmenmeldungen").add({
        "firmaId": widget.firmaId,
        "firmenname": widget.firmenname,
        "melderId": user.uid,
        "melderEmail": user.email ?? "",
        "grund": grund,
        "beschreibung": beschreibungController.text.trim(),
        "status": "offen",
        "erstelltAm": FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection("benachrichtigungen").add({
        "userId": widget.firmaId,
        "titel": "Firmenmeldung",
        "text": "Dein Firmenprofil wurde gemeldet.",
        "typ": "firmenmeldung",
        "gelesen": false,
        "erstelltAm": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Firmenmeldung erfolgreich gesendet."),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Fehler: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        wirdGespeichert = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      appBar: AppBar(
        backgroundColor: const Color(0xff050b2c),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Firma melden",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _kopfbereich(),
          const SizedBox(height: 16),
          _meldeKarte(),
        ],
      ),
    );
  }

  Widget _kopfbereich() {
    return Container(
      padding: const EdgeInsets.all(22),
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
        children: [
          const CircleAvatar(
            radius: 38,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.business,
              color: Color(0xff5b2cff),
              size: 38,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.firmenname,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.flag_outlined,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  "Firmenprofil melden",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _meldeKarte() {
    return Container(
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
          const Text(
            "Warum möchtest du diese Firma melden?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: grund,
            decoration: InputDecoration(
              labelText: "Grund auswählen",
              filled: true,
              fillColor: const Color(0xfff7f7fb),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            items: gruende.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(e),
              );
            }).toList(),
            onChanged: wirdGespeichert
                ? null
                : (value) {
                    if (value == null) return;

                    setState(() {
                      grund = value;
                    });
                  },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: beschreibungController,
            enabled: !wirdGespeichert,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: "Beschreibung optional",
              hintText: "Beschreibe kurz, was auffällig ist.",
              alignLabelWithHint: true,
              filled: true,
              fillColor: const Color(0xfff7f7fb),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: wirdGespeichert ? null : meldungSenden,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: wirdGespeichert
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.flag,
                      color: Colors.white,
                    ),
              label: Text(
                wirdGespeichert ? "Wird gesendet..." : "Firma melden",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
