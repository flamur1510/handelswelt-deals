import 'package:flutter/material.dart';

const List<String> startKategorien = [
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

IconData iconFuerKategorie(String kategorie) {
  switch (kategorie) {
    case "Marktplatz":
      return Icons.storefront_outlined;
    case "Auto & Motor":
      return Icons.directions_car;
    case "Immobilien":
      return Icons.home_work_outlined;
    case "Jobs":
      return Icons.work_outline;
    case "Dienstleistungen":
      return Icons.handyman_outlined;
    case "Baumaschinen":
      return Icons.precision_manufacturing_outlined;
    case "Boote":
      return Icons.sailing_outlined;
    case "Anhänger":
      return Icons.local_shipping_outlined;
    case "Tierbedarf":
      return Icons.pets_outlined;
    case "Baumarkt":
      return Icons.construction_outlined;
    case "Landwirtschaft":
      return Icons.agriculture_outlined;
    case "Freizeit & Hobby":
      return Icons.sports_esports_outlined;
    default:
      return Icons.grid_view_rounded;
  }
}

bool istVermietungsUnterkategorie(String wert) {
  const vermietungen = [
    "Autovermietung",
    "Bootsvermietung",
    "Baumaschinenvermietung",
    "Anhängervermietung",
    "Maschinenvermietung",
    "Immobilie vermieten",
    "Wohnung mieten",
    "Haus mieten",
    "Gewerbeimmobilie vermieten",
    "Garage vermieten",
    "Ferienimmobilie vermieten",
  ];

  return vermietungen.contains(wert);
}

bool istVerkaufsUnterkategorie(String wert) {
  return wert.contains("verkaufen") ||
      wert.contains("kaufen") ||
      wert == "Autoteile" ||
      wert == "Reifen & Felgen" ||
      wert == "Bootszubehör" ||
      wert == "Ersatzteile" ||
      wert == "Futtermittel" ||
      wert == "Stallbedarf" ||
      wert == "Forsttechnik" ||
      wert == "Tiere Zubehör";
}

List<String> unterkategorienFuer(String kategorie) {
  switch (kategorie) {
    case "Marktplatz":
      return [
        "Elektronik",
        "Mode",
        "Möbel",
        "Haushalt",
        "Sport",
        "Baby & Kind",
        "Musik",
        "Bücher",
        "Uhren & Schmuck",
        "Garten",
        "Werkzeug",
        "Spielzeug",
        "Sonstiges",
      ];

    case "Auto & Motor":
      return [
        "Autos verkaufen",
        "Autovermietung",
        "Motorräder verkaufen",
        "Autoteile",
        "Reifen & Felgen",
        "Anhänger verkaufen",
        "Wohnmobile verkaufen",
        "Nutzfahrzeuge verkaufen",
        "Sonstiges",
      ];

    case "Immobilien":
      return [
        "Immobilie verkaufen",
        "Immobilie vermieten",
        "Wohnung kaufen",
        "Wohnung mieten",
        "Haus kaufen",
        "Haus mieten",
        "Grundstück verkaufen",
        "Gewerbeimmobilie verkaufen",
        "Gewerbeimmobilie vermieten",
        "Garage verkaufen",
        "Garage vermieten",
        "Ferienimmobilie verkaufen",
        "Ferienimmobilie vermieten",
        "Sonstiges",
      ];

    case "Jobs":
      return [
        "Vollzeit",
        "Teilzeit",
        "Minijob",
        "Lehrstelle",
        "Praktikum",
        "Freelancer",
        "Homeoffice",
        "Saisonarbeit",
        "Sonstiges",
      ];

    case "Dienstleistungen":
      return [
        "Handwerker",
        "Elektriker",
        "Installateur",
        "Gartenpflege",
        "Reinigung",
        "Umzug",
        "Transport",
        "IT-Service",
        "Fotograf",
        "Nachhilfe",
        "Beauty & Wellness",
        "Kfz-Service",
        "Bauarbeiten",
        "Sonstiges",
      ];

    case "Baumaschinen":
      return [
        "Baumaschinen verkaufen",
        "Baumaschinenvermietung",
        "Bagger verkaufen",
        "Radlader verkaufen",
        "Kran verkaufen",
        "Dumper verkaufen",
        "Walze verkaufen",
        "Gabelstapler verkaufen",
        "Betonmischer verkaufen",
        "Kompressor verkaufen",
        "Arbeitsbühne verkaufen",
        "Ersatzteile",
        "Sonstiges",
      ];

    case "Boote":
      return [
        "Boote verkaufen",
        "Bootsvermietung",
        "Motorboot verkaufen",
        "Segelboot verkaufen",
        "Yacht verkaufen",
        "Jetski verkaufen",
        "Schlauchboot verkaufen",
        "Hausboot verkaufen",
        "Angelboot verkaufen",
        "Kajak/Kanu verkaufen",
        "Bootszubehör",
        "Bootsanhänger verkaufen",
        "Sonstiges",
      ];

    case "Anhänger":
      return [
        "Anhänger verkaufen",
        "Anhängervermietung",
        "PKW-Anhänger verkaufen",
        "Kipper verkaufen",
        "Autotransporter verkaufen",
        "Pferdeanhänger verkaufen",
        "Bootsanhänger verkaufen",
        "Wohnwagen verkaufen",
        "Verkaufsanhänger verkaufen",
        "Ersatzteile",
        "Sonstiges",
      ];

    case "Tierbedarf":
      return [
        "Hundezubehör",
        "Katzenzubehör",
        "Aquarium",
        "Kleintierzubehör",
        "Vogelzubehör",
        "Pferdezubehör",
        "Futter",
        "Käfige",
        "Kratzbäume",
        "Transportboxen",
        "Sonstiges",
      ];

    case "Baumarkt":
      return [
        "Werkzeug",
        "Elektrowerkzeug",
        "Baustoffe",
        "Holz",
        "Farben & Lacke",
        "Sanitär",
        "Elektromaterial",
        "Garten",
        "Türen & Fenster",
        "Bodenbeläge",
        "Heizung",
        "Maschinen",
        "Sonstiges",
      ];

    case "Landwirtschaft":
      return [
        "Landmaschinen verkaufen",
        "Maschinenvermietung",
        "Traktoren verkaufen",
        "Anhänger verkaufen",
        "Futtermittel",
        "Stallbedarf",
        "Forsttechnik",
        "Ersatzteile",
        "Tiere Zubehör",
        "Sonstiges",
      ];

    case "Freizeit & Hobby":
      return [
        "Sportgeräte",
        "Camping",
        "Fahrräder",
        "Gaming",
        "Musikinstrumente",
        "Sammlungen",
        "Bücher",
        "Tickets",
        "Wassersport",
        "Wintersport",
        "Sonstiges",
      ];

    default:
      return [];
  }
}

List<String> detailUnterkategorienFuer(
  String kategorie, [
  String? unterkategorie,
]) {
  switch (kategorie) {
    case "Marktplatz":
      switch (unterkategorie) {
        case "Elektronik":
          return [
            "Handys",
            "Tablets",
            "Laptops",
            "PCs",
            "TV",
            "Kameras",
            "Konsolen",
            "Audio",
            "Smartwatch",
            "Zubehör",
          ];
        case "Mode":
          return [
            "Damen",
            "Herren",
            "Kinder",
            "Schuhe",
            "Taschen",
            "Accessoires",
            "Trachten",
            "Sportkleidung",
          ];
        case "Möbel":
          return [
            "Sofa",
            "Bett",
            "Schrank",
            "Tisch",
            "Stühle",
            "Regale",
            "Küche",
            "Badmöbel",
            "Gartenmöbel",
          ];
        case "Haushalt":
          return [
            "Küchengeräte",
            "Waschmaschine",
            "Trockner",
            "Staubsauger",
            "Geschirr",
            "Dekoration",
            "Lampen",
          ];
        case "Sport":
          return [
            "Fitness",
            "Fußball",
            "Ski",
            "Snowboard",
            "Wassersport",
            "Outdoor",
            "Fahrradzubehör",
          ];
        case "Baby & Kind":
          return [
            "Kinderwagen",
            "Autositze",
            "Kleidung",
            "Spielzeug",
            "Babybett",
            "Kindermöbel",
          ];
        case "Musik":
          return [
            "Gitarren",
            "Klavier",
            "Keyboard",
            "DJ",
            "Studio",
            "Blasinstrumente",
            "Zubehör",
          ];
        case "Bücher":
          return [
            "Romane",
            "Schule",
            "Studium",
            "Fachbücher",
            "Kinderbücher",
            "Comics",
          ];
        case "Uhren & Schmuck":
          return [
            "Uhren",
            "Ringe",
            "Ketten",
            "Armbänder",
            "Ohrringe",
            "Luxus",
          ];
        case "Garten":
          return [
            "Gartengeräte",
            "Pflanzen",
            "Gartenmöbel",
            "Grill",
            "Pool",
            "Dekoration",
          ];
        case "Werkzeug":
          return [
            "Handwerkzeug",
            "Elektrowerkzeug",
            "Werkstatt",
            "Leitern",
            "Maschinen",
          ];
        case "Spielzeug":
          return [
            "Lego",
            "Playmobil",
            "Puppen",
            "Brettspiele",
            "Outdoor-Spielzeug",
          ];
        default:
          return [];
      }

    case "Auto & Motor":
      switch (unterkategorie) {
        case "Autos verkaufen":
          return [
            "Limousine",
            "Kombi",
            "SUV",
            "Cabrio",
            "Coupe",
            "Kleinwagen",
            "Van",
            "Sportwagen",
            "Oldtimer",
          ];
        case "Autovermietung":
          return [
            "PKW",
            "Transporter",
            "Luxusauto",
            "Oldtimer",
            "Wohnmobil",
            "Nutzfahrzeug",
            "7-Sitzer",
            "Elektroauto",
          ];
        case "Motorräder verkaufen":
          return [
            "Supersportler",
            "Naked Bike",
            "Tourer",
            "Enduro",
            "Motocross",
            "Roller",
            "Chopper/Cruiser",
            "Quad/ATV",
          ];
        case "Autoteile":
          return [
            "Motor",
            "Bremsen",
            "Karosserie",
            "Innenraum",
            "Elektronik",
            "Auspuff",
            "Fahrwerk",
            "Scheinwerfer",
          ];
        case "Reifen & Felgen":
          return [
            "Sommerreifen",
            "Winterreifen",
            "Ganzjahresreifen",
            "Alufelgen",
            "Stahlfelgen",
            "Kompletträder",
          ];
        case "Anhänger verkaufen":
          return [
            "PKW-Anhänger",
            "Kipper",
            "Autotransporter",
            "Pferdeanhänger",
            "Bootsanhänger",
            "Planenanhänger",
          ];
        case "Wohnmobile verkaufen":
          return [
            "Wohnmobil",
            "Wohnwagen",
            "Campervan",
            "Kastenwagen",
            "Alkoven",
            "Teilintegriert",
          ];
        case "Nutzfahrzeuge verkaufen":
          return [
            "Transporter",
            "LKW",
            "Bus",
            "Pickup",
            "Kühlfahrzeug",
            "Kipper",
          ];
        default:
          return [];
      }

    case "Immobilien":
      switch (unterkategorie) {
        case "Immobilie verkaufen":
          return [
            "Wohnung",
            "Haus",
            "Grundstück",
            "Gewerbe",
            "Garage",
            "Ferienimmobilie",
            "Zinshaus",
          ];
        case "Immobilie vermieten":
          return [
            "Wohnung",
            "Haus",
            "Gewerbe",
            "Garage",
            "Ferienimmobilie",
            "Zimmer",
            "Lagerfläche",
          ];
        case "Wohnung kaufen":
          return [
            "Garçonnière",
            "2-Zimmer",
            "3-Zimmer",
            "4-Zimmer",
            "Penthouse",
            "Maisonette",
            "Altbau",
            "Neubau",
          ];
        case "Wohnung mieten":
          return [
            "Garçonnière",
            "2-Zimmer",
            "3-Zimmer",
            "4-Zimmer",
            "Penthouse",
            "Maisonette",
            "Altbau",
            "Neubau",
            "WG-Zimmer",
          ];
        case "Haus kaufen":
          return [
            "Einfamilienhaus",
            "Mehrfamilienhaus",
            "Reihenhaus",
            "Doppelhaushälfte",
            "Villa",
            "Bauernhaus",
            "Bungalow",
          ];
        case "Haus mieten":
          return [
            "Einfamilienhaus",
            "Reihenhaus",
            "Doppelhaushälfte",
            "Villa",
            "Bauernhaus",
            "Bungalow",
          ];
        case "Grundstück verkaufen":
          return [
            "Baugrund",
            "Garten",
            "Acker",
            "Wald",
            "Gewerbegrund",
            "Freizeitgrund",
          ];
        case "Gewerbeimmobilie verkaufen":
          return [
            "Büro",
            "Lager",
            "Geschäftslokal",
            "Praxis",
            "Gastronomie",
            "Halle",
            "Hotel",
          ];
        case "Gewerbeimmobilie vermieten":
          return [
            "Büro",
            "Lager",
            "Geschäftslokal",
            "Praxis",
            "Gastronomie",
            "Halle",
            "Coworking",
          ];
        case "Garage verkaufen":
        case "Garage vermieten":
          return [
            "Einzelgarage",
            "Tiefgarage",
            "Carport",
            "Stellplatz",
            "Doppelgarage",
          ];
        case "Ferienimmobilie verkaufen":
        case "Ferienimmobilie vermieten":
          return [
            "Ferienwohnung",
            "Ferienhaus",
            "Chalet",
            "Apartment",
            "Seehaus",
          ];
        default:
          return [];
      }

    case "Jobs":
      switch (unterkategorie) {
        case "Vollzeit":
        case "Teilzeit":
        case "Minijob":
        case "Lehrstelle":
        case "Praktikum":
        case "Freelancer":
        case "Homeoffice":
        case "Saisonarbeit":
          return [
            "Handwerk",
            "Büro",
            "Verkauf",
            "Gastronomie",
            "IT",
            "Pflege",
            "Bau",
            "Fahrer",
            "Lager",
            "Reinigung",
            "Sonstiges",
          ];
        default:
          return [];
      }

    case "Dienstleistungen":
      switch (unterkategorie) {
        case "Handwerker":
          return [
            "Maler",
            "Fliesenleger",
            "Tischler",
            "Maurer",
            "Dachdecker",
            "Bodenleger",
            "Allrounder",
          ];
        case "Elektriker":
          return [
            "Installation",
            "Reparatur",
            "Smart Home",
            "Photovoltaik",
            "E-Check",
          ];
        case "Installateur":
          return [
            "Heizung",
            "Sanitär",
            "Rohrbruch",
            "Badumbau",
            "Thermenservice",
          ];
        case "Gartenpflege":
          return [
            "Rasen mähen",
            "Heckenschnitt",
            "Baumpflege",
            "Gartenbau",
            "Winterdienst",
          ];
        case "Reinigung":
          return [
            "Haushalt",
            "Büro",
            "Fenster",
            "Baureinigung",
            "Teppichreinigung",
          ];
        case "Umzug":
          return [
            "Privatumzug",
            "Firmenumzug",
            "Entrümpelung",
            "Möbeltransport",
            "Montage",
          ];
        case "Transport":
          return [
            "Kleintransport",
            "Möbeltransport",
            "Express",
            "Lieferung",
            "Entsorgung",
          ];
        case "IT-Service":
          return [
            "PC Reparatur",
            "Netzwerk",
            "Webseite",
            "App",
            "Datenrettung",
            "Support",
          ];
        case "Fotograf":
          return [
            "Hochzeit",
            "Portrait",
            "Produktfotos",
            "Immobilienfotos",
            "Event",
          ];
        case "Nachhilfe":
          return [
            "Mathematik",
            "Deutsch",
            "Englisch",
            "Sprachen",
            "EDV",
            "Schule",
          ];
        case "Beauty & Wellness":
          return [
            "Friseur",
            "Kosmetik",
            "Massage",
            "Nägel",
            "Make-up",
          ];
        case "Kfz-Service":
          return [
            "Reparatur",
            "Reifenwechsel",
            "Aufbereitung",
            "Pickerl-Vorbereitung",
            "Pannenhilfe",
          ];
        case "Bauarbeiten":
          return [
            "Innenausbau",
            "Trockenbau",
            "Pflasterung",
            "Abbruch",
            "Renovierung",
          ];
        default:
          return [];
      }

    case "Baumaschinen":
      switch (unterkategorie) {
        case "Baumaschinen verkaufen":
          return [
            "Bagger",
            "Radlader",
            "Kran",
            "Dumper",
            "Walze",
            "Gabelstapler",
            "Arbeitsbühne",
            "Kompressor",
            "Betonmischer",
          ];
        case "Baumaschinenvermietung":
          return [
            "Bagger",
            "Radlader",
            "Kran",
            "Arbeitsbühne",
            "Gabelstapler",
            "Walze",
            "Kompressor",
            "Betonmischer",
            "Rüttelplatte",
          ];
        case "Bagger verkaufen":
          return [
            "Minibagger",
            "Kettenbagger",
            "Mobilbagger",
            "Schaufelbagger",
            "Raupenbagger",
          ];
        case "Radlader verkaufen":
          return [
            "Kompaktlader",
            "Hoflader",
            "Teleskoplader",
            "Skidsteer",
          ];
        case "Kran verkaufen":
          return [
            "Mobilkran",
            "Turmkran",
            "Ladekran",
            "Minikran",
          ];
        case "Dumper verkaufen":
          return [
            "Minidumper",
            "Raddumper",
            "Kettendumper",
          ];
        case "Walze verkaufen":
          return [
            "Tandemwalze",
            "Grabenwalze",
            "Vibrationswalze",
          ];
        case "Gabelstapler verkaufen":
          return [
            "Diesel",
            "Elektro",
            "Gas",
            "Hochhubwagen",
            "Teleskopstapler",
          ];
        case "Betonmischer verkaufen":
          return [
            "Handmischer",
            "Fahrmischer",
            "Betonpumpe",
          ];
        case "Kompressor verkaufen":
          return [
            "Baukompressor",
            "Druckluft",
            "Schraubenkompressor",
          ];
        case "Arbeitsbühne verkaufen":
          return [
            "Scherenbühne",
            "Teleskopbühne",
            "Gelenkbühne",
            "Anhängerbühne",
          ];
        case "Ersatzteile":
          return [
            "Schaufeln",
            "Hydraulik",
            "Ketten",
            "Reifen",
            "Motoren",
            "Filter",
          ];
        default:
          return [];
      }

    case "Boote":
      switch (unterkategorie) {
        case "Boote verkaufen":
          return [
            "Motorboot",
            "Segelboot",
            "Yacht",
            "Jetski",
            "Hausboot",
            "Angelboot",
            "Kajak/Kanu",
            "Schlauchboot",
          ];
        case "Bootsvermietung":
          return [
            "Motorboot",
            "Segelboot",
            "Yacht",
            "Jetski",
            "Hausboot",
            "Kajak/Kanu",
            "Schlauchboot",
            "Angelboot",
          ];
        case "Motorboot verkaufen":
          return [
            "Sportboot",
            "Kajütboot",
            "Daycruiser",
            "Fischerboot",
            "Bowrider",
          ];
        case "Segelboot verkaufen":
          return [
            "Jolle",
            "Segelyacht",
            "Katamaran",
            "Daysailer",
          ];
        case "Yacht verkaufen":
          return [
            "Motoryacht",
            "Segelyacht",
            "Luxusyacht",
            "Flybridge",
          ];
        case "Jetski verkaufen":
          return [
            "1-Sitzer",
            "2-Sitzer",
            "3-Sitzer",
            "Sport",
          ];
        case "Schlauchboot verkaufen":
          return [
            "Mit Motor",
            "Ohne Motor",
            "RIB",
            "Tender",
          ];
        case "Hausboot verkaufen":
          return [
            "Klassisch",
            "Modern",
            "Floating Home",
          ];
        case "Angelboot verkaufen":
          return [
            "Aluboot",
            "GFK",
            "Kajütboot",
            "Bass Boat",
          ];
        case "Kajak/Kanu verkaufen":
          return [
            "Kajak",
            "Kanu",
            "SUP",
            "Faltboot",
          ];
        case "Bootszubehör":
          return [
            "Motoren",
            "Navigation",
            "Anker",
            "Seile",
            "Sitze",
            "Trailerzubehör",
            "Sicherheitsausrüstung",
          ];
        case "Bootsanhänger verkaufen":
          return [
            "Einachser",
            "Zweiachser",
            "Slipwagen",
            "Hafentrailer",
          ];
        default:
          return [];
      }

    case "Anhänger":
      switch (unterkategorie) {
        case "Anhänger verkaufen":
          return [
            "PKW-Anhänger",
            "Kipper",
            "Autotransporter",
            "Pferdeanhänger",
            "Bootsanhänger",
            "Wohnwagen",
            "Verkaufsanhänger",
          ];
        case "Anhängervermietung":
          return [
            "PKW-Anhänger",
            "Kipper",
            "Autotransporter",
            "Pferdeanhänger",
            "Bootsanhänger",
            "Verkaufsanhänger",
            "Planenanhänger",
          ];
        case "PKW-Anhänger verkaufen":
          return [
            "Einachser",
            "Zweiachser",
            "Planenanhänger",
            "Kastenanhänger",
            "Hochlader",
            "Tieflader",
          ];
        case "Kipper verkaufen":
          return [
            "Einseitenkipper",
            "Dreiseitenkipper",
            "Rückwärtskipper",
          ];
        case "Autotransporter verkaufen":
          return [
            "Einachser",
            "Zweiachser",
            "Geschlossen",
            "Offen",
          ];
        case "Pferdeanhänger verkaufen":
          return [
            "1-Pferd",
            "2-Pferde",
            "3-Pferde",
            "Mit Sattelkammer",
          ];
        case "Bootsanhänger verkaufen":
          return [
            "Einachser",
            "Zweiachser",
            "Hafentrailer",
            "Sliptrailer",
          ];
        case "Wohnwagen verkaufen":
          return [
            "Klein",
            "Familie",
            "Luxus",
            "Oldtimer",
          ];
        case "Verkaufsanhänger verkaufen":
          return [
            "Imbiss",
            "Marktstand",
            "Kühlanhänger",
            "Foodtruck-Anhänger",
          ];
        case "Ersatzteile":
          return [
            "Achsen",
            "Bremsen",
            "Kupplung",
            "Reifen",
            "Beleuchtung",
          ];
        default:
          return [];
      }

    case "Tierbedarf":
      switch (unterkategorie) {
        case "Hundezubehör":
          return [
            "Leinen",
            "Halsbänder",
            "Hundebetten",
            "Spielzeug",
            "Transportboxen",
            "Näpfe",
          ];
        case "Katzenzubehör":
          return [
            "Kratzbäume",
            "Katzenklos",
            "Körbe",
            "Spielzeug",
            "Transportboxen",
          ];
        case "Aquarium":
          return [
            "Aquarien",
            "Filter",
            "Beleuchtung",
            "Dekoration",
            "Pumpen",
          ];
        case "Kleintierzubehör":
          return [
            "Käfige",
            "Streu",
            "Häuschen",
            "Laufräder",
            "Futter",
          ];
        case "Vogelzubehör":
          return [
            "Käfige",
            "Volieren",
            "Sitzstangen",
            "Futter",
            "Spielzeug",
          ];
        case "Pferdezubehör":
          return [
            "Sattel",
            "Trense",
            "Decken",
            "Pflege",
            "Stallbedarf",
          ];
        case "Futter":
          return [
            "Hund",
            "Katze",
            "Pferd",
            "Vogel",
            "Kleintier",
            "Fisch",
          ];
        case "Käfige":
          return [
            "Hundebox",
            "Vogelkäfig",
            "Kleintierkäfig",
            "Transportbox",
          ];
        case "Kratzbäume":
          return [
            "Klein",
            "Mittel",
            "Groß",
            "Wandmontage",
          ];
        default:
          return [];
      }

    case "Baumarkt":
      switch (unterkategorie) {
        case "Werkzeug":
          return [
            "Handwerkzeug",
            "Maschinen",
            "Werkstatt",
            "Leitern",
            "Messwerkzeug",
          ];
        case "Elektrowerkzeug":
          return [
            "Bohrmaschine",
            "Akkuschrauber",
            "Säge",
            "Schleifer",
            "Fräse",
            "Set",
          ];
        case "Baustoffe":
          return [
            "Zement",
            "Ziegel",
            "Dämmung",
            "Gipskarton",
            "Beton",
            "Sand/Kies",
          ];
        case "Holz":
          return [
            "Bretter",
            "Balken",
            "Platten",
            "Terrassendielen",
            "Restholz",
          ];
        case "Farben & Lacke":
          return [
            "Wandfarbe",
            "Lack",
            "Lasur",
            "Pinsel/Rollen",
            "Grundierung",
          ];
        case "Sanitär":
          return [
            "Waschbecken",
            "WC",
            "Dusche",
            "Armaturen",
            "Badewanne",
            "Rohre",
          ];
        case "Elektromaterial":
          return [
            "Kabel",
            "Schalter",
            "Steckdosen",
            "Sicherungen",
            "Beleuchtung",
          ];
        case "Garten":
          return [
            "Rasenmäher",
            "Gartengeräte",
            "Bewässerung",
            "Gartenhaus",
            "Zaun",
          ];
        case "Türen & Fenster":
          return [
            "Innentüren",
            "Haustüren",
            "Fenster",
            "Rollläden",
            "Beschläge",
          ];
        case "Bodenbeläge":
          return [
            "Laminat",
            "Parkett",
            "Vinyl",
            "Fliesen",
            "Teppich",
          ];
        case "Heizung":
          return [
            "Heizkörper",
            "Thermostate",
            "Öfen",
            "Zubehör",
            "Wärmepumpe",
          ];
        case "Maschinen":
          return [
            "Betonmischer",
            "Kompressor",
            "Stromerzeuger",
            "Rüttelplatte",
            "Schweißgerät",
          ];
        default:
          return [];
      }

    case "Landwirtschaft":
      switch (unterkategorie) {
        case "Landmaschinen verkaufen":
          return [
            "Mähwerk",
            "Pflug",
            "Sämaschine",
            "Presse",
            "Güllefass",
            "Ladewagen",
          ];
        case "Maschinenvermietung":
          return [
            "Traktor",
            "Mähwerk",
            "Pflug",
            "Sämaschine",
            "Presse",
            "Forsttechnik",
            "Anhänger",
            "Hoflader",
          ];
        case "Traktoren verkaufen":
          return [
            "Kleintraktor",
            "Standardtraktor",
            "Oldtimer-Traktor",
            "Schmalspur",
            "Allrad",
          ];
        case "Anhänger verkaufen":
          return [
            "Kipper",
            "Ladewagen",
            "Tieflader",
            "Güllefass",
            "Ballentransport",
          ];
        case "Futtermittel":
          return [
            "Heu",
            "Stroh",
            "Silage",
            "Kraftfutter",
            "Mineralfutter",
          ];
        case "Stallbedarf":
          return [
            "Tränken",
            "Futterraufen",
            "Boxen",
            "Tore",
            "Melktechnik",
          ];
        case "Forsttechnik":
          return [
            "Seilwinde",
            "Holzspalter",
            "Säge",
            "Rückewagen",
            "Forstkran",
          ];
        case "Ersatzteile":
          return [
            "Reifen",
            "Hydraulik",
            "Zapfwelle",
            "Filter",
            "Anbauteile",
          ];
        case "Tiere Zubehör":
          return [
            "Weidezaun",
            "Futterstellen",
            "Transport",
            "Pflege",
          ];
        default:
          return [];
      }

    case "Freizeit & Hobby":
      switch (unterkategorie) {
        case "Sportgeräte":
          return [
            "Fitness",
            "Fußball",
            "Ski",
            "Wassersport",
            "Tennis",
            "Klettern",
          ];
        case "Camping":
          return [
            "Zelte",
            "Campingmöbel",
            "Kocher",
            "Schlafsäcke",
            "Kühlbox",
            "Wohnmobilzubehör",
          ];
        case "Fahrräder":
          return [
            "Mountainbike",
            "E-Bike",
            "Rennrad",
            "Citybike",
            "Kinderfahrrad",
            "Zubehör",
          ];
        case "Gaming":
          return [
            "Konsolen",
            "Spiele",
            "Controller",
            "PC Gaming",
            "Headsets",
            "Zubehör",
          ];
        case "Musikinstrumente":
          return [
            "Gitarre",
            "Bass",
            "Klavier",
            "Keyboard",
            "Schlagzeug",
            "Blasinstrumente",
          ];
        case "Sammlungen":
          return [
            "Münzen",
            "Briefmarken",
            "Karten",
            "Figuren",
            "Antiquitäten",
          ];
        case "Bücher":
          return [
            "Romane",
            "Fachbücher",
            "Kinderbücher",
            "Comics",
            "Schule",
          ];
        case "Tickets":
          return [
            "Konzert",
            "Sport",
            "Theater",
            "Festival",
            "Sonstiges",
          ];
        case "Wassersport":
          return [
            "SUP",
            "Surfbrett",
            "Tauchen",
            "Kajak",
            "Zubehör",
          ];
        case "Wintersport":
          return [
            "Ski",
            "Snowboard",
            "Schuhe",
            "Helm",
            "Bekleidung",
          ];
        default:
          return [];
      }

    default:
      return [];
  }
}


String suchfilterAnzeigeText(String wert) {
  switch (wert) {
    case "Autos verkaufen":
      return "Autos kaufen";
    case "Motorräder verkaufen":
      return "Motorräder kaufen";
    case "Anhänger verkaufen":
      return "Anhänger kaufen";
    case "Wohnmobile verkaufen":
      return "Wohnmobile kaufen";
    case "Nutzfahrzeuge verkaufen":
      return "Nutzfahrzeuge kaufen";

    case "Immobilie verkaufen":
      return "Immobilie kaufen";
    case "Immobilie vermieten":
      return "Immobilie mieten";
    case "Grundstück verkaufen":
      return "Grundstück kaufen";
    case "Gewerbeimmobilie verkaufen":
      return "Gewerbeimmobilie kaufen";
    case "Gewerbeimmobilie vermieten":
      return "Gewerbeimmobilie mieten";
    case "Garage verkaufen":
      return "Garage kaufen";
    case "Garage vermieten":
      return "Garage mieten";
    case "Ferienimmobilie verkaufen":
      return "Ferienimmobilie kaufen";
    case "Ferienimmobilie vermieten":
      return "Ferienimmobilie mieten";

    case "Baumaschinen verkaufen":
      return "Baumaschinen kaufen";
    case "Baumaschinenvermietung":
      return "Baumaschinen mieten";
    case "Bagger verkaufen":
      return "Bagger kaufen";
    case "Radlader verkaufen":
      return "Radlader kaufen";
    case "Kran verkaufen":
      return "Kran kaufen";
    case "Dumper verkaufen":
      return "Dumper kaufen";
    case "Walze verkaufen":
      return "Walze kaufen";
    case "Gabelstapler verkaufen":
      return "Gabelstapler kaufen";
    case "Betonmischer verkaufen":
      return "Betonmischer kaufen";
    case "Kompressor verkaufen":
      return "Kompressor kaufen";
    case "Arbeitsbühne verkaufen":
      return "Arbeitsbühne kaufen";

    case "Boote verkaufen":
      return "Boote kaufen";
    case "Bootsvermietung":
      return "Boote mieten";
    case "Motorboot verkaufen":
      return "Motorboot kaufen";
    case "Segelboot verkaufen":
      return "Segelboot kaufen";
    case "Yacht verkaufen":
      return "Yacht kaufen";
    case "Jetski verkaufen":
      return "Jetski kaufen";
    case "Schlauchboot verkaufen":
      return "Schlauchboot kaufen";
    case "Hausboot verkaufen":
      return "Hausboot kaufen";
    case "Angelboot verkaufen":
      return "Angelboot kaufen";
    case "Kajak/Kanu verkaufen":
      return "Kajak/Kanu kaufen";
    case "Bootsanhänger verkaufen":
      return "Bootsanhänger kaufen";

    case "Autovermietung":
      return "Auto mieten";
    case "Anhängervermietung":
      return "Anhänger mieten";
    case "PKW-Anhänger verkaufen":
      return "PKW-Anhänger kaufen";
    case "Kipper verkaufen":
      return "Kipper kaufen";
    case "Autotransporter verkaufen":
      return "Autotransporter kaufen";
    case "Pferdeanhänger verkaufen":
      return "Pferdeanhänger kaufen";
    case "Wohnwagen verkaufen":
      return "Wohnwagen kaufen";
    case "Verkaufsanhänger verkaufen":
      return "Verkaufsanhänger kaufen";

    case "Landmaschinen verkaufen":
      return "Landmaschinen kaufen";
    case "Maschinenvermietung":
      return "Maschinen mieten";
    case "Traktoren verkaufen":
      return "Traktoren kaufen";

    default:
      return wert;
  }
}

List<String> unterkategorienSucheFuer(String kategorie) {
  return unterkategorienFuer(kategorie);
}

List<String> detailUnterkategorienSucheFuer(
  String kategorie, [
  String? unterkategorie,
]) {
  return detailUnterkategorienFuer(kategorie, unterkategorie);
}


bool darfPrivatInserieren(String kategorie) {
  switch (kategorie) {
    case "Jobs":
    case "Dienstleistungen":
      return false;
    default:
      return true;
  }
}

bool istGewerblicheUnterkategorie(
  String kategorie,
  String unterkategorie,
) {
  if (kategorie == "Jobs") return true;
  if (kategorie == "Dienstleistungen") return true;

  if (istVermietungsUnterkategorie(unterkategorie)) {
    return true;
  }

  if (kategorie == "Immobilien" &&
      (unterkategorie == "Gewerbeimmobilie verkaufen" ||
          unterkategorie == "Gewerbeimmobilie vermieten")) {
    return true;
  }

  return false;
}
