// lib/kategorien_daten/unterkategorien.dart

/// Zentrale Kategorien-Struktur für Handelswelt.
///
/// Grundregel:
/// - Privatkonto: darf privat erlaubte Sachen verkaufen/kaufen.
/// - Firmenkonto: darf zusätzlich gewerbliche Angebote, Jobs, Dienstleistungen
///   und Vermietungen anbieten.
/// - Tierbedarf: nur Zubehör/Bedarf, keine Tierverkäufe.

const List<String> hauptKategorien = [
  "Marktplatz",
  "Auto & Motor",
  "Immobilien",
  "Jobs",
  "Dienstleistungen",
  "Baumaschinen",
  "Boote",
  "Anhänger",
  "Tierbedarf",
  "Baumarkt",
  "Landwirtschaft",
  "Freizeit & Hobby",
];

const List<String> marktplatzUnterkategorien = [
  "Elektronik",
  "Haus & Wohnen",
  "Haushalt",
  "Kleidung & Mode",
  "Baby & Kinder",
  "Gaming",
  "Sport & Fitness",
  "Musik & Hobby",
];

const List<String> autoMotorUnterkategorien = [
  "Verkauf",
  "Vermietung",
  "Zubehör",
];

const List<String> immobilienUnterkategorien = [
  "Kaufen",
  "Mieten",
  "Gewerbe",
  "Ferienobjekte",
  "Grundstücke",
];

const List<String> jobsUnterkategorien = [
  "Vollzeit",
  "Teilzeit",
  "Geringfügig",
  "Lehre / Ausbildung",
  "Praktikum",
  "Freelancer / Werkvertrag",
  "Saisonarbeit",
];

const List<String> dienstleistungenUnterkategorien = [
  "Handwerk",
  "Haus & Garten",
  "Reinigung",
  "Transport",
  "IT & Technik",
  "Marketing",
  "Fotografie",
  "Events",
  "Gesundheit",
  "Bildung",
  "Sonstige Dienstleistungen",
];

const List<String> baumaschinenUnterkategorien = [
  "Verkauf",
  "Vermietung",
  "Zubehör",
  "Ersatzteile",
];

const List<String> booteUnterkategorien = [
  "Verkauf",
  "Vermietung",
  "Bootszubehör",
  "Liegeplätze",
];

const List<String> anhaengerUnterkategorien = [
  "Verkauf",
  "Vermietung",
  "Zubehör",
];

const List<String> tierbedarfUnterkategorien = [
  "Hunde",
  "Katzen",
  "Pferdebedarf",
  "Vögel",
  "Kleintiere",
  "Aquaristik",
  "Futter",
  "Sonstiges",
];

const List<String> baumarktUnterkategorien = [
  "Werkzeug",
  "Maschinen",
  "Baustoffe",
  "Holz",
  "Farben",
  "Sanitär",
  "Elektro",
  "Garten",
  "Leitern & Gerüste",
  "Arbeitsschutz",
  "Sonstiges",
];

const List<String> landwirtschaftUnterkategorien = [
  "Traktoren",
  "Landmaschinen",
  "Forstwirtschaft",
  "Anbaugeräte",
  "Ersatzteile",
  "Stalltechnik",
  "Futtermittel",
];

const List<String> freizeitHobbyUnterkategorien = [
  "Camping",
  "Fahrräder",
  "Outdoor",
  "Musikinstrumente",
  "Modellbau",
  "Sammeln",
  "Bücher",
  "Tickets",
  "Sonstiges",
];

List<String> unterkategorienFuer(String kategorie) {
  switch (kategorie) {
    case "Marktplatz":
      return marktplatzUnterkategorien;
    case "Auto & Motor":
      return autoMotorUnterkategorien;
    case "Immobilien":
      return immobilienUnterkategorien;
    case "Jobs":
      return jobsUnterkategorien;
    case "Dienstleistungen":
      return dienstleistungenUnterkategorien;
    case "Baumaschinen":
      return baumaschinenUnterkategorien;
    case "Boote":
      return booteUnterkategorien;
    case "Anhänger":
      return anhaengerUnterkategorien;
    case "Tierbedarf":
      return tierbedarfUnterkategorien;
    case "Baumarkt":
      return baumarktUnterkategorien;
    case "Landwirtschaft":
      return landwirtschaftUnterkategorien;
    case "Freizeit & Hobby":
      return freizeitHobbyUnterkategorien;
    default:
      return [];
  }
}

/// Detailunterkategorien für Marktplatz.
/// Beispiel:
/// Marktplatz -> Elektronik -> Smartphones
const Map<String, List<String>> marktplatzDetails = {
  "Elektronik": [
    "Smartphones",
    "Tablets",
    "Laptops",
    "PCs",
    "Monitore",
    "TV & Heimkino",
    "Kameras",
    "Smartwatches",
    "Drucker",
    "Sonstiges",
  ],
  "Haus & Wohnen": [
    "Sofas",
    "Tische",
    "Stühle",
    "Schränke",
    "Betten",
    "Matratzen",
    "Dekoration",
    "Lampen",
    "Sonstiges",
  ],
  "Haushalt": [
    "Küchengeräte",
    "Waschmaschinen",
    "Trockner",
    "Staubsauger",
    "Kaffeemaschinen",
    "Geschirr",
    "Sonstiges",
  ],
  "Kleidung & Mode": [
    "Damen",
    "Herren",
    "Kinder",
    "Schuhe",
    "Taschen",
    "Schmuck",
    "Uhren",
    "Accessoires",
  ],
  "Baby & Kinder": [
    "Kinderwagen",
    "Autositze",
    "Spielzeug",
    "Kinderzimmer",
    "Babykleidung",
    "Lernspiele",
    "Sonstiges",
  ],
  "Gaming": [
    "Konsolen",
    "Spiele",
    "Gaming PCs",
    "Controller",
    "Zubehör",
    "Retro Gaming",
  ],
  "Sport & Fitness": [
    "Fitnessgeräte",
    "Fahrradzubehör",
    "Laufsport",
    "Teamsport",
    "Wintersport",
    "Outdoor Sport",
  ],
  "Musik & Hobby": [
    "Gitarren",
    "Klaviere",
    "Schlagzeug",
    "Blasinstrumente",
    "DJ Equipment",
    "Modellbau",
    "Basteln",
    "Sammlerstücke",
  ],
};

List<String> detailUnterkategorienFuer({
  required String kategorie,
  required String unterkategorie,
}) {
  if (kategorie == "Marktplatz") {
    return marktplatzDetails[unterkategorie] ?? [];
  }

  return [];
}

const List<String> allgemeineZustaende = [
  "Neu",
  "Wie neu",
  "Sehr gut",
  "Gut",
  "Gebraucht",
  "Defekt",
];

bool istTierverkaufErlaubt() {
  return false;
}

bool darfPrivatInKategorieInserieren(String kategorie) {
  if (kategorie == "Jobs") return false;
  if (kategorie == "Dienstleistungen") return false;

  return true;
}

bool istFirmenKategorie(String kategorie) {
  return kategorie == "Jobs" || kategorie == "Dienstleistungen";
}

bool istGewerblicheUnterkategorie(String kategorie, String unterkategorie) {
  if (unterkategorie == "Vermietung") return true;
  if (unterkategorie == "Liegeplätze") return true;
  if (kategorie == "Jobs") return true;
  if (kategorie == "Dienstleistungen") return true;

  return false;
}
