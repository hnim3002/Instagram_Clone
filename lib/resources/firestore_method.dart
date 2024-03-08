import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clon/models/comment_post.dart';
import 'package:instagram_clon/resources/storage_method.dart';
import 'package:instagram_clon/utils/const.dart';
import 'package:uuid/uuid.dart';

import '../models/post.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost({
    required String caption,
    required String username,
    required Uint8List file,
    required String uid,
    required String userPhotoUrl,
    required String postId,
  }) async {
    String res = "Some error occurred";
    try {
      String postPhotoUrl =
          await StorageMethods().uploadImageToStorage("post", file, true);

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

  Future<void> updateUserImg(String uid, Uint8List file) async {
    try {
      String postPhotoUrl = await StorageMethods().uploadImageToStorage("avatar", file, false);

      await _firestore.collection(kKeyCollectionUsers).doc(uid).update({
        kKeyUserPhoto: postPhotoUrl,
      });

    } catch (e) {
      print(e.toString());
    }
  }


  Future<void> updateUserPost(String postId, String uid, bool addPost) async {
    try {
      if (addPost) {
        await _firestore.collection(kKeyCollectionUsers).doc(uid).update({
          kKeyUserPost: FieldValue.arrayUnion([postId]),
        });
      } else {
        await _firestore.collection(kKeyCollectionUsers).doc(uid).update({
          kKeyUserPost: FieldValue.arrayRemove([postId]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateLikePost(String postId, String uid, bool isLike) async {
    try {
      if (isLike) {
        await _firestore.collection(kKeyCollectionPosts).doc(postId).update({
          kKeyLike: FieldValue.arrayUnion([uid]),
        });
        await _firestore.collection(kKeyCollectionUsers).doc(uid).update({
          kKeyLike: FieldValue.arrayUnion([postId]),
        });
      } else {
        await _firestore.collection(kKeyCollectionPosts).doc(postId).update({
          kKeyLike: FieldValue.arrayRemove([uid]),
        });
        await _firestore.collection(kKeyCollectionUsers).doc(uid).update({
          kKeyLike: FieldValue.arrayRemove([postId]),
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

  Future<void> updateUserFollowing(
      String uid, bool isFollowing, String uidFollowing) async {
    try {
      if (isFollowing) {
        await _firestore.collection(kKeyCollectionUsers).doc(uid).update({
          kKeyUserFollowing: FieldValue.arrayUnion([uidFollowing]),
        });
        await _firestore
            .collection(kKeyCollectionUsers)
            .doc(uidFollowing)
            .update({
          kKeyUserFollowers: FieldValue.arrayUnion([uid]),
        });
      } else {
        await _firestore.collection(kKeyCollectionUsers).doc(uid).update({
          kKeyUserFollowing: FieldValue.arrayRemove([uidFollowing]),
        });
        await _firestore
            .collection(kKeyCollectionUsers)
            .doc(uidFollowing)
            .update({
          kKeyUserFollowers: FieldValue.arrayRemove([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateUserFollowers(
      String uid, bool isFollowing, String uidFollowers) async {
    try {
      if (isFollowing) {
        await _firestore.collection(kKeyCollectionUsers).doc(uid).update({
          kKeyUserFollowers: FieldValue.arrayUnion([uidFollowers]),
        });
        await _firestore
            .collection(kKeyCollectionUsers)
            .doc(uidFollowers)
            .update({
          kKeyUserFollowing: FieldValue.arrayUnion([uid]),
        });
      } else {
        await _firestore.collection(kKeyCollectionUsers).doc(uid).update({
          kKeyUserFollowers: FieldValue.arrayRemove([uidFollowers]),
        });
        await _firestore
            .collection(kKeyCollectionUsers)
            .doc(uidFollowers)
            .update({
          kKeyUserFollowing: FieldValue.arrayRemove([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateUserInfo(String uid, String data, String value) async {
    try {
      switch(data) {
        case 'Name':
          await _firestore.collection(kKeyCollectionUsers).doc(uid).update({
            kKeyFullName: value,
          });
          break;
        case 'Username':
          await _firestore.collection(kKeyCollectionUsers).doc(uid).update({
            kKeyUserName: value,
          });
          break;
        case 'Bio':
          await _firestore.collection(kKeyCollectionUsers).doc(uid).update({
            kKeyUserBio: value,
          });
          break;
        case 'Email':
          break;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<bool> checkUsernameExist(String username) async {
    try {
      QuerySnapshot usersSnapshot = await _firestore
          .collection(kKeyCollectionUsers)
          .where(kKeyUserName, isEqualTo: username)
          .get();

      return usersSnapshot.docs.isNotEmpty;
    } catch (e) {
      print(e.toString());
    }
    return false;
  }

  Future<String> uploadPostComment({
    required String postId,
    required String uid,
    required String commentContent,
    required String collectionId,
  }) async {
    String error = "Some thing when wrong";
    try {
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

  Future<List<Map<String, dynamic>>> getPostsData() async {
    QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
        .collection(kKeyCollectionPosts)
        .orderBy(kKeyTimestamp, descending: true)
        .get();

    List<String> userIds =
        postsSnapshot.docs.map((doc) => doc[kKeyUsersId] as String).toList();

    if (userIds.isEmpty) return [];
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

      Map<String, dynamic> postData = postDoc.data() as Map<String, dynamic>;
      String? userId = postData[kKeyUsersId] as String?;
      Map<String, dynamic> userData = userDataMap[userId] ?? {};
      updatedCombinedData.add(
          {'post': postData, 'user': userData, 'comment': numberOfComments});
    }
    return updatedCombinedData;
  }

  Future<Map<String, dynamic>> updatePostData(String postId) async {
    Map<String, dynamic> postData = {};
    var docRef =
        await _firestore.collection(kKeyCollectionPosts).doc(postId).get();
    postData = docRef.data() as Map<String, dynamic>;

    String userId = postData[kKeyUsersId];
    Map<String, dynamic> userData = {};
    var usersSnapshot = await FirebaseFirestore.instance
        .collection(kKeyCollectionUsers)
        .doc(userId)
        .get();
    userData = usersSnapshot.data() as Map<String, dynamic>;

    int numberOfComments = 0;

    var comRef = await _firestore
        .collection(kKeyCollectionPosts)
        .doc(postId)
        .collection(kKeySubCollectionComment)
        .get();
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

  Future<List<Map<String, dynamic>>> initCommentData(
      String postId, List<int> reply) async {
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

    List<int> a = [];
    for (var doc in usersSnapshot.docs) {
      userDataMap[doc.id] = doc.data() as Map<String, dynamic>;
    }

    for (var postDoc in postsSnapshot.docs) {
      var commentsRef = _firestore
          .collection(kKeyCollectionPosts)
          .doc(postId)
          .collection(kKeySubCollectionComment)
          .where(kKeyParentId, isEqualTo: postDoc.id)
          .orderBy(kKeyTimestamp, descending: false);

      int numberOfReply = (await commentsRef.get()).size;
      a.add(numberOfReply);
      Map<String, dynamic> postData = postDoc.data() as Map<String, dynamic>;
      String? userId = postData[kKeySenderId] as String?;
      Map<String, dynamic> userData = userDataMap[userId] ?? {};

      updatedCombinedData.add({
        'post': postData,
        'user': userData,
      });
    }

    reply.addAll(a);

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

  Future<String> deletePost(String postId) async {
    String error = "Some thing when wrong";
    try {
      await _firestore.collection(kKeyCollectionPosts).doc(postId).delete();
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<List<String>> getUsersIdHaveNotFollow(List<dynamic> following, String uid) async {
    List<String> users = [];

    QuerySnapshot userSnapshot =
        await _firestore.collection(kKeyCollectionUsers).get();

    for (var userDoc in userSnapshot.docs) {
      var fieldValue = userDoc.get(kKeyUsersId);

      if (!following.contains(fieldValue) && fieldValue != uid) {
        users.add(fieldValue);
      }
    }

    return users;
  }

  Future<List<Map<String, dynamic>>> getPostUnique(List<dynamic> users) async {
    List<Map<String, dynamic>> posts = [];

    QuerySnapshot postSnapshot = await _firestore
        .collection(kKeyCollectionPosts)
        .orderBy(kKeyTimestamp, descending: true)
        .get();

    List<String> unique = []; // Change to List<String> for user IDs
    for (var postDoc in postSnapshot.docs) {
      String userId = postDoc.get(kKeyUsersId);
      if (users.contains(userId) && !unique.contains(userId)) {
        posts.add(postDoc.data() as Map<String, dynamic>);
        unique.add(userId);
      }
    }

    return posts;
  }

  Future<List<Map<String, dynamic>>> getUserPost(String uid) async {
    List<Map<String, dynamic>> posts = [];

    QuerySnapshot postSnapshot = await _firestore
        .collection(kKeyCollectionPosts)
        .orderBy(kKeyTimestamp, descending: true)
        .get();

    var usersSnapshot =
        await _firestore.collection(kKeyCollectionUsers).doc(uid).get();
    Map<String, dynamic> user = {};
    if (usersSnapshot.exists) {
      user = usersSnapshot.data()!;
    }
    for (var postDoc in postSnapshot.docs) {
      String userId = postDoc.get(kKeyUsersId);
      if (userId == uid) {
        posts.add(postDoc.data() as Map<String, dynamic>);
      }
    }

    return posts;
  }

  Future<List<Map<String, dynamic>>> getUserLikePost(List<dynamic> postIds) async {

    List<Map<String, dynamic>> posts = [];
    if(postIds.isEmpty) return [];

    QuerySnapshot postSnapshot = await _firestore
        .collection(kKeyCollectionPosts)
        .where(FieldPath.documentId, whereIn: postIds)
        .get();

    for (var postDoc in postSnapshot.docs) {

      posts.add(postDoc.data() as Map<String, dynamic>);

    }

    return posts;
  }

  Future<List<Map<String, dynamic>>> getUserSavePost(List<dynamic> postIds) async {

    List<Map<String, dynamic>> posts = [];

    print(postIds);

    if(postIds.isEmpty) return [];

    QuerySnapshot postSnapshot = await _firestore
        .collection(kKeyCollectionPosts)
        .where(FieldPath.documentId, whereIn: postIds)
        .get();

    for (var postDoc in postSnapshot.docs) {
      posts.add(postDoc.data() as Map<String, dynamic>);

    }
    return posts;
  }

  Future<List<Map<String, dynamic>>> getAPost(String postId) async {
    List<Map<String, dynamic>> posts = [];

    var postSnapshot =
        await _firestore.collection(kKeyCollectionPosts).doc(postId).get();

    Map<String, dynamic> postData = {};
    if (postSnapshot.exists) {
      postData = postSnapshot.data()!;
    }

    var usersSnapshot = await _firestore
        .collection(kKeyCollectionUsers)
        .doc(postData[kKeyUsersId])
        .get();
    Map<String, dynamic> user = {};
    if (usersSnapshot.exists) {
      user = usersSnapshot.data()!;
    }

    CollectionReference commentsRef = FirebaseFirestore.instance
        .collection(kKeyCollectionPosts)
        .doc(postId)
        .collection(kKeySubCollectionComment);

    int numberOfComments = (await commentsRef.get()).size;

    posts.add({'post': postData, 'user': user, 'comment': numberOfComments});

    return posts;
  }

  Future<List<Map<String, dynamic>>> getUserFollow(List<dynamic> followId) async {
    List<Map<String, dynamic>> userList = [];
    if(followId.isEmpty) return [];

    var usersSnapshot = await _firestore
        .collection(kKeyCollectionUsers)
        .where(FieldPath.documentId, whereIn: followId)
        .get();
    for(var user in usersSnapshot.docs) {
      userList.add(user.data());
    }

    return userList;
  }

  Future<Map<String, dynamic>> getAUser(String uid) async {
    Map<String, dynamic> userList = {};

    var usersSnapshot = await _firestore
        .collection(kKeyCollectionUsers)
        .doc(uid)
        .get();

    if(usersSnapshot.exists) {
      userList = usersSnapshot.data()!;
    }

    return userList;
  }


}
