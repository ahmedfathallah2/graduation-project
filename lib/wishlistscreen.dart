import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart'; // ✅ Adjust path if needed

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>().wishlist;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Wishlist"),
        backgroundColor: Colors.white,
      ),
      body: wishlist.isEmpty
          ? const Center(
              child: Text("Your wishlist is empty 😔"),
            )
          : ListView.builder(
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final product = wishlist[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Image.network(product.imageUrl, width: 60),
                    title: Text(product.title),
                    subtitle: Text("EGP ${product.priceEGP}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        Provider.of<WishlistProvider>(context, listen: false)
                            .toggleWishlist(product);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
