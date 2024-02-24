
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/const.dart';

class CommentsPost {
  final String? postId;
  final String? commentsId;
  final String? senderId;
  final String? receiverId;
  final String? parentId;
  final String? commentContent;
  final Timestamp timestamp;
  final List? like;

  const CommentsPost({
    required this.postId,
    required this.commentsId,
    required this.senderId,
    required this.receiverId,
    required this.parentId,
    required this.commentContent,
    required this.timestamp,
    required this.like,
  });

  Map<String, dynamic> toJson() => {
    kKeyPostId: postId,
    kKeyCommentId: commentsId,
    kKeyUsersId: senderId,
    kKeyReceiverId: receiverId,
    kKeyParentId: parentId,
    kKeyPostPhoto: commentContent,
    kKeyTimestamp: timestamp,
    kKeyLike: like
  };

  factory CommentsPost.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return CommentsPost(
        postId: data?[kKeyPostId],
        commentsId: data?[kKeyCommentId],
        senderId: data?[kKeySenderId],
        receiverId: data?[kKeyReceiverId],
        parentId: data?[kKeyParentId],
        commentContent: data?[kKeyCommentContent],
        timestamp: data?[kKeyTimestamp],
        like:  data?[kKeyLike] is Iterable ? List.from(data?[kKeyLike]) : null);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (postId != null) kKeyPostId: postId,
      if (commentsId != null) kKeyCommentId: commentsId,
      if (senderId != null)  kKeySenderId: senderId,
      if (receiverId != null)  kKeyReceiverId: receiverId,
      if (parentId != null)  kKeyParentId: parentId,
      if (commentContent != null) kKeyCommentContent: commentContent,
      kKeyTimestamp: timestamp,
      if (like != null) kKeyLike: like
    };
  }
}