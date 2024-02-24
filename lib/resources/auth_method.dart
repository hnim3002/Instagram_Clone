import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clon/models/user.dart' as model;
import 'package:instagram_clon/utils/const.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<model.User?> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    final ref = _db.collection("users").doc(currentUser.uid).withConverter(
      fromFirestore: model.User.fromFirestore,
      toFirestore: (model.User user, _) => user.toFirestore(),
    );
    final snap = await ref.get();

    return snap.data();
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String fullname,
  }) async {
    String error = "Some thing when wrong";
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      model.User user = model.User(
          email: email,
          username: username,
          fullname: fullname,
          uid: credential.user!.uid,
          photoUrl: kKeyDefaultAvatar,
          followers: [],
          following: []);

      _db.collection("users").doc(credential.user!.uid).set(user.toJson());
      error = 'Success';
    } on FirebaseAuthException catch (e) {
      error = e.code;
    } catch (e) {
      print(e);
    }
    return error;
  }

  Future<String> signInUser(
      {required String emailOrPhone, required String password}) async {
    String error = "Some thing when wrong";
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailOrPhone, password: password);
      error = 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        error = e.code;
      } else if (e.code == 'wrong-password') {
        error = e.code;
      }
    } catch (e) {
      print(e);
    }
    return error;
  }
}
