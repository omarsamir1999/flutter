class SignUpBody {
  String name;
  String email;
  String password;
  String phone;
  String address1;

  SignUpBody({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.address1,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["name"] = name;
    data["email"] = email;
    data["password"] = password;
    data["phone"] = phone;
    data["address1"] = address1;
    return data;
  }
}
