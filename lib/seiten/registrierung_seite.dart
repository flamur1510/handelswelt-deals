import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Für Google/Apple Login brauchst du zusätzlich diese Pakete in pubspec.yaml:
// google_sign_in: ^6.2.1
// sign_in_with_apple: ^6.1.1
//
// Danach:
// flutter pub get
//
// WICHTIG:
// Google/Apple müssen zusätzlich in Firebase Authentication aktiviert werden.

class RegistrierungSeite extends StatefulWidget {
  final VoidCallback? nachRegistrierung;
  final VoidCallback? zuLogin;

  const RegistrierungSeite({
    super.key,
    this.nachRegistrierung,
    this.zuLogin,
  });

  @override
  State<RegistrierungSeite> createState() => _RegistrierungSeiteState();
}

class _RegistrierungSeiteState extends State<RegistrierungSeite> {
  final formKey = GlobalKey<FormState>();

  String kontoTyp = "privat";
  bool passwortSichtbar = false;
  bool passwortWiederholenSichtbar = false;
  bool wirdGeladen = false;

  final benutzernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwortController = TextEditingController();
  final passwortWiederholenController = TextEditingController();

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
  final firmenOrtController = TextEditingController();
  final landController = TextEditingController(text: "Österreich");

  @override
  void dispose() {
    benutzernameController.dispose();
    emailController.dispose();
    passwortController.dispose();
    passwortWiederholenController.dispose();

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
    firmenOrtController.dispose();
    landController.dispose();

    super.dispose();
  }

  Future<void> registrierenMitEmail() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      wirdGeladen = true;
    });

    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      final userCredential = await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwortController.text.trim(),
      );

      final user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: "user-null",
          message: "Benutzer konnte nicht erstellt werden.",
        );
      }

      await user.updateDisplayName(benutzernameController.text.trim());

      await user.sendEmailVerification();

      await firestore.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "kontoTyp": kontoTyp,
        "benutzername": benutzernameController.text.trim(),
        "email": emailController.text.trim(),
        "emailVerifiziert": false,
        "erstelltAm": FieldValue.serverTimestamp(),
        "aktualisiertAm": FieldValue.serverTimestamp(),

        if (kontoTyp == "privat") ...{
          "vorname": vornameController.text.trim(),
          "nachname": nachnameController.text.trim(),
          "telefon": telefonController.text.trim(),
          "ort": ortController.text.trim(),
          "profilVerifiziert": false,
        },

        if (kontoTyp == "firma") ...{
          "firmenname": firmennameController.text.trim(),
          "rechtsform": rechtsformController.text.trim(),
          "uidNummer": uidNummerController.text.trim(),
          "ansprechpartner": ansprechpartnerController.text.trim(),
          "telefon": telefonController.text.trim(),
          "webseite": webseiteController.text.trim(),
          "strasse": strasseController.text.trim(),
          "plz": plzController.text.trim(),
          "ort": firmenOrtController.text.trim(),
          "land": landController.text.trim(),
          "firmaVerifiziert": false,
          "verifizierungsStatus": "offen",
          "gewerbescheinUrl": "",
          "verifiziertAm": null,
          "verifiziertVon": "",
          "verifizierungAbgelehntGrund": "",
        },
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Registrierung erfolgreich. Bitte bestätige deine E-Mail-Adresse.",
          ),
        ),
      );

      widget.nachRegistrierung?.call();
    } on FirebaseAuthException catch (e) {
      zeigeFehler(firebaseFehlerText(e));
    } catch (e) {
      zeigeFehler("Fehler: $e");
    }

    if (mounted) {
      setState(() {
        wirdGeladen = false;
      });
    }
  }

  String firebaseFehlerText(FirebaseAuthException e) {
    switch (e.code) {
      case "email-already-in-use":
        return "Diese E-Mail-Adresse wird bereits verwendet.";
      case "invalid-email":
        return "Bitte gib eine gültige E-Mail-Adresse ein.";
      case "weak-password":
        return "Das Passwort ist zu schwach.";
      case "network-request-failed":
        return "Keine Internetverbindung.";
      default:
        return e.message ?? "Registrierung fehlgeschlagen.";
    }
  }

  void zeigeFehler(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> registrierenMitGoogle() async {
    zeigeFehler(
      "Google Login wird im nächsten Schritt verbunden. Dafür brauchen wir google_sign_in und Firebase-Konfiguration.",
    );
  }

  Future<void> registrierenMitApple() async {
    zeigeFehler(
      "Apple Login wird im nächsten Schritt verbunden. Dafür brauchen wir sign_in_with_apple und Apple Developer Konfiguration.",
    );
  }

  String? pflichtfeld(String? value, String feldname) {
    if (value == null || value.trim().isEmpty) {
      return "$feldname eingeben";
    }
    return null;
  }

  String? emailPruefen(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "E-Mail eingeben";
    }

    if (!value.contains("@") || !value.contains(".")) {
      return "Gültige E-Mail eingeben";
    }

    return null;
  }

  String? passwortPruefen(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Passwort eingeben";
    }

    if (value.trim().length < 6) {
      return "Mindestens 6 Zeichen";
    }

    return null;
  }

  String? passwortWiederholenPruefen(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Passwort wiederholen";
    }

    if (value.trim() != passwortController.text.trim()) {
      return "Passwörter stimmen nicht überein";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final breit = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                breit ? 34 : 16,
                18,
                breit ? 34 : 16,
                26,
              ),
              children: [
                _kopf(),
                const SizedBox(height: 18),
                _kontoTypAuswahl(),
                const SizedBox(height: 16),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      _basisDaten(),
                      const SizedBox(height: 16),
                      kontoTyp == "privat"
                          ? _privatDaten()
                          : _firmenDaten(),
                      const SizedBox(height: 16),
                      _passwortDaten(),
                      const SizedBox(height: 18),
                      _registrierenButton(),
                      const SizedBox(height: 16),
                      _trenner(),
                      const SizedBox(height: 16),
                      _socialButtons(),
                      const SizedBox(height: 16),
                      _loginHinweis(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kopf() {
    return Column(
      children: [
        Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            color: const Color(0xfff1edff),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(
            Icons.shopping_cart_outlined,
            color: Color(0xff5b2cff),
            size: 34,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Konto erstellen",
          style: TextStyle(
            color: Color(0xff050b2c),
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          "Registriere dich als Privatperson oder Firma.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xff74788d),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _kontoTypAuswahl() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffececf4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _kontoTypButton(
              titel: "Privat",
              icon: Icons.person_outline,
              wert: "privat",
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _kontoTypButton(
              titel: "Firma",
              icon: Icons.business_outlined,
              wert: "firma",
            ),
          ),
        ],
      ),
    );
  }

  Widget _kontoTypButton({
    required String titel,
    required IconData icon,
    required String wert,
  }) {
    final aktiv = kontoTyp == wert;

    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: () {
        setState(() {
          kontoTyp = wert;
        });
      },
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: aktiv ? const Color(0xff5b2cff) : const Color(0xfff7f7fb),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: aktiv ? Colors.white : const Color(0xff5b2cff),
            ),
            const SizedBox(width: 8),
            Text(
              titel,
              style: TextStyle(
                color: aktiv ? Colors.white : const Color(0xff050b2c),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _karte({
    required String titel,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            titel,
            style: const TextStyle(
              color: Color(0xff050b2c),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _basisDaten() {
    return _karte(
      titel: "Zugangsdaten",
      children: [
        _feld(
          controller: benutzernameController,
          label: "Benutzername",
          icon: Icons.alternate_email,
          validator: (value) => pflichtfeld(value, "Benutzername"),
        ),
        _feld(
          controller: emailController,
          label: "E-Mail",
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: emailPruefen,
        ),
      ],
    );
  }

  Widget _privatDaten() {
    return _karte(
      titel: "Private Daten",
      children: [
        _feld(
          controller: vornameController,
          label: "Vorname",
          icon: Icons.person_outline,
          validator: (value) => pflichtfeld(value, "Vorname"),
        ),
        _feld(
          controller: nachnameController,
          label: "Nachname",
          icon: Icons.person_outline,
          validator: (value) => pflichtfeld(value, "Nachname"),
        ),
        _feld(
          controller: telefonController,
          label: "Telefonnummer optional",
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        _feld(
          controller: ortController,
          label: "Ort",
          icon: Icons.location_on_outlined,
          validator: (value) => pflichtfeld(value, "Ort"),
        ),
      ],
    );
  }

  Widget _firmenDaten() {
    return _karte(
      titel: "Firmendaten",
      children: [
        _feld(
          controller: firmennameController,
          label: "Firmenname",
          icon: Icons.business_outlined,
          validator: (value) => pflichtfeld(value, "Firmenname"),
        ),
        _feld(
          controller: rechtsformController,
          label: "Rechtsform optional",
          icon: Icons.account_balance_outlined,
        ),
        _feld(
          controller: uidNummerController,
          label: "UID-/USt-ID Nummer",
          icon: Icons.badge_outlined,
          validator: (value) => pflichtfeld(value, "UID-/USt-ID Nummer"),
        ),
        _feld(
          controller: ansprechpartnerController,
          label: "Ansprechpartner",
          icon: Icons.person_outline,
          validator: (value) => pflichtfeld(value, "Ansprechpartner"),
        ),
        _feld(
          controller: telefonController,
          label: "Telefonnummer",
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) => pflichtfeld(value, "Telefonnummer"),
        ),
        _feld(
          controller: webseiteController,
          label: "Webseite optional",
          icon: Icons.language_outlined,
        ),
        _feld(
          controller: strasseController,
          label: "Straße und Hausnummer",
          icon: Icons.location_city_outlined,
          validator: (value) => pflichtfeld(value, "Straße"),
        ),
        _feld(
          controller: plzController,
          label: "PLZ",
          icon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
          validator: (value) => pflichtfeld(value, "PLZ"),
        ),
        _feld(
          controller: firmenOrtController,
          label: "Ort",
          icon: Icons.location_on_outlined,
          validator: (value) => pflichtfeld(value, "Ort"),
        ),
        _feld(
          controller: landController,
          label: "Land",
          icon: Icons.flag_outlined,
          validator: (value) => pflichtfeld(value, "Land"),
        ),
      ],
    );
  }

  Widget _passwortDaten() {
    return _karte(
      titel: "Passwort",
      children: [
        _feld(
          controller: passwortController,
          label: "Passwort",
          icon: Icons.lock_outline,
          obscureText: !passwortSichtbar,
          validator: passwortPruefen,
          suffix: IconButton(
            onPressed: () {
              setState(() {
                passwortSichtbar = !passwortSichtbar;
              });
            },
            icon: Icon(
              passwortSichtbar ? Icons.visibility_off : Icons.visibility,
            ),
          ),
        ),
        _feld(
          controller: passwortWiederholenController,
          label: "Passwort wiederholen",
          icon: Icons.lock_reset_outlined,
          obscureText: !passwortWiederholenSichtbar,
          validator: passwortWiederholenPruefen,
          suffix: IconButton(
            onPressed: () {
              setState(() {
                passwortWiederholenSichtbar =
                    !passwortWiederholenSichtbar;
              });
            },
            icon: Icon(
              passwortWiederholenSichtbar
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
          ),
        ),
      ],
    );
  }

  Widget _feld({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: const Color(0xff5b2cff),
          ),
          suffixIcon: suffix,
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

  Widget _registrierenButton() {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: wirdGeladen ? null : registrierenMitEmail,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff5b2cff),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: wirdGeladen
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                "Mit E-Mail registrieren",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }

  Widget _trenner() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xffececf4),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "oder",
            style: TextStyle(
              color: Color(0xff74788d),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xffececf4),
          ),
        ),
      ],
    );
  }

  Widget _socialButtons() {
    return Column(
      children: [
        _socialButton(
          icon: Icons.g_mobiledata,
          text: "Mit Google anmelden",
          onTap: registrierenMitGoogle,
        ),
        const SizedBox(height: 10),
        _socialButton(
          icon: Icons.apple,
          text: "Mit Apple anmelden",
          onTap: registrierenMitApple,
        ),
      ],
    );
  }

  Widget _socialButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xffececf4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xff050b2c),
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Color(0xff050b2c),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginHinweis() {
    return Center(
      child: TextButton(
        onPressed: widget.zuLogin,
        child: const Text(
          "Du hast schon ein Konto? Einloggen",
          style: TextStyle(
            color: Color(0xff5b2cff),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
