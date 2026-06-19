import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/produkt.dart';
import 'detail_seite.dart';

class FavoritenSeite extends StatefulWidget {
  const FavoritenSeite({
    super.key,
    required List<Produkt> favoriten,
  });

  @override
  State<FavoritenSeite> createState() => _FavoritenSeiteState();
}

class _FavoritenSeiteState extends State<FavoritenSeite> {
  String ausgewaehlteKategorie = "Alle";
  String suche = "";
  String sortierung = "Neueste zuerst";

  final sucheController = TextEditingController();

  final List<String> kategorien = const [
    "Alle",
    "Marktplatz",
    "Auto & Motor",
    "Immobilien",
    "Jobs",
    "Elektronik",
    "Haus & Garten",
    "Mode",
    "Dienstleistungen",
    "Baumarkt",
    "Baumaschinen",
    "Boote",
    "Landwirtschaft",
    "Freizeit",
    "Tiere",
    "Baby & Kind",
    "Sport",
  ];

  final List<String> sortierungen = const [
    "Neueste zuerst",
    "Preis aufsteigend",
    "Preis absteigend",
    "Titel A-Z",
  ];

  @override
  void dispose() {
    sucheController.dispose();
    super.dispose();
  }

  IconData iconFuerKategorie(String kategorie) {
    if (kategorie == "Alle") return Icons.apps_outlined;
    if (kategorie == "Marktplatz") return Icons.storefront_outlined;
    if (kategorie == "Auto & Motor") return Icons.directions_car;
    if (kategorie == "Immobilien") return Icons.home_outlined;
    if (kategorie == "Jobs") return Icons.work_outline;
    if (kategorie == "Elektronik") return Icons.phone_iphone;
    if (kategorie == "Haus & Garten") return Icons.chair_outlined;
    if (kategorie == "Mode") return Icons.checkroom_outlined;
    if (kategorie == "Dienstleistungen") return Icons.handyman_outlined;
    if (kategorie == "Baumarkt") return Icons.construction_outlined;
    if (kategorie == "Baumaschinen") return Icons.precision_manufacturing_outlined;
    if (kategorie == "Boote") return Icons.sailing_outlined;
    if (kategorie == "Landwirtschaft") return Icons.agriculture_outlined;
    if (kategorie == "Freizeit") return Icons.sports_soccer_outlined;
    if (kategorie == "Tiere") return Icons.pets_outlined;
    if (kategorie == "Baby & Kind") return Icons.child_care_outlined;
    if (kategorie == "Sport") return Icons.fitness_center_outlined;

    return Icons.category_outlined;
  }

  String wert(Map<String, dynamic> daten, List<String> keys) {
    for (final key in keys) {
      final value = daten[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return "";
  }

  bool boolWert(Map<String, dynamic> daten, List<String> keys) {
    for (final key in keys) {
      final value = daten[key];
      if (value == true) return true;
      if (value.toString().toLowerCase() == "true") return true;
      if (value.toString().toLowerCase() == "ja") return true;
    }
    return false;
  }

  int zahl(String text) {
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

  DateTime zeitWert(Map<String, dynamic> fav) {
    final zeit = fav["erstelltAm"] ?? fav["gespeichertAm"] ?? fav["createdAt"];
    if (zeit is Timestamp) return zeit.toDate();
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  String kategorieAnzeige(String kategorie) {
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

  bool istVermietung(Map<String, dynamic> fav) {
    final unterkategorie = wert(fav, ["produktUnterkategorie", "unterkategorie"]);
    final detail = wert(fav, ["produktDetailUnterkategorie", "detailUnterkategorie"]);
    final text = "$unterkategorie $detail".toLowerCase();

    return text.contains("vermietung") ||
        wert(fav, ["mietpreisTag", "vermietungTagespreis"]).trim().isNotEmpty ||
        wert(fav, ["mietpreisWoche", "vermietungWochenpreis"]).trim().isNotEmpty;
  }

  bool kategoriePasst(Map<String, dynamic> fav) {
    if (ausgewaehlteKategorie == "Alle") return true;

    final rawKategorie = wert(
      fav,
      [
        "produktKategorie",
        "kategorie",
        "category",
      ],
    );

    final kategorie = kategorieAnzeige(rawKategorie);
    return kategorie == ausgewaehlteKategorie;
  }

  bool suchePasst(Map<String, dynamic> fav) {
    final text = suche.trim().toLowerCase();
    if (text.isEmpty) return true;

    final suchText = [
      wert(fav, ["produktTitel", "titel", "title"]),
      wert(fav, ["produktOrt", "ort", "location"]),
      wert(fav, ["produktPreis", "preis", "price"]),
      kategorieAnzeige(wert(fav, ["produktKategorie", "kategorie", "category"])),
      wert(fav, ["produktUnterkategorie", "unterkategorie"]),
      wert(fav, ["verkaeuferEmail", "sellerEmail"]),
      wert(fav, ["firmenname", "firma"]),
    ].join(" ").toLowerCase();

    return suchText.contains(text);
  }

  void sortieren(List<Map<String, dynamic>> favoriten) {
    if (sortierung == "Preis aufsteigend") {
      favoriten.sort((a, b) {
        final preisA = zahl(wert(a, ["produktPreis", "preis", "price"]));
        final preisB = zahl(wert(b, ["produktPreis", "preis", "price"]));
        return preisA.compareTo(preisB);
      });
    } else if (sortierung == "Preis absteigend") {
      favoriten.sort((a, b) {
        final preisA = zahl(wert(a, ["produktPreis", "preis", "price"]));
        final preisB = zahl(wert(b, ["produktPreis", "preis", "price"]));
        return preisB.compareTo(preisA);
      });
    } else if (sortierung == "Titel A-Z") {
      favoriten.sort((a, b) {
        final titelA = wert(a, ["produktTitel", "titel", "title"]).toLowerCase();
        final titelB = wert(b, ["produktTitel", "titel", "title"]).toLowerCase();
        return titelA.compareTo(titelB);
      });
    } else {
      favoriten.sort((a, b) => zeitWert(b).compareTo(zeitWert(a)));
    }
  }

  Future<void> favoritEntfernen(
    BuildContext context,
    Map<String, dynamic> fav, {
    bool ohneDialog = false,
  }) async {
    final favoritDocId = wert(fav, ["_favoritDocId"]);
    final titel = wert(fav, ["produktTitel", "titel", "title"]);

    if (favoritDocId.isEmpty) return;

    if (ohneDialog) {
      await FirebaseFirestore.instance.collection("favoriten").doc(favoritDocId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Favorit wurde entfernt.")),
        );
      }
      return;
    }

    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            "Favorit entfernen?",
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            titel.trim().isEmpty
                ? "Dieses Inserat aus deinen Favoriten entfernen?"
                : "\"$titel\" aus deinen Favoriten entfernen?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text("Abbrechen"),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              label: const Text(
                "Entfernen",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (bestaetigt != true) return;

    await FirebaseFirestore.instance
        .collection("favoriten")
        .doc(favoritDocId)
        .delete();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Favorit wurde entfernt.")),
    );
  }

  Future<void> detailOeffnen(
    BuildContext context,
    Map<String, dynamic> fav,
  ) async {
    final produktId = wert(fav, ["produktId", "id"]);

    if (produktId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produkt-ID fehlt.")),
      );
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection("inserate")
        .doc(produktId)
        .get();

    if (!context.mounted) return;

    if (!doc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dieses Inserat wurde gelöscht.")),
      );
      return;
    }

    final produkt = Produkt.fromFirestore(doc);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailSeite(produkt: produkt),
      ),
    );
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
              _kopfzeile(),
              const SizedBox(height: 22),
              _leer(
                text: "Bitte zuerst einloggen.",
                icon: Icons.lock_outline,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("favoriten")
              .where("userId", isEqualTo: user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Fehler: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xff5b2cff),
                ),
              );
            }

            final favoritenDocs = snapshot.data!.docs;

            final favoriten = favoritenDocs.map((doc) {
              final daten = doc.data() as Map<String, dynamic>;
              return {
                ...daten,
                "_favoritDocId": doc.id,
              };
            }).where((fav) {
              return kategoriePasst(fav) && suchePasst(fav);
            }).toList();

            sortieren(favoriten);

            return ListView(
              padding: EdgeInsets.fromLTRB(
                breit ? 46 : 16,
                18,
                breit ? 46 : 16,
                24,
              ),
              children: [
                _kopfzeile(),
                const SizedBox(height: 16),
                _suchfeld(),
                const SizedBox(height: 12),
                _sortierZeile(),
                const SizedBox(height: 16),
                _kategorieLeiste(),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ausgewaehlteKategorie == "Alle"
                            ? "Gespeicherte Deals"
                            : ausgewaehlteKategorie,
                        style: const TextStyle(
                          color: Color(0xff050b2c),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xfff1edff),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "${favoriten.length} gefunden",
                        style: const TextStyle(
                          color: Color(0xff5b2cff),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (favoritenDocs.isEmpty)
                  _leer(
                    text: "Noch keine Favoriten",
                    icon: Icons.favorite_border,
                  )
                else if (favoriten.isEmpty)
                  _leer(
                    text: "Keine passenden Favoriten gefunden.",
                    icon: Icons.search_off,
                  )
                else if (ausgewaehlteKategorie == "Alle")
                  _gruppiertNachKategorie(context, favoriten, breit)
                else
                  GridView.builder(
                    itemCount: favoriten.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: breit ? 4 : 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: breit ? 0.88 : 0.72,
                    ),
                    itemBuilder: (context, index) {
                      return _favoritKarte(context, favoriten[index]);
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _kopfzeile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xff050b2c),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff5b2cff), Color(0xff7a5cff)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Favoriten",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Deine gespeicherten Handelswelt Deals",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xffb9a8ff),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: const Icon(Icons.bookmark_added_outlined, color: Colors.white70, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _suchfeld() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffececf4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0f000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: sucheController,
        cursorColor: const Color(0xff5b2cff),
        onChanged: (wert) {
          setState(() {
            suche = wert;
          });
        },
        decoration: InputDecoration(
          hintText: "Favoriten suchen...",
          hintStyle: const TextStyle(
            color: Color(0xff74788d),
            fontWeight: FontWeight.w700,
          ),
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
                  icon: const Icon(Icons.close, color: Color(0xff74788d)),
                ),
          filled: true,
          fillColor: const Color(0xfff7f7fb),
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

  Widget _sortierZeile() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: sortierung,
            isExpanded: true,
            dropdownColor: Colors.white,
            style: const TextStyle(
              color: Color(0xff050b2c),
              fontWeight: FontWeight.w800,
            ),
            items: sortierungen
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                sortierung = value;
              });
            },
            decoration: InputDecoration(
              labelText: "Sortieren",
              labelStyle: const TextStyle(color: Color(0xff74788d)),
              prefixIcon: const Icon(Icons.swap_vert, color: Color(0xff5b2cff)),
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
        ),
        const SizedBox(width: 10),
        InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: () {
            setState(() {
              ausgewaehlteKategorie = "Alle";
              sortierung = "Neueste zuerst";
              suche = "";
              sucheController.clear();
            });
          },
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xfff1edff),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: const Color(0xffded7ff)),
            ),
            child: const Icon(
              Icons.restart_alt,
              color: Color(0xff5b2cff),
            ),
          ),
        ),
      ],
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
                    iconFuerKategorie(kategorie),
                    color: aktiv ? Colors.white : const Color(0xff5b2cff),
                    size: 18,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    kategorie,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

  Widget _gruppiertNachKategorie(BuildContext context, List<Map<String, dynamic>> favoriten, bool breit) {
    final Map<String, List<Map<String, dynamic>>> gruppen = {};
    for (final fav in favoriten) {
      final kat = kategorieAnzeige(wert(fav, ["produktKategorie", "kategorie", "category"]));
      final key = kat.isEmpty ? "Sonstige" : kat;
      gruppen.putIfAbsent(key, () => []).add(fav);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: gruppen.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 6),
              child: Row(
                children: [
                  Icon(iconFuerKategorie(entry.key), color: const Color(0xff5b2cff), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Color(0xff050b2c),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xfff1edff),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${entry.value.length}",
                      style: const TextStyle(
                        color: Color(0xff5b2cff),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GridView.builder(
              itemCount: entry.value.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: breit ? 4 : 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: breit ? 0.88 : 0.72,
              ),
              itemBuilder: (context, index) {
                return _favoritKarte(context, entry.value[index]);
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }

  Widget _favoritKarte(BuildContext context, Map<String, dynamic> fav) {
    final titel = wert(fav, ["produktTitel", "titel", "title"]);
    final preis = wert(fav, ["produktPreis", "preis", "price"]);
    final ort = wert(fav, ["produktOrt", "ort", "location"]);
    final bild = wert(fav, ["produktBild", "bild", "image"]);
    final kategorie = kategorieAnzeige(
      wert(fav, ["produktKategorie", "kategorie", "category"]),
    );
    final firmaVerifiziert = boolWert(fav, ["firmaVerifiziert", "verifiziert"]);
    final vermietung = istVermietung(fav);

    final preisText = preis.trim().isEmpty
        ? "Preis auf Anfrage"
        : (preis.endsWith("€") ? preis : "$preis €");

    final favoritDocId = wert(fav, ["_favoritDocId"]);

    return Dismissible(
      key: Key(favoritDocId.isEmpty ? titel : favoritDocId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) => favoritEntfernen(context, fav, ohneDialog: true).then((_) => false),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => detailOeffnen(context, fav),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
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
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                    child: bild.isEmpty
                        ? _platzhalter(kategorie)
                        : Image.network(
                            bild,
                            width: double.infinity,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _platzhalter(kategorie);
                            },
                          ),
                  ),
                  Positioned(
                    top: 9,
                    right: 9,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => favoritEntfernen(context, fav),
                      child: const CircleAvatar(
                        radius: 17,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.favorite, color: Colors.red, size: 19),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titel.isEmpty ? "Inserat" : titel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff050b2c),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preisText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff5b2cff),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: Color(0xff74788d)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            ort,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Color(0xff74788d), fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (kategorie.isNotEmpty) ...[
                          _chip(kategorie),
                          const SizedBox(width: 4),
                        ],
                        _chip(vermietung ? "Miete" : "Kauf"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _platzhalter(String kategorie) {
    return Container(
      height: 110,
      width: double.infinity,
      color: const Color(0xfff1edff),
      child: Icon(
        iconFuerKategorie(kategorie),
        color: const Color(0xff5b2cff),
        size: 42,
      ),
    );
  }

  Widget _bildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.72),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _chip(String text) {
    Color bg = const Color(0xfff1edff);
    Color fg = const Color(0xff5b2cff);

    if (text == "Gespeichert") {
      bg = const Color(0xffffedf1);
      fg = Colors.red;
    } else if (text.contains("Verifiziert")) {
      bg = const Color(0xffffefe0);
      fg = Colors.orange;
    } else if (text == "Vermietung") {
      bg = const Color(0xffeaf7ff);
      fg = Colors.blue;
    } else if (text == "Verkauf") {
      bg = const Color(0xfff1edff);
      fg = const Color(0xff5b2cff);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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

  Widget _leer({
    required String text,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffececf4)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Color(0xff5b2cff),
            size: 52,
          ),
          const SizedBox(height: 14),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xff050b2c),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Speichere Deals mit dem Herz-Symbol.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xff74788d)),
          ),
        ],
      ),
    );
  }
}
