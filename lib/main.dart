import 'package:ecommerce_app/helpers/firebase_helper.dart';
import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Import the splash screen

void main() async{
  await FirebaseHelper.configuration();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    ); 
  }
}
//comment