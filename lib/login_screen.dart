import 'package:ecommerce_app/amin_splash_screen.dart';
import 'package:ecommerce_app/guest.dart';
import 'package:ecommerce_app/homescreen.dart';
import 'package:ecommerce_app/signup.dart'; // 👈 import SignUpScreen
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
   const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obsecureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              
              decoration: InputDecoration(
                labelText: "Email Address",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              obscureText: obsecureText,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon:  IconButton(onPressed: (){
                    obsecureText = !obsecureText;
                    setState(() {
                      
                    });
                }, icon:  Icon(obsecureText?Icons.visibility_off:Icons.visibility)),
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Recovery Password",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Sign In", style: TextStyle(color: Colors.black),),
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
                 MaterialPageRoute(builder: (context)=>const adminsplashscreen()));
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
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
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
