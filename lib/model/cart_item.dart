class CartItem {
  final int productId;
  final String name;
  final String image;
  final double price;
  final int quantity;
  final String? units; // إضافة هذه الخاصية
  final String? size; // إضافة هذه الخاصية

  CartItem({
    required this.productId,
    required this.name,
    required this.image,
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
      image: json['image'],
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
      'image': image,
      'price': price,
      'quantity': quantity,
      'units': units, // تحويل الوحدات إلى JSON
      'size': size, // تحويل الحجم إلى JSON
    };
  }
}
