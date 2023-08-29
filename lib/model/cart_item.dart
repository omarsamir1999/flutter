class CartItem {
  final int productId;
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;
  final String? units; // إضافة هذه الخاصية
  final String? size; // إضافة هذه الخاصية

  CartItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    this.units, // تحديد قيمتها هنا
    this.size, // تحديد قيمتها هنا
  });

  // تحديث البناء من JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      price: json['price'].toDouble(),
      quantity: json['quantity'] ?? 1,
      units: json['units'], // استخراج الوحدات من JSON
      size: json['size'], // استخراج الحجم من JSON
    );
  }

  // تحديث التحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'units': units, // تحويل الوحدات إلى JSON
      'size': size, // تحويل الحجم إلى JSON
    };
  }
}
