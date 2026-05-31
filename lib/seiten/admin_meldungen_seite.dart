import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMeldungenSeite extends StatefulWidget {
  const AdminMeldungenSeite({super.key});

  @override
  State<AdminMeldungenSeite> createState() =>
      _AdminMeldungenSeiteState();
}

class _AdminMeldungenSeiteState
    extends State<AdminMeldungenSeite> {
  String filter = "offen";

  Future<void> meldungSchliessen(String id) async {
    await FirebaseFirestore.instance
        .collection("meldungen")
        .doc(id)
        .update({
      "status": "geschlossen",
    });
  }

  Future<void> meldungOeffnen(String id) async {
    await FirebaseFirestore.instance
        .collection("meldungen")
        .doc(id)
        .update({
      "status": "offen",
    });
  }

  Future<void> inseratLoeschen(
    String produktId,
  ) async {
    await FirebaseFirestore.instance
        .collection("inserate")
        .doc(produktId)
        .delete();
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
      "grund": "Admin Sperre",
      "erstelltAm":
          FieldValue.serverTimestamp(),
    });
  }

  Future<void> verkaeuferEntsperren(
    String verkaeuferId,
  ) async {
    await FirebaseFirestore.instance
        .collection("gesperrteUser")
        .doc(verkaeuferId)
        .delete();
  }

  Future<bool> istGesperrt(
    String verkaeuferId,
  ) async {
    if (verkaeuferId.isEmpty) {
      return false;
    }

    final doc = await FirebaseFirestore
        .instance
        .collection("gesperrteUser")
        .doc(verkaeuferId)
        .get();

    return doc.exists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xfffafafe),
      body: SafeArea(
        child: Column(
          children: [
            _kopfzeile(),

            Padding(
              padding:
                  const EdgeInsets.all(16),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: "offen",
                    label: Text("Offen"),
                  ),
                  ButtonSegment(
                    value: "geschlossen",
                    label: Text("Geschlossen"),
                  ),
                  ButtonSegment(
                    value: "alle",
                    label: Text("Alle"),
                  ),
                ],
                selected: {filter},
                onSelectionChanged:
                    (werte) {
                  setState(() {
                    filter = werte.first;
                  });
                },
              ),
            ),

            Expanded(
              child:
                  StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore
                    .instance
                    .collection("meldungen")
                    .orderBy(
                      "erstelltAm",
                      descending: true,
                    )
                    .snapshots(),
                builder:
                    (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child:
                          CircularProgressIndicator(
                        color: Color(
                            0xff5b2cff),
                      ),
                    );
                  }

                  final alle =
                      snapshot.data!.docs;

                  final meldungen =
                      alle.where((m) {
                    final data =
                        m.data()
                            as Map<String,
                                dynamic>;

                    final status =
                        data["status"] ??
                            "offen";

                    if (filter ==
                        "alle") {
                      return true;
                    }

                    return status ==
                        filter;
                  }).toList();

                  if (meldungen.isEmpty) {
                    return const Center(
                      child: Text(
                        "Keine Meldungen gefunden",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding:
                        const EdgeInsets
                            .all(16),
                    itemCount:
                        meldungen.length,
                    itemBuilder:
                        (context, index) {
                      final meldung =
                          meldungen[index];

                      final data =
                          meldung.data()
                              as Map<String,
                                  dynamic>;

                      final status =
                          data["status"] ??
                              "offen";

                      final produktId =
                          data["produktId"] ??
                              "";

                      final verkaeuferId =
                          data["verkaeuferId"] ??
                              "";

                      final verkaeuferEmail =
                          data["verkaeuferEmail"] ??
                              "";

                      return FutureBuilder<
                          bool>(
                        future:
                            istGesperrt(
                          verkaeuferId,
                        ),
                        builder:
                            (context,
                                sperre) {
                          final gesperrt =
                              sperre.data ??
                                  false;

                          return Container(
                            margin:
                                const EdgeInsets
                                    .only(
                              bottom: 16,
                            ),
                            padding:
                                const EdgeInsets
                                    .all(18),
                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.white,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          24),
                              border:
                                  Border.all(
                                color:
                                    const Color(
                                  0xffececf4,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child:
                                          Text(
                                        data["produktTitel"] ??
                                            "Unbekannt",
                                        style:
                                            const TextStyle(
                                          fontSize:
                                              20,
                                          fontWeight:
                                              FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal:
                                            10,
                                        vertical:
                                            5,
                                      ),
                                      decoration:
                                          BoxDecoration(
                                        color: status ==
                                                "offen"
                                            ? Colors.red
                                            : Colors.green,
                                        borderRadius:
                                            BorderRadius.circular(
                                                30),
                                      ),
                                      child:
                                          Text(
                                        status,
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                    height:
                                        14),

                                Text(
                                  "Grund: ${data["grund"] ?? ""}",
                                ),

                                const SizedBox(
                                    height:
                                        5),

                                Text(
                                  "Verkäufer: $verkaeuferEmail",
                                ),

                                Text(
                                  "Gemeldet von: ${data["melderEmail"] ?? ""}",
                                ),

                                if ((data["kommentar"] ??
                                        "")
                                    .toString()
                                    .isNotEmpty) ...[
                                  const SizedBox(
                                      height:
                                          12),
                                  Container(
                                    padding:
                                        const EdgeInsets
                                            .all(
                                                12),
                                    decoration:
                                        BoxDecoration(
                                      color:
                                          const Color(
                                        0xfff7f7fb,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(
                                              16),
                                    ),
                                    child:
                                        Text(
                                      data["kommentar"],
                                      style:
                                          const TextStyle(
                                        fontStyle:
                                            FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],

                                const SizedBox(
                                    height:
                                        16),

                                Wrap(
                                  spacing: 10,
                                  runSpacing:
                                      10,
                                  children: [
                                    ElevatedButton
                                        .icon(
                                      style:
                                          ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.green,
                                      ),
                                      onPressed:
                                          status ==
                                                  "offen"
                                              ? () {
                                                  meldungSchliessen(
                                                    meldung.id,
                                                  );
                                                }
                                              : null,
                                      icon:
                                          const Icon(
                                        Icons
                                            .check,
                                        color: Colors
                                            .white,
                                      ),
                                      label:
                                          const Text(
                                        "Schließen",
                                        style:
                                            TextStyle(
                                          color:
                                              Colors.white,
                                        ),
                                      ),
                                    ),

                                    ElevatedButton
                                        .icon(
                                      style:
                                          ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.orange,
                                      ),
                                      onPressed:
                                          status ==
                                                  "geschlossen"
                                              ? () {
                                                  meldungOeffnen(
                                                    meldung.id,
                                                  );
                                                }
                                              : null,
                                      icon:
                                          const Icon(
                                        Icons
                                            .refresh,
                                        color: Colors
                                            .white,
                                      ),
                                      label:
                                          const Text(
                                        "Öffnen",
                                        style:
                                            TextStyle(
                                          color:
                                              Colors.white,
                                        ),
                                      ),
                                    ),

                                    ElevatedButton
                                        .icon(
                                      style:
                                          ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.red,
                                      ),
                                      onPressed:
                                          produktId
                                                  .isEmpty
                                              ? null
                                              : () async {
                                                  await inseratLoeschen(
                                                      produktId);

                                                  await meldungSchliessen(
                                                      meldung.id);
                                                },
                                      icon:
                                          const Icon(
                                        Icons
                                            .delete_forever,
                                        color: Colors
                                            .white,
                                      ),
                                      label:
                                          const Text(
                                        "Inserat löschen",
                                        style:
                                            TextStyle(
                                          color:
                                              Colors.white,
                                        ),
                                      ),
                                    ),

                                    ElevatedButton
                                        .icon(
                                      style:
                                          ElevatedButton.styleFrom(
                                        backgroundColor:
                                            gesperrt
                                                ? Colors.blue
                                                : Colors.black,
                                      ),
                                      onPressed:
                                          () async {
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

                                        setState(
                                            () {});
                                      },
                                      icon:
                                          Icon(
                                        gesperrt
                                            ? Icons.lock_open
                                            : Icons.block,
                                        color: Colors
                                            .white,
                                      ),
                                      label:
                                          Text(
                                        gesperrt
                                            ? "Entsperren"
                                            : "Sperren",
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kopfzeile() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color:
                  const Color(0xffffedf1),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "Admin Meldungen",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                Text(
                  "Verwalte gemeldete Inserate",
                  style: TextStyle(
                    color: Color(
                        0xff74788d),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}