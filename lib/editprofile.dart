import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

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
            onPressed: () {
              // Save logic here
            },
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
            const Text('kenzy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextButton(
              onPressed: () {},
              child: const Text(
                "Change Profile Picture",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            const SizedBox(height: 20),
            const CustomTextField(label: "First Name", initialValue: "kenzy"),
            const CustomTextField(label: "Last Name", initialValue: "kazak"),
            const CustomTextField(label: "Location", initialValue: "Alexandria"),
            const CustomTextField(label: "Mobile Number", initialValue: "+20    1007298133"),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final String initialValue;

  const CustomTextField({super.key, required this.label, required this.initialValue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
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