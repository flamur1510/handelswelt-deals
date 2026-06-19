import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../kategorien_daten/kategorien.dart' as kdaten;
import '../model/produkt.dart';
import '../widgets/dienstleistungen_felder.dart';
import '../widgets/inserat_form_widgets.dart';
import '../widgets/jobs_felder.dart';

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

  final herstellerController = TextEditingController();
  final garantieController = TextEditingController();

  final autoMarkeController = TextEditingController();
  final autoModellController = TextEditingController();
  final autoBaujahrController = TextEditingController();
  final autoKilometerController = TextEditingController();
  final autoLeistungController = TextEditingController();
  final autoErstzulassungController = TextEditingController();
  final autoFarbeController = TextEditingController();
  final autoTuerenController = TextEditingController();
  final autoSitzeController = TextEditingController();
  final autoPickerlController = TextEditingController();
  final autoVorbesitzerController = TextEditingController();
  final autoKarosserieController = TextEditingController();
  final autoAntriebController = TextEditingController();
  final autoHubraumController = TextEditingController();
  final autoVerbrauchController = TextEditingController();
  final autoCo2Controller = TextEditingController();
  final autoSchluesselController = TextEditingController();

  final immobilienWohnflaecheController = TextEditingController();
  final immobilienZimmerController = TextEditingController();
  final immobilienKautionController = TextEditingController();
  final immobilienBetriebskostenController = TextEditingController();
  final immobilienNutzflaecheController = TextEditingController();
  final immobilienGrundstueckController = TextEditingController();
  final immobilienEtageController = TextEditingController();
  final immobilienHeizungController = TextEditingController();
  final immobilienEnergieausweisController = TextEditingController();
  final immobilienProvisionController = TextEditingController();
  final immobilienVerfuegbarAbController = TextEditingController();
  final immobilienBaujahrController = TextEditingController();
  final immobilienEnergieklasseController = TextEditingController();

  final bootMarkeController = TextEditingController();
  final bootModellController = TextEditingController();
  final bootBaujahrController = TextEditingController();
  final bootLaengeController = TextEditingController();
  final bootLeistungController = TextEditingController();

  final baumaschinenZustandController = TextEditingController();
  final baumaschinenBaujahrController = TextEditingController();
  final baumaschinenBetriebsstundenController = TextEditingController();
  final baumaschinenGewichtController = TextEditingController();

  final baumarktHerstellerController = TextEditingController();
  final baumarktMaterialController = TextEditingController();
  final baumarktMengeController = TextEditingController();

  final jobBerufsbezeichnungController = TextEditingController();
  final jobGehaltController = TextEditingController();
  final jobArbeitsortController = TextEditingController();
  final jobErfahrungController = TextEditingController();

  final dienstleistungEinsatzgebietController = TextEditingController();
  final dienstleistungPreisController = TextEditingController();
  final dienstleistungOeffnungszeitenController = TextEditingController();

  final vermietungTagespreisController = TextEditingController();
  final vermietungWochenpreisController = TextEditingController();
  final vermietungKautionController = TextEditingController();
  final vermietungMindestmietdauerController = TextEditingController();
  final vermietungUebergabeortController = TextEditingController();
  final vermietungVerfuegbarkeitController = TextEditingController();

  String kategorie = "Marktplatz";
  String unterkategorie = "";
  String detailUnterkategorie = "";
  String typ = "";

  String zustand = "Gebraucht";
  String autoKraftstoff = "Benzin";
  String autoGetriebe = "Automatik";
  String autoUnfallfrei = "Ja";
  String autoServicegepflegt = "Ja";
  String autoInzahlungnahme = "Nein";
  String autoLeasingMoeglich = "Nein";
  String autoFinanzierungMoeglich = "Nein";
  String autoNichtraucher = "Nein";
  String autoMwstAusweisbar = "Nein";

  String immobilienArt = "Wohnung mieten";
  String bootstyp = "Motorboot";
  String immobilienBalkon = "Nein";
  String immobilienTerrasse = "Nein";
  String immobilienGarten = "Nein";
  String immobilienGarage = "Nein";
  String immobilienLift = "Nein";
  String immobilienKeller = "Nein";
  String immobilienMoebliert = "Nein";

  String jobHomeoffice = "Kein Homeoffice";
  String jobFuehrerschein = "Nicht erforderlich";
  String jobSchichtarbeit = "Tagschicht";
  String jobReisebereitschaft = "Keine";

  String dienstleistungAnfahrt = "Ja";
  String dienstleistungNotdienst = "Nein";

  String vermietungLieferungMoeglich = "Nein";
  String vermietungVersicherungInklusive = "Nein";

  bool telefonSichtbar = false;
  bool whatsappAktiv = false;
  bool emailSichtbar = false;
  bool wirdGespeichert = false;

  List<Uint8List> bilderBytes = [];

  final zustaende = const [
    "Neu",
    "Wie neu",
    "Sehr gut",
    "Gut",
    "Gebraucht",
    "Defekt",
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

  final immobilienArten = const [
    "Wohnung mieten",
    "Wohnung kaufen",
    "Haus mieten",
    "Haus kaufen",
    "Grundstück",
    "Gewerbeimmobilie",
    "Ferienimmobilie",
  ];

  final bootstypen = const [
    "Motorboot",
    "Segelboot",
    "Yacht",
    "Jetski",
    "Schlauchboot",
    "Hausboot",
    "Angelboot",
    "Kajak/Kanu",
  ];

  @override
  void initState() {
    super.initState();
    kontoTypLaden();
  }

  Future<void> kontoTypLaden() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

    if (!doc.exists) return;

    final data = doc.data() ?? {};
    final kontoTyp = (data["kontoTyp"] ?? "privat").toString();

    if (!mounted) return;

    setState(() {
      typ = kontoTyp == "firma" ? "Firma" : "Privat";

      if (typ == "Firma") {
        firmennameController.text = (data["firmenname"] ?? "").toString();
        webseiteController.text = (data["webseite"] ?? "").toString();
        telefonController.text = (data["telefon"] ?? "").toString();

        telefonSichtbar = true;
        whatsappAktiv = true;
        emailSichtbar = true;
      } else {
        telefonController.text = (data["telefon"] ?? "").toString();

        telefonSichtbar = false;
        whatsappAktiv = false;
        emailSichtbar = false;
      }
    });
  }

  bool istVermietung() {
    const vermietungen = [
      "Autovermietung",
      "Bootsvermietung",
      "Baumaschinenvermietung",
      "Anhängervermietung",
      "Maschinenvermietung",
    ];

    return vermietungen.contains(unterkategorie) ||
        vermietungen.contains(detailUnterkategorie);
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
      "lat": 48.2082,
      "lon": 16.3738,
    };
  }

  Future<void> bilderAuswaehlen() async {
    const maxBilder = 30;

    if (bilderBytes.length >= maxBilder) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Du kannst maximal 30 Bilder hochladen."),
          backgroundColor: Color(0xff5b2cff),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final dateien = await picker.pickMultiImage();

    if (dateien.isEmpty) return;

    final freiePlaetze = maxBilder - bilderBytes.length;
    final ausgewaehlteDateien = dateien.take(freiePlaetze).toList();
    final neueBilder = <Uint8List>[];

    for (final datei in ausgewaehlteDateien) {
      final bytes = await datei.readAsBytes();
      neueBilder.add(bytes);
    }

    setState(() {
      bilderBytes.addAll(neueBilder);
    });

    if (dateien.length > freiePlaetze && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Es wurden nur so viele Bilder übernommen, bis 30 Bilder erreicht sind."),
          backgroundColor: Color(0xff5b2cff),
        ),
      );
    }
  }

  void bildEntfernen(int index) {
    setState(() {
      bilderBytes.removeAt(index);
    });
  }

  void bildAlsTitelbildSetzen(int index) {
    if (index <= 0 || index >= bilderBytes.length) return;

    setState(() {
      final bild = bilderBytes.removeAt(index);
      bilderBytes.insert(0, bild);
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
      final name = "${DateTime.now().millisecondsSinceEpoch}_${urls.length}.jpg";
      final ref = FirebaseStorage.instance.ref().child("inserate").child(name);

      await ref.putData(
        bild,
        SettableMetadata(contentType: "image/jpeg"),
      );

      final url = await ref.getDownloadURL();
      urls.add(url);
    }

    return urls;
  }

  bool pruefen() {
    if (typ == "Privat" && !kdaten.darfPrivatInserieren(kategorie)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Diese Kategorie ist nur für Firmenkonten verfügbar."),
        ),
      );
      return false;
    }

    if (typ == "Privat" &&
        kdaten.istGewerblicheUnterkategorie(kategorie, unterkategorie)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Diese Unterkategorie ist nur für Firmenkonten verfügbar."),
        ),
      );
      return false;
    }

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

    if (istVermietung()) {
      if (vermietungTagespreisController.text.trim().isEmpty &&
          vermietungWochenpreisController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bitte Mietpreis pro Tag oder Woche eingeben."),
          ),
        );
        return false;
      }
      return true;
    }

    if (kategorie == "Auto & Motor" &&
        (autoBaujahrController.text.trim().isEmpty ||
            autoKilometerController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bitte Baujahr und Kilometerstand eingeben."),
        ),
      );
      return false;
    }

    if (kategorie == "Immobilien" &&
        (immobilienWohnflaecheController.text.trim().isEmpty ||
            immobilienZimmerController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bitte Wohnfläche und Zimmer eingeben."),
        ),
      );
      return false;
    }

    if (kategorie == "Jobs" &&
        (jobBerufsbezeichnungController.text.trim().isEmpty ||
            jobArbeitsortController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bitte Berufsbezeichnung und Arbeitsort eingeben."),
        ),
      );
      return false;
    }

    if (kategorie == "Dienstleistungen" &&
        dienstleistungEinsatzgebietController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bitte Einsatzgebiet eingeben."),
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
        const SnackBar(content: Text("Bitte zuerst anmelden.")),
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
        unterkategorie: unterkategorie,
        detailUnterkategorie: detailUnterkategorie,
        typ: typ,
        beschreibung: beschreibungController.text.trim(),
        icon: kdaten.iconFuerKategorie(kategorie),
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
        marke: kategorie == "Auto & Motor" && !istVermietung()
            ? autoMarkeController.text.trim()
            : "",
        modell: kategorie == "Auto & Motor" && !istVermietung()
            ? autoModellController.text.trim()
            : "",
        baujahr: kategorie == "Auto & Motor" && !istVermietung()
            ? autoBaujahrController.text.trim()
            : "",
        kilometer: kategorie == "Auto & Motor" && !istVermietung()
            ? autoKilometerController.text.trim()
            : "",
        kraftstoff: kategorie == "Auto & Motor" && !istVermietung()
            ? autoKraftstoff
            : "",
        getriebe: kategorie == "Auto & Motor" && !istVermietung()
            ? autoGetriebe
            : "",
        leistung: kategorie == "Auto & Motor" && !istVermietung()
            ? autoLeistungController.text.trim()
            : "",
        farbe: kategorie == "Auto & Motor" && !istVermietung()
            ? autoFarbeController.text.trim()
            : "",
        karosserie: kategorie == "Auto & Motor" && !istVermietung()
            ? autoKarosserieController.text.trim()
            : "",
        erstzulassung: kategorie == "Auto & Motor" && !istVermietung()
            ? autoErstzulassungController.text.trim()
            : "",
        vorbesitzer: kategorie == "Auto & Motor" && !istVermietung()
            ? autoVorbesitzerController.text.trim()
            : "",
        antrieb: kategorie == "Auto & Motor" && !istVermietung()
            ? autoAntriebController.text.trim()
            : "",
        tuev: kategorie == "Auto & Motor" && !istVermietung()
            ? autoPickerlController.text.trim()
            : "",
        unfallfrei: kategorie == "Auto & Motor" && !istVermietung()
            ? autoUnfallfrei
            : "",
        tueren: kategorie == "Auto & Motor" && !istVermietung()
            ? autoTuerenController.text.trim()
            : "",
        sitze: kategorie == "Auto & Motor" && !istVermietung()
            ? autoSitzeController.text.trim()
            : "",
        serviceheft: kategorie == "Auto & Motor" && !istVermietung()
            ? autoServicegepflegt
            : "",
        nichtraucher: kategorie == "Auto & Motor" && !istVermietung()
            ? autoNichtraucher
            : "",
        mwstAusweisbar: kategorie == "Auto & Motor" && !istVermietung()
            ? autoMwstAusweisbar
            : "",
        hubraum: kategorie == "Auto & Motor" && !istVermietung()
            ? autoHubraumController.text.trim()
            : "",
        verbrauch: kategorie == "Auto & Motor" && !istVermietung()
            ? autoVerbrauchController.text.trim()
            : "",
        co2: kategorie == "Auto & Motor" && !istVermietung()
            ? autoCo2Controller.text.trim()
            : "",
        schluessel: kategorie == "Auto & Motor" && !istVermietung()
            ? autoSchluesselController.text.trim()
            : "",
        leasingMoeglich: kategorie == "Auto & Motor" && !istVermietung()
            ? autoLeasingMoeglich
            : "",
        finanzierungMoeglich: kategorie == "Auto & Motor" && !istVermietung()
            ? autoFinanzierungMoeglich
            : "",
        inzahlungnahmeMoeglich: kategorie == "Auto & Motor" && !istVermietung()
            ? autoInzahlungnahme
            : "",
        immobilienArt: kategorie == "Immobilien" ? immobilienArt : "",
        wohnflaeche: kategorie == "Immobilien"
            ? immobilienWohnflaecheController.text.trim()
            : "",
        zimmer:
            kategorie == "Immobilien" ? immobilienZimmerController.text.trim() : "",
        kaution: kategorie == "Immobilien"
            ? immobilienKautionController.text.trim()
            : "",
        betriebskosten: kategorie == "Immobilien"
            ? immobilienBetriebskostenController.text.trim()
            : "",
        etage: kategorie == "Immobilien"
            ? immobilienEtageController.text.trim()
            : "",
        balkon: kategorie == "Immobilien" ? immobilienBalkon : "",
        terrasse: kategorie == "Immobilien" ? immobilienTerrasse : "",
        garten: kategorie == "Immobilien" ? immobilienGarten : "",
        garage: kategorie == "Immobilien" ? immobilienGarage : "",
        lift: kategorie == "Immobilien" ? immobilienLift : "",
        keller: kategorie == "Immobilien" ? immobilienKeller : "",
        moebliert: kategorie == "Immobilien" ? immobilienMoebliert : "",
        energieklasse: kategorie == "Immobilien"
            ? immobilienEnergieklasseController.text.trim()
            : "",
        heizung: kategorie == "Immobilien"
            ? immobilienHeizungController.text.trim()
            : "",
        baujahrImmobilie: kategorie == "Immobilien"
            ? immobilienBaujahrController.text.trim()
            : "",
        verfuegbarAb: kategorie == "Immobilien"
            ? immobilienVerfuegbarAbController.text.trim()
            : "",
        zustand: (kategorie == "Jobs" ||
                kategorie == "Dienstleistungen" ||
                istVermietung())
            ? ""
            : zustand,
        hersteller: (kategorie == "Jobs" ||
                kategorie == "Dienstleistungen" ||
                istVermietung())
            ? ""
            : herstellerController.text.trim(),
        garantie: (kategorie == "Jobs" ||
                kategorie == "Dienstleistungen" ||
                istVermietung())
            ? ""
            : garantieController.text.trim(),
        bootMarke: kategorie == "Boote" && !istVermietung()
            ? bootMarkeController.text.trim()
            : "",
        bootModell: kategorie == "Boote" && !istVermietung()
            ? bootModellController.text.trim()
            : "",
        bootBaujahr: kategorie == "Boote" && !istVermietung()
            ? bootBaujahrController.text.trim()
            : "",
        bootLaenge: kategorie == "Boote" && !istVermietung()
            ? bootLaengeController.text.trim()
            : "",
        bootLeistung: kategorie == "Boote" && !istVermietung()
            ? bootLeistungController.text.trim()
            : "",
        bootstyp: kategorie == "Boote" && !istVermietung() ? bootstyp : "",
        baumaschinenZustand: kategorie == "Baumaschinen" && !istVermietung()
            ? baumaschinenZustandController.text.trim()
            : "",
        baumaschinenBaujahr: kategorie == "Baumaschinen" && !istVermietung()
            ? baumaschinenBaujahrController.text.trim()
            : "",
        baumaschinenBetriebsstunden:
            kategorie == "Baumaschinen" && !istVermietung()
                ? baumaschinenBetriebsstundenController.text.trim()
                : "",
        baumaschinenGewicht: kategorie == "Baumaschinen" && !istVermietung()
            ? baumaschinenGewichtController.text.trim()
            : "",
        baumarktHersteller: kategorie == "Baumarkt"
            ? baumarktHerstellerController.text.trim()
            : "",
        baumarktMaterial: kategorie == "Baumarkt"
            ? baumarktMaterialController.text.trim()
            : "",
        baumarktMenge:
            kategorie == "Baumarkt" ? baumarktMengeController.text.trim() : "",
      );

      final produktMap = produkt.toMap();
      produktMap["detailUnterkategorie"] = detailUnterkategorie;

      if (kategorie == "Auto & Motor" && !istVermietung()) {
        produktMap.addAll({
          "autoErstzulassung": autoErstzulassungController.text.trim(),
          "autoFarbe": autoFarbeController.text.trim(),
          "autoTueren": autoTuerenController.text.trim(),
          "autoSitze": autoSitzeController.text.trim(),
          "autoPickerlBis": autoPickerlController.text.trim(),
          "autoVorbesitzer": autoVorbesitzerController.text.trim(),
          "autoKarosserie": autoKarosserieController.text.trim(),
          "autoAntrieb": autoAntriebController.text.trim(),
          "autoHubraum": autoHubraumController.text.trim(),
          "autoVerbrauch": autoVerbrauchController.text.trim(),
          "autoCo2": autoCo2Controller.text.trim(),
          "autoSchluessel": autoSchluesselController.text.trim(),
          "autoUnfallfrei": autoUnfallfrei,
          "autoServicegepflegt": autoServicegepflegt,
          "autoInzahlungnahme": autoInzahlungnahme,
          "autoLeasingMoeglich": autoLeasingMoeglich,
          "autoFinanzierungMoeglich": autoFinanzierungMoeglich,
          "autoNichtraucher": autoNichtraucher,
          "autoMwstAusweisbar": autoMwstAusweisbar,
        });
      }

      if (kategorie == "Immobilien") {
        produktMap.addAll({
          "immobilienNutzflaeche": immobilienNutzflaecheController.text.trim(),
          "immobilienGrundstueck": immobilienGrundstueckController.text.trim(),
          "immobilienEtage": immobilienEtageController.text.trim(),
          "immobilienHeizung": immobilienHeizungController.text.trim(),
          "immobilienEnergieausweis": immobilienEnergieausweisController.text.trim(),
          "immobilienProvision": immobilienProvisionController.text.trim(),
          "immobilienVerfuegbarAb": immobilienVerfuegbarAbController.text.trim(),
          "immobilienBaujahr": immobilienBaujahrController.text.trim(),
          "immobilienEnergieklasse": immobilienEnergieklasseController.text.trim(),
          "immobilienBalkon": immobilienBalkon,
          "immobilienTerrasse": immobilienTerrasse,
          "immobilienGarten": immobilienGarten,
          "immobilienGarage": immobilienGarage,
          "immobilienLift": immobilienLift,
          "immobilienKeller": immobilienKeller,
          "immobilienMoebliert": immobilienMoebliert,
        });
      }

      produktMap["erstelltAm"] = FieldValue.serverTimestamp();

      if (kategorie == "Jobs") {
        produktMap.addAll({
          "jobBerufsbezeichnung": jobBerufsbezeichnungController.text.trim(),
          "jobGehalt": jobGehaltController.text.trim(),
          "jobArbeitsort": jobArbeitsortController.text.trim(),
          "jobErfahrung": jobErfahrungController.text.trim(),
          "jobBeschaeftigungsart": unterkategorie,
          "jobHomeoffice": jobHomeoffice,
          "jobFuehrerschein": jobFuehrerschein,
          "jobSchichtarbeit": jobSchichtarbeit,
          "jobReisebereitschaft": jobReisebereitschaft,
        });
      }

      if (kategorie == "Dienstleistungen") {
        produktMap.addAll({
          "dienstleistungEinsatzgebiet":
              dienstleistungEinsatzgebietController.text.trim(),
          "dienstleistungPreisProStunde":
              dienstleistungPreisController.text.trim(),
          "dienstleistungOeffnungszeiten":
              dienstleistungOeffnungszeitenController.text.trim(),
          "dienstleistungAnfahrt": dienstleistungAnfahrt,
          "dienstleistungNotdienst": dienstleistungNotdienst,
        });
      }

      if (istVermietung()) {
        produktMap.addAll({
          "istVermietung": true,
          "vermietungTagespreis": vermietungTagespreisController.text.trim(),
          "vermietungWochenpreis": vermietungWochenpreisController.text.trim(),
          "vermietungKaution": vermietungKautionController.text.trim(),
          "vermietungMindestmietdauer":
              vermietungMindestmietdauerController.text.trim(),
          "vermietungUebergabeort": vermietungUebergabeortController.text.trim(),
          "vermietungVerfuegbarkeit":
              vermietungVerfuegbarkeitController.text.trim(),
          "vermietungLieferungMoeglich": vermietungLieferungMoeglich,
          "vermietungVersicherungInklusive": vermietungVersicherungInklusive,
        });
      } else {
        produktMap["istVermietung"] = false;
      }

      final doc =
          await FirebaseFirestore.instance.collection("inserate").add(produktMap);

      produkt.id = doc.id;
      widget.onSpeichern(produkt);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inserat veröffentlicht.")),
        );
      }

      formularLeeren();
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

  void formularLeeren() {
    titelController.clear();
    preisController.clear();
    ortController.clear();
    adresseController.clear();
    beschreibungController.clear();

    telefonController.clear();
    firmennameController.clear();
    webseiteController.clear();

    herstellerController.clear();
    garantieController.clear();

    autoMarkeController.clear();
    autoModellController.clear();
    autoBaujahrController.clear();
    autoKilometerController.clear();
    autoLeistungController.clear();
    autoErstzulassungController.clear();
    autoFarbeController.clear();
    autoTuerenController.clear();
    autoSitzeController.clear();
    autoPickerlController.clear();
    autoVorbesitzerController.clear();
    autoKarosserieController.clear();
    autoAntriebController.clear();
    autoHubraumController.clear();
    autoVerbrauchController.clear();
    autoCo2Controller.clear();
    autoSchluesselController.clear();

    immobilienWohnflaecheController.clear();
    immobilienZimmerController.clear();
    immobilienKautionController.clear();
    immobilienBetriebskostenController.clear();
    immobilienNutzflaecheController.clear();
    immobilienGrundstueckController.clear();
    immobilienEtageController.clear();
    immobilienHeizungController.clear();
    immobilienEnergieausweisController.clear();
    immobilienProvisionController.clear();
    immobilienVerfuegbarAbController.clear();
    immobilienBaujahrController.clear();
    immobilienEnergieklasseController.clear();

    bootMarkeController.clear();
    bootModellController.clear();
    bootBaujahrController.clear();
    bootLaengeController.clear();
    bootLeistungController.clear();

    baumaschinenZustandController.clear();
    baumaschinenBaujahrController.clear();
    baumaschinenBetriebsstundenController.clear();
    baumaschinenGewichtController.clear();

    baumarktHerstellerController.clear();
    baumarktMaterialController.clear();
    baumarktMengeController.clear();

    jobBerufsbezeichnungController.clear();
    jobGehaltController.clear();
    jobArbeitsortController.clear();
    jobErfahrungController.clear();

    dienstleistungEinsatzgebietController.clear();
    dienstleistungPreisController.clear();
    dienstleistungOeffnungszeitenController.clear();

    vermietungTagespreisController.clear();
    vermietungWochenpreisController.clear();
    vermietungKautionController.clear();
    vermietungMindestmietdauerController.clear();
    vermietungUebergabeortController.clear();
    vermietungVerfuegbarkeitController.clear();

    setState(() {
      kategorie = "Marktplatz";
      unterkategorie = "";
      detailUnterkategorie = "";
      zustand = "Gebraucht";
      autoKraftstoff = "Benzin";
      autoGetriebe = "Automatik";
      autoUnfallfrei = "Ja";
      autoServicegepflegt = "Ja";
      autoInzahlungnahme = "Nein";
      autoLeasingMoeglich = "Nein";
      autoFinanzierungMoeglich = "Nein";
      autoNichtraucher = "Nein";
      autoMwstAusweisbar = "Nein";
      immobilienArt = "Wohnung mieten";
      bootstyp = "Motorboot";
      immobilienBalkon = "Nein";
      immobilienTerrasse = "Nein";
      immobilienGarten = "Nein";
      immobilienGarage = "Nein";
      immobilienLift = "Nein";
      immobilienKeller = "Nein";
      immobilienMoebliert = "Nein";
      jobHomeoffice = "Kein Homeoffice";
      jobFuehrerschein = "Nicht erforderlich";
      jobSchichtarbeit = "Tagschicht";
      jobReisebereitschaft = "Keine";
      dienstleistungAnfahrt = "Ja";
      dienstleistungNotdienst = "Nein";
      vermietungLieferungMoeglich = "Nein";
      vermietungVersicherungInklusive = "Nein";
      bilderBytes.clear();
    });

    kontoTypLaden();
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

    herstellerController.dispose();
    garantieController.dispose();

    autoMarkeController.dispose();
    autoModellController.dispose();
    autoBaujahrController.dispose();
    autoKilometerController.dispose();
    autoLeistungController.dispose();
    autoErstzulassungController.dispose();
    autoFarbeController.dispose();
    autoTuerenController.dispose();
    autoSitzeController.dispose();
    autoPickerlController.dispose();
    autoVorbesitzerController.dispose();
    autoKarosserieController.dispose();
    autoAntriebController.dispose();
    autoHubraumController.dispose();
    autoVerbrauchController.dispose();
    autoCo2Controller.dispose();
    autoSchluesselController.dispose();

    immobilienWohnflaecheController.dispose();
    immobilienZimmerController.dispose();
    immobilienKautionController.dispose();
    immobilienBetriebskostenController.dispose();
    immobilienNutzflaecheController.dispose();
    immobilienGrundstueckController.dispose();
    immobilienEtageController.dispose();
    immobilienHeizungController.dispose();
    immobilienEnergieausweisController.dispose();
    immobilienProvisionController.dispose();
    immobilienVerfuegbarAbController.dispose();
    immobilienBaujahrController.dispose();
    immobilienEnergieklasseController.dispose();

    bootMarkeController.dispose();
    bootModellController.dispose();
    bootBaujahrController.dispose();
    bootLaengeController.dispose();
    bootLeistungController.dispose();

    baumaschinenZustandController.dispose();
    baumaschinenBaujahrController.dispose();
    baumaschinenBetriebsstundenController.dispose();
    baumaschinenGewichtController.dispose();

    baumarktHerstellerController.dispose();
    baumarktMaterialController.dispose();
    baumarktMengeController.dispose();

    jobBerufsbezeichnungController.dispose();
    jobGehaltController.dispose();
    jobArbeitsortController.dispose();
    jobErfahrungController.dispose();

    dienstleistungEinsatzgebietController.dispose();
    dienstleistungPreisController.dispose();
    dienstleistungOeffnungszeitenController.dispose();

    vermietungTagespreisController.dispose();
    vermietungWochenpreisController.dispose();
    vermietungKautionController.dispose();
    vermietungMindestmietdauerController.dispose();
    vermietungUebergabeortController.dispose();
    vermietungVerfuegbarkeitController.dispose();

    super.dispose();
  }

  Widget _unterkategorieDropdown() {
    final unterkategorien = kdaten.unterkategorienFuer(kategorie);

    if (unterkategorien.isEmpty) {
      return const SizedBox.shrink();
    }

    final aktuellerWert =
        unterkategorien.contains(unterkategorie) ? unterkategorie : unterkategorien.first;

    // Startwert sofort setzen damit Jobdetails korrekt angezeigt werden
    if (unterkategorie.isEmpty || !unterkategorien.contains(unterkategorie)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => unterkategorie = unterkategorien.first);
      });
    }

    return InseratDropdown(
      label: "Unterkategorie",
      value: aktuellerWert,
      items: unterkategorien,
      onChanged: (value) {
        setState(() {
          unterkategorie = value!;
          detailUnterkategorie = "";
        });
      },
    );
  }

  Widget _detailUnterkategorieDropdown() {
    final aktuelleUnterkategorie = unterkategorie.isEmpty
        ? (kdaten.unterkategorienFuer(kategorie).isEmpty
            ? ""
            : kdaten.unterkategorienFuer(kategorie).first)
        : unterkategorie;

    final details = kdaten.detailUnterkategorienFuer(
      kategorie,
      aktuelleUnterkategorie,
    );

    if (details.isEmpty) {
      return const SizedBox.shrink();
    }

    final aktuellerWert =
        details.contains(detailUnterkategorie) ? detailUnterkategorie : details.first;

    return InseratDropdown(
      label: "Detail-Unterkategorie",
      value: aktuellerWert,
      items: details,
      onChanged: (value) {
        setState(() {
          detailUnterkategorie = value!;
        });
      },
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
            _kopfbereich(),
            const SizedBox(height: 18),
            _bilderBereich(),
            const SizedBox(height: 16),
            if (typ.isEmpty)
              InseratKarte(
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xff5b2cff),
                  ),
                ),
              ),
            if (typ == "Firma")
              InseratKarte(
                titel: "Firmenangaben",
                child: Column(
                  children: [
                    InseratFeld(
                      controller: firmennameController,
                      label: "Firmenname",
                    ),
                    InseratFeld(
                      controller: webseiteController,
                      label: "Webseite",
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        "Dieses Inserat wird automatisch als Firmeninserat veröffentlicht.",
                        style: TextStyle(
                          color: Color(0xff74788d),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (typ == "Privat")
              InseratKarte(
                child: const Row(
                  children: [
                    Icon(Icons.person_outline, color: Color(0xff5b2cff)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Dieses Inserat wird automatisch als Privatinserat veröffentlicht.",
                        style: TextStyle(
                          color: Color(0xff050b2c),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            InseratKarte(
              titel: "Grunddaten",
              child: Column(
                children: [
                  InseratFeld(controller: titelController, label: "Titel"),
                  InseratZeile(
                    links: InseratFeld(controller: preisController, label: "Preis"),
                    rechts: InseratFeld(controller: ortController, label: "Ort"),
                  ),
                  InseratFeld(controller: adresseController, label: "Adresse"),
                  InseratDropdown(
                    label: "Kategorie",
                    value: kategorie,
                    items: kdaten.startKategorien.where((e) => e != "Alle").toList(),
                    onChanged: (value) {
                      setState(() {
                        kategorie = value!;
                        unterkategorie = "";
                        detailUnterkategorie = "";
                      });
                    },
                  ),
                  _unterkategorieDropdown(),
                  _detailUnterkategorieDropdown(),
                  InseratFeld(
                    controller: beschreibungController,
                    label: "Beschreibung",
                    maxLines: 5,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (istVermietung()) _vermietungFelder(),
            if (!istVermietung() && kategorie == "Auto & Motor") _autoFelder(),
            if (!istVermietung() && kategorie == "Immobilien") _immobilienFelder(),
            if (!istVermietung() && kategorie == "Boote") _booteFelder(),
            if (!istVermietung() && kategorie == "Baumaschinen")
              _baumaschinenFelder(),
            if (!istVermietung() && kategorie == "Baumarkt") _baumarktFelder(),
            if (kategorie == "Jobs") _jobsFelder(),
            if (kategorie == "Dienstleistungen") _dienstleistungenFelder(),
            if (!istVermietung() &&
                kategorie != "Auto & Motor" &&
                kategorie != "Immobilien" &&
                kategorie != "Boote" &&
                kategorie != "Baumaschinen" &&
                kategorie != "Baumarkt" &&
                kategorie != "Jobs" &&
                kategorie != "Dienstleistungen")
              _produktFelder(),
            const SizedBox(height: 16),
            _kontaktFelder(),
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
                  wirdGespeichert ? "Wird gespeichert..." : "Inserat veröffentlichen",
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

  Widget _kopfbereich() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff050b2c),
        borderRadius: BorderRadius.circular(26),
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
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff5b2cff), Color(0xff7a5cff)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.add_business_outlined,
              color: Colors.white,
              size: 29,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Inserat erstellen",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Fotos zuerst, danach Daten ausfüllen und veröffentlichen.",
                  style: TextStyle(
                    color: Color(0xffb9a8ff),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _autoFelder() {
    return InseratKarte(
      titel: "Auto Details",
      child: Column(
        children: [
          InseratZeile(
            links: InseratFeld(controller: autoMarkeController, label: "Marke"),
            rechts: InseratFeld(controller: autoModellController, label: "Modell"),
          ),
          InseratZeile(
            links: InseratFeld(controller: autoBaujahrController, label: "Baujahr"),
            rechts: InseratFeld(controller: autoErstzulassungController, label: "Erstzulassung"),
          ),
          InseratZeile(
            links: InseratFeld(controller: autoKilometerController, label: "Kilometerstand"),
            rechts: InseratFeld(controller: autoLeistungController, label: "Leistung PS"),
          ),
          InseratZeile(
            links: InseratFeld(controller: autoFarbeController, label: "Farbe"),
            rechts: InseratFeld(controller: autoTuerenController, label: "Türen"),
          ),
          InseratZeile(
            links: InseratFeld(controller: autoSitzeController, label: "Sitze"),
            rechts: InseratFeld(controller: autoPickerlController, label: "Pickerl bis"),
          ),
          InseratZeile(
            links: InseratFeld(controller: autoVorbesitzerController, label: "Vorbesitzer"),
            rechts: InseratFeld(controller: autoKarosserieController, label: "Karosserie"),
          ),
          InseratZeile(
            links: InseratFeld(controller: autoAntriebController, label: "Antrieb"),
            rechts: InseratFeld(controller: autoHubraumController, label: "Hubraum ccm"),
          ),
          InseratZeile(
            links: InseratFeld(controller: autoVerbrauchController, label: "Verbrauch l/100km"),
            rechts: InseratFeld(controller: autoCo2Controller, label: "CO₂ g/km"),
          ),
          InseratZeile(
            links: InseratFeld(controller: autoSchluesselController, label: "Schlüsselanzahl"),
            rechts: InseratDropdown(
              label: "Kraftstoff",
              value: autoKraftstoff,
              items: kraftstoffe,
              onChanged: (value) => setState(() => autoKraftstoff = value!),
            ),
          ),
          InseratZeile(
            links: InseratDropdown(
              label: "Getriebe",
              value: autoGetriebe,
              items: getriebeArten,
              onChanged: (value) => setState(() => autoGetriebe = value!),
            ),
            rechts: InseratDropdown(
              label: "Unfallfrei",
              value: autoUnfallfrei,
              items: const ["Ja", "Nein"],
              onChanged: (value) => setState(() => autoUnfallfrei = value!),
            ),
          ),
          InseratZeile(
            links: InseratDropdown(
              label: "Servicegepflegt",
              value: autoServicegepflegt,
              items: const ["Ja", "Nein"],
              onChanged: (value) => setState(() => autoServicegepflegt = value!),
            ),
            rechts: InseratDropdown(
              label: "Inzahlungnahme",
              value: autoInzahlungnahme,
              items: const ["Ja", "Nein"],
              onChanged: (value) => setState(() => autoInzahlungnahme = value!),
            ),
          ),
          InseratZeile(
            links: InseratDropdown(
              label: "Leasing möglich",
              value: autoLeasingMoeglich,
              items: const ["Ja", "Nein"],
              onChanged: (value) => setState(() => autoLeasingMoeglich = value!),
            ),
            rechts: InseratDropdown(
              label: "Finanzierung",
              value: autoFinanzierungMoeglich,
              items: const ["Ja", "Nein"],
              onChanged: (value) => setState(() => autoFinanzierungMoeglich = value!),
            ),
          ),
          InseratZeile(
            links: InseratDropdown(
              label: "Nichtraucher",
              value: autoNichtraucher,
              items: const ["Ja", "Nein"],
              onChanged: (value) => setState(() => autoNichtraucher = value!),
            ),
            rechts: InseratDropdown(
              label: "MwSt. ausweisbar",
              value: autoMwstAusweisbar,
              items: const ["Ja", "Nein"],
              onChanged: (value) => setState(() => autoMwstAusweisbar = value!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _immobilienFelder() {
    return InseratKarte(
      titel: "Immobilien Details",
      child: Column(
        children: [
          InseratDropdown(
            label: "Immobilienart",
            value: immobilienArt,
            items: immobilienArten,
            onChanged: (value) => setState(() => immobilienArt = value!),
          ),
          InseratZeile(
            links: InseratFeld(controller: immobilienWohnflaecheController, label: "Wohnfläche m²"),
            rechts: InseratFeld(controller: immobilienNutzflaecheController, label: "Nutzfläche m²"),
          ),
          InseratZeile(
            links: InseratFeld(controller: immobilienGrundstueckController, label: "Grundstück m²"),
            rechts: InseratFeld(controller: immobilienZimmerController, label: "Zimmer"),
          ),
          InseratZeile(
            links: InseratFeld(controller: immobilienEtageController, label: "Etage"),
            rechts: InseratFeld(controller: immobilienKautionController, label: "Kaution"),
          ),
          InseratZeile(
            links: InseratFeld(controller: immobilienBetriebskostenController, label: "Betriebskosten"),
            rechts: InseratFeld(controller: immobilienHeizungController, label: "Heizung"),
          ),
          InseratZeile(
            links: InseratFeld(controller: immobilienEnergieausweisController, label: "Energieausweis"),
            rechts: InseratFeld(controller: immobilienProvisionController, label: "Provision"),
          ),
          InseratZeile(
            links: InseratFeld(controller: immobilienVerfuegbarAbController, label: "Verfügbar ab"),
            rechts: InseratFeld(controller: immobilienBaujahrController, label: "Baujahr"),
          ),
          InseratZeile(
            links: InseratFeld(controller: immobilienEnergieklasseController, label: "Energieklasse"),
            rechts: InseratDropdown(
              label: "Balkon",
              value: immobilienBalkon,
              items: const ["Ja", "Nein"],
              onChanged: (value) => setState(() => immobilienBalkon = value!),
            ),
          ),
          InseratZeile(
            links: InseratDropdown(
              label: "Terrasse",
              value: immobilienTerrasse,
              items: const ["Ja", "Nein"],
              onChanged: (value) => setState(() => immobilienTerrasse = value!),
            ),
            rechts: InseratDropdown(
              label: "Garten",
              value: immobilienGarten,
              items: const ["Ja", "Nein"],
              onChanged: (value) => setState(() => immobilienGarten = value!),
            ),
          ),
          InseratZeile(
            links: InseratDropdown(
              label: "Garage/Parkplatz",
              value: immobilienGarage,
              items: const ["Ja", "Nein"],
              onChanged: (value) => setState(() => immobilienGarage = value!),
            ),
            rechts: InseratDropdown(
              label: "Lift",
              value: immobilienLift,
              items: const ["Ja", "Nein"],
              onChanged: (value) => setState(() => immobilienLift = value!),
            ),
          ),
          InseratZeile(
            links: InseratDropdown(
              label: "Keller",
              value: immobilienKeller,
              items: const ["Ja", "Nein"],
              onChanged: (value) => setState(() => immobilienKeller = value!),
            ),
            rechts: InseratDropdown(
              label: "Möbliert",
              value: immobilienMoebliert,
              items: const ["Ja", "Nein"],
              onChanged: (value) => setState(() => immobilienMoebliert = value!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _booteFelder() {
    return InseratKarte(
      titel: "Boot Details",
      child: Column(
        children: [
          InseratDropdown(
            label: "Bootstyp",
            value: bootstyp,
            items: bootstypen,
            onChanged: (value) => setState(() => bootstyp = value!),
          ),
          InseratZeile(
            links: InseratFeld(controller: bootMarkeController, label: "Marke"),
            rechts: InseratFeld(controller: bootModellController, label: "Modell"),
          ),
          InseratZeile(
            links: InseratFeld(controller: bootBaujahrController, label: "Baujahr"),
            rechts: InseratFeld(controller: bootLaengeController, label: "Länge"),
          ),
          InseratFeld(controller: bootLeistungController, label: "Leistung PS"),
        ],
      ),
    );
  }

  Widget _baumaschinenFelder() {
    return InseratKarte(
      titel: "Baumaschinen Details",
      child: Column(
        children: [
          InseratZeile(
            links: InseratFeld(controller: baumaschinenZustandController, label: "Zustand"),
            rechts: InseratFeld(controller: baumaschinenBaujahrController, label: "Baujahr"),
          ),
          InseratZeile(
            links: InseratFeld(controller: baumaschinenBetriebsstundenController, label: "Betriebsstunden"),
            rechts: InseratFeld(controller: baumaschinenGewichtController, label: "Gewicht"),
          ),
        ],
      ),
    );
  }

  Widget _baumarktFelder() {
    return InseratKarte(
      titel: "Baumarkt Details",
      child: Column(
        children: [
          InseratZeile(
            links: InseratFeld(controller: baumarktHerstellerController, label: "Hersteller"),
            rechts: InseratFeld(controller: baumarktMaterialController, label: "Material"),
          ),
          InseratFeld(controller: baumarktMengeController, label: "Menge"),
        ],
      ),
    );
  }

  Widget _jobsFelder() {
    return JobsFelder(
      berufsbezeichnungController: jobBerufsbezeichnungController,
      gehaltController: jobGehaltController,
      arbeitsortController: jobArbeitsortController,
      erfahrungController: jobErfahrungController,
      homeoffice: jobHomeoffice,
      fuehrerschein: jobFuehrerschein,
      schichtarbeit: jobSchichtarbeit,
      reisebereitschaft: jobReisebereitschaft,
      onHomeoffice: (value) {
        setState(() {
          jobHomeoffice = value!;
        });
      },
      onFuehrerschein: (value) {
        setState(() {
          jobFuehrerschein = value!;
        });
      },
      onSchichtarbeit: (value) {
        setState(() {
          jobSchichtarbeit = value!;
        });
      },
      onReisebereitschaft: (value) {
        setState(() {
          jobReisebereitschaft = value!;
        });
      },
    );
  }

  Widget _dienstleistungenFelder() {
    return DienstleistungenFelder(
      einsatzgebietController: dienstleistungEinsatzgebietController,
      preisController: dienstleistungPreisController,
      oeffnungszeitenController: dienstleistungOeffnungszeitenController,
      anfahrt: dienstleistungAnfahrt,
      notdienst: dienstleistungNotdienst,
      onAnfahrt: (value) {
        setState(() {
          dienstleistungAnfahrt = value!;
        });
      },
      onNotdienst: (value) {
        setState(() {
          dienstleistungNotdienst = value!;
        });
      },
    );
  }

  Widget _vermietungFelder() {
    return InseratKarte(
      titel: "Vermietung Details",
      child: Column(
        children: [
          InseratZeile(
            links: InseratFeld(controller: vermietungTagespreisController, label: "Tagespreis"),
            rechts: InseratFeld(controller: vermietungWochenpreisController, label: "Wochenpreis"),
          ),
          InseratZeile(
            links: InseratFeld(controller: vermietungKautionController, label: "Kaution"),
            rechts: InseratFeld(controller: vermietungMindestmietdauerController, label: "Mindestmietdauer"),
          ),
          InseratZeile(
            links: InseratFeld(controller: vermietungUebergabeortController, label: "Übergabeort"),
            rechts: InseratFeld(controller: vermietungVerfuegbarkeitController, label: "Verfügbarkeit"),
          ),
          InseratZeile(
            links: InseratDropdown(
              label: "Lieferung möglich",
              value: vermietungLieferungMoeglich,
              items: const ["Ja", "Nein"],
              onChanged: (value) => setState(() => vermietungLieferungMoeglich = value!),
            ),
            rechts: InseratDropdown(
              label: "Versicherung inkl.",
              value: vermietungVersicherungInklusive,
              items: const ["Ja", "Nein"],
              onChanged: (value) => setState(() => vermietungVersicherungInklusive = value!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _produktFelder() {
    return InseratKarte(
      titel: "Produktdetails",
      child: Column(
        children: [
          InseratDropdown(
            label: "Zustand",
            value: zustand,
            items: zustaende,
            onChanged: (value) => setState(() => zustand = value!),
          ),
          InseratZeile(
            links: InseratFeld(controller: herstellerController, label: "Hersteller"),
            rechts: InseratFeld(controller: garantieController, label: "Garantie"),
          ),
        ],
      ),
    );
  }

  Widget _kontaktFelder() {
    return InseratKarte(
      titel: "Kontakt",
      child: Column(
        children: [
          InseratFeld(controller: telefonController, label: "Telefonnummer"),
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
                style: TextStyle(color: Color(0xff74788d)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bilderBereich() {
    const maxBilder = 30;
    final hatBilder = bilderBytes.isNotEmpty;
    final rest = maxBilder - bilderBytes.length;

    return InseratKarte(
      titel: "Fotos",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: bilderAuswaehlen,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xfff1edff),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xff5b2cff).withOpacity(0.22),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Color(0xff5b2cff),
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hatBilder ? "Weitere Fotos hinzufügen" : "Fotos hinzufügen",
                    style: const TextStyle(
                      color: Color(0xff050b2c),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${bilderBytes.length}/$maxBilder Bilder ausgewählt · erstes Bild ist Titelbild",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xff74788d),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hatBilder) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.image_outlined,
                  color: Color(0xff5b2cff),
                  size: 19,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    rest == 0
                        ? "Maximum erreicht"
                        : "Noch $rest Bilder möglich",
                    style: const TextStyle(
                      color: Color(0xff050b2c),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final breite = constraints.maxWidth;
                final spalten = breite > 760 ? 6 : (breite > 520 ? 4 : 3);
                final itemBreite = (breite - ((spalten - 1) * 9)) / spalten;

                return Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: [
                    for (int index = 0; index < bilderBytes.length; index++)
                      SizedBox(
                        width: itemBreite,
                        height: index == 0 ? itemBreite * 1.15 : itemBreite,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.memory(
                                  bilderBytes[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            if (index == 0)
                              Positioned(
                                left: 7,
                                bottom: 7,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff5b2cff),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    "Titelbild",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Positioned(
                                left: 7,
                                bottom: 7,
                                child: InkWell(
                                  onTap: () => bildAlsTitelbildSetzen(index),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.62),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "Als Titel",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              right: 6,
                              top: 6,
                              child: InkWell(
                                onTap: () => bildEntfernen(index),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.62),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 17,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
