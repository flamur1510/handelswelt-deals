import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BewertungenListeSeite extends StatelessWidget {
  final String verkaeuferId;
  final String verkaeuferEmail;

  const BewertungenListeSeite({
    super.key,
    required this.verkaeuferId,
    required this.verkaeuferEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f3ff),
      appBar: AppBar(
        title: const Text("Bewertungen"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("bewertungen")
            .where("verkaeuferId", isEqualTo: verkaeuferId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bewertungen = snapshot.data!.docs;

          if (bewertungen.isEmpty) {
            return const Center(
              child: Text(
                "Noch keine Bewertungen vorhanden.",
                style: TextStyle(fontSize: 20),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                verkaeuferEmail,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              for (final bewertung in bewertungen)
                Builder(
                  builder: (context) {
                    final data = bewertung.data() as Map<String, dynamic>;

                    final sterne = data["sterne"] ?? 0;
                    final kommentar = data["kommentar"] ?? "";
                    final bewerterEmail = data["bewerterEmail"] ?? "Unbekannt";

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                for (int i = 1; i <= 5; i++)
                                  Icon(
                                    i <= sterne
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                  ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Text(
                              kommentar.toString().isEmpty
                                  ? "Keine Beschreibung"
                                  : kommentar,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              "Von: $bewerterEmail",
                              style: const TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}