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
  String kategorieFilter = "Alle";

  final kategorien = const [
    "Alle",
    "Autos",
    "Immobilien",
    "Elektronik",
    "Möbel",
    "Jobs",
    "Mode",
    "Dienstleistungen",
    "Baumarkt",
  ];

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

  IconData iconFuerKategorie(String kategorie) {
    if (kategorie == "Immobilien") return Icons.home_outlined;
    if (kategorie == "Autos") return Icons.directions_car;
    if (kategorie == "Elektronik") return Icons.phone_iphone;
    if (kategorie == "Möbel") return Icons.chair_outlined;
    if (kategorie == "Jobs") return Icons.work_outline;
    if (kategorie == "Mode") return Icons.checkroom_outlined;
    if (kategorie == "Dienstleistungen") return Icons.handyman_outlined;
    if (kategorie == "Baumarkt") return Icons.construction_outlined;
    return Icons.shopping_bag_outlined;
  }

  String preisText(Produkt produkt) {
    return produkt.preis.endsWith("€") ? produkt.preis : "${produkt.preis} €";
  }

  @override
  void dispose() {
    sucheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final breit = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("inserate").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xff5b2cff),
                ),
              );
            }

            final alleProdukte = snapshot.data!.docs
                .map((doc) => Produkt.fromFirestore(doc))
                .toList();

            final produkte = alleProdukte.where((produkt) {
              final passtOrt = ortFilter.isEmpty ||
                  produkt.ort.toLowerCase().contains(ortFilter) ||
                  produkt.adresse.toLowerCase().contains(ortFilter);

              final passtKategorie = kategorieFilter == "Alle" ||
                  produkt.kategorie == kategorieFilter;

              return passtOrt && passtKategorie;
            }).toList();

            return Padding(
              padding: EdgeInsets.fromLTRB(
                breit ? 46 : 16,
                18,
                breit ? 46 : 16,
                24,
              ),
              child: Column(
                children: [
                  _kopfzeile(produkte.length),
                  const SizedBox(height: 14),
                  _suchLeiste(),
                  const SizedBox(height: 14),
                  if (breit)
                    Expanded(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 250,
                            child: _filterBox(produkte.length),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _kartenBox(produkte),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    _kategorieLeiste(),
                    const SizedBox(height: 14),
                    Expanded(
                      child: _kartenBox(produkte),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _kopfzeile(int anzahl) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xfff1edff),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.map_outlined,
            color: Color(0xff5b2cff),
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Karte",
                style: TextStyle(
                  color: Color(0xff050b2c),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "$anzahl Inserate in deiner Nähe",
                style: const TextStyle(
                  color: Color(0xff74788d),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xfff1edff),
          ),
          onPressed: () {
            mapController.move(
              const LatLng(48.2082, 16.3738),
              12,
            );
          },
          icon: const Icon(
            Icons.my_location,
            color: Color(0xff5b2cff),
          ),
        ),
      ],
    );
  }

  Widget _suchLeiste() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: TextField(
              controller: sucheController,
              onSubmitted: (_) => adresseSuchen(),
              decoration: InputDecoration(
                hintText: "Ort oder Adresse suchen...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17),
                  borderSide: const BorderSide(
                    color: Color(0xffececf4),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17),
                  borderSide: const BorderSide(
                    color: Color(0xffececf4),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 50,
          width: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff5b2cff),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
            onPressed: sucht ? null : adresseSuchen,
            child: sucht
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
    );
  }

  Widget _filterBox(int anzahl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xffececf4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Filter",
            style: TextStyle(
              color: Color(0xff050b2c),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "$anzahl Ergebnisse",
            style: const TextStyle(
              color: Color(0xff74788d),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          for (final kategorie in kategorien)
            _filterItem(kategorie),
          const Spacer(),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
              side: const BorderSide(
                color: Color(0xff5b2cff),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () {
              setState(() {
                kategorieFilter = "Alle";
                ortFilter = "";
                sucheController.clear();
              });
            },
            icon: const Icon(
              Icons.refresh,
              color: Color(0xff5b2cff),
            ),
            label: const Text(
              "Zurücksetzen",
              style: TextStyle(
                color: Color(0xff5b2cff),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterItem(String kategorie) {
    final aktiv = kategorieFilter == kategorie;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          kategorieFilter = kategorie;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: aktiv ? const Color(0xfff1edff) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              iconFuerKategorie(kategorie),
              color: aktiv
                  ? const Color(0xff5b2cff)
                  : const Color(0xff74788d),
              size: 21,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                kategorie,
                style: TextStyle(
                  color: aktiv
                      ? const Color(0xff5b2cff)
                      : const Color(0xff050b2c),
                  fontWeight: aktiv ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kategorieLeiste() {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: kategorien.length,
        itemBuilder: (context, index) {
          final kategorie = kategorien[index];
          final aktiv = kategorieFilter == kategorie;

          return GestureDetector(
            onTap: () {
              setState(() {
                kategorieFilter = kategorie;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: aktiv ? const Color(0xff5b2cff) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: aktiv
                      ? const Color(0xff5b2cff)
                      : const Color(0xffececf4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    iconFuerKategorie(kategorie),
                    size: 18,
                    color: aktiv ? Colors.white : const Color(0xff5b2cff),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    kategorie,
                    style: TextStyle(
                      color: aktiv ? Colors.white : const Color(0xff050b2c),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _kartenBox(List<Produkt> produkte) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
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
                      width: 105,
                      height: 62,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xff5b2cff),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.20),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Text(
                                preisText(produkt),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xff5b2cff),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.location_on,
                              color: Color(0xff5b2cff),
                              size: 28,
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.14),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Text(
                "${produkte.length} Inserate gefunden",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xff5b2cff),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}