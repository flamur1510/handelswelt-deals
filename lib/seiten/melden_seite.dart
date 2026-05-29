import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/produkt.dart';

class MeldenSeite extends StatefulWidget {
  final Produkt produkt;

  const MeldenSeite({
    super.key,
    required this.produkt,
  });

  @override
  State<MeldenSeite> createState() => _MeldenSeiteState();
}

class _MeldenSeiteState extends State<MeldenSeite> {
  final kommentarController = TextEditingController();

  String grund = "Betrug";
  bool speichert = false;

  Future<void> melden() async {
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      speichert = true;
    });

    try {
      await FirebaseFirestore.instance.collection("meldungen").add({
        "produktId": widget.produkt.id,
        "produktTitel": widget.produkt.titel,
        "verkaeuferId": widget.produkt.verkaeuferId,
        "verkaeuferEmail": widget.produkt.verkaeuferEmail,
        "melderId": user?.uid ?? "",
        "melderEmail": user?.email ?? "Gast",
        "grund": grund,
        "kommentar": kommentarController.text.trim(),
        "status": "offen",
        "erstelltAm": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inserat wurde gemeldet")),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler: $e")),
      );
    }

    if (mounted) {
      setState(() {
        speichert = false;
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
        title: const Text("Inserat melden"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.produkt.titel,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          DropdownButtonFormField<String>(
            value: grund,
            decoration: const InputDecoration(
              labelText: "Grund",
              filled: true,
              fillColor: Colors.white,
            ),
            items: const [
              DropdownMenuItem(value: "Betrug", child: Text("Betrug")),
              DropdownMenuItem(value: "Spam", child: Text("Spam")),
              DropdownMenuItem(
                value: "Falsche Angaben",
                child: Text("Falsche Angaben"),
              ),
              DropdownMenuItem(
                value: "Verbotener Inhalt",
                child: Text("Verbotener Inhalt"),
              ),
              DropdownMenuItem(value: "Sonstiges", child: Text("Sonstiges")),
            ],
            onChanged: (wert) {
              setState(() {
                grund = wert!;
              });
            },
          ),

          const SizedBox(height: 20),

          TextField(
            controller: kommentarController,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: "Kommentar",
              hintText: "Beschreibe kurz das Problem...",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),

          const SizedBox(height: 30),

          ElevatedButton.icon(
            icon: const Icon(Icons.report, color: Colors.white),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.all(18),
            ),
            onPressed: speichert ? null : melden,
            label: Text(
              speichert ? "Wird gemeldet..." : "Melden",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}