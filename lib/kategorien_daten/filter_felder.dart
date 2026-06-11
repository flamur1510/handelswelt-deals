// lib/kategorien_daten/filter_felder.dart

enum FilterFeldTyp {
  marke,
  modell,
  preis,
  baujahr,
  kilometer,
  ps,
  kraftstoff,
  getriebe,
  wohnflaeche,
  grundstueck,
  zimmer,
  laenge,
  breite,
  betriebsstunden,
  gewicht,
  zustand,
  ort,
  umkreis,
  anbieter,

  // Jobs
  berufsgruppe,
  beschaeftigungsart,
  gehalt,
  homeoffice,

  // Dienstleistungen
  dienstleistungsart,
}

const Map<String, List<FilterFeldTyp>> filterFelderProKategorie = {
  'Auto & Motor': [
    FilterFeldTyp.marke,
    FilterFeldTyp.modell,
    FilterFeldTyp.baujahr,
    FilterFeldTyp.kilometer,
    FilterFeldTyp.ps,
    FilterFeldTyp.kraftstoff,
    FilterFeldTyp.getriebe,
    FilterFeldTyp.preis,
    FilterFeldTyp.anbieter,
    FilterFeldTyp.ort,
    FilterFeldTyp.umkreis,
  ],
  'Autos': [
    FilterFeldTyp.marke,
    FilterFeldTyp.modell,
    FilterFeldTyp.baujahr,
    FilterFeldTyp.kilometer,
    FilterFeldTyp.ps,
    FilterFeldTyp.kraftstoff,
    FilterFeldTyp.getriebe,
    FilterFeldTyp.preis,
    FilterFeldTyp.anbieter,
    FilterFeldTyp.ort,
    FilterFeldTyp.umkreis,
  ],
  'Immobilien': [
    FilterFeldTyp.wohnflaeche,
    FilterFeldTyp.grundstueck,
    FilterFeldTyp.zimmer,
    FilterFeldTyp.baujahr,
    FilterFeldTyp.preis,
    FilterFeldTyp.anbieter,
    FilterFeldTyp.ort,
    FilterFeldTyp.umkreis,
  ],
  'Boote': [
    FilterFeldTyp.marke,
    FilterFeldTyp.modell,
    FilterFeldTyp.baujahr,
    FilterFeldTyp.laenge,
    FilterFeldTyp.ps,
    FilterFeldTyp.preis,
    FilterFeldTyp.anbieter,
    FilterFeldTyp.ort,
    FilterFeldTyp.umkreis,
  ],
  'Baumaschinen': [
    FilterFeldTyp.marke,
    FilterFeldTyp.modell,
    FilterFeldTyp.baujahr,
    FilterFeldTyp.betriebsstunden,
    FilterFeldTyp.gewicht,
    FilterFeldTyp.preis,
    FilterFeldTyp.anbieter,
    FilterFeldTyp.ort,
    FilterFeldTyp.umkreis,
  ],
  'Landwirtschaft': [
    FilterFeldTyp.marke,
    FilterFeldTyp.modell,
    FilterFeldTyp.baujahr,
    FilterFeldTyp.betriebsstunden,
    FilterFeldTyp.preis,
    FilterFeldTyp.anbieter,
    FilterFeldTyp.ort,
    FilterFeldTyp.umkreis,
  ],

  // Jobs und Dienstleistungen sind bei Handelswelt nur Firmen.
  // Deshalb gibt es dort keinen Privat/Firma-Filter.
  'Jobs': [
    FilterFeldTyp.berufsgruppe,
    FilterFeldTyp.beschaeftigungsart,
    FilterFeldTyp.gehalt,
    FilterFeldTyp.homeoffice,
    FilterFeldTyp.ort,
    FilterFeldTyp.umkreis,
  ],
  'Dienstleistungen': [
    FilterFeldTyp.dienstleistungsart,
    FilterFeldTyp.ort,
    FilterFeldTyp.umkreis,
  ],
  'Baumarkt': [
    FilterFeldTyp.marke,
    FilterFeldTyp.zustand,
    FilterFeldTyp.preis,
    FilterFeldTyp.anbieter,
    FilterFeldTyp.ort,
    FilterFeldTyp.umkreis,
  ],
  'Marktplatz': [
    FilterFeldTyp.marke,
    FilterFeldTyp.zustand,
    FilterFeldTyp.preis,
    FilterFeldTyp.anbieter,
    FilterFeldTyp.ort,
    FilterFeldTyp.umkreis,
  ],
  'Tierbedarf': [
    FilterFeldTyp.marke,
    FilterFeldTyp.zustand,
    FilterFeldTyp.preis,
    FilterFeldTyp.anbieter,
    FilterFeldTyp.ort,
    FilterFeldTyp.umkreis,
  ],
};

List<FilterFeldTyp> filterFelderFuerKategorie(String kategorie) {
  return filterFelderProKategorie[kategorie] ?? const [
    FilterFeldTyp.preis,
    FilterFeldTyp.anbieter,
    FilterFeldTyp.ort,
    FilterFeldTyp.umkreis,
  ];
}

bool hatFilterFeld(String kategorie, FilterFeldTyp feld) {
  return filterFelderFuerKategorie(kategorie).contains(feld);
}

bool istFirmenKategorie(String kategorie) {
  return kategorie == 'Jobs' || kategorie == 'Dienstleistungen';
}
