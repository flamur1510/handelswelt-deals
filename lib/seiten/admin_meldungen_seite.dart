import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMeldungenSeite extends StatefulWidget {
  const AdminMeldungenSeite({super.key});

  @override
  State<AdminMeldungenSeite> createState() => _AdminMeldungenSeiteState();
}

class _AdminMeldungenSeiteState extends State<AdminMeldungenSeite> {
  String filter = "offen";

  Future<void> meldungSchliessen(String id) async {
    await FirebaseFirestore.instance.collection("meldungen").doc(id).update({
      "status": "geschlossen",
    });
  }

  Future<void> meldungOeffnen(String id) async {
    await FirebaseFirestore.instance.collection("meldungen").doc(id).update({
      "status": "offen",
    });
  }

  Future<void> inseratLoeschen(String produktId) async {
    await FirebaseFirestore.instance.collection("inserate").doc(produktId).delete();
  }

  Future<void> verkaeuferSperren({
    required String verkaeuferId,
    required String verkaeuferEmail,
  }) async {
    if (verkaeuferId.isEmpty) return;

    await FirebaseFirestore.instance
        .collection("gesperrteUser")
        .doc(verkaeuferId)
        .set({
      "userId": verkaeuferId,
      "email": verkaeuferEmail,
      "grund": "Von Admin wegen Meldung gesperrt",
      "erstelltAm": FieldValue.serverTimestamp(),
    });
  }

  Future<void> verkaeuferEntsperren(String verkaeuferId) async {
    if (verkaeuferId.isEmpty) return;

    await FirebaseFirestore.instance
        .collection("gesperrteUser")
        .doc(verkaeuferId)
        .delete();
  }

  Future<bool> istGesperrt(String verkaeuferId) async {
    if (verkaeuferId.isEmpty) return false;

    final doc = await FirebaseFirestore.instance
        .collection("gesperrteUser")
        .doc(verkaeuferId)
        .get();

    return doc.exists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f3ff),
      appBar: AppBar(
        title: const Text("Admin Meldungen"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: "offen", label: Text("Offen")),
                ButtonSegment(value: "geschlossen", label: Text("Geschlossen")),
                ButtonSegment(value: "alle", label: Text("Alle")),
              ],
              selected: {filter},
              onSelectionChanged: (wert) {
                setState(() {
                  filter = wert.first;
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("meldungen")
                  .orderBy("erstelltAm", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final alleMeldungen = snapshot.data!.docs;

                final meldungen = alleMeldungen.where((meldung) {
                  final data = meldung.data() as Map<String, dynamic>;
                  final status = data["status"] ?? "offen";

                  if (filter == "alle") return true;

                  return status == filter;
                }).toList();

                if (meldungen.isEmpty) {
                  return const Center(
                    child: Text(
                      "Keine Meldungen gefunden.",
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    for (final meldung in meldungen)
                      Builder(
                        builder: (context) {
                          final data = meldung.data() as Map<String, dynamic>;

                          final status = data["status"] ?? "offen";
                          final produktId = data["produktId"] ?? "";
                          final verkaeuferId = data["verkaeuferId"] ?? "";
                          final verkaeuferEmail =
                              data["verkaeuferEmail"] ?? "";

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          data["produktTitel"] ??
                                              "Unbekanntes Inserat",
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Chip(
                                        backgroundColor: status == "offen"
                                            ? Colors.red
                                            : Colors.green,
                                        label: Text(
                                          status,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  Text("Grund: ${data["grund"] ?? ""}"),
                                  Text("Verkäufer: $verkaeuferEmail"),
                                  Text("Gemeldet von: ${data["melderEmail"] ?? ""}"),

                                  if ((data["kommentar"] ?? "")
                                      .toString()
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      data["kommentar"],
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 16),

                                  FutureBuilder<bool>(
                                    future: istGesperrt(verkaeuferId),
                                    builder: (context, sperrSnapshot) {
                                      final gesperrt =
                                          sperrSnapshot.data ?? false;

                                      return Column(
                                        children: [
                                          if (status == "offen")
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                icon: const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  padding: const EdgeInsets.all(14),
                                                ),
                                                onPressed: () {
                                                  meldungSchliessen(meldung.id);
                                                },
                                                label: const Text(
                                                  "Meldung schließen",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),

                                          if (status == "geschlossen")
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                icon: const Icon(
                                                  Icons.refresh,
                                                  color: Colors.white,
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.orange,
                                                  padding: const EdgeInsets.all(14),
                                                ),
                                                onPressed: () {
                                                  meldungOeffnen(meldung.id);
                                                },
                                                label: const Text(
                                                  "Wieder öffnen",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),

                                          const SizedBox(height: 10),

                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              icon: const Icon(
                                                Icons.delete_forever,
                                                color: Colors.white,
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                padding: const EdgeInsets.all(14),
                                              ),
                                              onPressed:
                                                  produktId.toString().isEmpty
                                                      ? null
                                                      : () async {
                                                          await inseratLoeschen(
                                                            produktId,
                                                          );
                                                          await meldungSchliessen(
                                                            meldung.id,
                                                          );
                                                        },
                                              label: const Text(
                                                "Inserat löschen",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(height: 10),

                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              icon: Icon(
                                                gesperrt
                                                    ? Icons.lock_open
                                                    : Icons.block,
                                                color: Colors.white,
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: gesperrt
                                                    ? Colors.blue
                                                    : Colors.black87,
                                                padding: const EdgeInsets.all(14),
                                              ),
                                              onPressed: verkaeuferId
                                                      .toString()
                                                      .isEmpty
                                                  ? null
                                                  : () async {
                                                      if (gesperrt) {
                                                        await verkaeuferEntsperren(
                                                          verkaeuferId,
                                                        );
                                                      } else {
                                                        await verkaeuferSperren(
                                                          verkaeuferId:
                                                              verkaeuferId,
                                                          verkaeuferEmail:
                                                              verkaeuferEmail,
                                                        );
                                                      }

                                                      setState(() {});
                                                    },
                                              label: Text(
                                                gesperrt
                                                    ? "Verkäufer entsperren"
                                                    : "Verkäufer sperren",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}