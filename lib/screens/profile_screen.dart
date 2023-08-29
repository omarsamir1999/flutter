import 'dart:convert';
import 'package:elshodaa_mall/screens/test.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

import '../constants/app_constants.dart';
import '../constants/colors.dart';
import '../constants/images.dart';
import 'home/main_home.dart';
import 'login.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool isLoading = false;
  Map<String, dynamic> userData = {};
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
    checkUserLogin();
  }

  Future<void> initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> checkUserLogin() async {
    await initSharedPreferences();

    String token = _prefs.getString('token') ?? '';

    if (token.isEmpty) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => const LoginScreen()),
      );
    } else {
      getUserData();
    }
  }

  Future<void> getUserData() async {
    setState(() {
      isLoading = true;
    });
    _prefs.getInt(AppConstants.PHONE) ?? 0;

    String token = _prefs.getString('token') ?? '';

    final url = Uri.parse('http://18.218.84.231:8080/api/v1/user');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      userData = json.decode(utf8.decode(response.bodyBytes));
      await _prefs.setString('userData', json.encode(userData));
      // Save user data in userData state variable
      setState(() {
        userData = userData;
      });
      // Save userData['userId'] value in AppConstants.PHONE variable
      await _prefs.setInt(AppConstants.PHONE, userData['userId'] ?? 0);
    } else {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Failed to fetch data'),
            content: Text('Error code: ${response.statusCode}'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userData');
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (BuildContext context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserDashboard()),
            );
          },
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: CustomColors.customGrey,
              ),
            )
          : Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage(
                      Images.loginBg,
                    ),
                    fit: BoxFit.cover,
                  )),
                ),
                Column(
                  children: [
                    const CircleAvatar(
                      radius: 80,
                      backgroundImage: AssetImage(
                        "assets/images/boy-icon-png-10.jpg",
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      color: Colors.white, // لون البطاقة
                      shadowColor: Colors.grey, // لون الظل
                      elevation: 4, // ارتفاع الظل
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // شكل الزوايا
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.person,
                          color: Colors.blue, // لون الأيقونة
                          size: 30, // حجم الأيقونة
                        ),
                        title: const Text(
                          'الاسم',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        subtitle: Text(
                          userData['name'] ?? '',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      shadowColor: Colors.grey,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.email,
                          color: Colors.red, // لون الأيقونة
                          size: 30, // حجم الأيقونة
                        ),
                        title: const Text(
                          'الايميل',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        subtitle: Text(
                          userData['email'] ?? '',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      shadowColor: Colors.grey,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.location_on,
                          color: Colors.green, // لون الأيقونة
                          size: 30, // حجم الأيقونة
                        ),
                        title: const Text(
                          'العنوان',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        subtitle: Text(
                          userData['address'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      shadowColor: Colors.grey,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.phone,
                          color: Colors.orange, // لون الأيقونة
                          size: 30, // حجم الأيقونة
                        ),
                        title: const Text(
                          'رقم الهاتف',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        subtitle: Text(
                          userData['phone'] ?? '',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                    BannerAdmob()
                  ],
                ).p(24),
              ],
            ),
    );
  }
}
