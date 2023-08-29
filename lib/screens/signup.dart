import 'dart:convert';
import 'package:elshodaa_mall/screens/profile_screen.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

import '../components/blur_container.dart';
import '../components/buttons.dart';
import '../components/textfields.dart';
import '../constants/images.dart';

class SignUpScreen extends StatefulWidget {
  static const String id = '/signup';
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  String email = '';
  String password = '';
  String name = '';
  String address = '';
  String phone = '';
  String city = "الشهداء";
  String gender = "ذكر";

  bool isLoading = false;
  Map<String, dynamic> userData = {};

  Future<void> sginup() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('http://18.218.84.231:8080/api/v1/auth/register');
    final body = jsonEncode({
      'email': email,
      'password': password,
      'name': name,
      'address': address,
      'gender': gender,
      'city': city,
      'phone': phone,
    });

    final response = await http.post(url, body: body, headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final token = jsonResponse['token'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);
      SharedPreferences prefss = await SharedPreferences.getInstance();
      await prefss.setString('userData', json.encode(userData));

      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AccountPage()),
      );
    } else {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('فشل في تسجيل الدخول'),
            content: Text('رقم الخطأ: ${response.statusCode}'),
            actions: [
              TextButton(
                child: const Text('موافق'),
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

  late AnimationController _blurAnimationController;

  @override
  void initState() {
    _blurAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
      lowerBound: 0,
      upperBound: 45,
    );
    super.initState();
    _blurAnimationController.forward();
    _blurAnimationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _blurAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
            image: AssetImage(
              Images.loginBg,
            ),
            fit: BoxFit.cover,
          )),
        ),
        BlurContainer(value: 50 - _blurAnimationController.value),
        SafeArea(
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                double.infinity.widthBox,
                const Spacer(),
                PrimaryTextField(
                  hintText: 'ألاسم',
                  prefixIcon: Icons.person,
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                ),
                12.heightBox,
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  elevation: 16,
                  shadowColor: Colors.black54,
                  child: TextFormField(
                    validator: (val) =>
                        val!.isEmpty || !val.contains("@gmail.com")
                            ? "enter a valid eamil"
                            : null,
                    textAlign: TextAlign.right,
                    onChanged: (value) => setState(() {
                      email = value;
                    }),
                    controller: null,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(top: 14),
                        suffixIcon: Icon(
                          Icons.email,
                          size: 20,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                        border: InputBorder.none,
                        hintText: 'الايميل',
                        hintStyle: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.normal)),
                  ).px(12).py(2.5),
                ),
                12.heightBox,
                PrimaryTextField(
                  hintText: 'كلمة المرور',
                  isObscure: true,
                  prefixIcon: Icons.key,
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
                12.heightBox,
                PrimaryTextField(
                  hintText: ' العنوان بالتفصيل',
                  prefixIcon: CupertinoIcons.location_solid,
                  onChanged: (value) {
                    setState(() {
                      address = value;
                    });
                  },
                ),
                12.heightBox,
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  elevation: 16,
                  shadowColor: Colors.black54,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.right,
                    onChanged: (value) => setState(() {
                      phone = value;
                    }),
                    controller: null,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(top: 14),
                        suffixIcon: Icon(
                          CupertinoIcons.phone_fill,
                          size: 20,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                        border: InputBorder.none,
                        hintText: 'رقم الهاتف',
                        hintStyle: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.normal)),
                  ).px(12).py(2.5),
                ),
                12.heightBox,
                const Text(
                  "النوع",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  elevation: 20,
                  shadowColor: Colors.black54,
                  child: DropdownButton<String>(
                    underline: Container(),
                    alignment: Alignment.centerRight,
                    value: gender,
                    elevation: 5,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                    items: <String>[
                      'ذكر',
                      'أنثي',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    hint: const Text(
                      "أختار النوع",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        gender = value ?? '';
                      });
                    },
                  ),
                ).px(12).py(2.5),
                12.heightBox,
                const Text(
                  "القريه",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  elevation: 20,
                  shadowColor: Colors.black54,
                  child: DropdownButton<String>(
                    underline: Container(),
                    alignment: Alignment.centerRight,
                    value: city,
                    elevation: 5,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                    items: <String>[
                      'الشهداء',
                      'سرسنا',
                      'ميت شهاله',
                      'دنشواي',
                      'أبو كلس',
                      'ابشادي',
                      'دناصور',
                      'كفر عشما',
                      'عشما',
                      'الجلابطه',
                      'سلامون',
                      'العراقيه',
                      'سرسموس',
                      'كفر سرسموس',
                      'كمشيش',
                      'طوخ',
                      'ميت ابو الكوم',
                      'كفر الجماله',
                      'شمياطس',
                      'س الجوابر',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    hint: const Text(
                      "أختار المدينة",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        city = value ?? '';
                      });
                    },
                  ),
                ).px(12).py(2.5),
                12.heightBox,
                const Spacer(),
                AuthButton(
                    text: 'انشاء حساب',
                    onPressed: () {
                      sginup();
                    }),
              ],
            ).p(24),
          ),
        ),
      ]),
    );
  }

  Column _buildTitleText(BuildContext context) {
    return Column(
      children: [
        Text(
          'Create account',
          softWrap: true,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
