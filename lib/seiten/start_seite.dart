import 'package:flutter/material.dart';

import '../model/produkt.dart';
import 'detail_seite.dart';

class StartSeite extends StatefulWidget {
  final List<Produkt> produkte;
  final Function(Produkt) favoritWechseln;

  const StartSeite({
    super.key,
    required this.produkte,
    required this.favoritWechseln,
  });

  @override
  State<StartSeite> createState() => _StartSeiteState();
}

class _StartSeiteState extends State<StartSeite> {
  String suche = "";
  String ausgewaehlteKategorie = "Alle";

  final List<String> kategorien = [
    "Alle",
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

  @override
  Widget build(BuildContext context) {
    final gefilterteProdukte = widget.produkte.where((produkt) {
      final text = suche.toLowerCase();

      final passtSuche =
          produkt.titel.toLowerCase().contains(text) ||
          produkt.ort.toLowerCase().contains(text) ||
          produkt.kategorie.toLowerCase().contains(text);

      final passtKategorie = ausgewaehlteKategorie == "Alle" ||
          produkt.kategorie == ausgewaehlteKategorie;

      return passtSuche && passtKategorie;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xfff6f3ff),

      body: ListView(
        children: [

          Container(
            padding: const EdgeInsets.fromLTRB(
              20,
              55,
              20,
              24,
            ),

            decoration: const BoxDecoration(
              color: Colors.deepPurple,

              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const Text(
                  "Handelswelt",

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Kaufen. Verkaufen. Finden.",

                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  onChanged: (wert) {

                    setState(() {
                      suche = wert;
                    });
                  },

                  decoration: InputDecoration(
                    hintText:
                        "Was suchst du?",

                    prefixIcon:
                        const Icon(Icons.search),

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(22),

                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const Text(
                  "Kategorien",

                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  height: 88,

                  child: ListView(
                    scrollDirection:
                        Axis.horizontal,

                    children: [

                      for (final kategorie
                          in kategorien)

                        GestureDetector(
                          onTap: () {

                            setState(() {

                              ausgewaehlteKategorie =
                                  kategorie;
                            });
                          },

                          child: Container(
                            width: 82,

                            margin:
                                const EdgeInsets.only(
                              right: 10,
                            ),

                            padding:
                                const EdgeInsets.all(8),

                            decoration: BoxDecoration(
                              color:
                                  ausgewaehlteKategorie ==
                                          kategorie
                                      ? Colors.deepPurple
                                      : Colors.white,

                              borderRadius:
                                  BorderRadius.circular(18),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.06),

                                  blurRadius: 8,
                                ),
                              ],
                            ),

                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,

                              children: [

                                Icon(
                                  iconFuerKategorie(
                                      kategorie),

                                  color:
                                      ausgewaehlteKategorie ==
                                              kategorie
                                          ? Colors.white
                                          : Colors.deepPurple,

                                  size: 26,
                                ),

                                const SizedBox(
                                    height: 7),

                                Text(
                                  kategorie,

                                  maxLines: 1,

                                  overflow:
                                      TextOverflow.ellipsis,

                                  textAlign:
                                      TextAlign.center,

                                  style: TextStyle(
                                    color:
                                        ausgewaehlteKategorie ==
                                                kategorie
                                            ? Colors.white
                                            : Colors.black,

                                    fontSize: 11,

                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [

                    const Text(
                      "Neueste Inserate",

                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    Text(
                      "${gefilterteProdukte.length}",

                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                ListView.builder(
                  shrinkWrap: true,

                  physics:
                      const NeverScrollableScrollPhysics(),

                  itemCount:
                      gefilterteProdukte.length,

                  itemBuilder:
                      (context, index) {

                    final produkt =
                        gefilterteProdukte[index];

                    return InkWell(
                      borderRadius:
                          BorderRadius.circular(18),

                      onTap: () {

                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) =>
                                DetailSeite(
                              produkt: produkt,
                            ),
                          ),
                        );
                      },

                      child: Container(
                        margin:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(18),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.05),

                              blurRadius: 7,
                            ),
                          ],
                        ),

                        child: Row(
                          children: [

                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.only(
                                topLeft:
                                    Radius.circular(18),

                                bottomLeft:
                                    Radius.circular(18),
                              ),

                              child: Image.network(
                                produkt.bild,

                                width: 130,
                                height: 130,

                                fit: BoxFit.cover,
                              ),
                            ),

                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(12),

                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                  children: [

                                    Row(
                                      children: [

                                        Expanded(
                                          child: Text(
                                            produkt.titel,

                                            maxLines: 2,

                                            overflow:
                                                TextOverflow.ellipsis,

                                            style:
                                                const TextStyle(
                                              fontSize: 16,

                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        IconButton(
                                          icon: Icon(
                                            produkt.favorit
                                                ? Icons.favorite
                                                : Icons.favorite_border,

                                            color:
                                                produkt.favorit
                                                    ? Colors.red
                                                    : Colors.grey,
                                          ),

                                          onPressed: () {

                                            widget
                                                .favoritWechseln(
                                              produkt,
                                            );
                                          },
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      produkt.preis
                                              .endsWith("€")
                                          ? produkt.preis
                                          : "${produkt.preis} €",

                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.deepPurple,

                                        fontSize: 18,

                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Row(
                                      children: [

                                        const Icon(
                                          Icons.location_on,

                                          size: 15,

                                          color:
                                              Colors.black54,
                                        ),

                                        const SizedBox(
                                            width: 3),

                                        Expanded(
                                          child: Text(
                                            produkt.ort,

                                            maxLines: 1,

                                            overflow:
                                                TextOverflow.ellipsis,

                                            style:
                                                const TextStyle(
                                              color:
                                                  Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    Row(
                                      children: [

                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),

                                          decoration:
                                              BoxDecoration(
                                            color: Colors
                                                .deepPurple
                                                .withOpacity(0.1),

                                            borderRadius:
                                                BorderRadius.circular(
                                                    20),
                                          ),

                                          child: Text(
                                            produkt.kategorie,

                                            style:
                                                const TextStyle(
                                              color:
                                                  Colors.deepPurple,

                                              fontWeight:
                                                  FontWeight.bold,

                                              fontSize: 12,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(
                                            width: 8),

                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),

                                          decoration:
                                              BoxDecoration(
                                            color: produkt.typ ==
                                                    "Firma"
                                                ? Colors.orange
                                                : Colors.green,

                                            borderRadius:
                                                BorderRadius.circular(
                                                    20),
                                          ),

                                          child: Text(
                                            produkt.typ,

                                            style:
                                                const TextStyle(
                                              color:
                                                  Colors.white,

                                              fontSize: 12,

                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}