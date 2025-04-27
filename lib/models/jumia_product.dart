class JumiaProduct {
  final String brand;
  final String category;
  final String imageUrl;
  final String link;
  final double parsedStorage;
  final int priceEGP;
  final String subcategory;
  final String title;

  JumiaProduct({
    required this.brand,
    required this.category,
    required this.imageUrl,
    required this.link,
    required this.parsedStorage,
    required this.priceEGP,
    required this.subcategory,
    required this.title,
  });

  factory JumiaProduct.fromFirestore(Map<String, dynamic> data) {
    return JumiaProduct(
      brand: data['Brand'] ?? '',
      category: data['Category'] ?? '',
      imageUrl: data['Image_URL'] ?? '',
      link: data['Link'] ?? '',
      parsedStorage: (data['Parsed_Storage'] ?? 0).toDouble(),
      priceEGP: (data['Price_EGP'] ?? 0).toInt(),
      subcategory: data['Subcategory'] ?? '',
      title: data['Title'] ?? '',
    );
  }
}
