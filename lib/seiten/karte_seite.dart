// lib/seiten/karte_seite.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../model/produkt.dart';
import 'detail_seite.dart';

class KarteSeite extends StatefulWidget {
  const KarteSeite({super.key});

  @override
  State<KarteSeite> createState() => _KarteSeiteState();
}

class _KarteSeiteState extends State<KarteSeite> {
  final MapController mapController = MapController();
  final sucheController = TextEditingController();

  bool sucht = false;
  String ortFilter = "";

  Future<void> adresseSuchen() async {
    final suche = sucheController.text.trim();

    if (suche.isEmpty) return;

    setState(() {
      sucht = true;
      ortFilter = suche.toLowerCase();
    });

    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search"
      "?q=${Uri.encodeComponent("$suche, Österreich")}"
      "&format=json"
      "&limit=1",
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "User-Agent": "HandelsweltApp/1.0",
        },
      );

      final daten = jsonDecode(response.body);

      if (daten is List && daten.isNotEmpty) {
        final lat = double.parse(daten[0]["lat"]);
        final lon = double.parse(daten[0]["lon"]);

        mapController.move(
          LatLng(lat, lon),
          14,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ort oder Adresse nicht gefunden."),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Fehler bei der Suche: $e"),
        ),
      );
    }

    setState(() {
      sucht = false;
    });
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
  void dispose() {
    sucheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f3ff),
      appBar: AppBar(
        title: const Text("Karte"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: sucheController,
                    onSubmitted: (_) => adresseSuchen(),
                    decoration: InputDecoration(
                      hintText: "Adresse oder Ort in Österreich suchen",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xfff6f3ff),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: IconButton(
                    onPressed: sucht ? null : adresseSuchen,
                    icon: sucht
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection("inserate").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final produkte = snapshot.data!.docs
                    .map((doc) => Produkt.fromFirestore(doc))
                    .where((produkt) {
                  if (ortFilter.isEmpty) return true;

                  return produkt.ort.toLowerCase().contains(ortFilter) ||
                      produkt.adresse.toLowerCase().contains(ortFilter);
                }).toList();

                return Stack(
                  children: [
                    FlutterMap(
                      mapController: mapController,
                      options: const MapOptions(
                        initialCenter: LatLng(48.2082, 16.3738),
                        initialZoom: 12,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          userAgentPackageName: "com.handelswelt.app",
                        ),
                        MarkerLayer(
                          markers: [
                            for (final produkt in produkte)
                              Marker(
                                point: LatLng(
                                  produkt.latitude,
                                  produkt.longitude,
                                ),
                                width: 95,
                                height: 95,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DetailSeite(
                                          produkt: produkt,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: farbeFuerKategorie(
                                            produkt.kategorie,
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.25),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          iconFuerKategorie(produkt.kategorie),
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.15),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          "${produkt.preis} €",
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Text(
                          "${produkte.length} Inserate gefunden",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
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