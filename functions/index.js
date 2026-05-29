const admin = require("firebase-admin");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

admin.initializeApp();

exports.sendChatPushNotification = onDocumentCreated(
  "benachrichtigungen/{id}",
  async (event) => {

    const data = event.data.data();

    const userId = data.userId;

    if (!userId) return;

    const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .get();

    if (!userDoc.exists) return;

    const token = userDoc.data().fcmToken;

    if (!token) return;

    await admin.messaging().send({
      token: token,
      notification: {
        title: data.titel || "Neue Nachricht",
        body: data.text || "",
      },
    });

    console.log("Push gesendet");
  }
);