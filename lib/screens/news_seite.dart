import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/produkt.dart';
import '../seiten/detail_seite.dart';
import '../seiten/chat_seite.dart';

class NewsSeite extends StatefulWidget {
  const NewsSeite({super.key});

  @override
  State<NewsSeite> createState() => _NewsSeiteState();
}

class _NewsSeiteState extends State<NewsSeite> {
  bool chatsOffen = false;
  bool favoritenOffen = false;

  String _text(Map<String, dynamic> daten, List<String> keys) {
    for (final key in keys) {
      final value = daten[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return '';
  }

  DateTime? _datum(dynamic wert) {
    if (wert is Timestamp) return wert.toDate();
    return null;
  }

  String _zeitText(dynamic wert) {
    final datum = _datum(wert);
    if (datum == null) return '';

    final jetzt = DateTime.now();
    final heute = DateTime(jetzt.year, jetzt.month, jetzt.day);
    final gestern = heute.subtract(const Duration(days: 1));
    final tag = DateTime(datum.year, datum.month, datum.day);

    final stunde = datum.hour.toString().padLeft(2, '0');
    final minute = datum.minute.toString().padLeft(2, '0');

    if (tag == heute) return '$stunde:$minute';
    if (tag == gestern) return 'Gestern';

    final d = datum.day.toString().padLeft(2, '0');
    final m = datum.month.toString().padLeft(2, '0');
    return '$d.$m.${datum.year}';
  }

  String _kategorieAnzeige(String kategorie) {
    if (kategorie == 'Autos' ||
        kategorie == 'Motorräder' ||
        kategorie == 'Motorrad') {
      return 'Auto & Motor';
    }
    if (kategorie == 'Möbel') return 'Haus & Garten';
    if (kategorie == 'Freizeit & Hobby') return 'Freizeit';
    if (kategorie == 'Tierbedarf') return 'Tiere';
    return kategorie;
  }

  int _zahl(String text) {
    return int.tryParse(
          text
              .replaceAll('€', '')
              .replaceAll('.', '')
              .replaceAll(',', '')
              .replaceAll('/Tag', '')
              .replaceAll('pro Tag', '')
              .trim(),
        ) ??
        0;
  }

  String _preisText(Produkt produkt) {
    final preis = produkt.preis.trim();
    if (preis.isEmpty) return 'Preis auf Anfrage';
    return preis.endsWith('€') ? preis : '$preis €';
  }

  Future<void> _chatAlsGelesenMarkieren(
    DocumentReference ref,
    String userId,
  ) async {
    await ref.set(
      {
        'ungelesenFuer': '',
        'gelesenVon': FieldValue.arrayUnion([userId]),
        'gelesenAm': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final breit = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            breit ? 46 : 16,
            18,
            breit ? 46 : 16,
            24,
          ),
          children: [
            _handelsweltHeader(),
            const SizedBox(height: 16),
            _heroKarte(user),
            const SizedBox(height: 18),
            if (user == null) ...[
              _leer('Bitte einloggen, um Chats und Favoriten zu sehen.'),
              const SizedBox(height: 18),
            ] else ...[
              _chatBereich(context, user.uid),
              const SizedBox(height: 14),
              _favoritenBereich(context, user.uid),
              const SizedBox(height: 18),
            ],
            _personalisierteInserate(context, user?.uid),
          ],
        ),
      ),
    );
  }

  Widget _handelsweltHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xff050b2c),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff5b2cff), Color(0xff7a5cff)],
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(Icons.language, color: Colors.white, size: 27),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'HANDELSWELT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              Text(
                'DEALS',
                style: TextStyle(
                  color: Color(0xffb9a8ff),
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: const Row(
              children: [
                Icon(Icons.notifications_outlined, color: Colors.white70, size: 18),
                SizedBox(width: 6),
                Text(
                  'News',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroKarte(User? user) {
    if (user == null) {
      return _heroInhalt(
        chats: 0,
        ungelesen: 0,
        favoriten: 0,
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('teilnehmer', arrayContains: user.uid)
          .snapshots(),
      builder: (context, chatSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('favoriten')
              .where('userId', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, favSnapshot) {
            final chats = chatSnapshot.data?.docs ?? [];
            final ungelesen = chats.where((doc) {
              final daten = doc.data() as Map<String, dynamic>;
              return (daten['ungelesenFuer'] ?? '').toString() == user.uid;
            }).length;

            final favoriten = favSnapshot.data?.docs.length ?? 0;

            return _heroInhalt(
              chats: chats.length,
              ungelesen: ungelesen,
              favoriten: favoriten,
            );
          },
        );
      },
    );
  }

  Widget _heroInhalt({
    required int chats,
    required int ungelesen,
    required int favoriten,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff050b2c), Color(0xff11184f), Color(0xff5b2cff)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x225b2cff),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deine News',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$ungelesen ungelesene Chats • $favoriten Favoriten',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 5),
                Text(
                  '$chats',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.13)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatBereich(BuildContext context, String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('teilnehmer', arrayContains: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _fehler('Chats konnten nicht geladen werden.');
        if (!snapshot.hasData) return _ladeKarte();

        final chats = snapshot.data!.docs.toList();

        chats.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aZeit = _datum(aData['aktualisiertAm']);
          final bZeit = _datum(bData['aktualisiertAm']);
          if (aZeit == null && bZeit == null) return 0;
          if (aZeit == null) return 1;
          if (bZeit == null) return -1;
          return bZeit.compareTo(aZeit);
        });

        final ungelesen = chats.where((doc) {
          final daten = doc.data() as Map<String, dynamic>;
          return (daten['ungelesenFuer'] ?? '').toString() == userId;
        }).length;

        return _aufklappBereich(
          titel: 'Chats',
          anzahl: chats.length,
          icon: Icons.chat_bubble_outline,
          offen: chatsOffen,
          hinweis: ungelesen > 0 ? '$ungelesen ungelesen' : 'Keine neuen Nachrichten',
          onTap: () => setState(() => chatsOffen = !chatsOffen),
          child: chats.isEmpty
              ? _leer('Noch keine Chats vorhanden.')
              : Column(
                  children: chats.take(8).map((doc) {
                    final daten = doc.data() as Map<String, dynamic>;
                    return _chatKarte(
                      context: context,
                      chatRef: doc.reference,
                      daten: daten,
                      userId: userId,
                    );
                  }).toList(),
                ),
        );
      },
    );
  }

  Widget _favoritenBereich(BuildContext context, String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('favoriten')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _fehler('Favoriten konnten nicht geladen werden.');
        if (!snapshot.hasData) return _ladeKarte();

        final favoriten = snapshot.data!.docs.toList();

        favoriten.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aZeit = _datum(aData['gespeichertAm'] ?? aData['erstelltAm']);
          final bZeit = _datum(bData['gespeichertAm'] ?? bData['erstelltAm']);
          if (aZeit == null && bZeit == null) return 0;
          if (aZeit == null) return 1;
          if (bZeit == null) return -1;
          return bZeit.compareTo(aZeit);
        });

        return _aufklappBereich(
          titel: 'Favoriten',
          anzahl: favoriten.length,
          icon: Icons.favorite,
          iconFarbe: Colors.red,
          offen: favoritenOffen,
          hinweis: favoriten.isEmpty
              ? 'Noch nichts gespeichert'
              : 'Deine zuletzt gespeicherten Inserate',
          onTap: () => setState(() => favoritenOffen = !favoritenOffen),
          child: favoriten.isEmpty
              ? _leer('Noch keine Favoriten gespeichert.')
              : Column(
                  children: favoriten.take(8).map((doc) {
                    final daten = doc.data() as Map<String, dynamic>;
                    return _favoritKarte(context, daten);
                  }).toList(),
                ),
        );
      },
    );
  }

  Widget _personalisierteInserate(BuildContext context, String? userId) {
    if (userId == null) {
      return _alleInserate(context, bevorzugteKategorien: const {});
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('favoriten')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, favSnapshot) {
        final favDocs = favSnapshot.data?.docs ?? [];
        final kategorieZaehler = <String, int>{};

        for (final doc in favDocs) {
          final daten = doc.data() as Map<String, dynamic>;
          final kat = _kategorieAnzeige(
            _text(daten, ['produktKategorie', 'kategorie', 'category']),
          );
          if (kat.trim().isEmpty) continue;
          kategorieZaehler[kat] = (kategorieZaehler[kat] ?? 0) + 1;
        }

        final topKategorien = kategorieZaehler.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        final bevorzugteKategorien = topKategorien.take(3).map((e) => e.key).toSet();

        return _alleInserate(context, bevorzugteKategorien: bevorzugteKategorien);
      },
    );
  }

  Widget _alleInserate(
    BuildContext context, {
    required Set<String> bevorzugteKategorien,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('inserate').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _fehler('Inserate konnten nicht geladen werden.');
        if (!snapshot.hasData) return _ladeKarte();

        final alleProdukte = snapshot.data!.docs.map((doc) {
          return Produkt.fromFirestore(doc);
        }).where((produkt) {
          if (bevorzugteKategorien.isEmpty) return true;
          return bevorzugteKategorien.contains(_kategorieAnzeige(produkt.kategorie));
        }).toList();

        final topInserate = [...alleProdukte]
          ..sort((a, b) => _zahl(a.preis).compareTo(_zahl(b.preis)));

        final neueInserate = [...alleProdukte].reversed.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bevorzugteKategorien.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'Für dich: ${bevorzugteKategorien.join(', ')}',
                  style: const TextStyle(
                    color: Color(0xff74788d),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
            _swipeBereich(
              titel: 'Top Inserate für dich',
              icon: Icons.local_fire_department_outlined,
              produkte: topInserate.take(12).toList(),
            ),
            const SizedBox(height: 16),
            _swipeBereich(
              titel: 'Neue Inserate für dich',
              icon: Icons.new_releases_outlined,
              produkte: neueInserate.take(12).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _swipeBereich({
    required String titel,
    required IconData icon,
    required List<Produkt> produkte,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffececf4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0f000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xff5b2cff).withOpacity(0.11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xff5b2cff), size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$titel (${produkte.length})',
                  style: const TextStyle(
                    color: Color(0xff050b2c),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Icon(Icons.swipe_right_alt, color: Color(0xff5b2cff)),
            ],
          ),
          const SizedBox(height: 12),
          if (produkte.isEmpty)
            _leer('Noch keine passenden Inserate gefunden.')
          else
            SizedBox(
              height: 224,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: produkte.length,
                itemBuilder: (context, index) {
                  return _produktKarte(context, produkte[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _produktKarte(BuildContext context, Produkt produkt) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailSeite(produkt: produkt)),
        );
      },
      child: Container(
        width: 178,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xffececf4)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 14,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 105,
                width: double.infinity,
                child: produkt.bild.trim().isEmpty
                    ? _produktPlatzhalter(produkt)
                    : Image.network(
                        produkt.bild,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _produktPlatzhalter(produkt),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produkt.titel.isEmpty ? 'Inserat' : produkt.titel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xff050b2c),
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _preisText(produkt),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xff5b2cff),
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xff74788d)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          produkt.ort.isEmpty ? 'Österreich' : produkt.ort,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xff74788d),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _produktPlatzhalter(Produkt produkt) {
    return Container(
      color: const Color(0xfff1edff),
      child: Icon(produkt.icon, color: const Color(0xff5b2cff), size: 38),
    );
  }

  Widget _chatKarte({
    required BuildContext context,
    required DocumentReference chatRef,
    required Map<String, dynamic> daten,
    required String userId,
  }) {
    final produktTitel = _text(daten, ['produktTitel']);
    final letzteNachricht = _text(daten, ['letzteNachricht']);
    final produktId = _text(daten, ['produktId']);

    final verkaeuferId = _text(daten, ['verkaeuferId']);
    final kaeuferId = _text(daten, ['kaeuferId']);
    final verkaeuferEmail = _text(daten, ['verkaeuferEmail']);
    final kaeuferEmail = _text(daten, ['kaeuferEmail']);

    final anderesId = userId == verkaeuferId ? kaeuferId : verkaeuferId;
    final anderesEmail = userId == verkaeuferId ? kaeuferEmail : verkaeuferEmail;

    final ungelesen = (daten['ungelesenFuer'] ?? '').toString() == userId;
    final zeit = _zeitText(daten['aktualisiertAm']);
    final initial = anderesEmail.isNotEmpty ? anderesEmail[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          if (ungelesen) await _chatAlsGelesenMarkieren(chatRef, userId);
          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatSeite(
                verkaeuferId: anderesId,
                verkaeuferEmail: anderesEmail,
                produktId: produktId,
                produktTitel: produktTitel.isEmpty ? 'Inserat' : produktTitel,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xfffbfbff),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ungelesen ? const Color(0xff5b2cff).withOpacity(0.6) : const Color(0xffececf4),
            ),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: const Color(0xfff1edff),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Color(0xff5b2cff),
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (ungelesen)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 17,
                        height: 17,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            produktTitel.isEmpty ? 'Inserat' : produktTitel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xff050b2c),
                              fontSize: 15,
                              fontWeight: ungelesen ? FontWeight.w900 : FontWeight.w800,
                            ),
                          ),
                        ),
                        if (zeit.isNotEmpty)
                          Text(
                            zeit,
                            style: const TextStyle(
                              color: Color(0xff74788d),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      anderesEmail.isEmpty ? 'Kontakt' : anderesEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff5b2cff),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      letzteNachricht.isEmpty ? 'Neue Nachricht' : letzteNachricht,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff74788d),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xff74788d)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _favoritKarte(BuildContext context, Map<String, dynamic> daten) {
    final titel = _text(daten, ['produktTitel', 'titel', 'title']);
    final preis = _text(daten, ['produktPreis', 'preis', 'price']);
    final ort = _text(daten, ['produktOrt', 'ort', 'location']);
    final bild = _text(daten, ['produktBild', 'bild', 'image']);
    final kategorie = _kategorieAnzeige(
      _text(daten, ['produktKategorie', 'kategorie', 'category']),
    );
    final produktId = _text(daten, ['produktId', 'id']);

    final preisText = preis.isEmpty ? 'Preis auf Anfrage' : (preis.endsWith('€') ? preis : '$preis €');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          if (produktId.isEmpty) return;

          final doc = await FirebaseFirestore.instance
              .collection('inserate')
              .doc(produktId)
              .get();

          if (!context.mounted) return;
          if (!doc.exists) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Dieses Inserat wurde gelöscht.')),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailSeite(produkt: Produkt.fromFirestore(doc)),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xfffbfbff),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xffececf4)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 58,
                  height: 58,
                  child: bild.isEmpty
                      ? Container(
                          color: const Color(0xfff1edff),
                          child: const Icon(Icons.favorite, color: Color(0xff5b2cff)),
                        )
                      : Image.network(
                          bild,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: const Color(0xfff1edff),
                              child: const Icon(Icons.favorite, color: Color(0xff5b2cff)),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titel.isEmpty ? 'Favorit' : titel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff050b2c),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preisText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff5b2cff),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [ort, kategorie].where((e) => e.trim().isNotEmpty).join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff74788d),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xff74788d)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _aufklappBereich({
    required String titel,
    required int anzahl,
    required IconData icon,
    required bool offen,
    required VoidCallback onTap,
    required Widget child,
    String hinweis = '',
    Color iconFarbe = const Color(0xff5b2cff),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffececf4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0f000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: iconFarbe.withOpacity(0.11),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: iconFarbe, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$titel ($anzahl)',
                          style: const TextStyle(
                            color: Color(0xff050b2c),
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (hinweis.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            hinweis,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xff74788d),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    offen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xff5b2cff),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
          if (offen)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _ladeKarte() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffececf4)),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xff5b2cff)),
      ),
    );
  }

  Widget _leer(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffececf4)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xff74788d),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _fehler(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withOpacity(0.25)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900),
      ),
    );
  }
}
