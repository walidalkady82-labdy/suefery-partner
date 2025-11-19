/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();


// TRIGGER: When a NEW Order is created in Firestore
exports.onNewOrder = functions.firestore
  .document('orders/{orderId}')
  .onCreate(async (snap, context) => {
    const orderData = snap.data();
    const storeId = orderData.storeId;

    if (!storeId) return;

    // 1. Find the Partner(s) who own this store
    // We query the 'users' collection for anyone with this storeId
    const partnersSnapshot = await admin.firestore()
      .collection('users')
      .where('storeId', '==', storeId)
      .where('userType', '==', 'partner')
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
        body: `Order #${context.params.orderId.substring(0, 4)} is waiting for a quote.`,
      },
      data: {
        orderId: context.params.orderId,
        type: 'new_order'
      }
    };

    // 3. Send to all partners of that store
    return admin.messaging().sendToDevice(tokens, payload);
  });

// TRIGGER: When Order Status Changes (e.g. Partner Accepted)
exports.onOrderStatusChange = functions.firestore
  .document('orders/{orderId}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const oldData = change.before.data();

    // Only notify if status changed
    if (newData.status === oldData.status) return;

    const customerId = newData.userId;
    
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
        orderId: context.params.orderId,
        type: 'order_update'
      }
    };

    return admin.messaging().sendToDevice(fcmToken, payload);
  });