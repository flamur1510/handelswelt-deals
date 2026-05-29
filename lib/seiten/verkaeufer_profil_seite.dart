import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerkaeuferProfilSeite extends StatelessWidget {
  final String verkaeuferId;
  final String verkaeuferEmail;
  final String typ;

  const VerkaeuferProfilSeite({
    super.key,
    required this.verkaeuferId,
    required this.verkaeuferEmail,
    required this.typ,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f3ff),
      appBar: AppBar(
        title: const Text("Verkäuferprofil"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.deepPurple.withOpacity(0.12),
            child: Icon(
              typ == "Firma" ? Icons.business : Icons.person,
              size: 65,
              color: Colors.deepPurple,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            verkaeuferEmail,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Chip(
              backgroundColor: typ == "Firma" ? Colors.orange : Colors.green,
              label: Text(
                typ == "Firma" ? "Firmenkonto" : "Privatkonto",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 30),

          if (typ == "Firma")
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("bewertungen")
                  .where("verkaeuferId", isEqualTo: verkaeuferId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                double summe = 0;

                for (final doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  summe += (data["sterne"] ?? 0).toDouble();
                }

                final durchschnitt =
                    docs.isEmpty ? 0 : summe / docs.length;

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        const Text(
                          "Bewertung",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 28,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "${durchschnitt.toStringAsFixed(1)} / 5",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text("${docs.length} Bewertungen"),
                      ],
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 25),

          const Text(
            "Alle Inserate",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("inserate")
                .where("verkaeuferId", isEqualTo: verkaeuferId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final inserate = snapshot.data!.docs;

              if (inserate.isEmpty) {
                return const Text("Keine Inserate vorhanden.");
              }

              return Column(
                children: [
                  for (final inserat in inserate)
                    Builder(
                      builder: (context) {
                        final data = inserat.data() as Map<String, dynamic>;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                data["bild"] ?? "",
                                width: 65,
                                height: 65,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              data["titel"] ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(data["ort"] ?? ""),
                            trailing: Text(
                              data["preis"] ?? "",
                              style: const TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}