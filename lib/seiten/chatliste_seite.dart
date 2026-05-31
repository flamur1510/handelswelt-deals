import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_seite.dart';

class ChatlisteSeite extends StatelessWidget {
  const ChatlisteSeite({super.key});

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
                "Bitte zuerst einloggen.",
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

    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            breit ? 46 : 16,
            18,
            breit ? 46 : 16,
            24,
          ),
          child: Column(
            children: [
              _kopfzeile(context),
              const SizedBox(height: 18),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("chats")
                      .where("teilnehmer", arrayContains: user.uid)
                      .orderBy("aktualisiertAm", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xff5b2cff),
                        ),
                      );
                    }

                    final chats = snapshot.data!.docs;

                    if (chats.isEmpty) {
                      return _leer();
                    }

                    return ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final daten =
                            chats[index].data() as Map<String, dynamic>;

                        return _chatKarte(
                          context: context,
                          userId: user.uid,
                          daten: daten,
                        );
                      },
                    );
                  },
                ),
              ),
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
            Icons.forum_outlined,
            color: Color(0xff5b2cff),
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Meine Chats",
                style: TextStyle(
                  color: Color(0xff050b2c),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Nachrichten zu deinen Inseraten.",
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

  Widget _chatKarte({
    required BuildContext context,
    required String userId,
    required Map<String, dynamic> daten,
  }) {
    final produktTitel = daten["produktTitel"] ?? "Inserat";
    final letzteNachricht = daten["letzteNachricht"] ?? "";
    final verkaeuferId = daten["verkaeuferId"] ?? "";
    final kaeuferId = daten["kaeuferId"] ?? "";
    final verkaeuferEmail = daten["verkaeuferEmail"] ?? "";
    final kaeuferEmail = daten["kaeuferEmail"] ?? "";
    final produktId = daten["produktId"] ?? "";

    final anderesEmail = userId == verkaeuferId ? kaeuferEmail : verkaeuferEmail;
    final anderesId = userId == verkaeuferId ? kaeuferId : verkaeuferId;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatSeite(
              verkaeuferId: anderesId,
              verkaeuferEmail: anderesEmail,
              produktId: produktId,
              produktTitel: produktTitel,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xffececf4),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: const Color(0xfff1edff),
              child: Text(
                anderesEmail.isNotEmpty ? anderesEmail[0].toUpperCase() : "?",
                style: const TextStyle(
                  color: Color(0xff5b2cff),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produktTitel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xff050b2c),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    anderesEmail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xff5b2cff),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    letzteNachricht,
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
            const Icon(
              Icons.chevron_right,
              color: Color(0xff74788d),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leer() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(34),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xffececf4),
          ),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.forum_outlined,
              color: Color(0xff5b2cff),
              size: 52,
            ),
            SizedBox(height: 14),
            Text(
              "Noch keine Chats",
              style: TextStyle(
                color: Color(0xff050b2c),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Sobald du Nachrichten bekommst, erscheinen sie hier.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff74788d),
              ),
            ),
          ],
        ),
      ),
    );
  }
}