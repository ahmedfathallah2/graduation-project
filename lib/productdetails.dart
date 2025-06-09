import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../models/jumia_product.dart';
import '../providers/wishlist_provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  final JumiaProduct product;

  const ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  void _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final isWishlisted = wishlistProvider.isInWishlist(product);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? Colors.red : Colors.grey,
            ),
            onPressed: () => wishlistProvider.toggleWishlist(product),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  product.imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 220,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 80),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              product.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (product.brand.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.brand,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                const SizedBox(width: 10),
                if (product.category.isNotEmpty)
                  Chip(
                    label: Text(product.category, style: const TextStyle(fontSize: 13)),
                    backgroundColor: Colors.blue[50],
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (product.subcategory.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.label_outline, size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(product.subcategory, style: const TextStyle(fontSize: 15, color: Colors.black54)),
                ],
              ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text(
                  'EGP ${product.priceEGP}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                if (product.parsedStorage > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Storage: ${product.parsedStorage}GB',
                      style: const TextStyle(fontSize: 13, color: Colors.orange),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart_checkout_outlined),
                    label: const Text('Buy Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: () => _launchURL(context, product.link),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? Colors.red : Colors.grey,
                    size: 30,
                  ),
                  onPressed: () => wishlistProvider.toggleWishlist(product),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (product.link.isNotEmpty)
              InkWell(
                onTap: () => _launchURL(context, product.link),
                child: Text(
                  'View on Jumia',
                  style: TextStyle(
                    color: Colors.blue[700],
                    decoration: TextDecoration.underline,
                    fontSize: 16,
                  ),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
