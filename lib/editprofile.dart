import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final locationController = TextEditingController(text: 'Alexandria');
  final mobileController = TextEditingController(text: '+20 1007298133');
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      // Try splitting full name into first + last
      final parts = user.displayName!.split(' ');
      firstNameController.text = parts.first;
      if (parts.length > 1) lastNameController.text = parts.sublist(1).join(' ');
    }
  }

  Future<void> saveChanges() async {
    final fullName = "${firstNameController.text.trim()} ${lastNameController.text.trim()}";
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(fullName);
        await user.reload();
        Navigator.pop(context); // Go back to profile screen
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    locationController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: saveChanges,
            child: const Text("Done", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.pinkAccent,
              child: Icon(Icons.person, size: 40, color: Colors.black),
            ),
            const SizedBox(height: 10),
            Text(
              "${firstNameController.text} ${lastNameController.text}".trim().isEmpty
                  ? 'User'
                  : "${firstNameController.text} ${lastNameController.text}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            TextButton(
              onPressed: () {
                // You can add profile pic update logic here
              },
              child: const Text("Change Profile Picture", style: TextStyle(color: Colors.blue)),
            ),
            const SizedBox(height: 20),
            CustomTextField(label: "First Name", controller: firstNameController),
            CustomTextField(label: "Last Name", controller: lastNameController),
            CustomTextField(label: "Location", controller: locationController),
            CustomTextField(label: "Mobile Number", controller: mobileController),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const CustomTextField({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF6F6F6),
            suffixIcon: const Icon(Icons.check, color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
