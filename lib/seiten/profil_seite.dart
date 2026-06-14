// lib/seiten/profil_seite.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../model/produkt.dart';

import 'admin_zentrale_seite.dart';
import 'chatliste_seite.dart';
import 'detail_seite.dart';
import 'inserat_bearbeiten_seite.dart';

class ProfilSeite extends StatefulWidget {
  final List<Produkt> produkte;

  const ProfilSeite({
    super.key,
    required this.produkte,
  });

  @override
  State<ProfilSeite> createState() => _ProfilSeiteState();
}

class _ProfilSeiteState extends State<ProfilSeite> {
  final benutzernameController = TextEditingController();
  final vornameController = TextEditingController();
  final nachnameController = TextEditingController();
  final telefonController = TextEditingController();
  final ortController = TextEditingController();

  final firmennameController = TextEditingController();
  final rechtsformController = TextEditingController();
  final uidNummerController = TextEditingController();
  final ansprechpartnerController = TextEditingController();
  final webseiteController = TextEditingController();
  final strasseController = TextEditingController();
  final plzController = TextEditingController();
  final landController = TextEditingController();

  bool datenGeladen = false;
  bool wirdGespeichert = false;
  bool bearbeitungsModus = false;
  bool istAdmin = false;
  String? geladeneUserId;

  String kontoTyp = "privat";
  bool firmaVerifiziert = false;
  bool profilVerifiziert = false;
  Timestamp? erstelltAm;

  String profilBildUrl = "";
  bool wirdProfilbildHochgeladen = false;
  bool wirdProfilbildGeloescht = false;

  String gewerbescheinUrl = "";
  bool wirdGewerbescheinHochgeladen = false;

  @override
  void dispose() {
    benutzernameController.dispose();
    vornameController.dispose();
    nachnameController.dispose();
    telefonController.dispose();
    ortController.dispose();
    firmennameController.dispose();
    rechtsformController.dispose();
    uidNummerController.dispose();
    ansprechpartnerController.dispose();
    webseiteController.dispose();
    strasseController.dispose();
    plzController.dispose();
    landController.dispose();
    super.dispose();
  }

  void _profilStateZuruecksetzen() {
    datenGeladen = false;
    wirdGespeichert = false;
    bearbeitungsModus = false;
    istAdmin = false;
    kontoTyp = "privat";
    firmaVerifiziert = false;
    profilVerifiziert = false;
    erstelltAm = null;
    profilBildUrl = "";
    wirdProfilbildHochgeladen = false;
    wirdProfilbildGeloescht = false;
    gewerbescheinUrl = "";
    wirdGewerbescheinHochgeladen = false;

    benutzernameController.clear();
    vornameController.clear();
    nachnameController.clear();
    telefonController.clear();
    ortController.clear();
    firmennameController.clear();
    rechtsformController.clear();
    uidNummerController.clear();
    ansprechpartnerController.clear();
    webseiteController.clear();
    strasseController.clear();
    plzController.clear();
    landController.clear();
  }

  Future<void> userDatenLaden(User user) async {
    // Wenn zwischen Privatkonto und Firmenkonto gewechselt wird, darf der alte
    // Profil-State nicht weiter angezeigt werden.
    if (datenGeladen && geladeneUserId == user.uid) return;

    if (geladeneUserId != user.uid) {
      _profilStateZuruecksetzen();
      geladeneUserId = user.uid;
    }

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data() ?? {};

      kontoTyp = (data["kontoTyp"] ?? "privat").toString();
      firmaVerifiziert = data["firmaVerifiziert"] == true;
      profilVerifiziert = data["profilVerifiziert"] == true;
      istAdmin = data["isAdmin"] == true;
      gewerbescheinUrl = (data["gewerbescheinUrl"] ?? "").toString();
      profilBildUrl = (data["profilBildUrl"] ??
              data["photoUrl"] ??
              user.photoURL ??
              "")
          .toString();

      if (data["erstelltAm"] is Timestamp) {
        erstelltAm = data["erstelltAm"] as Timestamp;
      }

      benutzernameController.text =
          (data["benutzername"] ?? user.displayName ?? "").toString();
      vornameController.text = (data["vorname"] ?? "").toString();
      nachnameController.text = (data["nachname"] ?? "").toString();
      telefonController.text = (data["telefon"] ?? "").toString();
      ortController.text = (data["ort"] ?? "").toString();

      firmennameController.text = (data["firmenname"] ?? "").toString();
      rechtsformController.text = (data["rechtsform"] ?? "").toString();
      uidNummerController.text = (data["uidNummer"] ?? "").toString();
      ansprechpartnerController.text =
          (data["ansprechpartner"] ?? "").toString();
      webseiteController.text = (data["webseite"] ?? "").toString();
      strasseController.text = (data["strasse"] ?? "").toString();
      plzController.text = (data["plz"] ?? "").toString();
      landController.text = (data["land"] ?? "Österreich").toString();
    } else {
      kontoTyp = "privat";
      benutzernameController.text = user.displayName ?? "";
      landController.text = "Österreich";
      profilBildUrl = user.photoURL ?? "";

      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "kontoTyp": "privat",
        "benutzername": user.displayName ?? "",
        "email": user.email ?? "",
        "emailVerifiziert": user.emailVerified,
        "profilBildUrl": profilBildUrl,
        "photoUrl": profilBildUrl,
        "erstelltAm": FieldValue.serverTimestamp(),
        "aktualisiertAm": FieldValue.serverTimestamp(),
        "profilVerifiziert": false,
        "isAdmin": false,
        "gesperrt": false,
      }, SetOptions(merge: true));
    }

    datenGeladen = true;

    if (mounted) setState(() {});
  }

  Future<void> datenSpeichern(User user) async {
    setState(() => wirdGespeichert = true);

    try {
      final benutzername = benutzernameController.text.trim();
      await user.updateDisplayName(benutzername);
      if (profilBildUrl.trim().isNotEmpty) {
        await user.updatePhotoURL(profilBildUrl.trim());
      }

      final daten = <String, dynamic>{
        "uid": user.uid,
        "email": user.email ?? "",
        "emailVerifiziert": user.emailVerified,
        "kontoTyp": kontoTyp,
        "benutzername": benutzername,
        "telefon": telefonController.text.trim(),
        "profilBildUrl": profilBildUrl,
        "photoUrl": profilBildUrl,
        "aktualisiertAm": FieldValue.serverTimestamp(),
      };

      if (kontoTyp == "privat") {
        daten.addAll({
          "vorname": vornameController.text.trim(),
          "nachname": nachnameController.text.trim(),
          "ort": ortController.text.trim(),
          "profilVerifiziert": profilVerifiziert,
        });
      } else {
        daten.addAll({
          "firmenname": firmennameController.text.trim(),
          "rechtsform": rechtsformController.text.trim(),
          "uidNummer": uidNummerController.text.trim(),
          "ansprechpartner": ansprechpartnerController.text.trim(),
          "webseite": webseiteController.text.trim(),
          "strasse": strasseController.text.trim(),
          "plz": plzController.text.trim(),
          "ort": ortController.text.trim(),
          "land": landController.text.trim().isEmpty
              ? "Österreich"
              : landController.text.trim(),
          "firmaVerifiziert": firmaVerifiziert,
          "gewerbescheinUrl": gewerbescheinUrl,
        });
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set(daten, SetOptions(merge: true));

      if (!mounted) return;

      setState(() {
        wirdGespeichert = false;
        bearbeitungsModus = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Daten gespeichert.")),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => wirdGespeichert = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Fehler beim Speichern: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> profilbildHochladen(User user) async {
    try {
      setState(() => wirdProfilbildHochgeladen = true);

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.custom,
        allowedExtensions: ["jpg", "jpeg", "png"],
      );

      if (result == null || result.files.single.bytes == null) {
        if (!mounted) return;
        setState(() => wirdProfilbildHochgeladen = false);
        return;
      }

      final file = result.files.single;
      final endung = file.extension ?? "jpg";
      final ref = FirebaseStorage.instance
          .ref()
          .child("profilbilder")
          .child(user.uid)
          .child("profilbild_${DateTime.now().millisecondsSinceEpoch}.$endung");

      await ref.putData(
        file.bytes!,
        SettableMetadata(contentType: endung == "png" ? "image/png" : "image/jpeg"),
      );

      final downloadUrl = await ref.getDownloadURL();

      await user.updatePhotoURL(downloadUrl);
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "profilBildUrl": downloadUrl,
        "photoUrl": downloadUrl,
        "aktualisiertAm": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      setState(() {
        profilBildUrl = downloadUrl;
        wirdProfilbildHochgeladen = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profilbild wurde aktualisiert."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => wirdProfilbildHochgeladen = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Fehler beim Profilbild: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> profilbildLoeschen(User user) async {
    if (profilBildUrl.trim().isEmpty) return;

    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text(
            "Profilbild entfernen?",
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text("Dein Profilbild wird aus deinem Profil entfernt."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Abbrechen"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Entfernen",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    if (bestaetigt != true) return;

    try {
      setState(() => wirdProfilbildGeloescht = true);

      await user.updatePhotoURL(null);
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "profilBildUrl": "",
        "photoUrl": "",
        "aktualisiertAm": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      setState(() {
        profilBildUrl = "";
        wirdProfilbildGeloescht = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profilbild wurde entfernt.")),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => wirdProfilbildGeloescht = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> gewerbescheinHochladen(User user) async {
    try {
      setState(() => wirdGewerbescheinHochgeladen = true);

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.custom,
        allowedExtensions: ["pdf", "jpg", "jpeg", "png"],
      );

      if (result == null || result.files.single.bytes == null) {
        if (!mounted) return;
        setState(() => wirdGewerbescheinHochgeladen = false);
        return;
      }

      final file = result.files.single;
      final dateiname = file.name;
      final ref = FirebaseStorage.instance
          .ref()
          .child("gewerbescheine")
          .child(user.uid)
          .child(dateiname);

      await ref.putData(file.bytes!);
      final downloadUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "gewerbescheinUrl": downloadUrl,
        "firmaVerifiziert": false,
        "verifizierungStatus": "ausstehend",
        "aktualisiertAm": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      setState(() {
        gewerbescheinUrl = downloadUrl;
        firmaVerifiziert = false;
        wirdGewerbescheinHochgeladen = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gewerbeschein erfolgreich hochgeladen."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => wirdGewerbescheinHochgeladen = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Fehler beim Hochladen: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> inseratLoeschen(Produkt produkt) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text("Inserat löschen?"),
          content: const Text("Möchtest du dieses Inserat wirklich löschen?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Abbrechen"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Löschen", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (bestaetigt != true) return;

    await FirebaseFirestore.instance.collection("inserate").doc(produkt.id).delete();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Inserat gelöscht.")),
    );

    setState(() {});
  }

  String mitgliedSeitText() {
    if (erstelltAm == null) return "Neu";
    final datum = erstelltAm!.toDate();
    final tag = datum.day.toString().padLeft(2, "0");
    final monat = datum.month.toString().padLeft(2, "0");
    final jahr = datum.year.toString();
    return "$tag.$monat.$jahr";
  }

  String anzeigenName(User user) {
    if (kontoTyp == "firma" && firmennameController.text.trim().isNotEmpty) {
      return firmennameController.text.trim();
    }
    if (benutzernameController.text.trim().isNotEmpty) {
      return benutzernameController.text.trim();
    }
    return user.email ?? "Benutzer";
  }

  String kontoStatusText() {
    if (kontoTyp == "firma") return "Firmenkonto";
    return "Privatkonto";
  }

  IconData kontoStatusIcon() {
    if (kontoTyp == "firma") return Icons.business_outlined;
    return Icons.person_outline;
  }

  Widget _profilAvatar({
    required double radius,
    required IconData fallbackIcon,
    Color iconColor = const Color(0xff5b2cff),
    Color backgroundColor = Colors.white,
  }) {
    final hatBild = profilBildUrl.trim().isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: hatBild ? NetworkImage(profilBildUrl.trim()) : null,
      child: !hatBild
          ? Icon(
              fallbackIcon,
              color: iconColor,
              size: radius,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final breit = MediaQuery.of(context).size.width > 900;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xfffafafe),
        body: SafeArea(
          child: Center(
            child: Text(
              "Bitte zuerst einloggen.",
              style: TextStyle(
                color: Color(0xff050b2c),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      );
    }

    final meineProdukte =
        widget.produkte.where((p) => p.verkaeuferId == user.uid).toList();

    return FutureBuilder(
      future: userDatenLaden(user),
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: const Color(0xfffafafe),
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                breit ? 46 : 16,
                18,
                breit ? 46 : 16,
                28,
              ),
              children: [
                _profilHeader(user, meineProdukte.length),
                const SizedBox(height: 18),
                _statistikBereich(meineProdukte, user.uid),
                const SizedBox(height: 18),
                _profilFormular(user),
                const SizedBox(height: 18),
                _aktionsBereich(),
                const SizedBox(height: 24),
                _meineInserateSwipeBereich(meineProdukte),
                const SizedBox(height: 16),
                _logoutButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _profilHeader(User user, int anzahl) {
    final istFirma = kontoTyp == "firma";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff070b2f),
            Color(0xff11184f),
            Color(0xff5b2cff),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff5b2cff).withOpacity(0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _profilAvatar(
                    radius: 42,
                    fallbackIcon: istFirma ? Icons.business : Icons.person,
                    backgroundColor: Colors.white,
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: wirdProfilbildHochgeladen
                          ? null
                          : () => profilbildHochladen(user),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xff5b2cff),
                            width: 2,
                          ),
                        ),
                        child: wirdProfilbildHochgeladen
                            ? const Padding(
                                padding: EdgeInsets.all(8),
                                child: CircularProgressIndicator(
                                  color: Color(0xff5b2cff),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                color: Color(0xff5b2cff),
                                size: 18,
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
                    Text(
                      anzeigenName(user),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _headerBadge(
                          istFirma ? "Firma" : "Privat",
                          istFirma ? Icons.business : Icons.person,
                        ),
                        if (user.emailVerified)
                          _headerBadge("E-Mail bestätigt", Icons.mark_email_read_outlined),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      user.email ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _einstellungenOeffnen(user),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.13),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.16)),
            ),
            child: Row(
              children: [
                Expanded(child: _headerWert("$anzahl", "Inserate")),
                Expanded(
                  child: _headerWert(
                    user.emailVerified ? "Ja" : "Nein",
                    "E-Mail bestätigt",
                  ),
                ),
                Expanded(child: _headerWert(mitgliedSeitText(), "Mitglied seit")),
              ],
            ),
          ),
        ],
      ),
    );
  }


  void _einstellungenOeffnen(User user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xffececf4)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xffd9d9e6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Row(
                  children: [
                    _profilAvatar(
                      radius: 26,
                      fallbackIcon: kontoTyp == "firma" ? Icons.business : Icons.person,
                      backgroundColor: const Color(0xfff1edff),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            anzeigenName(user),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xff050b2c),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user.email ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xff74788d),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _einstellungTile(
                  icon: Icons.edit_outlined,
                  titel: "Profil bearbeiten",
                  text: "Name, Telefon, Standort und Firmendaten ändern",
                  farbe: const Color(0xff5b2cff),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Future.delayed(const Duration(milliseconds: 120), () {
                      if (!mounted) return;
                      setState(() {
                        bearbeitungsModus = true;
                      });
                    });
                  },
                ),
                _einstellungTile(
                  icon: Icons.photo_camera_outlined,
                  titel: profilBildUrl.trim().isEmpty
                      ? "Profilbild hochladen"
                      : "Profilbild ändern",
                  text: "JPG oder PNG auswählen und speichern",
                  farbe: Colors.orange,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Future.delayed(const Duration(milliseconds: 120), () {
                      if (!mounted) return;
                      profilbildHochladen(user);
                    });
                  },
                ),
                if (profilBildUrl.trim().isNotEmpty)
                  _einstellungTile(
                    icon: Icons.delete_outline,
                    titel: "Profilbild entfernen",
                    text: "Aktuelles Profilbild löschen",
                    farbe: Colors.red,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      Future.delayed(const Duration(milliseconds: 120), () {
                        if (!mounted) return;
                        profilbildLoeschen(user);
                      });
                    },
                  ),
                _einstellungTile(
                  icon: Icons.chat_bubble_outline,
                  titel: "Meine Chats",
                  text: "Nachrichten und Anfragen öffnen",
                  farbe: const Color(0xff050b2c),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Future.delayed(const Duration(milliseconds: 120), () {
                      if (!mounted) return;
                      Navigator.of(this.context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChatlisteSeite(),
                        ),
                      );
                    });
                  },
                ),
                if (kontoTyp == "firma")
                  _einstellungTile(
                    icon: Icons.verified_user_outlined,
                    titel: "Firmenstatus",
                    text: firmaVerifiziert
                        ? "Deine Firma ist verifiziert"
                        : "Gewerbeschein und Prüfung verwalten",
                    farbe: firmaVerifiziert ? Colors.green : Colors.orange,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      Future.delayed(const Duration(milliseconds: 120), () {
                        if (!mounted) return;
                        setState(() {
                          bearbeitungsModus = true;
                        });
                      });
                    },
                  ),
                if (istAdmin)
                  _einstellungTile(
                    icon: Icons.admin_panel_settings_outlined,
                    titel: "Admin-Zentrale",
                    text: "Benutzer, Firmen, Inserate und Meldungen verwalten",
                    farbe: Colors.red,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      Future.delayed(const Duration(milliseconds: 120), () {
                        if (!mounted) return;
                        Navigator.of(this.context).push(
                          MaterialPageRoute(
                            builder: (_) => const AdminZentraleSeite(),
                          ),
                        );
                      });
                    },
                  ),
                const Divider(height: 22),
                _einstellungTile(
                  icon: Icons.lock_outline,
                  titel: "Passwort ändern",
                  text: "Passwort-Zurücksetzen per E-Mail senden",
                  farbe: const Color(0xff5b2cff),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final email = user.email;
                    if (email == null || email.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Keine E-Mail-Adresse gefunden."),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Passwort-Link wurde per E-Mail gesendet."),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
                _einstellungTile(
                  icon: Icons.logout,
                  titel: "Abmelden",
                  text: "Aus Handelswelt ausloggen",
                  farbe: const Color(0xff050b2c),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await FirebaseAuth.instance.signOut();
                    if (mounted) {
                      setState(() {
                        geladeneUserId = null;
                        _profilStateZuruecksetzen();
                      });
                    }
                  },
                ),
                _einstellungTile(
                  icon: Icons.delete_forever_outlined,
                  titel: "Konto löschen anfragen",
                  text: "Löschanfrage für dein Konto speichern",
                  farbe: Colors.red,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Future.delayed(const Duration(milliseconds: 120), () {
                      if (!mounted) return;
                      _kontoLoeschungAnfragen(user);
                    });
                  },
                ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _einstellungTile({
    required IconData icon,
    required String titel,
    required String text,
    required Color farbe,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: farbe.withOpacity(0.11),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: farbe, size: 23),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: const TextStyle(
                      color: Color(0xff050b2c),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xff74788d),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 24,
              child: Icon(Icons.chevron_right, color: Color(0xff74788d)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _kontoLoeschungAnfragen(User user) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text(
            "Konto löschen anfragen?",
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text(
            "Deine Löschanfrage wird gespeichert. Ein Admin kann dein Konto anschließend prüfen und entfernen.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Abbrechen"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Anfragen",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    if (bestaetigt != true) return;

    await FirebaseFirestore.instance.collection("kontoLoeschAnfragen").doc(user.uid).set({
      "userId": user.uid,
      "email": user.email ?? "",
      "name": anzeigenName(user),
      "status": "offen",
      "erstelltAm": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Löschanfrage wurde gespeichert."),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _headerBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerWert(String wert, String label) {
    return Column(
      children: [
        Text(
          wert,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _statistikBereich(List<Produkt> meineProdukte, String userId) {
    return Row(
      children: [
        _statKarte(
          Icons.inventory_2_outlined,
          "Inserate",
          "${meineProdukte.length}",
        ),
        const SizedBox(width: 10),
        _statKarte(
          Icons.business_outlined,
          "Konto",
          kontoTyp == "firma" ? "Firma" : "Privat",
        ),
        const SizedBox(width: 10),
        _statKarte(
          Icons.mark_email_read_outlined,
          "E-Mail",
          FirebaseAuth.instance.currentUser?.emailVerified == true ? "Ja" : "Nein",
        ),
      ],
    );
  }

  Widget _statKarte(IconData icon, String titel, String wert) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
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
            Icon(icon, color: const Color(0xff5b2cff), size: 28),
            const SizedBox(height: 8),
            Text(
              wert,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xff050b2c),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              titel,
              style: const TextStyle(color: Color(0xff74788d), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profilFormular(User user) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _bereichTitel("Profildaten")),
              TextButton.icon(
                onPressed: wirdGespeichert
                    ? null
                    : () {
                        setState(() {
                          bearbeitungsModus = !bearbeitungsModus;
                        });
                      },
                icon: Icon(
                  bearbeitungsModus ? Icons.close : Icons.edit_outlined,
                  color: const Color(0xff5b2cff),
                ),
                label: Text(
                  bearbeitungsModus ? "Schließen" : "Bearbeiten",
                  style: const TextStyle(
                    color: Color(0xff5b2cff),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _profilUebersicht(user),
          const SizedBox(height: 14),
          _profilbildBox(user),
          const SizedBox(height: 16),
          if (bearbeitungsModus) ...[
            if (kontoTyp == "privat") ...[
              _feld(controller: benutzernameController, label: "Benutzername", icon: Icons.alternate_email),
              _feld(controller: vornameController, label: "Vorname", icon: Icons.person_outline),
              _feld(controller: nachnameController, label: "Nachname", icon: Icons.person_outline),
              _feld(controller: telefonController, label: "Telefon", icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
              _feld(controller: ortController, label: "Ort", icon: Icons.location_on_outlined),
            ] else ...[
              _infoBox(
                icon: Icons.business_outlined,
                text: "Du nutzt ein Firmenkonto. Deine privaten Firmendaten bleiben intern und werden nicht öffentlich angezeigt.",
              ),
              const SizedBox(height: 12),
              _gewerbescheinUploadBox(user),
              const SizedBox(height: 12),
              _feld(controller: benutzernameController, label: "Benutzername", icon: Icons.alternate_email),
              _feld(controller: firmennameController, label: "Firmenname", icon: Icons.business_outlined),
              _feld(controller: rechtsformController, label: "Rechtsform", icon: Icons.account_balance_outlined),
              _feld(controller: uidNummerController, label: "UID-/USt-ID Nummer", icon: Icons.badge_outlined),
              _feld(controller: ansprechpartnerController, label: "Ansprechpartner", icon: Icons.person_outline),
              _feld(controller: telefonController, label: "Telefon", icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
              _feld(controller: webseiteController, label: "Webseite", icon: Icons.language_outlined),
              _feld(controller: strasseController, label: "Straße und Hausnummer", icon: Icons.location_city_outlined),
              _feld(controller: plzController, label: "PLZ", icon: Icons.pin_outlined, keyboardType: TextInputType.number),
              _feld(controller: ortController, label: "Ort", icon: Icons.location_on_outlined),
              _feld(controller: landController, label: "Land", icon: Icons.flag_outlined),
            ],
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                icon: wirdGespeichert
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff5b2cff),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: wirdGespeichert ? null : () => datenSpeichern(user),
                label: Text(
                  wirdGespeichert ? "Wird gespeichert..." : "Daten speichern",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _profilbildBox(User user) {
    final hatProfilbild = profilBildUrl.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xfff7f7fb),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hatProfilbild ? const Color(0xffded4ff) : const Color(0xffececf4),
        ),
      ),
      child: Row(
        children: [
          _profilAvatar(
            radius: 31,
            fallbackIcon: kontoTyp == "firma" ? Icons.business : Icons.person,
            backgroundColor: const Color(0xffeee8ff),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hatProfilbild ? "Profilbild ist aktiv" : "Noch kein Profilbild",
                  style: const TextStyle(
                    color: Color(0xff050b2c),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Du kannst dein Profilbild jederzeit ändern.",
                  style: TextStyle(
                    color: Color(0xff74788d),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              SizedBox(
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: wirdProfilbildHochgeladen ? null : () => profilbildHochladen(user),
                  icon: wirdProfilbildHochgeladen
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.upload, color: Colors.white, size: 18),
                  label: Text(
                    wirdProfilbildHochgeladen
                        ? "Lädt..."
                        : hatProfilbild
                            ? "Ändern"
                            : "Hochladen",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5b2cff),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              if (hatProfilbild) ...[
                const SizedBox(height: 6),
                SizedBox(
                  height: 36,
                  child: TextButton.icon(
                    onPressed: wirdProfilbildGeloescht ? null : () => profilbildLoeschen(user),
                    icon: wirdProfilbildGeloescht
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline, color: Colors.red, size: 17),
                    label: const Text(
                      "Entfernen",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _gewerbescheinUploadBox(User user) {
    final hatGewerbeschein = gewerbescheinUrl.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xfff7f7fb),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hatGewerbeschein
              ? Colors.green.withOpacity(0.35)
              : const Color(0xffececf4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hatGewerbeschein ? Icons.description : Icons.description_outlined,
                color: hatGewerbeschein ? Colors.green : const Color(0xff5b2cff),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hatGewerbeschein
                      ? "Firmendokument ist hochgeladen"
                      : "Noch kein Firmendokument hochgeladen",
                  style: TextStyle(
                    color: hatGewerbeschein ? Colors.green : const Color(0xff050b2c),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Erlaubt sind PDF, JPG, JPEG oder PNG. Das Dokument bleibt privat und ist nur für dich und den Admin sichtbar.",
            style: TextStyle(
              color: Color(0xff74788d),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: wirdGewerbescheinHochgeladen ? null : () => gewerbescheinHochladen(user),
              icon: wirdGewerbescheinHochgeladen
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file, color: Colors.white),
              label: Text(
                wirdGewerbescheinHochgeladen
                    ? "Wird hochgeladen..."
                    : hatGewerbeschein
                        ? "Dokument ersetzen"
                        : "Dokument hochladen",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff5b2cff),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profilUebersicht(User user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xfff7f7fb),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffececf4)),
      ),
      child: Row(
        children: [
          _profilAvatar(
            radius: 28,
            fallbackIcon: kontoTyp == "firma" ? Icons.business : Icons.person,
            backgroundColor: const Color(0xffeee8ff),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  anzeigenName(user),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff050b2c),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(kontoStatusIcon(), size: 16, color: const Color(0xff5b2cff)),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        kontoStatusText(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xff74788d),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  "Mitglied seit: ${mitgliedSeitText()}",
                  style: const TextStyle(color: Color(0xff74788d), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox({required IconData icon, required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xfff1edff),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffded4ff)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff5b2cff)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xff050b2c),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feld({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xff5b2cff)),
          filled: true,
          fillColor: const Color(0xfff7f7fb),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _aktionsBereich() {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
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
          _bereichTitel("Schnellzugriff"),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _aktionsButton(
                  icon: Icons.chat_bubble_outline,
                  text: "Chats",
                  farbe: const Color(0xff5b2cff),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatlisteSeite()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _aktionsButton(
                  icon: Icons.inventory_2_outlined,
                  text: "Inserate",
                  farbe: const Color(0xff050b2c),
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _aktionsButton(
                  icon: Icons.settings_outlined,
                  text: "Einstellungen",
                  farbe: Colors.blueGrey,
                  onTap: user == null ? () {} : () => _einstellungenOeffnen(user),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _aktionsButton(
                  icon: kontoTyp == "firma" ? Icons.business_outlined : Icons.person_outline,
                  text: kontoTyp == "firma" ? "Firma" : "Privat",
                  farbe: const Color(0xff7a5cff),
                  onTap: () {
                    setState(() {
                      bearbeitungsModus = true;
                    });
                  },
                ),
              ),
            ],
          ),
          if (istAdmin) ...[
            const SizedBox(height: 10),
            _aktionsButton(
              icon: Icons.admin_panel_settings_outlined,
              text: "Admin-Zentrale",
              farbe: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminZentraleSeite()),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _aktionsButton({
    required IconData icon,
    required String text,
    required Color farbe,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: farbe,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: farbe.withOpacity(0.20),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bereichTitel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xff050b2c),
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
  }


  Widget _meineInserateSwipeBereich(List<Produkt> produkte) {
    final aktiveProdukte = [...produkte]
      ..sort((a, b) => a.titel.toLowerCase().compareTo(b.titel.toLowerCase()));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xff5b2cff).withOpacity(0.11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xff5b2cff),
                  size: 23,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Meine Inserate (${aktiveProdukte.length})",
                  style: const TextStyle(
                    color: Color(0xff050b2c),
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Icon(Icons.swipe_right_alt, color: Color(0xff5b2cff)),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Nach rechts swipen, um deine Inserate schnell zu prüfen und zu bearbeiten.",
            style: TextStyle(
              color: Color(0xff74788d),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          if (aktiveProdukte.isEmpty)
            _leerKarte()
          else
            SizedBox(
              height: 520,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: aktiveProdukte.length,
                itemBuilder: (context, index) {
                  return _inseratSwipeKarte(aktiveProdukte[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _inseratSwipeKarte(Produkt produkt) {
    final preisText = _produktPreisText(produkt);
    final detailChips = _inseratDetailChips(produkt).take(3).toList();

    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: const Color(0xfffbfbff),
        borderRadius: BorderRadius.circular(24),
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
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailSeite(produkt: produkt)),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        child: produkt.bild.isEmpty
                            ? _platzhalterBildKompakt(produkt)
                            : Image.network(
                                produkt.bild,
                                height: 135,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _platzhalterBildKompakt(produkt);
                                },
                              ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: _bildBadge(produkt.kategorie.isEmpty ? "Inserat" : produkt.kategorie),
                      ),
                      if (produkt.typ.trim().isNotEmpty)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: _bildBadge(produkt.typ == "Firma" ? "Firma" : "Privat"),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 11, 12, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          produkt.titel.isEmpty ? "Inserat" : produkt.titel,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xff050b2c),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          preisText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xff5b2cff),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 15,
                              color: Color(0xff74788d),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                [produkt.ort, produkt.kategorie]
                                    .where((e) => e.trim().isNotEmpty)
                                    .join(" • "),
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
                        if (detailChips.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: detailChips,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 43,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 17),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff5b2cff),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InseratBearbeitenSeite(produkt: produkt),
                          ),
                        );
                      },
                      label: const Text(
                        "Bearbeiten",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 45,
                  height: 43,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () => inseratLoeschen(produkt),
                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 19),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _platzhalterBildKompakt(Produkt produkt) {
    return Container(
      height: 135,
      width: double.infinity,
      color: const Color(0xfff1edff),
      child: Icon(produkt.icon, color: const Color(0xff5b2cff), size: 42),
    );
  }

  Widget _leerKarte() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffececf4)),
      ),
      child: const Column(
        children: [
          Icon(Icons.inventory_2_outlined, color: Color(0xff5b2cff), size: 46),
          SizedBox(height: 12),
          Text(
            "Noch keine Inserate erstellt.",
            style: TextStyle(
              color: Color(0xff050b2c),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String _produktPreisText(Produkt produkt) {
    final preis = produkt.preis.trim();
    if (preis.isEmpty) return "Preis auf Anfrage";
    return preis.endsWith("€") ? preis : "$preis €";
  }

  List<Widget> _inseratDetailChips(Produkt produkt) {
    final chips = <Widget>[];

    void add(String text, IconData icon, {Color farbe = const Color(0xff5b2cff)}) {
      final sauber = text.trim();
      if (sauber.isEmpty) return;
      chips.add(_detailChip(icon: icon, text: sauber, farbe: farbe));
    }

    add(produkt.typ, produkt.typ == "Firma" ? Icons.business_outlined : Icons.person_outline);
    add(produkt.unterkategorie, Icons.category_outlined);
    add(produkt.detailUnterkategorie, Icons.tune_outlined);

    if (produkt.kategorie == "Auto & Motor" || produkt.kategorie == "Autos") {
      final markeModell = [produkt.marke, produkt.modell]
          .where((e) => e.trim().isNotEmpty)
          .join(" ");
      add(markeModell, Icons.directions_car_outlined);
      add(produkt.baujahr.isEmpty ? "" : "Baujahr ${produkt.baujahr}", Icons.calendar_month_outlined);
      add(produkt.kilometer.isEmpty ? "" : "${produkt.kilometer} km", Icons.speed_outlined);
      add(produkt.kraftstoff, Icons.local_gas_station_outlined);
      add(produkt.getriebe, Icons.settings_outlined);
      add(produkt.leistung.isEmpty ? "" : "${produkt.leistung} PS", Icons.flash_on_outlined);
    } else if (produkt.kategorie == "Immobilien") {
      add(produkt.immobilienArt, Icons.home_work_outlined);
      add(produkt.wohnflaeche.isEmpty ? "" : "${produkt.wohnflaeche} m²", Icons.square_foot_outlined);
      add(produkt.zimmer.isEmpty ? "" : "${produkt.zimmer} Zimmer", Icons.meeting_room_outlined);
      add(produkt.betriebskosten.isEmpty ? "" : "BK ${produkt.betriebskosten}", Icons.receipt_long_outlined);
      add(produkt.etage.isEmpty ? "" : "Etage ${produkt.etage}", Icons.stairs_outlined);
    } else if (produkt.kategorie == "Boote") {
      final bootName = [produkt.bootMarke, produkt.bootModell]
          .where((e) => e.trim().isNotEmpty)
          .join(" ");
      add(produkt.bootstyp, Icons.sailing_outlined);
      add(bootName, Icons.directions_boat_outlined);
      add(produkt.bootBaujahr.isEmpty ? "" : "Baujahr ${produkt.bootBaujahr}", Icons.calendar_month_outlined);
      add(produkt.bootLaenge.isEmpty ? "" : "${produkt.bootLaenge} Länge", Icons.straighten_outlined);
      add(produkt.bootLeistung.isEmpty ? "" : "${produkt.bootLeistung} PS", Icons.flash_on_outlined);
    } else if (produkt.kategorie == "Baumaschinen") {
      add(produkt.baumaschinenZustand, Icons.construction_outlined);
      add(produkt.baumaschinenBaujahr.isEmpty ? "" : "Baujahr ${produkt.baumaschinenBaujahr}", Icons.calendar_month_outlined);
      add(produkt.baumaschinenBetriebsstunden.isEmpty ? "" : "${produkt.baumaschinenBetriebsstunden} Std.", Icons.timer_outlined);
      add(produkt.baumaschinenGewicht.isEmpty ? "" : "${produkt.baumaschinenGewicht} Gewicht", Icons.scale_outlined);
    } else {
      add(produkt.zustand, Icons.verified_outlined);
      add(produkt.hersteller, Icons.factory_outlined);
      add(produkt.garantie.isEmpty ? "" : "Garantie ${produkt.garantie}", Icons.shield_outlined);
    }

    if (chips.length > 8) return chips.take(8).toList();
    return chips;
  }

  Widget _detailChip({
    required IconData icon,
    required String text,
    Color farbe = const Color(0xff5b2cff),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: farbe.withOpacity(0.09),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: farbe.withOpacity(0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: farbe, size: 15),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: farbe,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inseratKarte(Produkt produkt) {
    final preisText = _produktPreisText(produkt);
    final detailChips = _inseratDetailChips(produkt);
    final kurzBeschreibung = produkt.beschreibung.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
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
            borderRadius: BorderRadius.circular(26),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailSeite(produkt: produkt)),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(26),
                        topRight: Radius.circular(26),
                      ),
                      child: produkt.bild.isEmpty
                          ? _platzhalterBild(produkt)
                          : Image.network(
                              produkt.bild,
                              height: 190,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _platzhalterBild(produkt);
                              },
                            ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _bildBadge(produkt.kategorie.isEmpty ? "Inserat" : produkt.kategorie),
                    ),
                    if (produkt.typ.trim().isNotEmpty)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: _bildBadge(produkt.typ),
                      ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.62),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                preisText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produkt.titel.isEmpty ? "Inserat" : produkt.titel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xff050b2c),
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Color(0xff74788d),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              [produkt.ort, produkt.kategorie]
                                  .where((e) => e.trim().isNotEmpty)
                                  .join(" • "),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xff74788d),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (kurzBeschreibung.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          kurzBeschreibung,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xff050b2c),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ],
                      if (detailChips.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: detailChips,
                        ),
                      ],
                      const SizedBox(height: 12),
                      _inseratStatistikNurBesitzer(produkt),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff5b2cff),
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InseratBearbeitenSeite(produkt: produkt),
                        ),
                      );
                    },
                    label: const Text(
                      "Bearbeiten",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                    ),
                    onPressed: () => inseratLoeschen(produkt),
                    label: const Text(
                      "Löschen",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xff050b2c),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }


  Widget _inseratStatistikNurBesitzer(Produkt produkt) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();
    if (produkt.verkaeuferId.trim() != user.uid) return const SizedBox();
    if (produkt.id.trim().isEmpty) return const SizedBox();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("inserate")
          .doc(produkt.id)
          .snapshots(),
      builder: (context, inseratSnapshot) {
        int aufrufe = 0;

        final data = inseratSnapshot.data?.data();
        if (data is Map<String, dynamic>) {
          final wert = data["aufrufe"];
          if (wert is num) {
            aufrufe = wert.toInt();
          }
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("favoriten")
              .where("produktId", isEqualTo: produkt.id)
              .snapshots(),
          builder: (context, favoritenSnapshot) {
            final favoriten = favoritenSnapshot.data?.docs.length ?? 0;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("chats")
                  .where("produktId", isEqualTo: produkt.id)
                  .snapshots(),
              builder: (context, chatsSnapshot) {
                final anfragen = chatsSnapshot.data?.docs.length ?? 0;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xfff7f7fb),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xffececf4)),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _kleinerStatistikChip(
                        icon: Icons.visibility_outlined,
                        text: "$aufrufe Aufruf${aufrufe == 1 ? "" : "e"}",
                        farbe: const Color(0xff5b2cff),
                      ),
                      _kleinerStatistikChip(
                        icon: Icons.favorite_border,
                        text: "$favoriten Favorit${favoriten == 1 ? "" : "en"}",
                        farbe: Colors.red,
                      ),
                      _kleinerStatistikChip(
                        icon: Icons.chat_bubble_outline,
                        text: "$anfragen Anfrage${anfragen == 1 ? "" : "n"}",
                        farbe: Colors.orange,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _kleinerStatistikChip({
    required IconData icon,
    required String text,
    required Color farbe,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: farbe.withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: farbe.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: farbe, size: 16),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: farbe,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _platzhalterBild(Produkt produkt) {
    return Container(
      height: 190,
      width: double.infinity,
      color: const Color(0xfff1edff),
      child: Icon(produkt.icon, color: const Color(0xff5b2cff), size: 56),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout, color: Colors.white),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff050b2c),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
        },
        label: const Text(
          "Abmelden",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}