import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../model/produkt.dart';
import '../auto_daten/auto_daten.dart';
import '../immobilien_daten/immobilien_daten.dart';
import '../widgets_boote/boote_felder.dart';
import '../widgets_baumaschinen/baumaschinen_felder.dart';
import '../widgets_baumarkt/baumarkt_felder.dart';

class InseratBearbeitenSeite extends StatefulWidget {
  final Produkt produkt;

  const InseratBearbeitenSeite({
    super.key,
    required this.produkt,
  });

  @override
  State<InseratBearbeitenSeite> createState() =>
      _InseratBearbeitenSeiteState();
}

class _InseratBearbeitenSeiteState extends State<InseratBearbeitenSeite> {
  late TextEditingController titelController;
  late TextEditingController preisController;
  late TextEditingController ortController;
  late TextEditingController adresseController;
  late TextEditingController beschreibungController;

  late TextEditingController telefonController;
  late TextEditingController firmennameController;
  late TextEditingController webseiteController;

  late TextEditingController baujahrController;
  late TextEditingController kilometerController;
  late TextEditingController leistungController;
  late TextEditingController erstzulassungController;
  late TextEditingController vorbesitzerController;
  late TextEditingController tuevController;
  late TextEditingController hubraumController;
  late TextEditingController verbrauchController;
  late TextEditingController co2Controller;
  late TextEditingController schluesselController;

  late TextEditingController wohnflaecheController;
  late TextEditingController zimmerController;
  late TextEditingController etageController;
  late TextEditingController kautionController;
  late TextEditingController betriebskostenController;
  late TextEditingController baujahrImmobilieController;

  late TextEditingController herstellerController;
  late TextEditingController garantieController;

  late TextEditingController bootMarkeController;
  late TextEditingController bootModellController;
  late TextEditingController bootBaujahrController;
  late TextEditingController bootLaengeController;
  late TextEditingController bootLeistungController;

  late TextEditingController baumaschinenZustandController;
  late TextEditingController baumaschinenBaujahrController;
  late TextEditingController baumaschinenBetriebsstundenController;
  late TextEditingController baumaschinenKraftstoffController;
  late TextEditingController baumaschinenLeistungController;
  late TextEditingController baumaschinenGewichtController;

  late TextEditingController baumarktHerstellerController;
  late TextEditingController baumarktMaterialController;
  late TextEditingController baumarktFarbeController;
  late TextEditingController baumarktMasseController;
  late TextEditingController baumarktGewichtController;
  late TextEditingController baumarktMengeController;

  late String kategorie;
  late String unterkategorie;
  late String typ;
  late String bootstyp;

  late String ausgewaehlteMarke;
  late String ausgewaehltesModell;
  late String ausgewaehlterKraftstoff;
  late String ausgewaehltesGetriebe;
  late String ausgewaehlterZustand;

  late String ausgewaehlteFarbe;
  late String ausgewaehlteKarosserie;
  late String ausgewaehlterAntrieb;
  late String ausgewaehlteUnfallfrei;
  late String ausgewaehlteTueren;
  late String ausgewaehlteSitze;
  late String ausgewaehlteServiceheft;
  late String ausgewaehlteNichtraucher;
  late String ausgewaehlteMwst;
  late String ausgewaehltesPickerlNeu;

  late String ausgewaehltesLeasing;
  late String ausgewaehlteFinanzierung;
  late String ausgewaehlteInzahlungnahme;

  late String ausgewaehlteImmobilienArt;
  late String ausgewaehlterImmobilienZustand;
  late String ausgewaehlterBalkon;
  late String ausgewaehlteTerrasse;
  late String ausgewaehlterGarten;
  late String ausgewaehlteGarage;
  late String ausgewaehlterLift;
  late String ausgewaehlterKeller;
  late String ausgewaehltMoebliert;
  late String ausgewaehlteEnergieklasse;
  late String ausgewaehlteHeizung;
  late String ausgewaehlteVerfuegbarkeit;

  late bool telefonSichtbar;
  late bool whatsappAktiv;
  late bool emailSichtbar;

  bool wirdGespeichert = false;

  List<String> vorhandeneBilder = [];
  List<Uint8List> neueBilderBytes = [];

  final kategorien = const [
    "Marktplatz",
    "Immobilien",
    "Autos",
    "Elektronik",
    "Möbel",
    "Jobs",
    "Mode",
    "Dienstleistungen",
    "Baumarkt",
    "Baumaschinen",
    "Boote",
  ];

  final booteUnterkategorien = const [
    "Motorboot",
    "Segelboot",
    "Schlauchboot",
    "Jetski",
    "Hausboot",
    "Angelboot",
    "Kajak/Kanu",
    "Bootszubehör",
    "Andere",
  ];

  final baumaschinenUnterkategorien = const [
    "Bagger",
    "Radlader",
    "Kran",
    "Dumper",
    "Walze",
    "Gabelstapler",
    "Betonmischer",
    "Anhänger",
    "Ersatzteile",
    "Andere",
  ];

  final baumarktUnterkategorien = const [
    "Werkzeug",
    "Baumaterial",
    "Holz",
    "Türen & Fenster",
    "Fliesen",
    "Farben & Lacke",
    "Sanitär",
    "Elektromaterial",
    "Gartenbau",
    "Andere",
  ];

  final kraftstoffe = const [
    "Benzin",
    "Diesel",
    "Elektro",
    "Hybrid",
    "Plug-in Hybrid",
    "Gas",
  ];

  final getriebeArten = const [
    "Automatik",
    "Manuell",
    "Halbautomatik",
  ];

  final zustaende = const [
    "Neu",
    "Wie neu",
    "Sehr gut",
    "Gut",
    "Gebraucht",
    "Defekt",
  ];

  final farben = const [
    "Schwarz",
    "Weiß",
    "Silber",
    "Grau",
    "Blau",
    "Rot",
    "Grün",
    "Gelb",
    "Orange",
    "Braun",
    "Beige",
    "Gold",
    "Andere",
  ];

  final karosserien = const [
    "Limousine",
    "Kombi",
    "SUV/Geländewagen",
    "Kleinwagen",
    "Coupé",
    "Cabrio",
    "Van/Minibus",
    "Transporter",
    "Pickup",
    "Andere",
  ];

  final antriebe = const [
    "Frontantrieb",
    "Heckantrieb",
    "Allrad",
    "Andere",
  ];

  final jaNein = const [
    "Ja",
    "Nein",
  ];

  final tuerenListe = const [
    "2",
    "3",
    "4",
    "5",
    "6+",
  ];

  final sitzeListe = const [
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8+",
  ];

  @override
  void initState() {
    super.initState();

    final p = widget.produkt;

    titelController = TextEditingController(text: p.titel);
    preisController = TextEditingController(text: p.preis);
    ortController = TextEditingController(text: p.ort);
    adresseController = TextEditingController(text: p.adresse);
    beschreibungController = TextEditingController(text: p.beschreibung);

    telefonController = TextEditingController(text: p.telefon);
    firmennameController = TextEditingController(text: p.firmenname);
    webseiteController = TextEditingController(text: p.webseite);

    baujahrController = TextEditingController(text: p.baujahr);
    kilometerController = TextEditingController(text: p.kilometer);
    leistungController = TextEditingController(text: p.leistung);
    erstzulassungController = TextEditingController(text: p.erstzulassung);
    vorbesitzerController = TextEditingController(text: p.vorbesitzer);
    tuevController = TextEditingController(text: p.tuev);
    hubraumController = TextEditingController(text: p.hubraum);
    verbrauchController = TextEditingController(text: p.verbrauch);
    co2Controller = TextEditingController(text: p.co2);
    schluesselController = TextEditingController(text: p.schluessel);

    wohnflaecheController = TextEditingController(text: p.wohnflaeche);
    zimmerController = TextEditingController(text: p.zimmer);
    etageController = TextEditingController(text: p.etage);
    kautionController = TextEditingController(text: p.kaution);
    betriebskostenController = TextEditingController(text: p.betriebskosten);
    baujahrImmobilieController =
        TextEditingController(text: p.baujahrImmobilie);

    herstellerController = TextEditingController(text: p.hersteller);
    garantieController = TextEditingController(text: p.garantie);

    bootMarkeController = TextEditingController(text: p.bootMarke);
    bootModellController = TextEditingController(text: p.bootModell);
    bootBaujahrController = TextEditingController(text: p.bootBaujahr);
    bootLaengeController = TextEditingController(text: p.bootLaenge);
    bootLeistungController = TextEditingController(text: p.bootLeistung);

    baumaschinenZustandController =
        TextEditingController(text: p.baumaschinenZustand);
    baumaschinenBaujahrController =
        TextEditingController(text: p.baumaschinenBaujahr);
    baumaschinenBetriebsstundenController =
        TextEditingController(text: p.baumaschinenBetriebsstunden);
    baumaschinenKraftstoffController =
        TextEditingController(text: p.baumaschinenKraftstoff);
    baumaschinenLeistungController =
        TextEditingController(text: p.baumaschinenLeistung);
    baumaschinenGewichtController =
        TextEditingController(text: p.baumaschinenGewicht);

    baumarktHerstellerController =
        TextEditingController(text: p.baumarktHersteller);
    baumarktMaterialController =
        TextEditingController(text: p.baumarktMaterial);
    baumarktFarbeController = TextEditingController(text: p.baumarktFarbe);
    baumarktMasseController = TextEditingController(text: p.baumarktMasse);
    baumarktGewichtController =
        TextEditingController(text: p.baumarktGewicht);
    baumarktMengeController = TextEditingController(text: p.baumarktMenge);

    kategorie = p.kategorie.isEmpty ? "Marktplatz" : p.kategorie;
    unterkategorie = p.unterkategorie;
    typ = p.typ.isEmpty ? "Privat" : p.typ;
    bootstyp = p.bootstyp.isEmpty ? "Motorboot" : p.bootstyp;

    ausgewaehlteMarke = p.marke.isEmpty ? "Audi" : p.marke;
    ausgewaehltesModell = p.modell.isEmpty ? "A1" : p.modell;
    ausgewaehlterKraftstoff = p.kraftstoff.isEmpty ? "Benzin" : p.kraftstoff;
    ausgewaehltesGetriebe = p.getriebe.isEmpty ? "Automatik" : p.getriebe;
    ausgewaehlterZustand = p.zustand.isEmpty ? "Gebraucht" : p.zustand;

    ausgewaehlteFarbe = p.farbe.isEmpty ? "Schwarz" : p.farbe;
    ausgewaehlteKarosserie =
        p.karosserie.isEmpty ? "Limousine" : p.karosserie;
    ausgewaehlterAntrieb = p.antrieb.isEmpty ? "Frontantrieb" : p.antrieb;
    ausgewaehlteUnfallfrei = p.unfallfrei.isEmpty ? "Ja" : p.unfallfrei;
    ausgewaehlteTueren = p.tueren.isEmpty ? "5" : p.tueren;
    ausgewaehlteSitze = p.sitze.isEmpty ? "5" : p.sitze;
    ausgewaehlteServiceheft = p.serviceheft.isEmpty ? "Ja" : p.serviceheft;
    ausgewaehlteNichtraucher = p.nichtraucher.isEmpty ? "Ja" : p.nichtraucher;
    ausgewaehlteMwst =
        p.mwstAusweisbar.isEmpty ? "Nein" : p.mwstAusweisbar;
    ausgewaehltesPickerlNeu = p.pickerlNeu.isEmpty ? "Nein" : p.pickerlNeu;

    ausgewaehltesLeasing =
        p.leasingMoeglich.isEmpty ? "Nein" : p.leasingMoeglich;
    ausgewaehlteFinanzierung = p.finanzierungMoeglich.isEmpty
        ? "Nein"
        : p.finanzierungMoeglich;
    ausgewaehlteInzahlungnahme = p.inzahlungnahmeMoeglich.isEmpty
        ? "Nein"
        : p.inzahlungnahmeMoeglich;

    ausgewaehlteImmobilienArt =
        p.immobilienArt.isEmpty ? "Wohnung mieten" : p.immobilienArt;
    ausgewaehlterImmobilienZustand = p.zustand.isEmpty ? "Gut" : p.zustand;
    ausgewaehlterBalkon = p.balkon.isEmpty ? "Nein" : p.balkon;
    ausgewaehlteTerrasse = p.terrasse.isEmpty ? "Nein" : p.terrasse;
    ausgewaehlterGarten = p.garten.isEmpty ? "Nein" : p.garten;
    ausgewaehlteGarage = p.garage.isEmpty ? "Nein" : p.garage;
    ausgewaehlterLift = p.lift.isEmpty ? "Nein" : p.lift;
    ausgewaehlterKeller = p.keller.isEmpty ? "Nein" : p.keller;
    ausgewaehltMoebliert = p.moebliert.isEmpty ? "Nein" : p.moebliert;
    ausgewaehlteEnergieklasse =
        p.energieklasse.isEmpty ? "A" : p.energieklasse;
    ausgewaehlteHeizung = p.heizung.isEmpty ? "Fernwärme" : p.heizung;
    ausgewaehlteVerfuegbarkeit =
        p.verfuegbarAb.isEmpty ? "Sofort" : p.verfuegbarAb;

    telefonSichtbar = p.telefonSichtbar;
    whatsappAktiv = p.whatsappAktiv;
    emailSichtbar = p.emailSichtbar;

    vorhandeneBilder = p.bilder.isNotEmpty
        ? List<String>.from(p.bilder)
        : (p.bild.isNotEmpty ? [p.bild] : []);
  }

  Future<Map<String, double>> koordinatenHolen(String suche) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search"
      "?q=${Uri.encodeComponent("$suche, Österreich")}"
      "&format=json"
      "&limit=1",
    );

    final response = await http.get(
      url,
      headers: {
        "User-Agent": "HandelsweltApp/1.0",
      },
    );

    final daten = jsonDecode(response.body);

    if (daten is List && daten.isNotEmpty) {
      return {
        "lat": double.parse(daten[0]["lat"]),
        "lon": double.parse(daten[0]["lon"]),
      };
    }

    return {
      "lat": widget.produkt.latitude,
      "lon": widget.produkt.longitude,
    };
  }

  Future<void> bilderAuswaehlen() async {
    final picker = ImagePicker();
    final dateien = await picker.pickMultiImage();

    if (dateien.isEmpty) return;

    final neueBilder = <Uint8List>[];

    for (final datei in dateien) {
      final bytes = await datei.readAsBytes();
      neueBilder.add(bytes);
    }

    setState(() {
      neueBilderBytes.addAll(neueBilder);
    });
  }

  Future<List<String>> neueBilderHochladen() async {
    final urls = <String>[];

    for (final bild in neueBilderBytes) {
      final name =
          "${DateTime.now().millisecondsSinceEpoch}_${urls.length}.jpg";

      final ref = FirebaseStorage.instance.ref().child("inserate").child(name);

      await ref.putData(
        bild,
        SettableMetadata(
          contentType: "image/jpeg",
        ),
      );

      final url = await ref.getDownloadURL();
      urls.add(url);
    }

    return urls;
  }

  void typGeaendert(String neuerTyp) {
    setState(() {
      typ = neuerTyp;

      if (typ == "Firma") {
        telefonSichtbar = true;
        whatsappAktiv = true;
        emailSichtbar = true;
      } else {
        telefonSichtbar = false;
        whatsappAktiv = false;
        emailSichtbar = false;
        ausgewaehltesLeasing = "Nein";
        ausgewaehlteFinanzierung = "Nein";
        ausgewaehlteInzahlungnahme = "Nein";
      }
    });
  }

  bool pruefen() {
    if (titelController.text.trim().isEmpty ||
        preisController.text.trim().isEmpty ||
        ortController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bitte Titel, Preis und Ort eingeben."),
        ),
      );
      return false;
    }

    if (typ == "Firma" && firmennameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bitte Firmenname eingeben."),
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> speichern() async {
    if (!pruefen()) return;

    setState(() {
      wirdGespeichert = true;
    });

    try {
      final sucheAdresse = adresseController.text.trim().isEmpty
          ? ortController.text.trim()
          : "${adresseController.text.trim()}, ${ortController.text.trim()}";

      final koordinaten = await koordinatenHolen(sucheAdresse);
      final neueBildUrls = await neueBilderHochladen();

      final alleBilder = [
        ...vorhandeneBilder.where((bild) => bild.trim().isNotEmpty),
        ...neueBildUrls,
      ];

      final bildHaupt = alleBilder.isNotEmpty
          ? alleBilder.first
          : "https://images.unsplash.com/photo-1523275335684-37898b6baf30";

      final daten = {
        "titel": titelController.text.trim(),
        "preis": preisController.text.trim(),
        "ort": ortController.text.trim(),
        "adresse": adresseController.text.trim(),
        "kategorie": kategorie,
        "unterkategorie": unterkategorie,
        "typ": typ,
        "beschreibung": beschreibungController.text.trim(),
        "bild": bildHaupt,
        "bilder": alleBilder,
        "telefon": telefonController.text.trim(),
        "firmenname": firmennameController.text.trim(),
        "webseite": webseiteController.text.trim(),
        "telefonSichtbar": telefonSichtbar,
        "whatsappAktiv": whatsappAktiv,
        "emailSichtbar": emailSichtbar,
        "latitude": koordinaten["lat"] ?? widget.produkt.latitude,
        "longitude": koordinaten["lon"] ?? widget.produkt.longitude,

        "marke": kategorie == "Autos" ? ausgewaehlteMarke : "",
        "modell": kategorie == "Autos" ? ausgewaehltesModell : "",
        "baujahr": kategorie == "Autos" ? baujahrController.text.trim() : "",
        "kilometer":
            kategorie == "Autos" ? kilometerController.text.trim() : "",
        "kraftstoff": kategorie == "Autos" ? ausgewaehlterKraftstoff : "",
        "getriebe": kategorie == "Autos" ? ausgewaehltesGetriebe : "",
        "leistung": kategorie == "Autos" ? leistungController.text.trim() : "",

        "immobilienArt":
            kategorie == "Immobilien" ? ausgewaehlteImmobilienArt : "",
        "wohnflaeche":
            kategorie == "Immobilien" ? wohnflaecheController.text.trim() : "",
        "zimmer":
            kategorie == "Immobilien" ? zimmerController.text.trim() : "",

        "zustand": kategorie == "Immobilien"
            ? ausgewaehlterImmobilienZustand
            : ausgewaehlterZustand,
        "hersteller": herstellerController.text.trim(),
        "garantie": garantieController.text.trim(),

        "bootMarke":
            kategorie == "Boote" ? bootMarkeController.text.trim() : "",
        "bootModell":
            kategorie == "Boote" ? bootModellController.text.trim() : "",
        "bootBaujahr":
            kategorie == "Boote" ? bootBaujahrController.text.trim() : "",
        "bootLaenge":
            kategorie == "Boote" ? bootLaengeController.text.trim() : "",
        "bootLeistung":
            kategorie == "Boote" ? bootLeistungController.text.trim() : "",
        "bootstyp": kategorie == "Boote" ? bootstyp : "",

        "baumaschinenZustand": kategorie == "Baumaschinen"
            ? baumaschinenZustandController.text.trim()
            : "",
        "baumaschinenBaujahr": kategorie == "Baumaschinen"
            ? baumaschinenBaujahrController.text.trim()
            : "",
        "baumaschinenBetriebsstunden": kategorie == "Baumaschinen"
            ? baumaschinenBetriebsstundenController.text.trim()
            : "",
        "baumaschinenKraftstoff": kategorie == "Baumaschinen"
            ? baumaschinenKraftstoffController.text.trim()
            : "",
        "baumaschinenLeistung": kategorie == "Baumaschinen"
            ? baumaschinenLeistungController.text.trim()
            : "",
        "baumaschinenGewicht": kategorie == "Baumaschinen"
            ? baumaschinenGewichtController.text.trim()
            : "",

        "baumarktHersteller": kategorie == "Baumarkt"
            ? baumarktHerstellerController.text.trim()
            : "",
        "baumarktMaterial": kategorie == "Baumarkt"
            ? baumarktMaterialController.text.trim()
            : "",
        "baumarktFarbe": kategorie == "Baumarkt"
            ? baumarktFarbeController.text.trim()
            : "",
        "baumarktMasse": kategorie == "Baumarkt"
            ? baumarktMasseController.text.trim()
            : "",
        "baumarktGewicht": kategorie == "Baumarkt"
            ? baumarktGewichtController.text.trim()
            : "",
        "baumarktMenge": kategorie == "Baumarkt"
            ? baumarktMengeController.text.trim()
            : "",
      };

      await FirebaseFirestore.instance
          .collection("inserate")
          .doc(widget.produkt.id)
          .update(daten);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inserat gespeichert.")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler: $e")),
      );
    }

    if (mounted) {
      setState(() {
        wirdGespeichert = false;
      });
    }
  }

  @override
  void dispose() {
    titelController.dispose();
    preisController.dispose();
    ortController.dispose();
    adresseController.dispose();
    beschreibungController.dispose();

    telefonController.dispose();
    firmennameController.dispose();
    webseiteController.dispose();

    baujahrController.dispose();
    kilometerController.dispose();
    leistungController.dispose();
    erstzulassungController.dispose();
    vorbesitzerController.dispose();
    tuevController.dispose();
    hubraumController.dispose();
    verbrauchController.dispose();
    co2Controller.dispose();
    schluesselController.dispose();

    wohnflaecheController.dispose();
    zimmerController.dispose();
    etageController.dispose();
    kautionController.dispose();
    betriebskostenController.dispose();
    baujahrImmobilieController.dispose();

    herstellerController.dispose();
    garantieController.dispose();

    bootMarkeController.dispose();
    bootModellController.dispose();
    bootBaujahrController.dispose();
    bootLaengeController.dispose();
    bootLeistungController.dispose();

    baumaschinenZustandController.dispose();
    baumaschinenBaujahrController.dispose();
    baumaschinenBetriebsstundenController.dispose();
    baumaschinenKraftstoffController.dispose();
    baumaschinenLeistungController.dispose();
    baumaschinenGewichtController.dispose();

    baumarktHerstellerController.dispose();
    baumarktMaterialController.dispose();
    baumarktFarbeController.dispose();
    baumarktMasseController.dispose();
    baumarktGewichtController.dispose();
    baumarktMengeController.dispose();

    super.dispose();
  }

  Widget _karte({String? titel, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffececf4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titel != null) ...[
            Text(
              titel,
              style: const TextStyle(
                color: Color(0xff050b2c),
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _feld(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xfff7f7fb),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    final sichereItems = items.isEmpty ? ["Andere"] : items;
    final sichererWert =
        sichereItems.contains(value) ? value : sichereItems.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: sichererWert,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xfff7f7fb),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        items: sichereItems
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _unterkategorieDropdown() {
    if (kategorie == "Boote") {
      return _dropdown(
        label: "Unterkategorie",
        value: unterkategorie.isEmpty
            ? booteUnterkategorien.first
            : unterkategorie,
        items: booteUnterkategorien,
        onChanged: (value) {
          setState(() {
            unterkategorie = value!;
          });
        },
      );
    }

    if (kategorie == "Baumaschinen") {
      return _dropdown(
        label: "Unterkategorie",
        value: unterkategorie.isEmpty
            ? baumaschinenUnterkategorien.first
            : unterkategorie,
        items: baumaschinenUnterkategorien,
        onChanged: (value) {
          setState(() {
            unterkategorie = value!;
          });
        },
      );
    }

    if (kategorie == "Baumarkt") {
      return _dropdown(
        label: "Unterkategorie",
        value: unterkategorie.isEmpty
            ? baumarktUnterkategorien.first
            : unterkategorie,
        items: baumarktUnterkategorien,
        onChanged: (value) {
          setState(() {
            unterkategorie = value!;
          });
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _autoFelder() {
    return _karte(
      titel: "Fahrzeugdaten",
      child: Column(
        children: [
          _feld(baujahrController, "Baujahr"),
          _feld(kilometerController, "Kilometerstand"),
          _feld(leistungController, "Leistung / PS"),
        ],
      ),
    );
  }

  Widget _immobilienFelder() {
    return _karte(
      titel: "Immobilien Details",
      child: Column(
        children: [
          _feld(wohnflaecheController, "Wohnfläche m²"),
          _feld(zimmerController, "Zimmer"),
        ],
      ),
    );
  }

  Widget _booteFelder() {
    return _karte(
      titel: "Boot Details",
      child: BooteFelder(
        markeController: bootMarkeController,
        modellController: bootModellController,
        baujahrController: bootBaujahrController,
        laengeController: bootLaengeController,
        leistungController: bootLeistungController,
        bootstyp: bootstyp,
        onBootstypChanged: (value) {
          setState(() {
            bootstyp = value!;
          });
        },
      ),
    );
  }

  Widget _baumaschinenFelder() {
    return _karte(
      titel: "Baumaschinen Details",
      child: BaumaschinenFelder(
        zustandController: baumaschinenZustandController,
        baujahrController: baumaschinenBaujahrController,
        betriebsstundenController: baumaschinenBetriebsstundenController,
        kraftstoffController: baumaschinenKraftstoffController,
        leistungController: baumaschinenLeistungController,
        gewichtController: baumaschinenGewichtController,
      ),
    );
  }

  Widget _baumarktFelder() {
    return _karte(
      titel: "Baumarkt Details",
      child: BaumarktFelder(
        herstellerController: baumarktHerstellerController,
        materialController: baumarktMaterialController,
        farbeController: baumarktFarbeController,
        masseController: baumarktMasseController,
        gewichtController: baumarktGewichtController,
        mengeController: baumarktMengeController,
      ),
    );
  }

  Widget _produktFelder() {
    return _karte(
      titel: "Produktdetails",
      child: Column(
        children: [
          _feld(herstellerController, "Hersteller"),
          _feld(garantieController, "Garantie"),
        ],
      ),
    );
  }

  Widget _kontaktFelder() {
    return _karte(
      titel: "Kontakt",
      child: Column(
        children: [
          _feld(telefonController, "Telefonnummer"),
          if (typ == "Privat") ...[
            SwitchListTile(
              value: telefonSichtbar,
              title: const Text("Telefon anzeigen"),
              onChanged: (value) {
                setState(() {
                  telefonSichtbar = value;
                });
              },
            ),
            SwitchListTile(
              value: whatsappAktiv,
              title: const Text("WhatsApp anzeigen"),
              onChanged: (value) {
                setState(() {
                  whatsappAktiv = value;
                });
              },
            ),
            SwitchListTile(
              value: emailSichtbar,
              title: const Text("E-Mail anzeigen"),
              onChanged: (value) {
                setState(() {
                  emailSichtbar = value;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _bilderBereich() {
    return _karte(
      titel: "Bilder",
      child: OutlinedButton.icon(
        onPressed: bilderAuswaehlen,
        icon: const Icon(Icons.image_outlined),
        label: const Text("Neue Bilder hinzufügen"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final breit = MediaQuery.of(context).size.width > 900;

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
            const Text(
              "Inserat bearbeiten",
              style: TextStyle(
                color: Color(0xff050b2c),
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            _karte(
              child: Column(
                children: [
                  _dropdown(
                    label: "Verkäufertyp",
                    value: typ,
                    items: const ["Privat", "Firma"],
                    onChanged: (value) {
                      if (value != null) typGeaendert(value);
                    },
                  ),
                  if (typ == "Firma") ...[
                    _feld(firmennameController, "Firmenname"),
                    _feld(webseiteController, "Webseite"),
                  ],
                ],
              ),
            ),
            _karte(
              child: Column(
                children: [
                  _feld(titelController, "Titel"),
                  _feld(preisController, "Preis"),
                  _feld(ortController, "Ort"),
                  _feld(adresseController, "Adresse"),
                  _dropdown(
                    label: "Kategorie",
                    value: kategorie,
                    items: kategorien,
                    onChanged: (value) {
                      setState(() {
                        kategorie = value!;
                        unterkategorie = "";
                      });
                    },
                  ),
                  _unterkategorieDropdown(),
                  _feld(
                    beschreibungController,
                    "Beschreibung",
                    maxLines: 5,
                  ),
                ],
              ),
            ),
            if (kategorie == "Autos") _autoFelder(),
            if (kategorie == "Immobilien") _immobilienFelder(),
            if (kategorie == "Boote") _booteFelder(),
            if (kategorie == "Baumaschinen") _baumaschinenFelder(),
            if (kategorie == "Baumarkt") _baumarktFelder(),
            if (kategorie != "Autos" &&
                kategorie != "Immobilien" &&
                kategorie != "Boote" &&
                kategorie != "Baumaschinen" &&
                kategorie != "Baumarkt")
              _produktFelder(),
            _kontaktFelder(),
            _bilderBereich(),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff5b2cff),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: wirdGespeichert ? null : speichern,
                child: Text(
                  wirdGespeichert
                      ? "Wird gespeichert..."
                      : "Änderungen speichern",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}