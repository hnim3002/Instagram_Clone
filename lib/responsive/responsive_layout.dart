import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clon/providers/user_provider.dart';
import 'package:instagram_clon/resources/firestore_method.dart';
import 'package:instagram_clon/utils/dimenstion.dart';
import 'package:provider/provider.dart';


import '../providers/posts_provider.dart';
import '../providers/posts_state_provider.dart';
import '../riverpod_providers/post_provider.dart';
import '../riverpod_providers/user_provider.dart';

class ResponsiveLayout extends ConsumerStatefulWidget {
  final Widget webScreenLayout;
  final Widget mobileScreenLayout;

  const ResponsiveLayout(
      {super.key,
      required this.webScreenLayout,
      required this.mobileScreenLayout});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends ConsumerState<ResponsiveLayout> with WidgetsBindingObserver  {

  @override
  void dispose() {

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    // addData();
    // getPostData();
    super.initState();

  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   if (state == AppLifecycleState.paused) {
  //     updateActivity(false);
  //     print('App is about to exit. Execute cleanup code here.');
  //   }
  //   else if (state == AppLifecycleState.resumed) {
  //
  //     updateActivity(true);
  //     print('App resumed.');
  //
  //   }
  // }


  // Future<void> updateActivity(bool isActive) async {
  //   await FirestoreMethods().updateActivity(FirebaseAuth.instance.currentUser!.uid, isActive);
  // }

  addData() async {
    // UserProvider userProvider = Provider.of(context, listen: false);
    // await userProvider.refreshUser();
    ref.watch(userNotifierProvider);
    // updateActivity(true);
  }

  Future<void> getPostData() async {
    ref.watch(postNotifierProvider);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth > webScreenSize) {
        return widget.mobileScreenLayout;
      } else {
        return widget.mobileScreenLayout;
      }
    });
  }
}
