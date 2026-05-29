import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/produkt.dart';

class InseratBearbeitenSeite extends StatefulWidget {
  final Produkt produkt;

  const InseratBearbeitenSeite({
    super.key,
    required this.produkt,
  });

  @override
  State<InseratBearbeitenSeite> createState() =>
      _InseratBearbeitenSeiteState();
}

class _InseratBearbeitenSeiteState extends State<InseratBearbeitenSeite> {
  late TextEditingController titelController;
  late TextEditingController preisController;
  late TextEditingController ortController;
  late TextEditingController beschreibungController;

  bool speichert = false;

  @override
  void initState() {
    super.initState();

    titelController = TextEditingController(text: widget.produkt.titel);
    preisController = TextEditingController(text: widget.produkt.preis);
    ortController = TextEditingController(text: widget.produkt.ort);
    beschreibungController =
        TextEditingController(text: widget.produkt.beschreibung);
  }

  Future<void> speichern() async {
    setState(() {
      speichert = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection("inserate")
          .doc(widget.produkt.id)
          .update({
        "titel": titelController.text.trim(),
        "preis": preisController.text.trim(),
        "ort": ortController.text.trim(),
        "beschreibung": beschreibungController.text.trim(),
      });

      widget.produkt.titel = titelController.text.trim();
      widget.produkt.preis = preisController.text.trim();
      widget.produkt.ort = ortController.text.trim();
      widget.produkt.beschreibung = beschreibungController.text.trim();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inserat gespeichert")),
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
    titelController.dispose();
    preisController.dispose();
    ortController.dispose();
    beschreibungController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f3ff),
      appBar: AppBar(
        title: const Text("Inserat bearbeiten"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: titelController,
            decoration: const InputDecoration(labelText: "Titel"),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: preisController,
            decoration: const InputDecoration(labelText: "Preis"),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: ortController,
            decoration: const InputDecoration(labelText: "Ort"),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: beschreibungController,
            maxLines: 5,
            decoration: const InputDecoration(labelText: "Beschreibung"),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.all(18),
            ),
            onPressed: speichert ? null : speichern,
            child: Text(
              speichert ? "Speichert..." : "Speichern",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}