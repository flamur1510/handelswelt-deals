import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'model/produkt.dart';

import 'seiten/start_seite.dart';
import 'seiten/kategorien_seite.dart';
import 'seiten/karte_seite.dart';
import 'seiten/inserat_seite.dart';
import 'seiten/favoriten_seite.dart';
import 'seiten/benachrichtigungen_seite.dart';
import 'seiten/profil_seite.dart';
import 'seiten/login_seite.dart';

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
  State<HandelsweltApp> createState() => _HandelsweltAppState();
}

class _HandelsweltAppState extends State<HandelsweltApp> {
  int aktuelleSeite = 0;

  void produktHinzufuegen(Produkt produkt) {
    setState(() {
      aktuelleSeite = 0;
    });
  }

  Future<void> favoritWechseln(Produkt produkt) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;
    if (produkt.id.isEmpty) return;

    final favId = "${user.uid}_${produkt.id}";
    final favRef =
        FirebaseFirestore.instance.collection("favoriten").doc(favId);

    if (produkt.favorit) {
      await favRef.delete();
    } else {
      await favRef.set({
        "userId": user.uid,
        "userEmail": user.email ?? "",
        "produktId": produkt.id,
        "produktTitel": produkt.titel,
        "produktBild": produkt.bild,
        "produktPreis": produkt.preis,
        "produktOrt": produkt.ort,
        "verkaeuferId": produkt.verkaeuferId,
        "verkaeuferEmail": produkt.verkaeuferEmail,
        "erstelltAm": FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnapshot) {
        final user = userSnapshot.data;

        if (user == null) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: LoginSeite(),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("inserate").snapshots(),
          builder: (context, inserateSnapshot) {
            final produkte = inserateSnapshot.hasData
                ? inserateSnapshot.data!.docs
                    .map((doc) => Produkt.fromFirestore(doc))
                    .toList()
                : <Produkt>[];

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("favoriten")
                  .where("userId", isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, favSnapshot) {
                final favoritIds = favSnapshot.hasData
                    ? favSnapshot.data!.docs
                        .map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return data["produktId"]?.toString() ?? "";
                        })
                        .where((id) => id.isNotEmpty)
                        .toSet()
                    : <String>{};

                for (final produkt in produkte) {
                  produkt.favorit = favoritIds.contains(produkt.id);
                }

                final favoriten =
                    produkte.where((produkt) => produkt.favorit).toList();

                return _app(produkte, favoriten);
              },
            );
          },
        );
      },
    );
  }

  Widget _app(List<Produkt> produkte, List<Produkt> favoriten) {
    final seiten = [
      StartSeite(
        produkte: produkte,
        favoritWechseln: favoritWechseln,
        zuInserat: () {
          setState(() {
            aktuelleSeite = 3;
          });
        },
      ),
      KategorienSeite(
        produkte: produkte,
      ),
      const KarteSeite(),
      InseratSeite(
        onSpeichern: produktHinzufuegen,
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
      debugShowCheckedModeBanner: false,
      title: "Handelswelt Deals",
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xfffafafe),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff5b2cff),
        ),
      ),
      home: Scaffold(
        body: seiten[aktuelleSeite],
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Color(0xffececf4),
              ),
            ),
          ),
          child: NavigationBar(
            height: 64,
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xfff1edff),
            selectedIndex: aktuelleSeite,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) {
              setState(() {
                aktuelleSeite = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, size: 22),
                selectedIcon: Icon(
                  Icons.home,
                  color: Color(0xff5b2cff),
                  size: 22,
                ),
                label: "Start",
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined, size: 22),
                selectedIcon: Icon(
                  Icons.grid_view_rounded,
                  color: Color(0xff5b2cff),
                  size: 22,
                ),
                label: "Kategorien",
              ),
              NavigationDestination(
                icon: Icon(Icons.map_outlined, size: 22),
                selectedIcon: Icon(
                  Icons.map,
                  color: Color(0xff5b2cff),
                  size: 22,
                ),
                label: "Karte",
              ),
              NavigationDestination(
                icon: Icon(Icons.add_box_outlined, size: 22),
                selectedIcon: Icon(
                  Icons.add_box,
                  color: Color(0xff5b2cff),
                  size: 22,
                ),
                label: "Inserat",
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_border, size: 22),
                selectedIcon: Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 22,
                ),
                label: "Favoriten",
              ),
              NavigationDestination(
                icon: Icon(Icons.notifications_none, size: 22),
                selectedIcon: Icon(
                  Icons.notifications,
                  color: Color(0xff5b2cff),
                  size: 22,
                ),
                label: "News",
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline, size: 22),
                selectedIcon: Icon(
                  Icons.person,
                  color: Color(0xff5b2cff),
                  size: 22,
                ),
                label: "Profil",
              ),
            ],
          ),
        ),
      ),
    );
  }
}