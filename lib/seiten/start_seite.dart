// lib/seiten/start_seite.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import '../model/produkt.dart';
import '../kategorien_daten/kategorien.dart';
import '../kategorien_daten/marken_hersteller.dart';
import '../kategorien_daten/filter_felder.dart';
import 'detail_seite.dart';
import 'benachrichtigungen_seite.dart';
import 'firmen_profil_seite.dart';

class StartSeite extends StatefulWidget {
  final List<Produkt> produkte;
  final Function(Produkt) favoritWechseln;
  final VoidCallback zuInserat;

  const StartSeite({
    super.key,
    required this.produkte,
    required this.favoritWechseln,
    required this.zuInserat,
  });

  @override
  State<StartSeite> createState() => _StartSeiteState();
}

class _StartSeiteState extends State<StartSeite> {
  String suche = "";
  String ausgewaehlteKategorie = "Alle";
  String filterUnterkategorie = "Alle";
  String filterDetailUnterkategorie = "Alle";
  String filterMarke = "Alle";
  String filterModell = "Alle";
  String filterAnbieter = "Alle";
  String filterKraftstoff = "Alle";
  String filterGetriebe = "Alle";
  String filterImmobilienArt = "Alle";
  String filterBalkon = "Alle";
  String filterGarage = "Alle";
  String sortierung = "Neueste zuerst";
  String umkreisFilter = "Österreichweit";

  bool standortAktiv = false;
  bool standortLaedt = false;
  double? meineLatitude;
  double? meineLongitude;

  final sucheController = TextEditingController();
  final ortController = TextEditingController();
  final preisVonController = TextEditingController();
  final preisBisController = TextEditingController();
  final baujahrVonController = TextEditingController();
  final baujahrBisController = TextEditingController();
  final kilometerVonController = TextEditingController();
  final kilometerBisController = TextEditingController();
  final psVonController = TextEditingController();
  final psBisController = TextEditingController();
  final wohnflaecheVonController = TextEditingController();
  final wohnflaecheBisController = TextEditingController();
  final zimmerVonController = TextEditingController();
  final zimmerBisController = TextEditingController();
  final bootLaengeVonController = TextEditingController();
  final bootLaengeBisController = TextEditingController();
  final betriebsstundenBisController = TextEditingController();
  final berufsbezeichnungController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final sortierungen = const [
    "Neueste zuerst",
    "Älteste zuerst",
    "Preis aufsteigend",
    "Preis absteigend",
  ];

  final umkreisOptionen = const [
    "Österreichweit",
    "5 km",
    "10 km",
    "25 km",
    "50 km",
    "100 km",
    "250 km",
  ];

  final anbieterOptionen = const [
    "Alle",
    "Privat",
    "Firma",
  ];

  final kraftstoffOptionen = const [
    "Alle",
    "Benzin",
    "Diesel",
    "Elektro",
    "Hybrid",
    "Plug-in-Hybrid",
    "Gas",
    "Andere",
  ];

  final getriebeOptionen = const [
    "Alle",
    "Schaltgetriebe",
    "Automatik",
    "Halbautomatik",
  ];

  final immobilienArtOptionen = const [
    "Alle",
    "Wohnung",
    "Haus",
    "Grundstück",
    "Gewerbe",
    "Garage/Stellplatz",
    "Büro",
    "Lager",
  ];

  final jaNeinOptionen = const ["Alle", "Ja", "Nein"];

  final Map<String, List<double>> ortKoordinaten = const {
    "wien": [48.2082, 16.3738],
    "graz": [47.0707, 15.4395],
    "linz": [48.3069, 14.2858],
    "salzburg": [47.8095, 13.0550],
    "innsbruck": [47.2692, 11.4041],
    "klagenfurt": [46.6247, 14.3053],
    "villach": [46.6086, 13.8506],
    "wels": [48.1575, 14.0289],
    "st. pölten": [48.2047, 15.6256],
    "sankt pölten": [48.2047, 15.6256],
    "dornbirn": [47.4125, 9.7417],
    "wiener neustadt": [47.8119, 16.2439],
    "steyr": [48.0427, 14.4213],
    "feldkirch": [47.2370, 9.5985],
    "bregenz": [47.5031, 9.7471],
    "leoben": [47.3765, 15.0914],
    "krems": [48.4092, 15.6141],
    "krems an der donau": [48.4092, 15.6141],
    "baden": [48.0064, 16.2326],
    "mödling": [48.0853, 16.2839],
    "amstetten": [48.1229, 14.8721],
    "vöcklabruck": [48.0089, 13.6558],
    "voecklabruck": [48.0089, 13.6558],
    "gmunden": [47.9184, 13.7993],
    "attnang-puchheim": [48.0083, 13.7167],
    "regau": [47.9903, 13.6889],
    "schwanenstadt": [48.0550, 13.7750],
    "ried im innkreis": [48.2117, 13.4886],
    "braunau am inn": [48.2563, 13.0434],
    "eferding": [48.3089, 14.0225],
    "perg": [48.2500, 14.6333],
    "freistadt": [48.5110, 14.5045],
    "rohrbach": [48.5724, 13.9886],
    "kirchdorf an der krems": [47.9056, 14.1246],
    "hallein": [47.6833, 13.1000],
    "zell am see": [47.3235, 12.7969],
    "sankt johann im pongau": [47.3500, 13.2000],
    "st. johann im pongau": [47.3500, 13.2000],
    "bischofshofen": [47.4167, 13.2167],
    "tamsweg": [47.1281, 13.8111],
    "kufstein": [47.5833, 12.1667],
    "wörgl": [47.4833, 12.0667],
    "woergl": [47.4833, 12.0667],
    "schwaz": [47.3517, 11.7100],
    "lienz": [46.8297, 12.7690],
    "imst": [47.2450, 10.7397],
    "bludenz": [47.1548, 9.8220],
    "spittal an der drau": [46.7989, 13.4978],
    "wolfsberg": [46.8406, 14.8442],
    "feldkirchen in kärnten": [46.7227, 14.0967],
    "feldkirchen in kaernten": [46.7227, 14.0967],
    "kapfenberg": [47.4446, 15.2933],
    "bruck an der mur": [47.4167, 15.2667],
    "knittelfeld": [47.2167, 14.8167],
    "leibnitz": [46.7816, 15.5384],
    "weiz": [47.2167, 15.6167],
    "hartberg": [47.2806, 15.9694],
    "mistelbach": [48.5700, 16.5767],
    "tulln": [48.3315, 16.0586],
    "klosterneuburg": [48.3052, 16.3252],
    "stockerau": [48.3833, 16.2167],
    "hollabrunn": [48.5620, 16.0785],
    "horn": [48.6627, 15.6566],
    "waidhofen an der thaya": [48.8167, 15.2833],
    "zwettl": [48.6073, 15.1671],
    "gänserndorf": [48.3393, 16.7202],
    "gaenserndorf": [48.3393, 16.7202],
    "neusiedl am see": [47.9490, 16.8417],
    "eisenstadt": [47.8456, 16.5333],
    "oberwart": [47.2897, 16.2053],
    "güssing": [47.0594, 16.3244],
    "guessing": [47.0594, 16.3244],
  };

  @override
  void dispose() {
    scrollController.dispose();
    sucheController.dispose();
    ortController.dispose();
    preisVonController.dispose();
    preisBisController.dispose();
    baujahrVonController.dispose();
    baujahrBisController.dispose();
    kilometerVonController.dispose();
    kilometerBisController.dispose();
    psVonController.dispose();
    psBisController.dispose();
    wohnflaecheVonController.dispose();
    wohnflaecheBisController.dispose();
    zimmerVonController.dispose();
    zimmerBisController.dispose();
    bootLaengeVonController.dispose();
    bootLaengeBisController.dispose();
    betriebsstundenBisController.dispose();
    berufsbezeichnungController.dispose();
    super.dispose();
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

  String mitEinheit(String wert, String einheit) {
    final sauber = wert.trim();
    if (sauber.isEmpty) return "";
    if (einheit.isEmpty) return sauber;
    if (sauber.toLowerCase().contains(einheit.toLowerCase())) return sauber;
    return "$sauber $einheit";
  }

  List<String> _unterkategorienFilterItems() {
    if (ausgewaehlteKategorie == "Alle") return const ["Alle"];
    return ["Alle", ...unterkategorienSucheFuer(ausgewaehlteKategorie)];
  }

  List<String> _detailFilterItems() {
    if (ausgewaehlteKategorie == "Alle") return const ["Alle"];
    if (filterUnterkategorie == "Alle") return const ["Alle"];

    final details = detailUnterkategorienSucheFuer(
      ausgewaehlteKategorie,
      filterUnterkategorie,
    );

    if (details.isEmpty) return const ["Alle"];

    return ["Alle", ...details];
  }

  String _markeVonProdukt(Produkt produkt) {
    final werte = <String>[
      if (produkt.kategorie == "Auto & Motor") produkt.marke,
      if (produkt.kategorie == "Autos") produkt.marke,
      if (produkt.kategorie == "Boote") produkt.bootMarke,
      if (produkt.kategorie == "Baumarkt") produkt.baumarktHersteller,
      produkt.marke,
      produkt.bootMarke,
      produkt.baumarktHersteller,
      produkt.hersteller,
    ];

    for (final wert in werte) {
      final sauber = wert.trim();
      if (sauber.isNotEmpty) return sauber;
    }

    return "";
  }

  String _modellVonProdukt(Produkt produkt) {
    final werte = <String>[
      if (produkt.kategorie == "Auto & Motor") produkt.modell,
      if (produkt.kategorie == "Autos") produkt.modell,
      if (produkt.kategorie == "Boote") produkt.bootModell,
      produkt.modell,
      produkt.bootModell,
    ];

    for (final wert in werte) {
      final sauber = wert.trim();
      if (sauber.isNotEmpty) return sauber;
    }

    return "";
  }

  bool _basisFilterFuerMarken(Produkt produkt) {
    return kategoriePasst(produkt) &&
        unterkategoriePasst(produkt) &&
        detailUnterkategoriePasst(produkt);
  }

  String _norm(String wert) {
    return wert.trim().toLowerCase();
  }

  List<String> _standardMarkenFuerKategorie() {
    final sammlung = <String, String>{};

    void addAll(List<String> werte) {
      for (final wert in werte) {
        final sauber = wert.trim();
        if (sauber.isNotEmpty && sauber != "Alle") {
          sammlung[_norm(sauber)] = sauber;
        }
      }
    }

    try {
      addAll(
        markenHerstellerFuerFilter(
          kategorie: ausgewaehlteKategorie,
          unterkategorie: filterUnterkategorie,
          detailUnterkategorie: filterDetailUnterkategorie,
        ),
      );
    } catch (_) {
      // Falls die externe Marken-Datei noch nicht komplett ist,
      // greifen die Handelswelt-Fallback-Listen unten.
    }

    addAll(_fallbackMarkenHerstellerFuerFilter());

    final liste = sammlung.values.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return liste;
  }

  List<String> _fallbackMarkenHerstellerFuerFilter() {
    final kategorie = _norm(ausgewaehlteKategorie);
    final unter = _norm(filterUnterkategorie);
    final detail = _norm(filterDetailUnterkategorie);
    final kombi = "$kategorie $unter $detail";

    const pkwMarken = [
      "Abarth", "Alfa Romeo", "Alpina", "Aston Martin", "Audi", "Bentley",
      "BMW", "BYD", "Cadillac", "Chevrolet", "Chrysler", "Citroën", "Cupra",
      "Dacia", "Daewoo", "Daihatsu", "Dodge", "DS Automobiles", "Ferrari",
      "Fiat", "Ford", "Genesis", "Honda", "Hyundai", "Infiniti", "Jaguar",
      "Jeep", "Kia", "Lada", "Lamborghini", "Lancia", "Land Rover", "Lexus",
      "Lotus", "Maserati", "Mazda", "McLaren", "Mercedes-Benz", "MG", "Mini",
      "Mitsubishi", "Nissan", "Opel", "Peugeot", "Polestar", "Porsche",
      "Renault", "Rolls-Royce", "Saab", "Seat", "Skoda", "Smart", "SsangYong",
      "Subaru", "Suzuki", "Tesla", "Toyota", "Volkswagen", "Volvo",
    ];

    const lkwMarken = [
      "DAF", "Fuso", "Ford Trucks", "Iveco", "MAN", "Mercedes-Benz Trucks",
      "Renault Trucks", "Scania", "Tatra", "Volvo Trucks", "Unimog",
    ];

    const transporterMarken = [
      "Citroën Jumper", "Citroën Jumpy", "Fiat Ducato", "Ford Transit",
      "Iveco Daily", "MAN TGE", "Mercedes-Benz Sprinter", "Mercedes-Benz Vito",
      "Nissan NV", "Opel Movano", "Opel Vivaro", "Peugeot Boxer",
      "Peugeot Expert", "Renault Master", "Renault Trafic", "Toyota Proace",
      "VW Caddy", "VW Crafter", "VW Transporter",
    ];

    const motorradMarken = [
      "Aprilia", "Benelli", "BMW Motorrad", "Ducati", "GasGas",
      "Harley-Davidson", "Honda", "Husqvarna", "Indian", "Kawasaki", "KTM",
      "Moto Guzzi", "Piaggio", "Suzuki", "Triumph", "Vespa", "Yamaha",
    ];

    const anhaengerMarken = [
      "Anssems", "Böckmann", "Brenderup", "Eduard", "Hapert", "Humbaur",
      "Koch", "Pongratz", "Saris", "Stema", "Unsinn",
    ];

    const bootMarken = [
      "Alumacraft", "Astondoa", "Azimut", "Bavaria", "Bayliner", "Beneteau",
      "Boston Whaler", "Cranchi", "Fairline", "Ferretti", "Four Winns",
      "Jeanneau", "Lagoon", "Malibu", "MasterCraft", "Monterey", "Princess",
      "Quicksilver", "Regal", "Riva", "Sea Ray", "Sunseeker", "Wellcraft",
      "Yamaha Boats",
    ];

    const baumaschinenHersteller = [
      "Atlas Copco", "Bobcat", "Bomag", "Case Construction", "Caterpillar",
      "Doosan", "Dynapac", "Hitachi", "Hyundai CE", "JCB", "Kobelco",
      "Komatsu", "Kubota", "Liebherr", "Manitou", "New Holland Construction",
      "Sany", "Takeuchi", "Terex", "Volvo CE", "Wacker Neuson", "Yanmar",
    ];

    const landwirtschaftHersteller = [
      "Case IH", "Claas", "Deutz-Fahr", "Fendt", "John Deere", "Kubota",
      "Massey Ferguson", "New Holland", "Pöttinger", "Same", "Steyr", "Valtra",
    ];

    const baumarktHersteller = [
      "AEG", "Bahco", "Black+Decker", "Bosch", "DeWalt", "Einhell", "Festool",
      "Fischer", "Hilti", "Kärcher", "Knipex", "Makita", "Metabo",
      "Milwaukee", "Ryobi", "Stanley", "Stihl", "Wera", "Wiha", "Wolfcraft",
    ];

    if (kategorie == "boote") return bootMarken;
    if (kategorie == "baumaschinen") return baumaschinenHersteller;
    if (kategorie == "landwirtschaft") return landwirtschaftHersteller;
    if (kategorie == "baumarkt") return baumarktHersteller;
    if (kategorie == "anhänger" || kategorie == "anhaenger") return anhaengerMarken;

    if (kategorie == "auto & motor" || kategorie == "autos") {
      if (kombi.contains("lkw") ||
          kombi.contains("lastwagen") ||
          kombi.contains("nutzfahrzeug")) {
        return lkwMarken;
      }

      if (kombi.contains("transporter") ||
          kombi.contains("bus") ||
          kombi.contains("van") ||
          kombi.contains("kleinbus")) {
        return transporterMarken;
      }

      if (kombi.contains("motorrad") ||
          kombi.contains("moped") ||
          kombi.contains("roller")) {
        return motorradMarken;
      }

      if (kombi.contains("anhänger") || kombi.contains("anhaenger")) {
        return anhaengerMarken;
      }

      if (unter == "alle" && detail == "alle") {
        return [
          ...pkwMarken,
          ...lkwMarken,
          ...transporterMarken,
          ...motorradMarken,
          ...anhaengerMarken,
        ];
      }

      return pkwMarken;
    }

    if (kategorie == "alle") {
      return [
        ...pkwMarken,
        ...lkwMarken,
        ...transporterMarken,
        ...motorradMarken,
        ...anhaengerMarken,
        ...bootMarken,
        ...baumaschinenHersteller,
        ...landwirtschaftHersteller,
        ...baumarktHersteller,
      ];
    }

    return const [];
  }

  List<String> _markenFilterItems() {
    final alleMarken = <String, String>{};

    for (final marke in _standardMarkenFuerKategorie()) {
      final sauber = marke.trim();
      if (sauber.isNotEmpty) alleMarken[_norm(sauber)] = sauber;
    }

    for (final produkt in widget.produkte.where(_basisFilterFuerMarken)) {
      for (final wert in [
        produkt.marke,
        produkt.hersteller,
        produkt.bootMarke,
        produkt.baumarktHersteller,
      ]) {
        final sauber = wert.trim();
        if (sauber.isNotEmpty) alleMarken[_norm(sauber)] = sauber;
      }
    }

    final marken = alleMarken.values.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return ["Alle", ...marken];
  }

  List<String> _modellFilterItems() {
    final modelleMap = <String, String>{};

    if (filterMarke != "Alle") {
      for (final modell in modelleFuerMarkeUndBereich(
        kategorie: ausgewaehlteKategorie,
        unterkategorie: filterUnterkategorie,
        detailUnterkategorie: filterDetailUnterkategorie,
        marke: filterMarke,
      )) {
        final sauber = modell.trim();
        if (sauber.isNotEmpty) modelleMap[_norm(sauber)] = sauber;
      }
    }

    for (final produkt in widget.produkte.where((produkt) {
      if (!_basisFilterFuerMarken(produkt)) return false;
      if (filterMarke != "Alle" && _norm(_markeVonProdukt(produkt)) != _norm(filterMarke)) {
        return false;
      }
      return true;
    })) {
      for (final wert in [produkt.modell, produkt.bootModell]) {
        final sauber = wert.trim();
        if (sauber.isNotEmpty) modelleMap[_norm(sauber)] = sauber;
      }
    }

    final modelle = modelleMap.values.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return ["Alle", ...modelle];
  }

  bool preisPasst(Produkt produkt) {
    final preis = zahl(produkt.preis);
    final von = zahl(preisVonController.text);
    final bis = zahl(preisBisController.text);

    if (von > 0 && preis < von) return false;
    if (bis > 0 && preis > bis) return false;

    return true;
  }

  bool kategoriePasst(Produkt produkt) {
    if (ausgewaehlteKategorie == "Alle") return true;
    return produkt.kategorie == ausgewaehlteKategorie;
  }

  bool unterkategoriePasst(Produkt produkt) {
    if (filterUnterkategorie == "Alle") return true;
    return produkt.unterkategorie == filterUnterkategorie;
  }

  bool detailUnterkategoriePasst(Produkt produkt) {
    if (filterDetailUnterkategorie == "Alle") return true;
    return produkt.detailUnterkategorie == filterDetailUnterkategorie;
  }

  bool markePasst(Produkt produkt) {
    if (filterMarke == "Alle") return true;
    return _norm(_markeVonProdukt(produkt)) == _norm(filterMarke);
  }

  bool modellPasst(Produkt produkt) {
    if (filterModell == "Alle") return true;
    return _norm(_modellVonProdukt(produkt)) == _norm(filterModell);
  }

  bool anbieterPasst(Produkt produkt) {
    if (produkt.kategorie == "Jobs" || produkt.kategorie == "Dienstleistungen") {
      return produkt.typ == "Firma";
    }

    if (filterAnbieter == "Alle") return true;
    return produkt.typ == filterAnbieter;
  }


  bool _zahlBereichPasst(String wert, TextEditingController vonCtrl, TextEditingController bisCtrl) {
    final nummer = zahl(wert);
    final von = zahl(vonCtrl.text);
    final bis = zahl(bisCtrl.text);

    if (von > 0 && nummer < von) return false;
    if (bis > 0 && nummer > bis) return false;
    return true;
  }

  bool detailDatenPasst(Produkt produkt) {
    if (produkt.kategorie == "Auto & Motor" || produkt.kategorie == "Autos") {
      if (!_zahlBereichPasst(produkt.baujahr, baujahrVonController, baujahrBisController)) return false;
      if (!_zahlBereichPasst(produkt.kilometer, kilometerVonController, kilometerBisController)) return false;
      if (!_zahlBereichPasst(produkt.leistung, psVonController, psBisController)) return false;
      if (filterKraftstoff != "Alle" && _norm(produkt.kraftstoff) != _norm(filterKraftstoff)) return false;
      if (filterGetriebe != "Alle" && _norm(produkt.getriebe) != _norm(filterGetriebe)) return false;
    }

    if (produkt.kategorie == "Immobilien") {
      if (filterImmobilienArt != "Alle" && _norm(produkt.immobilienArt) != _norm(filterImmobilienArt) && _norm(produkt.detailUnterkategorie) != _norm(filterImmobilienArt)) return false;
      if (!_zahlBereichPasst(produkt.wohnflaeche, wohnflaecheVonController, wohnflaecheBisController)) return false;
      if (!_zahlBereichPasst(produkt.zimmer, zimmerVonController, zimmerBisController)) return false;
      if (filterBalkon != "Alle" && _norm(produkt.balkon) != _norm(filterBalkon)) return false;
      if (filterGarage != "Alle" && _norm(produkt.garage) != _norm(filterGarage)) return false;
    }

    if (produkt.kategorie == "Boote") {
      if (!_zahlBereichPasst(produkt.bootBaujahr, baujahrVonController, baujahrBisController)) return false;
      if (!_zahlBereichPasst(produkt.bootLaenge, bootLaengeVonController, bootLaengeBisController)) return false;
      if (!_zahlBereichPasst(produkt.bootLeistung, psVonController, psBisController)) return false;
    }

    if (produkt.kategorie == "Baumaschinen") {
      if (!_zahlBereichPasst(produkt.baumaschinenBaujahr, baujahrVonController, baujahrBisController)) return false;
      final betriebsstundenBis = zahl(betriebsstundenBisController.text);
      if (betriebsstundenBis > 0 && zahl(produkt.baumaschinenBetriebsstunden) > betriebsstundenBis) return false;
    }

    if (produkt.kategorie == "Jobs") {
      final berufssuche = berufsbezeichnungController.text.trim().toLowerCase();
      if (berufssuche.isNotEmpty) {
        final berufsfeld = [
          produkt.jobBerufsbezeichnung,
          produkt.titel,
          produkt.unterkategorie,
        ].join(" ").toLowerCase();
        if (!berufsfeld.contains(berufssuche)) return false;
      }
    }

    return true;
  }

  bool suchePasst(Produkt produkt) {
    final text = suche.trim().toLowerCase();
    if (text.isEmpty) return true;

    final suchText = [
      produkt.titel,
      produkt.preis,
      produkt.ort,
      produkt.kategorie,
      produkt.unterkategorie,
      produkt.detailUnterkategorie,
      produkt.typ,
      produkt.beschreibung,
      produkt.marke,
      produkt.modell,
      produkt.immobilienArt,
      produkt.zustand,
      produkt.hersteller,
      produkt.bootMarke,
      produkt.bootModell,
      produkt.baumarktHersteller,
      produkt.baumarktMaterial,
    ].join(" ").toLowerCase();

    return suchText.contains(text);
  }

  List<double>? koordinatenFuerOrt(String ort) {
    final sauber = ort.trim().toLowerCase();
    if (sauber.isEmpty) return null;

    for (final eintrag in ortKoordinaten.entries) {
      if (sauber == eintrag.key || sauber.contains(eintrag.key)) {
        return eintrag.value;
      }
    }

    return null;
  }

  double entfernungKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const erdradiusKm = 6371.0;

    final dLat = (lat2 - lat1) * math.pi / 180.0;
    final dLon = (lon2 - lon1) * math.pi / 180.0;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180.0) *
            math.cos(lat2 * math.pi / 180.0) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return erdradiusKm * c;
  }

  double umkreisKm() {
    if (umkreisFilter == "Österreichweit") return 0;

    return double.tryParse(
          umkreisFilter.replaceAll("km", "").trim(),
        ) ??
        0;
  }

  bool ortPasst(Produkt produkt) {
    if (standortAktiv && meineLatitude != null && meineLongitude != null) {
      final radius = umkreisKm();
      if (radius <= 0) return true;
      final produktLat = produkt.latitude;
      final produktLon = produkt.longitude;
      if (produktLat == 0 && produktLon == 0) return true;
      return entfernungKm(meineLatitude!, meineLongitude!, produktLat, produktLon) <= radius;
    }

    final ortText = ortController.text.trim().toLowerCase();
    if (ortText.isEmpty) return true;

    final produktOrt = produkt.ort.trim().toLowerCase();
    final radius = umkreisKm();

    if (radius <= 0) {
      return produktOrt.contains(ortText);
    }

    final suchKoordinaten = koordinatenFuerOrt(ortText);

    if (suchKoordinaten == null) {
      return produktOrt.contains(ortText);
    }

    final produktLat = produkt.latitude;
    final produktLon = produkt.longitude;

    if (produktLat == 0 && produktLon == 0) {
      return produktOrt.contains(ortText);
    }

    final entfernung = entfernungKm(
      suchKoordinaten[0],
      suchKoordinaten[1],
      produktLat,
      produktLon,
    );

    return entfernung <= radius;
  }

  List<Produkt> gefilterteProdukte() {
    final liste = widget.produkte.where((produkt) {
      return suchePasst(produkt) &&
          kategoriePasst(produkt) &&
          unterkategoriePasst(produkt) &&
          detailUnterkategoriePasst(produkt) &&
          markePasst(produkt) &&
          modellPasst(produkt) &&
          anbieterPasst(produkt) &&
          detailDatenPasst(produkt) &&
          ortPasst(produkt) &&
          preisPasst(produkt);
    }).toList();

    if (sortierung == "Älteste zuerst") {
      liste.sort((a, b) =>
          widget.produkte.indexOf(b).compareTo(widget.produkte.indexOf(a)));
    } else if (sortierung == "Preis aufsteigend") {
      liste.sort((a, b) => zahl(a.preis).compareTo(zahl(b.preis)));
    } else if (sortierung == "Preis absteigend") {
      liste.sort((a, b) => zahl(b.preis).compareTo(zahl(a.preis)));
    }

    return liste;
  }

  void filterZuruecksetzen() {
    setState(() {
      suche = "";
      sucheController.clear();
      ortController.clear();
      preisVonController.clear();
      preisBisController.clear();
      baujahrVonController.clear();
      baujahrBisController.clear();
      kilometerVonController.clear();
      kilometerBisController.clear();
      psVonController.clear();
      psBisController.clear();
      wohnflaecheVonController.clear();
      wohnflaecheBisController.clear();
      zimmerVonController.clear();
      zimmerBisController.clear();
      bootLaengeVonController.clear();
      bootLaengeBisController.clear();
      betriebsstundenBisController.clear();
      berufsbezeichnungController.clear();
      ausgewaehlteKategorie = "Alle";
      filterUnterkategorie = "Alle";
      filterDetailUnterkategorie = "Alle";
      filterMarke = "Alle";
      filterModell = "Alle";
      filterAnbieter = "Alle";
      filterKraftstoff = "Alle";
      filterGetriebe = "Alle";
      filterImmobilienArt = "Alle";
      filterBalkon = "Alle";
      filterGarage = "Alle";
      sortierung = "Neueste zuerst";
      umkreisFilter = "Österreichweit";
      standortAktiv = false;
      meineLatitude = null;
      meineLongitude = null;
    });
  }

  Future<void> standortAktivieren(void Function(VoidCallback) setzen) async {
    setzen(() => standortLaedt = true);
    try {
      final dienstAktiv = await Geolocator.isLocationServiceEnabled();
      if (!dienstAktiv) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitte Standort am Gerät aktivieren.')),
        );
        return;
      }
      LocationPermission erlaubnis = await Geolocator.checkPermission();
      if (erlaubnis == LocationPermission.denied) {
        erlaubnis = await Geolocator.requestPermission();
      }
      if (erlaubnis == LocationPermission.denied ||
          erlaubnis == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Standort-Berechtigung wurde nicht erlaubt.')),
        );
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      setzen(() {
        meineLatitude = position.latitude;
        meineLongitude = position.longitude;
        standortAktiv = true;
        if (umkreisFilter == "Österreichweit") umkreisFilter = "25 km";
        ortController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Standort Fehler: $e')),
      );
    } finally {
      if (mounted) setzen(() => standortLaedt = false);
    }
  }

  void standortDeaktivieren(void Function(VoidCallback) setzen) {
    setzen(() {
      standortAktiv = false;
      meineLatitude = null;
      meineLongitude = null;
      umkreisFilter = "Österreichweit";
    });
  }

  void _logoZurStartseite() {
    filterZuruecksetzen();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final produkte = gefilterteProdukte();

    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final breit = constraints.maxWidth > 900;

            return ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: [
                _header(breit),
                _kompakteSuche(breit),
                _heroBannerKlein(breit),
                _beliebteKategorien(breit),
                _startInseratBereiche(produkte, breit),
                _footer(breit),
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
        vertical: 12,
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _logoZurStartseite,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(breit ? 9 : 8),
                  child: Image.asset(
                    'assets/logo/image_neu2.png',
                    width: breit ? 46 : 38,
                    height: breit ? 46 : 38,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 9),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "HANDELSWELT",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Color(0xff050b2c),
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                        height: 1,
                      ),
                    ),
                    Text(
                      "DEALS",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Color(0xff5b2cff),
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: breit ? 34 : 12),
          if (breit)
            Expanded(
              child: SizedBox(
                height: 48,
                child: TextField(
                  controller: sucheController,
                  onChanged: (wert) {
                    setState(() {
                      suche = wert;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Suche nach Autos, Immobilien, Jobs...",
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xff5b2cff),
                    ),
                    filled: true,
                    fillColor: const Color(0xfff3f3f8),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: 12),
          _benachrichtigungsGlocke(),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(17),
            onTap: widget.zuInserat,
            child: Container(
              height: 48,
              width: breit ? 178 : 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff5b2cff),
                    Color(0xff7a5cff),
                  ],
                ),
                borderRadius: BorderRadius.circular(17),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x335b2cff),
                    blurRadius: 14,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: breit
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 19,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Inserat erstellen",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      )
                    : const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benachrichtigungsGlocke() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return IconButton(
        tooltip: "Nachrichten",
        icon: const Icon(
          Icons.forum_outlined,
          color: Color(0xff050b2c),
          size: 29,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const BenachrichtigungenSeite(),
            ),
          );
        },
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("benachrichtigungen")
          .where("userId", isEqualTo: user.uid)
          .where("gelesen", isEqualTo: false)
          .snapshots(),
      builder: (context, benachrichtigungSnapshot) {
        final normaleBenachrichtigungen =
            benachrichtigungSnapshot.data?.docs.length ?? 0;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("chats")
              .where("teilnehmer", arrayContains: user.uid)
              .where("ungelesenFuer", isEqualTo: user.uid)
              .snapshots(),
          builder: (context, chatSnapshot) {
            final ungeleseneChats = chatSnapshot.data?.docs.length ?? 0;
            final anzahl = normaleBenachrichtigungen + ungeleseneChats;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: "Nachrichten",
                  icon: const Icon(
                    Icons.forum_outlined,
                    color: Color(0xff050b2c),
                    size: 29,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BenachrichtigungenSeite(),
                      ),
                    );
                  },
                ),
                if (anzahl > 0)
                  Positioned(
                    right: 3,
                    top: 3,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 19,
                        minHeight: 19,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        anzahl > 99 ? "99+" : anzahl.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _kategorienLeiste() {
    return Container(
      height: 76,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 38),
        itemCount: startKategorien.length,
        itemBuilder: (context, index) {
          final kategorie = startKategorien[index];
          final aktiv = ausgewaehlteKategorie == kategorie;

          return GestureDetector(
            onTap: () {
              setState(() {
                ausgewaehlteKategorie = kategorie;
                filterUnterkategorie = "Alle";
                filterDetailUnterkategorie = "Alle";
                filterMarke = "Alle";
                filterModell = "Alle";
              });
            },
            child: Container(
              width: 112,
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconFuerKategorie(kategorie),
                    color: aktiv
                        ? const Color(0xff5b2cff)
                        : const Color(0xff11152f),
                    size: 23,
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


  Widget _kompakteSuche(bool breit) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        breit ? 46 : 16,
        18,
        breit ? 46 : 16,
        0,
      ),
      child: Container(
        padding: EdgeInsets.all(breit ? 16 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xffececf4)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: breit
            ? Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 52,
                      child: TextField(
                        controller: sucheController,
                        onChanged: (wert) {
                          setState(() {
                            suche = wert;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Was suchst du?",
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xff5b2cff),
                          ),
                          filled: true,
                          fillColor: const Color(0xfff7f7fb),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(17),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 52,
                      child: _ortSuchFeld(kompakt: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _filterButton(),
                  const SizedBox(width: 10),
                  _filterZuruecksetzenButton(),
                ],
              )
            : Column(
                children: [
                  SizedBox(
                    height: 52,
                    child: TextField(
                      controller: sucheController,
                      onChanged: (wert) {
                        setState(() {
                          suche = wert;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Was suchst du?",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xff5b2cff),
                        ),
                        filled: true,
                        fillColor: const Color(0xfff7f7fb),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: TextField(
                            controller: ortController,
                            onChanged: (_) {
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              hintText: "Österreichweit",
                              prefixIcon: const Icon(
                                Icons.location_on_outlined,
                                color: Color(0xff5b2cff),
                              ),
                              filled: true,
                              fillColor: const Color(0xfff7f7fb),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(17),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _filterButton(),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _filterButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: _filterDialogOeffnen,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: const Color(0xfff1edff),
          borderRadius: BorderRadius.circular(17),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              color: Color(0xff5b2cff),
              size: 20,
            ),
            SizedBox(width: 7),
            Text(
              "Filter",
              style: TextStyle(
                color: Color(0xff5b2cff),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _filterDialogOeffnen() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final kategorieItems = [
          "Alle",
          ...startKategorien.where((e) => e != "Alle"),
        ];

        return StatefulBuilder(
          builder: (context, modalSetState) {
            void neuSetzen(VoidCallback fn) {
              setState(fn);
              modalSetState(() {});
            }

            final unterkategorieItems = _unterkategorienFilterItems();
            final detailItems = _detailFilterItems();
            final markenItems = _markenFilterItems();
            final modellItems = _modellFilterItems();

            return DraggableScrollableSheet(
              initialChildSize: 0.78,
              minChildSize: 0.45,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xffd8d8e8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Row(
                        children: [
                          Icon(
                            Icons.tune,
                            color: Color(0xff5b2cff),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Erweiterte Filter",
                            style: TextStyle(
                              color: Color(0xff050b2c),
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _suchDropdown(
                        label: "Kategorie",
                        value: ausgewaehlteKategorie,
                        items: kategorieItems,
                        icon: Icons.category_outlined,
                        onChanged: (value) {
                          if (value == null) return;
                          neuSetzen(() {
                            ausgewaehlteKategorie = value;
                            filterUnterkategorie = "Alle";
                            filterDetailUnterkategorie = "Alle";
                            filterMarke = "Alle";
                            filterModell = "Alle";
                            filterAnbieter = istFirmenKategorie(value) ? "Firma" : "Alle";
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      _suchDropdown(
                        label: "Unterkategorie",
                        value: filterUnterkategorie,
                        items: unterkategorieItems,
                        icon: Icons.account_tree_outlined,
                        onChanged: (value) {
                          if (value == null) return;
                          neuSetzen(() {
                            filterUnterkategorie = value;
                            filterDetailUnterkategorie = "Alle";
                            filterMarke = "Alle";
                            filterModell = "Alle";
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      _suchDropdown(
                        label: "Detail",
                        value: filterDetailUnterkategorie,
                        items: detailItems,
                        icon: Icons.label_outline,
                        onChanged: (value) {
                          if (value == null) return;
                          neuSetzen(() {
                            filterDetailUnterkategorie = value;
                            filterMarke = "Alle";
                            filterModell = "Alle";
                          });
                        },
                      ),
                      if (_zeigtMarkenFilter()) ...[
                        const SizedBox(height: 10),
                        _suchbareAuswahl(
                          label: _markenFilterLabel(),
                          value: filterMarke,
                          items: markenItems,
                          icon: Icons.verified_outlined,
                          onSelected: (value) {
                            neuSetzen(() {
                              filterMarke = value;
                              filterModell = "Alle";
                            });
                          },
                        ),
                      ],
                      if (_zeigtModellFilter()) ...[
                        const SizedBox(height: 10),
                        _suchbareAuswahl(
                          label: _modellFilterLabel(),
                          value: filterModell,
                          items: modellItems,
                          icon: Icons.sell_outlined,
                          onSelected: (value) {
                            neuSetzen(() {
                              filterModell = value;
                            });
                          },
                        ),
                      ],
                      const SizedBox(height: 10),
                      _kategorieDetailFilter(neuSetzen),
                      if (!_istFirmenKategorieAktiv()) ...[
                        const SizedBox(height: 10),
                        _suchDropdown(
                          label: "Anbieter",
                          value: filterAnbieter,
                          items: anbieterOptionen,
                          icon: Icons.person_outline,
                          onChanged: (value) {
                            if (value == null) return;
                            neuSetzen(() {
                              filterAnbieter = value;
                            });
                          },
                        ),
                      ],
                      const SizedBox(height: 10),
                      TextField(
                        controller: ortController,
                        onChanged: (_) {
                          neuSetzen(() {
                            standortAktiv = false;
                            meineLatitude = null;
                            meineLongitude = null;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Ort / Stadt",
                          prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xff5b2cff)),
                          suffixIcon: ortController.text.trim().isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    neuSetzen(() {
                                      ortController.clear();
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: standortAktiv
                                ? const Color(0xff5b2cff)
                                : Colors.white,
                            foregroundColor: standortAktiv
                                ? Colors.white
                                : const Color(0xff5b2cff),
                            side: const BorderSide(color: Color(0xff5b2cff)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: standortLaedt
                              ? null
                              : (standortAktiv
                                  ? () => standortDeaktivieren(neuSetzen)
                                  : () => standortAktivieren(neuSetzen)),
                          icon: standortLaedt
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(standortAktiv
                                  ? Icons.location_on
                                  : Icons.my_location_outlined),
                          label: Text(
                            standortLaedt
                                ? 'Standort wird geholt...'
                                : (standortAktiv
                                    ? 'Mein Standort aktiv'
                                    : 'In meiner Nähe'),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _suchDropdown(
                        label: "Umkreis",
                        value: umkreisFilter,
                        items: umkreisOptionen,
                        icon: Icons.near_me_outlined,
                        onChanged: (value) {
                          if (value == null) return;
                          neuSetzen(() {
                            umkreisFilter = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      _suchDropdown(
                        label: "Sortieren",
                        value: sortierung,
                        items: sortierungen,
                        icon: Icons.swap_vert,
                        onChanged: (value) {
                          if (value == null) return;
                          neuSetzen(() {
                            sortierung = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _preisFeld(preisVonController, "Preis von"),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _preisFeld(preisBisController, "Preis bis"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                neuSetzen(filterZuruecksetzen);
                              },
                              icon: const Icon(Icons.restart_alt),
                              label: const Text("Zurücksetzen"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xff5b2cff),
                                side: const BorderSide(
                                  color: Color(0xff5b2cff),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(17),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(sheetContext);
                              },
                              icon: const Icon(Icons.check),
                              label: const Text("Anwenden"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff5b2cff),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(17),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _suchFilterGross(bool breit) {
    final kategorieItems = ["Alle", ...startKategorien.where((e) => e != "Alle")];
    final unterkategorieItems = _unterkategorienFilterItems();
    final detailItems = _detailFilterItems();
    final markenItems = _markenFilterItems();
    final modellItems = _modellFilterItems();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        breit ? 46 : 16,
        18,
        breit ? 46 : 16,
        0,
      ),
      child: Container(
        padding: EdgeInsets.all(breit ? 18 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xffececf4)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.tune,
                  color: Color(0xff5b2cff),
                  size: 22,
                ),
                SizedBox(width: 8),
                Text(
                  "Suchfilter",
                  style: TextStyle(
                    color: Color(0xff050b2c),
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            breit
                ? Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _suchTextFeld(
                          label: "Was suchst du?",
                          icon: Icons.search,
                          onChanged: (value) {
                            setState(() {
                              suche = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _ortFeld(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _suchDropdown(
                          label: "Umkreis",
                          value: umkreisFilter,
                          items: umkreisOptionen,
                          icon: Icons.near_me_outlined,
                          onChanged: (value) {
                            setState(() {
                              umkreisFilter = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _suchDropdown(
                          label: "Kategorie",
                          value: ausgewaehlteKategorie,
                          items: kategorieItems,
                          icon: Icons.category_outlined,
                          onChanged: (value) {
                            setState(() {
                              ausgewaehlteKategorie = value!;
                              filterUnterkategorie = "Alle";
                              filterDetailUnterkategorie = "Alle";
                              filterAnbieter = istFirmenKategorie(value) ? "Firma" : "Alle";
                            });
                          },
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _suchTextFeld(
                        label: "Was suchst du?",
                        icon: Icons.search,
                        onChanged: (value) {
                          setState(() {
                            suche = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      _ortFeld(),
                      const SizedBox(height: 10),
                      _suchDropdown(
                        label: "Umkreis",
                        value: umkreisFilter,
                        items: umkreisOptionen,
                        icon: Icons.near_me_outlined,
                        onChanged: (value) {
                          setState(() {
                            umkreisFilter = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      _suchDropdown(
                        label: "Kategorie",
                        value: ausgewaehlteKategorie,
                        items: kategorieItems,
                        icon: Icons.category_outlined,
                        onChanged: (value) {
                          setState(() {
                            ausgewaehlteKategorie = value!;
                            filterUnterkategorie = "Alle";
                            filterDetailUnterkategorie = "Alle";
                            filterAnbieter = istFirmenKategorie(value) ? "Firma" : "Alle";
                          });
                        },
                      ),
                    ],
                  ),
            const SizedBox(height: 10),
            breit
                ? Row(
                    children: [
                      Expanded(
                        child: _suchDropdown(
                          label: "Unterkategorie",
                          value: filterUnterkategorie,
                          items: unterkategorieItems,
                          icon: Icons.account_tree_outlined,
                          onChanged: (value) {
                            setState(() {
                              filterUnterkategorie = value!;
                              filterDetailUnterkategorie = "Alle";
                              filterMarke = "Alle";
                              filterModell = "Alle";
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _suchDropdown(
                          label: "Detail",
                          value: filterDetailUnterkategorie,
                          items: detailItems,
                          icon: Icons.label_outline,
                          onChanged: (value) {
                            setState(() {
                              filterDetailUnterkategorie = value!;
                              filterMarke = "Alle";
                              filterModell = "Alle";
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _preisFeld(preisVonController, "Preis von"),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _preisFeld(preisBisController, "Preis bis"),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _suchDropdown(
                        label: "Unterkategorie",
                        value: filterUnterkategorie,
                        items: unterkategorieItems,
                        icon: Icons.account_tree_outlined,
                        onChanged: (value) {
                          setState(() {
                            filterUnterkategorie = value!;
                            filterDetailUnterkategorie = "Alle";
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      _suchDropdown(
                        label: "Detail",
                        value: filterDetailUnterkategorie,
                        items: detailItems,
                        icon: Icons.label_outline,
                        onChanged: (value) {
                          setState(() {
                            filterDetailUnterkategorie = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      _preisFeld(preisVonController, "Preis von"),
                      const SizedBox(height: 10),
                      _preisFeld(preisBisController, "Preis bis"),
                    ],
                  ),
            const SizedBox(height: 10),
            breit
                ? Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _suchDropdown(
                          label: "Sortieren",
                          value: sortierung,
                          items: sortierungen,
                          icon: Icons.swap_vert,
                          onChanged: (value) {
                            setState(() {
                              sortierung = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      _filterZuruecksetzenButton(),
                    ],
                  )
                : Column(
                    children: [
                      _suchDropdown(
                        label: "Sortieren",
                        value: sortierung,
                        items: sortierungen,
                        icon: Icons.swap_vert,
                        onChanged: (value) {
                          setState(() {
                            sortierung = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _filterZuruecksetzenButton(),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _suchTextFeld({
    required String label,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: sucheController,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xff5b2cff)),
        filled: true,
        fillColor: const Color(0xfff7f7fb),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _ortFeld() {
    return _ortSuchFeld(kompakt: false);
  }

  Widget _ortSuchFeld({required bool kompakt}) {
    return TextField(
      controller: ortController,
      onChanged: (_) {
        setState(() {});
      },
      onSubmitted: (_) {
        setState(() {});
      },
      decoration: InputDecoration(
        labelText: kompakt ? null : "Ort",
        hintText: kompakt ? "Ort oder PLZ suchen" : "Ort oder PLZ suchen",
        prefixIcon: const Icon(
          Icons.location_on_outlined,
          color: Color(0xff5b2cff),
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ortController.text.trim().isNotEmpty)
              IconButton(
                tooltip: "Ort löschen",
                icon: const Icon(
                  Icons.close,
                  color: Color(0xff74788d),
                  size: 19,
                ),
                onPressed: () {
                  setState(() {
                    ortController.clear();
                    umkreisFilter = "Österreichweit";
                  });
                },
              ),
            IconButton(
              tooltip: "Ort suchen",
              icon: const Icon(
                Icons.search,
                color: Color(0xff5b2cff),
              ),
              onPressed: _ortAuswahlOeffnen,
            ),
          ],
        ),
        filled: true,
        fillColor: const Color(0xfff7f7fb),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kompakt ? 17 : 16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  List<String> _ortVorschlaege(String sucheText) {
    final text = sucheText.trim().toLowerCase();

    final alleOrte = ortKoordinaten.keys
        .where((ort) => !ort.contains("oe") && !ort.contains("ae") && !ort.contains("ue"))
        .map((ort) {
          if (ort == "st. pölten") return "St. Pölten";
          if (ort == "st. johann im pongau") return "St. Johann im Pongau";
          return ort
              .split(" ")
              .map((teil) => teil.isEmpty
                  ? teil
                  : "${teil[0].toUpperCase()}${teil.substring(1)}")
              .join(" ");
        })
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    if (text.isEmpty) return alleOrte.take(80).toList();

    return alleOrte
        .where((ort) => ort.toLowerCase().contains(text))
        .take(80)
        .toList();
  }

  Future<void> _ortAuswahlOeffnen() async {
    final controller = TextEditingController(text: ortController.text.trim());

    final auswahl = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            final vorschlaege = _ortVorschlaege(controller.text);

            return DraggableScrollableSheet(
              initialChildSize: 0.74,
              minChildSize: 0.42,
              maxChildSize: 0.94,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xffd8d8e8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                        child: TextField(
                          controller: controller,
                          autofocus: true,
                          onChanged: (_) => modalSetState(() {}),
                          decoration: InputDecoration(
                            labelText: "Ort suchen",
                            hintText: "z.B. Vöcklabruck, Wien, Graz...",
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xff5b2cff),
                            ),
                            filled: true,
                            fillColor: const Color(0xfff7f7fb),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(17),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.pop(context, ""),
                                icon: const Icon(Icons.public),
                                label: const Text("Österreichweit"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xff5b2cff),
                                  side: const BorderSide(
                                    color: Color(0xff5b2cff),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final eigenerOrt = controller.text.trim();
                                  if (eigenerOrt.isNotEmpty) {
                                    Navigator.pop(context, eigenerOrt);
                                  }
                                },
                                icon: const Icon(Icons.check),
                                label: const Text("Übernehmen"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff5b2cff),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: vorschlaege.isEmpty
                            ? const Center(
                                child: Text(
                                  "Kein Ort gefunden. Du kannst den Ort trotzdem übernehmen.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xff74788d),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: vorschlaege.length,
                                itemBuilder: (context, index) {
                                  final ort = vorschlaege[index];
                                  final aktiv = ort.toLowerCase() ==
                                      ortController.text.trim().toLowerCase();

                                  return ListTile(
                                    leading: Icon(
                                      aktiv
                                          ? Icons.check_circle
                                          : Icons.location_on_outlined,
                                      color: aktiv
                                          ? const Color(0xff5b2cff)
                                          : const Color(0xff74788d),
                                    ),
                                    title: Text(
                                      ort,
                                      style: TextStyle(
                                        color: const Color(0xff050b2c),
                                        fontWeight:
                                            aktiv ? FontWeight.w900 : FontWeight.w700,
                                      ),
                                    ),
                                    subtitle: const Text(
                                      "Österreich",
                                      style: TextStyle(
                                        color: Color(0xff74788d),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    onTap: () => Navigator.pop(context, ort),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );

    if (auswahl == null) return;

    setState(() {
      ortController.text = auswahl;
      if (auswahl.trim().isEmpty) {
        umkreisFilter = "Österreichweit";
      } else if (umkreisFilter == "Österreichweit") {
        umkreisFilter = "25 km";
      }
    });
  }

  Widget _preisFeld(TextEditingController controller, String label) {
    final labelKlein = label.toLowerCase();

    IconData icon;

    if (labelKlein.contains("preis")) {
      icon = Icons.euro;
    } else if (labelKlein.contains("km") || labelKlein.contains("kilometer")) {
      icon = Icons.speed_outlined;
    } else if (labelKlein.contains("baujahr")) {
      icon = Icons.calendar_month_outlined;
    } else if (labelKlein.contains("ps")) {
      icon = Icons.bolt_outlined;
    } else if (labelKlein.contains("m²") || labelKlein.contains("fläche")) {
      icon = Icons.square_foot_outlined;
    } else if (labelKlein.contains("zimmer")) {
      icon = Icons.meeting_room_outlined;
    } else if (labelKlein.contains("länge")) {
      icon = Icons.straighten_outlined;
    } else if (labelKlein.contains("betriebsstunden")) {
      icon = Icons.timer_outlined;
    } else {
      icon = Icons.numbers_outlined;
    }

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: (_) {
        setState(() {});
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: const Color(0xff5b2cff),
        ),
        filled: true,
        fillColor: const Color(0xfff7f7fb),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  bool _istAutoFilterAktiv() {
    final text = "${ausgewaehlteKategorie} ${filterUnterkategorie} ${filterDetailUnterkategorie}".toLowerCase();
    return text.contains("auto") || text.contains("motor") || text.contains("lkw") || text.contains("transporter") || text.contains("motorrad");
  }

  bool _istImmobilienFilterAktiv() {
    return ausgewaehlteKategorie.toLowerCase().contains("immobilien");
  }

  bool _istBooteFilterAktiv() {
    return ausgewaehlteKategorie.toLowerCase().contains("boot");
  }

  bool _istBaumaschinenFilterAktiv() {
    return ausgewaehlteKategorie.toLowerCase().contains("baumaschine");
  }

  bool _istJobsFilterAktiv() {
    return ausgewaehlteKategorie.toLowerCase().contains("job");
  }

  bool _istLandwirtschaftFilterAktiv() {
    return ausgewaehlteKategorie.toLowerCase().contains("landwirtschaft");
  }

  bool _istBaumarktFilterAktiv() {
    return ausgewaehlteKategorie.toLowerCase().contains("baumarkt");
  }

  bool _istMarktplatzFilterAktiv() {
    final text = "${ausgewaehlteKategorie} ${filterUnterkategorie} ${filterDetailUnterkategorie}".toLowerCase();
    return text.contains("marktplatz") ||
        text.contains("elektronik") ||
        text.contains("freizeit") ||
        text.contains("hobby");
  }

  bool _istTierbedarfFilterAktiv() {
    return ausgewaehlteKategorie.toLowerCase().contains("tierbedarf");
  }

  bool _hatFilterFeld(FilterFeldTyp feld) {
    if (ausgewaehlteKategorie == "Alle") return true;
    return hatFilterFeld(ausgewaehlteKategorie, feld);
  }

  bool _istFirmenKategorieAktiv() {
    return istFirmenKategorie(ausgewaehlteKategorie);
  }

  bool _zeigtMarkenFilter() {
    if (ausgewaehlteKategorie == "Alle") return false;
    return _hatFilterFeld(FilterFeldTyp.marke);
  }

  bool _zeigtModellFilter() {
    if (ausgewaehlteKategorie == "Alle") return false;
    return _hatFilterFeld(FilterFeldTyp.modell);
  }

  String _markenFilterLabel() {
    if (_istBaumaschinenFilterAktiv() ||
        _istLandwirtschaftFilterAktiv() ||
        _istBaumarktFilterAktiv()) {
      return "Hersteller suchen";
    }

    if (_istBooteFilterAktiv()) return "Bootsmarke suchen";
    return "Marke suchen";
  }

  String _modellFilterLabel() {
    if (_istBaumaschinenFilterAktiv() || _istLandwirtschaftFilterAktiv()) {
      return "Maschinenmodell suchen";
    }

    if (_istBooteFilterAktiv()) return "Bootsmodell suchen";
    return "Modell suchen";
  }

  Widget _kategorieDetailFilter(void Function(VoidCallback fn) neuSetzen) {
    if (_istAutoFilterAktiv()) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _preisFeld(baujahrVonController, "Baujahr von")),
              const SizedBox(width: 10),
              Expanded(child: _preisFeld(baujahrBisController, "Baujahr bis")),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _preisFeld(kilometerVonController, "KM von")),
              const SizedBox(width: 10),
              Expanded(child: _preisFeld(kilometerBisController, "KM bis")),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _preisFeld(psVonController, "PS von")),
              const SizedBox(width: 10),
              Expanded(child: _preisFeld(psBisController, "PS bis")),
            ],
          ),
          const SizedBox(height: 10),
          _suchDropdown(
            label: "Kraftstoff",
            value: filterKraftstoff,
            items: kraftstoffOptionen,
            icon: Icons.local_gas_station_outlined,
            onChanged: (value) {
              if (value == null) return;
              neuSetzen(() => filterKraftstoff = value);
            },
          ),
          const SizedBox(height: 10),
          _suchDropdown(
            label: "Getriebe",
            value: filterGetriebe,
            items: getriebeOptionen,
            icon: Icons.settings_outlined,
            onChanged: (value) {
              if (value == null) return;
              neuSetzen(() => filterGetriebe = value);
            },
          ),
        ],
      );
    }

    if (_istImmobilienFilterAktiv()) {
      return Column(
        children: [
          _suchbareAuswahl(
            label: "Immobilienart suchen",
            value: filterImmobilienArt,
            items: immobilienArtOptionen,
            icon: Icons.home_work_outlined,
            onSelected: (value) => neuSetzen(() => filterImmobilienArt = value),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _preisFeld(wohnflaecheVonController, "m² von")),
              const SizedBox(width: 10),
              Expanded(child: _preisFeld(wohnflaecheBisController, "m² bis")),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _preisFeld(zimmerVonController, "Zimmer von")),
              const SizedBox(width: 10),
              Expanded(child: _preisFeld(zimmerBisController, "Zimmer bis")),
            ],
          ),
          const SizedBox(height: 10),
          _suchDropdown(
            label: "Balkon",
            value: filterBalkon,
            items: jaNeinOptionen,
            icon: Icons.balcony_outlined,
            onChanged: (value) {
              if (value == null) return;
              neuSetzen(() => filterBalkon = value);
            },
          ),
          const SizedBox(height: 10),
          _suchDropdown(
            label: "Garage",
            value: filterGarage,
            items: jaNeinOptionen,
            icon: Icons.garage_outlined,
            onChanged: (value) {
              if (value == null) return;
              neuSetzen(() => filterGarage = value);
            },
          ),
        ],
      );
    }

    if (_istBooteFilterAktiv()) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _preisFeld(baujahrVonController, "Baujahr von")),
              const SizedBox(width: 10),
              Expanded(child: _preisFeld(baujahrBisController, "Baujahr bis")),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _preisFeld(bootLaengeVonController, "Länge von")),
              const SizedBox(width: 10),
              Expanded(child: _preisFeld(bootLaengeBisController, "Länge bis")),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _preisFeld(psVonController, "PS von")),
              const SizedBox(width: 10),
              Expanded(child: _preisFeld(psBisController, "PS bis")),
            ],
          ),
        ],
      );
    }

    if (_istBaumaschinenFilterAktiv()) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _preisFeld(baujahrVonController, "Baujahr von")),
              const SizedBox(width: 10),
              Expanded(child: _preisFeld(baujahrBisController, "Baujahr bis")),
            ],
          ),
          const SizedBox(height: 10),
          _preisFeld(betriebsstundenBisController, "Betriebsstunden bis"),
        ],
      );
    }

    if (_istJobsFilterAktiv()) {
      return TextField(
        controller: berufsbezeichnungController,
        onChanged: (_) => neuSetzen(() {}),
        decoration: InputDecoration(
          labelText: "Berufsbezeichnung / Branche",
          prefixIcon: const Icon(Icons.work_outline, color: Color(0xff5b2cff)),
          suffixIcon: berufsbezeichnungController.text.trim().isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => neuSetzen(() => berufsbezeichnungController.clear()),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      );
    }

    return const SizedBox();
  }

  Widget _suchbareAuswahl({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required Function(String) onSelected,
  }) {
    final sichereItems = items.isEmpty ? ["Alle"] : items.toSet().toList();
    final anzeige = sichereItems.contains(value) ? value : "Alle";

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final auswahl = await _auswahlSucheOeffnen(
          titel: label,
          items: sichereItems,
          aktuellerWert: anzeige,
        );
        if (auswahl != null) onSelected(auswahl);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xff5b2cff)),
          suffixIcon: const Icon(Icons.search, color: Color(0xff5b2cff)),
          filled: true,
          fillColor: const Color(0xfff7f7fb),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        child: Text(
          suchfilterAnzeigeText(anzeige),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xff050b2c),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Future<String?> _auswahlSucheOeffnen({
    required String titel,
    required List<String> items,
    required String aktuellerWert,
  }) {
    final controller = TextEditingController();

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            final text = controller.text.trim().toLowerCase();
            final gefiltert = items.where((item) {
              if (text.isEmpty) return true;
              return item.toLowerCase().contains(text);
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.45,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xffd8d8e8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                        child: TextField(
                          controller: controller,
                          autofocus: true,
                          onChanged: (_) => modalSetState(() {}),
                          decoration: InputDecoration(
                            hintText: "Suchen, z.B. B...",
                            labelText: titel,
                            prefixIcon: const Icon(Icons.search, color: Color(0xff5b2cff)),
                            filled: true,
                            fillColor: const Color(0xfff7f7fb),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(17),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: gefiltert.length,
                          itemBuilder: (context, index) {
                            final item = gefiltert[index];
                            final aktiv = item == aktuellerWert;
                            return ListTile(
                              leading: Icon(
                                aktiv ? Icons.check_circle : Icons.circle_outlined,
                                color: aktiv ? const Color(0xff5b2cff) : const Color(0xff74788d),
                              ),
                              title: Text(
                                suchfilterAnzeigeText(item),
                                style: TextStyle(
                                  fontWeight: aktiv ? FontWeight.w900 : FontWeight.w700,
                                  color: const Color(0xff050b2c),
                                ),
                              ),
                              onTap: () => Navigator.pop(context, item),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _suchDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    final sichereItems = items.isEmpty ? ["Alle"] : items.toSet().toList();
    final sichererWert =
        sichereItems.contains(value) ? value : sichereItems.first;

    return DropdownButtonFormField<String>(
      value: sichererWert,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xff5b2cff)),
        filled: true,
        fillColor: const Color(0xfff7f7fb),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: sichereItems
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                suchfilterAnzeigeText(item),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _filterZuruecksetzenButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: filterZuruecksetzen,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xfff1edff),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restart_alt,
              color: Color(0xff5b2cff),
              size: 20,
            ),
            SizedBox(width: 7),
            Text(
              "Zurücksetzen",
              style: TextStyle(
                color: Color(0xff5b2cff),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _heroBannerKlein(bool breit) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        breit ? 46 : 16,
        14,
        breit ? 46 : 16,
        0,
      ),
      child: Container(
        height: breit ? 112 : 124,
        padding: EdgeInsets.symmetric(
          horizontal: breit ? 24 : 18,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xff050b2c),
              Color(0xff11184f),
              Color(0xff5b2cff),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x245b2cff),
              blurRadius: 22,
              offset: Offset(0, 9),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Opacity(
                opacity: 0.12,
                child: Image.asset(
                  'assets/logo/image_neu2.png',
                  width: breit ? 130 : 110,
                  height: breit ? 130 : 110,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(breit ? 12 : 11),
                  child: Image.asset(
                    'assets/logo/image_neu2.png',
                    width: breit ? 62 : 54,
                    height: breit ? 62 : 54,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Entdecke echte Top-Deals",
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: breit ? 24 : 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            height: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        "Handeln, mieten und inserieren – schnell, lokal und übersichtlich.",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: breit ? 14 : 12,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                if (breit) ...[
                  const SizedBox(width: 14),
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: widget.zuInserat,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: Color(0xff5b2cff),
                            size: 19,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Jetzt inserieren",
                            style: TextStyle(
                              color: Color(0xff5b2cff),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 10),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: widget.zuInserat,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xff5b2cff),
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
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
        padding: EdgeInsets.all(breit ? 24 : 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xff050b2c),
              Color(0xff11184f),
              Color(0xff5b2cff),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x225b2cff),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: breit
            ? Row(
                children: [
                  Expanded(child: _heroText(breit)),
                  const SizedBox(width: 22),
                  _heroButton(),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _heroText(breit),
                  const SizedBox(height: 18),
                  _heroButton(),
                ],
              ),
      ),
    );
  }

  Widget _heroText(bool breit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.13),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            "Handelswelt Deals",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          "Österreichs Marktplatz\nfür echte Top-Deals.",
          style: TextStyle(
            color: Colors.white,
            fontSize: breit ? 26 : 22,
            fontWeight: FontWeight.w900,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Autos, Immobilien, Jobs, Dienstleistungen, Boote, Baumaschinen und vieles mehr.",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),

      ],
    );
  }

  Widget _heroButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: widget.zuInserat,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_outline, color: Color(0xff5b2cff)),
            SizedBox(width: 8),
            Text(
              "Jetzt inserieren",
              style: TextStyle(
                color: Color(0xff5b2cff),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vertrauensLeiste(bool breit) {
    final vorteile = [
      {
        "icon": Icons.verified_user_outlined,
        "titel": "Sicher handeln",
        "text": "Klare Inserate & direkte Kontaktaufnahme",
      },
      {
        "icon": Icons.euro_outlined,
        "titel": "Kostenlos starten",
        "text": "Inserate einfach veröffentlichen",
      },
      {
        "icon": Icons.rocket_launch_outlined,
        "titel": "Schnell verkaufen",
        "text": "Dein Deal ist sofort sichtbar",
      },
      {
        "icon": Icons.phone_iphone_outlined,
        "titel": "Mobile optimiert",
        "text": "Perfekt für Handy, Tablet und Web",
      },
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        breit ? 46 : 16,
        18,
        breit ? 46 : 16,
        0,
      ),
      child: GridView.builder(
        itemCount: vorteile.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: breit ? 4 : 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: breit ? 3.05 : 1.55,
        ),
        itemBuilder: (context, index) {
          final item = vorteile[index];

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xffececf4)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0f000000),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xfff1edff),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    item["icon"] as IconData,
                    color: const Color(0xff5b2cff),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["titel"] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xff050b2c),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item["text"] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xff74788d),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1.22,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _beliebteKategorien(bool breit) {
    final hauptKategorien = [
      {
        "titel": "Marktplatz",
        "kategorie": "Marktplatz",
        "icon": Icons.storefront_outlined,
        "bild": "https://images.unsplash.com/photo-1523275335684-37898b6baf30",
        "anzahl": "Elektronik, Mode & mehr",
      },
      {
        "titel": "Auto & Motor",
        "kategorie": "Auto & Motor",
        "icon": Icons.directions_car,
        "bild": "https://images.unsplash.com/photo-1494976388531-d1058494cdd8",
        "anzahl": "Kaufen, Mieten & Zubehör",
      },
      {
        "titel": "Immobilien",
        "kategorie": "Immobilien",
        "icon": Icons.home,
        "bild": "https://images.unsplash.com/photo-1564013799919-ab600027ffc6",
        "anzahl": "Wohnungen & Häuser",
      },
      {
        "titel": "Jobs",
        "kategorie": "Jobs",
        "icon": Icons.work_outline,
        "bild": "https://images.unsplash.com/photo-1521791136064-7986c2920216",
        "anzahl": "Jobs finden & bewerben",
      },
      {
        "titel": "Dienstleistungen",
        "kategorie": "Dienstleistungen",
        "icon": Icons.handyman_outlined,
        "bild": "https://images.unsplash.com/photo-1504384308090-c894fdcc538d",
        "anzahl": "Dienstleistungen finden",
      },
      {
        "titel": "Baumaschinen",
        "kategorie": "Baumaschinen",
        "icon": Icons.precision_manufacturing_outlined,
        "bild": "https://images.unsplash.com/photo-1503387762-592deb58ef4e",
        "anzahl": "Bagger, Kräne & Geräte",
      },
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        breit ? 46 : 16,
        26,
        breit ? 46 : 16,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Beliebte Kategorien",
                  style: TextStyle(
                    color: Color(0xff050b2c),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: filterZuruecksetzen,
                child: const Text(
                  "Alle anzeigen",
                  style: TextStyle(
                    color: Color(0xff5b2cff),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            itemCount: hauptKategorien.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: breit ? 6 : 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: breit ? 1.02 : 0.92,
            ),
            itemBuilder: (context, index) {
              final item = hauptKategorien[index];

              return InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  setState(() {
                    final neueKategorie = item["kategorie"] as String;
                    ausgewaehlteKategorie = neueKategorie;
                    filterUnterkategorie = "Alle";
                    filterDetailUnterkategorie = "Alle";
                    filterMarke = "Alle";
                    filterModell = "Alle";
                    filterAnbieter = istFirmenKategorie(neueKategorie) ? "Firma" : "Alle";
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xffececf4)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                              child: Image.network(
                                item["bild"] as String,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: const Color(0xfff1edff),
                                    child: Center(
                                      child: Icon(
                                        item["icon"] as IconData,
                                        color: const Color(0xff5b2cff),
                                        size: 44,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.08),
                                    Colors.black.withOpacity(0.35),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 18,
                              bottom: -27,
                              child: Container(
                                height: 54,
                                width: 54,
                                decoration: BoxDecoration(
                                  color: const Color(0xff5b2cff),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x335b2cff),
                                      blurRadius: 14,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  item["icon"] as IconData,
                                  color: Colors.white,
                                  size: 27,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 34, 18, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["titel"] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xff050b2c),
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item["anzahl"] as String,
                              style: const TextStyle(
                                color: Color(0xff74788d),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _topBewerteteFirmen(bool breit) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("bewertungen").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }

        final Map<String, _FirmenBewertungInfo> firmen = {};

        for (final doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final firmaId = (data["firmaId"] ?? "").toString().trim();
          if (firmaId.isEmpty) continue;

          final firmaName = (data["firmaName"] ?? "Firma").toString().trim();
          final wert = data["sterne"];
          double sterne = 0;

          if (wert is int) {
            sterne = wert.toDouble();
          } else if (wert is double) {
            sterne = wert;
          } else {
            sterne = double.tryParse(wert.toString()) ?? 0;
          }

          if (sterne <= 0) continue;

          final info = firmen.putIfAbsent(
            firmaId,
            () => _FirmenBewertungInfo(
              firmaId: firmaId,
              firmaName: firmaName.isEmpty ? "Firma" : firmaName,
            ),
          );

          info.summe += sterne;
          info.anzahl += 1;
        }

        final topFirmen = firmen.values
            .where((firma) => firma.anzahl > 0)
            .toList()
          ..sort((a, b) {
            final bewertungVergleich = b.durchschnitt.compareTo(a.durchschnitt);
            if (bewertungVergleich != 0) return bewertungVergleich;
            return b.anzahl.compareTo(a.anzahl);
          });

        final sichtbareFirmen = topFirmen.take(10).toList();

        if (sichtbareFirmen.isEmpty) return const SizedBox();

        return Padding(
          padding: EdgeInsets.fromLTRB(
            breit ? 46 : 16,
            26,
            breit ? 46 : 16,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Top bewertete Firmen",
                      style: TextStyle(
                        color: Color(0xff050b2c),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xffffefe0),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 16),
                        SizedBox(width: 5),
                        Text(
                          "Vertrauen",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: breit ? 158 : 148,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: sichtbareFirmen.length,
                  itemBuilder: (context, index) {
                    final firma = sichtbareFirmen[index];
                    return _topFirmaKarte(firma, breit);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _topFirmaKarte(_FirmenBewertungInfo firma, bool breit) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FirmenProfilSeite(
              userId: firma.firmaId,
              firmenname: firma.firmaName,
            ),
          ),
        );
      },
      child: Container(
        width: breit ? 260 : 225,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xffececf4)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0f000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xfff1edff),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Color(0xff5b2cff),
                    size: 29,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firma.firmaName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xff050b2c),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Verifizierte Handelswelt-Firma",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xff74788d),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 20),
                const SizedBox(width: 5),
                Text(
                  firma.durchschnitt.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Color(0xff050b2c),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "${firma.anzahl} Bewertung${firma.anzahl == 1 ? "" : "en"}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xff74788d),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xffffefe0),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: Colors.orange, size: 15),
                  SizedBox(width: 5),
                  Text(
                    "Top bewertet",
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _startInseratBereiche(List<Produkt> produkte, bool breit) {
    final neueste = produkte.take(12).toList();

    final beliebte = [...produkte]
      ..sort((a, b) {
        final bWert = (b.favorit ? 3 : 0) + (b.firmaVerifiziert ? 2 : 0);
        final aWert = (a.favorit ? 3 : 0) + (a.firmaVerifiziert ? 2 : 0);
        final vergleich = bWert.compareTo(aWert);
        if (vergleich != 0) return vergleich;
        return zahl(b.preis).compareTo(zahl(a.preis));
      });

    final inDerNaehe = [...produkte]
      ..sort((a, b) {
        final entfernungA = _entfernungZumSuchOrt(a);
        final entfernungB = _entfernungZumSuchOrt(b);
        return entfernungA.compareTo(entfernungB);
      });

    return Padding(
      padding: EdgeInsets.fromLTRB(
        breit ? 46 : 16,
        26,
        0,
        10,
      ),
      child: Column(
        children: [
          _horizontaleInseratLeiste(
            titel: "Neueste Inserate",
            untertitel: "${produkte.length} Deals gefunden",
            icon: Icons.fiber_new_rounded,
            produkte: neueste,
            breit: breit,
          ),
          const SizedBox(height: 26),
          _horizontaleInseratLeiste(
            titel: "Beliebte Inserate",
            untertitel: "Top Deals & Favoriten",
            icon: Icons.local_fire_department_rounded,
            produkte: beliebte.take(12).toList(),
            breit: breit,
          ),
          const SizedBox(height: 26),
          _horizontaleInseratLeiste(
            titel: "In deiner Nähe",
            untertitel: _naeheUntertitel(),
            icon: Icons.near_me_rounded,
            produkte: inDerNaehe.take(12).toList(),
            breit: breit,
          ),
        ],
      ),
    );
  }

  String _naeheUntertitel() {
    final ort = ortController.text.trim();
    if (ort.isEmpty) {
      return "Standort: Österreichweit";
    }

    final radius = umkreisFilter == "Österreichweit" ? "" : " • $umkreisFilter";
    return "$ort$radius";
  }

  double _entfernungZumSuchOrt(Produkt produkt) {
    final ortText = ortController.text.trim();
    final suchKoordinaten = koordinatenFuerOrt(ortText.isEmpty ? "wien" : ortText);

    if (suchKoordinaten == null) return 99999;
    if (produkt.latitude == 0 && produkt.longitude == 0) return 99999;

    return entfernungKm(
      suchKoordinaten[0],
      suchKoordinaten[1],
      produkt.latitude,
      produkt.longitude,
    );
  }

  Widget _horizontaleInseratLeiste({
    required String titel,
    required String untertitel,
    required IconData icon,
    required List<Produkt> produkte,
    required bool breit,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(right: breit ? 46 : 16),
          child: Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: const Color(0xfff1edff),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xff5b2cff),
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titel,
                      style: const TextStyle(
                        color: Color(0xff050b2c),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      untertitel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff74788d),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.swipe_rounded,
                color: Color(0xff5b2cff),
                size: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (produkte.isEmpty)
          Padding(
            padding: EdgeInsets.only(right: breit ? 46 : 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xffececf4)),
              ),
              child: const Text(
                "Keine Inserate gefunden.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xff74788d),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: breit ? 405 : 355,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(right: breit ? 46 : 16),
              itemCount: produkte.length,
              itemBuilder: (context, index) {
                return _dealSwipeKarte(produkte[index], breit);
              },
            ),
          ),
      ],
    );
  }

  Widget _dealSwipeKarte(Produkt produkt, bool breit) {
    final preisText =
        produkt.preis.endsWith("€") ? produkt.preis : "${produkt.preis} €";

    final info1 = _infoZeile1(produkt);
    final info2 = _infoZeile2(produkt);
    final entfernung = _entfernungZumSuchOrt(produkt);
    final entfernungText =
        entfernung < 9999 ? " • ${entfernung.toStringAsFixed(0)} km" : "";

    final chips = <String>[
      if (produkt.detailUnterkategorie.trim().isNotEmpty)
        produkt.detailUnterkategorie,
      if (produkt.kategorie == "Auto & Motor" && produkt.baujahr.trim().isNotEmpty)
        produkt.baujahr,
      if (produkt.kategorie == "Auto & Motor" && produkt.kilometer.trim().isNotEmpty)
        mitEinheit(produkt.kilometer, "km"),
      if (produkt.kategorie == "Auto & Motor" && produkt.kraftstoff.trim().isNotEmpty)
        produkt.kraftstoff,
      if (produkt.kategorie == "Auto & Motor" && produkt.leistung.trim().isNotEmpty)
        mitEinheit(produkt.leistung, "PS"),
      if (produkt.kategorie == "Immobilien" && produkt.wohnflaeche.trim().isNotEmpty)
        mitEinheit(produkt.wohnflaeche, "m²"),
      if (produkt.kategorie == "Immobilien" && produkt.zimmer.trim().isNotEmpty)
        "${produkt.zimmer} Zi.",
      if (produkt.kategorie == "Boote" && produkt.bootLaenge.trim().isNotEmpty)
        mitEinheit(produkt.bootLaenge, "m"),
      if (produkt.kategorie == "Baumaschinen" &&
          produkt.baumaschinenBetriebsstunden.trim().isNotEmpty)
        mitEinheit(produkt.baumaschinenBetriebsstunden, "h"),
    ].where((e) => e.trim().isNotEmpty).take(4).toList();

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailSeite(produkt: produkt),
          ),
        );
      },
      child: Container(
        width: breit ? 268 : 218,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xffececf4)),
          boxShadow: const [
            BoxShadow(
              blurRadius: 16,
              color: Color(0x12000000),
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: breit ? 172 : 142,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: produkt.bild.isEmpty
                          ? _platzhalterBild(produkt, breit)
                          : Image.network(
                              produkt.bild,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _platzhalterBild(produkt, breit);
                              },
                            ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(22),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.08),
                          Colors.transparent,
                          Colors.black.withOpacity(0.46),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _bildBadge(
                      produkt.firmaVerifiziert ? "VERIFIZIERT" : "NEU",
                      produkt.firmaVerifiziert ? Colors.orange : Colors.red,
                    ),
                  ),
                  Positioned(
                    top: 9,
                    right: 9,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        widget.favoritWechseln(produkt);
                      },
                      child: CircleAvatar(
                        radius: 17,
                        backgroundColor: Colors.white,
                        child: Icon(
                          produkt.favorit
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: produkt.favorit
                              ? Colors.red
                              : const Color(0xff74788d),
                          size: 19,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produkt.titel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xff050b2c),
                      fontSize: breit ? 16 : 14,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    preisText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xff5b2cff),
                      fontSize: breit ? 18 : 16,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  if (info1.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      info1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff050b2c),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                  ],
                  if (info2.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      info2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff74788d),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: Color(0xff74788d),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          "${produkt.ort.isEmpty ? "Österreich" : produkt.ort}$entfernungText",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xff74788d),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _miniChip(
                        produkt.typ == "Firma" ? "Firma" : "Privat",
                        const Color(0xffe8f8ee),
                        Colors.green,
                      ),
                      const SizedBox(width: 5),
                      _miniChip(
                        _anzeigenId(produkt),
                        const Color(0xfff4f4f8),
                        const Color(0xff74788d),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dealKarte(Produkt produkt, bool breit) {
    final preisText =
        produkt.preis.endsWith("€") ? produkt.preis : "${produkt.preis} €";

    final bildBreite = breit ? 230.0 : 135.0;
    final bildHoehe = breit ? 168.0 : 135.0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailSeite(produkt: produkt),
          ),
        );
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xffececf4)),
          boxShadow: const [
            BoxShadow(
              blurRadius: 16,
              color: Color(0x12000000),
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: bildBreite,
              height: bildHoehe,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    produkt.bild.isEmpty
                        ? _platzhalterBild(produkt, breit)
                        : Image.network(
                            produkt.bild,
                            width: bildBreite,
                            height: bildHoehe,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _platzhalterBild(produkt, breit);
                            },
                          ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.20),
                            Colors.transparent,
                            Colors.black.withOpacity(0.18),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _bildBadge(
                        produkt.firmaVerifiziert ? "VERIFIZIERT" : "NEU",
                        produkt.firmaVerifiziert ? Colors.orange : Colors.red,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _bildBadge(
                        produkt.detailUnterkategorie.isNotEmpty
                            ? produkt.detailUnterkategorie
                            : produkt.kategorie,
                        Colors.black.withOpacity(0.72),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _kartenText(produkt, preisText, breit),
            ),
            if (breit) ...[
              if (produkt.unterkategorie.isNotEmpty) ...[
                _miniChip(
                  produkt.unterkategorie,
                  const Color(0xffeaf7ff),
                  Colors.blue,
                ),
                const SizedBox(width: 12),
              ],
              if (produkt.detailUnterkategorie.isNotEmpty) ...[
                _miniChip(
                  produkt.detailUnterkategorie,
                  const Color(0xffeef8ee),
                  Colors.green,
                ),
                const SizedBox(width: 12),
              ],
              _verkaeuferBadge(produkt),
              const SizedBox(width: 18),
            ],
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor:
                    produkt.favorit ? const Color(0xffffedf1) : Colors.white,
                side: const BorderSide(color: Color(0xffececf4)),
              ),
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

  Widget _bildBadge(String text, Color farbe) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: farbe,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 11,
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
            fontSize: breit ? 20 : 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          preisText,
          style: TextStyle(
            color: const Color(0xff5b2cff),
            fontSize: breit ? 22 : 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (zeile1.isNotEmpty) ...[
          const SizedBox(height: 7),
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
        const SizedBox(height: 7),
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
        const SizedBox(height: 5),
        Wrap(
          spacing: 7,
          runSpacing: 5,
          children: [
            if (!breit) _verkaeuferBadge(produkt),
            _miniChip(
              _anzeigenId(produkt),
              const Color(0xfff4f4f8),
              const Color(0xff74788d),
            ),
          ],
        ),
      ],
    );
  }

  String _infoZeile1(Produkt produkt) {
    if (produkt.kategorie == "Auto & Motor") {
      final teile = [
        produkt.detailUnterkategorie,
        produkt.marke,
        produkt.modell,
      ].where((e) => e.trim().isNotEmpty).toList();

      return teile.join(" • ");
    }

    if (produkt.kategorie == "Immobilien") {
      return produkt.detailUnterkategorie.isNotEmpty
          ? produkt.detailUnterkategorie
          : (produkt.immobilienArt.isEmpty ? "Immobilie" : produkt.immobilienArt);
    }

    if (produkt.kategorie == "Boote") {
      final teile = [
        produkt.detailUnterkategorie,
        produkt.bootMarke,
        produkt.bootModell,
      ].where((e) => e.trim().isNotEmpty).toList();

      return teile.join(" • ");
    }

    if (produkt.kategorie == "Baumaschinen" ||
        produkt.kategorie == "Baumarkt" ||
        produkt.kategorie == "Landwirtschaft" ||
        produkt.kategorie == "Anhänger" ||
        produkt.kategorie == "Tierbedarf" ||
        produkt.kategorie == "Freizeit & Hobby" ||
        produkt.kategorie == "Marktplatz" ||
        produkt.kategorie == "Dienstleistungen" ||
        produkt.kategorie == "Jobs") {
      final teile = [
        produkt.unterkategorie,
        produkt.detailUnterkategorie,
      ].where((e) => e.trim().isNotEmpty).toList();

      return teile.join(" • ");
    }

    return produkt.zustand;
  }

  String _infoZeile2(Produkt produkt) {
    if (produkt.kategorie == "Auto & Motor") {
      final teile = [
        produkt.baujahr,
        mitEinheit(produkt.kilometer, "km"),
        produkt.kraftstoff,
        produkt.getriebe,
        mitEinheit(produkt.leistung, "PS"),
      ].where((e) => e.trim().isNotEmpty).toList();

      return teile.join(" • ");
    }

    if (produkt.kategorie == "Immobilien") {
      final teile = [
        mitEinheit(produkt.wohnflaeche, "m²"),
        produkt.zimmer.isEmpty ? "" : "${produkt.zimmer} Zimmer",
        produkt.balkon == "Ja" ? "Balkon" : "",
        produkt.garage == "Ja" ? "Garage" : "",
      ].where((e) => e.trim().isNotEmpty).toList();

      return teile.join(" • ");
    }

    if (produkt.kategorie == "Boote") {
      final teile = [
        produkt.bootBaujahr,
        mitEinheit(produkt.bootLaenge, "m"),
        mitEinheit(produkt.bootLeistung, "PS"),
      ].where((e) => e.trim().isNotEmpty).toList();

      return teile.join(" • ");
    }

    if (produkt.kategorie == "Baumaschinen") {
      final teile = [
        produkt.baumaschinenBaujahr,
        mitEinheit(produkt.baumaschinenBetriebsstunden, "h"),
        mitEinheit(produkt.baumaschinenGewicht, "kg"),
      ].where((e) => e.trim().isNotEmpty).toList();

      return teile.join(" • ");
    }

    if (produkt.kategorie == "Baumarkt") {
      final teile = [
        produkt.baumarktMaterial,
        produkt.baumarktMenge,
      ].where((e) => e.trim().isNotEmpty).toList();

      return teile.join(" • ");
    }

    final teile = [
      produkt.zustand,
      produkt.hersteller,
      produkt.garantie,
    ].where((e) => e.trim().isNotEmpty).toList();

    return teile.join(" • ");
  }

  String _anzeigenId(Produkt produkt) {
    final nummer = produkt.titel.hashCode.abs().toString().padLeft(6, "0");
    return "HW-${nummer.substring(0, 6)}";
  }

  Widget _platzhalterBild(Produkt produkt, bool breit) {
    return Container(
      width: breit ? 220 : 140,
      height: breit ? 165 : 140,
      color: const Color(0xfff1edff),
      child: Icon(
        produkt.icon,
        color: const Color(0xff5b2cff),
        size: 44,
      ),
    );
  }

  Widget _verkaeuferBadge(Produkt produkt) {
    final istFirma = produkt.typ == "Firma";
    final text = produkt.firmaVerifiziert
        ? "✅ Verifizierte Firma"
        : (istFirma ? "⏳ Firma in Prüfung" : "👤 Privat");

    final bg = produkt.firmaVerifiziert
        ? const Color(0xffffefe0)
        : (istFirma ? const Color(0xfffff6df) : const Color(0xffe8f8ee));

    final fg = produkt.firmaVerifiziert
        ? Colors.orange
        : (istFirma ? Colors.amber : Colors.green);

    return _miniChip(text, bg, fg);
  }

  Widget _miniChip(String text, Color bg, Color fg) {
    if (text.trim().isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
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

  Widget _footerLink({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.09),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _infoDialog(String titel, String text) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            titel,
            style: const TextStyle(
              color: Color(0xff050b2c),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            text,
            style: const TextStyle(
              color: Color(0xff74788d),
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Schließen",
                style: TextStyle(
                  color: Color(0xff5b2cff),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _footer(bool breit) {
    final links = Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: breit ? WrapAlignment.end : WrapAlignment.start,
      children: [
        _footerLink(
          text: "Impressum",
          icon: Icons.info_outline,
          onTap: () => _infoDialog(
            "Impressum",
            "Hier kommen später Firmenname, Adresse, Kontakt, UID-Nummer und rechtliche Angaben von Handelswelt hinein.",
          ),
        ),
        _footerLink(
          text: "Datenschutz",
          icon: Icons.privacy_tip_outlined,
          onTap: () => _infoDialog(
            "Datenschutz",
            "Hier kommt später die Datenschutzerklärung hinein: welche Daten gespeichert werden, wofür sie genutzt werden und wie Nutzer ihre Daten löschen lassen können.",
          ),
        ),
        _footerLink(
          text: "AGB",
          icon: Icons.description_outlined,
          onTap: () => _infoDialog(
            "AGB",
            "Hier kommen später die Nutzungsbedingungen für Käufer, Verkäufer, private Nutzer und Firmen hinein.",
          ),
        ),
        _footerLink(
          text: "Kontakt",
          icon: Icons.mail_outline,
          onTap: () => _infoDialog(
            "Kontakt",
            "Du erreichst uns per E-Mail unter support@handelswelt-deals.at.",
          ),
        ),
        _footerLink(
          text: "Hilfe",
          icon: Icons.help_outline,
          onTap: () => _infoDialog(
            "Hilfe",
            "Hier kommen später häufige Fragen, Sicherheitstipps und Hilfe zum Inserieren hinein.",
          ),
        ),
      ],
    );

    final branding = Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'assets/logo/image_neu2.png',
            width: 48,
            height: 48,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Handelswelt",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Deals für Österreich",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      margin: EdgeInsets.fromLTRB(
        breit ? 46 : 16,
        8,
        breit ? 46 : 16,
        24,
      ),
      padding: EdgeInsets.all(breit ? 22 : 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff050b2c),
            Color(0xff11184f),
            Color(0xff5b2cff),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (breit)
            Row(
              children: [
                Expanded(child: branding),
                const SizedBox(width: 18),
                links,
              ],
            )
          else ...[
            branding,
            const SizedBox(height: 16),
            links,
          ],
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.12),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: Text(
                  "© Handelswelt • Alle Rechte vorbehalten",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                "Österreich",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FirmenBewertungInfo {
  final String firmaId;
  final String firmaName;
  double summe = 0;
  int anzahl = 0;

  _FirmenBewertungInfo({
    required this.firmaId,
    required this.firmaName,
  });

  double get durchschnitt => anzahl == 0 ? 0 : summe / anzahl;
}

class _HeroStatistik extends StatelessWidget {
  final String zahl;
  final String text;

  const _HeroStatistik({
    required this.zahl,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
        ),
      ),
      child: Column(
        children: [
          Text(
            zahl,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
