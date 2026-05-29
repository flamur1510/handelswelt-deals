import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'model/produkt.dart';
import 'demo_produkte.dart';

import 'seiten/start_seite.dart';
import 'seiten/kategorien_seite.dart';
import 'seiten/karte_seite.dart';
import 'seiten/inserat_seite.dart';
import 'seiten/favoriten_seite.dart';
import 'seiten/benachrichtigungen_seite.dart';
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

  List<Produkt> produkte =
      List.from(demoProdukte);

  void produktHinzufuegen(
      Produkt produkt) {

    setState(() {

      produkte.insert(0, produkt);

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

  @override
  Widget build(BuildContext context) {

    final favoriten =
        produkte
            .where((produkt) =>
                produkt.favorit)
            .toList();

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
        favoriten: favoriten,
      ),

      const BenachrichtigungenSeite(),

      ProfilSeite(
        produkte: produkte,
      ),
    ];

    return MaterialApp(

      debugShowCheckedModeBanner:
          false,

      theme: ThemeData(
        primarySwatch:
            Colors.deepPurple,

        scaffoldBackgroundColor:
            const Color(0xfff6f3ff),
      ),

      home: Scaffold(

        body:
            seiten[aktuelleSeite],

        bottomNavigationBar:
            NavigationBar(

          selectedIndex:
              aktuelleSeite,

          onDestinationSelected:
              (index) {

            setState(() {

              aktuelleSeite =
                  index;
            });
          },

          destinations: const [

            NavigationDestination(
              icon: Icon(Icons.home),
              label: "Start",
            ),

            NavigationDestination(
              icon:
                  Icon(Icons.category),
              label: "Kategorien",
            ),

            NavigationDestination(
              icon: Icon(Icons.map),
              label: "Karte",
            ),

            NavigationDestination(
              icon:
                  Icon(Icons.add_box),
              label: "Inserat",
            ),

            NavigationDestination(
              icon:
                  Icon(Icons.favorite),
              label: "Favoriten",
            ),

            NavigationDestination(
              icon:
                  Icon(Icons.notifications),
              label: "News",
            ),

            NavigationDestination(
              icon:
                  Icon(Icons.person),
              label: "Profil",
            ),
          ],
        ),
      ),
    );
  }
}