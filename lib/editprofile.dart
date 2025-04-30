import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel? userModel;

  const EditProfileScreen({
    super.key, 
    this.userModel,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final locationController = TextEditingController();
  final mobileController = TextEditingController();
  
  // Preference controllers
  final minPriceController = TextEditingController();
  final maxPriceController = TextEditingController();
  final storageController = TextEditingController();
  
  final List<String> selectedBrands = [];
  final List<String> selectedCategories = [];
  
  String? errorMessage;
  bool isLoading = false;
  bool showPreferences = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      final parts = user.displayName!.split(' ');
      firstNameController.text = parts.first;
      if (parts.length > 1) lastNameController.text = parts.sublist(1).join(' ');
    }
    
    // If user model is provided, use those values
    if (widget.userModel != null) {
      locationController.text = widget.userModel!.location;
      mobileController.text = widget.userModel!.mobile;
      
      // Set preference values
      minPriceController.text = widget.userModel!.preferences.minPrice.toString();
      maxPriceController.text = widget.userModel!.preferences.maxPrice.toString();
      storageController.text = widget.userModel!.preferences.storage.toString();
      
      // Set selected lists
      selectedBrands.addAll(widget.userModel!.preferences.brand);
      selectedCategories.addAll(widget.userModel!.preferences.category);
    }
  }

  Future<void> saveChanges() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      
      // Update display name in Firebase Auth
      final fullName = "${firstNameController.text.trim()} ${lastNameController.text.trim()}";
      await user.updateDisplayName(fullName);
      
      // Update user data in Firestore
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      
      // Create preferences object
      final preferences = UserPreferences(
        brand: selectedBrands,
        category: selectedCategories,
        minPrice: int.tryParse(minPriceController.text) ?? 0,
        maxPrice: int.tryParse(maxPriceController.text) ?? 10000,
        storage: int.tryParse(storageController.text) ?? 0,
      );
      
      // Update user data
      await userRef.update({
        'username': fullName,
        'location': locationController.text.trim(),
        'mobile': mobileController.text.trim(),
        'preferences': preferences.toMap(),
      });
      
      await user.reload();
      Navigator.pop(context, true); // Return true to indicate changes were made
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    locationController.dispose();
    mobileController.dispose();
    minPriceController.dispose();
    maxPriceController.dispose();
    storageController.dispose();
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
            onPressed: isLoading ? null : saveChanges,
            child: isLoading 
              ? const SizedBox(
                  width: 20, 
                  height: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2)
                )
              : const Text("Save", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            Center(
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
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            const Text("Profile Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // Basic Info
            CustomTextField(label: "First Name", controller: firstNameController),
            CustomTextField(label: "Last Name", controller: lastNameController),
            CustomTextField(label: "Location", controller: locationController),
            CustomTextField(label: "Mobile Number", controller: mobileController),
            
            const SizedBox(height: 20),
            
            // Preferences Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Shopping Preferences", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(showPreferences ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                  onPressed: () {
                    setState(() {
                      showPreferences = !showPreferences;
                    });
                  },
                ),
              ],
            ),
            
            if (showPreferences) ...[
              const SizedBox(height: 10),
              // Price Range
              Row(
                children: [
                  Expanded(child: CustomTextField(label: "Min Price", controller: minPriceController, keyboardType: TextInputType.number)),
                  const SizedBox(width: 20),
                  Expanded(child: CustomTextField(label: "Max Price", controller: maxPriceController, keyboardType: TextInputType.number)),
                ],
              ),
              
              // Storage
              CustomTextField(label: "Storage (GB)", controller: storageController, keyboardType: TextInputType.number),
              
              // Brands
              const SizedBox(height: 15),
              const Text("Preferred Brands", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildChipSelector(
                options: ['Apple', 'Samsung', 'Xiaomi', 'Google', 'OnePlus', 'Nokia', 'Sony'],
                selected: selectedBrands,
                onToggle: (brand) {
                  setState(() {
                    if (selectedBrands.contains(brand)) {
                      selectedBrands.remove(brand);
                    } else {
                      selectedBrands.add(brand);
                    }
                  });
                },
              ),
              
              // Categories
              const SizedBox(height: 15),
              const Text("Preferred Categories", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildChipSelector(
                options: ['Phones', 'Tablets', 'Laptops', 'Accessories', 'Audio', 'Gaming'],
                selected: selectedCategories,
                onToggle: (category) {
                  setState(() {
                    if (selectedCategories.contains(category)) {
                      selectedCategories.remove(category);
                    } else {
                      selectedCategories.add(category);
                    }
                  });
                },
              ),
            ],
            
            // Error message if present
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChipSelector({
    required List<String> options,
    required List<String> selected,
    required Function(String) onToggle,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (_) => onToggle(option),
          backgroundColor: Colors.grey[200],
          selectedColor: Colors.blue[100],
          checkmarkColor: Colors.blue,
        );
      }).toList(),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key, 
    required this.label, 
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

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
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF6F6F6),
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