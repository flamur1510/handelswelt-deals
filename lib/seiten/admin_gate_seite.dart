import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_meldungen_seite.dart';

class AdminGateSeite extends StatelessWidget {
  const AdminGateSeite({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Bitte einloggen."),
        ),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final data =
            snapshot.data!.data() as Map<String, dynamic>? ?? {};

        final isAdmin = data["isAdmin"] == true;

        if (!isAdmin) {
          return const Scaffold(
            body: Center(
              child: Text(
                "Kein Zugriff",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          );
        }

        return const AdminMeldungenSeite();
      },
    );
  }
}
