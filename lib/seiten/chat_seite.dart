import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:file_picker/file_picker.dart';

import 'firmen_profil_seite.dart';

class ChatSeite extends StatefulWidget {
  final String verkaeuferId;
  final String verkaeuferEmail;
  final String produktId;
  final String produktTitel;

  const ChatSeite({
    super.key,
    required this.verkaeuferId,
    required this.verkaeuferEmail,
    required this.produktId,
    required this.produktTitel,
  });

  @override
  State<ChatSeite> createState() => _ChatSeiteState();
}

class _ChatSeiteState extends State<ChatSeite> with WidgetsBindingObserver {
  final nachrichtController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final Map<String, AudioPlayer> _audioPlayerMap = {};

  bool wirdGesendet = false;
  bool wirdBildGesendet = false;
  bool wirdStandortGesendet = false;
  bool wirdAudioGesendet = false;
  bool wirdDateiGesendet = false;
  bool nimmtAudioAuf = false;
  DateTime? aufnahmeStart;
  String? aktuellSpielendeAudioUrl;

  String chatIdFuer(String userId) {
    final ids = [userId, widget.verkaeuferId]..sort();
    return "${widget.produktId}_${ids[0]}_${ids[1]}";
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _eigenenOnlineStatusSetzen(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatAlsGelesenMarkieren();
    });
  }

  @override
  void dispose() {
    _eigenenOnlineStatusSetzen(false);
    WidgetsBinding.instance.removeObserver(this);
    nachrichtController.dispose();
    _audioRecorder.dispose();
    for (final player in _audioPlayerMap.values) {
      player.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _eigenenOnlineStatusSetzen(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _eigenenOnlineStatusSetzen(false);
    }
  }

  Future<void> _eigenenOnlineStatusSetzen(bool online) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set(
        {
          "online": online,
          "letzteAktivitaet": FieldValue.serverTimestamp(),
          "aktualisiertAm": FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // Online-Status soll den Chat niemals blockieren.
    }
  }

  Future<Map<String, dynamic>?> _chatBasisDaten(User user) async {
    final chatId = chatIdFuer(user.uid);
    final chatRef = FirebaseFirestore.instance.collection("chats").doc(chatId);
    final chatDoc = await chatRef.get();
    final vorhandeneDaten = chatDoc.data() ?? {};

    final gespeicherteKaeuferId =
        (vorhandeneDaten["kaeuferId"] ?? "").toString();
    final gespeicherteKaeuferEmail =
        (vorhandeneDaten["kaeuferEmail"] ?? "").toString();

    final istBestehenderChat =
        chatDoc.exists && gespeicherteKaeuferId.isNotEmpty;

    final kaeuferId = istBestehenderChat ? gespeicherteKaeuferId : user.uid;
    final kaeuferEmail =
        istBestehenderChat ? gespeicherteKaeuferEmail : (user.email ?? "");

    final empfaengerId =
        user.uid == widget.verkaeuferId ? kaeuferId : widget.verkaeuferId;

    final teilnehmer = [
      kaeuferId,
      widget.verkaeuferId,
    ];

    return {
      "chatId": chatId,
      "chatRef": chatRef,
      "kaeuferId": kaeuferId,
      "kaeuferEmail": kaeuferEmail,
      "empfaengerId": empfaengerId,
      "teilnehmer": teilnehmer,
    };
  }

  Future<void> _chatUebersichtAktualisieren({
    required User user,
    required String letzteNachricht,
    String letzteNachrichtTyp = 'text',
  }) async {
    final basis = await _chatBasisDaten(user);
    if (basis == null) return;

    final chatRef = basis["chatRef"] as DocumentReference;

    await chatRef.set(
      {
        "chatId": basis["chatId"],
        "produktId": widget.produktId,
        "produktTitel": widget.produktTitel,
        "teilnehmer": basis["teilnehmer"],
        "kaeuferId": basis["kaeuferId"],
        "kaeuferEmail": basis["kaeuferEmail"],
        "verkaeuferId": widget.verkaeuferId,
        "verkaeuferEmail": widget.verkaeuferEmail,
        "letzteNachricht": letzteNachricht,
        "letzteNachrichtTyp": letzteNachrichtTyp,
        "senderIdLetzteNachricht": user.uid,
        "ungelesenFuer": basis["empfaengerId"],
        "gelesenVon": [user.uid],
        "aktualisiertAm": FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> chatAlsGelesenMarkieren() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final chatId = chatIdFuer(user.uid);
    final chatRef = FirebaseFirestore.instance.collection("chats").doc(chatId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) return;

    final daten = chatDoc.data() ?? {};
    final ungelesenFuer = (daten["ungelesenFuer"] ?? "").toString();

    if (ungelesenFuer == user.uid) {
      await chatRef.set(
        {
          "ungelesenFuer": "",
          "gelesenVon": FieldValue.arrayUnion([user.uid]),
          "gelesenAm": FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    final ungeleseneNachrichten = await chatRef
        .collection("nachrichten")
        .where("senderId", isNotEqualTo: user.uid)
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in ungeleseneNachrichten.docs) {
      batch.set(
        doc.reference,
        {
          "gelesenVon": FieldValue.arrayUnion([user.uid]),
          "gelesenAm": FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  Future<void> nachrichtSenden() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final text = nachrichtController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      wirdGesendet = true;
    });

    try {
      final basis = await _chatBasisDaten(user);
      if (basis == null) return;

      final chatRef = basis["chatRef"] as DocumentReference;

      await _chatUebersichtAktualisieren(
        user: user,
        letzteNachricht: text,
      );

      await chatRef.collection("nachrichten").add({
        "typ": "text",
        "text": text,
        "senderId": user.uid,
        "senderEmail": user.email ?? "",
        "gelesenVon": [user.uid],
        "erstelltAm": FieldValue.serverTimestamp(),
      });

      nachrichtController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Nachricht konnte nicht gesendet werden: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        wirdGesendet = false;
      });
    }
  }

  Future<void> bildSenden() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final quelle = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return SafeArea(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_library_outlined),
                    title: const Text(
                      "Bild aus Galerie auswählen",
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_camera_outlined),
                    title: const Text(
                      "Kamera öffnen",
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (quelle == null) return;

      final bild = await _imagePicker.pickImage(
        source: quelle,
        imageQuality: 82,
        maxWidth: 1600,
      );

      if (bild == null) return;

      setState(() {
        wirdBildGesendet = true;
      });

      final chatId = chatIdFuer(user.uid);
      final dateiname = "${DateTime.now().millisecondsSinceEpoch}_${user.uid}.jpg";

      final ref = FirebaseStorage.instance
          .ref()
          .child("chat_bilder")
          .child(chatId)
          .child(dateiname);

      await ref.putFile(File(bild.path));
      final bildUrl = await ref.getDownloadURL();

      final basis = await _chatBasisDaten(user);
      if (basis == null) return;

      final chatRef = basis["chatRef"] as DocumentReference;

      await _chatUebersichtAktualisieren(
        user: user,
        letzteNachricht: "📷 Bild",
        letzteNachrichtTyp: "bild",
      );

      await chatRef.collection("nachrichten").add({
        "typ": "bild",
        "text": "",
        "bildUrl": bildUrl,
        "senderId": user.uid,
        "senderEmail": user.email ?? "",
        "gelesenVon": [user.uid],
        "erstelltAm": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Bild konnte nicht gesendet werden: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        wirdBildGesendet = false;
      });
    }
  }

  Future<bool> _standortBerechtigungPruefen() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Standortdienste sind deaktiviert."),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Standortberechtigung wurde abgelehnt."),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Standortberechtigung dauerhaft abgelehnt. Bitte in den Einstellungen erlauben.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }

    return true;
  }

  Future<void> standortSenden() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      setState(() {
        wirdStandortGesendet = true;
      });

      final erlaubt = await _standortBerechtigungPruefen();
      if (!erlaubt) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final basis = await _chatBasisDaten(user);
      if (basis == null) return;

      final chatRef = basis["chatRef"] as DocumentReference;

      await _chatUebersichtAktualisieren(
        user: user,
        letzteNachricht: "📍 Standort",
        letzteNachrichtTyp: "standort",
      );

      await chatRef.collection("nachrichten").add({
        "typ": "standort",
        "text": "",
        "latitude": position.latitude,
        "longitude": position.longitude,
        "mapsUrl": _mapsUrl(position.latitude, position.longitude),
        "senderId": user.uid,
        "senderEmail": user.email ?? "",
        "gelesenVon": [user.uid],
        "erstelltAm": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Standort konnte nicht gesendet werden: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        wirdStandortGesendet = false;
      });
    }
  }

  String _mapsUrl(double latitude, double longitude) {
    return "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
  }


  Future<void> sprachaufnahmeStarten() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (wirdGesendet || wirdBildGesendet || wirdStandortGesendet || wirdAudioGesendet) {
      return;
    }

    try {
      final erlaubt = await _audioRecorder.hasPermission();

      if (!erlaubt) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Mikrofonberechtigung wurde abgelehnt."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final dateiname =
          "hw_audio_${DateTime.now().millisecondsSinceEpoch}_${user.uid}.m4a";
      final pfad = "${Directory.systemTemp.path}/$dateiname";

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: pfad,
      );

      if (!mounted) return;

      setState(() {
        nimmtAudioAuf = true;
        aufnahmeStart = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Aufnahme konnte nicht gestartet werden: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> sprachaufnahmeStoppenUndSenden() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (!nimmtAudioAuf) return;

    try {
      final start = aufnahmeStart;
      final pfad = await _audioRecorder.stop();
      final dauer = start == null
          ? 0
          : DateTime.now().difference(start).inSeconds.clamp(1, 600);

      if (!mounted) return;

      setState(() {
        nimmtAudioAuf = false;
        aufnahmeStart = null;
        wirdAudioGesendet = true;
      });

      if (pfad == null || pfad.trim().isEmpty) {
        if (mounted) {
          setState(() {
            wirdAudioGesendet = false;
          });
        }
        return;
      }

      final datei = File(pfad);
      if (!await datei.exists()) {
        if (!mounted) return;
        setState(() {
          wirdAudioGesendet = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Aufnahmedatei wurde nicht gefunden."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final chatId = chatIdFuer(user.uid);
      final dateiname =
          "${DateTime.now().millisecondsSinceEpoch}_${user.uid}.m4a";

      final ref = FirebaseStorage.instance
          .ref()
          .child("chat_audio")
          .child(chatId)
          .child(dateiname);

      await ref.putFile(datei);
      final audioUrl = await ref.getDownloadURL();

      final basis = await _chatBasisDaten(user);
      if (basis == null) return;

      final chatRef = basis["chatRef"] as DocumentReference;

      await _chatUebersichtAktualisieren(
        user: user,
        letzteNachricht: "🎤 Sprachnachricht",
        letzteNachrichtTyp: "audio",
      );

      await chatRef.collection("nachrichten").add({
        "typ": "audio",
        "text": "",
        "audioUrl": audioUrl,
        "dauerSekunden": dauer,
        "senderId": user.uid,
        "senderEmail": user.email ?? "",
        "gelesenVon": [user.uid],
        "erstelltAm": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sprachnachricht konnte nicht gesendet werden: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        nimmtAudioAuf = false;
        aufnahmeStart = null;
        wirdAudioGesendet = false;
      });
    }
  }

  Future<void> audioAbspielenOderStoppen(String audioUrl) async {
    if (audioUrl.trim().isEmpty) return;

    try {
      if (aktuellSpielendeAudioUrl == audioUrl) {
        final player = _audioPlayerMap[audioUrl];
        await player?.stop();
        if (!mounted) return;
        setState(() {
          aktuellSpielendeAudioUrl = null;
        });
        return;
      }

      for (final player in _audioPlayerMap.values) {
        await player.stop();
      }

      final player = _audioPlayerMap.putIfAbsent(audioUrl, () {
        final neuerPlayer = AudioPlayer();
        neuerPlayer.onPlayerComplete.listen((_) {
          if (!mounted) return;
          setState(() {
            if (aktuellSpielendeAudioUrl == audioUrl) {
              aktuellSpielendeAudioUrl = null;
            }
          });
        });
        return neuerPlayer;
      });

      await player.play(UrlSource(audioUrl));

      if (!mounted) return;
      setState(() {
        aktuellSpielendeAudioUrl = audioUrl;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Audio konnte nicht abgespielt werden: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> dateiSenden() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (wirdGesendet ||
        wirdBildGesendet ||
        wirdStandortGesendet ||
        wirdAudioGesendet ||
        wirdDateiGesendet ||
        nimmtAudioAuf) {
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt',
          'zip',
        ],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final picked = result.files.single;
      final dateiname = picked.name.trim().isEmpty ? 'Datei' : picked.name.trim();
      final dateigroesse = picked.size;
      final endung = picked.extension?.toLowerCase() ?? '';

      const maxBytes = 25 * 1024 * 1024;
      if (dateigroesse > maxBytes) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Die Datei darf maximal 25 MB groß sein.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (mounted) {
        setState(() {
          wirdDateiGesendet = true;
        });
      }

      final chatId = chatIdFuer(user.uid);
      final saubererName = dateiname.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final storageName = '${DateTime.now().millisecondsSinceEpoch}_${user.uid}_$saubererName';

      final ref = FirebaseStorage.instance
          .ref()
          .child('chat_dateien')
          .child(chatId)
          .child(storageName);

      final metadata = SettableMetadata(
        contentType: _contentTypeFuerEndung(endung),
        customMetadata: {
          'originalName': dateiname,
          'senderId': user.uid,
        },
      );

      if (picked.bytes != null) {
        await ref.putData(picked.bytes!, metadata);
      } else if (picked.path != null && picked.path!.trim().isNotEmpty) {
        await ref.putFile(File(picked.path!), metadata);
      } else {
        throw Exception('Datei konnte nicht gelesen werden.');
      }

      final dateiUrl = await ref.getDownloadURL();

      final basis = await _chatBasisDaten(user);
      if (basis == null) return;

      final chatRef = basis['chatRef'] as DocumentReference;

      await _chatUebersichtAktualisieren(
        user: user,
        letzteNachricht: '📎 $dateiname',
        letzteNachrichtTyp: 'datei',
      );

      await chatRef.collection('nachrichten').add({
        'typ': 'datei',
        'text': '',
        'dateiUrl': dateiUrl,
        'dateiname': dateiname,
        'dateigroesse': dateigroesse,
        'dateiEndung': endung,
        'senderId': user.uid,
        'senderEmail': user.email ?? '',
        'gelesenVon': [user.uid],
        'erstelltAm': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Datei konnte nicht gesendet werden: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        wirdDateiGesendet = false;
      });
    }
  }

  String _contentTypeFuerEndung(String endung) {
    switch (endung.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'zip':
        return 'application/zip';
      default:
        return 'application/octet-stream';
    }
  }

  String _dateigroesseText(int bytes) {
    if (bytes <= 0) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }


  Future<void> _textKopieren(String wert) async {
    final sauber = wert.trim();
    if (sauber.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: sauber));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Kopiert."),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _chatOderNutzerMelden({
    required String partnerId,
    required String grund,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final chatId = chatIdFuer(user.uid);

    try {
      await FirebaseFirestore.instance.collection("meldungen").add({
        "typ": "chat",
        "chatId": chatId,
        "produktId": widget.produktId,
        "produktTitel": widget.produktTitel,
        "melderId": user.uid,
        "gemeldeterUserId": partnerId,
        "grund": grund,
        "status": "offen",
        "erstelltAm": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Meldung wurde gespeichert."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Meldung konnte nicht gespeichert werden: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _meldenDialogOeffnen(String partnerId) async {
    if (partnerId.trim().isEmpty) return;

    final grund = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Chat melden",
                  style: TextStyle(
                    color: Color(0xff050b2c),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                _meldeGrundTile("Spam oder Werbung"),
                _meldeGrundTile("Betrug oder verdächtiges Verhalten"),
                _meldeGrundTile("Beleidigung oder Belästigung"),
                _meldeGrundTile("Unangemessene Inhalte"),
                _meldeGrundTile("Sonstiges Problem"),
              ],
            ),
          ),
        );
      },
    );

    if (grund == null || grund.trim().isEmpty) return;
    await _chatOderNutzerMelden(partnerId: partnerId, grund: grund);
  }

  Widget _meldeGrundTile(String grund) {
    return ListTile(
      leading: const Icon(Icons.flag_outlined, color: Colors.red),
      title: Text(
        grund,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      onTap: () => Navigator.pop(context, grund),
    );
  }

  Future<void> _blockierenOderFreigeben({
    required String partnerId,
    required bool istBlockiert,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (partnerId.trim().isEmpty) return;

    final chatId = chatIdFuer(user.uid);
    final chatRef = FirebaseFirestore.instance.collection("chats").doc(chatId);

    if (!istBlockiert) {
      final bestaetigt = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            title: const Text(
              "Nutzer blockieren?",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            content: const Text(
              "Dieser Nutzer kann dir in diesem Chat keine neuen Nachrichten mehr senden, solange du ihn blockiert hast.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Abbrechen"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Blockieren",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          );
        },
      );

      if (bestaetigt != true) return;
    }

    try {
      await chatRef.set({
        "blockiertVon": istBlockiert
            ? FieldValue.arrayRemove([user.uid])
            : FieldValue.arrayUnion([user.uid]),
        "aktualisiertAm": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection("blockierungen")
          .doc("${user.uid}_$partnerId")
          .set({
        "blockiererId": user.uid,
        "blockierterUserId": partnerId,
        "chatId": chatId,
        "aktiv": !istBlockiert,
        "aktualisiertAm": FieldValue.serverTimestamp(),
        "erstelltAm": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(istBlockiert ? "Blockierung aufgehoben." : "Nutzer wurde blockiert."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Aktion fehlgeschlagen: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _nachrichtFuerMichLoeschen(String nachrichtId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (nachrichtId.trim().isEmpty) return;

    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text(
            "Nachricht entfernen?",
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text("Die Nachricht wird nur für dich ausgeblendet."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Abbrechen"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Entfernen",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    if (bestaetigt != true) return;

    final chatId = chatIdFuer(user.uid);
    await FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId)
        .collection("nachrichten")
        .doc(nachrichtId)
        .set({
      "geloeschtFuer": FieldValue.arrayUnion([user.uid]),
    }, SetOptions(merge: true));
  }

  void _dateiAnzeigen({
    required String dateiname,
    required String dateiUrl,
    required int dateigroesse,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Datei',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateiname,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              if (dateigroesse > 0) ...[
                const SizedBox(height: 6),
                Text(_dateigroesseText(dateigroesse)),
              ],
              const SizedBox(height: 14),
              const Text(
                'Download-Link:',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              SelectableText(
                dateiUrl,
                style: const TextStyle(color: Color(0xff5b2cff)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => _textKopieren(dateiUrl),
              child: const Text('Link kopieren'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Schließen'),
            ),
          ],
        );
      },
    );
  }

  String _dauerText(int sekunden) {
    final sichereSekunden = sekunden < 0 ? 0 : sekunden;
    final minuten = (sichereSekunden ~/ 60).toString();
    final rest = (sichereSekunden % 60).toString().padLeft(2, "0");
    return "$minuten:$rest";
  }

  String _zeitText(dynamic wert) {
    if (wert is! Timestamp) return "";

    final datum = wert.toDate();
    final jetzt = DateTime.now();
    final heute = DateTime(jetzt.year, jetzt.month, jetzt.day);
    final gestern = heute.subtract(const Duration(days: 1));
    final tag = DateTime(datum.year, datum.month, datum.day);

    final stunde = datum.hour.toString().padLeft(2, "0");
    final minute = datum.minute.toString().padLeft(2, "0");
    final uhrzeit = "$stunde:$minute";

    if (tag == heute) return uhrzeit;
    if (tag == gestern) return "Gestern $uhrzeit";

    final d = datum.day.toString().padLeft(2, "0");
    final m = datum.month.toString().padLeft(2, "0");
    return "$d.$m.${datum.year} $uhrzeit";
  }

  String _chatPartnerName(Map<String, dynamic> daten, User user) {
    final istVerkaeufer = user.uid == widget.verkaeuferId;

    if (istVerkaeufer) {
      final kaeuferEmail = (daten["kaeuferEmail"] ?? "").toString();
      return kaeuferEmail.isEmpty ? "Käufer" : kaeuferEmail;
    }

    if (widget.verkaeuferEmail.trim().isNotEmpty) {
      return widget.verkaeuferEmail.trim();
    }

    return "Verkäufer";
  }


  String _chatPartnerId(Map<String, dynamic> daten, User user) {
    final verkaeuferId = (daten["verkaeuferId"] ?? widget.verkaeuferId).toString();
    final kaeuferId = (daten["kaeuferId"] ?? "").toString();

    if (user.uid == verkaeuferId) return kaeuferId;
    return verkaeuferId.isNotEmpty ? verkaeuferId : widget.verkaeuferId;
  }

  String _anzeigenameAusUserDaten({
    required Map<String, dynamic> userData,
    required String fallback,
  }) {
    final kontoTyp = (userData["kontoTyp"] ?? "").toString();
    final firmenname = (userData["firmenname"] ?? "").toString().trim();
    final benutzername = (userData["benutzername"] ?? "").toString().trim();
    final vorname = (userData["vorname"] ?? "").toString().trim();
    final nachname = (userData["nachname"] ?? "").toString().trim();

    if (kontoTyp == "firma" && firmenname.isNotEmpty) return firmenname;
    if (benutzername.isNotEmpty) return benutzername;

    final vollerName = "$vorname $nachname".trim();
    if (vollerName.isNotEmpty) return vollerName;

    return fallback.trim().isEmpty ? "Kontakt" : fallback.trim();
  }

  String _profilBildAusUserDaten(Map<String, dynamic> userData) {
    final profilBild = (userData["profilBildUrl"] ?? "").toString().trim();
    if (profilBild.isNotEmpty) return profilBild;

    final logo = (userData["logoUrl"] ?? userData["firmenlogo"] ?? "").toString().trim();
    return logo;
  }

  bool _istOnline(Map<String, dynamic> userData) {
    return userData["online"] == true;
  }

  String _onlineText(Map<String, dynamic> userData) {
    if (_istOnline(userData)) return "Online";

    final letzteAktivitaet = userData["letzteAktivitaet"];
    if (letzteAktivitaet is! Timestamp) return "Offline";

    final diff = DateTime.now().difference(letzteAktivitaet.toDate());
    if (diff.inMinutes < 1) return "Gerade eben aktiv";
    if (diff.inMinutes < 60) return "Zuletzt vor ${diff.inMinutes} Min.";
    if (diff.inHours < 24) return "Zuletzt vor ${diff.inHours} Std.";
    if (diff.inDays == 1) return "Zuletzt gestern";
    return "Zuletzt vor ${diff.inDays} Tagen";
  }

  bool _firmaVerifiziert(Map<String, dynamic> userData) {
    return userData["firmaVerifiziert"] == true ||
        userData["verifiziert"] == true ||
        userData["istVerifiziert"] == true;
  }

  void _bildGrossAnzeigen(String bildUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              InteractiveViewer(
                child: Center(
                  child: Image.network(
                    bildUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          "Bild konnte nicht geladen werden.",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.black),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _standortAnzeigen({
    required double latitude,
    required double longitude,
    required String mapsUrl,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            "Standort",
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Latitude: ${latitude.toStringAsFixed(6)}"),
              Text("Longitude: ${longitude.toStringAsFixed(6)}"),
              const SizedBox(height: 12),
              const Text(
                "Google-Maps-Link:",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              SelectableText(
                mapsUrl,
                style: const TextStyle(color: Color(0xff5b2cff)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => _textKopieren(mapsUrl),
              child: const Text("Link kopieren"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Schließen"),
            ),
          ],
        );
      },
    );
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
                "Bitte zuerst einloggen, um Nachrichten zu senden.",
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

    final chatId = chatIdFuer(user.uid);
    final chatRef = FirebaseFirestore.instance.collection("chats").doc(chatId);

    return Scaffold(
      backgroundColor: const Color(0xfffafafe),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            breit ? 46 : 16,
            16,
            breit ? 46 : 16,
            16,
          ),
          child: StreamBuilder<DocumentSnapshot>(
            stream: chatRef.snapshots(),
            builder: (context, chatSnapshot) {
              final chatDaten =
                  chatSnapshot.data?.data() as Map<String, dynamic>? ?? {};
              final partnerName = _chatPartnerName(chatDaten, user);
              final partnerId = _chatPartnerId(chatDaten, user);
              final blockiertVon = List<String>.from(chatDaten["blockiertVon"] ?? []);
              final ichHabeBlockiert = blockiertVon.contains(user.uid);
              final ichBinBlockiert = blockiertVon.any((id) => id != user.uid);

              return Column(
                children: [
                  _kopfzeile(
                    context,
                    partnerName,
                    partnerId,
                    ichHabeBlockiert,
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xffececf4)),
                      ),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: chatRef
                            .collection("nachrichten")
                            .orderBy("erstelltAm", descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xff5b2cff),
                              ),
                            );
                          }

                          final nachrichten = snapshot.data!.docs.where((doc) {
                            final daten = doc.data() as Map<String, dynamic>;
                            final geloeschtFuer = List<String>.from(daten["geloeschtFuer"] ?? []);
                            return !geloeschtFuer.contains(user.uid);
                          }).toList();

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            chatAlsGelesenMarkieren();
                          });

                          if (nachrichten.isEmpty) {
                            return const Center(
                              child: Text(
                                "Noch keine Nachrichten.\nSchreibe die erste Nachricht.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xff74788d),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            reverse: true,
                            padding: const EdgeInsets.all(14),
                            itemCount: nachrichten.length,
                            itemBuilder: (context, index) {
                              final daten = nachrichten[index].data()
                                  as Map<String, dynamic>;

                              final istIch = daten["senderId"] == user.uid;
                              final gelesenVon = List<String>.from(
                                daten["gelesenVon"] ?? [],
                              );
                              final istGelesen =
                                  gelesenVon.any((id) => id != user.uid);

                              final latRaw = daten["latitude"];
                              final lonRaw = daten["longitude"];
                              final latitude = latRaw is num ? latRaw.toDouble() : 0.0;
                              final longitude = lonRaw is num ? lonRaw.toDouble() : 0.0;
                              final dauerRaw = daten["dauerSekunden"];
                              final dauerSekunden =
                                  dauerRaw is num ? dauerRaw.toInt() : 0;

                              return _nachrichtBubble(
                                nachrichtId: nachrichten[index].id,
                                typ: (daten["typ"] ?? "text").toString(),
                                text: (daten["text"] ?? "").toString(),
                                bildUrl: (daten["bildUrl"] ?? "").toString(),
                                audioUrl: (daten["audioUrl"] ?? "").toString(),
                                dateiUrl: (daten["dateiUrl"] ?? "").toString(),
                                dateiname: (daten["dateiname"] ?? "").toString(),
                                dateigroesse: (daten["dateigroesse"] is num)
                                    ? (daten["dateigroesse"] as num).toInt()
                                    : 0,
                                dateiEndung: (daten["dateiEndung"] ?? "").toString(),
                                dauerSekunden: dauerSekunden,
                                latitude: latitude,
                                longitude: longitude,
                                mapsUrl: (daten["mapsUrl"] ?? "").toString(),
                                zeit: _zeitText(daten["erstelltAm"]),
                                istIch: istIch,
                                istGelesen: istGelesen,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (ichHabeBlockiert)
                    _chatHinweis(
                      text: "Du hast diesen Nutzer blockiert.",
                      buttonText: "Freigeben",
                      onTap: () => _blockierenOderFreigeben(
                        partnerId: partnerId,
                        istBlockiert: true,
                      ),
                    )
                  else if (ichBinBlockiert)
                    _chatHinweis(
                      text: "Du kannst in diesem Chat aktuell nicht antworten.",
                    )
                  else
                    _eingabeLeiste(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _kopfzeile(
    BuildContext context,
    String partnerName,
    String partnerId,
    bool ichHabeBlockiert,
  ) {
    if (partnerId.trim().isEmpty) {
      return _kopfzeileInhalt(
        context: context,
        name: partnerName,
        statusText: "",
        online: false,
        profilBildUrl: "",
        firmaVerifiziert: false,
        partnerId: "",
        ichHabeBlockiert: ichHabeBlockiert,
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(partnerId)
          .snapshots(),
      builder: (context, snapshot) {
        final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final name = _anzeigenameAusUserDaten(
          userData: userData,
          fallback: partnerName,
        );
        final profilBildUrl = _profilBildAusUserDaten(userData);
        final online = _istOnline(userData);
        final statusText = _onlineText(userData);
        final verifiziert = _firmaVerifiziert(userData);

        return _kopfzeileInhalt(
          context: context,
          name: name,
          statusText: statusText,
          online: online,
          profilBildUrl: profilBildUrl,
          firmaVerifiziert: verifiziert,
          partnerId: partnerId,
          ichHabeBlockiert: ichHabeBlockiert,
        );
      },
    );
  }

  Widget _kopfzeileInhalt({
    required BuildContext context,
    required String name,
    required String statusText,
    required bool online,
    required String profilBildUrl,
    required bool firmaVerifiziert,
    required String partnerId,
    required bool ichHabeBlockiert,
  }) {
    void profilOeffnen() {
      if (partnerId.trim().isEmpty) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FirmenProfilSeite(
            userId: partnerId,
            firmenname: name,
          ),
        ),
      );
    }

    return Row(
      children: [
        IconButton(
          style: IconButton.styleFrom(backgroundColor: Colors.white),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xff050b2c)),
        ),
        const SizedBox(width: 10),
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: partnerId.trim().isEmpty ? null : profilOeffnen,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xfff1edff),
                backgroundImage: profilBildUrl.trim().isNotEmpty
                    ? NetworkImage(profilBildUrl.trim())
                    : null,
                child: profilBildUrl.trim().isEmpty
                    ? Text(
                        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : "?",
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
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: partnerId.trim().isEmpty ? null : profilOeffnen,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
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
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (firmaVerifiziert)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.verified,
                            color: Colors.orange,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: online ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          statusText.isEmpty ? widget.produktTitel : statusText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: online ? Colors.green : const Color(0xff74788d),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.produktTitel,
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
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xff050b2c)),
          onSelected: (wert) {
            if (wert == "melden") {
              _meldenDialogOeffnen(partnerId);
            } else if (wert == "blockieren") {
              _blockierenOderFreigeben(
                partnerId: partnerId,
                istBlockiert: ichHabeBlockiert,
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: "melden",
              child: Row(
                children: [
                  Icon(Icons.flag_outlined, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Chat melden"),
                ],
              ),
            ),
            PopupMenuItem(
              value: "blockieren",
              child: Row(
                children: [
                  Icon(
                    ichHabeBlockiert ? Icons.lock_open : Icons.block,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(ichHabeBlockiert ? "Blockierung aufheben" : "Nutzer blockieren"),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _nachrichtBubble({
    required String nachrichtId,
    required String typ,
    required String text,
    required String bildUrl,
    required String audioUrl,
    required String dateiUrl,
    required String dateiname,
    required int dateigroesse,
    required String dateiEndung,
    required int dauerSekunden,
    required double latitude,
    required double longitude,
    required String mapsUrl,
    required String zeit,
    required bool istIch,
    required bool istGelesen,
  }) {
    return GestureDetector(
      onLongPress: () => _nachrichtFuerMichLoeschen(nachrichtId),
      child: Align(
        alignment: istIch ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: istIch ? const Color(0xff5b2cff) : const Color(0xfff3f3f8),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(istIch ? 18 : 4),
            bottomRight: Radius.circular(istIch ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              istIch ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (typ == "bild" && bildUrl.trim().isNotEmpty)
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _bildGrossAnzeigen(bildUrl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    bildUrl,
                    width: 260,
                    height: 220,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 260,
                        height: 220,
                        color: Colors.black.withOpacity(0.06),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xff5b2cff),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 260,
                        height: 130,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          "Bild konnte nicht geladen werden",
                          style: TextStyle(
                            color: istIch ? Colors.white : const Color(0xff050b2c),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            else if (typ == "audio" && audioUrl.trim().isNotEmpty)
              _audioNachricht(
                audioUrl: audioUrl,
                dauerSekunden: dauerSekunden,
                istIch: istIch,
              )
            else if (typ == "datei" && dateiUrl.trim().isNotEmpty)
              _dateiNachricht(
                dateiUrl: dateiUrl,
                dateiname: dateiname,
                dateigroesse: dateigroesse,
                dateiEndung: dateiEndung,
                istIch: istIch,
              )
            else if (typ == "standort")
              InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () => _standortAnzeigen(
                  latitude: latitude,
                  longitude: longitude,
                  mapsUrl: mapsUrl.isEmpty ? _mapsUrl(latitude, longitude) : mapsUrl,
                ),
                child: Container(
                  width: 260,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: istIch
                        ? Colors.white.withOpacity(0.14)
                        : const Color(0xffeaf7ff),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: istIch
                          ? Colors.white.withOpacity(0.20)
                          : Colors.blue.withOpacity(0.20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: istIch ? Colors.white : const Color(0xff5b2cff),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: istIch ? const Color(0xff5b2cff) : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Standort geteilt",
                              style: TextStyle(
                                color: istIch ? Colors.white : const Color(0xff050b2c),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Google Maps öffnen",
                              style: TextStyle(
                                color: istIch ? Colors.white70 : const Color(0xff74788d),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Text(
                text,
                style: TextStyle(
                  color: istIch ? Colors.white : const Color(0xff050b2c),
                  fontSize: 15,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (zeit.isNotEmpty)
                  Text(
                    zeit,
                    style: TextStyle(
                      color: istIch ? Colors.white70 : const Color(0xff74788d),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (istIch) ...[
                  const SizedBox(width: 7),
                  Icon(
                    istGelesen ? Icons.done_all : Icons.done,
                    size: 16,
                    color: istGelesen ? Colors.lightBlueAccent : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _dateiNachricht({
    required String dateiUrl,
    required String dateiname,
    required int dateigroesse,
    required String dateiEndung,
    required bool istIch,
  }) {
    final name = dateiname.trim().isEmpty ? 'Datei' : dateiname.trim();
    final endung = dateiEndung.trim().isEmpty
        ? (name.contains('.') ? name.split('.').last.toUpperCase() : 'DATEI')
        : dateiEndung.toUpperCase();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _dateiAnzeigen(
        dateiname: name,
        dateiUrl: dateiUrl,
        dateigroesse: dateigroesse,
      ),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: istIch ? Colors.white.withOpacity(0.14) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: istIch
                ? Colors.white.withOpacity(0.20)
                : const Color(0xffececf4),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: istIch ? Colors.white : const Color(0xff5b2cff),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.insert_drive_file_outlined,
                color: istIch ? const Color(0xff5b2cff) : Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: istIch ? Colors.white : const Color(0xff050b2c),
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${endung.toUpperCase()}${dateigroesse > 0 ? ' • ${_dateigroesseText(dateigroesse)}' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: istIch ? Colors.white70 : const Color(0xff74788d),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.download_outlined,
              color: istIch ? Colors.white70 : const Color(0xff5b2cff),
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  Widget _audioNachricht({
    required String audioUrl,
    required int dauerSekunden,
    required bool istIch,
  }) {
    final spielt = aktuellSpielendeAudioUrl == audioUrl;

    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: istIch ? Colors.white.withOpacity(0.14) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: istIch
              ? Colors.white.withOpacity(0.20)
              : const Color(0xffececf4),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => audioAbspielenOderStoppen(audioUrl),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: istIch ? Colors.white : const Color(0xff5b2cff),
                shape: BoxShape.circle,
              ),
              child: Icon(
                spielt ? Icons.stop : Icons.play_arrow,
                color: istIch ? const Color(0xff5b2cff) : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    18,
                    (index) => Expanded(
                      child: Container(
                        height: (index % 5 + 2) * 4,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: istIch
                              ? Colors.white.withOpacity(0.72)
                              : const Color(0xff5b2cff).withOpacity(0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _dauerText(dauerSekunden),
                  style: TextStyle(
                    color: istIch ? Colors.white70 : const Color(0xff74788d),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.mic,
            color: istIch ? Colors.white70 : const Color(0xff5b2cff),
            size: 20,
          ),
        ],
      ),
    );
  }


  Widget _chatHinweis({
    required String text,
    String? buttonText,
    VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xfffff6df),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orange.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xff050b2c),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (buttonText != null && onTap != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onTap,
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _eingabeLeiste() {
    final gesperrt = wirdGesendet ||
        wirdBildGesendet ||
        wirdStandortGesendet ||
        wirdAudioGesendet ||
        wirdDateiGesendet;
    final andereAktionLaeuft = gesperrt || nimmtAudioAuf;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffececf4)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xfffff6df),
              ),
              onPressed: andereAktionLaeuft ? null : dateiSenden,
              icon: wirdDateiGesendet
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.orange,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.attach_file,
                      color: Colors.orange,
                    ),
            ),
          ),
          const SizedBox(width: 7),
          SizedBox(
            width: 46,
            height: 46,
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xfff1edff),
              ),
              onPressed: andereAktionLaeuft ? null : bildSenden,
              icon: wirdBildGesendet
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Color(0xff5b2cff),
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.photo_outlined,
                      color: Color(0xff5b2cff),
                    ),
            ),
          ),
          const SizedBox(width: 7),
          SizedBox(
            width: 46,
            height: 46,
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xffeaf7ff),
              ),
              onPressed: andereAktionLaeuft ? null : standortSenden,
              icon: wirdStandortGesendet
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.location_on_outlined,
                      color: Colors.blue,
                    ),
            ),
          ),
          const SizedBox(width: 7),
          SizedBox(
            width: 46,
            height: 46,
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: nimmtAudioAuf
                    ? const Color(0xffffedf1)
                    : const Color(0xfff7f7fb),
              ),
              onPressed: gesperrt
                  ? null
                  : (nimmtAudioAuf
                      ? sprachaufnahmeStoppenUndSenden
                      : sprachaufnahmeStarten),
              icon: wirdAudioGesendet
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.red,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      nimmtAudioAuf ? Icons.stop : Icons.mic_none_outlined,
                      color: nimmtAudioAuf ? Colors.red : const Color(0xff050b2c),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: nachrichtController,
              enabled: !nimmtAudioAuf,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) {
                if (!andereAktionLaeuft) nachrichtSenden();
              },
              decoration: InputDecoration(
                hintText: nimmtAudioAuf ? "Aufnahme läuft..." : "Nachricht schreiben...",
                filled: true,
                fillColor: const Color(0xfff7f7fb),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 52,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff5b2cff),
                disabledBackgroundColor: const Color(0xffc9bfff),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              onPressed: andereAktionLaeuft ? null : nachrichtSenden,
              child: wirdGesendet
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
