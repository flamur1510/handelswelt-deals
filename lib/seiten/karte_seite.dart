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

  LatLng? gesuchterStandort;

  void _zurStartseite() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  final kategorien = const [
    "Alle",
    "Marktplatz",
    "Auto & Motor",
    "Immobilien",
    "Jobs",
    "Elektronik",
    "Haus & Garten",
    "Mode",
    "Dienstleistungen",
    "Baumarkt",
    "Baumaschinen",
    "Boote",
    "Landwirtschaft",
    "Freizeit",
    "Tiere",
    "Baby & Kind",
    "Sport",
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

        final punkt = LatLng(lat, lon);

        setState(() {
          gesuchterStandort = punkt;
        });

        mapController.move(punkt, 16);
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
    if (kategorie == "Alle") return Icons.apps_outlined;
    if (kategorie == "Marktplatz") return Icons.storefront_outlined;
    if (kategorie == "Auto & Motor") return Icons.directions_car;
    if (kategorie == "Immobilien") return Icons.home_outlined;
    if (kategorie == "Jobs") return Icons.work_outline;
    if (kategorie == "Elektronik") return Icons.phone_iphone;
    if (kategorie == "Haus & Garten") return Icons.chair_outlined;
    if (kategorie == "Mode") return Icons.checkroom_outlined;
    if (kategorie == "Dienstleistungen") return Icons.handyman_outlined;
    if (kategorie == "Baumarkt") return Icons.construction_outlined;
    if (kategorie == "Baumaschinen") {
      return Icons.precision_manufacturing_outlined;
    }
    if (kategorie == "Boote") return Icons.sailing_outlined;
    if (kategorie == "Landwirtschaft") return Icons.agriculture_outlined;
    if (kategorie == "Freizeit") return Icons.sports_soccer_outlined;
    if (kategorie == "Tiere") return Icons.pets_outlined;
    if (kategorie == "Baby & Kind") return Icons.child_care_outlined;
    if (kategorie == "Sport") return Icons.fitness_center_outlined;

    return Icons.category_outlined;
  }

  bool kategoriePasst(Produkt produkt) {
    if (kategorieFilter == "Alle") return true;

    if (kategorieFilter == "Auto & Motor") {
      return produkt.kategorie == "Auto & Motor" ||
          produkt.kategorie == "Autos" ||
          produkt.kategorie == "Motorräder" ||
          produkt.kategorie == "Motorrad";
    }

    if (kategorieFilter == "Haus & Garten") {
      return produkt.kategorie == "Haus & Garten" ||
          produkt.kategorie == "Möbel";
    }

    return produkt.kategorie == kategorieFilter;
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

              final passtKategorie = kategoriePasst(produkt);

              return passtOrt && passtKategorie;
            }).toList();

            return Padding(
              padding: EdgeInsets.fromLTRB(
                breit ? 28 : 16,
                14,
                breit ? 28 : 16,
                24,
              ),
              child: Column(
                children: [
                  _kopfzeile(breit),
                  const SizedBox(height: 16),
                  _kartenInfoZeile(produkte.length),
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

  Widget _kopfzeile(bool breit) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: breit ? 22 : 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: const Color(0xff050b2c),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff5b2cff), Color(0xff7a5cff)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.map, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              const Text(
                "Karte",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (breit) ...[
            _navChip("Start", Icons.home_outlined, false, _zurStartseite),
            const SizedBox(width: 8),
            _navChip("Karte", Icons.map_outlined, true, null),
          ],
          if (!breit)
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.08),
              ),
              onPressed: _zurStartseite,
              icon: const Icon(Icons.home_outlined, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _navChip(String text, IconData icon, bool aktiv, VoidCallback? onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: aktiv
              ? const Color(0xff5b2cff).withOpacity(0.18)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: aktiv
                ? const Color(0xff7a5cff)
                : Colors.white.withOpacity(0.12),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: aktiv ? const Color(0xffb9a8ff) : Colors.white70,
              size: 17,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: aktiv ? const Color(0xffb9a8ff) : Colors.white70,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kartenInfoZeile(int anzahl) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xfff1edff),
            borderRadius: BorderRadius.circular(18),
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
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$anzahl Inserate auf der Karte",
                style: const TextStyle(
                  color: Color(0xff74788d),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
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
            setState(() {
              gesuchterStandort = null;
              ortFilter = "";
              sucheController.clear();
            });

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
              cursorColor: const Color(0xff5b2cff),
              controller: sucheController,
              onSubmitted: (_) => adresseSuchen(),
              decoration: InputDecoration(
                hintText: "Ort oder Adresse suchen...",
                prefixIcon: const Icon(Icons.search, color: Color(0xff5b2cff)),
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17),
                  borderSide: const BorderSide(
                    color: Color(0xff5b2cff),
                    width: 1.4,
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
        color: const Color(0xff050b2c),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xff202844),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: const Color(0xff5b2cff).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.tune,
                  color: Color(0xffb9a8ff),
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Filter",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "$anzahl Ergebnisse",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final kategorie in kategorien) _filterItem(kategorie),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
              side: const BorderSide(
                color: Color(0xff7a5cff),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () {
              setState(() {
                kategorieFilter = "Alle";
                ortFilter = "";
                gesuchterStandort = null;
                sucheController.clear();
              });
            },
            icon: const Icon(
              Icons.refresh,
              color: Color(0xffb9a8ff),
            ),
            label: const Text(
              "Zurücksetzen",
              style: TextStyle(
                color: Color(0xffb9a8ff),
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
          color: aktiv
              ? const Color(0xff5b2cff).withOpacity(0.18)
              : const Color(0xff111833),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: aktiv ? const Color(0xff7a5cff) : const Color(0xff26304f),
          ),
        ),
        child: Row(
          children: [
            Icon(
              iconFuerKategorie(kategorie),
              color: aktiv ? const Color(0xffb9a8ff) : Colors.white70,
              size: 21,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                kategorie,
                style: TextStyle(
                  color: aktiv ? Colors.white : Colors.white70,
                  fontWeight: aktiv ? FontWeight.w900 : FontWeight.w700,
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
                  if (gesuchterStandort != null)
                    Marker(
                      point: gesuchterStandort!,
                      width: 70,
                      height: 70,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.blue,
                        size: 60,
                      ),
                    ),
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