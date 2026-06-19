const admin = require("firebase-admin");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

admin.initializeApp();

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
