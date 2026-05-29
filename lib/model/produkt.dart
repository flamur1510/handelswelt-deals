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

  // IMMOBILIEN
  String wohnflaeche;
  String zimmer;
  String etage;
  String kaution;
  String betriebskosten;

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

    // IMMOBILIEN
    this.wohnflaeche = "",
    this.zimmer = "",
    this.etage = "",
    this.kaution = "",
    this.betriebskosten = "",

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

      // IMMOBILIEN
      "wohnflaeche": wohnflaeche,
      "zimmer": zimmer,
      "etage": etage,
      "kaution": kaution,
      "betriebskosten": betriebskosten,

      // PRODUKTE
      "zustand": zustand,
      "hersteller": hersteller,
      "garantie": garantie,
    };
  }

  factory Produkt.fromFirestore(
    DocumentSnapshot doc,
  ) {
    final data =
        doc.data() as Map<String, dynamic>;

    return Produkt(
      id: doc.id,

      titel: data["titel"] ?? "",
      preis: data["preis"] ?? "",

      ort: data["ort"] ?? "",
      adresse: data["adresse"] ?? "",

      kategorie:
          data["kategorie"] ?? "",

      typ: data["typ"] ?? "Privat",

      beschreibung:
          data["beschreibung"] ?? "",

      icon: Icons.shopping_bag,

      bild: data["bild"] ?? "",

      bilder:
          List<String>.from(
        data["bilder"] ?? [],
      ),

      favorit:
          data["favorit"] ?? false,

      verkaeuferId:
          data["verkaeuferId"] ?? "",

      verkaeuferEmail:
          data["verkaeuferEmail"] ?? "",

      latitude:
          (data["latitude"] ?? 48.2082)
              .toDouble(),

      longitude:
          (data["longitude"] ?? 16.3738)
              .toDouble(),

      // AUTOS
      marke: data["marke"] ?? "",
      modell: data["modell"] ?? "",
      baujahr: data["baujahr"] ?? "",
      kilometer:
          data["kilometer"] ?? "",
      kraftstoff:
          data["kraftstoff"] ?? "",
      getriebe:
          data["getriebe"] ?? "",
      leistung:
          data["leistung"] ?? "",

      // IMMOBILIEN
      wohnflaeche:
          data["wohnflaeche"] ?? "",

      zimmer:
          data["zimmer"] ?? "",

      etage:
          data["etage"] ?? "",

      kaution:
          data["kaution"] ?? "",

      betriebskosten:
          data["betriebskosten"] ?? "",

      // PRODUKTE
      zustand:
          data["zustand"] ?? "",

      hersteller:
          data["hersteller"] ?? "",

      garantie:
          data["garantie"] ?? "",
    );
  }
}