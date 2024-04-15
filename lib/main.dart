import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_clon/providers/comments_provider.dart';
import 'package:instagram_clon/providers/comments_state_provider.dart';
import 'package:instagram_clon/providers/posts_provider.dart';
import 'package:instagram_clon/providers/posts_state_provider.dart';
import 'package:instagram_clon/providers/user_provider.dart';
import 'package:instagram_clon/resources/messaging_method.dart';
import 'package:instagram_clon/responsive/mobile_screen.dart';
import 'package:instagram_clon/responsive/responsive_layout.dart';
import 'package:instagram_clon/responsive/web_screen.dart';

import 'package:instagram_clon/screens/login_screen.dart';

import 'package:provider/provider.dart';

import 'firebase_options.dart';

const bool USE_EMULATOR = false;

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (USE_EMULATOR) {
    await useEmulator();
  }
  runApp(const MyApp());
}

Future<void> useEmulator() async {
  const localHostString = "10.0.2.2";

  FirebaseFirestore.instance.useFirestoreEmulator(localHostString, 8080);

  await FirebaseAuth.instance.useAuthEmulator(localHostString, 9099);

  await FirebaseStorage.instance.useStorageEmulator(localHostString, 9199);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor:
          Colors.white, // set color of system navigation bar
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness
          .dark, // Set the status bar text color// transparent status bar
    ));
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(create: (_) => CommentsStateProvider()),
        ChangeNotifierProvider(create: (_) => CommentsProvider()),
        ChangeNotifierProvider(create: (_) => PostsProvider()),
        ChangeNotifierProvider(create: (_) => PostsStateProvider())
      ],
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData.light(useMaterial3: true).copyWith(
            scaffoldBackgroundColor: Colors.white,
          ),
          navigatorKey: navigatorKey,
          darkTheme: ThemeData.dark(useMaterial3: true)
              .copyWith(scaffoldBackgroundColor: Colors.black),
          routes: {
            '/home_screen': (context) => const MobileScreenLayout(),
          },
          home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text("${snapshot.error}"),
                  );
                }
                if (snapshot.hasData && snapshot.data != null) {
                  MessagingMethod().uploadTokenToServer();
                  MessagingMethod().initNotifications();
                  return const ResponsiveLayout(
                    mobileScreenLayout: MobileScreenLayout(),
                    webScreenLayout: WebScreenLayout(),
                  );
                } else {
                  // No user authenticated
                  return const LoginScreen();
                }
              }
          )),
    );
  }
}
