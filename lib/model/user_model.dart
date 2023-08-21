class UserModel {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? activePhone;
  String? address;
  String? role;

  UserModel(
      {this.id,
      this.name,
      this.email,
      this.phone,
      this.activePhone,
      this.address,
      this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phone: json['phone'],
        activePhone: json['activePhone'],
        address: json['address'],
        role: json['role'],
      );
}
