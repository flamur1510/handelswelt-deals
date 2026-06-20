const admin = require("firebase-admin");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");

admin.initializeApp();

const INSERAT_LAUFZEIT_TAGE = 30;

// Markiert Inserate, deren 30-tägige Laufzeit abgelaufen ist, täglich als "abgelaufen".
exports.inserateAblaufenLassen = onSchedule(
  { schedule: "every day 03:00", timeZone: "Europe/Vienna", region: "europe-west1" },
  async () => {
    const grenze = admin.firestore.Timestamp.fromMillis(
      Date.now() - INSERAT_LAUFZEIT_TAGE * 24 * 60 * 60 * 1000
    );

    const snapshot = await admin
      .firestore()
      .collection("inserate")
      .where("status", "==", "aktiv")
      .where("erstelltAm", "<=", grenze)
      .get();

    if (snapshot.empty) {
      console.log("Keine abgelaufenen Inserate gefunden.");
      return;
    }

    const batch = admin.firestore().batch();
    snapshot.docs.forEach((doc) => {
      batch.update(doc.ref, { status: "abgelaufen" });
    });
    await batch.commit();

    console.log(`${snapshot.size} Inserat(e) als abgelaufen markiert.`);
  }
);

exports.sendChatPushNotification = onDocumentCreated(
  "chats/{chatId}/nachrichten/{nachrichtId}",
  async (event) => {
    const nachricht = event.data.data();
    const chatId = event.params.chatId;

    const senderId = (nachricht.senderId || "").toString();
    const typ = (nachricht.typ || "text").toString();
    const text = (nachricht.text || "").toString().trim();

    // Benachrichtigungstext je nach Typ
    let vorschau;
    if (typ === "bild") vorschau = "📷 Bild";
    else if (typ === "audio") vorschau = "🎤 Sprachnachricht";
    else if (typ === "standort") vorschau = "📍 Standort";
    else if (typ === "datei") vorschau = "📎 Datei";
    else vorschau = text.length > 80 ? text.substring(0, 80) + "…" : text || "Neue Nachricht";

    // Chat-Dokument lesen um Empfänger zu bestimmen
    const chatDoc = await admin.firestore().collection("chats").doc(chatId).get();
    if (!chatDoc.exists) return;

    const chatDaten = chatDoc.data();
    const teilnehmer = chatDaten.teilnehmer || [];
    const produktTitel = (chatDaten.produktTitel || "Chat").toString();
    const senderEmail = (nachricht.senderEmail || chatDaten.kaeuferEmail || "").toString();

    // Absender-Name kürzen (nur Teil vor @)
    const absenderAnzeige = senderEmail.includes("@")
      ? senderEmail.split("@")[0]
      : senderEmail || "Jemand";

    // Alle Empfänger außer dem Absender benachrichtigen
    const empfaenger = teilnehmer.filter((id) => id !== senderId);

    const promises = empfaenger.map(async (empfaengerId) => {
      if (!empfaengerId) return;

      const userDoc = await admin.firestore().collection("users").doc(empfaengerId).get();
      if (!userDoc.exists) return;

      const userData = userDoc.data();
      const tokens = [];

      // Primärer Token
      const fcmToken = (userData.fcmToken || "").toString().trim();
      if (fcmToken) tokens.push(fcmToken);

      // Alle gespeicherten Tokens (multi-device)
      const fcmTokens = userData.fcmTokens || [];
      for (const t of fcmTokens) {
        const tok = (t || "").toString().trim();
        if (tok && !tokens.includes(tok)) tokens.push(tok);
      }

      if (tokens.length === 0) return;

      const nachrichtenPromises = tokens.map((token) =>
        admin.messaging().send({
          token,
          notification: {
            title: `${absenderAnzeige} – ${produktTitel}`,
            body: vorschau,
          },
          android: {
            notification: {
              channelId: "chat_nachrichten",
              priority: "high",
              sound: "default",
            },
          },
          apns: {
            payload: {
              aps: {
                alert: {
                  title: `${absenderAnzeige} – ${produktTitel}`,
                  body: vorschau,
                },
                sound: "default",
                badge: 1,
              },
            },
          },
          data: {
            chatId,
            produktTitel,
            senderId,
          },
        }).catch((err) => {
          // Ungültige Tokens still ignorieren
          console.warn("Token ungültig:", token, err.message);
        })
      );

      await Promise.all(nachrichtenPromises);
      console.log(`Push gesendet an ${empfaengerId} (${tokens.length} Token(s))`);
    });

    await Promise.all(promises);
  }
);
