import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/svg.dart';
import 'package:instagram_clon/providers/user_provider.dart';

import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../Widgets/post_card_widgets.dart';

import '../models/user.dart' as model;
import '../providers/posts_provider.dart';
import '../providers/posts_state_provider.dart';
import '../riverpod_providers/post_provider.dart';
import '../riverpod_providers/user_provider.dart';
import '../utils/color_schemes.dart';
import '../utils/const.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Function toChatScreen;
  const HomeScreen({super.key, required this.toChatScreen});
  
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  void initState() {
    super.initState();
  }


  Future<void> getPostData() async {
    // Provider.of<PostsStateProvider>(context, listen: false).setPostDataSize(await Provider.of<PostsProvider>(context, listen: false).initPostData());
    ref.read(postNotifierProvider.notifier).updatePostData();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    // final model.User? user = Provider.of<UserProvider>(context).user;
    final user = ref.watch(userNotifierProvider);
    final postData = ref.watch(postNotifierProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            return getPostData();
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                elevation: 0,
                backgroundColor: isDarkMode ? Colors.black : primaryColor,
                title: SvgPicture.asset(
                  height: 30,
                  "assets/images/ic_instagram.svg",
                  colorFilter: ColorFilter.mode(
                      isDarkMode ? primaryColor : Colors.black,
                      BlendMode.srcIn),
                ),
                actions: [
                  IconButton(
                      visualDensity: VisualDensity.compact,
                      highlightColor: Colors.transparent,
                      enableFeedback: false,
                      color: isDarkMode ? Colors.white : Colors.black,
                      iconSize: 25,
                      onPressed: () {
                        widget.toChatScreen();
                      },
                      icon: const Icon(
                        Symbols.chat_rounded,
                        weight: 500,
                      )),
                ],
                floating: true,
                snap: true,
              ),

              switch (postData) {
                AsyncData(:final value) => SliverList(
                  delegate: SliverChildBuilderDelegate(
                    findChildIndexCallback: (key) {
                      return int.tryParse(key.toString());
                    },
                        (context, index) {
                      return PostCard(
                        key: Key(index.toString() +
                            DateTime.now().millisecondsSinceEpoch.toString()),

                        index: index,
                        postPhotoUrl: value[index]["post"][kKeyPostPhoto],
                        userPhotoUrl: value[index]["user"][kKeyUserPhoto],
                      );
                    },
                    childCount: value.length,
                  ),
                ),
                AsyncError(:final error) => Text('Oops $error'),
                _ =>  SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return Container();
                    },
                    childCount: 1,
                  ),
                ),
              }
            ],
          ),
        ),
      ),
    );
  }
}
