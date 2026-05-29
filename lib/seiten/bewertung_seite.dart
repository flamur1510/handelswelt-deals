import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BewertungSeite extends StatefulWidget {
  final String verkaeuferId;
  final String verkaeuferEmail;

  const BewertungSeite({
    super.key,
    required this.verkaeuferId,
    required this.verkaeuferEmail,
  });

  @override
  State<BewertungSeite> createState() => _BewertungSeiteState();
}

class _BewertungSeiteState extends State<BewertungSeite> {
  int sterne = 5;
  final kommentarController = TextEditingController();
  bool speichern = false;

  Future<void> bewertungSpeichern() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bitte zuerst einloggen."),
        ),
      );
      return;
    }

    setState(() {
      speichern = true;
    });

    try {
      await FirebaseFirestore.instance.collection("bewertungen").add({
        "verkaeuferId": widget.verkaeuferId,
        "verkaeuferEmail": widget.verkaeuferEmail,
        "bewerterId": user.uid,
        "bewerterEmail": user.email ?? "",
        "sterne": sterne,
        "kommentar": kommentarController.text.trim(),
        "erstelltAm": FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection("benachrichtigungen").add({
        "userId": widget.verkaeuferId,
        "typ": "bewertung",
        "titel": "Neue Bewertung",
        "text":
            "${user.email ?? "Ein Nutzer"} hat dich mit $sterne Sternen bewertet.",
        "gelesen": false,
        "erstelltAm": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bewertung wurde gespeichert."),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Fehler: $e"),
        ),
      );
    }

    if (mounted) {
      setState(() {
        speichern = false;
      });
    }
  }

  @override
  void dispose() {
    kommentarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f3ff),
      appBar: AppBar(
        title: const Text("Firma bewerten"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              widget.verkaeuferEmail,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= 5; i++)
                  IconButton(
                    icon: Icon(
                      i <= sterne ? Icons.star : Icons.star_border,
                      size: 42,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        sterne = i;
                      });
                    },
                  ),
              ],
            ),

            const SizedBox(height: 25),

            TextField(
              controller: kommentarController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Kommentar",
                hintText: "Wie war deine Erfahrung?",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.star,
                  color: Colors.white,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.all(18),
                ),
                onPressed: speichern ? null : bewertungSpeichern,
                label: Text(
                  speichern ? "Speichert..." : "Bewertung absenden",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}