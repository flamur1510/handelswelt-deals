import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

import 'model/produkt.dart';

import 'seiten/start_seite.dart';
import 'seiten/kategorien_seite.dart';
import 'seiten/karte_seite.dart';
import 'seiten/inserat_seite.dart';
import 'seiten/favoriten_seite.dart';
import 'screens/news_seite.dart';
import 'seiten/profil_seite.dart';
import 'seiten/login_seite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const HandelsweltApp());
}

class HandelsweltApp extends StatelessWidget {
  const HandelsweltApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xfff6f3ff),
      ),
      home: const AuthPruefungSeite(),
    );
  }
}

class AuthPruefungSeite extends StatelessWidget {
  const AuthPruefungSeite({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xfffafafe),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xff5b2cff),
              ),
            ),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginSeite();
        }

        if (!user.emailVerified) {
          return const EmailVerifizierenSeite();
        }

        return const HandelsweltHome();
      },
    );
  }
}

class EmailVerifizierenSeite extends StatefulWidget {
  const EmailVerifizierenSeite({super.key});

  @override
  State<EmailVerifizierenSeite> createState() =>
      _EmailVerifizierenSeiteState();
}

class _EmailVerifizierenSeiteState extends State<EmailVerifizierenSeite> {
  Timer? timer;
  bool laedt = false;

  @override
  void initState() {
    super.initState();

    // Alle 3 Sekunden automatisch prüfen, ob die E-Mail bestätigt wurde.
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      automatischPruefen();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> mailErneutSenden() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    setState(() {
      laedt = true;
    });

    try {
      await user.sendEmailVerification();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bestätigungs-Mail wurde erneut gesendet."),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Fehler: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        laedt = false;
      });
    }
  }

  Future<void> automatischPruefen() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      await user.reload();

      final aktuellerUser = FirebaseAuth.instance.currentUser;

      if (aktuellerUser != null && aktuellerUser.emailVerified) {
        timer?.cancel();

        await FirebaseFirestore.instance
            .collection("users")
            .doc(aktuellerUser.uid)
            .set({
          "emailVerifiziert": true,
          "emailVerifiziertAm": FieldValue.serverTimestamp(),
          "aktualisiertAm": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const HandelsweltHome(),
          ),
          (route) => false,
        );
      }
    } catch (_) {
      // Falls kurz kein Internet da ist, wird beim nächsten Timer erneut geprüft.
    }
  }

  Future<void> abmelden() async {
    timer?.cancel();
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? "";

    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      appBar: AppBar(
        backgroundColor: const Color(0xff050b2c),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "E-Mail bestätigen",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: const Color(0xffececf4),
              ),
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
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: Color(0xfff1edff),
                  child: Icon(
                    Icons.mark_email_unread_outlined,
                    color: Color(0xff5b2cff),
                    size: 42,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Bitte bestätige deine E-Mail-Adresse",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xff050b2c),
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  email.isEmpty
                      ? "Wir haben dir einen Bestätigungslink gesendet."
                      : "Wir haben einen Bestätigungslink an $email gesendet.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xff74788d),
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xfff1edff),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Color(0xff5b2cff),
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Sobald du den Link in deiner E-Mail bestätigst, wirst du automatisch weitergeleitet.",
                          style: TextStyle(
                            color: Color(0xff050b2c),
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: laedt ? null : mailErneutSenden,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xff5b2cff),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: laedt
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              color: Color(0xff5b2cff),
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.refresh,
                            color: Color(0xff5b2cff),
                          ),
                    label: const Text(
                      "E-Mail erneut senden",
                      style: TextStyle(
                        color: Color(0xff5b2cff),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: laedt ? null : abmelden,
                  child: const Text(
                    "Abmelden",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HandelsweltHome extends StatefulWidget {
  const HandelsweltHome({super.key});

  @override
  State<HandelsweltHome> createState() => _HandelsweltHomeState();
}

class _HandelsweltHomeState extends State<HandelsweltHome> {
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
      beschreibung: "Sehr guter Zustand.",
      icon: Icons.phone_iphone,
      bild: "https://images.unsplash.com/photo-1592750475338-74b7b21085ab",
      bilder: [
        "https://images.unsplash.com/photo-1592750475338-74b7b21085ab",
      ],
      verkaeuferId: "demo1",
      verkaeuferEmail: "max@test.at",
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
      beschreibung: "Service gepflegt.",
      icon: Icons.directions_car,
      bild: "https://images.unsplash.com/photo-1555215695-3004980ad54e",
      bilder: [
        "https://images.unsplash.com/photo-1555215695-3004980ad54e",
      ],
      verkaeuferId: "demo2",
      verkaeuferEmail: "bmw@test.at",
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
    final snapshot = await FirebaseFirestore.instance
        .collection("inserate")
        .get();

    final geladeneProdukte = snapshot.docs.map((doc) {
      return Produkt.fromFirestore(doc);
    }).toList();

    if (!mounted) return;

    setState(() {
      produkte = [
        ...geladeneProdukte,
        ...produkte,
      ];
    });
  }

  void produktHinzufuegen(Produkt produkt) {
    setState(() {
      produkte.insert(0, produkt);
      aktuelleSeite = 0;
    });
  }

  void favoritWechseln(Produkt produkt) {
    setState(() {
      produkt.favorit = !produkt.favorit;
    });
  }

  void kontoWechseln() {
    setState(() {
      firmenkonto = !firmenkonto;
    });
  }

  @override
  Widget build(BuildContext context) {
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
      const NewsSeite(),
      ProfilSeite(
        produkte: produkte,
      ),
    ];

    return Scaffold(
      body: seiten[aktuelleSeite],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: aktuelleSeite,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            aktuelleSeite = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Start",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: "Kategorien",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Karte",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: "Inserat",
          ),
          BottomNavigationBarItem(
            icon: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("chats")
                  .where(
                    "ungelesenFuer",
                    isEqualTo:
                        FirebaseAuth.instance.currentUser?.uid ?? "",
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                final anzahl = snapshot.data?.docs.length ?? 0;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications),
                    if (anzahl > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: "News",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}
