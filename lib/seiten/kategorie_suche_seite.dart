import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../kategorien_daten/kategorien.dart' as kdaten;
import '../model/produkt.dart';
import 'detail_seite.dart';

class KategorieSucheSeite extends StatefulWidget {
  final String kategorie;
  final List<Produkt> produkte;

  const KategorieSucheSeite({
    super.key,
    required this.kategorie,
    required this.produkte,
  });

  @override
  State<KategorieSucheSeite> createState() => _KategorieSucheSeiteState();
}

class _KategorieSucheSeiteState extends State<KategorieSucheSeite> {
  final sucheController = TextEditingController();
  final preisVonController = TextEditingController();
  final preisBisController = TextEditingController();
  final ortController = TextEditingController();

  final markeController = TextEditingController();
  final modellController = TextEditingController();
  final kilometerVonController = TextEditingController();
  final kilometerBisController = TextEditingController();
  final baujahrVonController = TextEditingController();
  final baujahrBisController = TextEditingController();

  final wohnflaecheVonController = TextEditingController();
  final wohnflaecheBisController = TextEditingController();
  final zimmerController = TextEditingController();

  final mietpreisTagVonController = TextEditingController();
  final mietpreisTagBisController = TextEditingController();
  final mietpreisWocheVonController = TextEditingController();
  final mietpreisWocheBisController = TextEditingController();

  String kontoFilter = 'Alle';
  String vermietungFilter = 'Alle';
  String sortierung = 'Neueste zuerst';
  String unterkategorieFilter = 'Alle';
  String detailUnterkategorieFilter = 'Alle';
  String umkreisFilter = 'Ganz Österreich';

  String kraftstoffFilter = 'Alle';
  String getriebeFilter = 'Alle';
  String unfallfreiFilter = 'Alle';
  String inzahlungnahmeFilter = 'Alle';

  String balkonFilter = 'Alle';
  String garageFilter = 'Alle';
  String moebliertFilter = 'Alle';
  String gartenFilter = 'Alle';
  String liftFilter = 'Alle';

  String lieferungFilter = 'Alle';
  String versicherungFilter = 'Alle';

  bool standortLaedt = false;
  bool standortAktiv = false;
  double? meineLatitude;
  double? meineLongitude;

  final jaNeinAlle = const ['Alle', 'Ja', 'Nein'];

  final kraftstoffe = const [
    'Alle',
    'Benzin',
    'Diesel',
    'Elektro',
    'Hybrid',
    'Plug-in Hybrid',
    'Gas',
  ];

  final getriebeArten = const [
    'Alle',
    'Automatik',
    'Manuell',
    'Halbautomatik',
  ];

  final umkreisWerte = const [
    'Ganz Österreich',
    '10 km',
    '25 km',
    '50 km',
    '100 km',
  ];

  double zahl(String text) {
    final sauber = text
        .replaceAll('€', '')
        .replaceAll('km', '')
        .replaceAll('m²', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();

    return double.tryParse(sauber) ?? 0;
  }

  DateTime datum(Produkt produkt) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  bool istVermietung(Produkt produkt) {
    return produkt.unterkategorie == 'Autovermietung' ||
        produkt.unterkategorie == 'Bootsvermietung' ||
        produkt.unterkategorie == 'Baumaschinenvermietung' ||
        produkt.unterkategorie == 'Anhängervermietung' ||
        produkt.unterkategorie == 'Maschinenvermietung' ||
        produkt.mietpreisTag.trim().isNotEmpty ||
        produkt.mietpreisWoche.trim().isNotEmpty ||
        produkt.mietpreisMonat.trim().isNotEmpty;
  }

  double sortierPreis(Produkt produkt) {
    final vermietung = istVermietung(produkt);

    if (vermietung && produkt.mietpreisTag.trim().isNotEmpty) {
      return zahl(produkt.mietpreisTag);
    }

    if (vermietung && produkt.mietpreisWoche.trim().isNotEmpty) {
      return zahl(produkt.mietpreisWoche);
    }

    return zahl(produkt.preis);
  }

  bool passtJaNein(String filter, String wert) {
    if (filter == 'Alle') return true;
    return wert.toLowerCase().trim() == filter.toLowerCase().trim();
  }

  double entfernungKm(double lat1, double lon1, double lat2, double lon2) {
    const erdradius = 6371.0;
    final dLat = _gradZuRad(lat2 - lat1);
    final dLon = _gradZuRad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_gradZuRad(lat1)) *
            cos(_gradZuRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return erdradius * c;
  }

  double _gradZuRad(double grad) {
    return grad * pi / 180;
  }

  double? umkreisKm() {
    switch (umkreisFilter) {
      case '10 km':
        return 10;
      case '25 km':
        return 25;
      case '50 km':
        return 50;
      case '100 km':
        return 100;
      default:
        return null;
    }
  }

  Future<void> standortAktivieren() async {
    setState(() {
      standortLaedt = true;
    });

    try {
      final dienstAktiv = await Geolocator.isLocationServiceEnabled();
      if (!dienstAktiv) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitte Standort am Gerät aktivieren.')),
        );
        return;
      }

      LocationPermission erlaubnis = await Geolocator.checkPermission();
      if (erlaubnis == LocationPermission.denied) {
        erlaubnis = await Geolocator.requestPermission();
      }

      if (erlaubnis == LocationPermission.denied ||
          erlaubnis == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Standort-Berechtigung wurde nicht erlaubt.')),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;
      setState(() {
        meineLatitude = position.latitude;
        meineLongitude = position.longitude;
        standortAktiv = true;
        umkreisFilter = '25 km';
        ortController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Standort Fehler: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          standortLaedt = false;
        });
      }
    }
  }

  void standortDeaktivieren() {
    setState(() {
      standortAktiv = false;
      meineLatitude = null;
      meineLongitude = null;
      umkreisFilter = 'Ganz Österreich';
    });
  }

  bool passtZumUmkreis(Produkt produkt, List<Produkt> basisListe) {
    final radius = umkreisKm();
    if (radius == null) return true;

    if (standortAktiv && meineLatitude != null && meineLongitude != null) {
      final distanz = entfernungKm(
        meineLatitude!,
        meineLongitude!,
        produkt.latitude,
        produkt.longitude,
      );
      return distanz <= radius;
    }

    final ortSuche = ortController.text.trim().toLowerCase();
    if (ortSuche.isEmpty) return true;

    final referenz = basisListe.where((p) {
      return p.ort.toLowerCase().contains(ortSuche) &&
          p.latitude != 0 &&
          p.longitude != 0;
    }).toList();

    if (referenz.isEmpty) {
      return produkt.ort.toLowerCase().contains(ortSuche);
    }

    final ref = referenz.first;
    final distanz = entfernungKm(
      ref.latitude,
      ref.longitude,
      produkt.latitude,
      produkt.longitude,
    );

    return distanz <= radius;
  }

  Widget feld(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: label.toLowerCase().contains('preis') ||
                label.toLowerCase().contains('km') ||
                label.toLowerCase().contains('baujahr') ||
                label.toLowerCase().contains('zimmer') ||
                label.toLowerCase().contains('m²')
            ? TextInputType.number
            : TextInputType.text,
        onChanged: (_) => setState(() {
          if (label == 'Ort') {
            standortAktiv = false;
            meineLatitude = null;
            meineLongitude = null;
          }
        }),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final sichereItems = items.toSet().toList();
    final sichererWert = sichereItems.contains(value) ? value : sichereItems.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: sichererWert,
        items: sichereItems
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value == null) return;
          onChanged(value);
          setState(() {});
        },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    sucheController.dispose();
    preisVonController.dispose();
    preisBisController.dispose();
    ortController.dispose();

    markeController.dispose();
    modellController.dispose();
    kilometerVonController.dispose();
    kilometerBisController.dispose();
    baujahrVonController.dispose();
    baujahrBisController.dispose();

    wohnflaecheVonController.dispose();
    wohnflaecheBisController.dispose();
    zimmerController.dispose();

    mietpreisTagVonController.dispose();
    mietpreisTagBisController.dispose();
    mietpreisWocheVonController.dispose();
    mietpreisWocheBisController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unterkategorien = [
      'Alle',
      ...kdaten.unterkategorienFuer(widget.kategorie),
    ];

    final detailUnterkategorien = [
      'Alle',
      ...kdaten.detailUnterkategorienFuer(
        widget.kategorie,
        unterkategorieFilter == 'Alle' ? null : unterkategorieFilter,
      ),
    ];

    final basisListe = widget.produkte
        .where((produkt) => produkt.kategorie == widget.kategorie)
        .toList();

    final List<Produkt> produkte = widget.produkte.where((Produkt produkt) {
      if (produkt.kategorie != widget.kategorie) {
        return false;
      }

      if (unterkategorieFilter != 'Alle' &&
          produkt.unterkategorie != unterkategorieFilter) {
        return false;
      }

      if (detailUnterkategorieFilter != 'Alle' &&
          produkt.detailUnterkategorie != detailUnterkategorieFilter) {
        return false;
      }

      final vermietung = istVermietung(produkt);

      if (vermietungFilter == 'Nur Verkauf' && vermietung) return false;
      if (vermietungFilter == 'Nur Vermietung' && !vermietung) return false;

      if (kontoFilter != 'Alle' && produkt.typ != kontoFilter) return false;

      final suchtext = sucheController.text.toLowerCase().trim();
      final passtZurSuche = suchtext.isEmpty ||
          produkt.titel.toLowerCase().contains(suchtext) ||
          produkt.beschreibung.toLowerCase().contains(suchtext) ||
          produkt.unterkategorie.toLowerCase().contains(suchtext) ||
          produkt.detailUnterkategorie.toLowerCase().contains(suchtext) ||
          produkt.marke.toLowerCase().contains(suchtext) ||
          produkt.modell.toLowerCase().contains(suchtext);

      final ortText = ortController.text.trim().toLowerCase();
      final passtZumOrt = standortAktiv ||
          ortText.isEmpty ||
          produkt.ort.toLowerCase().contains(ortText) ||
          passtZumUmkreis(produkt, basisListe);

      final preis = vermietung && produkt.mietpreisTag.trim().isNotEmpty
          ? zahl(produkt.mietpreisTag)
          : zahl(produkt.preis);

      final preisVon =
          preisVonController.text.isEmpty ? 0 : zahl(preisVonController.text);

      final preisBis = preisBisController.text.isEmpty
          ? 999999999
          : zahl(preisBisController.text);

      final passtZumPreis = preis >= preisVon && preis <= preisBis;

      bool autoFilter = true;

      if (widget.kategorie == 'Auto & Motor') {
        final kilometer = zahl(produkt.kilometer);
        final kilometerVon = kilometerVonController.text.isEmpty
            ? 0
            : zahl(kilometerVonController.text);
        final kilometerBis = kilometerBisController.text.isEmpty
            ? 999999999
            : zahl(kilometerBisController.text);

        final baujahr = int.tryParse(produkt.baujahr.trim()) ?? 0;
        final baujahrVon = baujahrVonController.text.isEmpty
            ? 0
            : int.tryParse(baujahrVonController.text.trim()) ?? 0;
        final baujahrBis = baujahrBisController.text.isEmpty
            ? 999999
            : int.tryParse(baujahrBisController.text.trim()) ?? 999999;

        final passtZurMarke = markeController.text.isEmpty ||
            produkt.marke
                .toLowerCase()
                .contains(markeController.text.toLowerCase());

        final passtZumModell = modellController.text.isEmpty ||
            produkt.modell
                .toLowerCase()
                .contains(modellController.text.toLowerCase());

        final passtKraftstoff = kraftstoffFilter == 'Alle' ||
            produkt.kraftstoff.toLowerCase() == kraftstoffFilter.toLowerCase();

        final passtGetriebe = getriebeFilter == 'Alle' ||
            produkt.getriebe.toLowerCase() == getriebeFilter.toLowerCase();

        final passtUnfallfrei = passtJaNein(unfallfreiFilter, produkt.unfallfrei);
        final passtInzahlungnahme =
            passtJaNein(inzahlungnahmeFilter, produkt.inzahlungnahmeMoeglich);

        autoFilter = kilometer >= kilometerVon &&
            kilometer <= kilometerBis &&
            baujahr >= baujahrVon &&
            baujahr <= baujahrBis &&
            passtZurMarke &&
            passtZumModell &&
            passtKraftstoff &&
            passtGetriebe &&
            passtUnfallfrei &&
            passtInzahlungnahme;
      }

      bool immobilienFilter = true;

      if (widget.kategorie == 'Immobilien') {
        final wohnflaeche = zahl(produkt.wohnflaeche);
        final wohnflaecheVon = wohnflaecheVonController.text.isEmpty
            ? 0
            : zahl(wohnflaecheVonController.text);
        final wohnflaecheBis = wohnflaecheBisController.text.isEmpty
            ? 999999999
            : zahl(wohnflaecheBisController.text);

        final zimmer = zahl(produkt.zimmer);
        final zimmerMin =
            zimmerController.text.isEmpty ? 0 : zahl(zimmerController.text);

        immobilienFilter = wohnflaeche >= wohnflaecheVon &&
            wohnflaeche <= wohnflaecheBis &&
            zimmer >= zimmerMin &&
            passtJaNein(balkonFilter, produkt.balkon) &&
            passtJaNein(garageFilter, produkt.garage) &&
            passtJaNein(moebliertFilter, produkt.moebliert) &&
            passtJaNein(gartenFilter, produkt.garten) &&
            passtJaNein(liftFilter, produkt.lift);
      }

      bool vermietungSpezialFilter = true;

      if (vermietungFilter == 'Nur Vermietung' || vermietung) {
        final tag = zahl(produkt.mietpreisTag);
        final woche = zahl(produkt.mietpreisWoche);

        final tagVon = mietpreisTagVonController.text.isEmpty
            ? 0
            : zahl(mietpreisTagVonController.text);
        final tagBis = mietpreisTagBisController.text.isEmpty
            ? 999999999
            : zahl(mietpreisTagBisController.text);

        final wocheVon = mietpreisWocheVonController.text.isEmpty
            ? 0
            : zahl(mietpreisWocheVonController.text);
        final wocheBis = mietpreisWocheBisController.text.isEmpty
            ? 999999999
            : zahl(mietpreisWocheBisController.text);

        vermietungSpezialFilter = tag >= tagVon &&
            tag <= tagBis &&
            woche >= wocheVon &&
            woche <= wocheBis &&
            passtJaNein(lieferungFilter, produkt.lieferungMoeglich) &&
            passtJaNein(versicherungFilter, produkt.versicherung);
      }

      return passtZurSuche &&
          passtZumOrt &&
          passtZumUmkreis(produkt, basisListe) &&
          passtZumPreis &&
          autoFilter &&
          immobilienFilter &&
          vermietungSpezialFilter;
    }).toList();

    if (sortierung == 'Preis aufsteigend') {
      produkte.sort((a, b) => sortierPreis(a).compareTo(sortierPreis(b)));
    }

    if (sortierung == 'Preis absteigend') {
      produkte.sort((a, b) => sortierPreis(b).compareTo(sortierPreis(a)));
    }

    if (sortierung == 'Neueste zuerst') {
      produkte.sort((a, b) => datum(b).compareTo(datum(a)));
    }

    if (sortierung == 'Älteste zuerst') {
      produkte.sort((a, b) => datum(a).compareTo(datum(b)));
    }

    return Scaffold(
      backgroundColor: const Color(0xfff6f3ff),
      appBar: AppBar(
        title: Text(widget.kategorie),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          feld(sucheController, 'Suche'),
          feld(ortController, 'Ort'),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: standortAktiv
                          ? const Color(0xff5b2cff)
                          : Colors.white,
                      foregroundColor: standortAktiv
                          ? Colors.white
                          : const Color(0xff5b2cff),
                      side: const BorderSide(color: Color(0xff5b2cff)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: standortLaedt
                        ? null
                        : (standortAktiv ? standortDeaktivieren : standortAktivieren),
                    icon: standortLaedt
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            standortAktiv
                                ? Icons.location_on
                                : Icons.my_location_outlined,
                          ),
                    label: Text(
                      standortLaedt
                          ? 'Standort wird geholt...'
                          : (standortAktiv ? 'In meiner Nähe aktiv' : 'In meiner Nähe'),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          dropdown(
            label: 'Umkreis',
            value: umkreisFilter,
            items: umkreisWerte,
            onChanged: (value) {
              umkreisFilter = value!;
            },
          ),

          Row(
            children: [
              Expanded(child: feld(preisVonController, 'Preis von')),
              const SizedBox(width: 12),
              Expanded(child: feld(preisBisController, 'Preis bis')),
            ],
          ),

          dropdown(
            label: 'Unterkategorie',
            value: unterkategorieFilter,
            items: unterkategorien,
            onChanged: (value) {
              unterkategorieFilter = value!;
              detailUnterkategorieFilter = 'Alle';
            },
          ),

          if (detailUnterkategorien.length > 1)
            dropdown(
              label: 'Detail-Unterkategorie',
              value: detailUnterkategorieFilter,
              items: detailUnterkategorien,
              onChanged: (value) {
                detailUnterkategorieFilter = value!;
              },
            ),

          dropdown(
            label: 'Privat / Firma',
            value: kontoFilter,
            items: const ['Alle', 'Privat', 'Firma'],
            onChanged: (value) {
              kontoFilter = value!;
            },
          ),

          dropdown(
            label: 'Verkauf / Vermietung',
            value: vermietungFilter,
            items: const ['Alle', 'Nur Verkauf', 'Nur Vermietung'],
            onChanged: (value) {
              vermietungFilter = value!;
            },
          ),

          dropdown(
            label: 'Sortierung',
            value: sortierung,
            items: const [
              'Neueste zuerst',
              'Älteste zuerst',
              'Preis aufsteigend',
              'Preis absteigend',
            ],
            onChanged: (value) {
              sortierung = value!;
            },
          ),

          if (widget.kategorie == 'Auto & Motor') ...[
            const SizedBox(height: 10),
            const Text(
              'Fahrzeugsuche',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            feld(markeController, 'Marke'),
            feld(modellController, 'Modell'),
            Row(
              children: [
                Expanded(child: feld(kilometerVonController, 'KM von')),
                const SizedBox(width: 12),
                Expanded(child: feld(kilometerBisController, 'KM bis')),
              ],
            ),
            Row(
              children: [
                Expanded(child: feld(baujahrVonController, 'Baujahr von')),
                const SizedBox(width: 12),
                Expanded(child: feld(baujahrBisController, 'Baujahr bis')),
              ],
            ),
            dropdown(
              label: 'Kraftstoff',
              value: kraftstoffFilter,
              items: kraftstoffe,
              onChanged: (value) {
                kraftstoffFilter = value!;
              },
            ),
            dropdown(
              label: 'Getriebe',
              value: getriebeFilter,
              items: getriebeArten,
              onChanged: (value) {
                getriebeFilter = value!;
              },
            ),
            dropdown(
              label: 'Unfallfrei',
              value: unfallfreiFilter,
              items: jaNeinAlle,
              onChanged: (value) {
                unfallfreiFilter = value!;
              },
            ),
            dropdown(
              label: 'Inzahlungnahme möglich',
              value: inzahlungnahmeFilter,
              items: jaNeinAlle,
              onChanged: (value) {
                inzahlungnahmeFilter = value!;
              },
            ),
          ],

          if (widget.kategorie == 'Immobilien') ...[
            const SizedBox(height: 10),
            const Text(
              'Immobiliensuche',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: feld(wohnflaecheVonController, 'm² von')),
                const SizedBox(width: 12),
                Expanded(child: feld(wohnflaecheBisController, 'm² bis')),
              ],
            ),
            feld(zimmerController, 'Mindestens Zimmer'),
            dropdown(
              label: 'Balkon',
              value: balkonFilter,
              items: jaNeinAlle,
              onChanged: (value) {
                balkonFilter = value!;
              },
            ),
            dropdown(
              label: 'Garage/Parkplatz',
              value: garageFilter,
              items: jaNeinAlle,
              onChanged: (value) {
                garageFilter = value!;
              },
            ),
            dropdown(
              label: 'Möbliert',
              value: moebliertFilter,
              items: jaNeinAlle,
              onChanged: (value) {
                moebliertFilter = value!;
              },
            ),
            dropdown(
              label: 'Garten',
              value: gartenFilter,
              items: jaNeinAlle,
              onChanged: (value) {
                gartenFilter = value!;
              },
            ),
            dropdown(
              label: 'Lift',
              value: liftFilter,
              items: jaNeinAlle,
              onChanged: (value) {
                liftFilter = value!;
              },
            ),
          ],

          if (vermietungFilter == 'Nur Vermietung') ...[
            const SizedBox(height: 10),
            const Text(
              'Vermietungssuche',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: feld(mietpreisTagVonController, 'Tagespreis von'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: feld(mietpreisTagBisController, 'Tagespreis bis'),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: feld(mietpreisWocheVonController, 'Wochenpreis von'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: feld(mietpreisWocheBisController, 'Wochenpreis bis'),
                ),
              ],
            ),
            dropdown(
              label: 'Lieferung möglich',
              value: lieferungFilter,
              items: jaNeinAlle,
              onChanged: (value) {
                lieferungFilter = value!;
              },
            ),
            dropdown(
              label: 'Versicherung inklusive',
              value: versicherungFilter,
              items: jaNeinAlle,
              onChanged: (value) {
                versicherungFilter = value!;
              },
            ),
          ],

          const SizedBox(height: 20),

          Text(
            '${produkte.length} Ergebnisse',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          for (final produkt in produkte) _produktKarte(context, produkt),
        ],
      ),
    );
  }

  Widget _produktKarte(BuildContext context, Produkt produkt) {
    final preis = produkt.preis.endsWith('€') ? produkt.preis : '${produkt.preis} €';
    final vermietung = istVermietung(produkt);

    String untertitel;

    if (produkt.kategorie == 'Auto & Motor') {
      untertitel = '${produkt.ort} • ${produkt.baujahr} • ${produkt.kilometer} km';
    } else if (produkt.kategorie == 'Immobilien') {
      untertitel = '${produkt.ort} • ${produkt.wohnflaeche} m² • ${produkt.zimmer} Zimmer';
    } else if (vermietung) {
      untertitel = '${produkt.ort} • Vermietung';
    } else {
      untertitel = '${produkt.ort} • ${produkt.typ}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: produkt.bild.isEmpty
              ? Container(
                  width: 80,
                  height: 80,
                  color: const Color(0xfff1edff),
                  child: const Icon(Icons.image_not_supported_outlined),
                )
              : Image.network(
                  produkt.bild,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: const Color(0xfff1edff),
                      child: const Icon(Icons.image_not_supported_outlined),
                    );
                  },
                ),
        ),
        title: Text(
          produkt.titel,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          untertitel,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          vermietung && produkt.mietpreisTag.trim().isNotEmpty
              ? '${produkt.mietpreisTag} €/Tag'
              : preis,
          style: const TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailSeite(produkt: produkt),
            ),
          );
        },
      ),
    );
  }
}
