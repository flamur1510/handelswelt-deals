/// ─────────────────────────────────────────────────────────
/// HERO BANNER & VERTRAUENSLEISTE
///
/// HeroBannerKlein  — kompakter Banner in der Startseite
/// HeroBanner       — großer Landing-Banner (aktuell ungenutzt)
/// Vertrauensleiste — 4-Kachel-Vertrauens-Grid
///
/// Alle Widgets sind vollständig stateless und brauchen nur
/// [zuInserat] als Callback für den „Jetzt inserieren"-Button.
/// ─────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

// ── HeroBannerKlein ──────────────────────────────────────────────

/// Kompakter Gradient-Banner mit „Jetzt inserieren"-Button.
class HeroBannerKlein extends StatelessWidget {
  final VoidCallback zuInserat;

  const HeroBannerKlein({super.key, required this.zuInserat});

  @override
  Widget build(BuildContext context) {
    final breit = MediaQuery.sizeOf(context).width > 900;

    return Padding(
      padding: EdgeInsets.fromLTRB(breit ? 46 : 16, 14, breit ? 46 : 16, 0),
      child: Container(
        height: breit ? 112 : 124,
        padding: EdgeInsets.symmetric(
          horizontal: breit ? 24 : 18,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xffffffff),
              Color(0xff11184f),
              Color(0xff5b2cff),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x245b2cff),
              blurRadius: 22,
              offset: Offset(0, 9),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -18,
              top: -28,
              child: Icon(
                Icons.language,
                color: Colors.white.withOpacity(0.08),
                size: breit ? 138 : 118,
              ),
            ),
            Row(
              children: [
                Container(
                  width: breit ? 58 : 50,
                  height: breit ? 58 : 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.18),
                    ),
                  ),
                  child: const Icon(
                    Icons.local_offer_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Entdecke echte Top-Deals",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: breit ? 24 : 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        "Handeln, mieten und inserieren – schnell, lokal und übersichtlich.",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: breit ? 14 : 12,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                if (breit) ...[
                  const SizedBox(width: 14),
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: zuInserat,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_circle_outline,
                              color: Color(0xff5b2cff), size: 19),
                          SizedBox(width: 8),
                          Text(
                            "Jetzt inserieren",
                            style: TextStyle(
                              color: Color(0xff5b2cff),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 10),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: zuInserat,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xff5b2cff),
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── HeroBanner (groß) ─────────────────────────────────────────────

/// Großer Landing-Banner mit Statistik-Chips.
class HeroBanner extends StatelessWidget {
  final VoidCallback zuInserat;

  const HeroBanner({super.key, required this.zuInserat});

  @override
  Widget build(BuildContext context) {
    final breit = MediaQuery.sizeOf(context).width > 900;

    return Padding(
      padding: EdgeInsets.fromLTRB(breit ? 46 : 16, 22, breit ? 46 : 16, 0),
      child: Container(
        padding: EdgeInsets.all(breit ? 24 : 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xffffffff),
              Color(0xff11184f),
              Color(0xff5b2cff),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x225b2cff),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: breit
            ? Row(
                children: [
                  Expanded(child: _HeroText(breit: breit)),
                  const SizedBox(width: 22),
                  _HeroButton(zuInserat: zuInserat),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroText(breit: breit),
                  const SizedBox(height: 18),
                  _HeroButton(zuInserat: zuInserat),
                ],
              ),
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  final bool breit;
  const _HeroText({required this.breit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.13),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            "Handelswelt Deals",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          "Österreichs Marktplatz\nfür echte Top-Deals.",
          style: TextStyle(
            color: Colors.white,
            fontSize: breit ? 26 : 22,
            fontWeight: FontWeight.w900,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Autos, Immobilien, Jobs, Dienstleistungen, Boote, Baumaschinen und vieles mehr.",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _HeroButton extends StatelessWidget {
  final VoidCallback zuInserat;
  const _HeroButton({required this.zuInserat});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: zuInserat,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_outline, color: Color(0xff5b2cff)),
            SizedBox(width: 8),
            Text(
              "Jetzt inserieren",
              style: TextStyle(
                color: Color(0xff5b2cff),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Vertrauensleiste ─────────────────────────────────────────────

/// 4-Kachel Grid mit Vertrauensargumenten.
class Vertrauensleiste extends StatelessWidget {
  const Vertrauensleiste({super.key});

  static const _vorteile = [
    (
      icon: Icons.verified_user_outlined,
      titel: "Sicher handeln",
      text: "Klare Inserate & direkte Kontaktaufnahme",
    ),
    (
      icon: Icons.euro_outlined,
      titel: "Kostenlos starten",
      text: "Inserate einfach veröffentlichen",
    ),
    (
      icon: Icons.rocket_launch_outlined,
      titel: "Schnell verkaufen",
      text: "Dein Deal ist sofort sichtbar",
    ),
    (
      icon: Icons.phone_iphone_outlined,
      titel: "Mobile optimiert",
      text: "Perfekt für Handy, Tablet und Web",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final breit = MediaQuery.sizeOf(context).width > 900;

    return Padding(
      padding: EdgeInsets.fromLTRB(breit ? 46 : 16, 18, breit ? 46 : 16, 0),
      child: GridView.count(
        crossAxisCount: breit ? 4 : 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: breit ? 3.05 : 1.55,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: _vorteile
            .map(
              (item) => Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xff2a2a4a)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0f000000),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xff1a1035),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item.icon,
                        color: const Color(0xff5b2cff),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.titel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xffffffff),
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xff9094a8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              height: 1.22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── HeroStatistikKarte ────────────────────────────────────────────

/// Kleines Statistik-Kästchen für den Hero-Banner.
class HeroStatistikKarte extends StatelessWidget {
  final String zahl;
  final String text;

  const HeroStatistikKarte({
    super.key,
    required this.zahl,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          Text(
            zahl,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
