import 'package:ecommerce_app/amin_splash_screen.dart';
import 'package:ecommerce_app/guest.dart';
import 'package:ecommerce_app/homescreen.dart';
import 'package:ecommerce_app/signup.dart';
import 'package:ecommerce_app/admin_homescreen.dart';
//import 'package:ecommerce_app/password_reset_screen.dart'; // Import the new reset screen
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obsecureText = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? errorMessage;
  bool isLoading = false;

  Future<void> signIn() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Sign in with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      
      // Check if user is admin by querying Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      
      // Determine if user is admin
      bool isAdmin = false;
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        isAdmin = userData['isAdmin'] ?? false;
      }
      
      // Navigate to appropriate screen based on admin status
      if (isAdmin) {
        // Navigate to admin home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
        );
      } else {
        // Navigate to regular user home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(email: emailController.text.trim())),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        errorMessage = "An unexpected error occurred";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showPasswordResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How would you like to reset your password?'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showEmailResetDialog();
                  },
                  child: Text('Email Link'),
                ),
                
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEmailResetDialog() {
    final emailController = TextEditingController();
    String? errorMessage;
    bool isLoading = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Reset Password via Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
              ),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() {
                          isLoading = true;
                          errorMessage = null;
                        });
                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: emailController.text.trim(),
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text('Password reset email sent!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } on FirebaseAuthException catch (e) {
                          setState(() {
                            errorMessage = e.message;
                          });
                        } catch (e) {
                          setState(() {
                            errorMessage = 'An unexpected error occurred';
                          });
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      )
                    : Text('Send Reset Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              "Welcome Back!",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email Address",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: obsecureText,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obsecureText = !obsecureText;
                    });
                  },
                  icon: Icon(
                      obsecureText ? Icons.visibility_off : Icons.visibility),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => _showPasswordResetDialog(),
                child: const Text(
                  "Recovery Password",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading ? null : signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading 
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
                  )
                : const Text(
                    "Sign In",
                    style: TextStyle(color: Colors.black),
                  ),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 15),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DealsScreen()),
                );
              },
              icon: const Icon(Icons.person_outline, color: Colors.purple),
              label: const Text("Continue as a guest"),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const adminsplashscreen()));
              },
              icon: const Icon(Icons.admin_panel_settings, color: Colors.blue),
              label: const Text("Admin Login"),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                text: "Don't Have An Account? ",
                style: const TextStyle(color: Colors.grey),
                children: [
                  TextSpan(
                    text: "Sign Up For Free",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpScreen()),
                        );
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
