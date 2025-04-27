// firebase_helper.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/jumia_product.dart';

class FirebaseHelper {
  static Stream<List<JumiaProduct>> fetchJumiaProducts() {
  return FirebaseFirestore.instance.collection('products').snapshots().map(
    (snapshot) {
      return snapshot.docs.map((doc) {
        return JumiaProduct.fromFirestore(doc.data());
      }).toList();
    },
  );
}

}
