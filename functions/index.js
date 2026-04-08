const { onCall } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNotificationToDevices = onCall(async (request) => {
  const userId = request.auth?.uid;

  if (!userId) {
    throw new Error("User must be logged in");
  }

  const { app, title, text, senderToken } = request.data;

  const snapshot = await admin
    .firestore()
    .collection("users")
    .doc(userId)
    .collection("devices")
    .get();

  const tokens = [];

  snapshot.forEach((doc) => {
    const t = doc.data().token;
    if (t /*&& t !== senderToken*/) {
      tokens.push(t);
    }
  });

  if (tokens.length === 0) return { success: false };

  const message = {
    notification: {
      title: `${app}: ${title}`,
      body: text,
    },
    data: {
      title: `${app}: ${title}`,
      body: text,
    },
    tokens: tokens,
  };

  await admin.messaging().sendEachForMulticast(message);

  return { success: true };
});