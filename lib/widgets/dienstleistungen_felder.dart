import 'package:flutter/material.dart';

import 'inserat_form_widgets.dart';

class DienstleistungenFelder extends StatelessWidget {
  final TextEditingController einsatzgebietController;
  final TextEditingController preisController;
  final TextEditingController oeffnungszeitenController;

  final String anfahrt;
  final String notdienst;

  final Function(String?) onAnfahrt;
  final Function(String?) onNotdienst;

  const DienstleistungenFelder({
    super.key,
    required this.einsatzgebietController,
    required this.preisController,
    required this.oeffnungszeitenController,
    required this.anfahrt,
    required this.notdienst,
    required this.onAnfahrt,
    required this.onNotdienst,
  });

  @override
  Widget build(BuildContext context) {
    return InseratKarte(
      titel: "Dienstleistungsdetails",
      child: Column(
        children: [
          InseratFeld(
            controller: einsatzgebietController,
            label: "Einsatzgebiet",
          ),
          InseratFeld(
            controller: preisController,
            label: "Preis pro Stunde",
          ),
          InseratFeld(
            controller: oeffnungszeitenController,
            label: "Öffnungszeiten",
          ),
          InseratDropdown(
            label: "Anfahrt möglich",
            value: anfahrt,
            items: const ["Ja", "Nein"],
            onChanged: onAnfahrt,
          ),
          InseratDropdown(
            label: "24h Notdienst",
            value: notdienst,
            items: const ["Ja", "Nein"],
            onChanged: onNotdienst,
          ),
        ],
      ),
    );
  }
}