import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Produkt {
  String id;

  String titel;
  String preis;
  String ort;
  String adresse;
  String kategorie;
  String unterkategorie;
  String detailUnterkategorie;
  String typ;
  String beschreibung;

  IconData icon;

  String bild;
  List<String> bilder;

  bool favorit;

  String verkaeuferId;
  String verkaeuferEmail;

  String telefon;
  String firmenname;
  String webseite;

  bool firmaVerifiziert;

  bool telefonSichtbar;
  bool whatsappAktiv;
  bool emailSichtbar;

  double latitude;
  double longitude;

  String marke;
  String modell;
  String baujahr;
  String kilometer;
  String kraftstoff;
  String getriebe;
  String leistung;
  String farbe;
  String karosserie;
  String erstzulassung;
  String vorbesitzer;
  String antrieb;
  String tuev;
  String unfallfrei;
  String tueren;
  String sitze;
  String serviceheft;
  String nichtraucher;
  String mwstAusweisbar;
  String hubraum;
  String verbrauch;
  String co2;
  String schluessel;
  String pickerlNeu;
  String leasingMoeglich;
  String finanzierungMoeglich;
  String inzahlungnahmeMoeglich;

  String immobilienArt;
  String wohnflaeche;
  String zimmer;
  String etage;
  String kaution;
  String betriebskosten;
  String balkon;
  String terrasse;
  String garten;
  String garage;
  String lift;
  String keller;
  String moebliert;
  String energieklasse;
  String heizung;
  String baujahrImmobilie;
  String verfuegbarAb;

  String zustand;
  String hersteller;
  String garantie;

  // Jobs
  String jobBerufsbezeichnung;
  String jobGehalt;
  String jobArbeitsort;
  String jobErfahrung;
  String jobBeschaeftigungsart;
  String jobHomeoffice;
  String jobFuehrerschein;

  // Dienstleistungen
  String dienstleistungEinsatzgebiet;
  String dienstleistungPreisProStunde;
  String dienstleistungOeffnungszeiten;
  String dienstleistungAnfahrt;
  String dienstleistungNotdienst;

  // Vermietung
  String mietpreisTag;
  String mietpreisWoche;
  String mietpreisMonat;
  String mindestmietdauer;
  String versicherung;
  String lieferungMoeglich;

  String bootMarke;
  String bootModell;
  String bootBaujahr;
  String bootLaenge;
  String bootLeistung;
  String bootstyp;

  String baumaschinenZustand;
  String baumaschinenBaujahr;
  String baumaschinenBetriebsstunden;
  String baumaschinenKraftstoff;
  String baumaschinenLeistung;
  String baumaschinenGewicht;

  String baumarktHersteller;
  String baumarktMaterial;
  String baumarktFarbe;
  String baumarktMasse;
  String baumarktGewicht;
  String baumarktMenge;

  Produkt({
    this.id = "",
    required this.titel,
    required this.preis,
    required this.ort,
    this.adresse = "",
    required this.kategorie,
    this.unterkategorie = "",
    this.detailUnterkategorie = "",
    required this.typ,
    required this.beschreibung,
    required this.icon,
    required this.bild,
    this.bilder = const [],
    this.favorit = false,
    required this.verkaeuferId,
    required this.verkaeuferEmail,
    this.telefon = "",
    this.firmenname = "",
    this.webseite = "",
    this.firmaVerifiziert = false,
    this.telefonSichtbar = false,
    this.whatsappAktiv = false,
    this.emailSichtbar = false,
    this.latitude = 48.2082,
    this.longitude = 16.3738,
    this.marke = "",
    this.modell = "",
    this.baujahr = "",
    this.kilometer = "",
    this.kraftstoff = "",
    this.getriebe = "",
    this.leistung = "",
    this.farbe = "",
    this.karosserie = "",
    this.erstzulassung = "",
    this.vorbesitzer = "",
    this.antrieb = "",
    this.tuev = "",
    this.unfallfrei = "",
    this.tueren = "",
    this.sitze = "",
    this.serviceheft = "",
    this.nichtraucher = "",
    this.mwstAusweisbar = "",
    this.hubraum = "",
    this.verbrauch = "",
    this.co2 = "",
    this.schluessel = "",
    this.pickerlNeu = "",
    this.leasingMoeglich = "",
    this.finanzierungMoeglich = "",
    this.inzahlungnahmeMoeglich = "",
    this.immobilienArt = "",
    this.wohnflaeche = "",
    this.zimmer = "",
    this.etage = "",
    this.kaution = "",
    this.betriebskosten = "",
    this.balkon = "",
    this.terrasse = "",
    this.garten = "",
    this.garage = "",
    this.lift = "",
    this.keller = "",
    this.moebliert = "",
    this.energieklasse = "",
    this.heizung = "",
    this.baujahrImmobilie = "",
    this.verfuegbarAb = "",
    this.zustand = "",
    this.hersteller = "",
    this.garantie = "",
    this.jobBerufsbezeichnung = "",
    this.jobGehalt = "",
    this.jobArbeitsort = "",
    this.jobErfahrung = "",
    this.jobBeschaeftigungsart = "",
    this.jobHomeoffice = "",
    this.jobFuehrerschein = "",
    this.dienstleistungEinsatzgebiet = "",
    this.dienstleistungPreisProStunde = "",
    this.dienstleistungOeffnungszeiten = "",
    this.dienstleistungAnfahrt = "",
    this.dienstleistungNotdienst = "",
    this.mietpreisTag = "",
    this.mietpreisWoche = "",
    this.mietpreisMonat = "",
    this.mindestmietdauer = "",
    this.versicherung = "",
    this.lieferungMoeglich = "",
    this.bootMarke = "",
    this.bootModell = "",
    this.bootBaujahr = "",
    this.bootLaenge = "",
    this.bootLeistung = "",
    this.bootstyp = "",
    this.baumaschinenZustand = "",
    this.baumaschinenBaujahr = "",
    this.baumaschinenBetriebsstunden = "",
    this.baumaschinenKraftstoff = "",
    this.baumaschinenLeistung = "",
    this.baumaschinenGewicht = "",
    this.baumarktHersteller = "",
    this.baumarktMaterial = "",
    this.baumarktFarbe = "",
    this.baumarktMasse = "",
    this.baumarktGewicht = "",
    this.baumarktMenge = "",
  });

  Map<String, dynamic> toMap() {
    return {
      "titel": titel,
      "preis": preis,
      "ort": ort,
      "adresse": adresse,
      "kategorie": kategorie,
      "unterkategorie": unterkategorie,
      "detailUnterkategorie": detailUnterkategorie,
      "typ": typ,
      "beschreibung": beschreibung,
      "bild": bild,
      "bilder": bilder,
      "favorit": favorit,
      "verkaeuferId": verkaeuferId,
      "verkaeuferEmail": verkaeuferEmail,
      "telefon": telefon,
      "firmenname": firmenname,
      "webseite": webseite,
      "firmaVerifiziert": firmaVerifiziert,
      "telefonSichtbar": telefonSichtbar,
      "whatsappAktiv": whatsappAktiv,
      "emailSichtbar": emailSichtbar,
      "latitude": latitude,
      "longitude": longitude,

      "marke": marke,
      "modell": modell,
      "baujahr": baujahr,
      "kilometer": kilometer,
      "kraftstoff": kraftstoff,
      "getriebe": getriebe,
      "leistung": leistung,
      "farbe": farbe,
      "karosserie": karosserie,
      "erstzulassung": erstzulassung,
      "vorbesitzer": vorbesitzer,
      "antrieb": antrieb,
      "tuev": tuev,
      "unfallfrei": unfallfrei,
      "tueren": tueren,
      "sitze": sitze,
      "serviceheft": serviceheft,
      "nichtraucher": nichtraucher,
      "mwstAusweisbar": mwstAusweisbar,
      "hubraum": hubraum,
      "verbrauch": verbrauch,
      "co2": co2,
      "schluessel": schluessel,
      "pickerlNeu": pickerlNeu,
      "leasingMoeglich": leasingMoeglich,
      "finanzierungMoeglich": finanzierungMoeglich,
      "inzahlungnahmeMoeglich": inzahlungnahmeMoeglich,

      "immobilienArt": immobilienArt,
      "wohnflaeche": wohnflaeche,
      "zimmer": zimmer,
      "etage": etage,
      "kaution": kaution,
      "betriebskosten": betriebskosten,
      "balkon": balkon,
      "terrasse": terrasse,
      "garten": garten,
      "garage": garage,
      "lift": lift,
      "keller": keller,
      "moebliert": moebliert,
      "energieklasse": energieklasse,
      "heizung": heizung,
      "baujahrImmobilie": baujahrImmobilie,
      "verfuegbarAb": verfuegbarAb,

      "zustand": zustand,
      "hersteller": hersteller,
      "garantie": garantie,

      "jobBerufsbezeichnung": jobBerufsbezeichnung,
      "jobGehalt": jobGehalt,
      "jobArbeitsort": jobArbeitsort,
      "jobErfahrung": jobErfahrung,
      "jobBeschaeftigungsart": jobBeschaeftigungsart,
      "jobHomeoffice": jobHomeoffice,
      "jobFuehrerschein": jobFuehrerschein,

      "dienstleistungEinsatzgebiet": dienstleistungEinsatzgebiet,
      "dienstleistungPreisProStunde": dienstleistungPreisProStunde,
      "dienstleistungOeffnungszeiten": dienstleistungOeffnungszeiten,
      "dienstleistungAnfahrt": dienstleistungAnfahrt,
      "dienstleistungNotdienst": dienstleistungNotdienst,

      "mietpreisTag": mietpreisTag,
      "mietpreisWoche": mietpreisWoche,
      "mietpreisMonat": mietpreisMonat,
      "mindestmietdauer": mindestmietdauer,
      "versicherung": versicherung,
      "lieferungMoeglich": lieferungMoeglich,

      "bootMarke": bootMarke,
      "bootModell": bootModell,
      "bootBaujahr": bootBaujahr,
      "bootLaenge": bootLaenge,
      "bootLeistung": bootLeistung,
      "bootstyp": bootstyp,

      "baumaschinenZustand": baumaschinenZustand,
      "baumaschinenBaujahr": baumaschinenBaujahr,
      "baumaschinenBetriebsstunden": baumaschinenBetriebsstunden,
      "baumaschinenKraftstoff": baumaschinenKraftstoff,
      "baumaschinenLeistung": baumaschinenLeistung,
      "baumaschinenGewicht": baumaschinenGewicht,

      "baumarktHersteller": baumarktHersteller,
      "baumarktMaterial": baumarktMaterial,
      "baumarktFarbe": baumarktFarbe,
      "baumarktMasse": baumarktMasse,
      "baumarktGewicht": baumarktGewicht,
      "baumarktMenge": baumarktMenge,
    };
  }

  factory Produkt.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Produkt(
      id: doc.id,
      titel: data["titel"] ?? "",
      preis: data["preis"] ?? "",
      ort: data["ort"] ?? "",
      adresse: data["adresse"] ?? "",
      kategorie: data["kategorie"] ?? "",
      unterkategorie: data["unterkategorie"] ?? "",
      detailUnterkategorie: data["detailUnterkategorie"] ?? "",
      typ: data["typ"] ?? "Privat",
      beschreibung: data["beschreibung"] ?? "",
      icon: Icons.shopping_bag,
      bild: data["bild"] ?? "",
      bilder: List<String>.from(data["bilder"] ?? []),
      favorit: data["favorit"] ?? false,
      verkaeuferId: data["verkaeuferId"] ?? "",
      verkaeuferEmail: data["verkaeuferEmail"] ?? "",
      telefon: data["telefon"] ?? "",
      firmenname: data["firmenname"] ?? "",
      webseite: data["webseite"] ?? "",
      firmaVerifiziert: data["firmaVerifiziert"] ?? false,
      telefonSichtbar: data["telefonSichtbar"] ?? false,
      whatsappAktiv: data["whatsappAktiv"] ?? false,
      emailSichtbar: data["emailSichtbar"] ?? false,
      latitude: (data["latitude"] ?? 48.2082).toDouble(),
      longitude: (data["longitude"] ?? 16.3738).toDouble(),

      marke: data["marke"] ?? "",
      modell: data["modell"] ?? "",
      baujahr: data["baujahr"] ?? "",
      kilometer: data["kilometer"] ?? "",
      kraftstoff: data["kraftstoff"] ?? "",
      getriebe: data["getriebe"] ?? "",
      leistung: data["leistung"] ?? "",
      farbe: data["farbe"] ?? "",
      karosserie: data["karosserie"] ?? "",
      erstzulassung: data["erstzulassung"] ?? "",
      vorbesitzer: data["vorbesitzer"] ?? "",
      antrieb: data["antrieb"] ?? "",
      tuev: data["tuev"] ?? "",
       unfallfrei: data["unfallfrei"] ?? data["autoUnfallfrei"] ?? "",
      tueren: data["tueren"] ?? data["autoTueren"] ?? "",
      sitze: data["sitze"] ?? data["autoSitze"] ?? "",
      serviceheft: data["serviceheft"] ?? data["autoServicegepflegt"] ?? "",
      nichtraucher: data["nichtraucher"] ?? "",
      mwstAusweisbar: data["mwstAusweisbar"] ?? "",
      hubraum: data["hubraum"] ?? "",
      verbrauch: data["verbrauch"] ?? "",
      co2: data["co2"] ?? "",
      schluessel: data["schluessel"] ?? "",
      pickerlNeu: data["pickerlNeu"] ?? "",
      leasingMoeglich: data["leasingMoeglich"] ?? "",
      finanzierungMoeglich: data["finanzierungMoeglich"] ?? "",
      inzahlungnahmeMoeglich:
          data["inzahlungnahmeMoeglich"] ?? data["autoInzahlungnahme"] ?? "",

      immobilienArt: data["immobilienArt"] ?? "",
      wohnflaeche: data["wohnflaeche"] ?? "",
      zimmer: data["zimmer"] ?? "",
      etage: data["etage"] ?? data["immobilienEtage"] ?? "",
      kaution: data["kaution"] ?? data["vermietungKaution"] ?? "",
      betriebskosten: data["betriebskosten"] ?? "",
      balkon: data["balkon"] ?? data["immobilienBalkon"] ?? "",
      terrasse: data["terrasse"] ?? "",
      garten: data["garten"] ?? "",
      garage: data["garage"] ?? data["immobilienGarage"] ?? "",
      lift: data["lift"] ?? "",
      keller: data["keller"] ?? "",
      moebliert: data["moebliert"] ?? data["immobilienMoebliert"] ?? "",
      energieklasse: data["energieklasse"] ?? "",
      heizung: data["heizung"] ?? data["immobilienHeizung"] ?? "",
      baujahrImmobilie: data["baujahrImmobilie"] ?? "",
      verfuegbarAb: data["verfuegbarAb"] ?? data["immobilienVerfuegbarAb"] ?? "",

      zustand: data["zustand"] ?? "",
      hersteller: data["hersteller"] ?? "",
      garantie: data["garantie"] ?? "",

      jobBerufsbezeichnung: data["jobBerufsbezeichnung"] ?? "",
      jobGehalt: data["jobGehalt"] ?? "",
      jobArbeitsort: data["jobArbeitsort"] ?? "",
      jobErfahrung: data["jobErfahrung"] ?? "",
      jobBeschaeftigungsart: data["jobBeschaeftigungsart"] ?? "",
      jobHomeoffice: data["jobHomeoffice"] ?? "",
      jobFuehrerschein: data["jobFuehrerschein"] ?? "",

      dienstleistungEinsatzgebiet: data["dienstleistungEinsatzgebiet"] ?? "",
      dienstleistungPreisProStunde: data["dienstleistungPreisProStunde"] ?? "",
      dienstleistungOeffnungszeiten: data["dienstleistungOeffnungszeiten"] ?? "",
      dienstleistungAnfahrt: data["dienstleistungAnfahrt"] ?? "",
      dienstleistungNotdienst: data["dienstleistungNotdienst"] ?? "",

      mietpreisTag:
          data["mietpreisTag"] ?? data["vermietungTagespreis"] ?? "",
      mietpreisWoche:
          data["mietpreisWoche"] ?? data["vermietungWochenpreis"] ?? "",
      mietpreisMonat:
          data["mietpreisMonat"] ?? data["vermietungMonatspreis"] ?? "",
      mindestmietdauer:
          data["mindestmietdauer"] ?? data["vermietungMindestmietdauer"] ?? "",
      versicherung:
          data["versicherung"] ?? data["vermietungVersicherungInklusive"] ?? "",
      lieferungMoeglich:
          data["lieferungMoeglich"] ?? data["vermietungLieferungMoeglich"] ?? "",

      bootMarke: data["bootMarke"] ?? "",
      bootModell: data["bootModell"] ?? "",
      bootBaujahr: data["bootBaujahr"] ?? "",
      bootLaenge: data["bootLaenge"] ?? "",
      bootLeistung: data["bootLeistung"] ?? "",
      bootstyp: data["bootstyp"] ?? "",

      baumaschinenZustand: data["baumaschinenZustand"] ?? "",
      baumaschinenBaujahr: data["baumaschinenBaujahr"] ?? "",
      baumaschinenBetriebsstunden:
          data["baumaschinenBetriebsstunden"] ?? "",
      baumaschinenKraftstoff: data["baumaschinenKraftstoff"] ?? "",
      baumaschinenLeistung: data["baumaschinenLeistung"] ?? "",
      baumaschinenGewicht: data["baumaschinenGewicht"] ?? "",

      baumarktHersteller: data["baumarktHersteller"] ?? "",
      baumarktMaterial: data["baumarktMaterial"] ?? "",
      baumarktFarbe: data["baumarktFarbe"] ?? "",
      baumarktMasse: data["baumarktMasse"] ?? "",
      baumarktGewicht: data["baumarktGewicht"] ?? "",
      baumarktMenge: data["baumarktMenge"] ?? "",
    );
  }
}
