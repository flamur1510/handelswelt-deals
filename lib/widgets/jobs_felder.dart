import 'package:flutter/material.dart';

import 'inserat_form_widgets.dart';

// ── Berufsfelder (wie Willhaben) ──────────────────────────

const List<String> jobBerufsfelder = [
  "Bau & Handwerk",
  "Büro & Verwaltung",
  "Einkauf & Logistik",
  "Elektro & Elektronik",
  "Gastronomie & Tourismus",
  "Gesundheit & Soziales",
  "Handel & Verkauf",
  "IT & Telekommunikation",
  "Immobilien",
  "Kreativ & Design",
  "Landwirtschaft & Forstwirtschaft",
  "Marketing & Werbung",
  "Medien & Journalismus",
  "Personalwesen",
  "Produktion & Fertigung",
  "Recht & Steuern",
  "Reinigung & Haushalt",
  "Sicherheit",
  "Technik & Ingenieurwesen",
  "Transport & Fahrer",
  "Unterricht & Bildung",
  "Wissenschaft & Forschung",
  "Sonstige",
];

// ── Positionen je Berufsfeld ──────────────────────────────

const Map<String, List<String>> jobPositionen = {
  "Bau & Handwerk": [
    "Maurer", "Elektriker", "Installateur / Klempner", "Tischler / Schreiner",
    "Maler / Lackierer", "Dachdecker", "Fliesenleger", "Zimmermann",
    "Schweißer", "Baggerfahrer", "Polier", "Bauhelfer", "Sonstige",
  ],
  "Büro & Verwaltung": [
    "Bürokaufmann/-frau", "Sachbearbeiter/in", "Sekretär/in", "Assistent/in der Geschäftsführung",
    "Dateneingabe", "Empfang / Rezeption", "Office Manager", "Verwaltungsangestellte/r", "Sonstige",
  ],
  "Einkauf & Logistik": [
    "Lagerarbeiter/in", "Staplerfahrer/in", "Einkäufer/in", "Logistiker/in",
    "Disponent/in", "Kommissionierer/in", "Lagerleiter/in", "Supply Chain Manager", "Sonstige",
  ],
  "Elektro & Elektronik": [
    "Elektriker/in", "Elektrotechniker/in", "Mechatroniker/in", "Elektroniker/in",
    "SPS-Programmierer/in", "Servicetechniker/in", "Automatisierungstechniker/in", "Sonstige",
  ],
  "Gastronomie & Tourismus": [
    "Koch / Köchin", "Kellner/in", "Barkeeper/in", "Barista",
    "Küchenhilfe", "Restaurantleiter/in", "Hotelfachmann/-frau", "Rezeptionist/in",
    "Housekeeping", "Eventmanager/in", "Sonstige",
  ],
  "Gesundheit & Soziales": [
    "Krankenpfleger/in", "Altenpfleger/in", "Arzthelfer/in", "Physiotherapeut/in",
    "Ergotherapeut/in", "Sozialarbeiter/in", "Rettungssanitäter/in", "Hebamme",
    "Behindertenbegleitung", "Kinderbetreuung", "Sonstige",
  ],
  "Handel & Verkauf": [
    "Verkäufer/in", "Kassierer/in", "Filialleiter/in", "Außendienstmitarbeiter/in",
    "Key Account Manager", "Handelsvertreter/in", "Merchandiser/in", "Sonstige",
  ],
  "IT & Telekommunikation": [
    "Softwareentwickler/in", "Frontend-Entwickler/in", "Backend-Entwickler/in",
    "Full-Stack-Entwickler/in", "IT-Administrator/in", "IT-Support", "DevOps Engineer",
    "Datenbankadministrator/in", "IT-Projektmanager/in", "Cybersecurity Analyst",
    "UX/UI Designer", "Data Scientist", "Sonstige",
  ],
  "Immobilien": [
    "Immobilienmakler/in", "Immobilienverwalter/in", "Hausverwalter/in",
    "Facility Manager", "Immobilienberater/in", "Sonstige",
  ],
  "Kreativ & Design": [
    "Grafikdesigner/in", "Webdesigner/in", "Fotograf/in", "Videograf/in",
    "Illustrator/in", "Art Director", "Content Creator", "Animator/in", "Sonstige",
  ],
  "Landwirtschaft & Forstwirtschaft": [
    "Landwirt/in", "Erntehelfer/in", "Forstwirt/in", "Gärtner/in",
    "Tierpfleger/in", "Weinbauer/in", "Maschinenführer/in (Landwirtschaft)", "Sonstige",
  ],
  "Marketing & Werbung": [
    "Online Marketing Manager", "SEO/SEA Spezialist/in", "Social Media Manager",
    "PR Manager/in", "Marketing Assistent/in", "Marktforscher/in",
    "Texter/in / Copywriter", "Brand Manager", "Sonstige",
  ],
  "Medien & Journalismus": [
    "Journalist/in", "Redakteur/in", "Moderator/in", "Kameramann/-frau",
    "Cutter/in", "Sprecher/in", "Blogger/in", "Social Media Redakteur/in", "Sonstige",
  ],
  "Personalwesen": [
    "HR Manager/in", "Personalreferent/in", "Recruiter/in", "Lohnverrechner/in",
    "HR Business Partner", "Ausbildungsleiter/in", "Sonstige",
  ],
  "Produktion & Fertigung": [
    "Produktionsmitarbeiter/in", "Maschinenführer/in", "Qualitätsprüfer/in",
    "Schichtleiter/in", "CNC-Operator", "Produktionsleiter/in", "Sonstige",
  ],
  "Recht & Steuern": [
    "Rechtsanwalt/-anwältin", "Notar/in", "Steuerberater/in", "Buchhalter/in",
    "Bilanzbuchhalter/in", "Jurist/in", "Compliance Manager", "Sonstige",
  ],
  "Reinigung & Haushalt": [
    "Reinigungskraft", "Haushaltshelfer/in", "Gebäudereiniger/in",
    "Hausmeister/in", "Reinigungsleiter/in", "Sonstige",
  ],
  "Sicherheit": [
    "Sicherheitsmitarbeiter/in", "Portier/in", "Bodyguard",
    "Sicherheitsleiter/in", "Brandschutzbeauftragter", "Sonstige",
  ],
  "Technik & Ingenieurwesen": [
    "Maschinenbauingenieur/in", "Elektroingenieur/in", "Bauingenieur/in",
    "Projektingenieur/in", "Konstrukteur/in", "Techniker/in", "Sonstige",
  ],
  "Transport & Fahrer": [
    "LKW-Fahrer/in", "Busfahrer/in", "Taxifahrer/in", "Kurierfahrer/in",
    "Berufskraftfahrer/in", "Paketzusteller/in", "Straßenbahnfahrer/in", "Sonstige",
  ],
  "Unterricht & Bildung": [
    "Lehrer/in", "Nachhilfelehrer/in", "Kindergartenpädagoge/in",
    "Schulassistenz", "Ausbilder/in", "Trainer/in", "Sonstige",
  ],
  "Wissenschaft & Forschung": [
    "Forscher/in", "Laborant/in", "Wissenschaftlicher Mitarbeiter",
    "Chemiker/in", "Biologe/Biologin", "Physiker/in", "Sonstige",
  ],
  "Sonstige": ["Sonstige"],
};

// ── Beschäftigungsarten ────────────────────────────────────

const List<String> jobBeschaeftigungsarten = [
  "Vollzeit",
  "Teilzeit",
  "Geringfügig",
  "Lehre / Ausbildung",
  "Praktikum",
  "Freelancer / Werkvertrag",
  "Saisonarbeit",
];

// ── Schichtarbeit-Zeiten ───────────────────────────────────

const List<String> jobSchichten = [
  "Tagschicht",
  "Frühschicht",
  "Spätschicht",
  "Nachtschicht",
  "Wechselschicht",
  "Wochenende",
];

// ── Welche Felder für welches Berufsfeld ──────────────────

class _JobConfig {
  final bool homeoffice;
  final bool fuehrerschein;
  final bool schichtarbeit;
  final bool reisebereitschaft;

  const _JobConfig({
    this.homeoffice = false,
    this.fuehrerschein = false,
    this.schichtarbeit = false,
    this.reisebereitschaft = false,
  });
}

const Map<String, _JobConfig> _jobKonfiguration = {
  "Bau & Handwerk": _JobConfig(fuehrerschein: true, reisebereitschaft: true),
  "Büro & Verwaltung": _JobConfig(homeoffice: true),
  "Einkauf & Logistik": _JobConfig(fuehrerschein: true, reisebereitschaft: true),
  "Elektro & Elektronik": _JobConfig(fuehrerschein: true, reisebereitschaft: true),
  "Gastronomie & Tourismus": _JobConfig(schichtarbeit: true),
  "Gesundheit & Soziales": _JobConfig(schichtarbeit: true, fuehrerschein: true),
  "Handel & Verkauf": _JobConfig(schichtarbeit: true),
  "IT & Telekommunikation": _JobConfig(homeoffice: true),
  "Immobilien": _JobConfig(homeoffice: true, fuehrerschein: true),
  "Kreativ & Design": _JobConfig(homeoffice: true),
  "Landwirtschaft & Forstwirtschaft": _JobConfig(fuehrerschein: true, schichtarbeit: true),
  "Marketing & Werbung": _JobConfig(homeoffice: true),
  "Medien & Journalismus": _JobConfig(homeoffice: true, reisebereitschaft: true),
  "Personalwesen": _JobConfig(homeoffice: true),
  "Produktion & Fertigung": _JobConfig(schichtarbeit: true),
  "Recht & Steuern": _JobConfig(homeoffice: true),
  "Reinigung & Haushalt": _JobConfig(fuehrerschein: true),
  "Sicherheit": _JobConfig(schichtarbeit: true, fuehrerschein: true),
  "Technik & Ingenieurwesen": _JobConfig(homeoffice: true, reisebereitschaft: true, fuehrerschein: true),
  "Transport & Fahrer": _JobConfig(fuehrerschein: true, schichtarbeit: true, reisebereitschaft: true),
  "Unterricht & Bildung": _JobConfig(homeoffice: true),
  "Wissenschaft & Forschung": _JobConfig(homeoffice: true, reisebereitschaft: true),
  "Sonstige": _JobConfig(homeoffice: true, fuehrerschein: true),
};

_JobConfig _konfig(String berufsfeld) =>
    _jobKonfiguration[berufsfeld] ?? const _JobConfig();

// ── Widget ─────────────────────────────────────────────────

class JobsFelder extends StatelessWidget {
  final TextEditingController berufsbezeichnungController;
  final TextEditingController gehaltController;
  final TextEditingController arbeitsortController;
  final TextEditingController erfahrungController;

  final String homeoffice;
  final String fuehrerschein;
  final String schichtarbeit;
  final String reisebereitschaft;

  final Function(String?) onHomeoffice;
  final Function(String?) onFuehrerschein;
  final Function(String?) onSchichtarbeit;
  final Function(String?) onReisebereitschaft;

  const JobsFelder({
    super.key,
    required this.berufsbezeichnungController,
    required this.gehaltController,
    required this.arbeitsortController,
    required this.erfahrungController,
    required this.homeoffice,
    required this.fuehrerschein,
    required this.schichtarbeit,
    required this.reisebereitschaft,
    required this.onHomeoffice,
    required this.onFuehrerschein,
    required this.onSchichtarbeit,
    required this.onReisebereitschaft,
  });

  @override
  Widget build(BuildContext context) {
    return InseratKarte(
      titel: "Jobdetails",
      child: Column(
        children: [
          InseratFeld(
            controller: berufsbezeichnungController,
            label: "Berufsbezeichnung (z.B. Elektriker, Buchhalter)",
          ),
          InseratFeld(
            controller: gehaltController,
            label: "Gehalt (z.B. ab 2.000€ brutto)",
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
            items: const ["Kein Homeoffice", "Teilweise möglich", "Vollständig möglich"],
            onChanged: onHomeoffice,
          ),
          InseratDropdown(
            label: "Arbeitszeit",
            value: schichtarbeit,
            items: jobSchichten,
            onChanged: onSchichtarbeit,
          ),
          InseratDropdown(
            label: "Führerschein erforderlich",
            value: fuehrerschein,
            items: const ["Nicht erforderlich", "B (PKW)", "C (LKW)", "CE (LKW mit Anhänger)", "Staplerschein"],
            onChanged: onFuehrerschein,
          ),
          InseratDropdown(
            label: "Reisebereitschaft",
            value: reisebereitschaft,
            items: const ["Keine", "Gelegentlich", "Regelmäßig", "Häufig"],
            onChanged: onReisebereitschaft,
          ),
        ],
      ),
    );
  }
}
