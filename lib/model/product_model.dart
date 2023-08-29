class Product {
  final int id;
  final String name;
  final int units;
  final double price;
  final String status;
  final String categoryName;
  final String imageUrl;
  // List<Size> sizes;

  Product({
    required this.id,
    required this.name,
    required this.units,
    required this.price,
    required this.status,
    required this.categoryName,
    required this.imageUrl,
    // required this.sizes,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // List<dynamic> sizesJson = json['sizes'];
    return Product(
      id: json['id'],
      name: json['name'],
      units: json['units'],
      price: json['price'].toDouble(),
      status: json['status'],
      categoryName: json['categoryName'],
      imageUrl: json['imageUrl'],
      // sizes: sizesJson.map((sizeJson) => Size.fromJson(sizeJson)).toList(),
    );
  }
}

class Size {
  int id;
  String size;

  Size({
    required this.id,
    required this.size,
  });

  factory Size.fromJson(Map<String, dynamic> json) {
    return Size(
      id: json['id'],
      size: json['size'],
    );
  }
}
