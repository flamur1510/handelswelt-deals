import 'package:flutter/material.dart';

import '../model/produkt.dart';
import 'detail_seite.dart';

class KategorieSucheSeite extends StatefulWidget {
  final String kategorie;
  final List<Produkt> produkte;

  const KategorieSucheSeite({
    super.key,
    required this.kategorie,
    required this.produkte,
  });

  @override
  State<KategorieSucheSeite> createState() => _KategorieSucheSeiteState();
}

class _KategorieSucheSeiteState extends State<KategorieSucheSeite> {
  final sucheController = TextEditingController();
  final preisVonController = TextEditingController();
  final preisBisController = TextEditingController();
  final ortController = TextEditingController();

  final markeController = TextEditingController();
  final modellController = TextEditingController();
  final kilometerVonController = TextEditingController();
  final kilometerBisController = TextEditingController();
  final baujahrVonController = TextEditingController();
  final baujahrBisController = TextEditingController();

  final wohnflaecheVonController = TextEditingController();
  final wohnflaecheBisController = TextEditingController();
  final zimmerController = TextEditingController();

  double zahl(String text) {
    final sauber = text
        .replaceAll("€", "")
        .replaceAll(".", "")
        .replaceAll(",", ".")
        .trim();

    return double.tryParse(sauber) ?? 0;
  }

  Widget feld(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    sucheController.dispose();
    preisVonController.dispose();
    preisBisController.dispose();
    ortController.dispose();

    markeController.dispose();
    modellController.dispose();
    kilometerVonController.dispose();
    kilometerBisController.dispose();
    baujahrVonController.dispose();
    baujahrBisController.dispose();

    wohnflaecheVonController.dispose();
    wohnflaecheBisController.dispose();
    zimmerController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Produkt> produkte = widget.produkte.where((Produkt produkt) {
      if (produkt.kategorie != widget.kategorie) {
        return false;
      }

      final passtZurSuche = sucheController.text.isEmpty ||
          produkt.titel
              .toLowerCase()
              .contains(sucheController.text.toLowerCase()) ||
          produkt.beschreibung
              .toLowerCase()
              .contains(sucheController.text.toLowerCase());

      final passtZumOrt = ortController.text.isEmpty ||
          produkt.ort.toLowerCase().contains(ortController.text.toLowerCase());

      final preis = zahl(produkt.preis);

      final preisVon =
          preisVonController.text.isEmpty ? 0 : zahl(preisVonController.text);

      final preisBis = preisBisController.text.isEmpty
          ? 999999999
          : zahl(preisBisController.text);

      final passtZumPreis = preis >= preisVon && preis <= preisBis;

      bool autoFilter = true;

      if (widget.kategorie == "Autos") {
        final kilometer = double.tryParse(produkt.kilometer) ?? 0;
        final kilometerVon = kilometerVonController.text.isEmpty
            ? 0
            : double.tryParse(kilometerVonController.text) ?? 0;
        final kilometerBis = kilometerBisController.text.isEmpty
            ? 999999999
            : double.tryParse(kilometerBisController.text) ?? 999999999;

        final baujahr = int.tryParse(produkt.baujahr) ?? 0;
        final baujahrVon = baujahrVonController.text.isEmpty
            ? 0
            : int.tryParse(baujahrVonController.text) ?? 0;
        final baujahrBis = baujahrBisController.text.isEmpty
            ? 999999
            : int.tryParse(baujahrBisController.text) ?? 999999;

        final passtZurMarke = markeController.text.isEmpty ||
            produkt.marke
                .toLowerCase()
                .contains(markeController.text.toLowerCase());

        final passtZumModell = modellController.text.isEmpty ||
            produkt.modell
                .toLowerCase()
                .contains(modellController.text.toLowerCase());

        autoFilter = kilometer >= kilometerVon &&
            kilometer <= kilometerBis &&
            baujahr >= baujahrVon &&
            baujahr <= baujahrBis &&
            passtZurMarke &&
            passtZumModell;
      }

      bool immobilienFilter = true;

      if (widget.kategorie == "Immobilien") {
        final wohnflaeche = double.tryParse(produkt.wohnflaeche) ?? 0;
        final wohnflaecheVon = wohnflaecheVonController.text.isEmpty
            ? 0
            : double.tryParse(wohnflaecheVonController.text) ?? 0;
        final wohnflaecheBis = wohnflaecheBisController.text.isEmpty
            ? 999999999
            : double.tryParse(wohnflaecheBisController.text) ?? 999999999;

        final zimmer = int.tryParse(produkt.zimmer) ?? 0;
        final zimmerMin = zimmerController.text.isEmpty
            ? 0
            : int.tryParse(zimmerController.text) ?? 0;

        immobilienFilter = wohnflaeche >= wohnflaecheVon &&
            wohnflaeche <= wohnflaecheBis &&
            zimmer >= zimmerMin;
      }

      return passtZurSuche &&
          passtZumOrt &&
          passtZumPreis &&
          autoFilter &&
          immobilienFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xfff6f3ff),
      appBar: AppBar(
        title: Text(widget.kategorie),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          feld(sucheController, "Suche"),
          feld(ortController, "Ort"),

          Row(
            children: [
              Expanded(child: feld(preisVonController, "Preis von")),
              const SizedBox(width: 12),
              Expanded(child: feld(preisBisController, "Preis bis")),
            ],
          ),

          if (widget.kategorie == "Autos") ...[
            const SizedBox(height: 10),
            const Text(
              "Fahrzeugsuche",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            feld(markeController, "Marke"),
            feld(modellController, "Modell"),
            Row(
              children: [
                Expanded(child: feld(kilometerVonController, "KM von")),
                const SizedBox(width: 12),
                Expanded(child: feld(kilometerBisController, "KM bis")),
              ],
            ),
            Row(
              children: [
                Expanded(child: feld(baujahrVonController, "Baujahr von")),
                const SizedBox(width: 12),
                Expanded(child: feld(baujahrBisController, "Baujahr bis")),
              ],
            ),
          ],

          if (widget.kategorie == "Immobilien") ...[
            const SizedBox(height: 10),
            const Text(
              "Immobiliensuche",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: feld(wohnflaecheVonController, "m² von")),
                const SizedBox(width: 12),
                Expanded(child: feld(wohnflaecheBisController, "m² bis")),
              ],
            ),
            feld(zimmerController, "Mindestens Zimmer"),
          ],

          const SizedBox(height: 20),

          Text(
            "${produkte.length} Ergebnisse",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          for (final produkt in produkte)
            Card(
              margin: const EdgeInsets.only(bottom: 14),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    produkt.bild,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  produkt.titel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  produkt.kategorie == "Autos"
                      ? "${produkt.ort} • ${produkt.baujahr} • ${produkt.kilometer} km"
                      : produkt.kategorie == "Immobilien"
                          ? "${produkt.ort} • ${produkt.wohnflaeche} m² • ${produkt.zimmer} Zimmer"
                          : "${produkt.ort} • ${produkt.typ}",
                ),
                trailing: Text(
                  produkt.preis.endsWith("€")
                      ? produkt.preis
                      : "${produkt.preis} €",
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailSeite(produkt: produkt),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}