import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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

  Map<String, dynamic> _profilDatenFuerUser(User user) {
    return {
      "uid": user.uid,
      "kontoTyp": kontoTyp,
      "benutzername": benutzernameController.text.trim(),
      "email": emailController.text.trim(),
      "emailVerifiziert": user.emailVerified,
      "isAdmin": false,
      "gesperrt": false,
      "firmaVerifiziert": false,
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
        "verifizierungsStatus": "offen",
        "gewerbescheinUrl": "",
        "verifiziertAm": null,
        "verifiziertVon": "",
        "verifizierungAbgelehntGrund": "",
      },
    };
  }

  Future<void> registrierenMitEmail() async {
    if (!formKey.currentState!.validate()) return;
    if (wirdGeladen) return;

    setState(() {
      wirdGeladen = true;
    });

    User? erstellterUser;

    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      final userCredential = await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwortController.text.trim(),
      );

      final user = userCredential.user;
      erstellterUser = user;

      if (user == null) {
        throw FirebaseAuthException(
          code: "user-null",
          message: "Benutzer konnte nicht erstellt werden.",
        );
      }

      try {
        await user.updateDisplayName(benutzernameController.text.trim());
      } catch (e) {
        debugPrint("DisplayName konnte nicht gesetzt werden: $e");
      }

      try {
        await firestore.collection("users").doc(user.uid).set(
              _profilDatenFuerUser(user),
              SetOptions(merge: true),
            );
      } catch (e) {
        debugPrint("Profil konnte nicht gespeichert werden: $e");
        if (!mounted) return;
        zeigeFehler(
          "Konto wurde erstellt, aber das Profil konnte nicht gespeichert werden. Bitte später erneut einloggen.",
        );
        await FirebaseAuth.instance.signOut();
        widget.zuLogin?.call();
        return;
      }

      try {
        await user.sendEmailVerification();
      } catch (e) {
        debugPrint("Bestätigungs-E-Mail konnte nicht gesendet werden: $e");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Konto erstellt. Bitte logge dich ein und fordere die Bestätigungs-E-Mail später erneut an.",
            ),
            backgroundColor: Colors.orange,
          ),
        );
        await FirebaseAuth.instance.signOut();
        widget.zuLogin?.call();
        return;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Registrierung erfolgreich. Bitte bestätige deine E-Mail-Adresse und logge dich danach ein.",
          ),
          backgroundColor: Color(0xff5b2cff),
        ),
      );

      await FirebaseAuth.instance.signOut();
      widget.zuLogin?.call();
    } on FirebaseAuthException catch (e) {
      zeigeFehler(firebaseFehlerText(e));
    } catch (e) {
      debugPrint("Registrierung Fehler: $e");
      if (erstellterUser != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Konto wurde erstellt. Bitte bestätige deine E-Mail-Adresse und logge dich danach ein.",
            ),
            backgroundColor: Color(0xff5b2cff),
          ),
        );
        await FirebaseAuth.instance.signOut();
        widget.zuLogin?.call();
      } else {
        zeigeFehler("Registrierung fehlgeschlagen: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          wirdGeladen = false;
        });
      }
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

  String _zufallsNonce([int laenge = 32]) {
    const zeichen =
        "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._";
    final random = Random.secure();
    return List.generate(laenge, (_) => zeichen[random.nextInt(zeichen.length)])
        .join();
  }

  String _sha256(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  Future<void> _socialRegistrierungAbschliessen(UserCredential credential) async {
    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: "user-null",
        message: "Benutzer konnte nicht erstellt werden.",
      );
    }

    final firestore = FirebaseFirestore.instance;
    final userRef = firestore.collection("users").doc(user.uid);
    final userDoc = await userRef.get();

    final nameAusProvider = user.displayName?.trim();
    final emailAusProvider = user.email?.trim() ?? "";
    final benutzername = benutzernameController.text.trim().isNotEmpty
        ? benutzernameController.text.trim()
        : (nameAusProvider?.isNotEmpty == true
            ? nameAusProvider!
            : (emailAusProvider.contains("@")
                ? emailAusProvider.split("@").first
                : "Nutzer"));

    await userRef.set({
      "uid": user.uid,
      "kontoTyp": kontoTyp,
      "benutzername": benutzername,
      "email": emailAusProvider.isNotEmpty ? emailAusProvider : emailController.text.trim(),
      "emailVerifiziert": user.emailVerified,
      "isAdmin": userDoc.data()?['isAdmin'] ?? false,
      "gesperrt": userDoc.data()?['gesperrt'] ?? false,
      "firmaVerifiziert": userDoc.data()?['firmaVerifiziert'] ?? false,
      "aktualisiertAm": FieldValue.serverTimestamp(),
      if (!userDoc.exists) "erstelltAm": FieldValue.serverTimestamp(),
      if (kontoTyp == "privat") ...{
        "vorname": vornameController.text.trim(),
        "nachname": nachnameController.text.trim(),
        "telefon": telefonController.text.trim(),
        "ort": ortController.text.trim(),
        "profilVerifiziert": userDoc.data()?['profilVerifiziert'] ?? false,
      },
      if (kontoTyp == "firma") ...{
        "firmenname": firmennameController.text.trim().isNotEmpty
            ? firmennameController.text.trim()
            : benutzername,
        "rechtsform": rechtsformController.text.trim(),
        "uidNummer": uidNummerController.text.trim(),
        "ansprechpartner": ansprechpartnerController.text.trim(),
        "telefon": telefonController.text.trim(),
        "webseite": webseiteController.text.trim(),
        "strasse": strasseController.text.trim(),
        "plz": plzController.text.trim(),
        "ort": firmenOrtController.text.trim(),
        "land": landController.text.trim().isEmpty ? "Österreich" : landController.text.trim(),
        "verifizierungsStatus": userDoc.data()?['verifizierungsStatus'] ?? "offen",
        "gewerbescheinUrl": userDoc.data()?['gewerbescheinUrl'] ?? "",
        "verifiziertAm": userDoc.data()?['verifiziertAm'],
        "verifiziertVon": userDoc.data()?['verifiziertVon'] ?? "",
        "verifizierungAbgelehntGrund": userDoc.data()?['verifizierungAbgelehntGrund'] ?? "",
      },
    }, SetOptions(merge: true));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Anmeldung erfolgreich."),
        backgroundColor: Color(0xff5b2cff),
      ),
    );

    widget.nachRegistrierung?.call();
  }

  Future<void> registrierenMitGoogle() async {
    if (wirdGeladen) return;

    setState(() => wirdGeladen = true);

    try {
      UserCredential credential;

      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        credential = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return;

        final googleAuth = await googleUser.authentication;
        final oauthCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        credential =
            await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      }

      await _socialRegistrierungAbschliessen(credential);
    } on FirebaseAuthException catch (e) {
      zeigeFehler(firebaseFehlerText(e));
    } catch (e) {
      zeigeFehler("Google Registrierung fehlgeschlagen: $e");
    } finally {
      if (mounted) setState(() => wirdGeladen = false);
    }
  }

  Future<void> registrierenMitApple() async {
    if (wirdGeladen) return;

    setState(() => wirdGeladen = true);

    try {
      UserCredential credential;

      if (kIsWeb) {
        final provider = OAuthProvider("apple.com");
        provider.addScope("email");
        provider.addScope("name");
        credential = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final rawNonce = _zufallsNonce();
        final nonce = _sha256(rawNonce);

        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: const [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: nonce,
        );

        final oauthCredential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          rawNonce: rawNonce,
        );

        credential =
            await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      }

      await _socialRegistrierungAbschliessen(credential);
    } on FirebaseAuthException catch (e) {
      zeigeFehler(firebaseFehlerText(e));
    } catch (e) {
      zeigeFehler("Apple Registrierung fehlgeschlagen: $e");
    } finally {
      if (mounted) setState(() => wirdGeladen = false);
    }
  }

  Future<void> registrierenMitFacebook() async {
    if (wirdGeladen) return;

    setState(() => wirdGeladen = true);

    try {
      UserCredential credential;

      if (kIsWeb) {
        final provider = FacebookAuthProvider();
        credential = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final result = await FacebookAuth.instance.login(
          permissions: const ["email", "public_profile"],
        );

        if (result.status != LoginStatus.success || result.accessToken == null) {
          throw FirebaseAuthException(
            code: "facebook-aborted",
            message: "Facebook Anmeldung wurde abgebrochen.",
          );
        }

        final facebookCredential =
            FacebookAuthProvider.credential(result.accessToken!.tokenString);

        credential =
            await FirebaseAuth.instance.signInWithCredential(facebookCredential);
      }

      await _socialRegistrierungAbschliessen(credential);
    } on FirebaseAuthException catch (e) {
      zeigeFehler(firebaseFehlerText(e));
    } catch (e) {
      zeigeFehler("Facebook Registrierung fehlgeschlagen: $e");
    } finally {
      if (mounted) setState(() => wirdGeladen = false);
    }
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
        ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Image.asset(
            'assets/logo/image_neu2.png',
            width: 66,
            height: 66,
            fit: BoxFit.contain,
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
        const SizedBox(height: 10),
        _socialButton(
          icon: Icons.facebook,
          text: "Mit Facebook anmelden",
          onTap: registrierenMitFacebook,
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
      onTap: wirdGeladen ? null : onTap,
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
