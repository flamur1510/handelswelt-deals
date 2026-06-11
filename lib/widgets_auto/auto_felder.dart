import 'package:flutter/material.dart';
import '../auto_daten/auto_daten.dart';
import '../widgets/einheit_feld.dart';
import '../widgets/inserat_form_widgets.dart';

class AutoFelder extends StatelessWidget {
  final String typ;

  final TextEditingController baujahrController;
  final TextEditingController kilometerController;
  final TextEditingController leistungController;
  final TextEditingController erstzulassungController;
  final TextEditingController vorbesitzerController;
  final TextEditingController tuevController;
  final TextEditingController hubraumController;
  final TextEditingController verbrauchController;
  final TextEditingController co2Controller;
  final TextEditingController schluesselController;
  final TextEditingController garantieController;

  final String marke;
  final String modell;
  final String kraftstoff;
  final String getriebe;
  final String zustand;
  final String farbe;
  final String karosserie;
  final String antrieb;
  final String unfallfrei;
  final String tueren;
  final String sitze;
  final String serviceheft;
  final String nichtraucher;
  final String mwst;
  final String pickerlNeu;
  final String leasing;
  final String finanzierung;
  final String inzahlungnahme;

  final List<String> kraftstoffe;
  final List<String> getriebeArten;
  final List<String> zustaende;
  final List<String> farben;
  final List<String> karosserien;
  final List<String> antriebe;
  final List<String> jaNein;
  final List<String> tuerenListe;
  final List<String> sitzeListe;

  final Function(String) onMarke;
  final Function(String) onModell;
  final Function(String) onKraftstoff;
  final Function(String) onGetriebe;
  final Function(String) onZustand;
  final Function(String) onFarbe;
  final Function(String) onKarosserie;
  final Function(String) onAntrieb;
  final Function(String) onUnfallfrei;
  final Function(String) onTueren;
  final Function(String) onSitze;
  final Function(String) onServiceheft;
  final Function(String) onNichtraucher;
  final Function(String) onMwst;
  final Function(String) onPickerlNeu;
  final Function(String) onLeasing;
  final Function(String) onFinanzierung;
  final Function(String) onInzahlungnahme;

  const AutoFelder({
    super.key,
    required this.typ,
    required this.baujahrController,
    required this.kilometerController,
    required this.leistungController,
    required this.erstzulassungController,
    required this.vorbesitzerController,
    required this.tuevController,
    required this.hubraumController,
    required this.verbrauchController,
    required this.co2Controller,
    required this.schluesselController,
    required this.garantieController,
    required this.marke,
    required this.modell,
    required this.kraftstoff,
    required this.getriebe,
    required this.zustand,
    required this.farbe,
    required this.karosserie,
    required this.antrieb,
    required this.unfallfrei,
    required this.tueren,
    required this.sitze,
    required this.serviceheft,
    required this.nichtraucher,
    required this.mwst,
    required this.pickerlNeu,
    required this.leasing,
    required this.finanzierung,
    required this.inzahlungnahme,
    required this.kraftstoffe,
    required this.getriebeArten,
    required this.zustaende,
    required this.farben,
    required this.karosserien,
    required this.antriebe,
    required this.jaNein,
    required this.tuerenListe,
    required this.sitzeListe,
    required this.onMarke,
    required this.onModell,
    required this.onKraftstoff,
    required this.onGetriebe,
    required this.onZustand,
    required this.onFarbe,
    required this.onKarosserie,
    required this.onAntrieb,
    required this.onUnfallfrei,
    required this.onTueren,
    required this.onSitze,
    required this.onServiceheft,
    required this.onNichtraucher,
    required this.onMwst,
    required this.onPickerlNeu,
    required this.onLeasing,
    required this.onFinanzierung,
    required this.onInzahlungnahme,
  });

  @override
  Widget build(BuildContext context) {
    final modelle = autoModelle[marke] ?? ["Andere"];

    return InseratKarte(
      titel: "Fahrzeugdaten",
      child: Column(
        children: [
          InseratDropdown(
            label: "Marke",
            value: marke,
            items: autoMarken,
            onChanged: (value) {
              if (value != null) onMarke(value);
            },
          ),
          InseratDropdown(
            label: "Modell",
            value: modelle.contains(modell) ? modell : modelle.first,
            items: modelle,
            onChanged: (value) {
              if (value != null) onModell(value);
            },
          ),
          EinheitFeld(
            controller: baujahrController,
            label: "Baujahr",
            einheit: "",
          ),
          InseratFeld(
            controller: erstzulassungController,
            label: "Erstzulassung",
          ),
          EinheitFeld(
            controller: kilometerController,
            label: "Kilometerstand",
            einheit: "km",
          ),
          InseratDropdown(
            label: "Kraftstoff",
            value: kraftstoff,
            items: kraftstoffe,
            onChanged: (value) {
              if (value != null) onKraftstoff(value);
            },
          ),
          InseratDropdown(
            label: "Getriebe",
            value: getriebe,
            items: getriebeArten,
            onChanged: (value) {
              if (value != null) onGetriebe(value);
            },
          ),
          EinheitFeld(
            controller: leistungController,
            label: "Leistung",
            einheit: "PS",
          ),
          EinheitFeld(
            controller: hubraumController,
            label: "Hubraum",
            einheit: "cm³",
          ),
          EinheitFeld(
            controller: verbrauchController,
            label: "Verbrauch",
            einheit: "l/100km",
          ),
          EinheitFeld(
            controller: co2Controller,
            label: "CO₂",
            einheit: "g/km",
          ),
          EinheitFeld(
            controller: schluesselController,
            label: "Anzahl Schlüssel",
            einheit: "",
          ),
          InseratDropdown(
            label: "Farbe",
            value: farbe,
            items: farben,
            onChanged: (value) {
              if (value != null) onFarbe(value);
            },
          ),
          InseratDropdown(
            label: "Karosserie",
            value: karosserie,
            items: karosserien,
            onChanged: (value) {
              if (value != null) onKarosserie(value);
            },
          ),
          InseratDropdown(
            label: "Antrieb",
            value: antrieb,
            items: antriebe,
            onChanged: (value) {
              if (value != null) onAntrieb(value);
            },
          ),
          EinheitFeld(
            controller: vorbesitzerController,
            label: "Vorbesitzer",
            einheit: "",
          ),
          InseratFeld(
            controller: tuevController,
            label: "Pickerl / TÜV bis",
          ),
          InseratDropdown(
            label: "Pickerl neu",
            value: pickerlNeu,
            items: jaNein,
            onChanged: (value) {
              if (value != null) onPickerlNeu(value);
            },
          ),
          InseratDropdown(
            label: "Unfallfrei",
            value: unfallfrei,
            items: jaNein,
            onChanged: (value) {
              if (value != null) onUnfallfrei(value);
            },
          ),
          InseratDropdown(
            label: "Türen",
            value: tueren,
            items: tuerenListe,
            onChanged: (value) {
              if (value != null) onTueren(value);
            },
          ),
          InseratDropdown(
            label: "Sitze",
            value: sitze,
            items: sitzeListe,
            onChanged: (value) {
              if (value != null) onSitze(value);
            },
          ),
          InseratDropdown(
            label: "Serviceheft gepflegt",
            value: serviceheft,
            items: jaNein,
            onChanged: (value) {
              if (value != null) onServiceheft(value);
            },
          ),
          InseratDropdown(
            label: "Nichtraucherfahrzeug",
            value: nichtraucher,
            items: jaNein,
            onChanged: (value) {
              if (value != null) onNichtraucher(value);
            },
          ),
          InseratDropdown(
            label: "MwSt. ausweisbar",
            value: mwst,
            items: jaNein,
            onChanged: (value) {
              if (value != null) onMwst(value);
            },
          ),
          if (typ == "Firma") ...[
            InseratDropdown(
              label: "Leasing möglich",
              value: leasing,
              items: jaNein,
              onChanged: (value) {
                if (value != null) onLeasing(value);
              },
            ),
            InseratDropdown(
              label: "Finanzierung möglich",
              value: finanzierung,
              items: jaNein,
              onChanged: (value) {
                if (value != null) onFinanzierung(value);
              },
            ),
            InseratDropdown(
              label: "Inzahlungnahme möglich",
              value: inzahlungnahme,
              items: jaNein,
              onChanged: (value) {
                if (value != null) onInzahlungnahme(value);
              },
            ),
          ],
          InseratDropdown(
            label: "Zustand",
            value: zustand,
            items: zustaende,
            onChanged: (value) {
              if (value != null) onZustand(value);
            },
          ),
          InseratFeld(
            controller: garantieController,
            label: "Garantie",
          ),
        ],
      ),
    );
  }
}