import 'package:flutter/material.dart';

import '../model/produkt.dart';
import '../auto_daten/auto_daten.dart';
import '../immobilien_daten/immobilien_daten.dart';
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

  String filterMarke = "Alle";
  String filterModell = "Alle";
  String filterKraftstoff = "Alle";
  String filterGetriebe = "Alle";

  String filterImmobilienArt = "Alle";
  String filterBalkon = "Alle";
  String filterGarage = "Alle";
  String filterGarten = "Alle";

  final preisVonController = TextEditingController();
  final preisBisController = TextEditingController();
  final baujahrAbController = TextEditingController();
  final kilometerBisController = TextEditingController();
  final wohnflaecheAbController = TextEditingController();
  final zimmerAbController = TextEditingController();

  final List<String> kategorien = [
    "Alle",
    "Auto & Motor",
    "Immobilien",
    "Jobs",
    "Elektronik",
    "Haus & Garten",
    "Mode",
    "Mehr",
  ];

  final kraftstoffeFilter = const [
    "Alle",
    "Benzin",
    "Diesel",
    "Elektro",
    "Hybrid",
    "Plug-in Hybrid",
    "Gas",
  ];

  final getriebeFilter = const [
    "Alle",
    "Automatik",
    "Manuell",
    "Halbautomatik",
  ];

  final jaNeinAlle = const [
    "Alle",
    "Ja",
    "Nein",
  ];

  @override
  void dispose() {
    preisVonController.dispose();
    preisBisController.dispose();
    baujahrAbController.dispose();
    kilometerBisController.dispose();
    wohnflaecheAbController.dispose();
    zimmerAbController.dispose();
    super.dispose();
  }

  IconData iconFuerKategorie(String kategorie) {
    if (kategorie == "Auto & Motor" || kategorie == "Autos") {
      return Icons.directions_car;
    }
    if (kategorie == "Immobilien") return Icons.home_outlined;
    if (kategorie == "Jobs") return Icons.work_outline;
    if (kategorie == "Elektronik") return Icons.phone_iphone;
    if (kategorie == "Haus & Garten" || kategorie == "Möbel") {
      return Icons.chair_outlined;
    }
    if (kategorie == "Mode") return Icons.checkroom_outlined;
    return Icons.grid_view_rounded;
  }

  int zahl(String text) {
    return int.tryParse(
          text
              .replaceAll("€", "")
              .replaceAll(".", "")
              .replaceAll(",", "")
              .replaceAll("km", "")
              .replaceAll("m²", "")
              .trim(),
        ) ??
        0;
  }

  bool preisPasst(Produkt produkt) {
    final preis = zahl(produkt.preis);
    final von = zahl(preisVonController.text);
    final bis = zahl(preisBisController.text);

    if (von > 0 && preis < von) return false;
    if (bis > 0 && preis > bis) return false;

    return true;
  }

  bool autoFilterPasst(Produkt produkt) {
    if (ausgewaehlteKategorie != "Auto & Motor") return true;
    if (produkt.kategorie != "Autos") return false;

    if (filterMarke != "Alle" && produkt.marke != filterMarke) return false;
    if (filterModell != "Alle" && produkt.modell != filterModell) return false;

    if (filterKraftstoff != "Alle" &&
        produkt.kraftstoff != filterKraftstoff) {
      return false;
    }

    if (filterGetriebe != "Alle" && produkt.getriebe != filterGetriebe) {
      return false;
    }

    final baujahrAb = zahl(baujahrAbController.text);
    final baujahr = zahl(produkt.baujahr);

    if (baujahrAb > 0 && baujahr < baujahrAb) return false;

    final kmBis = zahl(kilometerBisController.text);
    final km = zahl(produkt.kilometer);

    if (kmBis > 0 && km > kmBis) return false;

    return true;
  }

  bool immobilienFilterPasst(Produkt produkt) {
    if (ausgewaehlteKategorie != "Immobilien") return true;
    if (produkt.kategorie != "Immobilien") return false;

    if (filterImmobilienArt != "Alle" &&
        produkt.immobilienArt != filterImmobilienArt) {
      return false;
    }

    if (filterBalkon != "Alle" && produkt.balkon != filterBalkon) {
      return false;
    }

    if (filterGarage != "Alle" && produkt.garage != filterGarage) {
      return false;
    }

    if (filterGarten != "Alle" && produkt.garten != filterGarten) {
      return false;
    }

    final wfAb = zahl(wohnflaecheAbController.text);
    final wf = zahl(produkt.wohnflaeche);

    if (wfAb > 0 && wf < wfAb) return false;

    final zimmerAb = zahl(zimmerAbController.text);
    final zimmer = zahl(produkt.zimmer);

    if (zimmerAb > 0 && zimmer < zimmerAb) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final gefilterteProdukte = widget.produkte.where((produkt) {
      final text = suche.toLowerCase();

      final passtSuche =
          produkt.titel.toLowerCase().contains(text) ||
          produkt.ort.toLowerCase().contains(text) ||
          produkt.kategorie.toLowerCase().contains(text) ||
          produkt.marke.toLowerCase().contains(text) ||
          produkt.modell.toLowerCase().contains(text) ||
          produkt.immobilienArt.toLowerCase().contains(text);

      final passtKategorie = ausgewaehlteKategorie == "Alle" ||
          produkt.kategorie == ausgewaehlteKategorie ||
          (ausgewaehlteKategorie == "Auto & Motor" &&
              produkt.kategorie == "Autos") ||
          (ausgewaehlteKategorie == "Haus & Garten" &&
              produkt.kategorie == "Möbel");

      return passtSuche &&
          passtKategorie &&
          preisPasst(produkt) &&
          autoFilterPasst(produkt) &&
          immobilienFilterPasst(produkt);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final breit = constraints.maxWidth > 900;

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                _header(breit),
                _kategorien(),
                _filterBereich(breit),
                _heroBanner(breit),
                _beliebteKategorien(breit),
                _neuesteInserate(gefilterteProdukte, breit),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header(bool breit) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: breit ? 46 : 16,
        vertical: 14,
      ),
      child: Row(
        children: [
          const Row(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                color: Color(0xff5b2cff),
                size: 34,
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Handelswelt",
                    style: TextStyle(
                      color: Color(0xff050b2c),
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  Text(
                    "Deals",
                    style: TextStyle(
                      color: Color(0xff5b2cff),
                      fontSize: 17,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(width: breit ? 34 : 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                onChanged: (wert) {
                  setState(() {
                    suche = wert;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Suche nach Produkten, Autos, Immobilien...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xfff3f3f8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            height: 48,
            width: breit ? 165 : 48,
            decoration: BoxDecoration(
              color: const Color(0xff5b2cff),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: breit
                  ? const Text(
                      "Inserat erstellen",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  : const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kategorien() {
    return Container(
      height: 70,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 38),
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
              width: 132,
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconFuerKategorie(kategorie),
                    color: aktiv
                        ? const Color(0xff5b2cff)
                        : const Color(0xff11152f),
                    size: 22,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    kategorie,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: aktiv
                          ? const Color(0xff5b2cff)
                          : const Color(0xff11152f),
                      fontSize: 12,
                      fontWeight: aktiv ? FontWeight.w900 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 170),
                    height: 3,
                    width: aktiv ? 58 : 0,
                    decoration: BoxDecoration(
                      color: const Color(0xff5b2cff),
                      borderRadius: BorderRadius.circular(20),
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

  Widget _filterBereich(bool breit) {
    if (ausgewaehlteKategorie != "Auto & Motor" &&
        ausgewaehlteKategorie != "Immobilien") {
      return const SizedBox();
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        breit ? 46 : 16,
        16,
        breit ? 46 : 16,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xffececf4),
          ),
        ),
        child: ausgewaehlteKategorie == "Auto & Motor"
            ? _autoFilter()
            : _immobilienFilter(),
      ),
    );
  }

  Widget _autoFilter() {
    final modelle = filterMarke == "Alle"
        ? ["Alle"]
        : ["Alle", ...(autoModelle[filterMarke] ?? ["Andere"])];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _filterTitel("Auto Filter"),
        _filterDropdown(
          "Marke",
          filterMarke,
          ["Alle", ...autoMarken],
          (value) {
            setState(() {
              filterMarke = value!;
              filterModell = "Alle";
            });
          },
        ),
        _filterDropdown(
          "Modell",
          filterModell,
          modelle,
          (value) {
            setState(() {
              filterModell = value!;
            });
          },
        ),
        _filterDropdown(
          "Kraftstoff",
          filterKraftstoff,
          kraftstoffeFilter,
          (value) {
            setState(() {
              filterKraftstoff = value!;
            });
          },
        ),
        _filterDropdown(
          "Getriebe",
          filterGetriebe,
          getriebeFilter,
          (value) {
            setState(() {
              filterGetriebe = value!;
            });
          },
        ),
        _filterFeld(preisVonController, "Preis von"),
        _filterFeld(preisBisController, "Preis bis"),
        _filterFeld(baujahrAbController, "Baujahr ab"),
        _filterFeld(kilometerBisController, "Kilometer bis"),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              setState(() {
                filterMarke = "Alle";
                filterModell = "Alle";
                filterKraftstoff = "Alle";
                filterGetriebe = "Alle";
                preisVonController.clear();
                preisBisController.clear();
                baujahrAbController.clear();
                kilometerBisController.clear();
              });
            },
            child: const Text("Filter zurücksetzen"),
          ),
        ),
      ],
    );
  }

  Widget _immobilienFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _filterTitel("Immobilien Filter"),
        _filterDropdown(
          "Immobilienart",
          filterImmobilienArt,
          ["Alle", ...immobilienArten],
          (value) {
            setState(() {
              filterImmobilienArt = value!;
            });
          },
        ),
        _filterDropdown(
          "Balkon",
          filterBalkon,
          jaNeinAlle,
          (value) {
            setState(() {
              filterBalkon = value!;
            });
          },
        ),
        _filterDropdown(
          "Garage",
          filterGarage,
          jaNeinAlle,
          (value) {
            setState(() {
              filterGarage = value!;
            });
          },
        ),
        _filterDropdown(
          "Garten",
          filterGarten,
          jaNeinAlle,
          (value) {
            setState(() {
              filterGarten = value!;
            });
          },
        ),
        _filterFeld(preisVonController, "Preis von"),
        _filterFeld(preisBisController, "Preis bis"),
        _filterFeld(wohnflaecheAbController, "Wohnfläche ab"),
        _filterFeld(zimmerAbController, "Zimmer ab"),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              setState(() {
                filterImmobilienArt = "Alle";
                filterBalkon = "Alle";
                filterGarage = "Alle";
                filterGarten = "Alle";
                preisVonController.clear();
                preisBisController.clear();
                wohnflaecheAbController.clear();
                zimmerAbController.clear();
              });
            },
            child: const Text("Filter zurücksetzen"),
          ),
        ),
      ],
    );
  }

  Widget _filterTitel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xff050b2c),
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _filterDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : items.first,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xfff7f7fb),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _filterFeld(
    TextEditingController controller,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: (_) {
          setState(() {});
        },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xfff7f7fb),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _heroBanner(bool breit) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        breit ? 46 : 16,
        22,
        breit ? 46 : 16,
        0,
      ),
      child: Container(
        height: breit ? 235 : 185,
        padding: EdgeInsets.all(breit ? 34 : 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xff050b2c),
              Color(0xff11184f),
              Color(0xff3f1bd8),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          "Finde die besten Deals\nin deiner Nähe.",
          style: TextStyle(
            color: Colors.white,
            fontSize: breit ? 31 : 24,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _beliebteKategorien(bool breit) {
    final items = [
      ["Autos", Icons.directions_car],
      ["Immobilien", Icons.home],
      ["Jobs", Icons.work],
      ["Elektronik", Icons.phone_iphone],
      ["Möbel", Icons.chair],
      ["Mode", Icons.checkroom],
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        breit ? 46 : 16,
        24,
        breit ? 46 : 16,
        0,
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  "Beliebte Kategorien",
                  style: TextStyle(
                    color: Color(0xff050b2c),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: breit ? 6 : 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: breit ? 1.8 : 1.05,
            ),
            itemBuilder: (context, index) {
              final item = items[index];

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xffececf4),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item[1] as IconData,
                      color: const Color(0xff5b2cff),
                      size: breit ? 38 : 31,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item[0] as String,
                      style: const TextStyle(
                        color: Color(0xff050b2c),
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _neuesteInserate(List<Produkt> produkte, bool breit) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        breit ? 46 : 16,
        26,
        breit ? 46 : 16,
        22,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Neueste Deals",
                  style: TextStyle(
                    color: Color(0xff050b2c),
                    fontSize: 20,
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
          const SizedBox(height: 12),
          if (produkte.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xffececf4),
                ),
              ),
              child: const Text(
                "Keine Deals gefunden.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xff74788d),
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            ListView.builder(
              itemCount: produkte.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _dealKarte(produkte[index], breit);
              },
            ),
        ],
      ),
    );
  }

  Widget _dealKarte(Produkt produkt, bool breit) {
    final preisText =
        produkt.preis.endsWith("€") ? produkt.preis : "${produkt.preis} €";

    return InkWell(
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: breit ? 170 : null,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xffececf4),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: produkt.bild.isEmpty
                  ? _platzhalterBild(produkt, breit)
                  : Image.network(
                      produkt.bild,
                      width: breit ? 170 : 120,
                      height: breit ? 140 : 126,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _platzhalterBild(produkt, breit);
                      },
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _kartenText(produkt, preisText, breit),
            ),
            if (breit) ...[
              _miniChip(
                produkt.kategorie == "Autos" ? "Auto" : produkt.kategorie,
                const Color(0xfff1edff),
                const Color(0xff5b2cff),
              ),
              const SizedBox(width: 12),
              _miniChip(
                produkt.typ,
                produkt.typ == "Firma"
                    ? const Color(0xffffefe0)
                    : const Color(0xffe8f8ee),
                produkt.typ == "Firma" ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 20),
            ],
            IconButton(
              onPressed: () {
                widget.favoritWechseln(produkt);
              },
              icon: Icon(
                produkt.favorit ? Icons.favorite : Icons.favorite_border,
                color: produkt.favorit ? Colors.red : const Color(0xff74788d),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kartenText(
    Produkt produkt,
    String preisText,
    bool breit,
  ) {
    final zeile1 = _infoZeile1(produkt);
    final zeile2 = _infoZeile2(produkt);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          produkt.titel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color(0xff050b2c),
            fontSize: breit ? 18 : 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          preisText,
          style: TextStyle(
            color: const Color(0xff5b2cff),
            fontSize: breit ? 17 : 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (zeile1.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            zeile1,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xff050b2c),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        if (zeile2.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            zeile2,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xff74788d),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 6),
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
      ],
    );
  }

  String _infoZeile1(Produkt produkt) {
    if (produkt.kategorie == "Autos") {
      final teile = [
        produkt.baujahr,
        produkt.kilometer.isEmpty ? "" : "${produkt.kilometer} km",
      ].where((e) => e.trim().isNotEmpty).toList();

      return teile.join(" • ");
    }

    if (produkt.kategorie == "Immobilien") {
      return produkt.immobilienArt.isEmpty
          ? "Immobilie"
          : produkt.immobilienArt;
    }

    return produkt.zustand;
  }

  String _infoZeile2(Produkt produkt) {
    if (produkt.kategorie == "Autos") {
      final teile = [
        produkt.kraftstoff,
        produkt.getriebe,
      ].where((e) => e.trim().isNotEmpty).toList();

      return teile.join(" • ");
    }

    if (produkt.kategorie == "Immobilien") {
      final teile = [
        produkt.wohnflaeche.isEmpty ? "" : "${produkt.wohnflaeche} m²",
        produkt.zimmer.isEmpty ? "" : "${produkt.zimmer} Zimmer",
        produkt.balkon == "Ja" ? "Balkon" : "",
        produkt.garage == "Ja" ? "Garage" : "",
      ].where((e) => e.trim().isNotEmpty).toList();

      return teile.join(" • ");
    }

    final teile = [
      produkt.hersteller,
      produkt.garantie,
    ].where((e) => e.trim().isNotEmpty).toList();

    return teile.join(" • ");
  }

  Widget _platzhalterBild(Produkt produkt, bool breit) {
    return Container(
      width: breit ? 170 : 120,
      height: breit ? 140 : 126,
      color: const Color(0xfff1edff),
      child: Icon(
        produkt.icon,
        color: const Color(0xff5b2cff),
        size: 40,
      ),
    );
  }

  Widget _miniChip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}