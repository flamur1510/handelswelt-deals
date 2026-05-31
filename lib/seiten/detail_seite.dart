import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../model/produkt.dart';
import 'chat_seite.dart';

class DetailSeite extends StatefulWidget {
  final Produkt produkt;

  const DetailSeite({
    super.key,
    required this.produkt,
  });

  @override
  State<DetailSeite> createState() => _DetailSeiteState();
}

class _DetailSeiteState extends State<DetailSeite> {
  int aktuellesBild = 0;

  @override
  Widget build(BuildContext context) {
    final bilder = widget.produkt.bilder.isNotEmpty
        ? widget.produkt.bilder
        : [widget.produkt.bild];

    final preisText = widget.produkt.preis.endsWith("€")
        ? widget.produkt.preis
        : "${widget.produkt.preis} €";

    final breit = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            breit ? 46 : 16,
            16,
            breit ? 46 : 16,
            24,
          ),
          children: [
            _kopfzeile(context),
            const SizedBox(height: 16),
            if (breit)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: _bilderGalerie(bilder)),
                  const SizedBox(width: 18),
                  Expanded(flex: 4, child: _seitenInfo(preisText)),
                ],
              )
            else ...[
              _bilderGalerie(bilder),
              const SizedBox(height: 16),
              _seitenInfo(preisText),
            ],
            const SizedBox(height: 18),
            _details(),
            const SizedBox(height: 18),
            _beschreibung(),
            const SizedBox(height: 18),
            _standort(),
          ],
        ),
      ),
    );
  }

  Widget _kopfzeile(BuildContext context) {
    return Row(
      children: [
        IconButton(
          style: IconButton.styleFrom(backgroundColor: Colors.white),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xff050b2c)),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            "Inserat Details",
            style: TextStyle(
              color: Color(0xff050b2c),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _bilderGalerie(List<String> bilder) {
    return Container(
      height: 390,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffececf4)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: bilder.length,
            onPageChanged: (index) {
              setState(() {
                aktuellesBild = index;
              });
            },
            itemBuilder: (context, index) {
              final bild = bilder[index];

              if (bild.isEmpty) {
                return _platzhalterBild();
              }

              return Image.network(
                bild,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return _platzhalterBild();
                },
              );
            },
          ),
          Positioned(
            left: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${aktuellesBild + 1}/${bilder.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _platzhalterBild() {
    return Container(
      color: const Color(0xfff1edff),
      child: Icon(
        widget.produkt.icon,
        color: const Color(0xff5b2cff),
        size: 80,
      ),
    );
  }

  Widget _seitenInfo(String preisText) {
    return Column(
      children: [
        _karte(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.produkt.titel,
                style: const TextStyle(
                  color: Color(0xff050b2c),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                preisText,
                style: const TextStyle(
                  color: Color(0xff5b2cff),
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(
                    widget.produkt.kategorie,
                    const Color(0xfff1edff),
                    const Color(0xff5b2cff),
                  ),
                  _chip(
                    widget.produkt.typ,
                    widget.produkt.typ == "Firma"
                        ? const Color(0xffffefe0)
                        : const Color(0xffe8f8ee),
                    widget.produkt.typ == "Firma"
                        ? Colors.orange
                        : Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xff74788d),
                    size: 19,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      widget.produkt.ort,
                      style: const TextStyle(
                        color: Color(0xff74788d),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _verkaeuferKarte(),
        const SizedBox(height: 14),
        _kontaktButtons(),
      ],
    );
  }

  Widget _verkaeuferKarte() {
    final name = widget.produkt.typ == "Firma"
        ? (widget.produkt.firmenname.isEmpty
            ? "Firma"
            : widget.produkt.firmenname)
        : "Privatverkäufer";

    return _karte(
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xfff1edff),
            child: Icon(
              widget.produkt.typ == "Firma" ? Icons.business : Icons.person,
              color: const Color(0xff5b2cff),
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff050b2c),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.produkt.emailSichtbar || widget.produkt.typ == "Firma"
                      ? widget.produkt.verkaeuferEmail
                      : "Kontakt über Handelswelt Chat",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff74788d),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kontaktButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff5b2cff),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatSeite(
                    verkaeuferId: widget.produkt.verkaeuferId,
                    verkaeuferEmail: widget.produkt.verkaeuferEmail,
                    produktId: widget.produkt.id,
                    produktTitel: widget.produkt.titel,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
            ),
            label: const Text(
              "Nachricht senden",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        if ((widget.produkt.telefonSichtbar ||
                widget.produkt.typ == "Firma") &&
            widget.produkt.telefon.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.phone_outlined),
              label: Text(widget.produkt.telefon),
            ),
          ),
        ],
      ],
    );
  }

  Widget _details() {
    return _karte(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Details",
            style: TextStyle(
              color: Color(0xff050b2c),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          if (widget.produkt.kategorie == "Autos") ...[
            _detailZeile("Marke", widget.produkt.marke),
            _detailZeile("Modell", widget.produkt.modell),
            _detailZeile("Baujahr", widget.produkt.baujahr),
            _detailZeile("Erstzulassung", widget.produkt.erstzulassung),
            _detailZeile("Kilometer", widget.produkt.kilometer),
            _detailZeile("Kraftstoff", widget.produkt.kraftstoff),
            _detailZeile("Getriebe", widget.produkt.getriebe),
            _detailZeile("Leistung", widget.produkt.leistung),
            _detailZeile("Hubraum", widget.produkt.hubraum),
            _detailZeile("Verbrauch", widget.produkt.verbrauch),
            _detailZeile("CO₂", widget.produkt.co2),
            _detailZeile("Schlüssel", widget.produkt.schluessel),
            _detailZeile("Farbe", widget.produkt.farbe),
            _detailZeile("Karosserie", widget.produkt.karosserie),
            _detailZeile("Antrieb", widget.produkt.antrieb),
            _detailZeile("Türen", widget.produkt.tueren),
            _detailZeile("Sitze", widget.produkt.sitze),
            _detailZeile("Pickerl/TÜV", widget.produkt.tuev),
            _detailZeile("Pickerl neu", widget.produkt.pickerlNeu),
            _detailZeile("Unfallfrei", widget.produkt.unfallfrei),
            _detailZeile("Serviceheft", widget.produkt.serviceheft),
            _detailZeile("Nichtraucher", widget.produkt.nichtraucher),
            _detailZeile("MwSt.", widget.produkt.mwstAusweisbar),
            _detailZeile("Leasing", widget.produkt.leasingMoeglich),
            _detailZeile("Finanzierung", widget.produkt.finanzierungMoeglich),
            _detailZeile(
              "Inzahlungnahme",
              widget.produkt.inzahlungnahmeMoeglich,
            ),
            _detailZeile("Zustand", widget.produkt.zustand),
            _detailZeile("Garantie", widget.produkt.garantie),
          ],
          if (widget.produkt.kategorie == "Immobilien") ...[
            _detailZeile("Immobilienart", widget.produkt.immobilienArt),
            _detailZeile("Wohnfläche", "${widget.produkt.wohnflaeche} m²"),
            _detailZeile("Zimmer", widget.produkt.zimmer),
            _detailZeile("Etage", widget.produkt.etage),
            _detailZeile("Kaution", widget.produkt.kaution),
            _detailZeile("Betriebskosten", widget.produkt.betriebskosten),
            _detailZeile("Balkon", widget.produkt.balkon),
            _detailZeile("Terrasse", widget.produkt.terrasse),
            _detailZeile("Garten", widget.produkt.garten),
            _detailZeile("Garage", widget.produkt.garage),
            _detailZeile("Lift", widget.produkt.lift),
            _detailZeile("Keller", widget.produkt.keller),
            _detailZeile("Möbliert", widget.produkt.moebliert),
            _detailZeile("Energieklasse", widget.produkt.energieklasse),
            _detailZeile("Heizung", widget.produkt.heizung),
            _detailZeile("Baujahr", widget.produkt.baujahrImmobilie),
            _detailZeile("Verfügbar ab", widget.produkt.verfuegbarAb),
            _detailZeile("Zustand", widget.produkt.zustand),
          ],
          if (widget.produkt.kategorie != "Autos" &&
              widget.produkt.kategorie != "Immobilien") ...[
            _detailZeile("Zustand", widget.produkt.zustand),
            _detailZeile("Hersteller", widget.produkt.hersteller),
            _detailZeile("Garantie", widget.produkt.garantie),
          ],
        ],
      ),
    );
  }

  Widget _beschreibung() {
    return _karte(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Beschreibung",
            style: TextStyle(
              color: Color(0xff050b2c),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.produkt.beschreibung.isEmpty
                ? "Keine Beschreibung vorhanden."
                : widget.produkt.beschreibung,
            style: const TextStyle(
              color: Color(0xff4d5368),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _standort() {
    return _karte(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Standort",
            style: TextStyle(
              color: Color(0xff050b2c),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 320,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  widget.produkt.latitude,
                  widget.produkt.longitude,
                ),
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: "com.handelswelt.app",
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        widget.produkt.latitude,
                        widget.produkt.longitude,
                      ),
                      width: 45,
                      height: 45,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 42,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailZeile(String titel, String wert) {
    if (wert.trim().isEmpty || wert.trim() == " m²") {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(
              titel,
              style: const TextStyle(
                color: Color(0xff74788d),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              wert,
              style: const TextStyle(
                color: Color(0xff050b2c),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _karte({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xffececf4),
        ),
      ),
      child: child,
    );
  }
}