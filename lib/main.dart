import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'views/auth_screen.dart'; // Import the AuthScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Flutter App',
      home: AuthScreen(),
      debugShowCheckedModeBanner: false,
      // Call AuthScreen
    );
  }
}
