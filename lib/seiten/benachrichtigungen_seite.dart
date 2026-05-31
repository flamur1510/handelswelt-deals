import 'package:flutter/material.dart';

class BenachrichtigungenSeite extends StatelessWidget {
  const BenachrichtigungenSeite({super.key});

  @override
  Widget build(BuildContext context) {
    final breit = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            breit ? 46 : 16,
            18,
            breit ? 46 : 16,
            24,
          ),
          children: [
            _kopfzeile(),
            const SizedBox(height: 22),

            _meldung(
              icon: Icons.favorite,
              farbe: Colors.red,
              titel: "Neuer Favorit",
              text:
                  "Jemand hat dein Inserat zu seinen Favoriten hinzugefügt.",
              zeit: "Vor 5 Minuten",
            ),

            _meldung(
              icon: Icons.chat_bubble_outline,
              farbe: const Color(0xff5b2cff),
              titel: "Neue Nachricht",
              text:
                  "Du hast eine neue Nachricht zu deinem Inserat erhalten.",
              zeit: "Vor 20 Minuten",
            ),

            _meldung(
              icon: Icons.visibility_outlined,
              farbe: Colors.orange,
              titel: "Inserat angesehen",
              text:
                  "Dein Inserat wurde heute mehrfach angesehen.",
              zeit: "Vor 1 Stunde",
            ),

            _meldung(
              icon: Icons.sell_outlined,
              farbe: Colors.green,
              titel: "Deal Empfehlung",
              text:
                  "Neue Angebote in deiner Nähe wurden gefunden.",
              zeit: "Heute",
            ),
          ],
        ),
      ),
    );
  }

  Widget _kopfzeile() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xfff1edff),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.notifications_active_outlined,
            color: Color(0xff5b2cff),
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Benachrichtigungen",
                style: TextStyle(
                  color: Color(0xff050b2c),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Alle Aktivitäten auf einen Blick.",
                style: TextStyle(
                  color: Color(0xff74788d),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _meldung({
    required IconData icon,
    required Color farbe,
    required String titel,
    required String text,
    required String zeit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xffececf4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: farbe.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: farbe,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xff74788d),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  zeit,
                  style: const TextStyle(
                    color: Color(0xff5b2cff),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}