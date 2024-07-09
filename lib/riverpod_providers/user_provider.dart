
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user.dart';
import '../resources/auth_method.dart';

part 'user_provider.g.dart';

@riverpod
class UserNotifier extends _$UserNotifier {
  final AuthMethods _authMethods = AuthMethods();

  @override
  Future<User?> build() async {
    return await _authMethods.getUserDetails();
  }

  Future<void> refreshUser() async {
    state = const AsyncLoading<User?>();
    User? user = await _authMethods.getUserDetails();
    state = AsyncData(user);
  }


}