/// ─────────────────────────────────────────────────────────
/// FAVORITEN SERVICE
/// Alle Firestore-Operationen für Favoriten zentral hier.
/// ─────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/app_konstanten.dart';
import '../model/produkt.dart';

class FavoritenService {
  FavoritenService._();

  static final _db = FirebaseFirestore.instance;

  /// Alle Favorit-IDs eines Nutzers laden
  static Future<Set<String>> favoritIdsFuerUser(String userId) async {
    if (userId.trim().isEmpty) return {};

    try {
      final snap = await _db
          .collection(FirestoreKollektionen.favoriten)
          .where('userId', isEqualTo: userId)
          .get();

      return snap.docs
          .map((doc) => (doc.data()['produktId'] ?? '').toString().trim())
          .where((id) => id.isNotEmpty)
          .toSet();
    } catch (_) {
      return {};
    }
  }

  /// Favorit hinzufügen
  static Future<void> hinzufuegen({
    required String userId,
    required String userEmail,
    required String produktId,
    required Produkt produkt,
  }) async {
    final docId = '${userId}_$produktId';

    await _db
        .collection(FirestoreKollektionen.favoriten)
        .doc(docId)
        .set({
      'userId': userId,
      'userEmail': userEmail,
      'produktId': produktId,
      'echteProduktId': produkt.id.trim(),
      'lokalerFavorit': produkt.id.trim().isEmpty,
      'produktTitel': produkt.titel,
      'produktBild': produkt.bild,
      'produktPreis': produkt.preis,
      'produktOrt': produkt.ort,
      'produktKategorie': produkt.kategorie,
      'produktUnterkategorie': produkt.unterkategorie,
      'produktDetailUnterkategorie': produkt.detailUnterkategorie,
      'verkaeuferId': produkt.verkaeuferId,
      'verkaeuferEmail': produkt.verkaeuferEmail,
      'firmaVerifiziert': produkt.firmaVerifiziert,
      'erstelltAm': FieldValue.serverTimestamp(),
      'gespeichertAm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Favorit entfernen
  static Future<void> entfernen({
    required String userId,
    required String produktId,
  }) async {
    final docId = '${userId}_$produktId';
    await _db
        .collection(FirestoreKollektionen.favoriten)
        .doc(docId)
        .delete();
  }

  /// Berechnet eine stabile ID für ein Produkt (auch ohne Firestore-ID)
  static String produktIdBerechnen(Produkt produkt) {
    final echteId = produkt.id.trim();
    if (echteId.isNotEmpty) return echteId;

    final basis = [
      produkt.titel,
      produkt.preis,
      produkt.ort,
      produkt.verkaeuferId,
      produkt.verkaeuferEmail,
      produkt.bild,
    ].join('_');

    return 'lokal_${basis.hashCode.abs()}';
  }
}
