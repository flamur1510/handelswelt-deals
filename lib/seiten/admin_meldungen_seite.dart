import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMeldungenSeite extends StatelessWidget {
  const AdminMeldungenSeite({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xfffafafe),
        appBar: AppBar(
          backgroundColor: const Color(0xff050b2c),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Admin Meldungen",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Color(0xff5b2cff),
            tabs: [
              Tab(
                icon: Icon(Icons.flag_outlined),
                text: "Inserate",
              ),
              Tab(
                icon: Icon(Icons.business_outlined),
                text: "Firmen",
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _InseratMeldungenTab(),
            _FirmenMeldungenTab(),
          ],
        ),
      ),
    );
  }
}

class _InseratMeldungenTab extends StatelessWidget {
  const _InseratMeldungenTab();

  Future<void> _alsBearbeitetMarkieren(DocumentReference ref) async {
    await ref.update({
      "status": "bearbeitet",
      "bearbeitetAm": FieldValue.serverTimestamp(),
    });
  }

  Future<void> _meldungLoeschen(DocumentReference ref) async {
    await ref.delete();
  }

  Future<void> _inseratLoeschen({
    required BuildContext context,
    required String inseratId,
    required DocumentReference meldungRef,
  }) async {
    if (inseratId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Inserat-ID fehlt."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bestaetigt = await _bestaetigen(
      context: context,
      titel: "Inserat löschen?",
      text:
          "Dieses Inserat wird dauerhaft entfernt. Die Meldung wird danach als bearbeitet markiert.",
      buttonText: "Löschen",
      farbe: Colors.red,
    );

    if (!bestaetigt) return;

    await FirebaseFirestore.instance
        .collection("inserate")
        .doc(inseratId)
        .delete();

    await _alsBearbeitetMarkieren(meldungRef);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Inserat gelöscht und Meldung bearbeitet."),
      ),
    );
  }

  Future<void> _benutzerSperren({
    required BuildContext context,
    required String userId,
    required String inseratId,
    required String titel,
    required String grund,
    required DocumentReference meldungRef,
  }) async {
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Benutzer-ID fehlt."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bestaetigt = await _bestaetigen(
      context: context,
      titel: "Benutzer sperren?",
      text:
          "Dieser Benutzer wird gesperrt. Die Meldung wird danach als bearbeitet markiert.",
      buttonText: "Sperren",
      farbe: Colors.red,
    );

    if (!bestaetigt) return;

    await FirebaseFirestore.instance.collection("gesperrteUser").doc(userId).set({
      "userId": userId,
      "grund": grund.trim().isEmpty ? "Inseratmeldung" : grund.trim(),
      "quelle": "admin_meldungen",
      "inseratId": inseratId,
      "inseratTitel": titel,
      "aktiv": true,
      "erstelltAm": FieldValue.serverTimestamp(),
      "aktualisiertAm": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection("users").doc(userId).set({
      "gesperrt": true,
      "sperrGrund": grund.trim().isEmpty ? "Inseratmeldung" : grund.trim(),
      "gesperrtAm": FieldValue.serverTimestamp(),
      "aktualisiertAm": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection("adminLog").add({
      "aktion": "benutzer_gesperrt",
      "userId": userId,
      "inseratId": inseratId,
      "inseratTitel": titel,
      "grund": grund,
      "erstelltAm": FieldValue.serverTimestamp(),
    });

    await _alsBearbeitetMarkieren(meldungRef);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Benutzer wurde gesperrt und Meldung bearbeitet."),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("meldungen")
          .orderBy("erstelltAm", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xff5b2cff),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              "Keine Inseratmeldungen vorhanden.",
              style: TextStyle(
                color: Color(0xff74788d),
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            final titel = (data["titel"] ?? "Inserat").toString();
            final grund = (data["grund"] ?? "-").toString();
            final melderEmail = (data["melderEmail"] ?? "-").toString();
            final verkaeuferId = (data["verkaeuferId"] ?? "").toString();
            final inseratId = (data["inseratId"] ?? "").toString();
            final status = (data["status"] ?? "offen").toString();

            return _AdminMeldungsKarte(
              icon: Icons.flag_outlined,
              iconFarbe: Colors.red,
              titel: titel,
              status: status,
              zeilen: [
                "Grund: $grund",
                "Gemeldet von: $melderEmail",
                if (verkaeuferId.isNotEmpty) "Verkäufer-ID: $verkaeuferId",
                if (inseratId.isNotEmpty) "Inserat-ID: $inseratId",
              ],
              buttons: [
                _AdminButton(
                  icon: Icons.check_circle_outline,
                  text: "Erledigt",
                  farbe: Colors.green,
                  onPressed: status == "bearbeitet"
                      ? null
                      : () async {
                          await _alsBearbeitetMarkieren(doc.reference);

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Meldung als bearbeitet markiert."),
                            ),
                          );
                        },
                ),
                _AdminButton(
                  icon: Icons.delete_forever,
                  text: "Inserat löschen",
                  farbe: Colors.red,
                  onPressed: inseratId.isEmpty
                      ? null
                      : () {
                          _inseratLoeschen(
                            context: context,
                            inseratId: inseratId,
                            meldungRef: doc.reference,
                          );
                        },
                ),
                _AdminButton(
                  icon: Icons.block,
                  text: "Benutzer sperren",
                  farbe: Colors.deepOrange,
                  onPressed: verkaeuferId.isEmpty
                      ? null
                      : () {
                          _benutzerSperren(
                            context: context,
                            userId: verkaeuferId,
                            inseratId: inseratId,
                            titel: titel,
                            grund: grund,
                            meldungRef: doc.reference,
                          );
                        },
                ),
                _AdminButton(
                  icon: Icons.delete_outline,
                  text: "Meldung löschen",
                  farbe: Colors.black87,
                  onPressed: () async {
                    final bestaetigt = await _bestaetigen(
                      context: context,
                      titel: "Meldung löschen?",
                      text: "Diese Meldung wird dauerhaft entfernt.",
                      buttonText: "Löschen",
                      farbe: Colors.red,
                    );

                    if (!bestaetigt) return;

                    await _meldungLoeschen(doc.reference);

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Meldung gelöscht."),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _FirmenMeldungenTab extends StatelessWidget {
  const _FirmenMeldungenTab();

  Future<void> _alsBearbeitetMarkieren(DocumentReference ref) async {
    await ref.update({
      "status": "bearbeitet",
      "bearbeitetAm": FieldValue.serverTimestamp(),
    });
  }

  Future<void> _meldungLoeschen(DocumentReference ref) async {
    await ref.delete();
  }

  Future<void> _firmaSperren({
    required BuildContext context,
    required String firmaId,
    required String firmenname,
    required DocumentReference meldungRef,
  }) async {
    if (firmaId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Firma-ID fehlt."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bestaetigt = await _bestaetigen(
      context: context,
      titel: "Firma sperren?",
      text:
          "Diese Firma wird in gesperrteUser eingetragen. Die Meldung wird danach als bearbeitet markiert.",
      buttonText: "Sperren",
      farbe: Colors.red,
    );

    if (!bestaetigt) return;

    await FirebaseFirestore.instance.collection("gesperrteUser").doc(firmaId).set({
      "userId": firmaId,
      "firmenname": firmenname,
      "grund": "Firmenmeldung",
      "erstelltAm": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _alsBearbeitetMarkieren(meldungRef);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Firma gesperrt und Meldung bearbeitet."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("firmenmeldungen")
          .orderBy("erstelltAm", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xff5b2cff),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              "Keine Firmenmeldungen vorhanden.",
              style: TextStyle(
                color: Color(0xff74788d),
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            final firmenname = (data["firmenname"] ?? "Firma").toString();
            final firmaId = (data["firmaId"] ?? "").toString();
            final grund = (data["grund"] ?? "-").toString();
            final beschreibung = (data["beschreibung"] ?? "").toString();
            final melderEmail = (data["melderEmail"] ?? "-").toString();
            final status = (data["status"] ?? "offen").toString();

            return _AdminMeldungsKarte(
              icon: Icons.business_outlined,
              iconFarbe: Colors.orange,
              titel: firmenname,
              status: status,
              zeilen: [
                "Grund: $grund",
                "Gemeldet von: $melderEmail",
                if (firmaId.isNotEmpty) "Firma-ID: $firmaId",
                if (beschreibung.trim().isNotEmpty)
                  "Beschreibung: $beschreibung",
              ],
              buttons: [
                _AdminButton(
                  icon: Icons.check_circle_outline,
                  text: "Erledigt",
                  farbe: Colors.green,
                  onPressed: status == "bearbeitet"
                      ? null
                      : () async {
                          await _alsBearbeitetMarkieren(doc.reference);

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Meldung als bearbeitet markiert."),
                            ),
                          );
                        },
                ),
                _AdminButton(
                  icon: Icons.block,
                  text: "Firma sperren",
                  farbe: Colors.red,
                  onPressed: firmaId.isEmpty
                      ? null
                      : () {
                          _firmaSperren(
                            context: context,
                            firmaId: firmaId,
                            firmenname: firmenname,
                            meldungRef: doc.reference,
                          );
                        },
                ),
                _AdminButton(
                  icon: Icons.delete_outline,
                  text: "Meldung löschen",
                  farbe: Colors.black87,
                  onPressed: () async {
                    final bestaetigt = await _bestaetigen(
                      context: context,
                      titel: "Meldung löschen?",
                      text: "Diese Meldung wird dauerhaft entfernt.",
                      buttonText: "Löschen",
                      farbe: Colors.red,
                    );

                    if (!bestaetigt) return;

                    await _meldungLoeschen(doc.reference);

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Meldung gelöscht."),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AdminMeldungsKarte extends StatelessWidget {
  final IconData icon;
  final Color iconFarbe;
  final String titel;
  final String status;
  final List<String> zeilen;
  final List<_AdminButton> buttons;

  const _AdminMeldungsKarte({
    required this.icon,
    required this.iconFarbe,
    required this.titel,
    required this.status,
    required this.zeilen,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    final istBearbeitet = status == "bearbeitet" || status == "geschlossen";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconFarbe.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: iconFarbe,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff050b2c),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: istBearbeitet ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  istBearbeitet ? "Bearbeitet" : "Offen",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...zeilen.map(
            (z) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                z,
                style: const TextStyle(
                  color: Color(0xff4d5368),
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: buttons,
          ),
        ],
      ),
    );
  }
}

class _AdminButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color farbe;
  final VoidCallback? onPressed;

  const _AdminButton({
    required this.icon,
    required this.text,
    required this.farbe,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: farbe,
        disabledBackgroundColor: const Color(0xffd6d6df),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      icon: Icon(
        icon,
        color: Colors.white,
        size: 18,
      ),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
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
            child: const Text("Abbrechen"),
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
