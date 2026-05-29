import 'package:flutter/material.dart';

class OnboardingSeite extends StatefulWidget {
  final Widget naechsteSeite;

  const OnboardingSeite({
    super.key,
    required this.naechsteSeite,
  });

  @override
  State<OnboardingSeite> createState() => _OnboardingSeiteState();
}

class _OnboardingSeiteState extends State<OnboardingSeite> {
  final PageController controller = PageController();
  int seite = 0;

  final daten = const [
    {
      "icon": Icons.storefront,
      "titel": "Willkommen bei Handelswelt",
      "text": "Der moderne Marktplatz für Österreich.",
    },
    {
      "icon": Icons.camera_alt,
      "titel": "Inserate mit Bildern",
      "text": "Erstelle Anzeigen mit mehreren Fotos und Beschreibung.",
    },
    {
      "icon": Icons.chat,
      "titel": "Direkt chatten",
      "text": "Käufer und Verkäufer können sofort Nachrichten senden.",
    },
  ];

  void weiter() {
    if (seite < daten.length - 1) {
      controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => widget.naechsteSeite,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: controller,
        itemCount: daten.length,
        onPageChanged: (index) {
          setState(() {
            seite = index;
          });
        },
        itemBuilder: (context, index) {
          final item = daten[index];

          return Container(
            padding: const EdgeInsets.all(28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple,
                  Color(0xff7b2ff7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item["icon"] as IconData,
                  size: 120,
                  color: Colors.white,
                ),
                const SizedBox(height: 35),
                Text(
                  item["titel"] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  item["text"] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 19,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 55),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < daten.length; i++)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: seite == i ? 24 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: seite == i ? Colors.white : Colors.white38,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 35),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 42,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  onPressed: weiter,
                  child: Text(
                    seite == daten.length - 1 ? "Loslegen" : "Weiter",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}