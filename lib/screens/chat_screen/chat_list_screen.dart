import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../Widgets/chat_user_card_widget.dart';
import '../../Widgets/user_card_widgets.dart';
import '../../models/user.dart' as model;
import '../../providers/user_provider.dart';
import '../../utils/const.dart';

class ChatListScreen extends StatefulWidget {
  final Function closeBtnOnPressed;
  const ChatListScreen({
    super.key,
    required this.closeBtnOnPressed,
  });

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> userData = [];
  final Stream<QuerySnapshot> chatRoomStream = FirebaseFirestore.instance
      .collection(kKeyCollectionChatRooms)
      .where(kKeyParticipantsId,
          arrayContains: FirebaseAuth.instance.currentUser!.uid)
      .orderBy(kKeyTimestamp, descending: true)
      .snapshots();

  Future<void> getUserData() async {
    QuerySnapshot chatRoomSnapshot = await FirebaseFirestore.instance
        .collection(kKeyCollectionChatRooms)
        .where(kKeyParticipantsId,
            arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .orderBy(kKeyTimestamp, descending: true)
        .get();

    List userList = chatRoomSnapshot.docs
        .expand((chatRoom) => chatRoom[kKeyParticipantsId])
        .where((user) => user != FirebaseAuth.instance.currentUser!.uid)
        .toList();

    if(userList.isEmpty) {
      return;
    }

    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection(kKeyCollectionUsers)
        .where(FieldPath.documentId, whereIn: userList)
        .get();

    List<Map<String, dynamic>> temp = [];
    for (var user in userSnapshot.docs) {
      temp.add(user.data() as Map<String, dynamic>);
    }
    if (mounted) {
      setState(() {
        userData = temp;
      });
    }
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model.User? user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.closeBtnOnPressed();
          },
        ),
        title: Text(
          user!.username!,
          style: const TextStyle(
              letterSpacing: 0.5, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          widget.closeBtnOnPressed();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      showSearch(
                          context: context, delegate: CustomSearchDelegate());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          const Icon(Symbols.search_rounded),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Search",
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  ActiveUserWidget(user: user),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text("Messages",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                  const SizedBox(
                    height: 20,
                  ),
                  StreamBuilder<QuerySnapshot>(
                      stream: chatRoomStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.data == null ||
                            snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No messages found'));
                        }

                        if (userData.isEmpty) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        // List<Map<String, dynamic>> chatRoomData = [];
                        // List<Map<String, dynamic>> userData2 = [];
                        // for (var doc in snapshot.data!.docs) {
                        //   chatRoomData.add(doc.data() as Map<String, dynamic>);
                        //   for (var user in doc[kKeyParticipantsId]) {
                        //     if (user != FirebaseAuth.instance.currentUser!.uid) {
                        //       bool isContains = false;
                        //       for (var userData in userData) {
                        //         if (userData[kKeyUsersId] == user) {
                        //           userData2.add(userData);
                        //           isContains = true;
                        //           break;
                        //         }
                        //       }
                        //       if(isContains == false) {
                        //         getUserData();
                        //       }
                        //     }
                        //   }
                        // }

                        List<Map<String, dynamic>> chatRoomData = [];
                        List<Map<String, dynamic>> userData2 = [];

                        for (var doc in snapshot.data!.docs) {
                          chatRoomData.add(doc.data() as Map<String, dynamic>);

                          var participants = doc[kKeyParticipantsId]
                              .where((user) =>
                                  user !=
                                  FirebaseAuth.instance.currentUser!.uid)
                              .toList();

                          var newUsers = participants
                              .where((user) => !userData
                                  .any((data) => data[kKeyUsersId] == user))
                              .toList();

                          if (newUsers.isNotEmpty) {
                            getUserData();
                          }

                          userData2.addAll(userData.where((data) =>
                              participants.contains(data[kKeyUsersId])));
                        }

                        return ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: chatRoomData.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ChatUserCard(
                              chatRoomData: chatRoomData[index],
                              userData: userData2[index],
                            );
                          },
                        );
                      })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ActiveUserWidget extends StatelessWidget {
  const ActiveUserWidget({
    super.key,
    required this.user,
  });

  final model.User? user;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 37,
                backgroundImage: CachedNetworkImageProvider(user!.photoUrl!),
              ),
              const Text("You")
            ],
          ),
          const SizedBox(
            width: 10,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: user!.following!.isNotEmpty
                ? FirebaseFirestore.instance
                .collection(kKeyCollectionUsers)
                .where(FieldPath.documentId, whereIn: user?.following!)
                .snapshots()
                : const Stream.empty(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.data == null) {
                return const SizedBox();
              }
              List<Map<String, dynamic>> userData = [];
              for (var docSnapshot in snapshot.data!.docs) {
                if((docSnapshot.data() as Map<String, dynamic>)[kKeyIsActive] == true) {
                  userData.add(docSnapshot.data() as Map<String, dynamic>);
                }
              }
              return SizedBox(
                height: 100,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: userData.length,
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 37,
                            backgroundImage: CachedNetworkImageProvider(
                                userData[index][kKeyUserPhoto]),
                          ),
                          Text(userData[index][kKeyFullName])
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.close_rounded))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(kKeyCollectionUsers)
          .orderBy(kKeyUserName)
          .where(kKeyUserName, isGreaterThanOrEqualTo: query)
          .snapshots(),
      builder: (context, snapshot) {
        final model.User? user =
            Provider.of<UserProvider>(context, listen: false).user;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users found'));
        }
        List<Map<String, dynamic>> updatedCombinedData = [];
        for (var userDoc in snapshot.data!.docs) {
          String userId = userDoc.get(kKeyUsersId);
          if (userId != user!.uid && user.following!.contains(userId)) {
            updatedCombinedData.add(userDoc.data() as Map<String, dynamic>);
          }
        }
        if (updatedCombinedData.isEmpty) {
          return const Center(child: Text('No users found'));
        }
        return ListView.builder(
          itemCount: updatedCombinedData.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> user = updatedCombinedData[index];
            return UserCard(
              userData: user,
              isReverse: true,
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(kKeyCollectionUsers)
          .orderBy(kKeyUserName)
          .where(kKeyUserName, isGreaterThanOrEqualTo: query)
          .snapshots(),
      builder: (context, snapshot) {
        final model.User? user =
            Provider.of<UserProvider>(context, listen: false).user;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users found'));
        }
        List<Map<String, dynamic>> updatedCombinedData = [];
        for (var userDoc in snapshot.data!.docs) {
          String userId = userDoc.get(kKeyUsersId);
          if (userId != user!.uid && user.following!.contains(userId)) {
            updatedCombinedData.add(userDoc.data() as Map<String, dynamic>);
          }
        }
        if (updatedCombinedData.isEmpty) {
          return const Center(child: Text('No users found'));
        }
        return ListView.builder(
          itemCount: updatedCombinedData.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> user = updatedCombinedData[index];
            return UserCard(userData: user, isReverse: true);
          },
        );
      },
    );
  }
}
