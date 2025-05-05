import 'package:flutter/material.dart';
import '../models/jumia_product.dart'; 

class WishlistProvider with ChangeNotifier {
  final List<JumiaProduct> _wishlist = [];

  List<JumiaProduct> get wishlist => _wishlist;

  void toggleWishlist(JumiaProduct product) {
    if (_wishlist.any((item) => item.title == product.title)) {
      _wishlist.removeWhere((item) => item.title == product.title);
    } else {
      _wishlist.add(product);
    }
    notifyListeners();
  }

  bool isInWishlist(JumiaProduct product) {
    return _wishlist.any((item) => item.title == product.title);
  }
}
