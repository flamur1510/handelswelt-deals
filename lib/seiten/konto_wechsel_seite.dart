import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class KontoWechselSeite extends StatefulWidget {
  const KontoWechselSeite({super.key});

  @override
  State<KontoWechselSeite> createState() => _KontoWechselSeiteState();
}

class _KontoWechselSeiteState extends State<KontoWechselSeite> {
  final emailController = TextEditingController();
  final passwortController = TextEditingController();

  bool wirdGeladen = false;

  @override
  void dispose() {
    emailController.dispose();
    passwortController.dispose();
    super.dispose();
  }

  Future<void> kontoWechseln() async {
    final email = emailController.text.trim();
    final passwort = passwortController.text.trim();

    if (email.isEmpty || passwort.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bitte E-Mail und Passwort eingeben."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      wirdGeladen = true;
    });

    try {
      await FirebaseAuth.instance.signOut();

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: passwort,
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Konto erfolgreich gewechselt."),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        wirdGeladen = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Fehler beim Kontowechsel: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final aktuellerUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      appBar: AppBar(
        backgroundColor: const Color(0xff050b2c),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Konto wechseln",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xff070b2f),
                  Color(0xff11184f),
                  Color(0xff5b2cff),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.swap_horiz,
                  color: Colors.white,
                  size: 42,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Zwischen Konten wechseln",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  aktuellerUser?.email == null
                      ? "Du bist aktuell nicht angemeldet."
                      : "Aktuell angemeldet: ${aktuellerUser!.email}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Container(
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
              children: [
                _feld(
                  controller: emailController,
                  label: "E-Mail-Adresse",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                _feld(
                  controller: passwortController,
                  label: "Passwort",
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    icon: wirdGeladen
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.login, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff5b2cff),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: wirdGeladen ? null : kontoWechseln,
                    label: Text(
                      wirdGeladen ? "Wird gewechselt..." : "Konto wechseln",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
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

  Widget _feld({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: const Color(0xff5b2cff),
          ),
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
}