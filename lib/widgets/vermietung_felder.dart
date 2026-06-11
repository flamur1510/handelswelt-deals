import 'package:flutter/material.dart';

import 'inserat_form_widgets.dart';

class VermietungFelder extends StatelessWidget {
  final TextEditingController preisTagController;
  final TextEditingController preisWocheController;
  final TextEditingController kautionController;
  final TextEditingController mindestdauerController;
  final TextEditingController uebergabeortController;

  final String lieferung;
  final String versicherung;
  final String verfuegbarkeit;

  final Function(String?) onLieferung;
  final Function(String?) onVersicherung;
  final Function(String?) onVerfuegbarkeit;

  const VermietungFelder({
    super.key,
    required this.preisTagController,
    required this.preisWocheController,
    required this.kautionController,
    required this.mindestdauerController,
    required this.uebergabeortController,
    required this.lieferung,
    required this.versicherung,
    required this.verfuegbarkeit,
    required this.onLieferung,
    required this.onVersicherung,
    required this.onVerfuegbarkeit,
  });

  @override
  Widget build(BuildContext context) {
    return InseratKarte(
      titel: "Vermietungsdetails",
      child: Column(
        children: [
          InseratFeld(
            controller: preisTagController,
            label: "Mietpreis pro Tag",
          ),
          InseratFeld(
            controller: preisWocheController,
            label: "Mietpreis pro Woche",
          ),
          InseratFeld(
            controller: kautionController,
            label: "Kaution",
          ),
          InseratFeld(
            controller: mindestdauerController,
            label: "Mindestmietdauer",
          ),
          InseratFeld(
            controller: uebergabeortController,
            label: "Übergabeort",
          ),
          InseratDropdown(
            label: "Lieferung möglich",
            value: lieferung,
            items: const ["Ja", "Nein"],
            onChanged: onLieferung,
          ),
          InseratDropdown(
            label: "Versicherung inklusive",
            value: versicherung,
            items: const ["Ja", "Nein"],
            onChanged: onVersicherung,
          ),
          InseratDropdown(
            label: "Verfügbarkeit",
            value: verfuegbarkeit,
            items: const [
              "Sofort verfügbar",
              "Nach Vereinbarung",
              "Nur Wochenende",
              "Wochentags",
              "Auf Anfrage",
            ],
            onChanged: onVerfuegbarkeit,
          ),
        ],
      ),
    );
  }
}
