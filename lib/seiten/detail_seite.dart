// lib/seiten/detail_seite.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/produkt.dart';
import 'chat_seite.dart';
import 'firmen_profil_seite.dart';
import 'inserat_melden_seite.dart';
import 'inserat_bearbeiten_seite.dart';

class DetailSeite extends StatefulWidget {
  final Produkt produkt;

  const DetailSeite({
    super.key,
    required this.produkt,
  });

  @override
  State<DetailSeite> createState() => _DetailSeiteState();
}

class _DetailSeiteState extends State<DetailSeite> {
  int aktuellesBild = 0;
  bool istFavorit = false;
  bool favoritLaedt = false;

  @override
  void initState() {
    super.initState();
    favoritPruefen();
    aufrufZaehlen();
  }

  bool istEigenesInserat() {
    final user = FirebaseAuth.instance.currentUser;
    final verkaeuferId = widget.produkt.verkaeuferId.trim();

    return user != null &&
        verkaeuferId.isNotEmpty &&
        user.uid == verkaeuferId;
  }

  Future<void> aufrufZaehlen() async {
    if (widget.produkt.id.trim().isEmpty) return;
    if (istEigenesInserat()) return;

    try {
      await FirebaseFirestore.instance
          .collection("inserate")
          .doc(widget.produkt.id)
          .set({
        "aufrufe": FieldValue.increment(1),
        "letzterAufruf": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Aufrufe sollen die Detailseite nie blockieren.
    }
  }

  Future<void> favoritPruefen() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.produkt.id.isEmpty) return;

    final favId = "${user.uid}_${widget.produkt.id}";
    final doc = await FirebaseFirestore.instance
        .collection("favoriten")
        .doc(favId)
        .get();

    if (!mounted) return;
    setState(() {
      istFavorit = doc.exists;
    });
  }

  Future<void> favoritWechseln() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bitte zuerst einloggen.")),
      );
      return;
    }

    if (widget.produkt.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fehler: Produkt-ID fehlt.")),
      );
      return;
    }

    setState(() {
      favoritLaedt = true;
    });

    try {
      final favId = "${user.uid}_${widget.produkt.id}";
      final favRef = FirebaseFirestore.instance.collection("favoriten").doc(favId);

      if (istFavorit) {
        await favRef.delete();
        if (mounted) {
          setState(() {
            istFavorit = false;
          });
        }
      } else {
        await favRef.set({
          "userId": user.uid,
          "userEmail": user.email ?? "",
          "produktId": widget.produkt.id,
          "produktTitel": widget.produkt.titel,
          "produktBild": widget.produkt.bild,
          "produktPreis": widget.produkt.preis,
          "produktOrt": widget.produkt.ort,
          "verkaeuferId": widget.produkt.verkaeuferId,
          "verkaeuferEmail": widget.produkt.verkaeuferEmail,
          "erstelltAm": FieldValue.serverTimestamp(),
        });
        if (mounted) {
          setState(() {
            istFavorit = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Favorit Fehler: $e")),
        );
      }
    }

    if (mounted) {
      setState(() {
        favoritLaedt = false;
      });
    }
  }

  bool istVermietung() {
    const vermietungen = [
      "Autovermietung",
      "Bootsvermietung",
      "Baumaschinenvermietung",
      "Anhängervermietung",
      "Maschinenvermietung",
    ];

    return vermietungen.contains(widget.produkt.unterkategorie) ||
        vermietungen.contains(widget.produkt.detailUnterkategorie);
  }

  String mitEinheit(String wert, String einheit) {
    final sauber = wert.trim();
    if (sauber.isEmpty) return "";
    if (sauber.toLowerCase().contains(einheit.toLowerCase())) return sauber;
    return "$sauber $einheit";
  }

  String preisText(Produkt produkt) {
    final preis = produkt.preis.trim();
    if (preis.isEmpty) return "Preis auf Anfrage";
    if (preis.endsWith("€")) return preis;
    return "$preis €";
  }

  Future<void> inseratTeilen() async {
    final text = [
      widget.produkt.titel,
      preisText(widget.produkt),
      widget.produkt.ort,
      "",
      "Inserat-ID: ${widget.produkt.id}",
      "Geteilt über Handelswelt",
    ].join("\n");

    await Clipboard.setData(ClipboardData(text: text));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Inserat wurde in die Zwischenablage kopiert."),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> emailSenden() async {
    final email = widget.produkt.verkaeuferEmail.trim();
    if (email.isEmpty) return;
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> telefonKopieren() async {
    final telefon = widget.produkt.telefon.trim();
    if (telefon.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: telefon));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Telefonnummer wurde kopiert."),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> inseratLoeschen() async {
    if (!istEigenesInserat()) return;
    if (widget.produkt.id.trim().isEmpty) return;

    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text(
            "Inserat löschen?",
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text("Möchtest du dieses Inserat wirklich löschen?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Abbrechen"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Löschen",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    if (bestaetigt != true) return;

    try {
      await FirebaseFirestore.instance
          .collection("inserate")
          .doc(widget.produkt.id)
          .delete();

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Inserat wurde gelöscht."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Fehler beim Löschen: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final bilder = widget.produkt.bilder.isNotEmpty
        ? widget.produkt.bilder
        : [widget.produkt.bild];

    final breit = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            breit ? 46 : 16,
            16,
            breit ? 46 : 16,
            24,
          ),
          children: [
            _kopfzeile(context),
            const SizedBox(height: 16),
            if (breit)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: _bilderGalerie(bilder)),
                  const SizedBox(width: 18),
                  Expanded(flex: 4, child: _seitenInfo()),
                ],
              )
            else ...[
              _bilderGalerie(bilder),
              const SizedBox(height: 16),
              _seitenInfo(),
            ],
            const SizedBox(height: 18),
            _details(),
            const SizedBox(height: 18),
            _beschreibung(),
            const SizedBox(height: 18),
            _standort(),
            const SizedBox(height: 18),
            _weitereInserateVomVerkaeufer(),
          ],
        ),
      ),
    );
  }

  Widget _kopfzeile(BuildContext context) {
    return Row(
      children: [
        IconButton(
          style: IconButton.styleFrom(backgroundColor: Colors.white),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xff050b2c)),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            "Inserat Details",
            style: TextStyle(
              color: Color(0xff050b2c),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        IconButton(
          style: IconButton.styleFrom(backgroundColor: Colors.white),
          onPressed: inseratTeilen,
          icon: const Icon(Icons.share_outlined, color: Color(0xff050b2c)),
        ),
        if (istEigenesInserat()) ...[
          IconButton(
            style: IconButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InseratBearbeitenSeite(produkt: widget.produkt),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined, color: Color(0xff5b2cff)),
          ),
          IconButton(
            style: IconButton.styleFrom(backgroundColor: const Color(0xffffedf1)),
            onPressed: inseratLoeschen,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: istFavorit ? const Color(0xffffedf1) : Colors.white,
          ),
          onPressed: favoritLaedt ? null : favoritWechseln,
          icon: favoritLaedt
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  istFavorit ? Icons.favorite : Icons.favorite_border,
                  color: istFavorit ? Colors.red : const Color(0xff050b2c),
                ),
        ),
      ],
    );
  }

  Widget _bilderGalerie(List<String> bilder) {
    return Container(
      height: 390,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffececf4)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: bilder.length,
            onPageChanged: (index) {
              setState(() {
                aktuellesBild = index;
              });
            },
            itemBuilder: (context, index) {
              final bild = bilder[index];
              if (bild.isEmpty) return _platzhalterBild(widget.produkt.icon, 80);

              return SizedBox.expand(
                child: Image.network(
                  bild,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _platzhalterBild(widget.produkt.icon, 80);
                  },
                ),
              );
            },
          ),
          if (bilder.length > 1)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(bilder.length, (i) => Container(
                  width: i == aktuellesBild ? 18 : 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == aktuellesBild
                        ? const Color(0xff5b2cff)
                        : Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                )),
              ),
            ),
        ],
      ),
    );
  }

  Widget _platzhalterBild(IconData icon, double groesse) {
    return Container(
      color: const Color(0xfff1edff),
      child: Icon(
        icon,
        color: const Color(0xff5b2cff),
        size: groesse,
      ),
    );
  }

  Widget _seitenInfo() {
    return Column(
      children: [
        _karte(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.produkt.titel,
                style: const TextStyle(
                  color: Color(0xff050b2c),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                preisText(widget.produkt),
                style: const TextStyle(
                  color: Color(0xff5b2cff),
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(widget.produkt.kategorie, const Color(0xfff1edff), const Color(0xff5b2cff)),
                  if (widget.produkt.unterkategorie.isNotEmpty)
                    _chip(widget.produkt.unterkategorie, const Color(0xffeaf7ff), Colors.blue),
                  if (widget.produkt.detailUnterkategorie.isNotEmpty)
                    _chip(widget.produkt.detailUnterkategorie, const Color(0xffeef8ee), Colors.green),
                  _chip(
                    widget.produkt.typ,
                    widget.produkt.typ == "Firma" ? const Color(0xffffefe0) : const Color(0xffe8f8ee),
                    widget.produkt.typ == "Firma" ? Colors.orange : Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Color(0xff74788d), size: 19),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      widget.produkt.ort,
                      style: const TextStyle(
                        color: Color(0xff74788d),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (istEigenesInserat()) ...[
                const SizedBox(height: 14),
                _statistikBlockNurFuerBesitzer(),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _verkaeuferKarte(),
        const SizedBox(height: 14),
        _kontaktButtons(),
      ],
    );
  }

  Widget _verkaeuferKarte() {
    final istFirma = widget.produkt.typ == "Firma";
    final istVerifiziert = widget.produkt.firmaVerifiziert;
    final name = istFirma
        ? (widget.produkt.firmenname.trim().isEmpty ? "Firma" : widget.produkt.firmenname.trim())
        : "Privatverkäufer";

    final karte = _karte(
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xfff1edff),
            child: Icon(
              istFirma ? Icons.business : Icons.person,
              color: const Color(0xff5b2cff),
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff050b2c),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _chip(
                      istVerifiziert ? "✅ Verifizierte Firma" : (istFirma ? "⏳ Firma in Prüfung" : "👤 Privat"),
                      istVerifiziert ? const Color(0xffffefe0) : (istFirma ? const Color(0xfffff6df) : const Color(0xffe8f8ee)),
                      istVerifiziert ? Colors.orange : (istFirma ? Colors.amber : Colors.green),
                    ),
                    if (widget.produkt.ort.trim().isNotEmpty)
                      _chip("📍 ${widget.produkt.ort}", const Color(0xfff4f4f8), const Color(0xff74788d)),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  istFirma
                      ? "Kontakt per E-Mail"
                      : "Kontakt über Nachrichten",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff74788d),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (istFirma && widget.produkt.webseite.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.produkt.webseite.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xff5b2cff),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (istVerifiziert)
            const Icon(Icons.arrow_forward_ios, size: 17, color: Color(0xff74788d)),
        ],
      ),
    );

    if (!istVerifiziert || widget.produkt.verkaeuferId.trim().isEmpty) {
      return karte;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: _firmenProfilOeffnen,
      child: karte,
    );
  }

  void _firmenProfilOeffnen() {
    if (!widget.produkt.firmaVerifiziert) return;
    if (widget.produkt.verkaeuferId.trim().isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FirmenProfilSeite(
          userId: widget.produkt.verkaeuferId,
          firmenname: widget.produkt.firmenname.trim().isEmpty
              ? "Firma"
              : widget.produkt.firmenname.trim(),
        ),
      ),
    );
  }

  Widget _kontaktButtons() {
    final istFirmaKontakt = widget.produkt.typ == "Firma";

    return Column(
      children: [
        if (istFirmaKontakt && widget.produkt.verkaeuferEmail.trim().isNotEmpty) ...[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff5b2cff),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onPressed: emailSenden,
              icon: const Icon(
                Icons.email_outlined,
                color: Colors.white,
              ),
              label: const Text(
                "E-Mail senden",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ] else ...[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff5b2cff),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatSeite(
                      verkaeuferId: widget.produkt.verkaeuferId,
                      verkaeuferEmail: widget.produkt.verkaeuferEmail,
                      produktId: widget.produkt.id,
                      produktTitel: widget.produkt.titel,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
              ),
              label: const Text(
                "Nachricht senden",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xff5b2cff)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            onPressed: inseratTeilen,
            icon: const Icon(
              Icons.share_outlined,
              color: Color(0xff5b2cff),
            ),
            label: const Text(
              "Inserat teilen",
              style: TextStyle(
                color: Color(0xff5b2cff),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        if (widget.produkt.firmaVerifiziert) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xff5b2cff)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onPressed: _firmenProfilOeffnen,
              icon: const Icon(
                Icons.business_outlined,
                color: Color(0xff5b2cff),
              ),
              label: const Text(
                "Firmenprofil ansehen",
                style: TextStyle(
                  color: Color(0xff5b2cff),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InseratMeldenSeite(
                    inseratId: widget.produkt.id,
                    titel: widget.produkt.titel,
                    verkaeuferId: widget.produkt.verkaeuferId,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.flag_outlined,
              color: Colors.red,
            ),
            label: const Text(
              "Inserat melden",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        if ((widget.produkt.telefonSichtbar || widget.produkt.typ == "Firma") &&
            widget.produkt.telefon.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onPressed: telefonKopieren,
              icon: const Icon(Icons.phone_outlined),
              label: Text(
                widget.produkt.telefon,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _statistikBlockNurFuerBesitzer() {
    if (!istEigenesInserat() || widget.produkt.id.trim().isEmpty) {
      return const SizedBox();
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("inserate")
          .doc(widget.produkt.id)
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
              .where("produktId", isEqualTo: widget.produkt.id)
              .snapshots(),
          builder: (context, favoritenSnapshot) {
            final favoriten = favoritenSnapshot.data?.docs.length ?? 0;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("chats")
                  .where("produktId", isEqualTo: widget.produkt.id)
                  .snapshots(),
              builder: (context, chatsSnapshot) {
                final nachrichten = chatsSnapshot.data?.docs.length ?? 0;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xfff7f7fb),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xffececf4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            color: Color(0xff5b2cff),
                            size: 20,
                          ),
                          SizedBox(width: 7),
                          Text(
                            "Inserat-Statistik",
                            style: TextStyle(
                              color: Color(0xff050b2c),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _statistikChip(
                            icon: Icons.visibility_outlined,
                            text: "$aufrufe Aufruf${aufrufe == 1 ? "" : "e"}",
                            farbe: const Color(0xff5b2cff),
                          ),
                          _statistikChip(
                            icon: Icons.favorite_border,
                            text: "$favoriten Favorit${favoriten == 1 ? "" : "en"}",
                            farbe: Colors.red,
                          ),
                          _statistikChip(
                            icon: Icons.chat_bubble_outline,
                            text: "$nachrichten Anfrage${nachrichten == 1 ? "" : "n"}",
                            farbe: Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      const Text(
                        "Nur für dich als Inserat-Besitzer sichtbar.",
                        style: TextStyle(
                          color: Color(0xff74788d),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
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

  Widget _statistikChip({
    required IconData icon,
    required String text,
    required Color farbe,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: farbe.withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: farbe.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: farbe, size: 17),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: farbe,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _details() {
    return _karte(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Details",
            style: TextStyle(
              color: Color(0xff050b2c),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _detailZeile("Kategorie", widget.produkt.kategorie),
          _detailZeile("Unterkategorie", widget.produkt.unterkategorie),
          _detailZeile("Detail-Unterkategorie", widget.produkt.detailUnterkategorie),
          const SizedBox(height: 8),

          if (istVermietung()) ...[
            _detailZeile("Mietpreis pro Tag", widget.produkt.mietpreisTag),
            _detailZeile("Mietpreis pro Woche", widget.produkt.mietpreisWoche),
            _detailZeile("Mietpreis pro Monat", widget.produkt.mietpreisMonat),
            _detailZeile("Kaution", widget.produkt.kaution),
            _detailZeile("Mindestmietdauer", widget.produkt.mindestmietdauer),
            _detailZeile("Versicherung", widget.produkt.versicherung),
            _detailZeile("Lieferung möglich", widget.produkt.lieferungMoeglich),
          ],

          if (widget.produkt.kategorie == "Jobs") ...[
            _detailZeile("Beschäftigungsart", widget.produkt.jobBeschaeftigungsart),
            _detailZeile("Gehalt", widget.produkt.jobGehalt),
            _detailZeile("Arbeitsort", widget.produkt.jobArbeitsort),
            _detailZeile("Berufserfahrung", widget.produkt.jobErfahrung),
            _detailZeile("Homeoffice", widget.produkt.jobHomeoffice),
            _detailZeile("Führerschein", widget.produkt.jobFuehrerschein),
          ],

          if (widget.produkt.kategorie == "Dienstleistungen") ...[
            _detailZeile("Einsatzgebiet", widget.produkt.dienstleistungEinsatzgebiet),
            _detailZeile("Preis pro Stunde", widget.produkt.dienstleistungPreisProStunde),
            _detailZeile("Öffnungszeiten", widget.produkt.dienstleistungOeffnungszeiten),
            _detailZeile("Anfahrt möglich", widget.produkt.dienstleistungAnfahrt),
            _detailZeile("24h Notdienst", widget.produkt.dienstleistungNotdienst),
          ],

          if (widget.produkt.kategorie == "Auto & Motor" && !istVermietung()) ...[
            _detailZeile("Marke", widget.produkt.marke),
            _detailZeile("Modell", widget.produkt.modell),
            _detailZeile("Baujahr", widget.produkt.baujahr),
            _detailZeile("Erstzulassung", widget.produkt.erstzulassung),
            _detailZeile("Kilometer", mitEinheit(widget.produkt.kilometer, "km")),
            _detailZeile("Kraftstoff", widget.produkt.kraftstoff),
            _detailZeile("Getriebe", widget.produkt.getriebe),
            _detailZeile("Leistung", mitEinheit(widget.produkt.leistung, "PS")),
            _detailZeile("Hubraum", mitEinheit(widget.produkt.hubraum, "cm³")),
            _detailZeile("Verbrauch", mitEinheit(widget.produkt.verbrauch, "l/100km")),
            _detailZeile("CO₂", mitEinheit(widget.produkt.co2, "g/km")),
            _detailZeile("Schlüssel", widget.produkt.schluessel),
            _detailZeile("Farbe", widget.produkt.farbe),
            _detailZeile("Karosserie", widget.produkt.karosserie),
            _detailZeile("Antrieb", widget.produkt.antrieb),
            _detailZeile("Türen", widget.produkt.tueren),
            _detailZeile("Sitze", widget.produkt.sitze),
            _detailZeile("Pickerl/TÜV", widget.produkt.tuev),
            _detailZeile("Pickerl neu", widget.produkt.pickerlNeu),
            _detailZeile("Unfallfrei", widget.produkt.unfallfrei),
            _detailZeile("Serviceheft", widget.produkt.serviceheft),
            _detailZeile("Nichtraucher", widget.produkt.nichtraucher),
            _detailZeile("MwSt.", widget.produkt.mwstAusweisbar),
            _detailZeile("Leasing", widget.produkt.leasingMoeglich),
            _detailZeile("Finanzierung", widget.produkt.finanzierungMoeglich),
            _detailZeile("Inzahlungnahme", widget.produkt.inzahlungnahmeMoeglich),
            _detailZeile("Zustand", widget.produkt.zustand),
            _detailZeile("Garantie", widget.produkt.garantie),
          ],

          if (widget.produkt.kategorie == "Immobilien") ...[
            _detailZeile("Immobilienart", widget.produkt.immobilienArt),
            _detailZeile("Wohnfläche", mitEinheit(widget.produkt.wohnflaeche, "m²")),
            _detailZeile("Zimmer", widget.produkt.zimmer),
            _detailZeile("Etage", widget.produkt.etage),
            _detailZeile("Kaution", widget.produkt.kaution),
            _detailZeile("Betriebskosten", widget.produkt.betriebskosten),
            _detailZeile("Balkon", widget.produkt.balkon),
            _detailZeile("Terrasse", widget.produkt.terrasse),
            _detailZeile("Garten", widget.produkt.garten),
            _detailZeile("Garage", widget.produkt.garage),
            _detailZeile("Lift", widget.produkt.lift),
            _detailZeile("Keller", widget.produkt.keller),
            _detailZeile("Möbliert", widget.produkt.moebliert),
            _detailZeile("Energieklasse", widget.produkt.energieklasse),
            _detailZeile("Heizung", widget.produkt.heizung),
            _detailZeile("Baujahr", widget.produkt.baujahrImmobilie),
            _detailZeile("Verfügbar ab", widget.produkt.verfuegbarAb),
            _detailZeile("Zustand", widget.produkt.zustand),
          ],

          if (widget.produkt.kategorie == "Boote" && !istVermietung()) ...[
            _detailZeile("Bootstyp", widget.produkt.bootstyp),
            _detailZeile("Marke", widget.produkt.bootMarke),
            _detailZeile("Modell", widget.produkt.bootModell),
            _detailZeile("Baujahr", widget.produkt.bootBaujahr),
            _detailZeile("Länge", mitEinheit(widget.produkt.bootLaenge, "m")),
            _detailZeile("Leistung", mitEinheit(widget.produkt.bootLeistung, "PS")),
          ],

          if (widget.produkt.kategorie == "Baumaschinen" && !istVermietung()) ...[
            _detailZeile("Zustand", widget.produkt.baumaschinenZustand),
            _detailZeile("Baujahr", widget.produkt.baumaschinenBaujahr),
            _detailZeile("Betriebsstunden", mitEinheit(widget.produkt.baumaschinenBetriebsstunden, "h")),
            _detailZeile("Kraftstoff", widget.produkt.baumaschinenKraftstoff),
            _detailZeile("Leistung", mitEinheit(widget.produkt.baumaschinenLeistung, "PS")),
            _detailZeile("Gewicht", mitEinheit(widget.produkt.baumaschinenGewicht, "kg")),
          ],

          if (widget.produkt.kategorie == "Baumarkt") ...[
            _detailZeile("Hersteller", widget.produkt.baumarktHersteller),
            _detailZeile("Material", widget.produkt.baumarktMaterial),
            _detailZeile("Farbe", widget.produkt.baumarktFarbe),
            _detailZeile("Maße", widget.produkt.baumarktMasse),
            _detailZeile("Gewicht", mitEinheit(widget.produkt.baumarktGewicht, "kg")),
            _detailZeile("Menge", widget.produkt.baumarktMenge),
          ],

          if (widget.produkt.kategorie != "Auto & Motor" &&
              widget.produkt.kategorie != "Immobilien" &&
              widget.produkt.kategorie != "Boote" &&
              widget.produkt.kategorie != "Baumaschinen" &&
              widget.produkt.kategorie != "Baumarkt" &&
              widget.produkt.kategorie != "Jobs" &&
              widget.produkt.kategorie != "Dienstleistungen" &&
              !istVermietung()) ...[
            _detailZeile("Zustand", widget.produkt.zustand),
            _detailZeile("Hersteller", widget.produkt.hersteller),
            _detailZeile("Garantie", widget.produkt.garantie),
          ],
        ],
      ),
    );
  }

  Widget _beschreibung() {
    return _karte(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Beschreibung",
            style: TextStyle(
              color: Color(0xff050b2c),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.produkt.beschreibung.isEmpty
                ? "Keine Beschreibung vorhanden."
                : widget.produkt.beschreibung,
            style: const TextStyle(color: Color(0xff4d5368), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _standort() {
    return _karte(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Standort",
            style: TextStyle(
              color: Color(0xff050b2c),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 320,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(widget.produkt.latitude, widget.produkt.longitude),
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: "com.handelswelt.app",
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(widget.produkt.latitude, widget.produkt.longitude),
                      width: 45,
                      height: 45,
                      child: const Icon(Icons.location_pin, color: Colors.red, size: 42),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _weitereInserateVomVerkaeufer() {
    final verkaeuferId = widget.produkt.verkaeuferId.trim();
    if (verkaeuferId.isEmpty) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("inserate")
          .where("verkaeuferId", isEqualTo: verkaeuferId)
          .limit(12)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _karte(
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(color: Color(0xff5b2cff)),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox();

        final produkte = snapshot.data!.docs
            .where((doc) => doc.id != widget.produkt.id)
            .map((doc) => Produkt.fromFirestore(doc))
            .take(8)
            .toList();

        if (produkte.isEmpty) return const SizedBox();

        return _karte(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Weitere Inserate vom Verkäufer",
                style: TextStyle(
                  color: Color(0xff050b2c),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: produkte.length,
                  itemBuilder: (context, index) {
                    return _kleineInseratKarte(produkte[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _kleineInseratKarte(Produkt produkt) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailSeite(produkt: produkt)),
        );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xfffafafe),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xffececf4)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 115,
              width: double.infinity,
              child: produkt.bild.trim().isEmpty
                  ? _platzhalterBild(produkt.icon, 42)
                  : Image.network(
                      produkt.bild,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _platzhalterBild(produkt.icon, 42);
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produkt.titel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xff050b2c),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    preisText(produkt),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xff5b2cff),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 15, color: Color(0xff74788d)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          produkt.ort,
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

  Widget _detailZeile(String titel, String wert) {
    final sauber = wert.trim();
    if (sauber.isEmpty || sauber == "m²" || sauber == " m²") return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xffececf4), width: 1)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final schmal = constraints.maxWidth < 430;

          if (schmal) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titel,
                  style: const TextStyle(
                    color: Color(0xff74788d),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sauber,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    color: Color(0xff050b2c),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 170,
                child: Text(
                  titel,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    color: Color(0xff74788d),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  sauber,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    color: Color(0xff050b2c),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _karte({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffececf4)),
      ),
      child: child,
    );
  }
}
