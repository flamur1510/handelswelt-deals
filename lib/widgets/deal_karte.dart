import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../model/produkt.dart';
import '../seiten/detail_seite.dart';
import '../constants/app_konstanten.dart';

// ── Hilfsfunktionen ───────────────────────────────────────────────

String mitEinheit(String wert, String einheit) {
  final s = wert.trim();
  return s.isEmpty ? "" : "$s $einheit";
}

String infoZeile1(Produkt p) {
  if (p.kategorie == "Auto & Motor") {
    return [p.marke, p.modell, p.unterkategorie]
        .where((e) => e.trim().isNotEmpty).join(" • ");
  }
  if (p.kategorie == "Immobilien") {
    return [
      p.immobilienArt.isEmpty ? "Immobilie" : p.immobilienArt,
      mitEinheit(p.wohnflaeche, "m²"),
      p.zimmer.isEmpty ? "" : "${p.zimmer} Zi.",
    ].where((e) => e.trim().isNotEmpty).join(" • ");
  }
  if (p.kategorie == "Jobs") {
    return [p.jobBerufsbezeichnung, p.unterkategorie]
        .where((e) => e.trim().isNotEmpty).join(" • ");
  }
  if (p.kategorie == "Dienstleistungen") {
    return [p.unterkategorie, p.detailUnterkategorie, p.dienstleistungEinsatzgebiet]
        .where((e) => e.trim().isNotEmpty).join(" • ");
  }
  if (p.kategorie == "Boote") {
    return [
      p.bootstyp.isNotEmpty ? p.bootstyp : p.detailUnterkategorie,
      p.bootMarke, p.bootModell,
    ].where((e) => e.trim().isNotEmpty).join(" • ");
  }
  if (p.kategorie == "Baumaschinen") {
    return [p.unterkategorie, p.baumaschinenBaujahr]
        .where((e) => e.trim().isNotEmpty).join(" • ");
  }
  return [p.unterkategorie, p.detailUnterkategorie, p.zustand]
      .where((e) => e.trim().isNotEmpty).join(" • ");
}

String infoZeile2(Produkt p) {
  if (p.kategorie == "Auto & Motor") {
    return [
      p.baujahr, mitEinheit(p.kilometer, "km"),
      p.kraftstoff, p.getriebe, mitEinheit(p.leistung, "PS"),
    ].where((e) => e.trim().isNotEmpty).join(" • ");
  }
  if (p.kategorie == "Immobilien") {
    return [
      p.balkon == "Ja" ? "Balkon" : "",
      p.garage == "Ja" ? "Garage" : "",
      p.lift == "Ja" ? "Lift" : "",
      p.betriebskosten.isEmpty ? "" : "BK: ${p.betriebskosten}",
    ].where((e) => e.trim().isNotEmpty).join(" • ");
  }
  if (p.kategorie == "Jobs") {
    return [
      p.jobGehalt, p.jobArbeitsort,
      p.jobHomeoffice == "Vollständig möglich" ? "100% Homeoffice"
          : p.jobHomeoffice == "Teilweise möglich" ? "Homeoffice möglich" : "",
    ].where((e) => e.trim().isNotEmpty).join(" • ");
  }
  if (p.kategorie == "Dienstleistungen") {
    return [
      p.dienstleistungPreisProStunde.isEmpty ? "" : "${p.dienstleistungPreisProStunde}/Std.",
      p.dienstleistungNotdienst == "Ja" ? "Notdienst" : "",
      p.dienstleistungAnfahrt == "Ja" ? "Kommt zu dir" : "",
    ].where((e) => e.trim().isNotEmpty).join(" • ");
  }
  if (p.kategorie == "Boote") {
    return [p.bootBaujahr, mitEinheit(p.bootLaenge, "m"), mitEinheit(p.bootLeistung, "PS")]
        .where((e) => e.trim().isNotEmpty).join(" • ");
  }
  if (p.kategorie == "Baumaschinen") {
    return [
      mitEinheit(p.baumaschinenBetriebsstunden, "h"),
      mitEinheit(p.baumaschinenGewicht, "kg"),
      p.baumaschinenKraftstoff,
    ].where((e) => e.trim().isNotEmpty).join(" • ");
  }
  if (p.kategorie == "Baumarkt") {
    return [p.baumarktMaterial, p.baumarktMenge, p.baumarktHersteller]
        .where((e) => e.trim().isNotEmpty).join(" • ");
  }
  return [
    p.hersteller,
    p.garantie.isEmpty ? "" : "Garantie: ${p.garantie}",
    p.zustand,
  ].where((e) => e.trim().isNotEmpty).join(" • ");
}

String anzeigenId(Produkt p) {
  final nr = p.titel.hashCode.abs().toString().padLeft(6, "0");
  return "HW-${nr.substring(0, 6)}";
}

Widget _platzhalter(Produkt p) {
  return Container(
    color: const Color(0xfff1edff),
    child: Center(child: Icon(p.icon, color: const Color(0xff5b2cff), size: 44)),
  );
}

Widget miniChip(String text, Color bg, Color fg) {
  if (text.trim().isEmpty) return const SizedBox.shrink();
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(30)),
    child: Text(text, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w800)),
  );
}

Widget verkaeuferBadge(Produkt p) {
  final istFirma = p.typ == kTypFirma;
  final text = p.firmaVerifiziert ? "✅ Verifiziert"
      : istFirma ? "⏳ Firma" : "👤 Privat";
  final bg = p.firmaVerifiziert ? const Color(0xffffefe0)
      : istFirma ? const Color(0xfffff6df) : const Color(0xffe8f8ee);
  final fg = p.firmaVerifiziert ? Colors.orange
      : istFirma ? Colors.amber : Colors.green;
  return miniChip(text, bg, fg);
}

// ── DealKarte (horizontale Listenzeile) ──────────────────────────

class DealKarte extends StatelessWidget {
  final Produkt produkt;
  final bool breit;
  final void Function(Produkt) onFavoritWechseln;

  const DealKarte({
    super.key,
    required this.produkt,
    required this.breit,
    required this.onFavoritWechseln,
  });

  @override
  Widget build(BuildContext context) {
    final preisText = produkt.preis.endsWith("€") ? produkt.preis : "${produkt.preis} €";
    final info1 = infoZeile1(produkt);
    final info2 = infoZeile2(produkt);
    final bildBreite = breit ? 210.0 : 130.0;
    final bildHoehe = breit ? 160.0 : 130.0;

    return InkWell(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => DetailSeite(produkt: produkt))),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xffececf4)),
          boxShadow: const [BoxShadow(blurRadius: 14, color: Color(0x10000000), offset: Offset(0, 5))],
        ),
        child: Row(
          children: [
            // ── Sauberes Foto ────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              child: SizedBox(
                width: bildBreite,
                height: bildHoehe,
                child: produkt.bild.isEmpty
                    ? _platzhalter(produkt)
                    : CachedNetworkImage(
                        imageUrl: produkt.bild,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _platzhalter(produkt),
                      ),
              ),
            ),
            // ── Daten rechts ─────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategorie-Chip
                    miniChip(
                      produkt.unterkategorie.isNotEmpty
                          ? produkt.unterkategorie
                          : produkt.kategorie,
                      const Color(0xfff1edff),
                      const Color(0xff5b2cff),
                    ),
                    const SizedBox(height: 6),
                    // Titel
                    Text(
                      produkt.titel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xff050b2c),
                        fontSize: breit ? 17 : 15,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Preis
                    Text(
                      preisText,
                      style: TextStyle(
                        color: const Color(0xff5b2cff),
                        fontSize: breit ? 20 : 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (info1.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(info1, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Color(0xff050b2c), fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                    if (info2.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(info2, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Color(0xff74788d), fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                    if (produkt.beschreibung.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(produkt.beschreibung, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Color(0xff74788d), fontSize: 12, height: 1.35)),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: Color(0xff9094a8)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            produkt.ort.isEmpty ? "Österreich" : produkt.ort,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Color(0xff9094a8), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // ── Favorit ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: produkt.favorit ? const Color(0xffffedf1) : const Color(0xfff7f7fb),
                ),
                onPressed: () => onFavoritWechseln(produkt),
                icon: Icon(
                  produkt.favorit ? Icons.favorite : Icons.favorite_border,
                  color: produkt.favorit ? Colors.red : const Color(0xff9094a8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── DealSwipeKarte (vertikale Karte in horizontaler Liste) ────────

class DealSwipeKarte extends StatelessWidget {
  final Produkt produkt;
  final bool breit;
  final void Function(Produkt) onFavoritWechseln;
  final String entfernungText;

  const DealSwipeKarte({
    super.key,
    required this.produkt,
    required this.breit,
    required this.onFavoritWechseln,
    this.entfernungText = "",
  });

  @override
  Widget build(BuildContext context) {
    final preisText = produkt.preis.endsWith("€") ? produkt.preis : "${produkt.preis} €";
    final info1 = infoZeile1(produkt);
    final info2 = infoZeile2(produkt);
    final karteBreite = breit ? 260.0 : 210.0;
    final bildHoehe = breit ? 160.0 : 130.0;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => DetailSeite(produkt: produkt))),
      child: Container(
        width: karteBreite,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xffececf4)),
          boxShadow: const [BoxShadow(blurRadius: 14, color: Color(0x10000000), offset: Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Sauberes Foto ─────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: SizedBox(
                    width: double.infinity,
                    height: bildHoehe,
                    child: produkt.bild.isEmpty
                        ? _platzhalter(produkt)
                        : CachedNetworkImage(
                            imageUrl: produkt.bild,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _platzhalter(produkt),
                          ),
                  ),
                ),
                // Nur Favorit-Button oben rechts — kein Text auf dem Foto
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => onFavoritWechseln(produkt),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        shape: BoxShape.circle,
                        boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 6)],
                      ),
                      child: Icon(
                        produkt.favorit ? Icons.favorite : Icons.favorite_border,
                        color: produkt.favorit ? Colors.red : const Color(0xff9094a8),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // ── Daten darunter ────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategorie
                    miniChip(
                      produkt.unterkategorie.isNotEmpty
                          ? produkt.unterkategorie
                          : produkt.kategorie,
                      const Color(0xfff1edff),
                      const Color(0xff5b2cff),
                    ),
                    const SizedBox(height: 6),
                    // Titel
                    Text(
                      produkt.titel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xff050b2c),
                        fontSize: breit ? 15 : 14,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Preis
                    Text(
                      preisText,
                      style: TextStyle(
                        color: const Color(0xff5b2cff),
                        fontSize: breit ? 17 : 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (info1.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(info1, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Color(0xff050b2c), fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                    if (info2.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(info2, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Color(0xff74788d), fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                    const Spacer(),
                    // Ort
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: Color(0xff9094a8)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            "${produkt.ort.isEmpty ? "Österreich" : produkt.ort}$entfernungText",
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Color(0xff9094a8), fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Badges
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        verkaeuferBadge(produkt),
                        miniChip(anzeigenId(produkt), const Color(0xfff4f4f8), const Color(0xff9094a8)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
