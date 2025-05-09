import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'splash_screen.dart';
import 'providers/wishlist_provider.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); 

  runApp(
    ChangeNotifierProvider(
      create: (context) => WishlistProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize wishlist when app starts if a user is logged in
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Load wishlist if a user is logged in
      Future.delayed(Duration.zero, () {
        Provider.of<WishlistProvider>(context, listen: false).loadWishlist();
      });
    }
    
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ecommerce App',
      home: SplashScreen(),
    );
  }
}
