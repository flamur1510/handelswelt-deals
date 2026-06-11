import 'package:flutter/material.dart';

import '../immobilien_daten/immobilien_daten.dart' as immobilien_daten;
import 'einheit_feld.dart';
import 'inserat_form_widgets.dart';

class ImmobilienFelder extends StatelessWidget {
  final TextEditingController wohnflaecheController;
  final TextEditingController zimmerController;
  final TextEditingController etageController;
  final TextEditingController kautionController;
  final TextEditingController betriebskostenController;
  final TextEditingController baujahrImmobilieController;

  final String immobilienArt;
  final String immobilienZustand;
  final String balkon;
  final String terrasse;
  final String garten;
  final String garage;
  final String lift;
  final String keller;
  final String moebliert;
  final String energieklasse;
  final String heizung;
  final String verfuegbarkeit;

  final void Function(String value) onImmobilienArt;
  final void Function(String value) onImmobilienZustand;
  final void Function(String value) onBalkon;
  final void Function(String value) onTerrasse;
  final void Function(String value) onGarten;
  final void Function(String value) onGarage;
  final void Function(String value) onLift;
  final void Function(String value) onKeller;
  final void Function(String value) onMoebliert;
  final void Function(String value) onEnergieklasse;
  final void Function(String value) onHeizung;
  final void Function(String value) onVerfuegbarkeit;

  const ImmobilienFelder({
    super.key,
    required this.wohnflaecheController,
    required this.zimmerController,
    required this.etageController,
    required this.kautionController,
    required this.betriebskostenController,
    required this.baujahrImmobilieController,
    required this.immobilienArt,
    required this.immobilienZustand,
    required this.balkon,
    required this.terrasse,
    required this.garten,
    required this.garage,
    required this.lift,
    required this.keller,
    required this.moebliert,
    required this.energieklasse,
    required this.heizung,
    required this.verfuegbarkeit,
    required this.onImmobilienArt,
    required this.onImmobilienZustand,
    required this.onBalkon,
    required this.onTerrasse,
    required this.onGarten,
    required this.onGarage,
    required this.onLift,
    required this.onKeller,
    required this.onMoebliert,
    required this.onEnergieklasse,
    required this.onHeizung,
    required this.onVerfuegbarkeit,
  });

  @override
  Widget build(BuildContext context) {
    return InseratKarte(
      titel: "Immobilien Details",
      child: Column(
        children: [
          InseratDropdown(
            label: "Immobilienart",
            value: immobilienArt,
            items: immobilien_daten.immobilienArten,
            onChanged: (value) {
              if (value != null) onImmobilienArt(value);
            },
          ),
          EinheitFeld(
            controller: wohnflaecheController,
            label: "Wohnfläche",
            einheit: "m²",
          ),
          EinheitFeld(
            controller: zimmerController,
            label: "Zimmer",
            einheit: "",
          ),
          EinheitFeld(
            controller: etageController,
            label: "Etage",
            einheit: "",
          ),
          EinheitFeld(
            controller: kautionController,
            label: "Kaution",
            einheit: "€",
          ),
          EinheitFeld(
            controller: betriebskostenController,
            label: "Betriebskosten",
            einheit: "€",
          ),
          EinheitFeld(
            controller: baujahrImmobilieController,
            label: "Baujahr",
            einheit: "",
          ),
          InseratDropdown(
            label: "Balkon",
            value: balkon,
            items: immobilien_daten.jaNeinImmobilien,
            onChanged: (value) {
              if (value != null) onBalkon(value);
            },
          ),
          InseratDropdown(
            label: "Terrasse",
            value: terrasse,
            items: immobilien_daten.jaNeinImmobilien,
            onChanged: (value) {
              if (value != null) onTerrasse(value);
            },
          ),
          InseratDropdown(
            label: "Garten",
            value: garten,
            items: immobilien_daten.jaNeinImmobilien,
            onChanged: (value) {
              if (value != null) onGarten(value);
            },
          ),
          InseratDropdown(
            label: "Garage/Stellplatz",
            value: garage,
            items: immobilien_daten.jaNeinImmobilien,
            onChanged: (value) {
              if (value != null) onGarage(value);
            },
          ),
          InseratDropdown(
            label: "Lift",
            value: lift,
            items: immobilien_daten.jaNeinImmobilien,
            onChanged: (value) {
              if (value != null) onLift(value);
            },
          ),
          InseratDropdown(
            label: "Keller",
            value: keller,
            items: immobilien_daten.jaNeinImmobilien,
            onChanged: (value) {
              if (value != null) onKeller(value);
            },
          ),
          InseratDropdown(
            label: "Möbliert",
            value: moebliert,
            items: immobilien_daten.jaNeinImmobilien,
            onChanged: (value) {
              if (value != null) onMoebliert(value);
            },
          ),
          InseratDropdown(
            label: "Energieklasse",
            value: energieklasse,
            items: immobilien_daten.energieklassen,
            onChanged: (value) {
              if (value != null) onEnergieklasse(value);
            },
          ),
          InseratDropdown(
            label: "Heizung",
            value: heizung,
            items: immobilien_daten.heizungsarten,
            onChanged: (value) {
              if (value != null) onHeizung(value);
            },
          ),
          InseratDropdown(
            label: "Verfügbarkeit",
            value: verfuegbarkeit,
            items: immobilien_daten.verfuegbarkeit,
            onChanged: (value) {
              if (value != null) onVerfuegbarkeit(value);
            },
          ),
          InseratDropdown(
            label: "Zustand",
            value: immobilienZustand,
            items: immobilien_daten.immobilienZustaende,
            onChanged: (value) {
              if (value != null) onImmobilienZustand(value);
            },
          ),
        ],
      ),
    );
  }
}