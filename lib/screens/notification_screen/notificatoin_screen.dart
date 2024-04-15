import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clon/Widgets/notification_listtile.dart';
import 'package:instagram_clon/resources/firestore_method.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<Map<String, dynamic>>> notificationData;


  Future<void> getUserNotificationData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    notificationData = FirestoreMethods().getNotificationData(uid);
  }

  @override
  void initState() {
    getUserNotificationData();
    super.initState();
  }

  @override
  void didChangeDependencies() {

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: notificationData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            print(snapshot.data!);
            if(snapshot.data!.isEmpty) {
              return const Center(
                child: Text("You have no notification"),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return NotificationListTile(notificationData: snapshot.data![index],);
              },
            );
          },
        ),
      )
    );
  }
}
