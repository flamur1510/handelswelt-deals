/// ─────────────────────────────────────────────────────────
/// INSERATE SERVICE
/// Alle Firestore-Operationen für Inserate zentral hier.
/// Kein Firestore-Code mehr direkt in den Widgets.
/// ─────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/app_konstanten.dart';
import '../model/produkt.dart';

class InserateService {
  InserateService._();

  static final _db = FirebaseFirestore.instance;

  static const int _seitengroesse = 20;

  /// Erste Seite laden — gibt Produkte + letztes Dokument als Cursor zurück.
  static Future<({List<Produkt> produkte, DocumentSnapshot? cursor})>
      ersteLaden() async {
    final snap = await _db
        .collection(FirestoreKollektionen.inserate)
        .orderBy('erstelltAm', descending: true)
        .limit(_seitengroesse)
        .get();

    final produkte =
        snap.docs.map((doc) => Produkt.fromFirestore(doc)).toList();
    final cursor = snap.docs.isNotEmpty ? snap.docs.last : null;
    return (produkte: produkte, cursor: cursor);
  }

  /// Nächste Seite laden — beginnt nach dem übergebenen Cursor.
  static Future<({List<Produkt> produkte, DocumentSnapshot? cursor})>
      naechsteSeite(DocumentSnapshot cursor) async {
    final snap = await _db
        .collection(FirestoreKollektionen.inserate)
        .orderBy('erstelltAm', descending: true)
        .startAfterDocument(cursor)
        .limit(_seitengroesse)
        .get();

    final produkte =
        snap.docs.map((doc) => Produkt.fromFirestore(doc)).toList();
    final neuerCursor = snap.docs.isNotEmpty ? snap.docs.last : null;
    return (produkte: produkte, cursor: neuerCursor);
  }

  /// Einmalig laden (Fallback / für spezielle Fälle)
  static Future<List<Produkt>> alleLaden() async {
    final snap = await _db
        .collection(FirestoreKollektionen.inserate)
        .orderBy('erstelltAm', descending: true)
        .limit(20)
        .get();

    return snap.docs.map((doc) => Produkt.fromFirestore(doc)).toList();
  }

  /// Anzahl der Aufrufe erhöhen
  static Future<void> aufrufZaehlen(String id) async {
    if (id.trim().isEmpty) return;
    try {
      await _db
          .collection(FirestoreKollektionen.inserate)
          .doc(id)
          .set(
            {
              'aufrufe': FieldValue.increment(1),
              'aktualisiertAm': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
    } catch (_) {}
  }

  /// Inserat löschen
  static Future<void> loeschen(String id) async {
    if (id.trim().isEmpty) return;
    await _db.collection(FirestoreKollektionen.inserate).doc(id).delete();
  }

  /// Inserat aktualisieren
  static Future<void> aktualisieren(
    String id,
    Map<String, dynamic> daten,
  ) async {
    if (id.trim().isEmpty) return;
    await _db
        .collection(FirestoreKollektionen.inserate)
        .doc(id)
        .set(daten, SetOptions(merge: true));
  }

  /// Stream für ein einzelnes Inserat (Echtzeit-Updates)
  static Stream<DocumentSnapshot<Map<String, dynamic>>> inseratStream(
    String id,
  ) {
    return _db
        .collection(FirestoreKollektionen.inserate)
        .doc(id)
        .snapshots();
  }

  /// Icon für eine Kategorie (aus dem Produkt-Modell herausgeholt)
  static IconData iconFuerKategorie(String kategorie) {
    switch (kategorie.toLowerCase()) {
      case 'auto & motor':
      case 'autos':
        return Icons.directions_car_outlined;
      case 'immobilien':
        return Icons.home_outlined;
      case 'elektronik':
        return Icons.devices_outlined;
      case 'jobs':
        return Icons.work_outline;
      case 'dienstleistungen':
        return Icons.build_outlined;
      case 'boote':
        return Icons.sailing_outlined;
      case 'baumaschinen':
        return Icons.precision_manufacturing_outlined;
      case 'baumarkt':
        return Icons.hardware_outlined;
      case 'landwirtschaft':
        return Icons.agriculture_outlined;
      case 'freizeit & hobby':
        return Icons.sports_outlined;
      case 'mode':
        return Icons.checkroom_outlined;
      case 'tierbedarf':
        return Icons.pets_outlined;
      case 'marktplatz':
        return Icons.storefront_outlined;
      default:
        return Icons.shopping_bag_outlined;
    }
  }
}
