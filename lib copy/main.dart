import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

import 'model/produkt.dart';

import 'seiten/start_seite.dart';
import 'seiten/kategorien_seite.dart';
import 'seiten/karte_seite.dart';
import 'seiten/inserat_seite.dart';
import 'seiten/favoriten_seite.dart';
import 'seiten/profil_seite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const HandelsweltApp());
}

class HandelsweltApp extends StatefulWidget {
  const HandelsweltApp({super.key});

  @override
  State<HandelsweltApp> createState() =>
      _HandelsweltAppState();
}

class _HandelsweltAppState
    extends State<HandelsweltApp> {

  int aktuelleSeite = 0;

  bool firmenkonto = false;

  List<Produkt> produkte = [

    Produkt(
      titel: "iPhone 14 Pro",
      preis: "650 €",
      ort: "Wien",
      adresse: "Mariahilfer Straße Wien",
      kategorie: "Elektronik",
      typ: "Privat",
      beschreibung:
          "Sehr guter Zustand.",

      icon:
          Icons.phone_iphone,

      bild:
          "https://images.unsplash.com/photo-1592750475338-74b7b21085ab",

      bilder: [
        "https://images.unsplash.com/photo-1592750475338-74b7b21085ab",
      ],

      verkaeuferId: "demo1",

      verkaeuferEmail:
          "max@test.at",

      latitude: 48.2082,
      longitude: 16.3738,
    ),

    Produkt(
      titel: "BMW 320d",
      preis: "18.900 €",
      ort: "Graz",
      adresse: "Graz Zentrum",
      kategorie: "Autos",
      typ: "Firma",
      beschreibung:
          "Service gepflegt.",

      icon:
          Icons.directions_car,

      bild:
          "https://images.unsplash.com/photo-1555215695-3004980ad54e",

      bilder: [
        "https://images.unsplash.com/photo-1555215695-3004980ad54e",
      ],

      verkaeuferId: "demo2",

      verkaeuferEmail:
          "bmw@test.at",

      latitude: 47.0707,
      longitude: 15.4395,

      marke: "BMW",
      modell: "320d",
      baujahr: "2019",
      kilometer: "98000",
    ),
  ];

  @override
  void initState() {
    super.initState();

    produkteLaden();
  }

  Future<void> produkteLaden() async {

    final snapshot =
        await FirebaseFirestore
            .instance
            .collection("inserate")
            .get();

    final geladeneProdukte =
        snapshot.docs.map((doc) {

      return Produkt
          .fromFirestore(doc);

    }).toList();

    setState(() {

      produkte = [
        ...geladeneProdukte,
        ...produkte,
      ];
    });
  }

  void produktHinzufuegen(
      Produkt produkt) {

    setState(() {

      produkte.insert(
        0,
        produkt,
      );

      aktuelleSeite = 0;
    });
  }

  void favoritWechseln(
      Produkt produkt) {

    setState(() {

      produkt.favorit =
          !produkt.favorit;
    });
  }

  void kontoWechseln() {

    setState(() {

      firmenkonto =
          !firmenkonto;
    });
  }

  @override
  Widget build(
      BuildContext context) {

    final seiten = [

      StartSeite(
        produkte: produkte,

        favoritWechseln:
            favoritWechseln,
      ),

      KategorienSeite(
        produkte: produkte,
      ),

      const KarteSeite(),

      InseratSeite(
        onSpeichern:
            produktHinzufuegen,
      ),

      FavoritenSeite(
        favoriten: produkte
            .where(
              (produkt) =>
                  produkt.favorit,
            )
            .toList(),
      ),

      ProfilSeite(
        firmenkonto:
            firmenkonto,

        kontoWechseln:
            kontoWechseln,
      ),
    ];

    return MaterialApp(

      debugShowCheckedModeBanner:
          false,

      theme: ThemeData(
        primarySwatch:
            Colors.deepPurple,

        scaffoldBackgroundColor:
            const Color(
                0xfff6f3ff),
      ),

      home: Scaffold(

        body:
            seiten[
                aktuelleSeite],

        bottomNavigationBar:
            BottomNavigationBar(

          currentIndex:
              aktuelleSeite,

          selectedItemColor:
              Colors.deepPurple,

          unselectedItemColor:
              Colors.grey,

          type:
              BottomNavigationBarType
                  .fixed,

          onTap: (index) {

            setState(() {

              aktuelleSeite =
                  index;
            });
          },

          items: const [

            BottomNavigationBarItem(
              icon:
                  Icon(Icons.home),

              label:
                  "Start",
            ),

            BottomNavigationBarItem(
              icon:
                  Icon(Icons.category),

              label:
                  "Kategorien",
            ),

            BottomNavigationBarItem(
              icon:
                  Icon(Icons.map),

              label:
                  "Karte",
            ),

            BottomNavigationBarItem(
              icon:
                  Icon(Icons.add_box),

              label:
                  "Inserat",
            ),

            BottomNavigationBarItem(
              icon:
                  Icon(Icons.favorite),

              label:
                  "Favoriten",
            ),

            BottomNavigationBarItem(
              icon:
                  Icon(Icons.person),

              label:
                  "Profil",
            ),
          ],
        ),
      ),
    );
  }
}