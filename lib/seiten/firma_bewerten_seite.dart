import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirmaBewertenSeite extends StatefulWidget {
  final String firmaId;
  final String firmaName;

  const FirmaBewertenSeite({
    super.key,
    required this.firmaId,
    required this.firmaName,
  });

  @override
  State<FirmaBewertenSeite> createState() => _FirmaBewertenSeiteState();
}

class _FirmaBewertenSeiteState extends State<FirmaBewertenSeite> {
  final textController = TextEditingController();

  int sterne = 5;
  bool wirdGespeichert = false;
  bool vorhandeneBewertungGeladen = false;
  bool hatSchonBewertet = false;
  int zeichen = 0;

  static const int minZeichen = 20;
  static const int maxZeichen = 1000;

  @override
  void initState() {
    super.initState();
    textController.addListener(() {
      setState(() {
        zeichen = textController.text.length;
      });
    });
    vorhandeneBewertungLaden();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future<void> vorhandeneBewertungLaden() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final bewertungId = "${widget.firmaId}_${user.uid}";
    final doc = await FirebaseFirestore.instance
        .collection("bewertungen")
        .doc(bewertungId)
        .get();

    if (!mounted) return;

    if (doc.exists) {
      final data = doc.data() ?? {};
      final vorhandeneSterne = data["sterne"];
      final vorhandenerText = (data["text"] ?? "").toString();

      setState(() {
        hatSchonBewertet = true;
        sterne = vorhandeneSterne is int ? vorhandeneSterne.clamp(1, 5) : 5;
        textController.text = vorhandenerText;
        zeichen = vorhandenerText.length;
        vorhandeneBewertungGeladen = true;
      });
    } else {
      setState(() {
        vorhandeneBewertungGeladen = true;
      });
    }
  }

  Future<bool> hatKontaktMitFirma(User user) async {
    final chatSnapshot = await FirebaseFirestore.instance
        .collection("chats")
        .where("teilnehmer", arrayContains: user.uid)
        .get();

    for (final doc in chatSnapshot.docs) {
      final daten = doc.data();
      final teilnehmer = List<String>.from(daten["teilnehmer"] ?? []);

      if (teilnehmer.contains(widget.firmaId)) {
        return true;
      }
    }

    return false;
  }

  Future<void> bewertungSpeichern() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _snack("Bitte zuerst einloggen.", istFehler: true);
      return;
    }

    if (user.uid == widget.firmaId) {
      _snack("Du kannst deine eigene Firma nicht bewerten.", istFehler: true);
      return;
    }

    final text = textController.text.trim();

    if (text.length < minZeichen) {
      _snack(
        "Bitte schreibe mindestens $minZeichen Zeichen.",
        istFehler: true,
      );
      return;
    }

    if (text.length > maxZeichen) {
      _snack(
        "Deine Bewertung darf maximal $maxZeichen Zeichen haben.",
        istFehler: true,
      );
      return;
    }

    setState(() {
      wirdGespeichert = true;
    });

    try {
      final hatKontakt = await hatKontaktMitFirma(user);

      if (!hatKontakt) {
        if (!mounted) return;
        setState(() {
          wirdGespeichert = false;
        });
        _snack(
          "Du kannst diese Firma erst bewerten, nachdem du mit ihr Kontakt hattest.",
          istFehler: true,
        );
        return;
      }

      final bewertungId = "${widget.firmaId}_${user.uid}";
      final bewertungRef = FirebaseFirestore.instance
          .collection("bewertungen")
          .doc(bewertungId);

      await bewertungRef.set({
        "firmaId": widget.firmaId,
        "firmaName": widget.firmaName,
        "bewerterId": user.uid,
        "bewerterEmail": user.email ?? "",
        "sterne": sterne,
        "text": text,
        "verifizierterKontakt": true,
        "aktualisiertAm": FieldValue.serverTimestamp(),
        "erstelltAm": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance.collection("benachrichtigungen").add({
        "userId": widget.firmaId,
        "titel": hatSchonBewertet ? "Bewertung aktualisiert" : "Neue Bewertung",
        "text": hatSchonBewertet
            ? "Eine Bewertung deiner Firma wurde aktualisiert."
            : "Deine Firma hat eine neue Bewertung erhalten.",
        "typ": "bewertung",
        "gelesen": false,
        "erstelltAm": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _snack(hatSchonBewertet
          ? "Bewertung wurde aktualisiert."
          : "Bewertung gespeichert.");

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _snack("Fehler beim Speichern: $e", istFehler: true);
    }

    if (mounted) {
      setState(() {
        wirdGespeichert = false;
      });
    }
  }

  void _snack(String text, {bool istFehler = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: istFehler ? Colors.red : null,
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
          "Firma bewerten",
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
          _durchschnittKarte(),
          const SizedBox(height: 16),
          _hinweisKarte(),
          const SizedBox(height: 16),
          if (!vorhandeneBewertungGeladen)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: Color(0xff5b2cff)),
              ),
            )
          else
            _bewertungsKarte(),
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
            widget.firmaName,
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  hatSchonBewertet
                      ? "Bewertung bearbeiten"
                      : "Verifizierte Firma bewerten",
                  style: const TextStyle(
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

  Widget _durchschnittKarte() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("bewertungen")
          .where("firmaId", isEqualTo: widget.firmaId)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        double summe = 0;

        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final wert = data["sterne"];
          if (wert is int) summe += wert;
          if (wert is double) summe += wert;
        }

        final durchschnitt = docs.isEmpty ? 0.0 : summe / docs.length;
        final text = docs.isEmpty ? "Noch keine Bewertungen" : "${durchschnitt.toStringAsFixed(1)} / 5";

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
          child: Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: Color(0xfffff6df),
                child: Icon(Icons.star, color: Colors.orange, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        color: Color(0xff050b2c),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "${docs.length} Bewertung${docs.length == 1 ? "" : "en"}",
                      style: const TextStyle(
                        color: Color(0xff74788d),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _sterneText(durchschnitt.round()),
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _hinweisKarte() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xfffff6df),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffffe5a8)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Bewertungen sind nur möglich, wenn du vorher mit dieser Firma Kontakt hattest. Deine Bewertung kann später aktualisiert werden.",
              style: TextStyle(
                color: Color(0xff050b2c),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bewertungsKarte() {
    final zuKurz = textController.text.trim().length < minZeichen;
    final zuLang = textController.text.trim().length > maxZeichen;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hatSchonBewertet ? "Bewertung bearbeiten" : "Deine Bewertung",
            style: const TextStyle(
              color: Color(0xff050b2c),
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _sterneBeschreibung(),
            style: const TextStyle(
              color: Color(0xff74788d),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final wert = index + 1;
              return IconButton(
                onPressed: wirdGespeichert
                    ? null
                    : () {
                        setState(() {
                          sterne = wert;
                        });
                      },
                icon: Icon(
                  wert <= sterne ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                  size: 38,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: textController,
            enabled: !wirdGespeichert,
            maxLines: 6,
            maxLength: maxZeichen,
            decoration: InputDecoration(
              labelText: "Bewertung schreiben",
              hintText: "Wie war deine Erfahrung mit dieser Firma?",
              alignLabelWithHint: true,
              filled: true,
              fillColor: const Color(0xfff7f7fb),
              errorText: zuLang
                  ? "Maximal $maxZeichen Zeichen erlaubt."
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  zuKurz
                      ? "Noch ${minZeichen - textController.text.trim().length} Zeichen mindestens."
                      : "Bewertung ist lang genug.",
                  style: TextStyle(
                    color: zuKurz ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                "$zeichen / $maxZeichen",
                style: const TextStyle(
                  color: Color(0xff74788d),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              icon: wirdGespeichert
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      hatSchonBewertet
                          ? Icons.update_outlined
                          : Icons.send_outlined,
                      color: Colors.white,
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff5b2cff),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: wirdGespeichert ? null : bewertungSpeichern,
              label: Text(
                wirdGespeichert
                    ? "Wird gespeichert..."
                    : (hatSchonBewertet
                        ? "Bewertung aktualisieren"
                        : "Bewertung absenden"),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _sterneBeschreibung() {
    switch (sterne) {
      case 1:
        return "Sehr schlechte Erfahrung";
      case 2:
        return "Schlechte Erfahrung";
      case 3:
        return "Okay";
      case 4:
        return "Gute Erfahrung";
      case 5:
      default:
        return "Sehr gute Erfahrung";
    }
  }

  String _sterneText(int anzahl) {
    final sichereAnzahl = anzahl.clamp(0, 5);
    return "★" * sichereAnzahl + "☆" * (5 - sichereAnzahl);
  }
}
