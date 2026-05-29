import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../model/produkt.dart';

class InseratSeite extends StatefulWidget {
  final Function(Produkt) onSpeichern;

  const InseratSeite({
    super.key,
    required this.onSpeichern,
  });

  @override
  State<InseratSeite> createState() =>
      _InseratSeiteState();
}

class _InseratSeiteState
    extends State<InseratSeite> {

  final titelController =
      TextEditingController();

  final preisController =
      TextEditingController();

  final ortController =
      TextEditingController();

  final adresseController =
      TextEditingController();

  final beschreibungController =
      TextEditingController();

  String kategorie = "Marktplatz";

  String typ = "Privat";

  bool wirdGespeichert = false;

  List<Uint8List> bilderBytes = [];

  Future<Map<String, double>>
      koordinatenHolen(
    String suche,
  ) async {

    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search"
      "?q=${Uri.encodeComponent("$suche, Österreich")}"
      "&format=json"
      "&limit=1",
    );

    final response = await http.get(
      url,
      headers: {
        "User-Agent":
            "HandelsweltApp/1.0",
      },
    );

    final daten =
        jsonDecode(response.body);

    if (daten is List &&
        daten.isNotEmpty) {

      return {
        "lat": double.parse(
            daten[0]["lat"]),
        "lon": double.parse(
            daten[0]["lon"]),
      };
    }

    return {
      "lat": 48.2082,
      "lon": 16.3738,
    };
  }

  Future<void>
      bilderAuswaehlen() async {

    final picker = ImagePicker();

    final dateien =
        await picker.pickMultiImage();

    if (dateien.isEmpty) return;

    final neueBilder =
        <Uint8List>[];

    for (final datei in dateien) {

      final bytes =
          await datei.readAsBytes();

      neueBilder.add(bytes);
    }

    setState(() {

      bilderBytes.addAll(
          neueBilder);
    });
  }

  Future<List<String>>
      bilderHochladen() async {

    if (bilderBytes.isEmpty) {

      return [
        "https://images.unsplash.com/photo-1523275335684-37898b6baf30",
      ];
    }

    final urls = <String>[];

    for (final bild
        in bilderBytes) {

      final name =
          "${DateTime.now().millisecondsSinceEpoch}_${urls.length}.jpg";

      final ref =
          FirebaseStorage.instance
              .ref()
              .child("inserate")
              .child(name);

      await ref.putData(
        bild,
        SettableMetadata(
          contentType:
              "image/jpeg",
        ),
      );

      final url =
          await ref.getDownloadURL();

      urls.add(url);
    }

    return urls;
  }

  IconData iconFuerKategorie(
      String kategorie) {

    if (kategorie ==
        "Immobilien") {
      return Icons.home;
    }

    if (kategorie ==
        "Autos") {
      return Icons.directions_car;
    }

    if (kategorie ==
        "Elektronik") {
      return Icons.phone_iphone;
    }

    if (kategorie ==
        "Möbel") {
      return Icons.chair;
    }

    if (kategorie ==
        "Jobs") {
      return Icons.work;
    }

    if (kategorie ==
        "Mode") {
      return Icons.checkroom;
    }

    if (kategorie ==
        "Dienstleistungen") {
      return Icons.handyman;
    }

    if (kategorie ==
        "Baumarkt") {
      return Icons.construction;
    }

    return Icons.shopping_bag;
  }

  Widget feld(
    TextEditingController controller,
    String label,
  ) {

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 15,
      ),

      child: TextField(
        controller: controller,

        decoration: InputDecoration(
          labelText: label,

          filled: true,

          fillColor: Colors.white,

          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
                    18),
          ),
        ),
      ),
    );
  }

  Future<void> speichern() async {

    if (titelController.text
            .trim()
            .isEmpty ||
        preisController.text
            .trim()
            .isEmpty ||
        ortController.text
            .trim()
            .isEmpty) {

      ScaffoldMessenger.of(
              context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Bitte Titel, Preis und Ort eingeben.",
          ),
        ),
      );

      return;
    }

    setState(() {
      wirdGespeichert = true;
    });

    try {

      final user =
          FirebaseAuth
              .instance.currentUser;

      if (user == null) {

        ScaffoldMessenger.of(
                context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Bitte zuerst einloggen.",
            ),
          ),
        );

        setState(() {
          wirdGespeichert =
              false;
        });

        return;
      }

      final sucheAdresse =
          adresseController.text
                  .trim()
                  .isEmpty
              ? ortController.text
                  .trim()
              : "${adresseController.text.trim()}, ${ortController.text.trim()}";

      final koordinaten =
          await koordinatenHolen(
              sucheAdresse);

      final bildUrls =
          await bilderHochladen();

      final produkt = Produkt(
        titel:
            titelController.text
                .trim(),

        preis:
            preisController.text
                .trim(),

        ort: ortController.text
            .trim(),

        adresse:
            adresseController.text
                .trim(),

        kategorie: kategorie,

        typ: typ,

        beschreibung:
            beschreibungController
                .text
                .trim(),

        icon:
            iconFuerKategorie(
                kategorie),

        bild: bildUrls.first,

        bilder: bildUrls,

        verkaeuferId:
            user.uid,

        verkaeuferEmail:
            user.email ?? "",

        latitude:
            koordinaten["lat"] ??
                48.2082,

        longitude:
            koordinaten["lon"] ??
                16.3738,
      );

      final doc =
          await FirebaseFirestore
              .instance
              .collection(
                  "inserate")
              .add(
                produkt.toMap(),
              );

      produkt.id = doc.id;

      widget.onSpeichern(
          produkt);

      ScaffoldMessenger.of(
              context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Inserat veröffentlicht.",
          ),
        ),
      );

      titelController.clear();

      preisController.clear();

      ortController.clear();

      adresseController.clear();

      beschreibungController
          .clear();

      setState(() {

        bilderBytes = [];

        wirdGespeichert =
            false;
      });

    } catch (e) {

      ScaffoldMessenger.of(
              context)
          .showSnackBar(
        SnackBar(
          content:
              Text("Fehler: $e"),
        ),
      );

      setState(() {

        wirdGespeichert =
            false;
      });
    }
  }

  @override
  void dispose() {

    titelController.dispose();

    preisController.dispose();

    ortController.dispose();

    adresseController.dispose();

    beschreibungController
        .dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xfff6f3ff),

      appBar: AppBar(
        title: const Text(
            "Inserat erstellen"),

        backgroundColor:
            Colors.deepPurple,

        foregroundColor:
            Colors.white,
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(
                20),

        children: [

          GestureDetector(
            onTap:
                bilderAuswaehlen,

            child: Container(
              height: 220,

              decoration:
                  BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius
                        .circular(
                            24),
              ),

              child:
                  bilderBytes
                          .isEmpty
                      ? const Center(
                          child:
                              Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,

                            children: [

                              Icon(
                                Icons
                                    .add_photo_alternate,

                                size:
                                    60,

                                color:
                                    Colors.deepPurple,
                              ),

                              SizedBox(
                                  height:
                                      10),

                              Text(
                                "Bilder auswählen",

                                style:
                                    TextStyle(
                                  fontSize:
                                      18,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView
                          .builder(
                          scrollDirection:
                              Axis.horizontal,

                          itemCount:
                              bilderBytes
                                  .length,

                          itemBuilder:
                              (
                            context,
                            index,
                          ) {

                            return Padding(
                              padding:
                                  const EdgeInsets.all(
                                      10),

                              child:
                                  ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(
                                        20),

                                child:
                                    Image.memory(
                                  bilderBytes[
                                      index],

                                  width:
                                      180,

                                  fit: BoxFit
                                      .cover,
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),

          const SizedBox(
              height: 25),

          feld(
            titelController,
            "Titel",
          ),

          feld(
            preisController,
            "Preis",
          ),

          feld(
            ortController,
            "Ort",
          ),

          feld(
            adresseController,
            "Adresse / Straße",
          ),

          DropdownButtonFormField<
              String>(
            value: kategorie,

            decoration:
                InputDecoration(
              filled: true,

              fillColor:
                  Colors.white,

              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                        18),
              ),
            ),

            items: const [

              DropdownMenuItem(
                value:
                    "Marktplatz",

                child: Text(
                    "Marktplatz"),
              ),

              DropdownMenuItem(
                value:
                    "Immobilien",

                child: Text(
                    "Immobilien"),
              ),

              DropdownMenuItem(
                value: "Autos",
                child:
                    Text("Autos"),
              ),

              DropdownMenuItem(
                value:
                    "Elektronik",

                child: Text(
                    "Elektronik"),
              ),

              DropdownMenuItem(
                value:
                    "Möbel",

                child:
                    Text("Möbel"),
              ),

              DropdownMenuItem(
                value: "Jobs",
                child:
                    Text("Jobs"),
              ),

              DropdownMenuItem(
                value: "Mode",
                child:
                    Text("Mode"),
              ),

              DropdownMenuItem(
                value:
                    "Dienstleistungen",

                child: Text(
                    "Dienstleistungen"),
              ),

              DropdownMenuItem(
                value:
                    "Baumarkt",

                child:
                    Text("Baumarkt"),
              ),
            ],

            onChanged: (wert) {

              setState(() {

                kategorie =
                    wert!;
              });
            },
          ),

          const SizedBox(
              height: 15),

          DropdownButtonFormField<
              String>(
            value: typ,

            decoration:
                InputDecoration(
              filled: true,

              fillColor:
                  Colors.white,

              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                        18),
              ),
            ),

            items: const [

              DropdownMenuItem(
                value:
                    "Privat",

                child: Text(
                    "Privat"),
              ),

              DropdownMenuItem(
                value:
                    "Firma",

                child:
                    Text("Firma"),
              ),
            ],

            onChanged: (wert) {

              setState(() {

                typ = wert!;
              });
            },
          ),

          const SizedBox(
              height: 20),

          TextField(
            controller:
                beschreibungController,

            maxLines: 6,

            decoration:
                InputDecoration(
              labelText:
                  "Beschreibung",

              filled: true,

              fillColor:
                  Colors.white,

              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                        18),
              ),
            ),
          ),

          const SizedBox(
              height: 30),

          ElevatedButton(
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.deepPurple,

              padding:
                  const EdgeInsets
                      .all(18),
            ),

            onPressed:
                wirdGespeichert
                    ? null
                    : speichern,

            child: Text(
              wirdGespeichert
                  ? "Wird gespeichert..."
                  : "Inserat veröffentlichen",

              style:
                  const TextStyle(
                color:
                    Colors.white,

                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}