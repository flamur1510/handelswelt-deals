import 'package:flutter/material.dart';
import '../widgets/einheit_feld.dart';

class BaumarktFelder extends StatelessWidget {
  final TextEditingController herstellerController;
  final TextEditingController materialController;
  final TextEditingController farbeController;
  final TextEditingController masseController;
  final TextEditingController gewichtController;
  final TextEditingController mengeController;

  const BaumarktFelder({
    super.key,
    required this.herstellerController,
    required this.materialController,
    required this.farbeController,
    required this.masseController,
    required this.gewichtController,
    required this.mengeController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: herstellerController,
          decoration: const InputDecoration(labelText: "Hersteller"),
        ),
        TextField(
          controller: materialController,
          decoration: const InputDecoration(labelText: "Material"),
        ),
        TextField(
          controller: farbeController,
          decoration: const InputDecoration(labelText: "Farbe"),
        ),
        TextField(
          controller: masseController,
          decoration: const InputDecoration(
            labelText: "Maße",
            hintText: "z. B. 120x60",
            suffixText: "cm",
          ),
          keyboardType: TextInputType.text,
        ),
        EinheitFeld(
          controller: gewichtController,
          label: "Gewicht",
          einheit: "kg",
        ),
        TextField(
          controller: mengeController,
          decoration: const InputDecoration(
            labelText: "Menge",
            hintText: "z. B. 10 Stück",
          ),
        ),
      ],
    );
  }
}