/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onDocumentCreated, onDocumentUpdated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
admin.initializeApp();


// TRIGGER: When a NEW Order is created in Firestore
exports.onNewOrder = onDocumentCreated("orders/{orderId}", async (event) => {
    const snap = event.data;
    if (!snap) {
        console.log("No data associated with the event");
        return;
    }
    const orderData = snap.data();
    const storeId = orderData.storeId;
    if (!storeId) return;

    // 1. Find the Partner(s) who own this store
    // We query the 'users' collection for anyone with this storeId
    const partnersSnapshot = await admin.firestore()
      .collection('users')
      .where('storeId', '==', storeId)
      .where('role', '==', 'partner')
      .get();

    const tokens = [];
    partnersSnapshot.forEach(doc => {
      const partner = doc.data();
      if (partner.fcmToken) {
        tokens.push(partner.fcmToken);
      }
    });

    if (tokens.length === 0) return;

    // 2. Construct Payload
    const payload = {
      notification: {
        title: 'New Order Received! 🔔',
        body: `Order #${event.params.id.substring(0, 4)} is waiting for a quote.`,
      },
      data: {
        orderId: event.params.id,
        type: 'new_order'
      }
    };

    // 3. Send to all partners of that store
    return admin.messaging().send(tokens, payload);
  });

// TRIGGER: When Order Status Changes (e.g. Partner Accepted)
exports.onOrderStatusChange = onDocumentUpdated("orders/{orderId}", async (event) => {
    const change = event.data;
    if (!change) {
        console.log("No data associated with the event");
        return;
    }
    const newData = change.after.data();
    const oldData = change.before.data();

    // Only notify if status changed
    // eslint-disable-next-line no-useless-return
    if (newData.status === oldData.status) return;

    const customerId = newData.id;
    
    // 1. Get Customer Token
    const userDoc = await admin.firestore().collection('users').doc(customerId).get();
    const fcmToken = userDoc.data().fcmToken;

    if (!fcmToken) return;

    // 2. Send Update
    const payload = {
      notification: {
        title: 'Order Update 📦',
        body: `Your order is now: ${newData.status}`,
      },
      data: {
        orderId: event.params.id,
        type: 'order_update'
      }
    };

    return admin.messaging().send(fcmToken, payload);
  });