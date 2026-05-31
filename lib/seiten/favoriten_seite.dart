import 'package:flutter/material.dart';

import '../model/produkt.dart';
import 'detail_seite.dart';

class FavoritenSeite extends StatelessWidget {
  final List<Produkt> favoriten;

  const FavoritenSeite({
    super.key,
    required this.favoriten,
  });

  @override
  Widget build(BuildContext context) {
    final breit = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            breit ? 46 : 16,
            18,
            breit ? 46 : 16,
            24,
          ),
          children: [
            _kopfzeile(),
            const SizedBox(height: 22),
            if (favoriten.isEmpty)
              _leer()
            else
              GridView.builder(
                itemCount: favoriten.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: breit ? 4 : 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: breit ? 0.92 : 0.72,
                ),
                itemBuilder: (context, index) {
                  return _favoritKarte(context, favoriten[index]);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _kopfzeile() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xffffedf1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.favorite,
            color: Colors.red,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Favoriten",
                style: TextStyle(
                  color: Color(0xff050b2c),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Deine gespeicherten Deals.",
                style: TextStyle(
                  color: Color(0xff74788d),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _favoritKarte(BuildContext context, Produkt produkt) {
    final preisText =
        produkt.preis.endsWith("€") ? produkt.preis : "${produkt.preis} €";

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailSeite(
              produkt: produkt,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xffececf4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: produkt.bild.isEmpty
                      ? _platzhalter(produkt)
                      : Image.network(
                          produkt.bild,
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _platzhalter(produkt);
                          },
                        ),
                ),
                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 19,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produkt.titel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xff050b2c),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    preisText,
                    style: const TextStyle(
                      color: Color(0xff5b2cff),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Color(0xff74788d),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          produkt.ort,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xff74788d),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _chip(produkt.kategorie),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _platzhalter(Produkt produkt) {
    return Container(
      height: 150,
      width: double.infinity,
      color: const Color(0xfff1edff),
      child: Icon(
        produkt.icon,
        color: const Color(0xff5b2cff),
        size: 42,
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xfff1edff),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xff5b2cff),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _leer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xffececf4),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.favorite_border,
            color: Colors.red,
            size: 52,
          ),
          SizedBox(height: 14),
          Text(
            "Noch keine Favoriten",
            style: TextStyle(
              color: Color(0xff050b2c),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Speichere Deals mit dem Herz-Symbol.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xff74788d),
            ),
          ),
        ],
      ),
    );
  }
}