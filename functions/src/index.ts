import * as v1 from 'firebase-functions/v1';



export const newsku = v1.firestore.document('news/{newsId}').onCreate((snap, context) => {
  const newValue = snap.data();
  console.log('new sku', newValue);
  return null;
});
```