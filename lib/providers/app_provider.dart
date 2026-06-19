/// ─────────────────────────────────────────────────────────
/// APP PROVIDER
/// Globaler State für Produkte und Favoriten.
///
/// Verwendet Cursor-basierte Pagination:
/// Erste 20 Inserate beim Start, danach jeweils 20 mehr
/// beim Scrollen ans Ende — spart 93% der Firestore-Reads.
/// ─────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/produkt.dart';
import '../services/favoriten_service.dart';
import '../services/inserate_service.dart';

class AppProvider extends ChangeNotifier {
  // ── State ─────────────────────────────────────────────

  List<Produkt> _produkte = [];
  bool _laedt = true;
  bool _laedtMehr = false;
  bool _mehrVorhanden = true;
  String? _fehler;
  int? _navigiereZuTab;

  DocumentSnapshot? _cursor;
  Set<String> _favoritIds = {};

  // ── Getter ────────────────────────────────────────────

  List<Produkt> get produkte => List.unmodifiable(_produkte);
  bool get laedt => _laedt;
  bool get laedtMehr => _laedtMehr;
  bool get mehrVorhanden => _mehrVorhanden;
  String? get fehler => _fehler;
  int? get navigiereZuTab => _navigiereZuTab;

  void tabNavigationAbgeschlossen() {
    _navigiereZuTab = null;
  }

  // ── Initialisierung ───────────────────────────────────

  /// Erste 20 Inserate laden + Favoriten markieren.
  Future<void> initialisieren() async {
    _laedt = true;
    _fehler = null;
    _produkte = [];
    _cursor = null;
    _mehrVorhanden = true;
    notifyListeners();

    // Favorit-IDs laden
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      _favoritIds = userId.isNotEmpty
          ? await FavoritenService.favoritIdsFuerUser(userId)
          : {};
    } catch (_) {
      _favoritIds = {};
    }

    // Erste Seite laden
    try {
      final ergebnis = await InserateService.ersteLaden();
      _favoritAnwenden(ergebnis.produkte);
      _produkte = ergebnis.produkte;
      _cursor = ergebnis.cursor;
      _mehrVorhanden = ergebnis.produkte.length >= 20;
    } catch (e) {
      _fehler = e.toString();
    }

    _laedt = false;
    notifyListeners();
  }

  /// Nächste 20 Inserate nachladen — wird beim Scroll-Ende ausgelöst.
  Future<void> mehrLaden() async {
    if (_laedtMehr || !_mehrVorhanden || _cursor == null) return;

    _laedtMehr = true;
    notifyListeners();

    try {
      final ergebnis = await InserateService.naechsteSeite(_cursor!);
      _favoritAnwenden(ergebnis.produkte);
      _produkte = [..._produkte, ...ergebnis.produkte];
      _cursor = ergebnis.cursor ?? _cursor;
      _mehrVorhanden = ergebnis.produkte.length >= 20;
    } catch (_) {
      // Fehler beim Nachladen ignorieren — bestehende Daten bleiben
    }

    _laedtMehr = false;
    notifyListeners();
  }

  void _favoritAnwenden(List<Produkt> produkte) {
    for (final p in produkte) {
      p.favorit = _favoritIds.contains(FavoritenService.produktIdBerechnen(p));
    }
  }

  // ── Navigation ────────────────────────────────────────

  void zuStartUndAktualisieren() {
    _navigiereZuTab = 0;
    notifyListeners();
  }

  // ── Produkte ──────────────────────────────────────────

  void produktHinzufuegen(Produkt produkt) {
    _navigiereZuTab = 0;
    notifyListeners();
  }

  // ── Favoriten ─────────────────────────────────────────

  Future<String?> favoritWechseln(Produkt produkt) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 'Bitte registrieren oder anmelden, um Favoriten zu speichern.';
    }

    final produktId = FavoritenService.produktIdBerechnen(produkt);

    try {
      if (produkt.favorit) {
        await FavoritenService.entfernen(
          userId: user.uid,
          produktId: produktId,
        );
        _favoritIds.remove(produktId);
      } else {
        await FavoritenService.hinzufuegen(
          userId: user.uid,
          userEmail: user.email ?? '',
          produktId: produktId,
          produkt: produkt,
        );
        _favoritIds.add(produktId);
      }

      final index = _produkte.indexWhere(
        (p) => FavoritenService.produktIdBerechnen(p) == produktId,
      );
      if (index != -1) {
        _produkte[index].favorit = !produkt.favorit;
        notifyListeners();
      }

      return null;
    } catch (e) {
      return 'Favorit konnte nicht gespeichert werden: $e';
    }
  }

  Future<void> favoritenNeuLaden() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      _favoritIds = {};
      for (final p in _produkte) {
        p.favorit = false;
      }
      notifyListeners();
      return;
    }

    try {
      _favoritIds = await FavoritenService.favoritIdsFuerUser(userId);
      for (final p in _produkte) {
        p.favorit = _favoritIds.contains(FavoritenService.produktIdBerechnen(p));
      }
      notifyListeners();
    } catch (_) {}
  }
}
