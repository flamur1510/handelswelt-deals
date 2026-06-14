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

import 'registrierung_seite.dart';

class LoginSeite extends StatefulWidget {
  const LoginSeite({super.key});

  @override
  State<LoginSeite> createState() => _LoginSeiteState();
}

class _LoginSeiteState extends State<LoginSeite> {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwortController = TextEditingController();

  bool passwortSichtbar = false;
  bool wirdGeladen = false;

  @override
  void dispose() {
    emailController.dispose();
    passwortController.dispose();
    super.dispose();
  }

  Future<void> einloggen() async {
    if (wirdGeladen) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    setState(() {
      wirdGeladen = true;
    });

    try {
      final auth = FirebaseAuth.instance;

      final userCredential = await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwortController.text.trim(),
      );

      final user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: "user-null",
          message: "Benutzer konnte nicht geladen werden.",
        );
      }

      await user.reload();

      // Wichtig:
      // Hier wird NICHT signOut() gemacht.
      // Der Nutzer bleibt angemeldet. Wenn die E-Mail noch nicht bestätigt ist,
      // entscheidet die main.dart / geschützte Funktion, ob die Bestätigungsseite kommt.
      if (!mounted) return;

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      zeigeFehler(firebaseFehlerText(e));
    } catch (e) {
      zeigeFehler("Fehler: $e");
    } finally {
      if (mounted) {
        setState(() {
          wirdGeladen = false;
        });
      }
    }
  }

  Future<void> passwortVergessen() async {
    final email = emailController.text.trim();

    if (email.isEmpty || !email.contains("@")) {
      zeigeFehler("Bitte gib zuerst deine E-Mail-Adresse ein.");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwort-Zurücksetzen E-Mail wurde gesendet."),
          backgroundColor: Color(0xff5b2cff),
        ),
      );
    } on FirebaseAuthException catch (e) {
      zeigeFehler(firebaseFehlerText(e));
    } catch (e) {
      zeigeFehler("Fehler: $e");
    }
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

  Future<void> _nachSocialLogin(UserCredential credential) async {
    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: "user-null",
        message: "Benutzer konnte nicht geladen werden.",
      );
    }

    final userRef = FirebaseFirestore.instance.collection("users").doc(user.uid);
    final userDoc = await userRef.get();

    await userRef.set({
      "uid": user.uid,
      "kontoTyp": userDoc.data()?['kontoTyp'] ?? "privat",
      "benutzername": user.displayName ?? user.email?.split("@").first ?? "Nutzer",
      "email": user.email ?? "",
      "emailVerifiziert": user.emailVerified,
      "telefon": user.phoneNumber ?? userDoc.data()?['telefon'] ?? "",
      "ort": userDoc.data()?['ort'] ?? "",
      "profilVerifiziert": userDoc.data()?['profilVerifiziert'] ?? false,
      "aktualisiertAm": FieldValue.serverTimestamp(),
      if (!userDoc.exists) "erstelltAm": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> loginMitGoogle() async {
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

      await _nachSocialLogin(credential);
    } on FirebaseAuthException catch (e) {
      zeigeFehler(firebaseFehlerText(e));
    } catch (e) {
      zeigeFehler("Google Login fehlgeschlagen: $e");
    } finally {
      if (mounted) setState(() => wirdGeladen = false);
    }
  }

  Future<void> loginMitApple() async {
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

      await _nachSocialLogin(credential);
    } on FirebaseAuthException catch (e) {
      zeigeFehler(firebaseFehlerText(e));
    } catch (e) {
      zeigeFehler("Apple Login fehlgeschlagen: $e");
    } finally {
      if (mounted) setState(() => wirdGeladen = false);
    }
  }

  Future<void> loginMitFacebook() async {
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

      await _nachSocialLogin(credential);
    } on FirebaseAuthException catch (e) {
      zeigeFehler(firebaseFehlerText(e));
    } catch (e) {
      zeigeFehler("Facebook Login fehlgeschlagen: $e");
    } finally {
      if (mounted) setState(() => wirdGeladen = false);
    }
  }

  String firebaseFehlerText(FirebaseAuthException e) {
    switch (e.code) {
      case "user-not-found":
        return "Kein Konto mit dieser E-Mail gefunden.";
      case "wrong-password":
        return "Falsches Passwort.";
      case "invalid-email":
        return "Bitte gib eine gültige E-Mail-Adresse ein.";
      case "invalid-credential":
        return "E-Mail oder Passwort ist falsch.";
      case "too-many-requests":
        return "Zu viele Versuche. Bitte später erneut probieren.";
      case "network-request-failed":
        return "Keine Internetverbindung.";
      case "user-disabled":
        return "Dieses Konto wurde deaktiviert.";
      case "operation-not-allowed":
        return "E-Mail/Passwort Login ist in Firebase nicht aktiviert.";
      default:
        return e.message ?? "Login fehlgeschlagen.";
    }
  }

  void zeigeFehler(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
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

    return null;
  }

  void zurRegistrierung() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrierungSeite(
          zuLogin: () {
            Navigator.pop(context);
          },
          nachRegistrierung: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final breit = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                breit ? 34 : 16,
                28,
                breit ? 34 : 16,
                26,
              ),
              children: [
                _kopf(),
                const SizedBox(height: 22),
                _loginKarte(),
                const SizedBox(height: 16),
                _trenner(),
                const SizedBox(height: 16),
                _socialButtons(),
                const SizedBox(height: 16),
                _registrierenHinweis(),
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
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xfff1edff),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(
            Icons.language,
            color: Color(0xff5b2cff),
            size: 35,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Handelswelt Deals",
          style: TextStyle(
            color: Color(0xff050b2c),
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          "Einloggen und weiter handeln.",
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

  Widget _loginKarte() {
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
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Einloggen",
              style: TextStyle(
                color: Color(0xff050b2c),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            _feld(
              controller: emailController,
              label: "E-Mail",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: emailPruefen,
            ),
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
                  color: const Color(0xff74788d),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: wirdGeladen ? null : passwortVergessen,
                child: const Text(
                  "Passwort vergessen?",
                  style: TextStyle(
                    color: Color(0xff5b2cff),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: wirdGeladen ? null : einloggen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff5b2cff),
                  disabledBackgroundColor: const Color(0xffb9a8ff),
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
                        "Einloggen",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
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
        cursorColor: const Color(0xff5b2cff),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xff74788d),
            fontWeight: FontWeight.w700,
          ),
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
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xff5b2cff),
              width: 1.4,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.4,
            ),
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
          onTap: loginMitGoogle,
        ),
        const SizedBox(height: 10),
        _socialButton(
          icon: Icons.apple,
          text: "Mit Apple anmelden",
          onTap: loginMitApple,
        ),
        const SizedBox(height: 10),
        _socialButton(
          icon: Icons.facebook,
          text: "Mit Facebook anmelden",
          onTap: loginMitFacebook,
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

  Widget _registrierenHinweis() {
    return Center(
      child: TextButton(
        onPressed: wirdGeladen ? null : zurRegistrierung,
        child: const Text(
          "Noch kein Konto? Jetzt registrieren",
          style: TextStyle(
            color: Color(0xff5b2cff),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
