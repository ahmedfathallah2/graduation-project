class Product {
  final String name;
  final String price;
  final String discount;
  final String imageUrl;
  final String description;
  final List<String> colors;
  final List<String> vendors;
  final List<String> dimensions;

  Product(
    {
     required this.colors,required this.vendors,required this.dimensions,
    required this.name,
    required this.price,
    required this.discount,
    required this.imageUrl,
    required this.description,
    

  });
}
