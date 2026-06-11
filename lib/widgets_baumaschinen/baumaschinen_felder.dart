import 'package:flutter/material.dart';
import '../widgets/einheit_feld.dart';

class BaumaschinenFelder extends StatelessWidget {
  final TextEditingController zustandController;
  final TextEditingController baujahrController;
  final TextEditingController betriebsstundenController;
  final TextEditingController kraftstoffController;
  final TextEditingController leistungController;
  final TextEditingController gewichtController;

  const BaumaschinenFelder({
    super.key,
    required this.zustandController,
    required this.baujahrController,
    required this.betriebsstundenController,
    required this.kraftstoffController,
    required this.leistungController,
    required this.gewichtController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: zustandController,
          decoration: const InputDecoration(
            labelText: "Zustand",
            hintText: "z. B. Neu, Gebraucht, Defekt",
          ),
        ),
        EinheitFeld(
          controller: baujahrController,
          label: "Baujahr",
          einheit: "",
        ),
        EinheitFeld(
          controller: betriebsstundenController,
          label: "Betriebsstunden",
          einheit: "h",
        ),
        TextField(
          controller: kraftstoffController,
          decoration: const InputDecoration(
            labelText: "Kraftstoff / Antrieb",
            hintText: "z. B. Diesel, Elektro",
          ),
        ),
        EinheitFeld(
          controller: leistungController,
          label: "Leistung",
          einheit: "PS",
        ),
        EinheitFeld(
          controller: gewichtController,
          label: "Gewicht",
          einheit: "kg",
        ),
      ],
    );
  }
}