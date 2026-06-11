import 'package:flutter/material.dart';

import 'admin_benutzer_seite.dart';
import 'admin_firmen_seite.dart';
import 'admin_inserate_seite.dart';
import 'admin_meldungen_seite.dart';
import 'firmen_verifizieren_seite.dart';

class AdminZentraleSeite extends StatelessWidget {
  const AdminZentraleSeite({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      appBar: AppBar(
        backgroundColor: const Color(0xff050b2c),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Admin-Zentrale",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _kopfBereich(),
          const SizedBox(height: 18),

          _adminKarte(
            context: context,
            icon: Icons.verified_user_outlined,
            titel: "Firmen verifizieren",
            beschreibung: "Firmenunterlagen prüfen und verifizieren",
            farbe: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FirmenVerifizierenSeite(),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          _adminKarte(
            context: context,
            icon: Icons.business_outlined,
            titel: "Firmenfreigaben",
            beschreibung: "Firmen prüfen und freigeben",
            farbe: const Color(0xff5b2cff),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminFirmenSeite(),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          _adminKarte(
            context: context,
            icon: Icons.report_gmailerrorred_outlined,
            titel: "Meldungen",
            beschreibung: "Gemeldete Inserate prüfen",
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

          const SizedBox(height: 14),

          _adminKarte(
            context: context,
            icon: Icons.people_outline,
            titel: "Benutzerverwaltung",
            beschreibung: "Benutzer prüfen, sperren und Rollen verwalten",
            farbe: const Color(0xff050b2c),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminBenutzerSeite(),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          _adminKarte(
            context: context,
            icon: Icons.inventory_2_outlined,
            titel: "Inseratverwaltung",
            beschreibung: "Inserate prüfen, sperren und löschen",
            farbe: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminInserateSeite(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _kopfBereich() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff5b2cff).withOpacity(0.20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.admin_panel_settings,
            color: Colors.white,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            "Handelswelt Admin",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Verwalte Firmen, Verifizierungen, Meldungen, Benutzer und Inserate.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _adminKarte({
    required BuildContext context,
    required IconData icon,
    required String titel,
    required String beschreibung,
    required Color farbe,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xffececf4),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0f000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: farbe.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: farbe,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
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
                  const SizedBox(height: 4),
                  Text(
                    beschreibung,
                    style: const TextStyle(
                      color: Color(0xff74788d),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xff74788d),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}