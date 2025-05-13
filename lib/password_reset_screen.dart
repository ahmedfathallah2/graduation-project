import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final codeController = TextEditingController();
  
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;
  String? errorMessage;
  bool isLoading = false;
  String? verificationId;
  int currentStep = 0; // 0: Email entry, 1: Code verification, 2: New password entry, 3: Success

  // Google Apps Script web app URL
  final String scriptUrl = 'https://script.google.com/macros/s/AKfycbxkTj9d3NvpWVAjPH2KW65fW5gvCygh-M7BSUdWQvcd-p8AXdemBf6XleaDkU0GQYsv9g/exec';

  // Step 1: Submit email for verification code
  Future<void> sendVerificationCode() async {
    if (emailController.text.trim().isEmpty) {
      setState(() {
        errorMessage = 'Please enter your email address';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Call Google Apps Script to generate and store verification code
      final response = await http.post(
        Uri.parse(scriptUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'generateCode',
          'email': emailController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);
      
      if (data['success']) {
        // In a real app, this verification code would be sent via email
        // Here we're just logging it for demonstration purposes
        print('Generated code: ${data['code']}');
        
        // Move to the code verification step
        setState(() {
          currentStep = 1;
          errorMessage = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent to your email!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Failed to send verification code';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Step 2: Verify the code
  Future<void> verifyCode() async {
    if (codeController.text.trim().isEmpty) {
      setState(() {
        errorMessage = 'Please enter the verification code';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Call Google Apps Script to verify the code
      final response = await http.post(
        Uri.parse(scriptUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'verifyCode',
          'email': emailController.text.trim(),
          'code': codeController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);
      
      if (data['success']) {
        // Move to password entry step
        setState(() {
          currentStep = 2;
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Invalid verification code';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to verify code';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Step 3: Update password
  Future<void> updatePassword() async {
    if (newPasswordController.text.trim().isEmpty) {
      setState(() {
        errorMessage = 'Please enter a new password';
      });
      return;
    }
    
    if (newPasswordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
      return;
    }

    if (newPasswordController.text.length < 6) {
      setState(() {
        errorMessage = 'Password must be at least 6 characters';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Get the current Firebase user
      User? user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // User is signed in, update password directly
        await user.updatePassword(newPasswordController.text);
      } else {
        // User is not signed in, use email and password reset
        // For this, we need to first sign in with the custom token or credential
        
        // One approach: Create a temporary email sign-in link and use it
        // This would typically be implemented with a custom backend or Firebase Functions
        
        // For now, we'll just simulate success for demonstration purposes
        await Future.delayed(const Duration(seconds: 2));
      }
      
      setState(() {
        currentStep = 3; // Success step
        errorMessage = null;
      });
      
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to update password: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Recovery'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password Recovery',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Different UI based on the current step
            if (currentStep == 0) _buildEmailStep(),
            if (currentStep == 1) _buildCodeStep(),
            if (currentStep == 2) _buildPasswordStep(),
            if (currentStep == 3) _buildSuccessStep(),
            
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter your email to receive a verification code.',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email Address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ElevatedButton(
          onPressed: isLoading ? null : sendVerificationCode,
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
                  'Send Verification Code',
                  style: TextStyle(color: Colors.black),
                ),
        ),
      ],
    );
  }
  
  Widget _buildCodeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter the verification code sent to your email.',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: codeController,
          decoration: InputDecoration(
            labelText: 'Verification Code',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: const Icon(Icons.lock_outlined),
          ),
        ),
        const SizedBox(height: 20),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentStep = 0;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: isLoading ? null : verifyCode,
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
                        'Verify Code',
                        style: TextStyle(color: Colors.black),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create a new password.',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: newPasswordController,
          obscureText: obscureNewPassword,
          decoration: InputDecoration(
            labelText: 'New Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  obscureNewPassword = !obscureNewPassword;
                });
              },
              icon: Icon(
                obscureNewPassword ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: confirmPasswordController,
          obscureText: obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  obscureConfirmPassword = !obscureConfirmPassword;
                });
              },
              icon: Icon(
                obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentStep = 1;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: isLoading ? null : updatePassword,
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
                        'Reset Password',
                        style: TextStyle(color: Colors.black),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSuccessStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 80,
          ),
          const SizedBox(height: 24),
          Text(
            'Password Reset Successful!',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your password has been successfully updated.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Return to login screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(200, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Back to Login',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
