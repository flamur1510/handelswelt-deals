import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BewertungenSeite extends StatelessWidget {
  final String verkaeuferId;

  const BewertungenSeite({
    super.key,
    required this.verkaeuferId,
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
            .orderBy("erstelltAm", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Fehler beim Laden der Bewertungen."),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "Noch keine Bewertungen vorhanden.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          double durchschnitt = 0;

          for (final doc in docs) {
            durchschnitt +=
                ((doc.data() as Map<String, dynamic>)["sterne"] ?? 0)
                    .toDouble();
          }

          durchschnitt = durchschnitt / docs.length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      durchschnitt.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${docs.length} Bewertungen",
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              ...docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;

                final sterne = data["sterne"] ?? 0;
                final kommentar = data["kommentar"] ?? "";
                final bewerter =
                    data["bewerterEmail"] ?? "Unbekannter Nutzer";

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bewerter,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < sterne
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                      ),

                      if (kommentar.toString().trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          kommentar,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
