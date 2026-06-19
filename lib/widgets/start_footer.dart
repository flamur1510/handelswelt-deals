/// ─────────────────────────────────────────────────────────
/// START FOOTER
/// Vollständig stateless — kein State-Zugriff nötig.
/// Zeigt Branding, rechtliche Links (Impressum, Datenschutz, …)
/// und Copyright-Zeile.
/// ─────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class StartFooter extends StatelessWidget {
  const StartFooter({super.key});

  void _infoDialog(BuildContext context, String titel, String text) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(
          titel,
          style: const TextStyle(
            color: Color(0xffffffff),
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          text,
          style: const TextStyle(
            color: Color(0xff9094a8),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "OK",
              style: TextStyle(
                color: Color(0xff5b2cff),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _link({
    required BuildContext context,
    required String text,
    required IconData icon,
    required String titel,
    required String inhalt,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _infoDialog(context, titel, inhalt),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.09),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final breit = MediaQuery.sizeOf(context).width > 900;

    final links = Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: breit ? WrapAlignment.end : WrapAlignment.start,
      children: [
        _link(
          context: context,
          text: "Impressum",
          icon: Icons.info_outline,
          titel: "Impressum",
          inhalt:
              "Hier kommen später Firmenname, Adresse, Kontakt, UID-Nummer und rechtliche Angaben von Handelswelt hinein.",
        ),
        _link(
          context: context,
          text: "Datenschutz",
          icon: Icons.privacy_tip_outlined,
          titel: "Datenschutz",
          inhalt:
              "Hier kommt später die Datenschutzerklärung hinein: welche Daten gespeichert werden, wofür sie genutzt werden und wie Nutzer ihre Daten löschen lassen können.",
        ),
        _link(
          context: context,
          text: "AGB",
          icon: Icons.description_outlined,
          titel: "AGB",
          inhalt:
              "Hier kommen später die Nutzungsbedingungen für Käufer, Verkäufer, private Nutzer und Firmen hinein.",
        ),
        _link(
          context: context,
          text: "Kontakt",
          icon: Icons.mail_outline,
          titel: "Kontakt",
          inhalt:
              "Hier kommen später Support-E-Mail, Telefonnummer oder Kontaktformular von Handelswelt hinein.",
        ),
        _link(
          context: context,
          text: "Hilfe",
          icon: Icons.help_outline,
          titel: "Hilfe",
          inhalt:
              "Hier kommen später häufige Fragen, Sicherheitstipps und Hilfe zum Inserieren hinein.",
        ),
      ],
    );

    final branding = Row(
      children: [
        Image.asset(
          'assets/logo/image_neu2.png',
          width: 54,
          height: 54,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Handelswelt",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Deals für Österreich",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      margin: EdgeInsets.fromLTRB(breit ? 46 : 16, 8, breit ? 46 : 16, 24),
      padding: EdgeInsets.all(breit ? 22 : 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffffffff), Color(0xff11184f)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (breit)
            Row(
              children: [
                Expanded(child: branding),
                const SizedBox(width: 18),
                links,
              ],
            )
          else ...[
            branding,
            const SizedBox(height: 16),
            links,
          ],
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withOpacity(0.12)),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: Text(
                  "© Handelswelt • Alle Rechte vorbehalten",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                "Österreich",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
