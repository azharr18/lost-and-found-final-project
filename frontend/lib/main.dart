import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lost & Found',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A), // Deeper, more professional blue
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFF3B82F6),
          background: const Color(0xFFF3F4F6),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: const Color(0xFF1F2937),
          displayColor: const Color(0xFF111827),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E3A8A),
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
            fontFamily: 'Poppins',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: const Color(0xFF1F2937), // Dark grey/black for contrast
          contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          elevation: 6,
        ),
        useMaterial3: true,
      ),
      home: FutureBuilder<String?>(
        future: AuthService.getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData && snapshot.data != null) {
            return MainScreen();
          }
          return LoginScreen();
        },
      ),
    );
  }
}
