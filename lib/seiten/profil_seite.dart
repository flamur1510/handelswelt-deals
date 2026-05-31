// lib/seiten/profil_seite.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/produkt.dart';

import 'detail_seite.dart';
import 'admin_meldungen_seite.dart';
import 'chatliste_seite.dart';
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
  final emailController = TextEditingController();
  final passwortController = TextEditingController();

  bool login = true;
  bool wirdGeladen = false;

  Future<void> anmelden() async {
    if (emailController.text.trim().isEmpty ||
        passwortController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bitte E-Mail und Passwort eingeben."),
        ),
      );
      return;
    }

    setState(() {
      wirdGeladen = true;
    });

    try {
      if (login) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwortController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwortController.text.trim(),
        );
      }

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Fehler: $e"),
        ),
      );
    }

    setState(() {
      wirdGeladen = false;
    });
  }

  Future<void> inseratLoeschen(Produkt produkt) async {
    await FirebaseFirestore.instance
        .collection("inserate")
        .doc(produkt.id)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Inserat gelöscht"),
      ),
    );

    setState(() {});
  }

  @override
  void dispose() {
    emailController.dispose();
    passwortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _loginAnsicht();
    }

    final meineProdukte =
        widget.produkte.where((p) => p.verkaeuferId == user.uid).toList();

    final istFirma = meineProdukte.any((p) => p.typ == "Firma");

    return Scaffold(
      backgroundColor: const Color(0xfff7f7fb),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            _profilHeader(user, meineProdukte.length, istFirma),
            const SizedBox(height: 18),
            _statistikBereich(meineProdukte),
            const SizedBox(height: 18),
            _aktionsBereich(),
            const SizedBox(height: 24),
            _bereichTitel("Meine Inserate"),
            const SizedBox(height: 14),
            if (meineProdukte.isEmpty)
              _leerKarte()
            else
              for (final produkt in meineProdukte) _inseratKarte(produkt),
            const SizedBox(height: 16),
            _logoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _loginAnsicht() {
    return Scaffold(
      backgroundColor: const Color(0xfff7f7fb),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff070b2f),
                          Color(0xff5b2cff),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    login ? "Willkommen zurück" : "Konto erstellen",
                    style: const TextStyle(
                      color: Color(0xff050b2c),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Melde dich an und verwalte deine Deals.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff74788d),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _loginFeld(
                    controller: emailController,
                    label: "E-Mail",
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 14),
                  _loginFeld(
                    controller: passwortController,
                    label: "Passwort",
                    icon: Icons.lock_outline,
                    geheim: true,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff5b2cff),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: wirdGeladen ? null : anmelden,
                      child: Text(
                        wirdGeladen
                            ? "Bitte warten..."
                            : login
                                ? "Einloggen"
                                : "Registrieren",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        login = !login;
                      });
                    },
                    child: Text(
                      login
                          ? "Noch keinen Account? Registrieren"
                          : "Bereits registriert? Einloggen",
                      style: const TextStyle(
                        color: Color(0xff5b2cff),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginFeld({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool geheim = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: geheim,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xfff2f3f8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _profilHeader(User user, int anzahl, bool istFirma) {
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
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white,
                child: Icon(
                  istFirma ? Icons.business : Icons.person,
                  color: const Color(0xff5b2cff),
                  size: 44,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.email ?? "Benutzer",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          istFirma ? "Verifizierte Firma" : "Privatkonto",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
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
              border: Border.all(
                color: Colors.white.withOpacity(0.16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _headerWert("$anzahl", "Inserate"),
                ),
                Expanded(
                  child: _headerWert("4.9", "Bewertung"),
                ),
                Expanded(
                  child: _headerWert("98%", "Antwort"),
                ),
              ],
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _statistikBereich(List<Produkt> meineProdukte) {
    final firmen = meineProdukte.where((p) => p.typ == "Firma").length;

    return Row(
      children: [
        _statKarte(Icons.inventory_2_outlined, "Inserate",
            "${meineProdukte.length}"),
        const SizedBox(width: 10),
        _statKarte(Icons.business_outlined, "Firma", "$firmen"),
        const SizedBox(width: 10),
        _statKarte(Icons.favorite_border, "Favoriten", "0"),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xff5b2cff),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              wert,
              style: const TextStyle(
                color: Color(0xff050b2c),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              titel,
              style: const TextStyle(
                color: Color(0xff74788d),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aktionsBereich() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _aktionsButton(
                icon: Icons.chat_bubble_outline,
                text: "Meine Chats",
                farbe: const Color(0xff5b2cff),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChatlisteSeite(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _aktionsButton(
                icon: Icons.admin_panel_settings_outlined,
                text: "Admin",
                farbe: Colors.red,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminMeldungenSeite(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
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
            Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
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

  Widget _leerKarte() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: Color(0xff5b2cff),
            size: 46,
          ),
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

  Widget _inseratKarte(Produkt produkt) {
    final preisText =
        produkt.preis.endsWith("€") ? produkt.preis : "${produkt.preis} €";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
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
                MaterialPageRoute(
                  builder: (_) => DetailSeite(
                    produkt: produkt,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                          height: 210,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _platzhalterBild(produkt);
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produkt.titel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xff050b2c),
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
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
                              "${produkt.ort} • ${produkt.kategorie}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xff74788d),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        preisText,
                        style: const TextStyle(
                          color: Color(0xff5b2cff),
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
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
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff5b2cff),
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InseratBearbeitenSeite(
                            produkt: produkt,
                          ),
                        ),
                      );
                    },
                    label: const Text(
                      "Bearbeiten",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    onPressed: () {
                      inseratLoeschen(produkt);
                    },
                    label: const Text(
                      "Löschen",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
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

  Widget _platzhalterBild(Produkt produkt) {
    return Container(
      height: 210,
      width: double.infinity,
      color: const Color(0xfff1edff),
      child: Icon(
        produkt.icon,
        color: const Color(0xff5b2cff),
        size: 56,
      ),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        icon: const Icon(
          Icons.logout,
          color: Colors.white,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff050b2c),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          setState(() {});
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