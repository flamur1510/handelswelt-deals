import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatSeite extends StatefulWidget {
  final String verkaeuferId;
  final String verkaeuferEmail;
  final String produktId;
  final String produktTitel;

  const ChatSeite({
    super.key,
    required this.verkaeuferId,
    required this.verkaeuferEmail,
    required this.produktId,
    required this.produktTitel,
  });

  @override
  State<ChatSeite> createState() => _ChatSeiteState();
}

class _ChatSeiteState extends State<ChatSeite> {
  final nachrichtController = TextEditingController();

  String chatIdErstellen(String userId) {
    final ids = [userId, widget.verkaeuferId];
    ids.sort();
    return "${ids[0]}_${ids[1]}_${widget.produktId}";
  }

  String zeitText(dynamic zeit) {
    if (zeit == null) return "";

    final datum = (zeit as Timestamp).toDate();
    final stunde = datum.hour.toString().padLeft(2, "0");
    final minute = datum.minute.toString().padLeft(2, "0");

    return "$stunde:$minute";
  }

  Future<void> newsErstellen({
    required String empfaengerId,
    required String senderEmail,
    required String text,
  }) async {
    if (empfaengerId.isEmpty) return;

    await FirebaseFirestore.instance.collection("benachrichtigungen").add({
      "userId": empfaengerId,
      "typ": "chat",
      "titel": "Neue Nachricht",
      "text": "$senderEmail: $text",
      "produktId": widget.produktId,
      "produktTitel": widget.produktTitel,
      "verkaeuferId": widget.verkaeuferId,
      "verkaeuferEmail": widget.verkaeuferEmail,
      "gelesen": false,
      "erstelltAm": FieldValue.serverTimestamp(),
    });
  }

  Future<void> nachrichtSenden() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bitte zuerst einloggen.")),
      );
      return;
    }

    final text = nachrichtController.text.trim();

    if (text.isEmpty) return;

    final chatId = chatIdErstellen(user.uid);
    final chatRef = FirebaseFirestore.instance.collection("chats").doc(chatId);

    final istVerkaeufer = user.uid == widget.verkaeuferId;

    String kaeuferId = "";
    String kaeuferEmail = "";

    final chatDoc = await chatRef.get();

    if (chatDoc.exists) {
      final data = chatDoc.data() as Map<String, dynamic>;
      kaeuferId = data["kaeuferId"] ?? "";
      kaeuferEmail = data["kaeuferEmail"] ?? "";
    }

    if (!istVerkaeufer) {
      kaeuferId = user.uid;
      kaeuferEmail = user.email ?? "";
    }

    final empfaengerId = istVerkaeufer ? kaeuferId : widget.verkaeuferId;

    await chatRef.set({
      "produktId": widget.produktId,
      "produktTitel": widget.produktTitel,
      "kaeuferId": kaeuferId,
      "kaeuferEmail": kaeuferEmail,
      "verkaeuferId": widget.verkaeuferId,
      "verkaeuferEmail": widget.verkaeuferEmail,
      "letzteNachricht": text,
      "aktualisiertAm": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await chatRef.collection("nachrichten").add({
      "text": text,
      "senderId": user.uid,
      "senderEmail": user.email ?? "",
      "zeit": FieldValue.serverTimestamp(),
    });

    await newsErstellen(
      empfaengerId: empfaengerId,
      senderEmail: user.email ?? "Nutzer",
      text: text,
    );

    nachrichtController.clear();
  }

  @override
  void dispose() {
    nachrichtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Chat"),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text("Bitte zuerst im Profil einloggen."),
        ),
      );
    }

    final chatId = chatIdErstellen(user.uid);

    return Scaffold(
      backgroundColor: const Color(0xfff6f3ff),
      appBar: AppBar(
        title: Text(widget.produktTitel),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Text(
              "Verkäufer: ${widget.verkaeuferEmail}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("chats")
                  .doc(chatId)
                  .collection("nachrichten")
                  .orderBy("zeit", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final nachrichten = snapshot.data!.docs;

                if (nachrichten.isEmpty) {
                  return const Center(
                    child: Text("Noch keine Nachrichten."),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: nachrichten.length,
                  itemBuilder: (context, index) {
                    final data =
                        nachrichten[index].data() as Map<String, dynamic>;

                    final istIch = data["senderId"] == user.uid;

                    return Align(
                      alignment:
                          istIch ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        constraints: const BoxConstraints(maxWidth: 300),
                        decoration: BoxDecoration(
                          color: istIch ? Colors.deepPurple : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                data["text"] ?? "",
                                style: TextStyle(
                                  color: istIch ? Colors.white : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              zeitText(data["zeit"]),
                              style: TextStyle(
                                color:
                                    istIch ? Colors.white70 : Colors.black45,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nachrichtController,
                    decoration: InputDecoration(
                      hintText: "Nachricht schreiben...",
                      filled: true,
                      fillColor: const Color(0xfff6f3ff),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => nachrichtSenden(),
                  ),
                ),

                const SizedBox(width: 10),

                CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: nachrichtSenden,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}