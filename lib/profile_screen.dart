import 'package:ecommerce_app/editprofile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          setState(() {
            userData = doc.data();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current user
    User? user = FirebaseAuth.instance.currentUser;

    // Fallback values in case data is null
    String displayName = user?.displayName ?? 'No name set';
    String email = user?.email ?? 'No email';

    // Get preferences from userData
    Map<String, dynamic>? preferences;
    List<String>? wishlist;
    
    if (userData != null) {
      preferences = userData!['preferences'] as Map<String, dynamic>?;
      wishlist = List<String>.from(userData!['wishlist'] ?? []);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              ).then((_) => _loadUserData()); // Refresh after returning
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.pinkAccent,
                  child: Icon(Icons.person, size: 40, color: Colors.black),
                ),
                const SizedBox(height: 10),
                Text(
                  displayName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                if (preferences != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Preferences',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        _buildPreferenceItem('Price Range', 
                          '${preferences['min_price']} - ${preferences['max_price']}'),
                        _buildPreferenceItem('Storage', 
                          '${preferences['storage']} GB'),
                        _buildPreferenceItem('Brands', 
                          _formatList(preferences['brand'])),
                        _buildPreferenceItem('Categories', 
                          _formatList(preferences['category'])),
                      ],
                    ),
                  ),
                ],
                if (wishlist != null && wishlist.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Wishlist',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${wishlist.length} items',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 30),

                // Menu Options
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListView(
                      children: [
                        const ProfileMenuItem(
                          icon: Icons.person_outline,
                          title: 'Profile',
                        ),
                        const ProfileMenuItem(
                          icon: Icons.favorite_border,
                          title: 'Wishlist',
                        ),
                        const ProfileMenuItem(
                          icon: Icons.search,
                          title: 'Recently Searched',
                        ),
                        const ProfileMenuItem(
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                        ),

                        // Logout Button
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text(
                            'Logout',
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          ),
                          onTap: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildPreferenceItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(
            value.isEmpty ? 'Not set' : value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatList(List<dynamic>? list) {
    if (list == null || list.isEmpty) return 'None selected';
    if (list.length == 1) return list[0].toString();
    if (list.length == 2) return '${list[0]}, ${list[1]}';
    return '${list[0]}, ${list[1]} +${list.length - 2} more';
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const ProfileMenuItem({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Handle tap
      },
    );
  }
}
