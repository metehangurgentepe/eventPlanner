/* eslint-enable no-unused-vars */


const functions = require("firebase-functions");
// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const { logger } = require("firebase-functions");
const { onRequest } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

// The Firebase Admin SDK to access Firestore.
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");


initializeApp();
const db = getFirestore();
const admin = require('firebase-admin');
const { Message } = require("firebase-functions/v1/pubsub");
const { user } = require("firebase-functions/v1/auth");


// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started

// Take the text parameter passed to this HTTP endpoint and insert it into
// Firestore under the path /messages/:documentId/original

exports.sendNotifications = functions.firestore.document('Events/{id}').onCreate(
  async (snapshot) => {
    // Notification details.
    const message = {
      data: {
        // You can add custom data here
        title: 'Notification Title',
        body: 'Notification Body',
        click_action: ''
      },
      token: 'dgEus5f9000Ss0PyiuMqiZ:APA91bEOObJ9wyNGmQ2Uh3f8YCML4LmIyzzai0ga9VEm5xTkaTZTY81v8a2oToju3W7LH6EiF0MYKMmzzBrJMLwITzsfGmu3pE4NNMlFI8gUf3QwJLYOKwutr9B0cLHloPVnGD55jhgK', // The device token of the user you want to send the notification to
    };
    // Get the list of device tokens.
    /*   const allTokens = await admin.firestore().collection('fcmTokens').get();
       const tokens = [];
       allTokens.forEach((tokenDoc) => {
         tokens.push(tokenDoc.tokenId);
       });*/
    try {
      const response = await admin.messaging().send(message)
      functions.logger.log('Bildirim yollandı' + response + snapshot.data().eventName);
    } catch (error) {
      console.error('Error sending notification:', error);
      return res.status(500).send('Error sending notification');
    }
    // Send notifications to all tokens.
    functions.logger.log('Notifications have been sent and tokens cleaned up.');
  });


exports.requestNotificationsToReceiver = functions.firestore.document("Request/{id}").onCreate(async (snapshot) => {
  const senderUser = snapshot.data().senderUser;
  const sender = (await db.collection("Users").doc(senderUser).get()).data();
  const receiverUser = snapshot.data().receiverUser;
  const user = (await db.collection("Users").doc(receiverUser).get()).data();
  const eventId = snapshot.data().eventId;
  const eventDoc = (await db.collection("Events").doc(eventId).get()).data();
  // const event = await eventDoc.get();
  const message = {
    notification: {
      title: 'Eventier',
      body: `${sender.fullname} adlı kullanıcı ${eventDoc.eventName} etkinliği için istek gönderdi. `
    },
    token: `${user.fcmToken}`
  }
  try {
    const response = await admin.messaging().send(message)
    functions.logger.log('Bildirim yollandı' + response + snapshot.data().eventId);
  } catch (error) {
    console.error('Error sending notification:', error);
    return res.status(500).send('Error sending notification');
  }
});


exports.sendNotificationUpdateEvent = functions.firestore.document("privateEvents/{id}").onUpdate(async (snapshot) => {
  const users = snapshot.after.data().users;
  const messages = [];

  const leadUser = snapshot.after.data().eventLeadUser;
  for (let i = 0; i < users.length; i++) {
    const currentUser = (await db.collection("Users").doc(users[i]).get()).data();

    if (leadUser != users[i]){
      const eventStartTime = new Date(snapshot.after.data().eventStartTime);
      const formattedDate = eventStartTime.toLocaleDateString('tr-TR', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: 'numeric',
        minute: 'numeric',
        second: 'numeric',
        timeZoneName: 'short'
      });

      const message = {
        notification: {
          title: 'Eventier',
          body: `${snapshot.after.data().eventName} adlı ${formattedDate} tarihindeki etkinlik güncellenmiştir.`
        },
        token: `${currentUser.fcmToken}`
      }
      messages.push(message);
    }
  }
  functions.logger.log(messages);
  try {
    const response = await admin.messaging().sendEach(messages);
    functions.logger.log('Bildirim yollandı' + response + snapshot.data().id);
  } catch (error) {
    console.error('Error sending notification:', error);
    return res.status(500).send('Error sending notification');
  }
});

exports.updatePublicEvent = functions.firestore.document('publicEvents/{id}').onUpdate(async (change,context) => {
    const newValue = change.after.data();
    const previousValue = change.before.data();

     // Örnek: publicEvents koleksiyonundaki bir belge güncellendiğinde events koleksiyonunu güncelle
     if (newValue && previousValue) {
      const eventId = context.params.id;
      const updatedData = newValue;

      // events koleksiyonunu güncelleme işlemini gerçekleştirin
      const eventsCollection = admin.firestore().collection('Events');
      await eventsCollection.doc(eventId).update(updatedData);
  }

  return null;
});

exports.updateWhenDeletedEvent = functions.firestore.document('Events/{id}').onDelete(async (snap, context) => {
  const eventId = context.params.id;

  // Silinen belgenin verilerini al
  const eventData = snap.data();

  // Silinen belgenin türüne göre hangi koleksiyondan silineceğini belirle
  const collectionName = eventData.publicEvent ? 'publicEvents' : 'privateEvents';

  // Koleksiyonu seç ve belgeyi sil
  const eventsCollection = admin.firestore().collection(collectionName);
  await eventsCollection.doc(eventId).delete();

  return null;
});

exports.deletePublicEventsWhenExpired = functions.firestore.document('publicEvents/{id}').onWrite(async (snap, context) => {
  const deletedEventData = snap.data(); // Silinen dokümanın verileri

  // Silinen dokümanın oluşturulma tarihini al
  const creationTimestamp = new Date(deletedEventData.eventStartTime); // Burada "timestamp" alanını kullanın veya belirlediğiniz alana göre ayarlayın
 

  // Şu anın zaman damgasını al
  const now = admin.firestore.Timestamp.now();

  // Etkinliğin oluşturulmasından şu anki tarih arasındaki farkı hesapla
  const timeDifference = now.toMillis() - creationTimestamp.toMillis();

  // Eğer fark 10 günden fazlaysa, dokümanı sil
  if (timeDifference > 10 * 24 * 60 * 60 * 1000) { // 10 günü milisaniye cinsinden hesapla
    try {
      await firestore.collection('publicEvents').doc(context.params.id).delete();
      console.log(`Etkinlik (ID: ${context.params.id}) 10 günden fazla süredir silindi.`);
    } catch (error) {
      console.error('Etkinlik silme hatası:', error);
    }
  }
});


exports.updatePrivateEvent = functions.firestore.document('privateEvents/{id}').onUpdate(async (change,context) => {
  const newValue = change.after.data();
  const previousValue = change.before.data();

   // Örnek: publicEvents koleksiyonundaki bir belge güncellendiğinde events koleksiyonunu güncelle
   if (newValue && previousValue) {
    const eventId = context.params.id;
    const updatedData = newValue;

    // events koleksiyonunu güncelleme işlemini gerçekleştirin
    const eventsCollection = admin.firestore().collection('Events');
    await eventsCollection.doc(eventId).update(updatedData);
}

return null;
});

exports.eventReminder = functions.firestore
  .document('Events/{id}')
  .onUpdate(async (change, context) => {
    const eventData = change.after.data();
    const users = eventData.users;

    // Etkinliğin tarihi yaklaşıyorsa (örneğin, 1 saat veya 1 gün önce), bildirim gönderin.
    // Tarih karşılaştırmasını burada yapabilirsiniz.
    const eventStartTime = new Date(eventData.eventStartTime);
    const fcmToken = [];
    const notificationTime = new Date(eventStartTime.getTime() - 30 * 60000); // 30 dakika önce

    const date = admin.firestore.Timestamp.fromDate(notificationTime);

    if (eventStartTime < currentDate && eventStartTime - currentDate <= 30 * 60000) {

      // get fcmTokens
      users.forEach(async id => {
        const user = (await db.collection("Users").doc(id).get()).data();
        functions.logger.log(user.fcmToken);
        fcmToken.push(user.fcmToken);

      });


      // schedule events notification

      fcmToken.forEach(token => {
        const message = {
          notification: {
            title: 'Etkinlik Hatırlatma',
            body: `Etkinlik ${eventData.eventName} yaklaşıyor!`,
          },
          token: token,
        };

        admin.messaging().send(message)
          .then(response => {
            console.log('Bildirim gönderildi:', response);
          })
          .catch(error => {
            console.error('Bildirim gönderme hatası:', error);
          });
      });
    }
    return null;
  });
  /* eslint-disable no-unused-vars */
