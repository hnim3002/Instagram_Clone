import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/const.dart';

class User {
  final String? email;
  final String? username;
  final String? uid;
  final String? photoUrl;
  final String? fullname;
  final List? followers;
  final List? following;

  const User({
    required this.email,
    required this.username,
    required this.fullname,
    required this.uid,
    required this.photoUrl,
    required this.followers,
    required this.following,
  });

  Map<String, dynamic> toJson() => {
        kKeyUsersId: uid,
        kKeyUserName: username,
        kKeyFullName: fullname,
        kKeyEmail: email,
        kKeyImage: photoUrl,
        kKeyUserFollowers: followers,
        kKeyUserFollowing: following
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
        photoUrl: data?[kKeyImage],
        followers:  data?[kKeyUserFollowers] is Iterable ? List.from(data?[kKeyUserFollowers]) : null,
        following:  data?[kKeyUserFollowing] is Iterable ? List.from(data?[kKeyUserFollowing]) : null);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (email != null) kKeyEmail: email,
      if (username != null) kKeyUserName: username,
      if (fullname != null) kKeyFullName: fullname,
      if (uid != null) kKeyUsersId: uid,
      if (photoUrl != null) kKeyImage: photoUrl,
      if (followers != null) kKeyUserFollowers: followers,
      if (following != null) kKeyUserFollowing: following,
    };
  }
}
