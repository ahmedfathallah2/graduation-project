import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/wishlist_analyzer_service.dart';
import '../preferences_screen.dart';

// This is an extension to the profile screen to add the automatic preferences feature
class ProfileExtension {
  // Add this section to the profile screen after the existing preferences section
  static Widget buildWishlistPreferencesSection(
    BuildContext context, 
    dynamic userData,
    bool isLoading
  ) {
    // If still loading or no user data, don't show anything
    if (isLoading || userData == null) {
      return const SizedBox.shrink();
    }
    
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // Loading state
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        if (data == null) {
          return const SizedBox.shrink();
        }
        
        // Check if user has auto_preferences and wishlist items
        final hasAutoPreferences = data.containsKey('auto_preferences');
        final wishlistCount = (data['wishlist'] as List?)?.length ?? 0;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.amber.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  const Text(
                    'Smart Preferences',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              Text(
                hasAutoPreferences 
                    ? 'We\'ve analyzed your wishlist to identify your preferences'
                    : wishlistCount > 0 
                        ? 'Add more items to your wishlist to get personalized recommendations'
                        : 'Add items to your wishlist to get personalized recommendations',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Show metrics if available
              if (hasAutoPreferences && 
                  data['auto_preferences'] is Map && 
                  data['auto_preferences'].containsKey('metrics') &&
                  (data['auto_preferences']['metrics'] as Map?)?.isNotEmpty == true) ...[
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    'From your wishlist:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                ...((data['auto_preferences']['metrics'] as Map<String, dynamic>)
                  .entries
                  .take(1) // Just show the first metric
                  .map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• ${entry.value}',
                      style: TextStyle(fontSize: 13, color: Colors.amber[900]),
                    ),
                  ))
                  .toList()),
                const SizedBox(height: 4),
              ],
              
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Recommended Preferences'),
                  onPressed: () {
                    // Navigate to Preferences Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PreferencesScreen(userModel: userData),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[400],
                    foregroundColor: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Add this method to the wishlist service to trigger preference updates
  static Future<void> updatePreferencesWhenWishlistChanges() async {
    try {
      final analyzerService = WishlistAnalyzerService();
      await analyzerService.updateAutomaticPreferences();
    } catch (e) {
      print('Error updating preferences when wishlist changes: $e');
    }
  }
}

// This widget can be placed in profile.dart before the wishlist summary section
class SmartPreferencesBanner extends StatelessWidget {
  final dynamic userData;
  final bool isLoading;
  
  const SmartPreferencesBanner({
    super.key,
    required this.userData,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileExtension.buildWishlistPreferencesSection(
      context, 
      userData, 
      isLoading
    );
  }
}