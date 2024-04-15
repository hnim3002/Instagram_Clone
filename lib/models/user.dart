import 'package:cloud_firestore/cloud_firestore.dart';


import '../utils/const.dart';

class User {
  final String? email;
  final String? username;
  final String? uid;
  final String? photoUrl;
  final String? fullname;
  final String? bio;
  final List? followers;
  final List? following;
  final List? post;
  final List? like;
  final List? save;
  final List? block;

  const User({
    required this.email,
    required this.username,
    required this.fullname,
    required this.uid,
    required this.bio,
    required this.photoUrl,
    required this.followers,
    required this.following,
    required this.post,
    required this.like,
    required this.save,
    required this.block,
  });

  Map<String, dynamic> toJson() => {
        kKeyUsersId: uid,
        kKeyUserName: username,
        kKeyFullName: fullname,
        kKeyEmail: email,
        kKeyUserBio: bio,
        kKeyUserPhoto: photoUrl,
        kKeyUserFollowers: followers,
        kKeyUserFollowing: following,
        kKeyUserPost: post,
        kKeyLike: like,
        kKeyUserSave: save,
        kKeyUserBlock: block,
      };

  factory User.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return User(
        email: data?[kKeyEmail],
        username: data?[kKeyUserName],
        fullname: data?[kKeyFullName],
        uid: data?[kKeyUsersId],
        bio: data?[kKeyUserBio],
        photoUrl: data?[kKeyUserPhoto],
        followers:  data?[kKeyUserFollowers] is Iterable ? List.from(data?[kKeyUserFollowers]) : null,
        following:  data?[kKeyUserFollowing] is Iterable ? List.from(data?[kKeyUserFollowing]) : null,
        post:  data?[kKeyUserPost] is Iterable ? List.from(data?[kKeyUserPost]) : null,
        like:  data?[kKeyLike] is Iterable ? List.from(data?[kKeyLike]) : null,
        save:  data?[kKeyUserSave] is Iterable ? List.from(data?[kKeyUserSave]) : null,
        block:  data?[kKeyUserBlock] is Iterable ? List.from(data?[kKeyUserBlock]) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (email != null) kKeyEmail: email,
      if (username != null) kKeyUserName: username,
      if (fullname != null) kKeyFullName: fullname,
      if (uid != null) kKeyUsersId: uid,
      if (bio != null) kKeyUserBio: bio,
      if (photoUrl != null) kKeyUserPhoto: photoUrl,
      if (followers != null) kKeyUserFollowers: followers,
      if (following != null) kKeyUserFollowing: following,
      if (post != null) kKeyUserPost: post,
      if (like != null) kKeyLike: like,
      if (save != null) kKeyUserSave: save,
      if (block != null) kKeyUserBlock: block,
    };
  }

  bool isUserFollowing(String uid) {
    return following!.contains(uid);
  }
}
