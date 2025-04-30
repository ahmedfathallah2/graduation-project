class UserPreferences {
  List<String> brand;
  List<String> category;
  List<String> subcategory;
  num minPrice;
  num maxPrice;
  num storage;

  UserPreferences({
    this.brand = const [],
    this.category = const [],
    this.subcategory = const [],
    this.minPrice = 0,
    this.maxPrice = 10000,
    this.storage = 0,
  });

  // Create from Firestore data
  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      brand: List<String>.from(map['brand'] ?? []),
      category: List<String>.from(map['category'] ?? []),
      subcategory: List<String>.from(map['subcategory'] ?? []),
      minPrice: map['min_price'] ?? 0,
      maxPrice: map['max_price'] ?? 10000,
      storage: map['storage'] ?? 0,
    );
  }

  // Convert to Firestore data
  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'category': category,
      'subcategory': subcategory,
      'min_price': minPrice,
      'max_price': maxPrice,
      'storage': storage,
    };
  }
  
  // Create a copy with potentially modified values
  UserPreferences copyWith({
    List<String>? brand,
    List<String>? category,
    List<String>? subcategory,
    num? minPrice,
    num? maxPrice,
    num? storage,
  }) {
    return UserPreferences(
      brand: brand ?? this.brand,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      storage: storage ?? this.storage,
    );
  }
}

class UserModel {
  String email;
  String username;
  String userId;
  String location;
  String mobile;
  UserPreferences preferences;
  List<String> wishlist;

  UserModel({
    required this.email,
    required this.username,
    required this.userId,
    this.location = '',
    this.mobile = '',
    required this.preferences,
    this.wishlist = const [],
  });

  // Create from Firestore data
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      userId: map['userid'] ?? '',
      location: map['location'] ?? '',
      mobile: map['mobile'] ?? '',
      preferences: UserPreferences.fromMap(map['preferences'] ?? {}),
      wishlist: List<String>.from(map['wishlist'] ?? []),
    );
  }

  // Convert to Firestore data
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'userid': userId,
      'location': location,
      'mobile': mobile,
      'preferences': preferences.toMap(),
      'wishlist': wishlist,
    };
  }
  
  // Create a copy with potentially modified values
  UserModel copyWith({
    String? email,
    String? username,
    String? location,
    String? mobile,
    UserPreferences? preferences,
    List<String>? wishlist,
  }) {
    return UserModel(
      email: email ?? this.email,
      username: username ?? this.username,
      userId: this.userId,
      location: location ?? this.location,
      mobile: mobile ?? this.mobile,
      preferences: preferences ?? this.preferences,
      wishlist: wishlist ?? this.wishlist,
    );
  }
}