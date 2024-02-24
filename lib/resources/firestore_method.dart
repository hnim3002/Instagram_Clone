import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clon/models/comment_post.dart';
import 'package:instagram_clon/resources/storage_method.dart';
import 'package:instagram_clon/utils/const.dart';
import 'package:uuid/uuid.dart';

import '../models/post.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(
      {required String caption,
      required String username,
      required Uint8List file,
      required String uid,
      required String userPhotoUrl}) async {
    String res = "Some error occurred";
    try {
      String postPhotoUrl =
          await StorageMethods().uploadImageToStorage("post", file, true);

      String postId = const Uuid().v1();

      Post post = Post(
          postId: postId,
          uid: uid,
          postPhotoUrl: postPhotoUrl,
          timestamp: Timestamp.fromDate(DateTime.now()),
          caption: caption,
          like: []);

      _firestore
          .collection(kKeyCollectionPosts)
          .doc(postId)
          .set(post.toFirestore());
      res = "Success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> updateLikePost(String postId, String uid, bool isLike) async {
    try {
      if (isLike) {
        await _firestore.collection(kKeyCollectionPosts).doc(postId).update({
          kKeyLike: FieldValue.arrayUnion([uid]),
        });
      } else {
        await _firestore.collection(kKeyCollectionPosts).doc(postId).update({
          kKeyLike: FieldValue.arrayRemove([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateLikeComment(
      String postId, String commentId, String uid, bool isLike) async {
    try {
      if (isLike) {
        await _firestore
            .collection(kKeyCollectionPosts)
            .doc(postId)
            .collection(kKeySubCollectionComment)
            .doc(commentId)
            .update({
          kKeyLike: FieldValue.arrayUnion([uid]),
        });
      } else {
        await _firestore
            .collection(kKeyCollectionPosts)
            .doc(postId)
            .collection(kKeySubCollectionComment)
            .doc(commentId)
            .update({
          kKeyLike: FieldValue.arrayRemove([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> uploadPostComment({
    required String postId,
    required String uid,
    required String commentContent,
  }) async {
    String error = "Some thing when wrong";
    try {
      String collectionId = const Uuid().v1();
      CommentsPost commentsPost = CommentsPost(
        postId: postId,
        commentContent: commentContent,
        timestamp: Timestamp.fromDate(DateTime.now()),
        like: [],
        commentsId: collectionId,
        senderId: uid,
        parentId: '',
        receiverId: '',
      );

      await _firestore
          .collection(kKeyCollectionPosts)
          .doc(postId)
          .collection(kKeySubCollectionComment)
          .doc(collectionId)
          .set(commentsPost.toFirestore());
      error = 'Success';
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String> uploadReplyComment(
      {required String postId,
      required String uid,
      required String commentContent,
      required String parentId,
      required String receiverId}) async {
    String error = "Some thing when wrong";
    try {
      String collectionId = const Uuid().v1();
      CommentsPost commentsPost = CommentsPost(
        postId: postId,
        commentContent: commentContent,
        timestamp: Timestamp.fromDate(DateTime.now()),
        like: [],
        commentsId: collectionId,
        senderId: uid,
        parentId: parentId,
        receiverId: receiverId,
      );

      await _firestore
          .collection(kKeyCollectionPosts)
          .doc(postId)
          .collection(kKeySubCollectionComment)
          .doc(collectionId)
          .set(commentsPost.toFirestore());
      error = 'Success';
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<List<int>> getNumberOfComment() async {
    QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
        .collection(kKeyCollectionPosts)
        .orderBy(kKeyTimestamp, descending: true)
        .get();

    List<int> comment = [];
    for (var postDoc in postsSnapshot.docs) {
      CollectionReference commentsRef = FirebaseFirestore.instance
          .collection(kKeyCollectionPosts)
          .doc(postDoc.id)
          .collection(kKeySubCollectionComment);

      int numberOfComments = (await commentsRef.get()).size;
      comment.add(numberOfComments);
    }
    return comment;
  }

  Future<List<List<dynamic>>> getNumberOfLike() async {
    QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
        .collection(kKeyCollectionPosts)
        .orderBy(kKeyTimestamp, descending: true)
        .get();

    List<List<dynamic>> like = [];
    for (var postDoc in postsSnapshot.docs) {
      Map<String, dynamic> postData = postDoc.data() as Map<String, dynamic>;
      like.add(postData[kKeyLike]);
    }
    return like;
  }

  Future<List<Map<String, dynamic>>> getPostsData(List<List<dynamic>> like, List<int> comment) async {
    like.clear();
    comment.clear();
    QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
        .collection(kKeyCollectionPosts)
        .orderBy(kKeyTimestamp, descending: true)
        .get();

    List<String> userIds =
        postsSnapshot.docs.map((doc) => doc[kKeyUsersId] as String).toList();

    // Perform a query to fetch user data based on userIds
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection(kKeyCollectionUsers)
        .where(FieldPath.documentId, whereIn: userIds)
        .get();

    // Create a map to store user data
    Map<String, Map<String, dynamic>> userDataMap = {};
    for (var doc in usersSnapshot.docs) {
      userDataMap[doc.id] = doc.data() as Map<String, dynamic>;
    }

    List<Map<String, dynamic>> updatedCombinedData = [];
    for (var postDoc in postsSnapshot.docs) {
      CollectionReference commentsRef = FirebaseFirestore.instance
          .collection(kKeyCollectionPosts)
          .doc(postDoc.id)
          .collection(kKeySubCollectionComment);

      int numberOfComments = (await commentsRef.get()).size;
      comment.add(numberOfComments);

      Map<String, dynamic> postData = postDoc.data() as Map<String, dynamic>;
      like.add(postData[kKeyLike]);
      String? userId = postData[kKeyUsersId] as String?;
      Map<String, dynamic> userData = userDataMap[userId] ?? {};
      updatedCombinedData.add(
          {'post': postData, 'user': userData, 'comment': numberOfComments});
    }
    return updatedCombinedData;
  }

  Future<Map<String, dynamic>> updatePostData(String postId) async {
    Map<String, dynamic> postData = {};
    var docRef =  await _firestore.collection(kKeyCollectionPosts).doc(postId).get();
    postData = docRef.data() as Map<String, dynamic>;

    String userId = postData[kKeyUsersId];
    Map<String, dynamic> userData = {};
    var usersSnapshot = await FirebaseFirestore.instance.collection(kKeyCollectionUsers).doc(userId).get();
    userData =  usersSnapshot.data() as Map<String, dynamic>;

    int numberOfComments = 0;

    var comRef = await _firestore.collection(kKeyCollectionPosts).doc(postId).collection(kKeySubCollectionComment).get();
    numberOfComments = comRef.size;

    Map<String, dynamic> updatedCombinedData = {
      "post": postData,
      "user": userData,
      "comment": numberOfComments
    };

    return updatedCombinedData;
  }

  Future<List<Map<String, dynamic>>> getCommentData(String postId) async {
    List<Map<String, dynamic>> updatedCombinedData = [];
    QuerySnapshot postsSnapshot = await _firestore
        .collection(kKeyCollectionPosts)
        .doc(postId)
        .collection(kKeySubCollectionComment)
        .where(kKeyParentId, isEqualTo: "")
        .orderBy(kKeyTimestamp, descending: false)
        .get();

    List<String> userIds =
        postsSnapshot.docs.map((doc) => doc[kKeySenderId] as String).toList();

    if (userIds.isEmpty) {
      return [];
    }

    // Perform a query to fetch user data based on userIds
    QuerySnapshot usersSnapshot = await _firestore
        .collection(kKeyCollectionUsers)
        .where(FieldPath.documentId, whereIn: userIds)
        .get();

    // Create a map to store user data
    Map<String, Map<String, dynamic>> userDataMap = {};
    for (var doc in usersSnapshot.docs) {
      userDataMap[doc.id] = doc.data() as Map<String, dynamic>;
    }

    for (var postDoc in postsSnapshot.docs) {
      Map<String, dynamic> postData = postDoc.data() as Map<String, dynamic>;
      String? userId = postData[kKeySenderId] as String?;
      Map<String, dynamic> userData = userDataMap[userId] ?? {};

      updatedCombinedData.add({
        'post': postData,
        'user': userData,
      });
    }

    return updatedCombinedData;
  }

  Future<List<Map<String, dynamic>>> getReplyData(
      String postId, String commentId) async {
    List<Map<String, dynamic>> updatedCombinedData = [];
    QuerySnapshot postsSnapshot = await _firestore
        .collection(kKeyCollectionPosts)
        .doc(postId)
        .collection(kKeySubCollectionComment)
        .where(kKeyParentId, isEqualTo: commentId)
        .orderBy(kKeyTimestamp, descending: false)
        .get();


    List<String> userIds =
        postsSnapshot.docs.map((doc) => doc[kKeySenderId] as String).toList();

    if (userIds.isEmpty) {
      return [];
    }

    QuerySnapshot usersSnapshot = await _firestore
        .collection(kKeyCollectionUsers)
        .where(FieldPath.documentId, whereIn: userIds)
        .get();

    // Create a map to store user data
    Map<String, Map<String, dynamic>> userDataMap = {};
    for (var doc in usersSnapshot.docs) {
      userDataMap[doc.id] = doc.data() as Map<String, dynamic>;
    }

    for (var postDoc in postsSnapshot.docs) {
      Map<String, dynamic> postData = postDoc.data() as Map<String, dynamic>;
      String? userId = postData[kKeySenderId] as String?;
      Map<String, dynamic> userData = userDataMap[userId] ?? {};

      updatedCombinedData.add({
        'post': postData,
        'user': userData,
      });
    }

    return updatedCombinedData;
  }

  Future<List<int>> getNumberOfReply(String postId) async {
    List<Map<String, dynamic>> updatedCombinedData = [];
    QuerySnapshot postsSnapshot = await _firestore
        .collection(kKeyCollectionPosts)
        .doc(postId)
        .collection(kKeySubCollectionComment)
        .where(kKeyParentId, isEqualTo: "")
        .orderBy(kKeyTimestamp, descending: false)
        .get();

    List<int> reply = [];
    for (var postDoc in postsSnapshot.docs) {
      var commentsRef = _firestore
          .collection(kKeyCollectionPosts)
          .doc(postId)
          .collection(kKeySubCollectionComment)
          .where(kKeyParentId, isEqualTo: postDoc.id)
          .orderBy(kKeyTimestamp, descending: false);

      int numberOfReply = (await commentsRef.get()).size;
      reply.add(numberOfReply);
    }

    return reply;
  }
}
