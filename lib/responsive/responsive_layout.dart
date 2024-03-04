import 'package:flutter/material.dart';
import 'package:instagram_clon/providers/user_provider.dart';
import 'package:instagram_clon/utils/dimenstion.dart';
import 'package:provider/provider.dart';

import '../providers/comments_provider.dart';
import '../providers/posts_provider.dart';
import '../providers/posts_state_provider.dart';

class ResponsiveLayout extends StatefulWidget {
  final Widget webScreenLayout;
  final Widget mobileScreenLayout;

  const ResponsiveLayout(
      {super.key,
      required this.webScreenLayout,
      required this.mobileScreenLayout});

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {


  @override
  void initState() {
    addData();
    getPostData();
    super.initState();

  }

  addData() async {
    UserProvider userProvider = Provider.of(context, listen: false);
    await userProvider.refreshUser();
  }

  Future<void> getPostData() async {
    Provider.of<PostsStateProvider>(context, listen: false).setPostDataSize(await Provider.of<PostsProvider>(context, listen: false).initPostData());
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
