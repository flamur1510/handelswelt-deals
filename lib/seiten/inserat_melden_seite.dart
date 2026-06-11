import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InseratMeldenSeite extends StatefulWidget {
  final String inseratId;
  final String titel;
  final String verkaeuferId;

  const InseratMeldenSeite({
    super.key,
    required this.inseratId,
    required this.titel,
    required this.verkaeuferId,
  });

  @override
  State<InseratMeldenSeite> createState() => _InseratMeldenSeiteState();
}

class _InseratMeldenSeiteState extends State<InseratMeldenSeite> {
  String grund = "Betrug";
  bool wirdGespeichert = false;

  final gruende = [
    "Betrug",
    "Spam",
    "Falsche Kategorie",
    "Verbotener Inhalt",
    "Duplikat",
    "Sonstiges",
  ];

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

    if (widget.inseratId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Inserat-ID fehlt."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (user.uid == widget.verkaeuferId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Du kannst dein eigenes Inserat nicht melden."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      wirdGespeichert = true;
    });

    try {
      await FirebaseFirestore.instance.collection("meldungen").add({
        "inseratId": widget.inseratId,
        "titel": widget.titel,
        "verkaeuferId": widget.verkaeuferId,
        "melderId": user.uid,
        "melderEmail": user.email ?? "",
        "grund": grund,
        "status": "offen",
        "typ": "inserat",
        "erstelltAm": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Meldung erfolgreich gesendet."),
          backgroundColor: Colors.green,
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
          "Inserat melden",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
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
                "Warum möchtest du dieses Inserat melden?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: grund,
                decoration: InputDecoration(
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
              const Spacer(),
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
                    wirdGespeichert ? "Wird gesendet..." : "Meldung senden",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
