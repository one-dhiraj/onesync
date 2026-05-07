const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNotificationToDevices = onCall(async (request) => {
  const userId = request.auth?.uid;

  if (!userId) {
    throw new HttpsError("unauthenticated", "User must be logged in");
  }

  const { app, title, text, senderToken } = request.data;

  // Only fetch devices that can receive
  const snapshot = await admin
    .firestore()
    .collection("users")
    .doc(userId)
    .collection("devices")
    .where("canReceive", "==", true)
    .get();

  // Faster token extraction
  const tokens = snapshot.docs
    .map((doc) => doc.data().token)
    .filter((t) => t && t !== senderToken);

  if (tokens.length === 0) {
    return { success: false };
  }

  const message = {
    notification: {
      title: `${app}: ${title}`,
      body: text,
    },
    data: {
      title: `${app}: ${title}`,
      body: text,
    },
  };

  // Send in chunks (FCM limit = 500 tokens)
  const chunkSize = 500;
  const chunks = [];

  for (let i = 0; i < tokens.length; i += chunkSize) {
    chunks.push(tokens.slice(i, i + chunkSize));
  }

  // ⚡ Parallel sending
  await Promise.all(
    chunks.map((chunk) =>
      admin.messaging().sendEachForMulticast({
        ...message,
        tokens: chunk,
      })
    )
  );

  return { success: true };
});