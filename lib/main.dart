import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rawal_samaj/providers/HomeFeedProvider.dart';
import 'Screens/bottom_nav.dart';
import 'Screens/splash_screen.dart';
import 'accounts/login_screen.dart';
import 'accounts/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox('postsBox');  // Create or open a box to store posts
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    webProvider: ReCaptchaV3Provider('your-recaptcha-key-if-needed'),
  );

  // ✅ Permission Handling
  await _requestPermissions();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HomeFeedProvider()),
        // ChangeNotifierProvider(create: (context) => PostProvider()),
      ],
      child: MyApp(),
    ),
  );
}

Future<void> _requestPermissions() async {
  await [
    Permission.camera,
    Permission.storage,
    Permission.microphone,
  ].request();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hindu Janjagriti',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => BottomNav(),
      },
    );
  }
}
