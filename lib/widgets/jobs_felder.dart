import 'package:flutter/material.dart';

import 'inserat_form_widgets.dart';

class JobsFelder extends StatelessWidget {
  final TextEditingController gehaltController;
  final TextEditingController arbeitsortController;
  final TextEditingController erfahrungController;

  final String beschaeftigungsart;
  final String homeoffice;
  final String fuehrerschein;

  final Function(String?) onBeschaeftigungsart;
  final Function(String?) onHomeoffice;
  final Function(String?) onFuehrerschein;

  const JobsFelder({
    super.key,
    required this.gehaltController,
    required this.arbeitsortController,
    required this.erfahrungController,
    required this.beschaeftigungsart,
    required this.homeoffice,
    required this.fuehrerschein,
    required this.onBeschaeftigungsart,
    required this.onHomeoffice,
    required this.onFuehrerschein,
  });

  @override
  Widget build(BuildContext context) {
    return InseratKarte(
      titel: "Jobdetails",
      child: Column(
        children: [
          InseratDropdown(
            label: "Beschäftigungsart",
            value: beschaeftigungsart,
            items: const [
              "Vollzeit",
              "Teilzeit",
              "Minijob",
              "Lehrstelle",
              "Praktikum",
              "Freelancer",
            ],
            onChanged: onBeschaeftigungsart,
          ),
          InseratFeld(
            controller: gehaltController,
            label: "Gehalt",
          ),
          InseratFeld(
            controller: arbeitsortController,
            label: "Arbeitsort",
          ),
          InseratFeld(
            controller: erfahrungController,
            label: "Berufserfahrung",
          ),
          InseratDropdown(
            label: "Homeoffice",
            value: homeoffice,
            items: const ["Ja", "Nein"],
            onChanged: onHomeoffice,
          ),
          InseratDropdown(
            label: "Führerschein erforderlich",
            value: fuehrerschein,
            items: const ["Ja", "Nein"],
            onChanged: onFuehrerschein,
          ),
        ],
      ),
    );
  }
}