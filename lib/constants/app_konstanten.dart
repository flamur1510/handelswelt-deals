/// ─────────────────────────────────────────────────────────
/// APP KONSTANTEN
/// Alle Farben, Stile und Werte zentral an einem Ort.
/// Wenn du eine Farbe ändern willst, ändere sie hier —
/// sie wird automatisch überall aktualisiert.
/// ─────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

// ── Farben ────────────────────────────────────────────────

const Color kPrimary = Color(0xff5b2cff);
const Color kPrimaryHell = Color(0xff1a1035);
const Color kHintergrund = Color(0xff0a0a1a);
const Color kTextDunkel = Color(0xffffffff);
const Color kTextDunkel2 = Color(0xffe8e8f0);
const Color kTextGrau = Color(0xff9094a8);
const Color kRand = Color(0xff2a2a4a);
const Color kKartenFill = Color(0xff1a1a35);
const Color kKartenHintergrund = Color(0xff12122a);
const Color kDunkelBlau = Color(0xff1a1a3a);

const LinearGradient kPrimaryGradient = LinearGradient(
  colors: [kTextDunkel, kPrimary],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kHeroGradient = LinearGradient(
  colors: [kTextDunkel, kDunkelBlau, kPrimary],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

const LinearGradient kFooterGradient = LinearGradient(
  colors: [kTextDunkel, kDunkelBlau],
);

// ── Schattierungen ────────────────────────────────────────

const List<BoxShadow> kKartenSchatten = [
  BoxShadow(
    color: Color(0x10000000),
    blurRadius: 18,
    offset: Offset(0, 8),
  ),
];

const List<BoxShadow> kPrimarySchatten = [
  BoxShadow(
    color: Color(0x335b2cff),
    blurRadius: 14,
    offset: Offset(0, 6),
  ),
];

// ── Abstände ──────────────────────────────────────────────

const double kPaddingMobil = 16.0;
const double kPaddingBreit = 46.0;
const double kBorderRadius = 18.0;
const double kBorderRadiusGross = 24.0;
const double kBreitSchwelle = 900.0; // ab wann gilt "Desktop-Layout"

// ── Firestore-Sammlungen (typsicher, kein Tippfehler möglich) ──

class FirestoreKollektionen {
  FirestoreKollektionen._();

  static const String inserate = 'inserate';
  static const String users = 'users';
  static const String chats = 'chats';
  static const String nachrichten = 'nachrichten';
  static const String favoriten = 'favoriten';
  static const String benachrichtigungen = 'benachrichtigungen';
  static const String meldungen = 'meldungen';
  static const String blockierungen = 'blockierungen';
}

// ── Filter- & Sortier-Werte (Magic Strings vermeiden) ────────

/// Kategorie-Standardwert ("alle Kategorien anzeigen")
const String kAlle = 'Alle';

/// Verkäufer-Typen
const String kTypPrivat = 'Privat';
const String kTypFirma = 'Firma';

/// Sortier-Optionen
const String kSortNeueste = 'Neueste zuerst';
const String kSortAelteste = 'Älteste zuerst';
const String kSortPreisAuf = 'Preis aufsteigend';
const String kSortPreisAb = 'Preis absteigend';

/// Umkreis-Filter
const String kUmkreisOesterreichweit = 'Österreichweit';

/// Standard-Sortierung beim App-Start
const String kSortDefault = kSortNeueste;

// ── Textstile ─────────────────────────────────────────────

const TextStyle kTitelStil = TextStyle(
  color: kTextDunkel,
  fontSize: 22,
  fontWeight: FontWeight.w900,
);

const TextStyle kUntertitelStil = TextStyle(
  color: kTextGrau,
  fontWeight: FontWeight.w700,
  height: 1.4,
);

const TextStyle kButtonStil = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.w900,
);

const TextStyle kChipStil = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w900,
);
