import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/produkt.dart';
import 'detail_seite.dart';
import 'firma_melden_seite.dart';

class FirmenProfilSeite extends StatefulWidget {
  final String userId;
  final String firmenname;

  const FirmenProfilSeite({
    super.key,
    required this.userId,
    required this.firmenname,
  });

  @override
  State<FirmenProfilSeite> createState() => _FirmenProfilSeiteState();
}

class _FirmenProfilSeiteState extends State<FirmenProfilSeite> {
  final firmenInseratSucheController = TextEditingController();

  String firmenInseratSuche = '';
  String firmenKategorieFilter = 'Alle';
  String firmenSortierung = 'Neueste zuerst';

  @override
  void initState() {
    super.initState();
    _profilAufrufZaehlen();
  }

  @override
  void dispose() {
    firmenInseratSucheController.dispose();
    super.dispose();
  }

  Future<void> _profilAufrufZaehlen() async {
    final user = FirebaseAuth.instance.currentUser;
    if (widget.userId.trim().isEmpty) return;
    if (user != null && user.uid == widget.userId) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).set({
        'profilAufrufe': FieldValue.increment(1),
        'letzterProfilAufrufAm': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Profilaufrufe dürfen das Öffnen des Firmenprofils niemals blockieren.
    }
  }

  bool get _istEigenesProfil {
    return FirebaseAuth.instance.currentUser?.uid == widget.userId;
  }

  int _intWert(dynamic wert) {
    if (wert is int) return wert;
    if (wert is num) return wert.toInt();
    return int.tryParse((wert ?? '0').toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(widget.userId).get(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xff5b2cff)),
            );
          }

          final data = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
          final telefon = (data['telefon'] ?? '').toString();
          final webseite = (data['webseite'] ?? '').toString();
          final email = (data['email'] ?? data['firmaEmail'] ?? '').toString();
          final ort = (data['ort'] ?? '').toString();
          final land = (data['land'] ?? '').toString();
          final beschreibung = (data['beschreibung'] ?? '').toString();
          final logoUrl = (data['logoUrl'] ?? data['firmenlogo'] ?? data['profilBildUrl'] ?? '').toString();
          final titelbildUrl = (data['titelbildUrl'] ?? data['bannerUrl'] ?? data['coverUrl'] ?? '').toString();
          final branche = (data['branche'] ?? data['kategorie'] ?? '').toString();
          final erstelltAm = data['erstelltAm'];
          final mitgliedSeit = erstelltAm is Timestamp ? _mitgliedSeitText(erstelltAm) : 'Neu';
          final profilAufrufe = _intWert(data['profilAufrufe']);
          final firmaVerifiziert = data['firmaVerifiziert'] == true ||
              data['verifiziert'] == true ||
              data['istVerifiziert'] == true ||
              data['emailVerifiziert'] == true;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 310,
                pinned: true,
                automaticallyImplyLeading: true,
                iconTheme: const IconThemeData(color: Colors.white),
                backgroundColor: const Color(0xff050b2c),
                flexibleSpace: FlexibleSpaceBar(
                  background: _profilKopf(
                    logoUrl: logoUrl,
                    titelbildUrl: titelbildUrl,
                    branche: branche,
                    firmaVerifiziert: firmaVerifiziert,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('inserate')
                      .where('verkaeuferId', isEqualTo: widget.userId)
                      .snapshots(),
                  builder: (context, inserateSnapshot) {
                    final inserate = inserateSnapshot.data?.docs ?? [];
                    final aktiveInserate = inserate.length;

                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _statistikKarten(
                            aktiveInserate: aktiveInserate,
                            mitgliedSeit: mitgliedSeit,
                            profilAufrufe: profilAufrufe,
                            istEigenesProfil: _istEigenesProfil,
                          ),
                          const SizedBox(height: 14),
                          _antwortStatistikBereich(),
                          const SizedBox(height: 14),
                          _kontaktSchnellKarte(
                            telefon: telefon,
                            email: email,
                            webseite: webseite,
                          ),
                          const SizedBox(height: 14),
                          _firmendatenKarte(
                            ort: ort,
                            land: land,
                            telefon: telefon,
                            email: email,
                            webseite: webseite,
                            branche: branche,
                            mitgliedSeit: mitgliedSeit,
                          ),
                          const SizedBox(height: 14),
                          _ueberUnsKarte(beschreibung),
                          const SizedBox(height: 14),
                          _firmaMeldenButton(),
                          const SizedBox(height: 14),
                          _inserateBereich(
                            context: context,
                            snapshot: inserateSnapshot,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _profilKopf({
    required String logoUrl,
    required String titelbildUrl,
    required String branche,
    required bool firmaVerifiziert,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (titelbildUrl.trim().isNotEmpty)
          Image.network(
            titelbildUrl.trim(),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _kopfVerlauf(),
          )
        else
          _kopfVerlauf(),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xff050b2c).withOpacity(0.78),
                const Color(0xff11184f).withOpacity(0.72),
                const Color(0xff5b2cff).withOpacity(0.72),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 42, 24, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: const Color(0xfff1edff),
                    backgroundImage: logoUrl.trim().isNotEmpty ? NetworkImage(logoUrl.trim()) : null,
                    child: logoUrl.trim().isEmpty
                        ? const Icon(
                            Icons.business,
                            color: Color(0xff5b2cff),
                            size: 44,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.firmenname,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                if (branche.trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    branche.trim(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                _firmenAbzeichenImKopf(firmaVerifiziert),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _kopfVerlauf() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff070b2f),
            Color(0xff11184f),
            Color(0xff5b2cff),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _statistikKarten({
    required int aktiveInserate,
    required String mitgliedSeit,
    required int profilAufrufe,
    required bool istEigenesProfil,
  }) {
    final karten = <Widget>[
      _statKarte(
        icon: Icons.inventory_2_outlined,
        wert: '$aktiveInserate',
        text: 'Aktive Inserate',
      ),
      _statKarte(
        icon: Icons.calendar_month_outlined,
        wert: mitgliedSeit,
        text: 'Mitglied seit',
      ),
      if (istEigenesProfil)
        _statKarte(
          icon: Icons.visibility_outlined,
          wert: '$profilAufrufe',
          text: 'Profilaufrufe',
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final istSchmal = constraints.maxWidth < 620;
        final breite = istSchmal
            ? (constraints.maxWidth - 10) / 2
            : (constraints.maxWidth - ((karten.length - 1) * 10)) / karten.length;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: karten.map((karte) => SizedBox(width: breite, child: karte)).toList(),
        );
      },
    );
  }

  Widget _statKarte({
    required IconData icon,
    required String wert,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          Icon(icon, color: const Color(0xff5b2cff), size: 27),
          const SizedBox(height: 8),
          Text(
            wert,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xff050b2c),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xff74788d),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Future<_AntwortStatistik> _antwortStatistikLaden() async {
    if (widget.userId.trim().isEmpty) {
      return const _AntwortStatistik(chatsMitAnfrage: 0, beantworteteChats: 0, durchschnittSekunden: 0);
    }

    final chatsSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('teilnehmer', arrayContains: widget.userId)
        .limit(60)
        .get();

    int chatsMitAnfrage = 0;
    int beantworteteChats = 0;
    int antwortenMitZeit = 0;
    int gesamtAntwortSekunden = 0;

    for (final chatDoc in chatsSnapshot.docs) {
      final nachrichtenSnapshot = await chatDoc.reference
          .collection('nachrichten')
          .orderBy('erstelltAm', descending: false)
          .limit(80)
          .get();

      Timestamp? offeneAnfrageZeit;
      bool hatteAnfrage = false;
      bool wurdeBeantwortet = false;

      for (final nachricht in nachrichtenSnapshot.docs) {
        final daten = nachricht.data();
        final senderId = (daten['senderId'] ?? '').toString();
        final erstelltAm = daten['erstelltAm'];

        if (erstelltAm is! Timestamp || senderId.trim().isEmpty) continue;

        final istFirma = senderId == widget.userId;

        if (!istFirma) {
          hatteAnfrage = true;
          offeneAnfrageZeit ??= erstelltAm;
        } else if (offeneAnfrageZeit != null) {
          wurdeBeantwortet = true;
          final diff = erstelltAm.toDate().difference(offeneAnfrageZeit.toDate()).inSeconds;
          if (diff >= 0) {
            gesamtAntwortSekunden += diff;
            antwortenMitZeit++;
          }
          offeneAnfrageZeit = null;
        }
      }

      if (hatteAnfrage) chatsMitAnfrage++;
      if (wurdeBeantwortet) beantworteteChats++;
    }

    final durchschnittSekunden = antwortenMitZeit == 0 ? 0 : (gesamtAntwortSekunden / antwortenMitZeit).round();

    return _AntwortStatistik(
      chatsMitAnfrage: chatsMitAnfrage,
      beantworteteChats: beantworteteChats,
      durchschnittSekunden: durchschnittSekunden,
    );
  }

  Widget _antwortStatistikBereich() {
    return FutureBuilder<_AntwortStatistik>(
      future: _antwortStatistikLaden(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _karte(
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(color: Color(0xff5b2cff)),
              ),
            ),
          );
        }

        final statistik = snapshot.data ?? const _AntwortStatistik(chatsMitAnfrage: 0, beantworteteChats: 0, durchschnittSekunden: 0);

        return LayoutBuilder(
          builder: (context, constraints) {
            final istSchmal = constraints.maxWidth < 620;
            final karten = [
              _antwortKarte(
                icon: Icons.mark_chat_read_outlined,
                titel: 'Antwortquote',
                wert: statistik.antwortQuoteText,
                text: statistik.chatsMitAnfrage == 0
                    ? 'Noch keine Anfragen'
                    : '${statistik.beantworteteChats}/${statistik.chatsMitAnfrage} Chats beantwortet',
                farbe: Colors.green,
              ),
              _antwortKarte(
                icon: Icons.schedule_outlined,
                titel: 'Antwortzeit',
                wert: statistik.antwortZeitText,
                text: statistik.durchschnittSekunden == 0 ? 'Noch keine Daten' : 'Durchschnitt aus Chatverlauf',
                farbe: const Color(0xff5b2cff),
              ),
            ];

            if (istSchmal) {
              return Column(
                children: [
                  karten[0],
                  const SizedBox(height: 10),
                  karten[1],
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: karten[0]),
                const SizedBox(width: 10),
                Expanded(child: karten[1]),
              ],
            );
          },
        );
      },
    );
  }

  Widget _antwortKarte({
    required IconData icon,
    required String titel,
    required String wert,
    required String text,
    required Color farbe,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: farbe.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: farbe, size: 27),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titel,
                  style: const TextStyle(
                    color: Color(0xff74788d),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  wert,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff050b2c),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  maxLines: 2,
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
        ],
      ),
    );
  }

  Widget _kontaktSchnellKarte({
    required String telefon,
    required String email,
    required String webseite,
  }) {
    final hatTelefon = telefon.trim().isNotEmpty;
    final hatEmail = email.trim().isNotEmpty;
    final hatWeb = webseite.trim().isNotEmpty;

    if (!hatTelefon && !hatEmail && !hatWeb) return const SizedBox();

    return _karte(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kontakt', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (hatTelefon) _kontaktChip(icon: Icons.phone_outlined, text: telefon.trim(), farbe: Colors.green),
              if (hatEmail) _kontaktChip(icon: Icons.email_outlined, text: email.trim(), farbe: const Color(0xff5b2cff)),
              if (hatWeb) _kontaktChip(icon: Icons.language_outlined, text: webseite.trim(), farbe: Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kontaktChip({
    required IconData icon,
    required String text,
    required Color farbe,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: farbe.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: farbe.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: farbe, size: 18),
          const SizedBox(width: 7),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: SelectableText(
              text,
              maxLines: 1,
              style: TextStyle(color: farbe, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _firmendatenKarte({
    required String ort,
    required String land,
    required String telefon,
    required String email,
    required String webseite,
    required String branche,
    required String mitgliedSeit,
  }) {
    return _karte(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Firmendaten', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          _info('Standort', _standortText(ort, land)),
          _info('Telefon', telefon),
          _info('E-Mail', email),
          _info('Webseite', webseite),
          if (branche.trim().isNotEmpty) _info('Branche', branche),
          _info('Mitglied seit', mitgliedSeit),
        ],
      ),
    );
  }

  Widget _ueberUnsKarte(String beschreibung) {
    return _karte(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Über uns', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text(
            beschreibung.trim().isEmpty ? 'Noch keine Firmenbeschreibung vorhanden.' : beschreibung,
            style: const TextStyle(
              color: Color(0xff4d5368),
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _firmaMeldenButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FirmaMeldenSeite(
                firmaId: widget.userId,
                firmenname: widget.firmenname,
              ),
            ),
          );
        },
        icon: const Icon(Icons.flag_outlined, color: Colors.red),
        label: const Text(
          'Firma melden',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  String _standortText(String ort, String land) {
    final teile = [ort, land].where((e) => e.trim().isNotEmpty).toList();
    return teile.join(', ');
  }

  Widget _inserateBereich({
    required BuildContext context,
    required AsyncSnapshot<QuerySnapshot> snapshot,
  }) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _karte(
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(18),
            child: CircularProgressIndicator(color: Color(0xff5b2cff)),
          ),
        ),
      );
    }

    final docs = snapshot.data?.docs ?? [];

    if (docs.isEmpty) {
      return _karte(
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alle Inserate', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            SizedBox(height: 12),
            Text('Keine Inserate vorhanden.', style: TextStyle(color: Color(0xff74788d), fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }

    final alleInserate = docs.map((doc) {
      final produkt = Produkt.fromFirestore(doc);
      final data = doc.data() as Map<String, dynamic>;
      final erstelltAm = data['erstelltAm'];
      return _FirmenInseratItem(
        produkt: produkt,
        erstelltAm: erstelltAm is Timestamp ? erstelltAm : null,
      );
    }).toList();

    final kategorien = alleInserate
        .map((item) => item.produkt.kategorie.trim())
        .where((kategorie) => kategorie.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final kategorieItems = ['Alle', ...kategorien];
    final aktiverKategorieFilter = kategorieItems.contains(firmenKategorieFilter) ? firmenKategorieFilter : 'Alle';
    final suchtext = firmenInseratSuche.trim().toLowerCase();

    final gefiltert = alleInserate.where((item) {
      final produkt = item.produkt;
      if (aktiverKategorieFilter != 'Alle' && produkt.kategorie != aktiverKategorieFilter) return false;
      if (suchtext.isEmpty) return true;

      final suchQuelle = [
        produkt.titel,
        produkt.preis,
        produkt.ort,
        produkt.kategorie,
        produkt.unterkategorie,
        produkt.detailUnterkategorie,
        produkt.beschreibung,
        produkt.marke,
        produkt.modell,
        produkt.immobilienArt,
        produkt.zustand,
        produkt.hersteller,
        produkt.bootMarke,
        produkt.bootModell,
        produkt.baumaschinenZustand,
      ].join(' ').toLowerCase();

      return suchQuelle.contains(suchtext);
    }).toList();

    if (firmenSortierung == 'Preis aufsteigend') {
      gefiltert.sort((a, b) => _zahl(a.produkt.preis).compareTo(_zahl(b.produkt.preis)));
    } else if (firmenSortierung == 'Preis absteigend') {
      gefiltert.sort((a, b) => _zahl(b.produkt.preis).compareTo(_zahl(a.produkt.preis)));
    } else {
      gefiltert.sort((a, b) {
        final aZeit = a.erstelltAm?.millisecondsSinceEpoch ?? 0;
        final bZeit = b.erstelltAm?.millisecondsSinceEpoch ?? 0;
        return bZeit.compareTo(aZeit);
      });
    }

    final breite = MediaQuery.of(context).size.width;
    final crossAxisCount = breite >= 900 ? 4 : breite >= 600 ? 3 : 2;

    return _karte(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Alle Inserate', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
              Text(
                '${gefiltert.length}/${alleInserate.length}',
                style: const TextStyle(color: Color(0xff5b2cff), fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _firmenInseratFilter(kategorieItems, aktiverKategorieFilter),
          const SizedBox(height: 14),
          if (gefiltert.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xfff7f7fb),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xffececf4)),
              ),
              child: const Text(
                'Keine passenden Inserate gefunden.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xff74788d), fontWeight: FontWeight.w700),
              ),
            )
          else
            GridView.builder(
              itemCount: gefiltert.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, index) => _firmenInseratKarte(context, gefiltert[index].produkt),
            ),
        ],
      ),
    );
  }

  Widget _firmenInseratFilter(List<String> kategorieItems, String aktiverKategorieFilter) {
    final istBreit = MediaQuery.of(context).size.width >= 720;

    final sucheFeld = TextField(
      controller: firmenInseratSucheController,
      onChanged: (value) => setState(() => firmenInseratSuche = value),
      decoration: InputDecoration(
        labelText: 'In Firmeninseraten suchen',
        prefixIcon: const Icon(Icons.search, color: Color(0xff5b2cff)),
        suffixIcon: firmenInseratSuche.trim().isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    firmenInseratSuche = '';
                    firmenInseratSucheController.clear();
                  });
                },
              ),
        filled: true,
        fillColor: const Color(0xfff7f7fb),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );

    final kategorieDropdown = _filterDropdown(
      label: 'Kategorie',
      value: aktiverKategorieFilter,
      items: kategorieItems,
      icon: Icons.category_outlined,
      onChanged: (value) => setState(() => firmenKategorieFilter = value ?? 'Alle'),
    );

    final sortDropdown = _filterDropdown(
      label: 'Sortieren',
      value: firmenSortierung,
      items: const ['Neueste zuerst', 'Preis aufsteigend', 'Preis absteigend'],
      icon: Icons.swap_vert,
      onChanged: (value) => setState(() => firmenSortierung = value ?? 'Neueste zuerst'),
    );

    final reset = InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() {
          firmenInseratSuche = '';
          firmenInseratSucheController.clear();
          firmenKategorieFilter = 'Alle';
          firmenSortierung = 'Neueste zuerst';
        });
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xfff1edff),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.restart_alt, color: Color(0xff5b2cff)),
      ),
    );

    if (istBreit) {
      return Row(
        children: [
          Expanded(flex: 2, child: sucheFeld),
          const SizedBox(width: 10),
          Expanded(child: kategorieDropdown),
          const SizedBox(width: 10),
          Expanded(child: sortDropdown),
          const SizedBox(width: 10),
          reset,
        ],
      );
    }

    return Column(
      children: [
        sucheFeld,
        const SizedBox(height: 10),
        kategorieDropdown,
        const SizedBox(height: 10),
        sortDropdown,
        const SizedBox(height: 10),
        Align(alignment: Alignment.centerRight, child: reset),
      ],
    );
  }

  Widget _filterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    final sichereItems = items.isEmpty ? ['Alle'] : items.toSet().toList();
    final sichererWert = sichereItems.contains(value) ? value : sichereItems.first;

    return DropdownButtonFormField<String>(
      value: sichererWert,
      isExpanded: true,
      items: sichereItems
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xff5b2cff)),
        filled: true,
        fillColor: const Color(0xfff7f7fb),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _firmenInseratKarte(BuildContext context, Produkt produkt) {
    final bild = produkt.bild.trim();
    final preis = _preisAnzeige(produkt);
    final vermietung = _istVermietung(produkt);
    final info = _produktInfoZeile(produkt);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailSeite(produkt: produkt))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xffececf4)),
          boxShadow: const [
            BoxShadow(color: Color(0x0d000000), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  bild.isEmpty
                      ? Container(
                          color: const Color(0xfff1edff),
                          child: Icon(produkt.icon, color: const Color(0xff5b2cff), size: 32),
                        )
                      : Image.network(
                          bild,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xfff1edff),
                            child: Icon(produkt.icon, color: const Color(0xff5b2cff), size: 32),
                          ),
                        ),
                  Positioned(
                    left: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: vermietung ? Colors.blue.withOpacity(0.85) : Colors.green.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        vermietung ? 'Miete' : 'Verkauf',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produkt.titel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff050b2c),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      preis,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff5b2cff),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (info.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        info,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xff050b2c),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 11, color: Color(0xff74788d)),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            produkt.ort,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xff74788d),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 3,
                      children: [
                        if (produkt.kategorie.trim().isNotEmpty)
                          _miniChip(produkt.kategorie, const Color(0xfff1edff), const Color(0xff5b2cff)),
                        if (produkt.unterkategorie.trim().isNotEmpty)
                          _miniChip(produkt.unterkategorie, const Color(0xffe8f8ee), Colors.green),
                        if (produkt.zustand.trim().isNotEmpty)
                          _miniChip(produkt.zustand, const Color(0xfffff6df), Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _firmenAbzeichenImKopf(bool firmaVerifiziert) {
    if (!firmaVerifiziert) return const SizedBox();
    return _abzeichenChip(
      icon: Icons.verified,
      text: 'Verifiziert',
      hintergrund: Colors.white.withOpacity(0.15),
      iconFarbe: Colors.white,
      textFarbe: Colors.white,
    );
  }

  Widget _abzeichenChip({
    required IconData icon,
    required String text,
    required Color hintergrund,
    required Color iconFarbe,
    required Color textFarbe,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hintergrund,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconFarbe, size: 16),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: textFarbe, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  String _mitgliedSeitText(Timestamp timestamp) {
    final datum = timestamp.toDate();
    final monat = datum.month.toString().padLeft(2, '0');
    final jahr = datum.year.toString();
    return '$monat.$jahr';
  }

  Widget _karte({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffececf4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0f000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _info(String titel, String wert) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$titel:',
              style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xff74788d)),
            ),
          ),
          Expanded(
            child: SelectableText(
              wert.isEmpty ? '-' : wert,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniChip(String text, Color bg, Color fg) {
    if (text.trim().isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(30)),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: fg, fontSize: 9.5, fontWeight: FontWeight.w900),
      ),
    );
  }

  int _zahl(String text) {
    return int.tryParse(
          text
              .replaceAll('€', '')
              .replaceAll('.', '')
              .replaceAll(',', '')
              .replaceAll('km', '')
              .replaceAll('m²', '')
              .trim(),
        ) ??
        0;
  }

  String _preisAnzeige(Produkt produkt) {
    if (_istVermietung(produkt) && produkt.mietpreisTag.trim().isNotEmpty) {
      final tag = produkt.mietpreisTag.trim();
      return tag.endsWith('€') ? '$tag / Tag' : '$tag € / Tag';
    }

    final preis = produkt.preis.trim();
    if (preis.isEmpty) return 'Preis auf Anfrage';
    if (preis.endsWith('€')) return preis;
    return '$preis €';
  }

  bool _istVermietung(Produkt produkt) {
    const vermietungen = [
      'Autovermietung',
      'Bootsvermietung',
      'Baumaschinenvermietung',
      'Anhängervermietung',
      'Maschinenvermietung',
    ];

    return vermietungen.contains(produkt.unterkategorie) ||
        vermietungen.contains(produkt.detailUnterkategorie) ||
        produkt.mietpreisTag.trim().isNotEmpty ||
        produkt.mietpreisWoche.trim().isNotEmpty ||
        produkt.mietpreisMonat.trim().isNotEmpty;
  }

  String _produktInfoZeile(Produkt produkt) {
    if (produkt.kategorie == 'Auto & Motor') {
      final teile = [
        produkt.marke,
        produkt.modell,
        produkt.baujahr,
        produkt.kilometer.trim().isEmpty ? '' : '${produkt.kilometer} km',
      ].where((e) => e.trim().isNotEmpty).toList();
      return teile.join(' • ');
    }

    if (produkt.kategorie == 'Immobilien') {
      final teile = [
        produkt.immobilienArt,
        produkt.wohnflaeche.trim().isEmpty ? '' : '${produkt.wohnflaeche} m²',
        produkt.zimmer.trim().isEmpty ? '' : '${produkt.zimmer} Zimmer',
      ].where((e) => e.trim().isNotEmpty).toList();
      return teile.join(' • ');
    }

    if (produkt.kategorie == 'Boote') {
      final teile = [
        produkt.bootMarke,
        produkt.bootModell,
        produkt.bootBaujahr,
      ].where((e) => e.trim().isNotEmpty).toList();
      return teile.join(' • ');
    }

    final teile = [
      produkt.detailUnterkategorie,
      produkt.zustand,
      produkt.hersteller,
    ].where((e) => e.trim().isNotEmpty).toList();

    return teile.join(' • ');
  }
}

class _AntwortStatistik {
  final int chatsMitAnfrage;
  final int beantworteteChats;
  final int durchschnittSekunden;

  const _AntwortStatistik({
    required this.chatsMitAnfrage,
    required this.beantworteteChats,
    required this.durchschnittSekunden,
  });

  String get antwortQuoteText {
    if (chatsMitAnfrage == 0) return '-';
    final prozent = ((beantworteteChats / chatsMitAnfrage) * 100).round();
    return '$prozent %';
  }

  String get antwortZeitText {
    if (durchschnittSekunden <= 0) return '-';
    final minuten = (durchschnittSekunden / 60).round();
    if (minuten < 1) return 'unter 1 Min.';
    if (minuten < 60) return 'ca. $minuten Min.';
    final stunden = (minuten / 60).round();
    if (stunden < 24) return 'ca. $stunden Std.';
    final tage = (stunden / 24).round();
    if (tage == 1) return 'ca. 1 Tag';
    return 'ca. $tage Tage';
  }
}

class _FirmenInseratItem {
  final Produkt produkt;
  final Timestamp? erstelltAm;

  const _FirmenInseratItem({
    required this.produkt,
    required this.erstelltAm,
  });
}
