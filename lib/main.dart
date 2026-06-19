import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
import 'seiten/splash_seite.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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
      home: const SplashSeite(naechsteSeite: AuthPruefungSeite()),
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

        // Gastmodus und Login sauber getrennt:
        // - Kein Nutzer: App darf trotzdem geöffnet und angesehen werden.
        // - Nutzer angemeldet: App bleibt geöffnet.
        // - E-Mail-Verifizierung wird nur bei geschützten Aktionen verlangt
        //   (Inserat, Favoriten, News, Profil), nicht jedes Mal beim App-Start.
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
    } catch (_) {}
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

class _HandelsweltHomeState extends State<HandelsweltHome>
    with WidgetsBindingObserver {
  int aktuelleSeite = 0;

  bool firmenkonto = false;
  int ungeleseneFavoriten = 0;

  StreamSubscription<RemoteMessage>? _pushForegroundSubscription;
  StreamSubscription<RemoteMessage>? _pushOpenedSubscription;
  StreamSubscription<String>? _pushTokenSubscription;
  StreamSubscription<QuerySnapshot>? _inserateSubscription;

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
    WidgetsBinding.instance.addObserver(this);
    _inserateEchtzeitLaden();
    _onlineStatusSetzen(true);
    _pushBenachrichtigungenVorbereiten();
  }

  @override
  void dispose() {
    _onlineStatusSetzen(false);
    WidgetsBinding.instance.removeObserver(this);
    _pushForegroundSubscription?.cancel();
    _pushOpenedSubscription?.cancel();
    _pushTokenSubscription?.cancel();
    _inserateSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _onlineStatusSetzen(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _onlineStatusSetzen(false);
    }
  }

  Future<void> _onlineStatusSetzen(bool online) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set(
        {
          "online": online,
          "letzteAktivitaet": FieldValue.serverTimestamp(),
          "aktualisiertAm": FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {}
  }

  Future<void> _pushBenachrichtigungenVorbereiten() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final messaging = FirebaseMessaging.instance;

      final einstellung = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      final pushErlaubt =
          einstellung.authorizationStatus == AuthorizationStatus.authorized ||
              einstellung.authorizationStatus == AuthorizationStatus.provisional;

      final token = await messaging.getToken();

      if (token != null && token.trim().isNotEmpty) {
        await _pushTokenSpeichern(user.uid, token, pushErlaubt);
      } else {
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set(
          {
            "pushAktiviert": pushErlaubt,
            "pushTokenAktualisiertAm": FieldValue.serverTimestamp(),
            "aktualisiertAm": FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      _pushTokenSubscription?.cancel();
      _pushTokenSubscription = messaging.onTokenRefresh.listen((neuerToken) async {
        final aktuellerUser = FirebaseAuth.instance.currentUser;
        if (aktuellerUser == null) return;
        if (neuerToken.trim().isEmpty) return;

        await _pushTokenSpeichern(aktuellerUser.uid, neuerToken, true);
      });

      final startNachricht = await FirebaseMessaging.instance.getInitialMessage();
      if (startNachricht != null) {
        _pushNachrichtOeffnen(startNachricht);
      }

      _pushForegroundSubscription?.cancel();
      _pushForegroundSubscription = FirebaseMessaging.onMessage.listen((message) {
        _pushImVordergrundAnzeigen(message);
      });

      _pushOpenedSubscription?.cancel();
      _pushOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
        (message) {
          _pushNachrichtOeffnen(message);
        },
      );
    } catch (e) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set(
          {
            "pushAktiviert": false,
            "pushFehler": e.toString(),
            "pushTokenAktualisiertAm": FieldValue.serverTimestamp(),
            "aktualisiertAm": FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
      // Push soll Web/Chrome oder die App nicht blockieren, falls noch kein Web-VAPID-Key eingerichtet ist.
    }
  }

  Future<void> _pushTokenSpeichern(
    String userId,
    String token,
    bool pushErlaubt,
  ) async {
    await FirebaseFirestore.instance.collection("users").doc(userId).set(
      {
        "fcmToken": token,
        "fcmTokens": FieldValue.arrayUnion([token]),
        "pushAktiviert": pushErlaubt,
        "pushTokenAktualisiertAm": FieldValue.serverTimestamp(),
        "aktualisiertAm": FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  void _pushImVordergrundAnzeigen(RemoteMessage message) {
    final titel = message.notification?.title ??
        message.data["title"]?.toString() ??
        "Handelswelt";
    final inhalt = message.notification?.body ??
        message.data["body"]?.toString() ??
        "Neue Benachrichtigung";

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$titel: $inhalt"),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: "Öffnen",
          onPressed: () => _pushNachrichtOeffnen(message),
        ),
      ),
    );
  }

  void _pushNachrichtOeffnen(RemoteMessage message) {
    if (!mounted) return;

    final typ = message.data["typ"]?.toString() ??
        message.data["type"]?.toString() ??
        "";

    setState(() {
      if (typ == "chat" || typ == "bewertung" || typ == "admin") {
        aktuelleSeite = 5;
      } else if (typ == "profil" || typ == "firma_verifiziert") {
        aktuelleSeite = 6;
      } else {
        aktuelleSeite = 5;
      }
    });
  }

  void _inserateEchtzeitLaden() {
    final user = FirebaseAuth.instance.currentUser;

    _inserateSubscription?.cancel();
    _inserateSubscription = FirebaseFirestore.instance
        .collection("inserate")
        .snapshots()
        .listen((snapshot) async {
      final geladeneProdukte = snapshot.docs.map((doc) {
        return Produkt.fromFirestore(doc);
      }).toList();

      final Set<String> favoritIds = {};

      if (user != null) {
        try {
          final favoritSnapshot = await FirebaseFirestore.instance
              .collection("favoriten")
              .where("userId", isEqualTo: user.uid)
              .get();

          for (final doc in favoritSnapshot.docs) {
            final daten = doc.data();
            final produktId = (daten["produktId"] ?? "").toString().trim();
            if (produktId.isNotEmpty) favoritIds.add(produktId);
          }
        } catch (_) {}
      }

      for (final produkt in geladeneProdukte) {
        produkt.favorit = favoritIds.contains(_favoritProduktId(produkt));
      }

      if (!mounted) return;

      setState(() {
        produkte = geladeneProdukte;
      });
    });
  }

  void produktHinzufuegen(Produkt produkt) {
    setState(() {
      produkte.insert(0, produkt);
      aktuelleSeite = 0;
    });
  }

  String _favoritProduktId(Produkt produkt) {
    final echteId = produkt.id.trim();

    if (echteId.isNotEmpty) {
      return echteId;
    }

    final basis = [
      produkt.titel,
      produkt.preis,
      produkt.ort,
      produkt.verkaeuferId,
      produkt.verkaeuferEmail,
      produkt.bild,
    ].join("_");

    return "lokal_${basis.hashCode.abs()}";
  }

  Future<void> favoritWechseln(Produkt produkt) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bitte registrieren oder anmelden, um Favoriten zu speichern."),
          backgroundColor: Color(0xff5b2cff),
        ),
      );
      return;
    }

    final produktId = _favoritProduktId(produkt);
    final docId = "${user.uid}_$produktId";
    final favRef = FirebaseFirestore.instance.collection("favoriten").doc(docId);

    try {
      if (produkt.favorit) {
        await favRef.delete();

        if (!mounted) return;

        setState(() {
          produkt.favorit = false;
        });
      } else {
        await favRef.set({
          "userId": user.uid,
          "userEmail": user.email ?? "",
          "produktId": produktId,
          "echteProduktId": produkt.id.trim(),
          "lokalerFavorit": produkt.id.trim().isEmpty,
          "produktTitel": produkt.titel,
          "produktBild": produkt.bild,
          "produktPreis": produkt.preis,
          "produktOrt": produkt.ort,
          "produktKategorie": produkt.kategorie,
          "produktUnterkategorie": produkt.unterkategorie,
          "produktDetailUnterkategorie": produkt.detailUnterkategorie,
          "verkaeuferId": produkt.verkaeuferId,
          "verkaeuferEmail": produkt.verkaeuferEmail,
          "firmaVerifiziert": produkt.firmaVerifiziert,
          "erstelltAm": FieldValue.serverTimestamp(),
          "gespeichertAm": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (!mounted) return;

        setState(() {
          produkt.favorit = true;
          if (aktuelleSeite != 4) {
            ungeleseneFavoriten++;
          }
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Favorit konnte nicht gespeichert werden: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void kontoWechseln() {
    setState(() {
      firmenkonto = !firmenkonto;
    });
  }

  bool _istEingeloggtUndVerifiziert() {
    final user = FirebaseAuth.instance.currentUser;
    return user != null && user.emailVerified;
  }

  void _loginErforderlich(String aktion) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const EmailVerifizierenSeite(),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Bitte registrieren oder anmelden, um $aktion zu nutzen.",
        ),
        backgroundColor: const Color(0xff5b2cff),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginSeite(),
      ),
    );
  }

  void _geschuetzteSeiteOeffnen(int index, String aktion) {
    if (!_istEingeloggtUndVerifiziert()) {
      _loginErforderlich(aktion);
      return;
    }

    setState(() {
      aktuelleSeite = index;

      if (index == 4) {
        ungeleseneFavoriten = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final seiten = [
      StartSeite(
        produkte: produkte,
        favoritWechseln: favoritWechseln,
        zuInserat: () {
          _geschuetzteSeiteOeffnen(3, "Inserate zu erstellen");
        },
      ),
      KategorienSeite(
        produkte: produkte,
      ),
      const KarteSeite(),
      InseratSeite(
        onSpeichern: produktHinzufuegen,
      ),
      const FavoritenSeite(
        favoriten: [],
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
          if (index == 3) {
            _geschuetzteSeiteOeffnen(index, "Inserate zu erstellen");
            return;
          }

          if (index == 4) {
            _geschuetzteSeiteOeffnen(index, "Favoriten zu speichern");
            return;
          }

          if (index == 5) {
            _geschuetzteSeiteOeffnen(index, "Nachrichten und Benachrichtigungen");
            return;
          }

          if (index == 6) {
            _geschuetzteSeiteOeffnen(index, "dein Profil");
            return;
          }

          setState(() {
            aktuelleSeite = index;
          });
          if (index == 0) _inserateEchtzeitLaden();
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Start",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: "Kategorien",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: "Karte",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: "Inserat",
          ),
          BottomNavigationBarItem(
            icon: _favoritenIcon(),
            label: "Favoriten",
          ),
          BottomNavigationBarItem(
            icon: _benachrichtigungsIcon(),
            activeIcon: const Icon(Icons.newspaper),
            label: "News",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
  }


  Widget _favoritenIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.favorite),
        if (ungeleseneFavoriten > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 17,
                minHeight: 17,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 1,
              ),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  ungeleseneFavoriten > 99 ? "99+" : "$ungeleseneFavoriten",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _benachrichtigungsIcon() {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? "";

    if (userId.isEmpty) {
      return const Icon(Icons.newspaper_outlined);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("chats")
          .where(
            "ungelesenFuer",
            isEqualTo: userId,
          )
          .snapshots(),
      builder: (context, chatSnapshot) {
        final chatAnzahl = chatSnapshot.data?.docs.length ?? 0;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("benachrichtigungen")
              .where("userId", isEqualTo: userId)
              .where("gelesen", isEqualTo: false)
              .snapshots(),
          builder: (context, benachrichtigungSnapshot) {
            final normaleAnzahl = benachrichtigungSnapshot.data?.docs.length ?? 0;
            final anzahl = chatAnzahl + normaleAnzahl;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.newspaper_outlined),
                if (anzahl > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 17,
                        minHeight: 17,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          anzahl > 99 ? "99+" : "$anzahl",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
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
}