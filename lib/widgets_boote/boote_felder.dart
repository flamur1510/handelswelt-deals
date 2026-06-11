import 'package:flutter/material.dart';
import '../widgets/einheit_feld.dart';

class BooteFelder extends StatelessWidget {
  final TextEditingController markeController;
  final TextEditingController modellController;
  final TextEditingController baujahrController;
  final TextEditingController laengeController;
  final TextEditingController leistungController;
  final String bootstyp;
  final Function(String?) onBootstypChanged;

  const BooteFelder({
    super.key,
    required this.markeController,
    required this.modellController,
    required this.baujahrController,
    required this.laengeController,
    required this.leistungController,
    required this.bootstyp,
    required this.onBootstypChanged,
  });

  @override
  Widget build(BuildContext context) {
    const bootstypen = [
      "Motorboot",
      "Segelboot",
      "Schlauchboot",
      "Jetski",
      "Hausboot",
      "Angelboot",
      "Kajak/Kanu",
      "Andere",
    ];

    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: bootstypen.contains(bootstyp) ? bootstyp : bootstypen.first,
          decoration: const InputDecoration(labelText: "Bootstyp"),
          items: bootstypen
              .map((typ) => DropdownMenuItem(value: typ, child: Text(typ)))
              .toList(),
          onChanged: onBootstypChanged,
        ),
        TextField(
          controller: markeController,
          decoration: const InputDecoration(labelText: "Marke"),
        ),
        TextField(
          controller: modellController,
          decoration: const InputDecoration(labelText: "Modell"),
        ),
        EinheitFeld(
          controller: baujahrController,
          label: "Baujahr",
          einheit: "",
        ),
        EinheitFeld(
          controller: laengeController,
          label: "Länge",
          einheit: "m",
        ),
        EinheitFeld(
          controller: leistungController,
          label: "Leistung",
          einheit: "PS",
        ),
      ],
    );
  }
}