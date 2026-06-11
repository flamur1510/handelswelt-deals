// lib/kategorien_daten/marken_hersteller.dart

String _sauber(String wert) => wert.trim().toLowerCase();

List<String> markenHerstellerFuerFilter({
  required String kategorie,
  String unterkategorie = 'Alle',
  String detailUnterkategorie = 'Alle',
}) {
  final k = _sauber(kategorie);
  final u = _sauber(unterkategorie);
  final d = _sauber(detailUnterkategorie);
  final bereich = '$k $u $d';

  if (k == 'alle' || k.isEmpty) {
    return const [];
  }

  if (k.contains('auto') || k.contains('motor') || k.contains('autos')) {
    if (bereich.contains('lkw') ||
        bereich.contains('truck') ||
        bereich.contains('nutzfahrzeug') ||
        bereich.contains('sattelzug') ||
        bereich.contains('zugmaschine')) {
      return _lkwMarken;
    }

    if (bereich.contains('transporter') ||
        bereich.contains('bus') ||
        bereich.contains('kastenwagen') ||
        bereich.contains('van')) {
      return _transporterMarken;
    }

    if (bereich.contains('motorrad') ||
        bereich.contains('moped') ||
        bereich.contains('roller') ||
        bereich.contains('quad')) {
      return _motorradMarken;
    }

    if (bereich.contains('anhänger') || bereich.contains('anhaenger')) {
      return _anhaengerMarken;
    }

    return _pkwMarken;
  }

  if (k.contains('boot')) {
    return _bootsMarken;
  }

  if (k.contains('baumaschine')) {
    return _baumaschinenHersteller;
  }

  if (k.contains('landwirtschaft')) {
    return _landwirtschaftHersteller;
  }

  if (k.contains('baumarkt')) {
    return _baumarktHersteller;
  }

  if (k.contains('marktplatz') ||
      k.contains('elektronik') ||
      k.contains('freizeit') ||
      k.contains('hobby')) {
    return _marktplatzMarken;
  }

  if (k.contains('tierbedarf')) {
    return _tierbedarfMarken;
  }

  return const [];
}

const List<String> _pkwMarken = [
  'Abarth', 'Aiways', 'Alfa Romeo', 'Alpina', 'Aston Martin', 'Audi',
  'Bentley', 'BMW', 'BYD', 'Cadillac', 'Chevrolet', 'Chrysler', 'Citroën',
  'Cupra', 'Dacia', 'Daewoo', 'Daihatsu', 'Dodge', 'DS Automobiles',
  'Ferrari', 'Fiat', 'Ford', 'Genesis', 'Honda', 'Hyundai', 'Infiniti',
  'Isuzu', 'Jaguar', 'Jeep', 'Kia', 'Lada', 'Lamborghini', 'Lancia',
  'Land Rover', 'Lexus', 'Lotus', 'Maserati', 'Mazda', 'McLaren',
  'Mercedes-Benz', 'MG', 'Mini', 'Mitsubishi', 'Nissan', 'Opel', 'Peugeot',
  'Polestar', 'Porsche', 'Renault', 'Rolls-Royce', 'Rover', 'Saab', 'Seat',
  'Skoda', 'Smart', 'SsangYong', 'Subaru', 'Suzuki', 'Tesla', 'Toyota',
  'Volkswagen', 'Volvo', 'Andere Marke', 'Sonstige',
];

const List<String> _lkwMarken = [
  'Mercedes-Benz Trucks', 'MAN', 'Scania', 'Volvo Trucks', 'DAF', 'Iveco',
  'Renault Trucks', 'Ford Trucks', 'Fuso', 'Isuzu Trucks', 'Tatra', 'Unimog',
  'MAN TGL', 'MAN TGM', 'MAN TGX', 'Mercedes Actros', 'Mercedes Atego',
  'Mercedes Arocs', 'Scania R-Serie', 'Scania S-Serie', 'Volvo FH', 'Volvo FM',
  'DAF XF', 'DAF CF', 'Iveco Stralis', 'Iveco S-Way', 'Renault T',
  'Andere LKW-Marke', 'Sonstige',
];

const List<String> _transporterMarken = [
  'Mercedes-Benz', 'Mercedes Sprinter', 'Mercedes Vito', 'Volkswagen',
  'VW Transporter', 'VW Crafter', 'Ford Transit', 'Iveco Daily',
  'Renault Master', 'Renault Trafic', 'Opel Movano', 'Opel Vivaro',
  'Peugeot Boxer', 'Peugeot Expert', 'Citroën Jumper', 'Citroën Jumpy',
  'Fiat Ducato', 'Fiat Talento', 'MAN TGE', 'Nissan NV', 'Toyota Proace',
  'Andere Transporter-Marke', 'Sonstige',
];

const List<String> _motorradMarken = [
  'Aprilia', 'Benelli', 'Beta', 'BMW Motorrad', 'Ducati', 'GasGas',
  'Harley-Davidson', 'Honda', 'Husqvarna', 'Indian', 'Kawasaki', 'KTM',
  'Moto Guzzi', 'Piaggio', 'Royal Enfield', 'Suzuki', 'Triumph', 'Vespa',
  'Yamaha', 'Andere Motorrad-Marke', 'Sonstige',
];

const List<String> _anhaengerMarken = [
  'Böckmann', 'Brenderup', 'Eduard', 'Hapert', 'Humbaur', 'Ifor Williams',
  'Kögel', 'Krone', 'Saris', 'Schmitz Cargobull', 'Stema', 'Unsinn',
  'Andere Anhänger-Marke', 'Sonstige',
];

const List<String> _bootsMarken = [
  'Absolute', 'Azimut', 'Bavaria', 'Bayliner', 'Beneteau', 'Cranchi',
  'Fairline', 'Ferretti', 'Four Winns', 'Galeon', 'Jeanneau', 'Lagoon',
  'MasterCraft', 'Monterey', 'Princess', 'Quicksilver', 'Regal', 'Rinker',
  'Saxdor', 'Sea Ray', 'Sealine', 'Sunseeker', 'Wellcraft', 'Yamaha',
  'Zar Formenti', 'Zodiac', 'Andere Bootsmarke', 'Sonstige',
];

const List<String> _baumaschinenHersteller = [
  'Ammann', 'Atlas', 'Atlas Copco', 'Bobcat', 'Bomag', 'Case', 'Caterpillar',
  'Doosan', 'Dynapac', 'Hitachi', 'Hyundai CE', 'JCB', 'Kobelco', 'Komatsu',
  'Kubota', 'Liebherr', 'Manitou', 'Mecalac', 'Sany', 'Takeuchi', 'Terex',
  'Volvo CE', 'Wacker Neuson', 'Weidemann', 'Yanmar',
  'Andere Baumaschinen-Marke', 'Sonstige',
];

const List<String> _landwirtschaftHersteller = [
  'Amazone', 'Case IH', 'Claas', 'Deutz-Fahr', 'Fendt', 'Fliegl', 'Horsch',
  'John Deere', 'Krone', 'Kubota', 'Kuhn', 'Lemken', 'Massey Ferguson',
  'New Holland', 'Pöttinger', 'Steyr', 'Valtra', 'Weidemann', 'Zetor',
  'Andere Landwirtschafts-Marke', 'Sonstige',
];

const List<String> _baumarktHersteller = [
  'AEG', 'Black+Decker', 'Bosch', 'DeWalt', 'Einhell', 'Festool', 'Gardena',
  'Hikoki', 'Hilti', 'Husqvarna', 'Kärcher', 'Makita', 'Metabo', 'Milwaukee',
  'Parkside', 'Ryobi', 'Stihl', 'Worx', 'Andere Baumarkt-Marke', 'Sonstige',
];

const List<String> _marktplatzMarken = [
  'Acer', 'Apple', 'Asus', 'Beko', 'Bose', 'Bosch', 'Canon', 'Dell', 'Dyson',
  'Electrolux', 'Google', 'HP', 'Huawei', 'Lenovo', 'LG', 'Miele', 'Microsoft',
  'Nikon', 'Nintendo', 'Panasonic', 'Philips', 'Samsung', 'Siemens', 'Sony',
  'Xiaomi', 'Adidas', 'Nike', 'Andere Marke', 'Sonstige',
];

const List<String> _tierbedarfMarken = [
  'AniOne', 'Eheim', 'Ferplast', 'Flexi', 'Fluval', 'Hunter', 'JBL', 'Josera',
  'Karlie', 'Kong', 'Royal Canin', 'Trixie', 'Vitakraft', 'Wolters',
  'Andere Tierbedarf-Marke', 'Sonstige',
];

List<String> modelleFuerMarkeUndBereich({
  required String kategorie,
  String unterkategorie = 'Alle',
  String detailUnterkategorie = 'Alle',
  required String marke,
}) {
  final k = _sauber(kategorie);
  final u = _sauber(unterkategorie);
  final d = _sauber(detailUnterkategorie);
  final m = marke.trim();
  final bereich = '$k $u $d';

  if (m.isEmpty || _sauber(m) == 'alle') return const [];

  if (k.contains('boot')) return _bootModelle[m] ?? const [];
  if (k.contains('baumaschine')) return _baumaschinenModelle[m] ?? const [];
  if (k.contains('landwirtschaft')) return _landwirtschaftModelle[m] ?? const [];

  if (k.contains('auto') || k.contains('motor') || k.contains('autos')) {
    if (bereich.contains('lkw') || bereich.contains('truck') || bereich.contains('nutzfahrzeug')) {
      return _lkwModelle[m] ?? const [];
    }
    if (bereich.contains('transporter') || bereich.contains('bus') || bereich.contains('kastenwagen') || bereich.contains('van')) {
      return _transporterModelle[m] ?? const [];
    }
    if (bereich.contains('motorrad') || bereich.contains('moped') || bereich.contains('roller') || bereich.contains('quad')) {
      return _motorradModelle[m] ?? const [];
    }
    return _pkwModelle[m] ?? const [];
  }

  return const [];
}

const Map<String, List<String>> _pkwModelle = {
  'Audi': ['A1', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'Q2', 'Q3', 'Q5', 'Q7', 'Q8', 'TT', 'e-tron', 'RS3', 'RS4', 'RS6'],
  'BMW': ['1er', '2er', '3er', '4er', '5er', '6er', '7er', '8er', 'X1', 'X2', 'X3', 'X4', 'X5', 'X6', 'X7', 'M2', 'M3', 'M4', 'M5', 'i3', 'i4', 'iX'],
  'Mercedes-Benz': ['A-Klasse', 'B-Klasse', 'C-Klasse', 'E-Klasse', 'S-Klasse', 'CLA', 'CLS', 'GLA', 'GLB', 'GLC', 'GLE', 'GLS', 'G-Klasse', 'V-Klasse', 'AMG GT', 'EQA', 'EQB', 'EQC', 'EQE', 'EQS'],
  'Volkswagen': ['Polo', 'Golf', 'Passat', 'Arteon', 'Touran', 'Tiguan', 'Touareg', 'T-Roc', 'T-Cross', 'ID.3', 'ID.4', 'ID.5', 'Sharan', 'Caddy'],
  'Skoda': ['Fabia', 'Scala', 'Octavia', 'Superb', 'Kamiq', 'Karoq', 'Kodiaq', 'Enyaq'],
  'Seat': ['Ibiza', 'Leon', 'Ateca', 'Arona', 'Tarraco', 'Alhambra'],
  'Ford': ['Fiesta', 'Focus', 'Mondeo', 'Kuga', 'Puma', 'S-Max', 'Galaxy', 'Mustang', 'Explorer'],
  'Opel': ['Corsa', 'Astra', 'Insignia', 'Mokka', 'Crossland', 'Grandland', 'Zafira'],
  'Toyota': ['Yaris', 'Corolla', 'Camry', 'C-HR', 'RAV4', 'Highlander', 'Land Cruiser', 'Prius', 'Proace'],
  'Hyundai': ['i10', 'i20', 'i30', 'IONIQ', 'Kona', 'Tucson', 'Santa Fe', 'Bayon'],
  'Kia': ['Picanto', 'Rio', 'Ceed', 'XCeed', 'Niro', 'Sportage', 'Sorento', 'EV6'],
  'Renault': ['Clio', 'Megane', 'Talisman', 'Captur', 'Kadjar', 'Koleos', 'Scenic', 'Zoe'],
  'Peugeot': ['208', '308', '508', '2008', '3008', '5008', 'Rifter'],
  'Citroën': ['C1', 'C3', 'C4', 'C5 Aircross', 'Berlingo', 'SpaceTourer'],
  'Fiat': ['500', 'Panda', 'Tipo', 'Punto', 'Doblo', 'Ducato'],
  'Mazda': ['2', '3', '6', 'CX-3', 'CX-30', 'CX-5', 'CX-60', 'MX-5'],
  'Nissan': ['Micra', 'Juke', 'Qashqai', 'X-Trail', 'Leaf', 'Navara'],
  'Volvo': ['V40', 'V60', 'V90', 'S60', 'S90', 'XC40', 'XC60', 'XC90'],
  'Tesla': ['Model 3', 'Model S', 'Model X', 'Model Y'],
  'Porsche': ['911', 'Boxster', 'Cayman', 'Panamera', 'Macan', 'Cayenne', 'Taycan'],
};

const Map<String, List<String>> _lkwModelle = {
  'MAN': ['TGL', 'TGM', 'TGS', 'TGX'],
  'Mercedes-Benz Trucks': ['Actros', 'Arocs', 'Atego', 'Econic', 'Unimog'],
  'Scania': ['P-Serie', 'G-Serie', 'R-Serie', 'S-Serie', 'XT'],
  'Volvo Trucks': ['FL', 'FE', 'FM', 'FH', 'FMX'],
  'DAF': ['LF', 'CF', 'XF', 'XG', 'XG+'],
  'Iveco': ['Eurocargo', 'Stralis', 'S-Way', 'Trakker', 'Daily'],
  'Renault Trucks': ['D', 'C', 'K', 'T'],
};

const Map<String, List<String>> _transporterModelle = {
  'Mercedes-Benz': ['Citan', 'Vito', 'Sprinter', 'V-Klasse'],
  'Volkswagen': ['Caddy', 'Transporter', 'Crafter', 'Multivan'],
  'Ford Transit': ['Transit Courier', 'Transit Connect', 'Transit Custom', 'Transit'],
  'Iveco Daily': ['Daily Kasten', 'Daily Pritsche', 'Daily Fahrgestell'],
  'Renault Master': ['Master', 'Trafic', 'Kangoo'],
  'Opel Movano': ['Movano', 'Vivaro', 'Combo'],
  'Peugeot Boxer': ['Boxer', 'Expert', 'Partner'],
  'Citroën Jumper': ['Jumper', 'Jumpy', 'Berlingo'],
  'Fiat Ducato': ['Ducato', 'Talento', 'Doblo'],
};

const Map<String, List<String>> _motorradModelle = {
  'BMW Motorrad': ['GS', 'R 1250 GS', 'S 1000 RR', 'F 900 R', 'F 750 GS', 'K 1600'],
  'KTM': ['Duke', 'Adventure', 'EXC', 'SX', 'Super Duke', 'RC'],
  'Yamaha': ['MT-07', 'MT-09', 'Tenere', 'Tracer', 'R1', 'R6', 'XMAX'],
  'Honda': ['CBR', 'CB', 'Africa Twin', 'Gold Wing', 'Forza', 'SH'],
  'Kawasaki': ['Ninja', 'Z650', 'Z900', 'Versys', 'Vulcan'],
  'Suzuki': ['GSX-R', 'V-Strom', 'SV650', 'Burgman'],
  'Ducati': ['Monster', 'Panigale', 'Multistrada', 'Scrambler', 'Diavel'],
  'Harley-Davidson': ['Sportster', 'Softail', 'Touring', 'Street Glide', 'Fat Boy'],
};

const Map<String, List<String>> _bootModelle = {
  'Bavaria': ['Bavaria 27', 'Bavaria 30', 'Bavaria 34', 'Bavaria 37', 'Bavaria 40', 'Bavaria Cruiser', 'Bavaria Sport'],
  'Bayliner': ['Element', 'VR4', 'VR5', 'VR6', 'Ciera', 'Trophy'],
  'Beneteau': ['Antares', 'Flyer', 'Oceanis', 'First', 'Swift Trawler'],
  'Jeanneau': ['Cap Camarat', 'Merry Fisher', 'Leader', 'Sun Odyssey', 'Prestige'],
  'Sea Ray': ['Sundancer', 'SLX', 'SDX', 'SPX'],
  'Quicksilver': ['Activ 505', 'Activ 605', 'Activ 675', 'Activ 755', 'Captur'],
  'Princess': ['V40', 'V50', 'V55', 'F45', 'F55', 'S60'],
  'Sunseeker': ['Portofino', 'Predator', 'Manhattan', 'Superhawk'],
  'Azimut': ['Atlantis', 'Flybridge', 'S-Serie', 'Magellano'],
};

const Map<String, List<String>> _baumaschinenModelle = {
  'Caterpillar': ['301', '302', '305', '308', '312', '320', '323', '330', '336', 'D6', 'D8'],
  'Komatsu': ['PC26', 'PC55', 'PC80', 'PC138', 'PC210', 'PC240', 'WA100', 'WA320'],
  'Liebherr': ['A 914', 'A 918', 'A 920', 'R 914', 'R 920', 'R 926', 'L 506', 'L 538'],
  'Volvo CE': ['EC18', 'EC35', 'EC140', 'EC220', 'L30', 'L60', 'L90', 'A25'],
  'JCB': ['8008', '8018', '3CX', '4CX', 'JS130', 'JS220', '531-70'],
  'Bobcat': ['E10', 'E19', 'E26', 'E35', 'S70', 'S100', 'T590'],
  'Kubota': ['KX018', 'KX027', 'KX057', 'U10', 'U17', 'U27', 'U55'],
  'Takeuchi': ['TB216', 'TB230', 'TB240', 'TB260', 'TB290', 'TL8'],
};

const Map<String, List<String>> _landwirtschaftModelle = {
  'John Deere': ['5R', '6M', '6R', '7R', '8R', '9R'],
  'Fendt': ['200 Vario', '300 Vario', '500 Vario', '700 Vario', '900 Vario', '1000 Vario'],
  'Steyr': ['Kompakt', 'Multi', 'Profi', 'Expert', 'Terrus'],
  'New Holland': ['T4', 'T5', 'T6', 'T7', 'T8', 'Boomer'],
  'Case IH': ['Farmall', 'Maxxum', 'Puma', 'Optum', 'Magnum'],
  'Claas': ['Arion', 'Axion', 'Xerion', 'Lexion', 'Jaguar'],
  'Massey Ferguson': ['MF 3700', 'MF 4700', 'MF 5700', 'MF 6700', 'MF 7700'],
};
