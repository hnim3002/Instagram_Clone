
import * as admin from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';
import * as functions from 'firebase-functions';
import { v4 as uuidv4 } from 'uuid';

admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();


export const onPostCreate = functions.firestore
  .document('posts/{postId}')
  .onCreate(async (snapshot, context) => {
    const postData = snapshot.data();
    const usersRef = db.collection('users');
    const querySnapshot = await usersRef.where('uid', '==', postData.uid).get();
    querySnapshot.forEach(async (doc) => {
      const follower = doc.get('followers');
      const userName = doc.get('username');
      for (var i = 0; i < follower.length; i++) {
        const notificationsId: string = uuidv4();
        await db.doc(`users/${follower[i]}/notifications/${notificationsId}`)
          .set({
            senderId: postData.uid,
            notificationsId: notificationsId,
            notificationType: 'post',
            postId: postData.postId,
            notificationContent: `${userName} just upload a new post`,
            Timestamp: Timestamp.now()
          });
      }
    });
  });

export const onNotificationCreate = functions.firestore
  .document('users/{userId}/notifications/{notificationsId}')
  .onCreate(async (snapshot, context) => {
    const userId = context.params.userId;
    const content = snapshot.get('content');
    const postId = snapshot.get('postId');
    const type = snapshot.get('type');
    const tokenSnapshot = await db.collection('users').doc(userId).get();
    const token = tokenSnapshot.data()?.fcmToken;
    

    let message: admin.messaging.Message;
    switch (type) {
      case 'post':
        message = {
          token: token,
          notification: {
            title: 'New Post',
            body: content,
          },
          data: {
            postId: postId,
            uid: userId,
            type: type,
          },
        };
        fcm.send(message);
        break;
      case 'follow':
        message = {
          token: token,
          notification: {
            title: 'New Follower',
            body: content,
          },
          data: {
            uid: userId,
           
            type: type,
          },
        };
        fcm.send(message);
        break;
    }


  });


