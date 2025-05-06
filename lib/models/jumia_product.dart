class JumiaProduct {
  final String id;
  final String title;
  final String brand;
  final String category;
  final String subcategory;
  final String imageUrl;
  final String link;
  final int parsedStorage;
  final int priceEGP;

  JumiaProduct({
    required this.id,
    required this.title,
    required this.brand,
    required this.category,
    required this.subcategory,
    required this.imageUrl,
    required this.link,
    required this.parsedStorage,
    required this.priceEGP,
  });

  factory JumiaProduct.fromFirestore(Map<String, dynamic> data) {
    return JumiaProduct(
      id: data['id'] ?? '', // Document ID
      title: data['Title'] ?? '',
      brand: data['Brand'] ?? '',
      category: data['Category'] ?? '',
      subcategory: data['Subcategory'] ?? '',
      imageUrl: data['Image_URL'] ?? '',
      link: data['Link'] ?? '',
      parsedStorage: data['Parsed_Storage'] ?? 0,
      priceEGP: data['Price_EGP'] ?? 0,
    );
  }
}
