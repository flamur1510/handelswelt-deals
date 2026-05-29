import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_seite.dart';

class BenachrichtigungenSeite extends StatelessWidget {
  const BenachrichtigungenSeite({super.key});

  String zeitText(dynamic zeit) {
    if (zeit == null) return "";

    final datum = (zeit as Timestamp).toDate();
    final tag = datum.day.toString().padLeft(2, "0");
    final monat = datum.month.toString().padLeft(2, "0");
    final stunde = datum.hour.toString().padLeft(2, "0");
    final minute = datum.minute.toString().padLeft(2, "0");

    return "$tag.$monat. $stunde:$minute";
  }

  Future<void> gelesen(String id) async {
    await FirebaseFirestore.instance
        .collection("benachrichtigungen")
        .doc(id)
        .update({
      "gelesen": true,
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xfff6f3ff),
        appBar: AppBar(
          title: const Text("News"),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            "Bitte zuerst einloggen.",
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xfff6f3ff),
      appBar: AppBar(
        title: const Text("News"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("benachrichtigungen")
            .where("userId", isEqualTo: user.uid)
            .orderBy("erstelltAm", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "News konnten nicht geladen werden.\nPrüfe Firebase Rules oder Index.",
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "Noch keine Nachrichten.",
                style: TextStyle(fontSize: 20),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final typ = data["typ"] ?? "system";
              final gelesenStatus = data["gelesen"] ?? false;

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                elevation: gelesenStatus ? 2 : 5,
                color: gelesenStatus ? Colors.white : Colors.deepPurple.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: CircleAvatar(
                    backgroundColor: typ == "chat"
                        ? Colors.deepPurple
                        : typ == "bewertung"
                            ? Colors.orange
                            : Colors.blue,
                    child: Icon(
                      typ == "chat"
                          ? Icons.chat
                          : typ == "bewertung"
                              ? Icons.star
                              : Icons.notifications,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    data["titel"] ?? "Benachrichtigung",
                    style: TextStyle(
                      fontWeight: gelesenStatus
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(data["text"] ?? ""),
                      const SizedBox(height: 6),
                      Text(
                        zeitText(data["erstelltAm"]),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: gelesenStatus
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.circle, color: Colors.deepPurple, size: 14),
                  onTap: () async {
                    await gelesen(doc.id);

                    if (typ == "chat") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatSeite(
                            verkaeuferId: data["verkaeuferId"] ?? "",
                            verkaeuferEmail: data["verkaeuferEmail"] ?? "",
                            produktId: data["produktId"] ?? "",
                            produktTitel: data["produktTitel"] ?? "Chat",
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}