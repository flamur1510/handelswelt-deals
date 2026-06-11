import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/produkt.dart';
import '../seiten/detail_seite.dart';
import 'chat_seite.dart';

class BenachrichtigungenSeite extends StatefulWidget {
  const BenachrichtigungenSeite({super.key});

  @override
  State<BenachrichtigungenSeite> createState() =>
      _BenachrichtigungenSeiteState();
}

class _BenachrichtigungenSeiteState extends State<BenachrichtigungenSeite> {
  String suche = "";
  String chatFilter = "Alle";

  bool allesWirdGelesen = false;
  bool chatsOffen = false;
  bool favoritenOffen = false;

  final sucheController = TextEditingController();

  final List<String> filter = const [
    "Alle",
    "Ungelesen",
  ];

  @override
  void dispose() {
    sucheController.dispose();
    super.dispose();
  }

  String _text(Map<String, dynamic> daten, List<String> keys) {
    for (final key in keys) {
      final value = daten[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return "";
  }

  DateTime? _datum(dynamic wert) {
    if (wert is Timestamp) return wert.toDate();
    return null;
  }

  String _zeitText(dynamic wert) {
    final datum = _datum(wert);
    if (datum == null) return "";

    final jetzt = DateTime.now();
    final heute = DateTime(jetzt.year, jetzt.month, jetzt.day);
    final gestern = heute.subtract(const Duration(days: 1));
    final tag = DateTime(datum.year, datum.month, datum.day);

    final stunde = datum.hour.toString().padLeft(2, "0");
    final minute = datum.minute.toString().padLeft(2, "0");

    if (tag == heute) return "$stunde:$minute";
    if (tag == gestern) return "Gestern";

    final d = datum.day.toString().padLeft(2, "0");
    final m = datum.month.toString().padLeft(2, "0");
    return "$d.$m.${datum.year}";
  }

  String _kategorieAnzeige(String kategorie) {
    if (kategorie == "Autos" ||
        kategorie == "Motorräder" ||
        kategorie == "Motorrad") {
      return "Auto & Motor";
    }
    if (kategorie == "Möbel") return "Haus & Garten";
    if (kategorie == "Freizeit & Hobby") return "Freizeit";
    if (kategorie == "Tierbedarf") return "Tiere";
    return kategorie;
  }

  int _zahl(String text) {
    return int.tryParse(
          text
              .replaceAll("€", "")
              .replaceAll(".", "")
              .replaceAll(",", "")
              .replaceAll("/Tag", "")
              .replaceAll("pro Tag", "")
              .trim(),
        ) ??
        0;
  }

  bool _chatPasstZurSuche(Map<String, dynamic> daten, String userId) {
    final text = suche.trim().toLowerCase();
    if (text.isEmpty) return true;

    final verkaeuferId = _text(daten, ["verkaeuferId"]);
    final kaeuferEmail = _text(daten, ["kaeuferEmail"]);
    final verkaeuferEmail = _text(daten, ["verkaeuferEmail"]);
    final anderesEmail =
        userId == verkaeuferId ? kaeuferEmail : verkaeuferEmail;

    final suchText = [
      _text(daten, ["produktTitel"]),
      _text(daten, ["letzteNachricht"]),
      anderesEmail,
      _text(daten, ["firmenname"]),
      _text(daten, ["verkaeuferName"]),
      _text(daten, ["kaeuferName"]),
    ].join(" ").toLowerCase();

    return suchText.contains(text);
  }

  bool _favoritPasstZurSuche(Map<String, dynamic> daten) {
    final text = suche.trim().toLowerCase();
    if (text.isEmpty) return true;

    final suchText = [
      _text(daten, ["titel"]),
      _text(daten, ["text"]),
      _text(daten, ["produktTitel"]),
      _text(daten, ["produktKategorie"]),
      _text(daten, ["produktPreis"]),
      _text(daten, ["produktOrt"]),
    ].join(" ").toLowerCase();

    return suchText.contains(text);
  }

  Future<void> _chatAlsGelesenMarkieren(
    DocumentReference ref,
    String userId,
  ) async {
    await ref.set(
      {
        "ungelesenFuer": "",
        "gelesenVon": FieldValue.arrayUnion([userId]),
        "gelesenAm": FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> _favoritHinweisGelesen(DocumentReference ref) async {
    await ref.set(
      {
        "gelesen": true,
        "gelesenAm": FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> _favoritHinweisLoeschen(DocumentReference ref) async {
    await ref.delete();
  }

  Future<void> _allesAlsGelesenMarkieren(String userId) async {
    if (allesWirdGelesen) return;

    setState(() {
      allesWirdGelesen = true;
    });

    try {
      final chats = await FirebaseFirestore.instance
          .collection("chats")
          .where("teilnehmer", arrayContains: userId)
          .get();

      final hinweise = await FirebaseFirestore.instance
          .collection("benachrichtigungen")
          .where("userId", isEqualTo: userId)
          .where("gelesen", isEqualTo: false)
          .get();

      final batch = FirebaseFirestore.instance.batch();

      for (final doc in chats.docs) {
        final daten = doc.data();
        final ungelesenFuer = (daten["ungelesenFuer"] ?? "").toString();

        if (ungelesenFuer == userId) {
          batch.set(
            doc.reference,
            {
              "ungelesenFuer": "",
              "gelesenVon": FieldValue.arrayUnion([userId]),
              "gelesenAm": FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        }
      }

      for (final doc in hinweise.docs) {
        final daten = doc.data();
        final typ = (daten["typ"] ?? "").toString().toLowerCase();

        if (typ != "favorit") continue;

        batch.set(
          doc.reference,
          {
            "gelesen": true,
            "gelesenAm": FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      await batch.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Chats und Favoriten wurden als gelesen markiert."),
          backgroundColor: Color(0xff5b2cff),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Fehler beim Markieren: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        allesWirdGelesen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final breit = MediaQuery.of(context).size.width > 900;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xfffafafe),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              breit ? 46 : 16,
              18,
              breit ? 46 : 16,
              24,
            ),
            children: [
              _handelsweltHeader(),
              const SizedBox(height: 18),
              _leer("Bitte einloggen, um deine News zu sehen."),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            breit ? 46 : 16,
            18,
            breit ? 46 : 16,
            24,
          ),
          children: [
            _handelsweltHeader(),
            const SizedBox(height: 14),
            _kopfbereich(user.uid),
            const SizedBox(height: 14),
            _suchfeld(),
            const SizedBox(height: 12),
            _filterLeiste(),
            const SizedBox(height: 12),
            _schnellAktion(user.uid),
            const SizedBox(height: 18),
            _chatListe(user.uid),
            const SizedBox(height: 14),
            _favoritenHinweise(user.uid),
            const SizedBox(height: 18),
            _personalisierteAngebote(user.uid),
          ],
        ),
      ),
    );
  }

  Widget _handelsweltHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xff050b2c),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
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
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: const Row(
              children: [
                Icon(Icons.notifications_outlined, color: Colors.white70, size: 18),
                SizedBox(width: 6),
                Text(
                  "News",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kopfbereich(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("chats")
          .where("teilnehmer", arrayContains: userId)
          .snapshots(),
      builder: (context, chatSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("benachrichtigungen")
              .where("userId", isEqualTo: userId)
              .where("gelesen", isEqualTo: false)
              .snapshots(),
          builder: (context, hinweiseSnapshot) {
            final chats = chatSnapshot.data?.docs ?? [];

            final ungeleseneChats = chats.where((doc) {
              final daten = doc.data() as Map<String, dynamic>;
              return (daten["ungelesenFuer"] ?? "").toString() == userId;
            }).length;

            final offeneFavoriten = (hinweiseSnapshot.data?.docs ?? []).where((doc) {
              final daten = doc.data() as Map<String, dynamic>;
              return (daten["typ"] ?? "").toString().toLowerCase() == "favorit";
            }).length;

            final gesamt = ungeleseneChats + offeneFavoriten;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                borderRadius: BorderRadius.circular(26),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x225b2cff),
                    blurRadius: 22,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.notifications_active_outlined,
                          color: Colors.white,
                          size: 31,
                        ),
                      ),
                      if (gesamt > 0)
                        Positioned(
                          right: -5,
                          top: -5,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Text(
                              gesamt > 99 ? "99+" : "$gesamt",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "News",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${chats.length} Chats • $ungeleseneChats ungelesen • $offeneFavoriten Favoriten-Hinweise",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _suchfeld() {
    return SizedBox(
      height: 52,
      child: TextField(
        controller: sucheController,
        cursorColor: const Color(0xff5b2cff),
        onChanged: (wert) {
          setState(() {
            suche = wert;
          });
        },
        decoration: InputDecoration(
          hintText: "Nachrichten, Favoriten oder Angebote suchen...",
          prefixIcon: const Icon(Icons.search, color: Color(0xff5b2cff)),
          suffixIcon: suche.trim().isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    setState(() {
                      suche = "";
                      sucheController.clear();
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0xffececf4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0xffececf4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0xff5b2cff), width: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _filterLeiste() {
    return SizedBox(
      height: 43,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filter.length,
        itemBuilder: (context, index) {
          final item = filter[index];
          final aktiv = chatFilter == item;

          return InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              setState(() {
                chatFilter = item;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: aktiv ? const Color(0xff5b2cff) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: aktiv ? const Color(0xff5b2cff) : const Color(0xffececf4),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  item,
                  style: TextStyle(
                    color: aktiv ? Colors.white : const Color(0xff050b2c),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _schnellAktion(String userId) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xffececf4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: allesWirdGelesen ? null : () => _allesAlsGelesenMarkieren(userId),
        icon: allesWirdGelesen
            ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  color: Color(0xff5b2cff),
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.done_all, color: Color(0xff5b2cff)),
        label: const Text(
          "Chats & Favoriten als gelesen markieren",
          style: TextStyle(
            color: Color(0xff5b2cff),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _chatListe(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("chats")
          .where("teilnehmer", arrayContains: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _fehler("Chats konnten nicht geladen werden.");

        if (!snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Color(0xff5b2cff)),
            ),
          );
        }

        final chats = snapshot.data!.docs.where((doc) {
          final daten = doc.data() as Map<String, dynamic>;
          final ungelesen = (daten["ungelesenFuer"] ?? "").toString() == userId;

          if (chatFilter == "Ungelesen" && !ungelesen) return false;

          return _chatPasstZurSuche(daten, userId);
        }).toList();

        chats.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aZeit = _datum(aData["aktualisiertAm"]);
          final bZeit = _datum(bData["aktualisiertAm"]);

          if (aZeit == null && bZeit == null) return 0;
          if (aZeit == null) return 1;
          if (bZeit == null) return -1;

          return bZeit.compareTo(aZeit);
        });

        return _aufklappBereich(
          titel: chatFilter == "Ungelesen" ? "Ungelesene Chats" : "Chats",
          anzahl: chats.length,
          icon: Icons.chat_bubble_outline,
          offen: chatsOffen,
          onTap: () {
            setState(() {
              chatsOffen = !chatsOffen;
            });
          },
          child: chats.isEmpty
              ? _leer(
                  chatFilter == "Ungelesen"
                      ? "Keine ungelesenen Chats."
                      : "Noch keine Chats vorhanden.",
                )
              : Column(
                  children: [
                    ...chats.take(5).map((doc) {
                      final daten = doc.data() as Map<String, dynamic>;
                      return _chatKarte(
                        context: context,
                        chatRef: doc.reference,
                        daten: daten,
                        userId: userId,
                      );
                    }),
                    if (chats.length > 5)
                      _mehrButton("Alle Chats anzeigen", Icons.chat_bubble_outline),
                  ],
                ),
        );
      },
    );
  }

  Widget _favoritenHinweise(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("benachrichtigungen")
          .where("userId", isEqualTo: userId)
          .where("gelesen", isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _fehler("Favoriten-Hinweise konnten nicht geladen werden.");
        }

        if (!snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Color(0xff5b2cff)),
            ),
          );
        }

        final docs = snapshot.data!.docs.where((doc) {
          final daten = doc.data() as Map<String, dynamic>;
          final typ = (daten["typ"] ?? "").toString().toLowerCase();

          if (typ != "favorit") return false;
          return _favoritPasstZurSuche(daten);
        }).toList();

        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aZeit = _datum(aData["erstelltAm"]);
          final bZeit = _datum(bData["erstelltAm"]);

          if (aZeit == null && bZeit == null) return 0;
          if (aZeit == null) return 1;
          if (bZeit == null) return -1;

          return bZeit.compareTo(aZeit);
        });

        return _aufklappBereich(
          titel: "Favoriten",
          anzahl: docs.length,
          icon: Icons.favorite,
          offen: favoritenOffen,
          iconFarbe: Colors.red,
          onTap: () {
            setState(() {
              favoritenOffen = !favoritenOffen;
            });
          },
          child: docs.isEmpty
              ? _leer("Keine neuen Favoriten-Hinweise.")
              : Column(
                  children: [
                    ...docs.take(5).map((doc) {
                      final daten = doc.data() as Map<String, dynamic>;
                      final titel = _text(daten, ["titel"]);
                      final text = _text(daten, ["text"]);
                      final zeit = _zeitText(daten["erstelltAm"]);

                      return Dismissible(
                        key: ValueKey(doc.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.only(right: 18),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.white),
                        ),
                        onDismissed: (_) async => _favoritHinweisLoeschen(doc.reference),
                        child: _hinweisKarte(
                          icon: Icons.favorite,
                          farbe: Colors.red,
                          titel: titel.isEmpty ? "Favorit" : titel,
                          text: text,
                          zeit: zeit,
                          onTap: () async {
                            await _favoritHinweisGelesen(doc.reference);
                          },
                        ),
                      );
                    }),
                    if (docs.length > 5)
                      _mehrButton("Alle Favoriten anzeigen", Icons.favorite),
                  ],
                ),
        );
      },
    );
  }

  Widget _personalisierteAngebote(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("favoriten")
          .where("userId", isEqualTo: userId)
          .snapshots(),
      builder: (context, favSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("inserate").snapshots(),
          builder: (context, inserateSnapshot) {
            if (!inserateSnapshot.hasData) {
              return const SizedBox(
                height: 80,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xff5b2cff)),
                ),
              );
            }

            final favDocs = favSnapshot.data?.docs ?? [];
            final kategorieZaehler = <String, int>{};

            for (final doc in favDocs) {
              final daten = doc.data() as Map<String, dynamic>;
              final kat = _kategorieAnzeige(
                _text(daten, ["produktKategorie", "kategorie", "category"]),
              );

              if (kat.trim().isEmpty) continue;
              kategorieZaehler[kat] = (kategorieZaehler[kat] ?? 0) + 1;
            }

            final topKategorien = kategorieZaehler.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            final bevorzugteKategorien =
                topKategorien.take(3).map((e) => e.key).toSet();

            final alleProdukte = inserateSnapshot.data!.docs.map((doc) {
              return Produkt.fromFirestore(doc);
            }).where((produkt) {
              if (bevorzugteKategorien.isEmpty) return true;
              return bevorzugteKategorien.contains(
                _kategorieAnzeige(produkt.kategorie),
              );
            }).toList();

            final topAngebote = [...alleProdukte]
              ..sort((a, b) => _zahl(a.preis).compareTo(_zahl(b.preis)));

            final neueInserate = [...alleProdukte].reversed.toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bevorzugteKategorien.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 10),
                    child: Text(
                      "Für dich: ${bevorzugteKategorien.join(", ")}",
                      style: const TextStyle(
                        color: Color(0xff74788d),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
                _angebotReihe(
                  titel: "🔥 Top Inserate für dich",
                  produkte: topAngebote.take(12).toList(),
                ),
                const SizedBox(height: 14),
                _angebotReihe(
                  titel: "🆕 Neue Inserate für dich",
                  produkte: neueInserate.take(12).toList(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _angebotReihe({
    required String titel,
    required List<Produkt> produkte,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xff5b2cff).withOpacity(0.11),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xff5b2cff),
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "$titel (${produkte.length})",
                  style: const TextStyle(
                    color: Color(0xff050b2c),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Icon(Icons.swipe_right_alt, color: Color(0xff5b2cff)),
            ],
          ),
          const SizedBox(height: 12),
          if (produkte.isEmpty)
            _leer("Noch keine passenden Inserate gefunden.")
          else
            SizedBox(
              height: 216,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: produkte.length,
                itemBuilder: (context, index) {
                  return _angebotKarte(produkte[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _angebotKarte(Produkt produkt) {
    final preis = produkt.preis.trim().isEmpty
        ? "Preis auf Anfrage"
        : (produkt.preis.trim().endsWith("€")
            ? produkt.preis.trim()
            : "${produkt.preis.trim()} €");

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailSeite(produkt: produkt)),
        );
      },
      child: Container(
        width: 178,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xffececf4)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 14,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 104,
                width: double.infinity,
                child: produkt.bild.trim().isEmpty
                    ? Container(
                        color: const Color(0xfff1edff),
                        child: Icon(
                          produkt.icon,
                          color: const Color(0xff5b2cff),
                          size: 38,
                        ),
                      )
                    : Image.network(
                        produkt.bild,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: const Color(0xfff1edff),
                            child: Icon(
                              produkt.icon,
                              color: const Color(0xff5b2cff),
                              size: 38,
                            ),
                          );
                        },
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produkt.titel.isEmpty ? "Inserat" : produkt.titel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xff050b2c),
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    preis,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xff5b2cff),
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aufklappBereich({
    required String titel,
    required int anzahl,
    required IconData icon,
    required bool offen,
    required VoidCallback onTap,
    required Widget child,
    Color iconFarbe = const Color(0xff5b2cff),
  }) {
    return Container(
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
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: iconFarbe.withOpacity(0.11),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: iconFarbe, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "$titel ($anzahl)",
                      style: const TextStyle(
                        color: Color(0xff050b2c),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Icon(
                    offen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xff5b2cff),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
          if (offen)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _mehrButton(String text, IconData icon) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {},
      child: Container(
        height: 46,
        margin: const EdgeInsets.only(top: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xfff7f7fb),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffececf4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xff5b2cff), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xff5b2cff),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xff5b2cff)),
          ],
        ),
      ),
    );
  }

  Widget _chatKarte({
    required BuildContext context,
    required DocumentReference chatRef,
    required Map<String, dynamic> daten,
    required String userId,
  }) {
    final produktTitel = _text(daten, ["produktTitel"]);
    final letzteNachricht = _text(daten, ["letzteNachricht"]);
    final produktId = _text(daten, ["produktId"]);

    final verkaeuferId = _text(daten, ["verkaeuferId"]);
    final kaeuferId = _text(daten, ["kaeuferId"]);

    final verkaeuferEmail = _text(daten, ["verkaeuferEmail"]);
    final kaeuferEmail = _text(daten, ["kaeuferEmail"]);

    final anderesId = userId == verkaeuferId ? kaeuferId : verkaeuferId;
    final anderesEmail =
        userId == verkaeuferId ? kaeuferEmail : verkaeuferEmail;

    final ungelesen = (daten["ungelesenFuer"] ?? "").toString() == userId;
    final zeit = _zeitText(daten["aktualisiertAm"]);
    final initial = anderesEmail.isNotEmpty ? anderesEmail[0].toUpperCase() : "?";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () async {
          if (ungelesen) {
            await _chatAlsGelesenMarkieren(chatRef, userId);
          }

          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatSeite(
                verkaeuferId: anderesId,
                verkaeuferEmail: anderesEmail,
                produktId: produktId,
                produktTitel: produktTitel.isEmpty ? "Inserat" : produktTitel,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: ungelesen
                  ? const Color(0xff5b2cff).withOpacity(0.55)
                  : const Color(0xffececf4),
              width: ungelesen ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xfff1edff),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Color(0xff5b2cff),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (ungelesen)
                    Positioned(
                      right: -2,
                      top: -2,
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
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Text(
                          "1",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            produktTitel.isEmpty ? "Inserat" : produktTitel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xff050b2c),
                              fontSize: 16,
                              fontWeight:
                                  ungelesen ? FontWeight.w900 : FontWeight.w800,
                            ),
                          ),
                        ),
                        if (zeit.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            zeit,
                            style: TextStyle(
                              color: ungelesen
                                  ? const Color(0xff5b2cff)
                                  : const Color(0xff74788d),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      anderesEmail.isEmpty ? "Kontakt" : anderesEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff5b2cff),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      letzteNachricht.isEmpty ? "Neue Nachricht" : letzteNachricht,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ungelesen
                            ? const Color(0xff050b2c)
                            : const Color(0xff74788d),
                        fontSize: 13,
                        fontWeight: ungelesen ? FontWeight.w900 : FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Color(0xff74788d)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hinweisKarte({
    required IconData icon,
    required Color farbe,
    required String titel,
    required String text,
    required String zeit,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: farbe.withOpacity(0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: farbe.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: farbe),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            titel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xff050b2c),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (zeit.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            zeit,
                            style: const TextStyle(
                              color: Color(0xff74788d),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      text.trim().isEmpty ? "-" : text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff74788d),
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.done, color: Color(0xff74788d)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leer(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffececf4)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xff74788d),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _fehler(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withOpacity(0.25)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
