import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../model/produkt.dart';
import '../auto_daten/auto_daten.dart';
import '../immobilien_daten/immobilien_daten.dart';

class InseratSeite extends StatefulWidget {
  final Function(Produkt) onSpeichern;

  const InseratSeite({
    super.key,
    required this.onSpeichern,
  });

  @override
  State<InseratSeite> createState() => _InseratSeiteState();
}

class _InseratSeiteState extends State<InseratSeite> {
  final titelController = TextEditingController();
  final preisController = TextEditingController();
  final ortController = TextEditingController();
  final adresseController = TextEditingController();
  final beschreibungController = TextEditingController();

  final telefonController = TextEditingController();
  final firmennameController = TextEditingController();
  final webseiteController = TextEditingController();

  final baujahrController = TextEditingController();
  final kilometerController = TextEditingController();
  final leistungController = TextEditingController();
  final erstzulassungController = TextEditingController();
  final vorbesitzerController = TextEditingController();
  final tuevController = TextEditingController();
  final hubraumController = TextEditingController();
  final verbrauchController = TextEditingController();
  final co2Controller = TextEditingController();
  final schluesselController = TextEditingController();

  final wohnflaecheController = TextEditingController();
  final zimmerController = TextEditingController();
  final etageController = TextEditingController();
  final kautionController = TextEditingController();
  final betriebskostenController = TextEditingController();
  final baujahrImmobilieController = TextEditingController();

  final herstellerController = TextEditingController();
  final garantieController = TextEditingController();

  String kategorie = "Marktplatz";
  String typ = "Privat";

  String ausgewaehlteMarke = "Audi";
  String ausgewaehltesModell = "A1";
  String ausgewaehlterKraftstoff = "Benzin";
  String ausgewaehltesGetriebe = "Automatik";
  String ausgewaehlterZustand = "Gebraucht";

  String ausgewaehlteFarbe = "Schwarz";
  String ausgewaehlteKarosserie = "Limousine";
  String ausgewaehlterAntrieb = "Frontantrieb";
  String ausgewaehlteUnfallfrei = "Ja";
  String ausgewaehlteTueren = "5";
  String ausgewaehlteSitze = "5";
  String ausgewaehlteServiceheft = "Ja";
  String ausgewaehlteNichtraucher = "Ja";
  String ausgewaehlteMwst = "Nein";
  String ausgewaehltesPickerlNeu = "Nein";

  String ausgewaehltesLeasing = "Nein";
  String ausgewaehlteFinanzierung = "Nein";
  String ausgewaehlteInzahlungnahme = "Nein";

  String ausgewaehlteImmobilienArt = "Wohnung mieten";
  String ausgewaehlterImmobilienZustand = "Gut";
  String ausgewaehlterBalkon = "Nein";
  String ausgewaehlteTerrasse = "Nein";
  String ausgewaehlterGarten = "Nein";
  String ausgewaehlteGarage = "Nein";
  String ausgewaehlterLift = "Nein";
  String ausgewaehlterKeller = "Nein";
  String ausgewaehltMoebliert = "Nein";
  String ausgewaehlteEnergieklasse = "A";
  String ausgewaehlteHeizung = "Fernwärme";
  String ausgewaehlteVerfuegbarkeit = "Sofort";

  bool telefonSichtbar = false;
  bool whatsappAktiv = false;
  bool emailSichtbar = false;
  bool wirdGespeichert = false;

  List<Uint8List> bilderBytes = [];

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
      "lat": 48.2082,
      "lon": 16.3738,
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
      bilderBytes.addAll(neueBilder);
    });
  }

  Future<List<String>> bilderHochladen() async {
    if (bilderBytes.isEmpty) {
      return [
        "https://images.unsplash.com/photo-1523275335684-37898b6baf30",
      ];
    }

    final urls = <String>[];

    for (final bild in bilderBytes) {
      final name =
          "${DateTime.now().millisecondsSinceEpoch}_${urls.length}.jpg";

      final ref = FirebaseStorage.instance
          .ref()
          .child("inserate")
          .child(name);

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

    if (kategorie == "Autos" &&
        (baujahrController.text.trim().isEmpty ||
            kilometerController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bitte Baujahr und Kilometerstand eingeben."),
        ),
      );
      return false;
    }

    if (kategorie == "Immobilien" &&
        (wohnflaecheController.text.trim().isEmpty ||
            zimmerController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bitte Wohnfläche und Zimmer eingeben."),
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> speichern() async {
    if (!pruefen()) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bitte zuerst anmelden."),
        ),
      );
      return;
    }

    setState(() {
      wirdGespeichert = true;
    });

    try {
      final sucheAdresse = adresseController.text.trim().isEmpty
          ? ortController.text.trim()
          : "${adresseController.text.trim()}, ${ortController.text.trim()}";

      final koordinaten = await koordinatenHolen(sucheAdresse);
      final bildUrls = await bilderHochladen();

      final produkt = Produkt(
        titel: titelController.text.trim(),
        preis: preisController.text.trim(),
        ort: ortController.text.trim(),
        adresse: adresseController.text.trim(),
        kategorie: kategorie,
        typ: typ,
        beschreibung: beschreibungController.text.trim(),
        icon: iconFuerKategorie(kategorie),
        bild: bildUrls.first,
        bilder: bildUrls,
        verkaeuferId: user.uid,
        verkaeuferEmail: user.email ?? "",
        telefon: telefonController.text.trim(),
        firmenname: firmennameController.text.trim(),
        webseite: webseiteController.text.trim(),
        telefonSichtbar: telefonSichtbar,
        whatsappAktiv: whatsappAktiv,
        emailSichtbar: emailSichtbar,
        latitude: koordinaten["lat"] ?? 48.2082,
        longitude: koordinaten["lon"] ?? 16.3738,

        marke: kategorie == "Autos" ? ausgewaehlteMarke : "",
        modell: kategorie == "Autos" ? ausgewaehltesModell : "",
        baujahr: baujahrController.text.trim(),
        kilometer: kilometerController.text.trim(),
        kraftstoff: kategorie == "Autos" ? ausgewaehlterKraftstoff : "",
        getriebe: kategorie == "Autos" ? ausgewaehltesGetriebe : "",
        leistung: leistungController.text.trim(),
        farbe: kategorie == "Autos" ? ausgewaehlteFarbe : "",
        karosserie: kategorie == "Autos" ? ausgewaehlteKarosserie : "",
        erstzulassung: erstzulassungController.text.trim(),
        vorbesitzer: vorbesitzerController.text.trim(),
        antrieb: kategorie == "Autos" ? ausgewaehlterAntrieb : "",
        tuev: tuevController.text.trim(),
        unfallfrei: kategorie == "Autos" ? ausgewaehlteUnfallfrei : "",
        tueren: kategorie == "Autos" ? ausgewaehlteTueren : "",
        sitze: kategorie == "Autos" ? ausgewaehlteSitze : "",
        serviceheft: kategorie == "Autos" ? ausgewaehlteServiceheft : "",
        nichtraucher: kategorie == "Autos" ? ausgewaehlteNichtraucher : "",
        mwstAusweisbar: kategorie == "Autos" ? ausgewaehlteMwst : "",
        hubraum: hubraumController.text.trim(),
        verbrauch: verbrauchController.text.trim(),
        co2: co2Controller.text.trim(),
        schluessel: schluesselController.text.trim(),
        pickerlNeu: kategorie == "Autos" ? ausgewaehltesPickerlNeu : "",
        leasingMoeglich:
            kategorie == "Autos" && typ == "Firma" ? ausgewaehltesLeasing : "",
        finanzierungMoeglich: kategorie == "Autos" && typ == "Firma"
            ? ausgewaehlteFinanzierung
            : "",
        inzahlungnahmeMoeglich: kategorie == "Autos" && typ == "Firma"
            ? ausgewaehlteInzahlungnahme
            : "",

        immobilienArt:
            kategorie == "Immobilien" ? ausgewaehlteImmobilienArt : "",
        wohnflaeche: wohnflaecheController.text.trim(),
        zimmer: zimmerController.text.trim(),
        etage: etageController.text.trim(),
        kaution: kautionController.text.trim(),
        betriebskosten: betriebskostenController.text.trim(),
        balkon: kategorie == "Immobilien" ? ausgewaehlterBalkon : "",
        terrasse: kategorie == "Immobilien" ? ausgewaehlteTerrasse : "",
        garten: kategorie == "Immobilien" ? ausgewaehlterGarten : "",
        garage: kategorie == "Immobilien" ? ausgewaehlteGarage : "",
        lift: kategorie == "Immobilien" ? ausgewaehlterLift : "",
        keller: kategorie == "Immobilien" ? ausgewaehlterKeller : "",
        moebliert: kategorie == "Immobilien" ? ausgewaehltMoebliert : "",
        energieklasse:
            kategorie == "Immobilien" ? ausgewaehlteEnergieklasse : "",
        heizung: kategorie == "Immobilien" ? ausgewaehlteHeizung : "",
        baujahrImmobilie: baujahrImmobilieController.text.trim(),
        verfuegbarAb:
            kategorie == "Immobilien" ? ausgewaehlteVerfuegbarkeit : "",

        zustand: kategorie == "Immobilien"
            ? ausgewaehlterImmobilienZustand
            : ausgewaehlterZustand,
        hersteller: herstellerController.text.trim(),
        garantie: garantieController.text.trim(),
      );

      final doc = await FirebaseFirestore.instance
          .collection("inserate")
          .add(produkt.toMap());

      produkt.id = doc.id;

      widget.onSpeichern(produkt);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Inserat veröffentlicht."),
          ),
        );
      }

      formularLeeren();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Fehler: $e"),
        ),
      );
    }

    setState(() {
      wirdGespeichert = false;
    });
  }

  void formularLeeren() {
    titelController.clear();
    preisController.clear();
    ortController.clear();
    adresseController.clear();
    beschreibungController.clear();

    telefonController.clear();
    firmennameController.clear();
    webseiteController.clear();

    baujahrController.clear();
    kilometerController.clear();
    leistungController.clear();
    erstzulassungController.clear();
    vorbesitzerController.clear();
    tuevController.clear();
    hubraumController.clear();
    verbrauchController.clear();
    co2Controller.clear();
    schluesselController.clear();

    wohnflaecheController.clear();
    zimmerController.clear();
    etageController.clear();
    kautionController.clear();
    betriebskostenController.clear();
    baujahrImmobilieController.clear();

    herstellerController.clear();
    garantieController.clear();

    setState(() {
      kategorie = "Marktplatz";
      typ = "Privat";

      ausgewaehlteMarke = "Audi";
      ausgewaehltesModell = "A1";
      ausgewaehlterKraftstoff = "Benzin";
      ausgewaehltesGetriebe = "Automatik";
      ausgewaehlterZustand = "Gebraucht";
      ausgewaehlteFarbe = "Schwarz";
      ausgewaehlteKarosserie = "Limousine";
      ausgewaehlterAntrieb = "Frontantrieb";
      ausgewaehlteUnfallfrei = "Ja";
      ausgewaehlteTueren = "5";
      ausgewaehlteSitze = "5";
      ausgewaehlteServiceheft = "Ja";
      ausgewaehlteNichtraucher = "Ja";
      ausgewaehlteMwst = "Nein";
      ausgewaehltesPickerlNeu = "Nein";
      ausgewaehltesLeasing = "Nein";
      ausgewaehlteFinanzierung = "Nein";
      ausgewaehlteInzahlungnahme = "Nein";

      ausgewaehlteImmobilienArt = "Wohnung mieten";
      ausgewaehlterImmobilienZustand = "Gut";
      ausgewaehlterBalkon = "Nein";
      ausgewaehlteTerrasse = "Nein";
      ausgewaehlterGarten = "Nein";
      ausgewaehlteGarage = "Nein";
      ausgewaehlterLift = "Nein";
      ausgewaehlterKeller = "Nein";
      ausgewaehltMoebliert = "Nein";
      ausgewaehlteEnergieklasse = "A";
      ausgewaehlteHeizung = "Fernwärme";
      ausgewaehlteVerfuegbarkeit = "Sofort";

      telefonSichtbar = false;
      whatsappAktiv = false;
      emailSichtbar = false;
      bilderBytes.clear();
    });
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

    super.dispose();
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
              "Inserat erstellen",
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
            const SizedBox(height: 16),
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
                      });
                    },
                  ),
                  _feld(
                    beschreibungController,
                    "Beschreibung",
                    maxLines: 5,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (kategorie == "Autos") _autoFelder(),
            if (kategorie == "Immobilien") _immobilienFelder(),
            if (kategorie != "Autos" && kategorie != "Immobilien")
              _produktFelder(),
            const SizedBox(height: 16),
            _kontaktFelder(),
            const SizedBox(height: 16),
            _bilderBereich(),
            const SizedBox(height: 20),
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
                      : "Inserat veröffentlichen",
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

  Widget _autoFelder() {
    final modelle = autoModelle[ausgewaehlteMarke] ?? ["Andere"];

    if (!modelle.contains(ausgewaehltesModell)) {
      ausgewaehltesModell = modelle.first;
    }

    return _karte(
      titel: "Fahrzeugdaten",
      child: Column(
        children: [
          _dropdown(
            label: "Marke",
            value: ausgewaehlteMarke,
            items: autoMarken,
            onChanged: (value) {
              setState(() {
                ausgewaehlteMarke = value!;
                final neueModelle =
                    autoModelle[ausgewaehlteMarke] ?? ["Andere"];
                ausgewaehltesModell = neueModelle.first;
              });
            },
          ),
          _dropdown(
            label: "Modell",
            value: ausgewaehltesModell,
            items: modelle,
            onChanged: (value) {
              setState(() {
                ausgewaehltesModell = value!;
              });
            },
          ),
          _feld(baujahrController, "Baujahr"),
          _feld(erstzulassungController, "Erstzulassung z.B. 03/2022"),
          _feld(kilometerController, "Kilometerstand"),
          _dropdown(
            label: "Kraftstoff",
            value: ausgewaehlterKraftstoff,
            items: kraftstoffe,
            onChanged: (value) {
              setState(() {
                ausgewaehlterKraftstoff = value!;
              });
            },
          ),
          _dropdown(
            label: "Getriebe",
            value: ausgewaehltesGetriebe,
            items: getriebeArten,
            onChanged: (value) {
              setState(() {
                ausgewaehltesGetriebe = value!;
              });
            },
          ),
          _feld(leistungController, "Leistung / PS"),
          _feld(hubraumController, "Hubraum cm³"),
          _feld(verbrauchController, "Verbrauch l/100km"),
          _feld(co2Controller, "CO₂ Emission"),
          _feld(schluesselController, "Anzahl Schlüssel"),
          _dropdown(
            label: "Karosserie",
            value: ausgewaehlteKarosserie,
            items: karosserien,
            onChanged: (value) {
              setState(() {
                ausgewaehlteKarosserie = value!;
              });
            },
          ),
          _dropdown(
            label: "Farbe",
            value: ausgewaehlteFarbe,
            items: farben,
            onChanged: (value) {
              setState(() {
                ausgewaehlteFarbe = value!;
              });
            },
          ),
          _dropdown(
            label: "Antrieb",
            value: ausgewaehlterAntrieb,
            items: antriebe,
            onChanged: (value) {
              setState(() {
                ausgewaehlterAntrieb = value!;
              });
            },
          ),
          _feld(vorbesitzerController, "Vorbesitzer"),
          _feld(tuevController, "Pickerl / TÜV bis"),
          _dropdown(
            label: "Pickerl neu",
            value: ausgewaehltesPickerlNeu,
            items: jaNein,
            onChanged: (value) {
              setState(() {
                ausgewaehltesPickerlNeu = value!;
              });
            },
          ),
          _dropdown(
            label: "Unfallfrei",
            value: ausgewaehlteUnfallfrei,
            items: jaNein,
            onChanged: (value) {
              setState(() {
                ausgewaehlteUnfallfrei = value!;
              });
            },
          ),
          _dropdown(
            label: "Türen",
            value: ausgewaehlteTueren,
            items: tuerenListe,
            onChanged: (value) {
              setState(() {
                ausgewaehlteTueren = value!;
              });
            },
          ),
          _dropdown(
            label: "Sitze",
            value: ausgewaehlteSitze,
            items: sitzeListe,
            onChanged: (value) {
              setState(() {
                ausgewaehlteSitze = value!;
              });
            },
          ),
          _dropdown(
            label: "Serviceheft gepflegt",
            value: ausgewaehlteServiceheft,
            items: jaNein,
            onChanged: (value) {
              setState(() {
                ausgewaehlteServiceheft = value!;
              });
            },
          ),
          _dropdown(
            label: "Nichtraucherfahrzeug",
            value: ausgewaehlteNichtraucher,
            items: jaNein,
            onChanged: (value) {
              setState(() {
                ausgewaehlteNichtraucher = value!;
              });
            },
          ),
          _dropdown(
            label: "MwSt. ausweisbar",
            value: ausgewaehlteMwst,
            items: jaNein,
            onChanged: (value) {
              setState(() {
                ausgewaehlteMwst = value!;
              });
            },
          ),
          if (typ == "Firma") ...[
            _dropdown(
              label: "Leasing möglich",
              value: ausgewaehltesLeasing,
              items: jaNein,
              onChanged: (value) {
                setState(() {
                  ausgewaehltesLeasing = value!;
                });
              },
            ),
            _dropdown(
              label: "Finanzierung möglich",
              value: ausgewaehlteFinanzierung,
              items: jaNein,
              onChanged: (value) {
                setState(() {
                  ausgewaehlteFinanzierung = value!;
                });
              },
            ),
            _dropdown(
              label: "Inzahlungnahme möglich",
              value: ausgewaehlteInzahlungnahme,
              items: jaNein,
              onChanged: (value) {
                setState(() {
                  ausgewaehlteInzahlungnahme = value!;
                });
              },
            ),
          ],
          _dropdown(
            label: "Zustand",
            value: ausgewaehlterZustand,
            items: zustaende,
            onChanged: (value) {
              setState(() {
                ausgewaehlterZustand = value!;
              });
            },
          ),
          _feld(garantieController, "Garantie"),
        ],
      ),
    );
  }

  Widget _immobilienFelder() {
    return _karte(
      titel: "Immobilien Details",
      child: Column(
        children: [
          _dropdown(
            label: "Immobilienart",
            value: ausgewaehlteImmobilienArt,
            items: immobilienArten,
            onChanged: (value) {
              setState(() {
                ausgewaehlteImmobilienArt = value!;
              });
            },
          ),
          _feld(wohnflaecheController, "Wohnfläche m²"),
          _feld(zimmerController, "Zimmer"),
          _feld(etageController, "Etage"),
          _feld(kautionController, "Kaution"),
          _feld(betriebskostenController, "Betriebskosten"),
          _feld(baujahrImmobilieController, "Baujahr"),
          _dropdown(
            label: "Balkon",
            value: ausgewaehlterBalkon,
            items: jaNeinImmobilien,
            onChanged: (value) {
              setState(() {
                ausgewaehlterBalkon = value!;
              });
            },
          ),
          _dropdown(
            label: "Terrasse",
            value: ausgewaehlteTerrasse,
            items: jaNeinImmobilien,
            onChanged: (value) {
              setState(() {
                ausgewaehlteTerrasse = value!;
              });
            },
          ),
          _dropdown(
            label: "Garten",
            value: ausgewaehlterGarten,
            items: jaNeinImmobilien,
            onChanged: (value) {
              setState(() {
                ausgewaehlterGarten = value!;
              });
            },
          ),
          _dropdown(
            label: "Garage/Stellplatz",
            value: ausgewaehlteGarage,
            items: jaNeinImmobilien,
            onChanged: (value) {
              setState(() {
                ausgewaehlteGarage = value!;
              });
            },
          ),
          _dropdown(
            label: "Lift",
            value: ausgewaehlterLift,
            items: jaNeinImmobilien,
            onChanged: (value) {
              setState(() {
                ausgewaehlterLift = value!;
              });
            },
          ),
          _dropdown(
            label: "Keller",
            value: ausgewaehlterKeller,
            items: jaNeinImmobilien,
            onChanged: (value) {
              setState(() {
                ausgewaehlterKeller = value!;
              });
            },
          ),
          _dropdown(
            label: "Möbliert",
            value: ausgewaehltMoebliert,
            items: jaNeinImmobilien,
            onChanged: (value) {
              setState(() {
                ausgewaehltMoebliert = value!;
              });
            },
          ),
          _dropdown(
            label: "Energieklasse",
            value: ausgewaehlteEnergieklasse,
            items: energieklassen,
            onChanged: (value) {
              setState(() {
                ausgewaehlteEnergieklasse = value!;
              });
            },
          ),
          _dropdown(
            label: "Heizung",
            value: ausgewaehlteHeizung,
            items: heizungsarten,
            onChanged: (value) {
              setState(() {
                ausgewaehlteHeizung = value!;
              });
            },
          ),
          _dropdown(
            label: "Verfügbarkeit",
            value: ausgewaehlteVerfuegbarkeit,
            items: verfuegbarkeit,
            onChanged: (value) {
              setState(() {
                ausgewaehlteVerfuegbarkeit = value!;
              });
            },
          ),
          _dropdown(
            label: "Zustand",
            value: ausgewaehlterImmobilienZustand,
            items: immobilienZustaende,
            onChanged: (value) {
              setState(() {
                ausgewaehlterImmobilienZustand = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _produktFelder() {
    return _karte(
      titel: "Produktdetails",
      child: Column(
        children: [
          _dropdown(
            label: "Zustand",
            value: ausgewaehlterZustand,
            items: zustaende,
            onChanged: (value) {
              setState(() {
                ausgewaehlterZustand = value!;
              });
            },
          ),
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
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                "Bei Firmen werden Telefon, WhatsApp und E-Mail automatisch angezeigt.",
                style: TextStyle(
                  color: Color(0xff74788d),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bilderBereich() {
    return _karte(
      titel: "Bilder",
      child: Column(
        children: [
          OutlinedButton.icon(
            onPressed: bilderAuswaehlen,
            icon: const Icon(Icons.image_outlined),
            label: const Text("Bilder auswählen"),
          ),
          if (bilderBytes.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 105,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: bilderBytes.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 105,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(
                        bilderBytes[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _karte({
    String? titel,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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

  Widget _feld(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : items.first,
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
}