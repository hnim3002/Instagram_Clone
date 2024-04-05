
import * as admin from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';
import * as functions from 'firebase-functions';
import { v4 as uuidv4 } from 'uuid';

admin.initializeApp();

const db = admin.firestore();


export const onCreatePost = functions.firestore
    .document('posts/{postId}')
    .onCreate(async (snapshot, context) => {
        const postData = snapshot.data();
        const usersRef = db.collection('users');
        const querySnapshot = await usersRef.where('uid', '==', postData.uid).get();
        querySnapshot.forEach(async (doc) => {
          const follower = doc.get('followers');
          const userName = doc.get('username');
          for(var i = 0; i < follower.length; i++) {
            const notificationsId: string = uuidv4();
            await db.doc(`users/${follower[i]}/notifications/${notificationsId}`)
              .set({
                notificationsId: notificationsId, 
                content: `${userName} just upload a new post`, 
                Timestamp: Timestamp.now()
              });
          }
        });
    });

