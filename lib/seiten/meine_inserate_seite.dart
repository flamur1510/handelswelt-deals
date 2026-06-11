import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/produkt.dart';
import 'detail_seite.dart';
import 'inserat_bearbeiten_seite.dart';

class MeineInserateSeite extends StatefulWidget {
  const MeineInserateSeite({super.key});

  @override
  State<MeineInserateSeite> createState() => _MeineInserateSeiteState();
}

class _MeineInserateSeiteState extends State<MeineInserateSeite> {
  String ausgewaehlteKategorie = "Alle";
  String suche = "";

  final sucheController = TextEditingController();

  final List<String> kategorien = const [
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

  @override
  void dispose() {
    sucheController.dispose();
    super.dispose();
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
    if (ausgewaehlteKategorie == "Alle") return true;

    if (ausgewaehlteKategorie == "Auto & Motor") {
      return produkt.kategorie == "Auto & Motor" ||
          produkt.kategorie == "Autos" ||
          produkt.kategorie == "Motorräder" ||
          produkt.kategorie == "Motorrad";
    }

    if (ausgewaehlteKategorie == "Haus & Garten") {
      return produkt.kategorie == "Haus & Garten" ||
          produkt.kategorie == "Möbel";
    }

    return produkt.kategorie == ausgewaehlteKategorie;
  }

  String kategorieAnzeige(String kategorie) {
    if (kategorie == "Autos" ||
        kategorie == "Motorräder" ||
        kategorie == "Motorrad") {
      return "Auto & Motor";
    }

    if (kategorie == "Möbel") {
      return "Haus & Garten";
    }

    return kategorie;
  }

  bool suchePasst(Produkt produkt) {
    final text = suche.trim().toLowerCase();
    if (text.isEmpty) return true;

    return produkt.titel.toLowerCase().contains(text) ||
        produkt.ort.toLowerCase().contains(text) ||
        produkt.kategorie.toLowerCase().contains(text) ||
        produkt.unterkategorie.toLowerCase().contains(text) ||
        produkt.preis.toLowerCase().contains(text);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final breit = MediaQuery.of(context).size.width > 900;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xfffafafe),
        body: SafeArea(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(18),
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xffececf4)),
              ),
              child: const Text(
                "Bitte zuerst einloggen.",
                style: TextStyle(
                  color: Color(0xff050b2c),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
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
                child: CircularProgressIndicator(),
              );
            }

            final docs = snapshot.data!.docs;

            final alleInserate = docs.map((doc) {
              return Produkt.fromFirestore(doc);
            }).toList();

            final meineInserate = alleInserate.where((produkt) {
              return kategoriePasst(produkt) && suchePasst(produkt);
            }).toList();

            return ListView(
              padding: EdgeInsets.fromLTRB(
                breit ? 46 : 16,
                18,
                breit ? 46 : 16,
                24,
              ),
              children: [
                _kopfzeile(),
                const SizedBox(height: 16),
                _suchfeld(),
                const SizedBox(height: 16),
                _kategorieLeiste(),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ausgewaehlteKategorie == "Alle"
                            ? "Meine Inserate"
                            : ausgewaehlteKategorie,
                        style: const TextStyle(
                          color: Color(0xff050b2c),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      "${meineInserate.length} gefunden",
                      style: const TextStyle(
                        color: Color(0xff5b2cff),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (alleInserate.isEmpty)
                  _leer(
                    titel: "Du hast noch keine Inserate erstellt.",
                    icon: Icons.add_box_outlined,
                  )
                else if (meineInserate.isEmpty)
                  _leer(
                    titel: "Keine passenden Inserate gefunden.",
                    icon: Icons.search_off,
                  )
                else
                  for (final produkt in meineInserate)
                    _inseratKarte(context, produkt, breit),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _kopfzeile() {
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
            Icons.inventory_2_outlined,
            color: Color(0xff5b2cff),
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Meine Inserate",
                style: TextStyle(
                  color: Color(0xff050b2c),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Bearbeite, prüfe oder lösche deine Deals.",
                style: TextStyle(
                  color: Color(0xff74788d),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _suchfeld() {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: sucheController,
        onChanged: (wert) {
          setState(() {
            suche = wert;
          });
        },
        decoration: InputDecoration(
          hintText: "Meine Inserate suchen...",
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
    );
  }

  Widget _kategorieLeiste() {
    return SizedBox(
      height: 86,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: kategorien.length,
        itemBuilder: (context, index) {
          final kategorie = kategorien[index];
          final aktiv = ausgewaehlteKategorie == kategorie;

          return GestureDetector(
            onTap: () {
              setState(() {
                ausgewaehlteKategorie = kategorie;
              });
            },
            child: Container(
              width: 112,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: aktiv ? const Color(0xff5b2cff) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: aktiv
                      ? const Color(0xff5b2cff)
                      : const Color(0xffececf4),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0f000000),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconFuerKategorie(kategorie),
                    color: aktiv ? Colors.white : const Color(0xff5b2cff),
                    size: 25,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    kategorie,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: aktiv ? Colors.white : const Color(0xff050b2c),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
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

  Widget _inseratKarte(BuildContext context, Produkt produkt, bool breit) {
    final preisText =
        produkt.preis.endsWith("€") ? produkt.preis : "${produkt.preis} €";

    return InkWell(
      borderRadius: BorderRadius.circular(24),
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xffececf4)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 16,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: breit
            ? Row(
                children: [
                  _bild(produkt, breit),
                  Expanded(
                    child: _kartenInhalt(context, produkt, preisText),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bild(produkt, breit),
                  _kartenInhalt(context, produkt, preisText),
                ],
              ),
      ),
    );
  }

  Widget _bild(Produkt produkt, bool breit) {
    final breite = breit ? 230.0 : double.infinity;
    final hoehe = breit ? 170.0 : 185.0;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(24),
        topRight: breit ? Radius.zero : const Radius.circular(24),
        bottomLeft: breit ? const Radius.circular(24) : Radius.zero,
      ),
      child: produkt.bild.isEmpty
          ? Container(
              width: breite,
              height: hoehe,
              color: const Color(0xfff1edff),
              child: Icon(
                produkt.icon,
                color: const Color(0xff5b2cff),
                size: 44,
              ),
            )
          : Image.network(
              produkt.bild,
              width: breite,
              height: hoehe,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: breite,
                  height: hoehe,
                  color: const Color(0xfff1edff),
                  child: Icon(
                    produkt.icon,
                    color: const Color(0xff5b2cff),
                    size: 44,
                  ),
                );
              },
            ),
    );
  }

  Widget _kartenInhalt(
    BuildContext context,
    Produkt produkt,
    String preisText,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produkt.titel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff050b2c),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  preisText,
                  style: const TextStyle(
                    color: Color(0xff5b2cff),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: Color(0xff74788d),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        produkt.ort,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xff74788d),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 8,
                  runSpacing: 7,
                  children: [
                    _chip(kategorieAnzeige(produkt.kategorie)),
                    _chip(produkt.typ == "Firma"
                        ? "Verifizierte Firma"
                        : "Privat"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xfff1edff),
                ),
                icon: const Icon(
                  Icons.edit,
                  color: Color(0xff5b2cff),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InseratBearbeitenSeite(
                        produkt: produkt,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xffffedf1),
                ),
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () async {
                  final bestaetigt = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Inserat löschen?"),
                        content: const Text(
                          "Möchtest du dieses Inserat wirklich löschen?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text("Abbrechen"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text(
                              "Löschen",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (bestaetigt == true) {
                    await FirebaseFirestore.instance
                        .collection("inserate")
                        .doc(produkt.id)
                        .delete();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xfff1edff),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xff5b2cff),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _leer({
    required String titel,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffececf4)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 44,
            color: const Color(0xff5b2cff),
          ),
          const SizedBox(height: 12),
          Text(
            titel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xff050b2c),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
