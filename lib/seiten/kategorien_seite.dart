// lib/seiten/kategorien_seite.dart

import 'package:flutter/material.dart';

import '../model/produkt.dart';
import '../kategorien_daten/kategorien.dart';
import '../kategorien_daten/marken_hersteller.dart';
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
  String ausgewaehlteUnterkategorie = "Alle";
  String ausgewaehltesDetail = "Alle";
  String filterMarke = "Alle";
  String filterModell = "Alle";
  String filterAnbieter = "Alle";
  String filterKraftstoff = "Alle";
  String filterGetriebe = "Alle";
  String filterImmobilienArt = "Alle";
  String filterBalkon = "Alle";
  String filterGarage = "Alle";
  String sortierung = "Neueste zuerst";
  String suche = "";
  String umkreisFilter = "Österreichweit";
  String filterAufzug = "Alle";
  String filterGarten = "Alle";
  String filterKeller = "Alle";
  String filterHomeoffice = "Alle";
  String filterBeschaeftigung = "Alle";
  String filterDienstleistungArt = "Alle";

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
  final grundstueckVonController = TextEditingController();
  final grundstueckBisController = TextEditingController();
  final zimmerVonController = TextEditingController();
  final zimmerBisController = TextEditingController();
  final gehaltVonController = TextEditingController();
  final gehaltBisController = TextEditingController();
  final bootLaengeVonController = TextEditingController();
  final bootLaengeBisController = TextEditingController();
  final betriebsstundenBisController = TextEditingController();
  final inhaltScrollController = ScrollController();

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

  final beschaeftigungOptionen = const [
    "Alle",
    "Vollzeit",
    "Teilzeit",
    "Lehre",
    "Geringfügig",
    "Freelance",
    "Praktikum",
  ];

  final dienstleistungOptionen = const [
    "Alle",
    "Handwerk",
    "Reinigung",
    "Transport",
    "Umzug",
    "Garten",
    "Bau",
    "IT",
    "Beauty",
    "Nachhilfe",
    "Notdienst",
    "Online",
    "Vor Ort",
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

  List<String> get kategorien {
    final liste = ["Alle", ...startKategorien.where((e) => e != "Alle")];
    return liste.toSet().toList();
  }

  List<String> get unterkategorien {
    if (ausgewaehlteKategorie == "Alle") return const ["Alle"];
    return ["Alle", ...unterkategorienSucheFuer(ausgewaehlteKategorie)]
        .toSet()
        .toList();
  }

  List<String> get details {
    if (ausgewaehlteKategorie == "Alle") return const ["Alle"];
    if (ausgewaehlteUnterkategorie == "Alle") return const ["Alle"];

    final detailListe = detailUnterkategorienSucheFuer(
      ausgewaehlteKategorie,
      ausgewaehlteUnterkategorie,
    );

    if (detailListe.isEmpty) return const ["Alle"];
    return ["Alle", ...detailListe].toSet().toList();
  }

  @override
  void dispose() {
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
    grundstueckVonController.dispose();
    grundstueckBisController.dispose();
    zimmerVonController.dispose();
    zimmerBisController.dispose();
    gehaltVonController.dispose();
    gehaltBisController.dispose();
    bootLaengeVonController.dispose();
    bootLaengeBisController.dispose();
    betriebsstundenBisController.dispose();
    inhaltScrollController.dispose();
    super.dispose();
  }

  String _norm(String wert) => wert.trim().toLowerCase();

  int zahl(String text) {
    return int.tryParse(
          text
              .replaceAll("€", "")
              .replaceAll(".", "")
              .replaceAll(",", "")
              .replaceAll("km", "")
              .replaceAll("m²", "")
              .replaceAll("h", "")
              .replaceAll("PS", "")
              .replaceAll("ps", "")
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

  bool _istAutoFilterAktiv() {
    final text =
        "$ausgewaehlteKategorie $ausgewaehlteUnterkategorie $ausgewaehltesDetail"
            .toLowerCase();
    return text.contains("auto") ||
        text.contains("motor") ||
        text.contains("lkw") ||
        text.contains("transporter") ||
        text.contains("motorrad");
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
    return ausgewaehlteKategorie.toLowerCase().contains("jobs");
  }

  bool _istDienstleistungenFilterAktiv() {
    return ausgewaehlteKategorie.toLowerCase().contains("dienstleistungen");
  }

  bool _istLandwirtschaftFilterAktiv() {
    return ausgewaehlteKategorie.toLowerCase().contains("landwirtschaft");
  }

  bool _istBaumarktFilterAktiv() {
    return ausgewaehlteKategorie.toLowerCase().contains("baumarkt");
  }

  bool _istMarktplatzFilterAktiv() {
    final text =
        "$ausgewaehlteKategorie $ausgewaehlteUnterkategorie $ausgewaehltesDetail"
            .toLowerCase();
    return text.contains("marktplatz") ||
        text.contains("elektronik") ||
        text.contains("freizeit") ||
        text.contains("hobby");
  }

  bool _istTierbedarfFilterAktiv() {
    return ausgewaehlteKategorie.toLowerCase().contains("tierbedarf");
  }

  bool _istFirmenKategorieAktiv() {
    return ausgewaehlteKategorie == "Jobs" ||
        ausgewaehlteKategorie == "Dienstleistungen";
  }

  bool _zeigtMarkenFilter() {
    if (ausgewaehlteKategorie == "Alle") return false;
    return _istAutoFilterAktiv() ||
        _istBooteFilterAktiv() ||
        _istBaumaschinenFilterAktiv() ||
        _istLandwirtschaftFilterAktiv() ||
        _istBaumarktFilterAktiv() ||
        _istMarktplatzFilterAktiv() ||
        _istTierbedarfFilterAktiv();
  }

  bool _zeigtModellFilter() {
    if (ausgewaehlteKategorie == "Alle") return false;
    return _istAutoFilterAktiv() ||
        _istBooteFilterAktiv() ||
        _istBaumaschinenFilterAktiv() ||
        _istLandwirtschaftFilterAktiv();
  }

  String _markenFilterLabel() {
    if (_istBaumaschinenFilterAktiv() ||
        _istLandwirtschaftFilterAktiv() ||
        _istBaumarktFilterAktiv()) {
      return "Hersteller";
    }

    if (_istBooteFilterAktiv()) return "Bootsmarke";
    return "Marke";
  }

  String _modellFilterLabel() {
    if (_istBaumaschinenFilterAktiv() || _istLandwirtschaftFilterAktiv()) {
      return "Maschinenmodell";
    }

    if (_istBooteFilterAktiv()) return "Bootsmodell";
    return "Modell";
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
        detailPasst(produkt);
  }

  List<String> _markenFilterItems() {
    final alleMarken = <String, String>{};

    void add(String wert) {
      final sauber = wert.trim();
      if (sauber.isNotEmpty && sauber != "Alle") {
        alleMarken[_norm(sauber)] = sauber;
      }
    }

    try {
      for (final wert in markenHerstellerFuerFilter(
        kategorie: ausgewaehlteKategorie,
        unterkategorie: ausgewaehlteUnterkategorie,
        detailUnterkategorie: ausgewaehltesDetail,
      )) {
        add(wert);
      }
    } catch (_) {}

    for (final produkt in widget.produkte.where(_basisFilterFuerMarken)) {
      add(produkt.marke);
      add(produkt.hersteller);
      add(produkt.bootMarke);
      add(produkt.baumarktHersteller);
    }

    final marken = alleMarken.values.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return ["Alle", ...marken];
  }

  List<String> _modellFilterItems() {
    final modelleMap = <String, String>{};

    void add(String wert) {
      final sauber = wert.trim();
      if (sauber.isNotEmpty && sauber != "Alle") {
        modelleMap[_norm(sauber)] = sauber;
      }
    }

    if (filterMarke != "Alle") {
      try {
        for (final modell in modelleFuerMarkeUndBereich(
          kategorie: ausgewaehlteKategorie,
          unterkategorie: ausgewaehlteUnterkategorie,
          detailUnterkategorie: ausgewaehltesDetail,
          marke: filterMarke,
        )) {
          add(modell);
        }
      } catch (_) {}
    }

    for (final produkt in widget.produkte.where((produkt) {
      if (!_basisFilterFuerMarken(produkt)) return false;
      if (filterMarke != "Alle" &&
          _norm(_markeVonProdukt(produkt)) != _norm(filterMarke)) {
        return false;
      }
      return true;
    })) {
      add(produkt.modell);
      add(produkt.bootModell);
    }

    final modelle = modelleMap.values.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return ["Alle", ...modelle];
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

  bool kategoriePasst(Produkt produkt) {
    if (ausgewaehlteKategorie == "Alle") return true;
    return produkt.kategorie == ausgewaehlteKategorie ||
        produkt.unterkategorie == ausgewaehlteKategorie ||
        produkt.detailUnterkategorie == ausgewaehlteKategorie;
  }

  bool unterkategoriePasst(Produkt produkt) {
    if (ausgewaehlteUnterkategorie == "Alle") return true;
    return produkt.unterkategorie == ausgewaehlteUnterkategorie ||
        produkt.detailUnterkategorie == ausgewaehlteUnterkategorie;
  }

  bool detailPasst(Produkt produkt) {
    if (ausgewaehltesDetail == "Alle") return true;
    return produkt.detailUnterkategorie == ausgewaehltesDetail;
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

  bool preisPasst(Produkt produkt) {
    final preis = zahl(produkt.preis);
    final von = zahl(preisVonController.text);
    final bis = zahl(preisBisController.text);

    if (von > 0 && preis < von) return false;
    if (bis > 0 && preis > bis) return false;

    return true;
  }

  bool _zahlBereichPasst(
    String wert,
    TextEditingController vonCtrl,
    TextEditingController bisCtrl,
  ) {
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
      if (filterImmobilienArt != "Alle" &&
          _norm(produkt.immobilienArt) != _norm(filterImmobilienArt) &&
          _norm(produkt.detailUnterkategorie) != _norm(filterImmobilienArt)) {
        return false;
      }
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
      if (betriebsstundenBis > 0 &&
          zahl(produkt.baumaschinenBetriebsstunden) > betriebsstundenBis) {
        return false;
      }
    }

    if (produkt.kategorie == "Jobs") {
      final jobText = [
        produkt.titel,
        produkt.beschreibung,
        produkt.unterkategorie,
        produkt.detailUnterkategorie,
      ].join(" ").toLowerCase();

      if (filterBeschaeftigung != "Alle" &&
          !jobText.contains(filterBeschaeftigung.toLowerCase())) {
        return false;
      }

      if (filterHomeoffice != "Alle") {
        final suchtHomeoffice = filterHomeoffice == "Ja";
        final hatHomeoffice = jobText.contains("homeoffice") ||
            jobText.contains("remote") ||
            jobText.contains("online");
        if (suchtHomeoffice != hatHomeoffice) return false;
      }
    }

    if (produkt.kategorie == "Dienstleistungen") {
      final dienstText = [
        produkt.titel,
        produkt.beschreibung,
        produkt.unterkategorie,
        produkt.detailUnterkategorie,
      ].join(" ").toLowerCase();

      if (filterDienstleistungArt != "Alle" &&
          !dienstText.contains(filterDienstleistungArt.toLowerCase())) {
        return false;
      }
    }

    return true;
  }

  bool ortPasst(Produkt produkt) {
    final ort = ortController.text.trim().toLowerCase();
    if (ort.isEmpty) return true;
    return produkt.ort.toLowerCase().contains(ort);
  }

  List<Produkt> gefilterteProdukte() {
    final liste = widget.produkte.where((produkt) {
      return suchePasst(produkt) &&
          kategoriePasst(produkt) &&
          unterkategoriePasst(produkt) &&
          detailPasst(produkt) &&
          markePasst(produkt) &&
          modellPasst(produkt) &&
          anbieterPasst(produkt) &&
          detailDatenPasst(produkt) &&
          ortPasst(produkt) &&
          preisPasst(produkt);
    }).toList();

    if (sortierung == "Älteste zuerst") {
      liste.sort(
        (a, b) => widget.produkte.indexOf(b).compareTo(widget.produkte.indexOf(a)),
      );
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
      grundstueckVonController.clear();
      grundstueckBisController.clear();
      zimmerVonController.clear();
      zimmerBisController.clear();
      gehaltVonController.clear();
      gehaltBisController.clear();
      bootLaengeVonController.clear();
      bootLaengeBisController.clear();
      betriebsstundenBisController.clear();
      ausgewaehlteKategorie = "Alle";
      ausgewaehlteUnterkategorie = "Alle";
      ausgewaehltesDetail = "Alle";
      filterMarke = "Alle";
      filterModell = "Alle";
      filterAnbieter = "Alle";
      filterKraftstoff = "Alle";
      filterGetriebe = "Alle";
      filterImmobilienArt = "Alle";
      filterBalkon = "Alle";
      filterGarage = "Alle";
      filterAufzug = "Alle";
      filterGarten = "Alle";
      filterKeller = "Alle";
      filterHomeoffice = "Alle";
      filterBeschaeftigung = "Alle";
      filterDienstleistungArt = "Alle";
      umkreisFilter = "Österreichweit";
      sortierung = "Neueste zuerst";
    });
  }

  int aktiveFilterAnzahl() {
    int anzahl = 0;
    if (suche.trim().isNotEmpty) anzahl++;
    if (ortController.text.trim().isNotEmpty) anzahl++;
    if (ausgewaehlteKategorie != "Alle") anzahl++;
    if (ausgewaehlteUnterkategorie != "Alle") anzahl++;
    if (ausgewaehltesDetail != "Alle") anzahl++;
    if (filterMarke != "Alle") anzahl++;
    if (filterModell != "Alle") anzahl++;
    if (filterAnbieter != "Alle") anzahl++;
    if (filterKraftstoff != "Alle") anzahl++;
    if (filterGetriebe != "Alle") anzahl++;
    if (filterImmobilienArt != "Alle") anzahl++;
    if (filterBalkon != "Alle") anzahl++;
    if (filterGarage != "Alle") anzahl++;
    if (filterAufzug != "Alle") anzahl++;
    if (filterGarten != "Alle") anzahl++;
    if (filterKeller != "Alle") anzahl++;
    if (filterHomeoffice != "Alle") anzahl++;
    if (filterBeschaeftigung != "Alle") anzahl++;
    if (filterDienstleistungArt != "Alle") anzahl++;
    if (umkreisFilter != "Österreichweit") anzahl++;
    if (preisVonController.text.trim().isNotEmpty) anzahl++;
    if (preisBisController.text.trim().isNotEmpty) anzahl++;
    if (baujahrVonController.text.trim().isNotEmpty) anzahl++;
    if (baujahrBisController.text.trim().isNotEmpty) anzahl++;
    if (kilometerVonController.text.trim().isNotEmpty) anzahl++;
    if (kilometerBisController.text.trim().isNotEmpty) anzahl++;
    if (psVonController.text.trim().isNotEmpty) anzahl++;
    if (psBisController.text.trim().isNotEmpty) anzahl++;
    if (wohnflaecheVonController.text.trim().isNotEmpty) anzahl++;
    if (wohnflaecheBisController.text.trim().isNotEmpty) anzahl++;
    if (grundstueckVonController.text.trim().isNotEmpty) anzahl++;
    if (grundstueckBisController.text.trim().isNotEmpty) anzahl++;
    if (zimmerVonController.text.trim().isNotEmpty) anzahl++;
    if (zimmerBisController.text.trim().isNotEmpty) anzahl++;
    if (gehaltVonController.text.trim().isNotEmpty) anzahl++;
    if (gehaltBisController.text.trim().isNotEmpty) anzahl++;
    return anzahl;
  }

  void _zurStartseiteSpringen() {
    // Logo/Start soll aus jedem Bereich zurück zur Startseite führen.
    // rootNavigator nimmt auch verschachtelte Bereiche/Unterseiten mit.
    final navigator = Navigator.of(context, rootNavigator: true);

    if (inhaltScrollController.hasClients) {
      inhaltScrollController.jumpTo(0);
    }

    filterZuruecksetzen();

    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final breit = MediaQuery.of(context).size.width > 980;
    final produkte = gefilterteProdukte();

    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      body: SafeArea(
        child: Column(
          children: [
            _kopfzeile(breit),
            Expanded(
              child: breit
                  ? Row(
                      children: [
                        _desktopFilterPanel(),
                        Expanded(child: _contentBereich(produkte, breit)),
                      ],
                    )
                  : _mobileContent(produkte, breit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kopfzeile(bool breit) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: breit ? 28 : 16,
        vertical: 13,
      ),
      decoration: const BoxDecoration(
        color: Color(0xff050b2c),
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _zurStartseiteSpringen,
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff5b2cff), Color(0xff7a5cff)],
                    ),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(Icons.language, color: Colors.white, size: 27),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "HANDELSWELT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    Text(
                      "DEALS",
                      style: TextStyle(
                        color: Color(0xffb9a8ff),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          if (breit) ...[
            _navChip("Start", Icons.home_outlined, false, onTap: _zurStartseiteSpringen),
            const SizedBox(width: 8),
            _navChip("Suchen & Finden", Icons.tune, true),
          ],
          if (!breit)
            IconButton(
              onPressed: _mobileFilterOeffnen,
              icon: const Icon(Icons.tune, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _navChip(String text, IconData icon, bool aktiv, {VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: aktiv
              ? const Color(0xff5b2cff).withOpacity(0.13)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: aktiv
                ? const Color(0xff5b2cff)
                : Colors.white.withOpacity(0.12),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: aktiv ? const Color(0xff5b2cff) : Colors.white70,
              size: 17,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: aktiv ? const Color(0xff5b2cff) : Colors.white70,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _desktopFilterPanel() {
    return Container(
      width: 330,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xff050b2c),
        border: Border(
          right: BorderSide(color: Color(0xff202844)),
        ),
      ),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: _filterInhalt(dunkel: true),
        ),
      ),
    );
  }

  Widget _mobileContent(List<Produkt> produkte, bool breit) {
    return Stack(
      children: [
        _contentBereich(produkte, breit),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            backgroundColor: const Color(0xff5b2cff),
            foregroundColor: Colors.white,
            onPressed: _mobileFilterOeffnen,
            icon: const Icon(Icons.tune),
            label: Text("Filter ${aktiveFilterAnzahl() > 0 ? "(${aktiveFilterAnzahl()})" : ""}"),
          ),
        ),
      ],
    );
  }

  Future<void> _mobileFilterOeffnen() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            void neuSetzen(VoidCallback fn) {
              setState(fn);
              modalSetState(() {});
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.88,
              minChildSize: 0.45,
              maxChildSize: 0.96,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xff0b1026),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 26),
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _filterInhalt(
                        dunkel: true,
                        neuSetzenExtern: neuSetzen,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(sheetContext),
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

  Widget _filterInhalt({
    required bool dunkel,
    void Function(VoidCallback fn)? neuSetzenExtern,
  }) {
    void neuSetzen(VoidCallback fn) {
      if (neuSetzenExtern != null) {
        neuSetzenExtern(fn);
      } else {
        setState(fn);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _filterTitel(dunkel),
        const SizedBox(height: 14),
        _suchFeld(dunkel),
        const SizedBox(height: 14),
        _filterAbschnitt("Sortierung", dunkel),
        _dropdown(
          label: "Sortieren",
          value: sortierung,
          items: sortierungen,
          icon: Icons.swap_vert,
          dunkel: dunkel,
          onChanged: (value) {
            if (value == null) return;
            neuSetzen(() => sortierung = value);
          },
        ),
        const SizedBox(height: 12),
        _filterAbschnitt("Kategorie", dunkel),
        _dropdown(
          label: "Kategorie",
          value: ausgewaehlteKategorie,
          items: kategorien,
          icon: Icons.category_outlined,
          dunkel: dunkel,
          onChanged: (value) {
            if (value == null) return;
            neuSetzen(() {
              ausgewaehlteKategorie = value;
              ausgewaehlteUnterkategorie = "Alle";
              ausgewaehltesDetail = "Alle";
              filterMarke = "Alle";
              filterModell = "Alle";
              filterAnbieter =
                  (value == "Jobs" || value == "Dienstleistungen") ? "Firma" : "Alle";
            });
          },
        ),
        const SizedBox(height: 10),
        _dropdown(
          label: "Unterkategorie",
          value: ausgewaehlteUnterkategorie,
          items: unterkategorien,
          icon: Icons.account_tree_outlined,
          dunkel: dunkel,
          onChanged: (value) {
            if (value == null) return;
            neuSetzen(() {
              ausgewaehlteUnterkategorie = value;
              ausgewaehltesDetail = "Alle";
              filterMarke = "Alle";
              filterModell = "Alle";
            });
          },
        ),
        const SizedBox(height: 10),
        _dropdown(
          label: "Detail",
          value: ausgewaehltesDetail,
          items: details,
          icon: Icons.label_outline,
          dunkel: dunkel,
          onChanged: (value) {
            if (value == null) return;
            neuSetzen(() {
              ausgewaehltesDetail = value;
              filterMarke = "Alle";
              filterModell = "Alle";
            });
          },
        ),
        if (_zeigtMarkenFilter()) ...[
          const SizedBox(height: 12),
          _filterAbschnitt(_markenFilterLabel(), dunkel),
          _suchbareAuswahl(
            label: _markenFilterLabel(),
            value: filterMarke,
            items: _markenFilterItems(),
            icon: Icons.verified_outlined,
            dunkel: dunkel,
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
            items: _modellFilterItems(),
            icon: Icons.sell_outlined,
            dunkel: dunkel,
            onSelected: (value) {
              neuSetzen(() => filterModell = value);
            },
          ),
        ],
        const SizedBox(height: 12),
        _kategorieDetailFilter(neuSetzen, dunkel),
        if (!_istFirmenKategorieAktiv()) ...[
          const SizedBox(height: 12),
          _filterAbschnitt("Anbieter", dunkel),
          _chipAuswahl(
            items: anbieterOptionen,
            value: filterAnbieter,
            dunkel: dunkel,
            onSelected: (value) {
              neuSetzen(() => filterAnbieter = value);
            },
          ),
        ],
        const SizedBox(height: 12),
        _filterAbschnitt("Preis", dunkel),
        Row(
          children: [
            Expanded(child: _zahlFeld(preisVonController, "von", Icons.euro, dunkel)),
            const SizedBox(width: 8),
            Expanded(child: _zahlFeld(preisBisController, "bis", Icons.euro, dunkel)),
          ],
        ),
        const SizedBox(height: 12),
        _filterAbschnitt("Ort", dunkel),
        _textFeld(
          controller: ortController,
          label: "Ort oder PLZ eingeben",
          icon: Icons.location_on_outlined,
          dunkel: dunkel,
        ),
        const SizedBox(height: 8),
        _dropdown(
          label: "Umkreis",
          value: umkreisFilter,
          items: umkreisOptionen,
          icon: Icons.near_me_outlined,
          dunkel: dunkel,
          onChanged: (value) {
            if (value == null) return;
            neuSetzen(() => umkreisFilter = value);
          },
        ),
        const SizedBox(height: 16),
        _zuruecksetzenButton(dunkel),
      ],
    );
  }

  Widget _filterTitel(bool dunkel) {
    final aktive = aktiveFilterAnzahl();

    return Row(
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: const Color(0xff5b2cff).withOpacity(0.13),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.tune,
            color: Color(0xff5b2cff),
            size: 21,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "Filter",
            style: TextStyle(
              color: dunkel ? Colors.white : const Color(0xff050b2c),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xff5b2cff),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            "$aktive aktiv",
            style: const TextStyle(
              color: Color(0xff050b2c),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterAbschnitt(String titel, bool dunkel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        titel.toUpperCase(),
        style: TextStyle(
          color: dunkel ? Colors.white : const Color(0xff050b2c),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _suchFeld(bool dunkel) {
    return _textFeld(
      controller: sucheController,
      label: "Was suchst du?",
      icon: Icons.search,
      dunkel: dunkel,
      onChanged: (wert) {
        setState(() {
          suche = wert;
        });
      },
    );
  }

  Widget _textFeld({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool dunkel,
    Function(String)? onChanged,
  }) {
    return TextField(
      cursorColor: const Color(0xff5b2cff),
      controller: controller,
      onChanged: onChanged ?? (_) => setState(() {}),
      style: TextStyle(
        color: dunkel ? Colors.white : const Color(0xff050b2c),
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: dunkel ? Colors.white70 : const Color(0xff74788d),
        ),
        prefixIcon: Icon(icon, color: const Color(0xff5b2cff), size: 20),
        filled: true,
        fillColor: dunkel ? const Color(0xff111833) : const Color(0xfff7f7fb),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(
            color: dunkel ? const Color(0xff26304f) : const Color(0xffececf4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(
            color: dunkel ? const Color(0xff26304f) : const Color(0xffececf4),
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
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required bool dunkel,
    required Function(String?) onChanged,
  }) {
    final sichereItems = items.isEmpty ? ["Alle"] : items.toSet().toList();
    final sichererWert = sichereItems.contains(value) ? value : sichereItems.first;

    return DropdownButtonFormField<String>(
      value: sichererWert,
      dropdownColor: dunkel ? const Color(0xff111833) : Colors.white,
      isExpanded: true,
      style: TextStyle(
        color: dunkel ? Colors.white : const Color(0xff050b2c),
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: dunkel ? Colors.white70 : const Color(0xff74788d),
        ),
        prefixIcon: Icon(icon, color: const Color(0xff5b2cff), size: 20),
        filled: true,
        fillColor: dunkel ? const Color(0xff111833) : const Color(0xfff7f7fb),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(
            color: dunkel ? const Color(0xff26304f) : const Color(0xffececf4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(
            color: dunkel ? const Color(0xff26304f) : const Color(0xffececf4),
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
      items: sichereItems.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            suchfilterAnzeigeText(item),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _zahlFeld(
    TextEditingController controller,
    String label,
    IconData icon,
    bool dunkel,
  ) {
    return TextField(
      cursorColor: const Color(0xff5b2cff),
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: (_) => setState(() {}),
      style: TextStyle(
        color: dunkel ? Colors.white : const Color(0xff050b2c),
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: dunkel ? Colors.white70 : const Color(0xff74788d),
        ),
        prefixIcon: Icon(icon, color: const Color(0xff5b2cff), size: 19),
        filled: true,
        fillColor: dunkel ? const Color(0xff111833) : const Color(0xfff7f7fb),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(
            color: dunkel ? const Color(0xff26304f) : const Color(0xffececf4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(
            color: dunkel ? const Color(0xff26304f) : const Color(0xffececf4),
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
    );
  }

  Widget _kategorieDetailFilter(
    void Function(VoidCallback fn) neuSetzen,
    bool dunkel,
  ) {
    if (_istAutoFilterAktiv()) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _filterAbschnitt("Fahrzeugdaten", dunkel),
          Row(
            children: [
              Expanded(child: _zahlFeld(baujahrVonController, "Baujahr von", Icons.calendar_month_outlined, dunkel)),
              const SizedBox(width: 8),
              Expanded(child: _zahlFeld(baujahrBisController, "bis", Icons.calendar_month_outlined, dunkel)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _zahlFeld(kilometerVonController, "KM von", Icons.speed_outlined, dunkel)),
              const SizedBox(width: 8),
              Expanded(child: _zahlFeld(kilometerBisController, "bis", Icons.speed_outlined, dunkel)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _zahlFeld(psVonController, "PS von", Icons.bolt_outlined, dunkel)),
              const SizedBox(width: 8),
              Expanded(child: _zahlFeld(psBisController, "bis", Icons.bolt_outlined, dunkel)),
            ],
          ),
          const SizedBox(height: 8),
          _dropdown(
            label: "Kraftstoff",
            value: filterKraftstoff,
            items: kraftstoffOptionen,
            icon: Icons.local_gas_station_outlined,
            dunkel: dunkel,
            onChanged: (value) {
              if (value == null) return;
              neuSetzen(() => filterKraftstoff = value);
            },
          ),
          const SizedBox(height: 8),
          _dropdown(
            label: "Getriebe",
            value: filterGetriebe,
            items: getriebeOptionen,
            icon: Icons.settings_outlined,
            dunkel: dunkel,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _filterAbschnitt("Immobilien-Filter", dunkel),
          _suchbareAuswahl(
            label: "Art",
            value: filterImmobilienArt,
            items: immobilienArtOptionen,
            icon: Icons.home_work_outlined,
            dunkel: dunkel,
            onSelected: (value) => neuSetzen(() => filterImmobilienArt = value),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _zahlFeld(zimmerVonController, "Zimmer von", Icons.meeting_room_outlined, dunkel)),
              const SizedBox(width: 8),
              Expanded(child: _zahlFeld(zimmerBisController, "bis", Icons.meeting_room_outlined, dunkel)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _zahlFeld(wohnflaecheVonController, "m² von", Icons.square_foot_outlined, dunkel)),
              const SizedBox(width: 8),
              Expanded(child: _zahlFeld(wohnflaecheBisController, "bis", Icons.square_foot_outlined, dunkel)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _zahlFeld(grundstueckVonController, "Grundstück von", Icons.landscape_outlined, dunkel)),
              const SizedBox(width: 8),
              Expanded(child: _zahlFeld(grundstueckBisController, "bis", Icons.landscape_outlined, dunkel)),
            ],
          ),
          const SizedBox(height: 8),
          _filterAbschnitt("Ausstattung", dunkel),
          _chipAuswahl(
            items: jaNeinOptionen,
            value: filterBalkon,
            labelPrefix: "Balkon: ",
            dunkel: dunkel,
            onSelected: (value) => neuSetzen(() => filterBalkon = value),
          ),
          const SizedBox(height: 8),
          _chipAuswahl(
            items: jaNeinOptionen,
            value: filterGarage,
            labelPrefix: "Garage: ",
            dunkel: dunkel,
            onSelected: (value) => neuSetzen(() => filterGarage = value),
          ),
          const SizedBox(height: 8),
          _chipAuswahl(
            items: jaNeinOptionen,
            value: filterGarten,
            labelPrefix: "Garten: ",
            dunkel: dunkel,
            onSelected: (value) => neuSetzen(() => filterGarten = value),
          ),
          const SizedBox(height: 8),
          _chipAuswahl(
            items: jaNeinOptionen,
            value: filterAufzug,
            labelPrefix: "Aufzug: ",
            dunkel: dunkel,
            onSelected: (value) => neuSetzen(() => filterAufzug = value),
          ),
          const SizedBox(height: 8),
          _chipAuswahl(
            items: jaNeinOptionen,
            value: filterKeller,
            labelPrefix: "Keller: ",
            dunkel: dunkel,
            onSelected: (value) => neuSetzen(() => filterKeller = value),
          ),
        ],
      );
    }

    if (_istBooteFilterAktiv()) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _filterAbschnitt("Bootsdaten", dunkel),
          Row(
            children: [
              Expanded(child: _zahlFeld(baujahrVonController, "Baujahr von", Icons.calendar_month_outlined, dunkel)),
              const SizedBox(width: 8),
              Expanded(child: _zahlFeld(baujahrBisController, "bis", Icons.calendar_month_outlined, dunkel)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _zahlFeld(bootLaengeVonController, "Länge von", Icons.straighten_outlined, dunkel)),
              const SizedBox(width: 8),
              Expanded(child: _zahlFeld(bootLaengeBisController, "bis", Icons.straighten_outlined, dunkel)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _zahlFeld(psVonController, "PS von", Icons.bolt_outlined, dunkel)),
              const SizedBox(width: 8),
              Expanded(child: _zahlFeld(psBisController, "bis", Icons.bolt_outlined, dunkel)),
            ],
          ),
        ],
      );
    }

    if (_istBaumaschinenFilterAktiv()) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _filterAbschnitt("Maschinendaten", dunkel),
          Row(
            children: [
              Expanded(child: _zahlFeld(baujahrVonController, "Baujahr von", Icons.calendar_month_outlined, dunkel)),
              const SizedBox(width: 8),
              Expanded(child: _zahlFeld(baujahrBisController, "bis", Icons.calendar_month_outlined, dunkel)),
            ],
          ),
          const SizedBox(height: 8),
          _zahlFeld(
            betriebsstundenBisController,
            "Betriebsstunden bis",
            Icons.timer_outlined,
            dunkel,
          ),
        ],
      );
    }

    if (_istJobsFilterAktiv()) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _filterAbschnitt("Job-Filter", dunkel),
          _suchbareAuswahl(
            label: "Beschäftigung",
            value: filterBeschaeftigung,
            items: beschaeftigungOptionen,
            icon: Icons.work_outline,
            dunkel: dunkel,
            onSelected: (value) => neuSetzen(() => filterBeschaeftigung = value),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _zahlFeld(gehaltVonController, "Gehalt von", Icons.euro, dunkel)),
              const SizedBox(width: 8),
              Expanded(child: _zahlFeld(gehaltBisController, "bis", Icons.euro, dunkel)),
            ],
          ),
          const SizedBox(height: 8),
          _chipAuswahl(
            items: jaNeinOptionen,
            value: filterHomeoffice,
            labelPrefix: "Homeoffice: ",
            dunkel: dunkel,
            onSelected: (value) => neuSetzen(() => filterHomeoffice = value),
          ),
        ],
      );
    }

    if (_istDienstleistungenFilterAktiv()) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _filterAbschnitt("Dienstleistungs-Filter", dunkel),
          _suchbareAuswahl(
            label: "Dienstleistungsart",
            value: filterDienstleistungArt,
            items: dienstleistungOptionen,
            icon: Icons.handyman_outlined,
            dunkel: dunkel,
            onSelected: (value) => neuSetzen(() => filterDienstleistungArt = value),
          ),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _chipAuswahl({
    required List<String> items,
    required String value,
    required bool dunkel,
    required Function(String) onSelected,
    String labelPrefix = "",
  }) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: items.map((item) {
        final aktiv = value == item;
        final text = labelPrefix.isEmpty ? item : "$labelPrefix${suchfilterAnzeigeText(item)}";

        return InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => onSelected(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: aktiv
                  ? const Color(0xff5b2cff)
                  : (dunkel ? const Color(0xff111833) : const Color(0xfff7f7fb)),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: aktiv
                    ? const Color(0xff5b2cff)
                    : (dunkel ? const Color(0xff26304f) : const Color(0xffececf4)),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: aktiv
                    ? Colors.white
                    : (dunkel ? Colors.white : const Color(0xff050b2c)),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _suchbareAuswahl({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required bool dunkel,
    required Function(String) onSelected,
  }) {
    final sichereItems = items.isEmpty ? ["Alle"] : items.toSet().toList();
    final anzeige = sichereItems.contains(value) ? value : "Alle";

    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: () async {
        final auswahl = await _auswahlSucheOeffnen(
          titel: label,
          items: sichereItems,
          aktuellerWert: anzeige,
          dunkel: dunkel,
        );
        if (auswahl != null) onSelected(auswahl);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: dunkel ? Colors.white70 : const Color(0xff74788d),
          ),
          prefixIcon: Icon(icon, color: const Color(0xff5b2cff), size: 20),
          suffixIcon: const Icon(Icons.search, color: Color(0xff5b2cff)),
          filled: true,
          fillColor: dunkel ? const Color(0xff111833) : const Color(0xfff7f7fb),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide(
              color: dunkel ? const Color(0xff26304f) : const Color(0xffececf4),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide(
              color: dunkel ? const Color(0xff26304f) : const Color(0xffececf4),
            ),
          ),
        ),
        child: Text(
          suchfilterAnzeigeText(anzeige),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: dunkel ? Colors.white : const Color(0xff050b2c),
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
    required bool dunkel,
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
                  decoration: BoxDecoration(
                    color: dunkel ? const Color(0xff0b1026) : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: dunkel ? Colors.white24 : const Color(0xffd8d8e8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                        child: TextField(
                          controller: controller,
                          autofocus: true,
                          style: TextStyle(color: dunkel ? Colors.white : const Color(0xff050b2c)),
                          onChanged: (_) => modalSetState(() {}),
                          decoration: InputDecoration(
                            hintText: "Suchen, z.B. B...",
                            hintStyle: TextStyle(color: dunkel ? Colors.white54 : const Color(0xff74788d)),
                            labelText: titel,
                            labelStyle: TextStyle(color: dunkel ? Colors.white70 : const Color(0xff74788d)),
                            prefixIcon: const Icon(Icons.search, color: Color(0xff5b2cff)),
                            filled: true,
                            fillColor: dunkel ? const Color(0xff111833) : const Color(0xfff7f7fb),
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
                                  color: dunkel ? Colors.white : const Color(0xff050b2c),
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

  Widget _zuruecksetzenButton(bool dunkel) {
    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: filterZuruecksetzen,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: dunkel ? const Color(0xff111833) : const Color(0xfff1edff),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: dunkel ? const Color(0xff26304f) : const Color(0xffececf4),
          ),
        ),
        child: const Center(
          child: Text(
            "Filter zurücksetzen",
            style: TextStyle(
              color: Color(0xff5b2cff),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _contentBereich(List<Produkt> produkte, bool breit) {
    return Scrollbar(
      thumbVisibility: breit,
      controller: inhaltScrollController,
      child: ListView(
        controller: inhaltScrollController,
        padding: EdgeInsets.fromLTRB(
        breit ? 24 : 16,
        18,
        breit ? 28 : 16,
        24,
      ),
      children: [
        _kategorieLeiste(),
        const SizedBox(height: 18),
        _ergebnisKopf(produkte.length),
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
              childAspectRatio: breit ? 0.70 : 0.55,
            ),
            itemBuilder: (context, index) {
              return _produktKarte(produkte[index], breit);
            },
          ),
      ],
      ),
    );
  }

  Widget _kategorieLeiste() {
    return SizedBox(
      height: 52,
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
                ausgewaehlteUnterkategorie = "Alle";
                ausgewaehltesDetail = "Alle";
                filterMarke = "Alle";
                filterModell = "Alle";
                filterAnbieter =
                    (kategorie == "Jobs" || kategorie == "Dienstleistungen") ? "Firma" : "Alle";
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 170),
              margin: const EdgeInsets.only(right: 9),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: aktiv ? const Color(0xff5b2cff) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: aktiv ? const Color(0xff5b2cff) : const Color(0xffececf4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: aktiv ? const Color(0x255b2cff) : const Color(0x0d000000),
                    blurRadius: aktiv ? 16 : 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    kategorie == "Alle" ? Icons.local_fire_department : iconFuerKategorie(kategorie),
                    color: aktiv ? Colors.white : const Color(0xff5b2cff),
                    size: 18,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    suchfilterAnzeigeText(kategorie),
                    style: TextStyle(
                      color: aktiv ? Colors.white : const Color(0xff050b2c),
                      fontSize: 13,
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

  Widget _ergebnisKopf(int anzahl) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Suchen & Finden",
                style: TextStyle(
                  color: Color(0xff050b2c),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _aktiverFilterText(),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xfff1edff),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            "$anzahl gefunden",
            style: const TextStyle(
              color: Color(0xff5b2cff),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  String _aktiverFilterText() {
    final teile = [
      if (ausgewaehlteKategorie != "Alle") suchfilterAnzeigeText(ausgewaehlteKategorie),
      if (ausgewaehlteUnterkategorie != "Alle") suchfilterAnzeigeText(ausgewaehlteUnterkategorie),
      if (ausgewaehltesDetail != "Alle") suchfilterAnzeigeText(ausgewaehltesDetail),
      if (filterMarke != "Alle") filterMarke,
      if (filterModell != "Alle") filterModell,
      if (suche.trim().isNotEmpty) "Suche: ${suche.trim()}",
      if (preisVonController.text.trim().isNotEmpty) "ab ${preisVonController.text.trim()} €",
      if (preisBisController.text.trim().isNotEmpty) "bis ${preisBisController.text.trim()} €",
      if (ortController.text.trim().isNotEmpty) "Ort: ${ortController.text.trim()}",
      if (umkreisFilter != "Österreichweit") umkreisFilter,
      sortierung,
    ];

    if (teile.isEmpty) return "Alle Inserate übersichtlich durchsuchen";
    return teile.join(" • ");
  }

  Widget _produktKarte(Produkt produkt, bool breit) {
    final preisText =
        produkt.preis.trim().endsWith("€") ? produkt.preis.trim() : "${produkt.preis.trim()} €";
    final info1 = _infoZeile1(produkt);
    final info2 = _infoZeile2(produkt);

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
            Expanded(
              flex: 46,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: produkt.bild.isEmpty
                          ? _platzhalter(produkt)
                          : Image.network(
                              produkt.bild,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _platzhalter(produkt);
                              },
                            ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.08),
                          Colors.transparent,
                          Colors.black.withOpacity(0.38),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 9,
                    left: 9,
                    child: _bildBadge(
                      produkt.firmaVerifiziert ? "VERIFIZIERT" : "NEU",
                      produkt.firmaVerifiziert ? Colors.orange : Colors.red,
                    ),
                  ),
                  Positioned(
                    top: 9,
                    right: 9,
                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: Colors.white,
                      child: Icon(
                        produkt.favorit ? Icons.favorite : Icons.favorite_border,
                        color: produkt.favorit ? Colors.red : const Color(0xff74788d),
                        size: 19,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 9,
                    right: 9,
                    bottom: 9,
                    child: Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: _kartenChips(produkt)
                          .map((chip) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.65),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  chip,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 54,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
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
                        height: 1.12,
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
                      ),
                    ),
                    if (info1.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        info1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xff050b2c),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                    if (info2.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        info2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xff74788d),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xff74788d),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            produkt.ort.isEmpty ? "Österreich" : produkt.ort,
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
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        _miniChip(
                          _anzeigenId(produkt),
                          const Color(0xfff4f4f8),
                          const Color(0xff74788d),
                        ),
                        _miniChip(
                          produkt.firmaVerifiziert
                              ? "✔ Firma"
                              : (produkt.typ == "Firma" ? "Firma" : "Privat"),
                          produkt.firmaVerifiziert
                              ? const Color(0xffffefe0)
                              : const Color(0xfff1edff),
                          produkt.firmaVerifiziert ? Colors.orange : const Color(0xff5b2cff),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _kartenChips(Produkt produkt) {
    return [
      if (produkt.kategorie == "Auto & Motor" && produkt.baujahr.trim().isNotEmpty)
        produkt.baujahr,
      if (produkt.kategorie == "Auto & Motor" && produkt.kilometer.trim().isNotEmpty)
        mitEinheit(produkt.kilometer, "km"),
      if (produkt.kategorie == "Auto & Motor" && produkt.leistung.trim().isNotEmpty)
        mitEinheit(produkt.leistung, "PS"),
      if (produkt.kategorie == "Immobilien" && produkt.wohnflaeche.trim().isNotEmpty)
        mitEinheit(produkt.wohnflaeche, "m²"),
      if (produkt.kategorie == "Immobilien" && produkt.zimmer.trim().isNotEmpty)
        "${produkt.zimmer} Zi.",
      if (produkt.kategorie == "Immobilien" && produkt.immobilienArt.trim().isNotEmpty)
        produkt.immobilienArt,
      if (produkt.kategorie == "Boote" && produkt.bootLaenge.trim().isNotEmpty)
        mitEinheit(produkt.bootLaenge, "m"),
      if (produkt.kategorie == "Baumaschinen" &&
          produkt.baumaschinenBetriebsstunden.trim().isNotEmpty)
        mitEinheit(produkt.baumaschinenBetriebsstunden, "h"),
    ].where((e) => e.trim().isNotEmpty).take(4).toList();
  }

  Widget _bildBadge(String text, Color farbe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

  Widget _platzhalter(Produkt produkt) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xfff1edff),
      child: Icon(
        produkt.icon,
        color: const Color(0xff5b2cff),
        size: 42,
      ),
    );
  }

  Widget _miniChip(String text, Color bg, Color fg) {
    if (text.trim().isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  String _infoZeile1(Produkt produkt) {
    if (produkt.kategorie == "Auto & Motor" || produkt.kategorie == "Autos") {
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

    final teile = [
      produkt.unterkategorie,
      produkt.detailUnterkategorie,
    ].where((e) => e.trim().isNotEmpty).toList();

    if (teile.isNotEmpty) return teile.join(" • ");
    return produkt.zustand;
  }

  String _infoZeile2(Produkt produkt) {
    if (produkt.kategorie == "Auto & Motor" || produkt.kategorie == "Autos") {
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

  Widget _leer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffececf4)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off,
            size: 46,
            color: Color(0xff5b2cff),
          ),
          SizedBox(height: 12),
          Text(
            "Keine Inserate gefunden.",
            style: TextStyle(
              color: Color(0xff050b2c),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Ändere deine Suche oder setze die Filter zurück.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xff74788d),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
