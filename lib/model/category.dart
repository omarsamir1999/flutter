class Category {
  int id;
  String name;
  String imageUrl;
  String iconUrl;
  List<Subcategory> subcategories;

  Category(
      {required this.id,
      required this.name,
      required this.imageUrl,
      required this.iconUrl,
      required this.subcategories});

  factory Category.fromJson(Map<String, dynamic> json) {
    var list = json['subcategories'] as List;
    List<Subcategory> subcategoryList =
        list.map((i) => Subcategory.fromJson(i)).toList();
    return Category(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      subcategories: subcategoryList,
      iconUrl: 'iconUrl',
    );
  }
}

class Subcategory {
  int id;
  String name;
  String imageUrl;

  Subcategory({required this.id, required this.name, required this.imageUrl});

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
    );
  }
}
