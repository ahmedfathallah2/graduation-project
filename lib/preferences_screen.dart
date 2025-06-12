// lib/preferences_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/user_model.dart';

class PreferencesScreen extends StatefulWidget {
  final UserModel userModel;
  
  const PreferencesScreen({Key? key, required this.userModel}) : super(key: key);
  
  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  late UserModel userData;
  Map<String, dynamic>? autoPreferences;
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    userData = widget.userModel;
    _loadAutoPreferences();
  }
  
  Future<void> _loadAutoPreferences() async {
    setState(() => isLoading = true);
    
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null && data.containsKey('auto_preferences')) {
            setState(() {
              autoPreferences = data['auto_preferences'];
            });
          }
        }
      }
    } catch (e) {
      print('Error loading preferences: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  Future<void> _applyRecommendedPreferences() async {
    if (autoPreferences == null) return;
    
    try {
      setState(() => isLoading = true);
      
      final brands = List<String>.from(autoPreferences!['brand'] ?? []);
      final categories = List<String>.from(autoPreferences!['category'] ?? []);
      final subcategories = List<String>.from(autoPreferences!['subcategory'] ?? []);
      
      // Update user preferences with recommendations
      final updatedPreferences = userData.preferences.copyWith(
        brand: brands,
        category: categories,
        subcategory: subcategories,
      );
      
      // Update in Firestore
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'preferences': updatedPreferences.toMap(),
        });
        
        // Update local user model
        setState(() {
          userData = userData.copyWith(preferences: updatedPreferences);
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preferences updated successfully!'))
      );
    } catch (e) {
      print('Error applying preferences: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update preferences.'))
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recommended Preferences'),
      ),
      body: isLoading 
          ? Center(child: CircularProgressIndicator())
          : autoPreferences == null
              ? Center(child: Text('No recommendations available yet.'))
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Based on your wishlist:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 24),
                      
                      _buildMetricsSection(
                        autoPreferences!['metrics'] as Map<String, dynamic>? ?? {},
                      ),
                      
                      SizedBox(height: 30),
                      
                      Center(
                        child: ElevatedButton(
                          onPressed: _applyRecommendedPreferences,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[400],
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          child: Text('Apply These Preferences'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildPreferenceSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        items.isEmpty
            ? Text('No recommendations')
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map((item) => Chip(
                  label: Text(item),
                  backgroundColor: Colors.amber[100],
                )).toList(),
              ),
        SizedBox(height: 24),
      ],
    );
  }
  
  Widget _buildMetricsSection(Map<String, dynamic> metrics) {
    if (metrics.isEmpty) return SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ...metrics.entries.map((entry) => Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Text(
            '• ${entry.value}',
            style: TextStyle(fontSize: 14),
          ),
        )).toList(),
        SizedBox(height: 24),
      ],
    );
  }
}
