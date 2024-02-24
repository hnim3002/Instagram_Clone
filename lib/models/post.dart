
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/const.dart';

class Post {
  final String? postId;
  final String? uid;
  // final String? username;
  // final String? userPhotoUrl;
  final String? postPhotoUrl;
  final Timestamp timestamp;
  final String? caption;
  final List? like;

  const Post({
    required this.postId,
    required this.uid,
    // required this.username,
    // required this.userPhotoUrl,
    required this.postPhotoUrl,
    required this.timestamp,
    required this.caption,
    required this.like,
  });

  Map<String, dynamic> toJson() => {
    kKeyPostId: postId,
    kKeyUsersId: uid,
    // kKeyUserName: username,
    // kKeyUserPhoto: userPhotoUrl,
    kKeyPostPhoto: postPhotoUrl,
    kKeyTimestamp: timestamp,
    kKeyCaption: caption,
    kKeyLike: like
  };

  factory Post.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Post(
        postId: data?[kKeyPostId],
        uid: data?[kKeyUsersId],
        // username: data?[kKeyUserName],
        // userPhotoUrl: data?[kKeyUserPhoto],
        postPhotoUrl: data?[kKeyPostPhoto],
        timestamp: data?[kKeyTimestamp],
        caption: data?[kKeyCaption],
        like:  data?[kKeyLike] is Iterable ? List.from(data?[kKeyLike]) : null);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (postId != null) kKeyPostId: postId,
      if (uid != null)  kKeyUsersId: uid,
      // if (username != null) kKeyUserName: username,
      // if (userPhotoUrl != null) kKeyUserPhoto: userPhotoUrl,
      if (postPhotoUrl != null) kKeyPostPhoto: postPhotoUrl,
      kKeyTimestamp: timestamp,
      if (caption != null) kKeyCaption: caption,
      if (like != null) kKeyLike: like
    };
  }
}