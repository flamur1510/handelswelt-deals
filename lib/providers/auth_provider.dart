/// ─────────────────────────────────────────────────────────
/// AUTH PROVIDER
/// Globaler Auth-State: eingeloggter User, Online-Status,
/// Push-Benachrichtigungen.
///
/// Verwendung:
///   context.watch<AuthProvider>().user
///   context.read<AuthProvider>().istEingeloggtUndVerifiziert
/// ─────────────────────────────────────────────────────────

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../constants/app_konstanten.dart';

class AuthProvider extends ChangeNotifier {
  // ── State ─────────────────────────────────────────────

  User? _user;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<String>? _tokenSub;

  // ── Getter ────────────────────────────────────────────

  User? get user => _user;
  bool get istEingeloggt => _user != null;
  bool get istVerifiziert => _user != null && _user!.emailVerified;
  bool get istEingeloggtUndVerifiziert => istEingeloggt && istVerifiziert;

  // ── Initialisierung ───────────────────────────────────

  AuthProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _tokenSub?.cancel();
    super.dispose();
  }

  // ── Online-Status ─────────────────────────────────────

  Future<void> onlineStatusSetzen(bool online) async {
    final uid = _user?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection(FirestoreKollektionen.users)
          .doc(uid)
          .set(
            {
              'online': online,
              'letzteAktivitaet': FieldValue.serverTimestamp(),
              'aktualisiertAm': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
    } catch (_) {}
  }

  // ── Push-Benachrichtigungen ───────────────────────────

  Future<void> pushVorbereiten() async {
    final uid = _user?.uid;
    if (uid == null) return;

    try {
      final messaging = FirebaseMessaging.instance;

      final einstellung = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      final pushErlaubt =
          einstellung.authorizationStatus == AuthorizationStatus.authorized ||
              einstellung.authorizationStatus ==
                  AuthorizationStatus.provisional;

      final token = await messaging.getToken();

      if (token != null && token.trim().isNotEmpty) {
        await _pushTokenSpeichern(uid, token, pushErlaubt);
      } else {
        await FirebaseFirestore.instance
            .collection(FirestoreKollektionen.users)
            .doc(uid)
            .set(
              {
                'pushAktiviert': pushErlaubt,
                'pushTokenAktualisiertAm': FieldValue.serverTimestamp(),
                'aktualisiertAm': FieldValue.serverTimestamp(),
              },
              SetOptions(merge: true),
            );
      }

      // Token-Refresh lauschen (Subscription wird in dispose() gecancelt)
      _tokenSub?.cancel();
      _tokenSub = messaging.onTokenRefresh.listen((neuerToken) async {
        final aktuellerUid = _user?.uid;
        if (aktuellerUid == null || neuerToken.trim().isEmpty) return;
        await _pushTokenSpeichern(aktuellerUid, neuerToken, true);
      });
    } catch (e) {
      // Push soll App nicht blockieren
      try {
        await FirebaseFirestore.instance
            .collection(FirestoreKollektionen.users)
            .doc(uid)
            .set(
              {
                'pushAktiviert': false,
                'pushFehler': e.toString(),
                'pushTokenAktualisiertAm': FieldValue.serverTimestamp(),
                'aktualisiertAm': FieldValue.serverTimestamp(),
              },
              SetOptions(merge: true),
            );
      } catch (_) {}
    }
  }

  Future<void> _pushTokenSpeichern(
    String userId,
    String token,
    bool pushErlaubt,
  ) async {
    await FirebaseFirestore.instance
        .collection(FirestoreKollektionen.users)
        .doc(userId)
        .set(
          {
            'fcmToken': token,
            'fcmTokens': FieldValue.arrayUnion([token]),
            'pushAktiviert': pushErlaubt,
            'pushTokenAktualisiertAm': FieldValue.serverTimestamp(),
            'aktualisiertAm': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
  }

  // ── Auth-Aktionen ─────────────────────────────────────

  Future<void> abmelden() async {
    await onlineStatusSetzen(false);
    await FirebaseAuth.instance.signOut();
  }
}
