// lib/seiten/kategorien_seite.dart

import 'package:flutter/material.dart';

import '../model/produkt.dart';

import 'kategorie_suche_seite.dart';

class KategorienSeite extends StatelessWidget {
  final List<Produkt> produkte;

  const KategorienSeite({
    super.key,
    required this.produkte,
  });

  IconData iconFuerKategorie(String kategorie) {
    if (kategorie == "Immobilien") return Icons.home;
    if (kategorie == "Autos") return Icons.directions_car;
    if (kategorie == "Elektronik") return Icons.phone_iphone;
    if (kategorie == "Möbel") return Icons.chair;
    if (kategorie == "Jobs") return Icons.work;
    if (kategorie == "Mode") return Icons.checkroom;
    if (kategorie == "Dienstleistungen") return Icons.handyman;
    if (kategorie == "Baumarkt") return Icons.construction;

    return Icons.shopping_bag;
  }

  Color farbeFuerKategorie(String kategorie) {
    if (kategorie == "Immobilien") return Colors.blue;
    if (kategorie == "Autos") return Colors.red;
    if (kategorie == "Elektronik") return Colors.deepPurple;
    if (kategorie == "Möbel") return Colors.brown;
    if (kategorie == "Jobs") return Colors.green;
    if (kategorie == "Mode") return Colors.pink;
    if (kategorie == "Dienstleistungen") return Colors.orange;
    if (kategorie == "Baumarkt") return Colors.teal;

    return Colors.deepPurple;
  }

  @override
  Widget build(BuildContext context) {
    final kategorien = [
      "Marktplatz",
      "Immobilien",
      "Autos",
      "Elektronik",
      "Möbel",
      "Jobs",
      "Mode",
      "Dienstleistungen",
      "Baumarkt",
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff6f3ff),

      appBar: AppBar(
        title: const Text("Kategorien"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [

          for (final kategorie in kategorien)

            Container(
              margin:
                  const EdgeInsets.only(
                      bottom: 18),

              child: Material(
                elevation: 5,

                borderRadius:
                    BorderRadius.circular(
                        26),

                color: Colors.white,

                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(
                          26),

                  onTap: () {

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            KategorieSucheSeite(
                          kategorie:
                              kategorie,

                          produkte:
                              produkte,
                        ),
                      ),
                    );
                  },

                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                            22),

                    child: Row(
                      children: [

                        CircleAvatar(
                          radius: 34,

                          backgroundColor:
                              farbeFuerKategorie(
                                      kategorie)
                                  .withOpacity(
                                      0.15),

                          child: Icon(
                            iconFuerKategorie(
                                kategorie),

                            color:
                                farbeFuerKategorie(
                                    kategorie),

                            size: 34,
                          ),
                        ),

                        const SizedBox(
                            width: 18),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              Text(
                                kategorie,

                                style:
                                    const TextStyle(
                                  fontSize:
                                      24,

                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),

                              const SizedBox(
                                  height:
                                      6),

                              Text(
                                "${produkte.where((p) => p.kategorie == kategorie).length} Anzeigen",
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding:
                              const EdgeInsets
                                  .all(10),

                          decoration:
                              BoxDecoration(
                            color:
                                Colors.deepPurple
                                    .withOpacity(
                                        0.1),

                            borderRadius:
                                BorderRadius
                                    .circular(
                                        16),
                          ),

                          child: const Icon(
                            Icons.arrow_forward_ios,

                            color: Colors
                                .deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}