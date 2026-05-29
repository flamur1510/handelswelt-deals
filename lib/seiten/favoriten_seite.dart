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
    return Scaffold(
      backgroundColor: const Color(0xfff6f3ff),
      appBar: AppBar(
        title: const Text("Favoriten"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: favoriten.isEmpty
          ? const Center(
              child: Text(
                "Noch keine Favoriten gespeichert.",
                style: TextStyle(fontSize: 20),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                for (final produkt in favoriten)
                  Card(
                    margin: const EdgeInsets.only(bottom: 18),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(14),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          produkt.bild,
                          width: 75,
                          height: 75,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        produkt.titel,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "${produkt.ort} • ${produkt.kategorie}",
                      ),
                      trailing: Text(
                        produkt.preis,
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                    ),
                  ),
              ],
            ),
    );
  }
}