import 'package:flutter/material.dart';

import '../model/produkt.dart';
import 'detail_seite.dart';

class KategorienSeite extends StatefulWidget {
  final List<Produkt> produkte;

  const KategorienSeite({
    super.key,
    required this.produkte,
  });

  @override
  State<KategorienSeite> createState() => _KategorienSeiteState();
}

class _KategorienSeiteState extends State<KategorienSeite> {
  String ausgewaehlteKategorie = "Alle";
  String suche = "";

  final List<String> kategorien = [
    "Alle",
    "Marktplatz",
    "Autos",
    "Immobilien",
    "Elektronik",
    "Möbel",
    "Jobs",
    "Mode",
    "Dienstleistungen",
    "Baumarkt",
  ];

  IconData iconFuerKategorie(String kategorie) {
    if (kategorie == "Autos") return Icons.directions_car;
    if (kategorie == "Immobilien") return Icons.home_outlined;
    if (kategorie == "Elektronik") return Icons.phone_iphone;
    if (kategorie == "Möbel") return Icons.chair_outlined;
    if (kategorie == "Jobs") return Icons.work_outline;
    if (kategorie == "Mode") return Icons.checkroom_outlined;
    if (kategorie == "Dienstleistungen") return Icons.handyman_outlined;
    if (kategorie == "Baumarkt") return Icons.construction_outlined;
    if (kategorie == "Marktplatz") return Icons.shopping_bag_outlined;
    return Icons.grid_view_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final breit = MediaQuery.of(context).size.width > 900;

    final produkte = widget.produkte.where((produkt) {
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
      backgroundColor: const Color(0xfffafafe),
      body: SafeArea(
        child: ListView(
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
            const SizedBox(height: 18),
            _kategorieLeiste(),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: Text(
                    ausgewaehlteKategorie == "Alle"
                        ? "Alle Kategorien"
                        : ausgewaehlteKategorie,
                    style: const TextStyle(
                      color: Color(0xff050b2c),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  "${produkte.length} gefunden",
                  style: const TextStyle(
                    color: Color(0xff5b2cff),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (produkte.isEmpty)
              _leer()
            else
              GridView.builder(
                itemCount: produkte.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: breit ? 4 : 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: breit ? 0.92 : 0.72,
                ),
                itemBuilder: (context, index) {
                  return _produktKarte(produkte[index]);
                },
              ),
          ],
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
            Icons.grid_view_rounded,
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
                "Kategorien",
                style: TextStyle(
                  color: Color(0xff050b2c),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Finde passende Deals nach Bereich.",
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
        onChanged: (wert) {
          setState(() {
            suche = wert;
          });
        },
        decoration: InputDecoration(
          hintText: "Kategorie oder Produkt suchen...",
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
              width: 104,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: aktiv ? const Color(0xff5b2cff) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: aktiv
                      ? const Color(0xff5b2cff)
                      : const Color(0xffececf4),
                ),
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

  Widget _produktKarte(Produkt produkt) {
    final preisText =
        produkt.preis.endsWith("€") ? produkt.preis : "${produkt.preis} €";

    return InkWell(
      borderRadius: BorderRadius.circular(20),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xffececf4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: produkt.bild.isEmpty
                  ? _platzhalter(produkt)
                  : Image.network(
                      produkt.bild,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _platzhalter(produkt);
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produkt.titel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xff050b2c),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    preisText,
                    style: const TextStyle(
                      color: Color(0xff5b2cff),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
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
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _chip(produkt.kategorie),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _platzhalter(Produkt produkt) {
    return Container(
      height: 150,
      width: double.infinity,
      color: const Color(0xfff1edff),
      child: Icon(
        produkt.icon,
        color: const Color(0xff5b2cff),
        size: 42,
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
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

  Widget _leer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xffececf4),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off,
            size: 44,
            color: Color(0xff5b2cff),
          ),
          SizedBox(height: 12),
          Text(
            "Keine Inserate gefunden.",
            style: TextStyle(
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