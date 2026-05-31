import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Produkt {
  String id;

  String titel;
  String preis;
  String ort;
  String adresse;
  String kategorie;
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

  bool telefonSichtbar;
  bool whatsappAktiv;
  bool emailSichtbar;

  double latitude;
  double longitude;

  // AUTOS
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

  // IMMOBILIEN
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

  // PRODUKTE
  String zustand;
  String hersteller;
  String garantie;

  Produkt({
    this.id = "",
    required this.titel,
    required this.preis,
    required this.ort,
    this.adresse = "",
    required this.kategorie,
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
    this.telefonSichtbar = false,
    this.whatsappAktiv = false,
    this.emailSichtbar = false,
    this.latitude = 48.2082,
    this.longitude = 16.3738,

    // AUTOS
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

    // IMMOBILIEN
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

    // PRODUKTE
    this.zustand = "",
    this.hersteller = "",
    this.garantie = "",
  });

  Map<String, dynamic> toMap() {
    return {
      "titel": titel,
      "preis": preis,
      "ort": ort,
      "adresse": adresse,
      "kategorie": kategorie,
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
      "telefonSichtbar": telefonSichtbar,
      "whatsappAktiv": whatsappAktiv,
      "emailSichtbar": emailSichtbar,
      "latitude": latitude,
      "longitude": longitude,

      // AUTOS
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

      // IMMOBILIEN
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

      // PRODUKTE
      "zustand": zustand,
      "hersteller": hersteller,
      "garantie": garantie,
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
      telefonSichtbar: data["telefonSichtbar"] ?? false,
      whatsappAktiv: data["whatsappAktiv"] ?? false,
      emailSichtbar: data["emailSichtbar"] ?? false,
      latitude: (data["latitude"] ?? 48.2082).toDouble(),
      longitude: (data["longitude"] ?? 16.3738).toDouble(),

      // AUTOS
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
      unfallfrei: data["unfallfrei"] ?? "",
      tueren: data["tueren"] ?? "",
      sitze: data["sitze"] ?? "",
      serviceheft: data["serviceheft"] ?? "",
      nichtraucher: data["nichtraucher"] ?? "",
      mwstAusweisbar: data["mwstAusweisbar"] ?? "",
      hubraum: data["hubraum"] ?? "",
      verbrauch: data["verbrauch"] ?? "",
      co2: data["co2"] ?? "",
      schluessel: data["schluessel"] ?? "",
      pickerlNeu: data["pickerlNeu"] ?? "",
      leasingMoeglich: data["leasingMoeglich"] ?? "",
      finanzierungMoeglich: data["finanzierungMoeglich"] ?? "",
      inzahlungnahmeMoeglich: data["inzahlungnahmeMoeglich"] ?? "",

      // IMMOBILIEN
      immobilienArt: data["immobilienArt"] ?? "",
      wohnflaeche: data["wohnflaeche"] ?? "",
      zimmer: data["zimmer"] ?? "",
      etage: data["etage"] ?? "",
      kaution: data["kaution"] ?? "",
      betriebskosten: data["betriebskosten"] ?? "",
      balkon: data["balkon"] ?? "",
      terrasse: data["terrasse"] ?? "",
      garten: data["garten"] ?? "",
      garage: data["garage"] ?? "",
      lift: data["lift"] ?? "",
      keller: data["keller"] ?? "",
      moebliert: data["moebliert"] ?? "",
      energieklasse: data["energieklasse"] ?? "",
      heizung: data["heizung"] ?? "",
      baujahrImmobilie: data["baujahrImmobilie"] ?? "",
      verfuegbarAb: data["verfuegbarAb"] ?? "",

      // PRODUKTE
      zustand: data["zustand"] ?? "",
      hersteller: data["hersteller"] ?? "",
      garantie: data["garantie"] ?? "",
    );
  }
}