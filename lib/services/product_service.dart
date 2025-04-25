import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/jumia_product.dart';
// 1. Add this outside any widget/class in the same file:
Stream<List<JumiaProduct>> fetchJumiaProducts() {
  return FirebaseFirestore.instance.collection('products').snapshots().map(
    (snapshot) {
      return snapshot.docs.map((doc) {
        return JumiaProduct.fromFirestore(doc.data());
      }).toList();
    },
  );
}
