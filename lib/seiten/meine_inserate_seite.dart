import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/produkt.dart';

import 'detail_seite.dart';
import 'inserat_bearbeiten_seite.dart';

class MeineInserateSeite extends StatelessWidget {
  const MeineInserateSeite({super.key});

  @override
  Widget build(BuildContext context) {

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {

      return Scaffold(

        backgroundColor:
            const Color(0xfff6f3ff),

        appBar: AppBar(

          title:
              const Text("Meine Inserate"),

          backgroundColor:
              Colors.deepPurple,

          foregroundColor:
              Colors.white,
        ),

        body: const Center(

          child: Text(
            "Bitte zuerst einloggen.",

            style: TextStyle(
              fontSize: 22,
            ),
          ),
        ),
      );
    }

    return Scaffold(

      backgroundColor:
          const Color(0xfff6f3ff),

      appBar: AppBar(

        title:
            const Text("Meine Inserate"),

        backgroundColor:
            Colors.deepPurple,

        foregroundColor:
            Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection("inserate")
            .where(
              "verkaeuferId",
              isEqualTo: user.uid,
            )
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {

            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final docs =
              snapshot.data!.docs;

          if (docs.isEmpty) {

            return const Center(

              child: Text(
                "Du hast noch keine Inserate erstellt.",

                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            );
          }

          final meineInserate =
              docs.map((doc) {

            return Produkt.fromFirestore(
                doc);

          }).toList();

          return ListView(

            padding:
                const EdgeInsets.all(20),

            children: [

              for (final produkt
                  in meineInserate)

                Card(

                  margin:
                      const EdgeInsets.only(
                          bottom: 18),

                  elevation: 4,

                  shape:
                      RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(
                            24),
                  ),

                  child: InkWell(

                    borderRadius:
                        BorderRadius.circular(
                            24),

                    onTap: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              DetailSeite(
                            produkt:
                                produkt,
                          ),
                        ),
                      );
                    },

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        ClipRRect(

                          borderRadius:
                              const BorderRadius.only(

                            topLeft:
                                Radius.circular(
                                    24),

                            topRight:
                                Radius.circular(
                                    24),
                          ),

                          child: Image.network(

                            produkt.bild,

                            height: 180,

                            width:
                                double.infinity,

                            fit: BoxFit.cover,
                          ),
                        ),

                        Padding(

                          padding:
                              const EdgeInsets
                                  .all(16),

                          child: Row(

                            children: [

                              Expanded(

                                child: Column(

                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [

                                    Text(

                                      produkt.titel,

                                      style:
                                          const TextStyle(

                                        fontSize:
                                            20,

                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(
                                        height: 6),

                                    Text(
                                      "${produkt.ort} • ${produkt.kategorie}",
                                    ),

                                    const SizedBox(
                                        height: 8),

                                    Text(

                                      produkt.preis,

                                      style:
                                          const TextStyle(

                                        fontSize:
                                            22,

                                        color:
                                            Colors.deepPurple,

                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Column(

                                children: [

                                  IconButton(

                                    icon: const Icon(
                                      Icons.edit,
                                      color:
                                          Colors.deepPurple,
                                    ),

                                    onPressed: () {

                                      Navigator.push(

                                        context,

                                        MaterialPageRoute(

                                          builder: (_) =>
                                              InseratBearbeitenSeite(

                                            produkt:
                                                produkt,
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  IconButton(

                                    icon: const Icon(
                                      Icons.delete,
                                      color:
                                          Colors.red,
                                    ),

                                    onPressed:
                                        () async {

                                      await FirebaseFirestore
                                          .instance
                                          .collection(
                                              "inserate")
                                          .doc(
                                              produkt.id)
                                          .delete();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}