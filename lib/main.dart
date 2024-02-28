import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_clon/providers/comments_provider.dart';
import 'package:instagram_clon/providers/comments_state_provider.dart';
import 'package:instagram_clon/providers/posts_provider.dart';
import 'package:instagram_clon/providers/user_provider.dart';
import 'package:instagram_clon/responsive/mobile_screen.dart';
import 'package:instagram_clon/responsive/responsive_layout.dart';
import 'package:instagram_clon/responsive/web_screen.dart';
import 'package:instagram_clon/screens/Home_screen.dart';
import 'package:instagram_clon/screens/login_screen.dart';
import 'package:instagram_clon/screens/post_screen/select_img.dart';
import 'package:instagram_clon/screens/search_screen/search_screen.dart';
import 'package:page_route_animator/page_route_animator.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor:
          Colors.white, // set color of system navigation bar
      statusBarColor: Colors.white, // transparent status bar
    ));
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CommentsStateProvider()
        ),
        ChangeNotifierProvider(
            create: (_) => CommentsProvider()
        ),
        ChangeNotifierProvider(
            create: (_) => PostsProvider()
        )
      ],
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData.light(useMaterial3: true).copyWith(
            scaffoldBackgroundColor: Colors.white,
          ),
          darkTheme: ThemeData.dark(useMaterial3: true)
              .copyWith(scaffoldBackgroundColor: Colors.black),
          routes: {
            '/home_screen': (context) => const MobileScreenLayout(),
          },
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/post-screen':
                return PageRouteAnimator(
                  child: const PostScreen(),
                  routeAnimation: RouteAnimation.leftToRight,
                  settings: settings,
                  curve: Curves.linear,
                  duration: const Duration(milliseconds: 300),
                  reverseDuration: const Duration(milliseconds: 300),
                );
              case '/chat-screen':
                return PageRouteAnimator(
                  child: const PostScreen(),
                  routeAnimation: RouteAnimation.rightToLeft,
                  settings: settings,
                  curve: Curves.linear,
                  duration: const Duration(milliseconds: 300),
                  reverseDuration: const Duration(milliseconds: 300),
                );
              default:
                return null;
            }
          },
          home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return const ResponsiveLayout(
                    mobileScreenLayout: MobileScreenLayout(),
                    webScreenLayout: WebScreenLayout(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("${snapshot.hasError}"),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return const LoginScreen();
              })),
    );
  }
}
