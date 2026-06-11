import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_seite.dart';

class ChatlisteSeite extends StatefulWidget {
  const ChatlisteSeite({super.key});

  @override
  State<ChatlisteSeite> createState() => _ChatlisteSeiteState();
}

class _ChatlisteSeiteState extends State<ChatlisteSeite> {
  final sucheController = TextEditingController();
  String suche = '';

  @override
  void dispose() {
    sucheController.dispose();
    super.dispose();
  }

  String _zeitText(dynamic wert) {
    if (wert is! Timestamp) return '';

    final datum = wert.toDate();
    final jetzt = DateTime.now();
    final heute = DateTime(jetzt.year, jetzt.month, jetzt.day);
    final gestern = heute.subtract(const Duration(days: 1));
    final tag = DateTime(datum.year, datum.month, datum.day);

    final stunde = datum.hour.toString().padLeft(2, '0');
    final minute = datum.minute.toString().padLeft(2, '0');
    final uhrzeit = '$stunde:$minute';

    if (tag == heute) return uhrzeit;
    if (tag == gestern) return 'Gestern';

    final d = datum.day.toString().padLeft(2, '0');
    final m = datum.month.toString().padLeft(2, '0');
    return '$d.$m.${datum.year}';
  }

  String _onlineText(Map<String, dynamic> userData) {
    final online = userData['online'] == true;
    if (online) return 'Online';

    final letzteAktivitaet = userData['letzteAktivitaet'];
    if (letzteAktivitaet is! Timestamp) return 'Offline';

    final diff = DateTime.now().difference(letzteAktivitaet.toDate());

    if (diff.inMinutes < 1) return 'Gerade eben aktiv';
    if (diff.inMinutes < 60) return 'Zuletzt vor ${diff.inMinutes} Min.';
    if (diff.inHours < 24) return 'Zuletzt vor ${diff.inHours} Std.';
    if (diff.inDays == 1) return 'Zuletzt gestern';
    return 'Zuletzt vor ${diff.inDays} Tagen';
  }

  bool _istOnline(Map<String, dynamic> userData) {
    return userData['online'] == true;
  }

  String _anzeigename({
    required Map<String, dynamic> userData,
    required String fallbackEmail,
  }) {
    final kontoTyp = (userData['kontoTyp'] ?? '').toString();
    final firmenname = (userData['firmenname'] ?? '').toString().trim();
    final benutzername = (userData['benutzername'] ?? '').toString().trim();
    final vorname = (userData['vorname'] ?? '').toString().trim();
    final nachname = (userData['nachname'] ?? '').toString().trim();

    if (kontoTyp == 'firma' && firmenname.isNotEmpty) return firmenname;
    if (benutzername.isNotEmpty) return benutzername;

    final vollerName = '$vorname $nachname'.trim();
    if (vollerName.isNotEmpty) return vollerName;

    return fallbackEmail.isEmpty ? 'Unbekannter Nutzer' : fallbackEmail;
  }

  String _profilBildUrl(Map<String, dynamic> userData) {
    final profilBild = (userData['profilBildUrl'] ?? '').toString().trim();
    if (profilBild.isNotEmpty) return profilBild;

    final logo = (userData['logoUrl'] ?? userData['firmenlogo'] ?? '').toString().trim();
    return logo;
  }

  String _letzteNachrichtText(Map<String, dynamic> daten) {
    final letzte = (daten['letzteNachricht'] ?? '').toString().trim();
    if (letzte.isNotEmpty) return letzte;

    final typ = (daten['letzteNachrichtTyp'] ?? '').toString();
    if (typ == 'bild') return '📷 Bild';
    if (typ == 'standort') return '📍 Standort';
    if (typ == 'audio') return '🎤 Sprachnachricht';

    return 'Noch keine Nachricht';
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
                border: Border.all(color: const Color(0xffececf4)),
              ),
              child: const Text(
                'Bitte zuerst einloggen.',
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
              const SizedBox(height: 14),
              _suchfeld(),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .where('teilnehmer', arrayContains: user.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _fehler(snapshot.error.toString());
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xff5b2cff),
                        ),
                      );
                    }

                    final chats = snapshot.data!.docs.toList();

                    chats.sort((a, b) {
                      final aData = a.data() as Map<String, dynamic>;
                      final bData = b.data() as Map<String, dynamic>;

                      final aZeit = aData['aktualisiertAm'];
                      final bZeit = bData['aktualisiertAm'];

                      if (aZeit is Timestamp && bZeit is Timestamp) {
                        return bZeit.compareTo(aZeit);
                      }

                      return 0;
                    });

                    final gefiltert = chats.where((doc) {
                      final daten = doc.data() as Map<String, dynamic>;
                      final produktTitel = (daten['produktTitel'] ?? '').toString();
                      final letzteNachricht = _letzteNachrichtText(daten);
                      final verkaeuferEmail = (daten['verkaeuferEmail'] ?? '').toString();
                      final kaeuferEmail = (daten['kaeuferEmail'] ?? '').toString();
                      final suchText = '$produktTitel $letzteNachricht $verkaeuferEmail $kaeuferEmail'.toLowerCase();
                      return suchText.contains(suche.trim().toLowerCase());
                    }).toList();

                    if (chats.isEmpty) {
                      return _leer();
                    }

                    if (gefiltert.isEmpty) {
                      return _keineTreffer();
                    }

                    return ListView.builder(
                      itemCount: gefiltert.length,
                      itemBuilder: (context, index) {
                        final daten = gefiltert[index].data() as Map<String, dynamic>;

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
          style: IconButton.styleFrom(backgroundColor: Colors.white),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xff050b2c)),
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
                'Meine Chats',
                style: TextStyle(
                  color: Color(0xff050b2c),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Nachrichten zu deinen Inseraten.',
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

  Widget _suchfeld() {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: sucheController,
        onChanged: (value) {
          setState(() {
            suche = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Chats suchen...',
          prefixIcon: const Icon(Icons.search, color: Color(0xff5b2cff)),
          suffixIcon: suche.trim().isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    setState(() {
                      suche = '';
                      sucheController.clear();
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0xffececf4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0xffececf4)),
          ),
        ),
      ),
    );
  }

  Widget _chatKarte({
    required BuildContext context,
    required String userId,
    required Map<String, dynamic> daten,
  }) {
    final produktTitel = (daten['produktTitel'] ?? 'Inserat').toString();
    final verkaeuferId = (daten['verkaeuferId'] ?? '').toString();
    final kaeuferId = (daten['kaeuferId'] ?? '').toString();
    final verkaeuferEmail = (daten['verkaeuferEmail'] ?? '').toString();
    final kaeuferEmail = (daten['kaeuferEmail'] ?? '').toString();
    final produktId = (daten['produktId'] ?? '').toString();
    final ungelesenFuer = (daten['ungelesenFuer'] ?? '').toString();
    final hatNeueNachricht = ungelesenFuer == userId;
    final aktualisiertAm = daten['aktualisiertAm'];

    final anderesEmail = userId == verkaeuferId ? kaeuferEmail : verkaeuferEmail;
    final anderesId = userId == verkaeuferId ? kaeuferId : verkaeuferId;

    return StreamBuilder<DocumentSnapshot>(
      stream: anderesId.isEmpty
          ? null
          : FirebaseFirestore.instance.collection('users').doc(anderesId).snapshots(),
      builder: (context, userSnapshot) {
        final userData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
        final name = _anzeigename(userData: userData, fallbackEmail: anderesEmail);
        final profilBildUrl = _profilBildUrl(userData);
        final online = _istOnline(userData);
        final onlineText = _onlineText(userData);
        final letzteNachricht = _letzteNachrichtText(daten);
        final firmaVerifiziert = userData['firmaVerifiziert'] == true || userData['verifiziert'] == true;

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
                color: hatNeueNachricht
                    ? const Color(0xff5b2cff).withOpacity(0.35)
                    : const Color(0xffececf4),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0f000000),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xfff1edff),
                      backgroundImage: profilBildUrl.isNotEmpty ? NetworkImage(profilBildUrl) : null,
                      child: profilBildUrl.isEmpty
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Color(0xff5b2cff),
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: online ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xff050b2c),
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (_zeitText(aktualisiertAm).isNotEmpty)
                            Text(
                              _zeitText(aktualisiertAm),
                              style: const TextStyle(
                                color: Color(0xff74788d),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              produktTitel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xff5b2cff),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (firmaVerifiziert)
                            const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(Icons.verified, color: Colors.orange, size: 16),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        onlineText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: online ? Colors.green : const Color(0xff74788d),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        letzteNachricht,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: hatNeueNachricht ? const Color(0xff050b2c) : const Color(0xff74788d),
                          fontSize: 13,
                          fontWeight: hatNeueNachricht ? FontWeight.w900 : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hatNeueNachricht)
                      Container(
                        width: 13,
                        height: 13,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    const Icon(Icons.chevron_right, color: Color(0xff74788d)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
          border: Border.all(color: const Color(0xffececf4)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_outlined, color: Color(0xff5b2cff), size: 52),
            SizedBox(height: 14),
            Text(
              'Noch keine Chats',
              style: TextStyle(
                color: Color(0xff050b2c),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Sobald du Nachrichten bekommst, erscheinen sie hier.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xff74788d)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _keineTreffer() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(34),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xffececf4)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, color: Color(0xff5b2cff), size: 52),
            SizedBox(height: 14),
            Text(
              'Keine Chats gefunden',
              style: TextStyle(
                color: Color(0xff050b2c),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Versuche einen anderen Suchbegriff.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xff74788d)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fehler(String fehler) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Text(
          'Chat konnte nicht geladen werden:\n\n$fehler',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
