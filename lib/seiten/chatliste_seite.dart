import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_seite.dart';

class ChatlisteSeite extends StatelessWidget {
  const ChatlisteSeite({super.key});

  String zeitText(dynamic zeit) {
    if (zeit == null) return "";

    final datum = (zeit as Timestamp).toDate();
    final stunde = datum.hour.toString().padLeft(2, "0");
    final minute = datum.minute.toString().padLeft(2, "0");

    return "$stunde:$minute";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Meine Chats")),
        body: const Center(
          child: Text("Bitte zuerst einloggen."),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xfff6f3ff),
      appBar: AppBar(
        title: const Text("Meine Chats"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("chats")
            .orderBy("aktualisiertAm", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return data["kaeuferId"] == user.uid ||
                data["verkaeuferId"] == user.uid;
          }).toList();

          if (chats.isEmpty) {
            return const Center(
              child: Text(
                "Noch keine Chats vorhanden.",
                style: TextStyle(fontSize: 20),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              for (final chat in chats)
                Builder(
                  builder: (context) {
                    final data = chat.data() as Map<String, dynamic>;

                    final istVerkaeufer = data["verkaeuferId"] == user.uid;

                    final andereEmail = istVerkaeufer
                        ? data["kaeuferEmail"] ?? "Unbekannt"
                        : data["verkaeuferEmail"] ?? "Unbekannt";

                    final ungelesen = istVerkaeufer
                        ? data["ungelesenVerkaeufer"] ?? 0
                        : data["ungelesenKaeufer"] ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.deepPurple.withOpacity(0.12),
                          child: const Icon(
                            Icons.chat,
                            color: Colors.deepPurple,
                          ),
                        ),
                        title: Text(
                          data["produktTitel"] ?? "Chat",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(andereEmail),
                            const SizedBox(height: 4),
                            Text(
                              data["letzteNachricht"] ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              zeitText(data["aktualisiertAm"]),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (ungelesen > 0)
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.deepPurple,
                                child: Text(
                                  "$ungelesen",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
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
                        },
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