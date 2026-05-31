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

  bool wirdGesendet = false;

  String chatIdFuer(String userId) {
    final ids = [userId, widget.verkaeuferId]..sort();
    return "${widget.produktId}_${ids[0]}_${ids[1]}";
  }

  Future<void> nachrichtSenden() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final text = nachrichtController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      wirdGesendet = true;
    });

    final chatId = chatIdFuer(user.uid);

    final chatRef = FirebaseFirestore.instance.collection("chats").doc(chatId);

    await chatRef.set(
      {
        "chatId": chatId,
        "produktId": widget.produktId,
        "produktTitel": widget.produktTitel,
        "teilnehmer": [
          user.uid,
          widget.verkaeuferId,
        ],
        "kaeuferId": user.uid,
        "kaeuferEmail": user.email ?? "",
        "verkaeuferId": widget.verkaeuferId,
        "verkaeuferEmail": widget.verkaeuferEmail,
        "letzteNachricht": text,
        "aktualisiertAm": FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await chatRef.collection("nachrichten").add({
      "text": text,
      "senderId": user.uid,
      "senderEmail": user.email ?? "",
      "erstelltAm": FieldValue.serverTimestamp(),
    });

    nachrichtController.clear();

    setState(() {
      wirdGesendet = false;
    });
  }

  @override
  void dispose() {
    nachrichtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final breit = MediaQuery.of(context).size.width > 900;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xfffafafe),
        body: SafeArea(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xffececf4),
                ),
              ),
              child: const Text(
                "Bitte zuerst einloggen, um Nachrichten zu senden.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xff050b2c),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final chatId = chatIdFuer(user.uid);

    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            breit ? 46 : 16,
            16,
            breit ? 46 : 16,
            16,
          ),
          child: Column(
            children: [
              _kopfzeile(context),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xffececf4),
                    ),
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("chats")
                        .doc(chatId)
                        .collection("nachrichten")
                        .orderBy("erstelltAm", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xff5b2cff),
                          ),
                        );
                      }

                      final nachrichten = snapshot.data!.docs;

                      if (nachrichten.isEmpty) {
                        return const Center(
                          child: Text(
                            "Noch keine Nachrichten.\nSchreibe die erste Nachricht.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xff74788d),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(14),
                        itemCount: nachrichten.length,
                        itemBuilder: (context, index) {
                          final daten = nachrichten[index].data()
                              as Map<String, dynamic>;

                          final istIch = daten["senderId"] == user.uid;

                          return _nachrichtBubble(
                            text: daten["text"] ?? "",
                            istIch: istIch,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _eingabeLeiste(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kopfzeile(BuildContext context) {
    return Row(
      children: [
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xff050b2c),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xfff1edff),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.chat_bubble_outline,
            color: Color(0xff5b2cff),
            size: 27,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Nachricht",
                style: TextStyle(
                  color: Color(0xff050b2c),
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                widget.produktTitel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xff74788d),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _nachrichtBubble({
    required String text,
    required bool istIch,
  }) {
    return Align(
      alignment: istIch ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 520,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: istIch ? const Color(0xff5b2cff) : const Color(0xfff3f3f8),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(istIch ? 18 : 4),
            bottomRight: Radius.circular(istIch ? 4 : 18),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: istIch ? Colors.white : const Color(0xff050b2c),
            fontSize: 15,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _eingabeLeiste() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xffececf4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: nachrichtController,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Nachricht schreiben...",
                filled: true,
                fillColor: const Color(0xfff7f7fb),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 52,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff5b2cff),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              onPressed: wirdGesendet ? null : nachrichtSenden,
              child: wirdGesendet
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}