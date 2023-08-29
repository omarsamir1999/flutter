import 'dart:convert';
import 'package:elshodaa_mall/screens/profile_screen.dart';
import 'package:elshodaa_mall/screens/signup.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:velocity_x/velocity_x.dart';

import '../components/blur_container.dart';
import '../components/buttons.dart';
import '../components/textfields.dart';
import '../constants/images.dart';
import 'home/main_home.dart';

class LoginScreen extends StatefulWidget {
  static const String id = '/login';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _blurAnimationController;

  @override
  void initState() {
    _blurAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
      lowerBound: 0,
      upperBound: 6,
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

  String email = '';
  String password = '';
  bool isLoading = false;
  Map<String, dynamic> userData = {};

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('http://18.218.84.231:8080/api/v1/auth/authenticate');
    final body = jsonEncode({
      'email': email,
      'password': password,
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

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AccountPage()),
      );
    } else {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserDashboard(),
                ),
              );
            }),
      ),
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
        BlurContainer(value: _blurAnimationController.value),
        SafeArea(
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                double.infinity.widthBox,
                const Spacer(),
                const Spacer(),
                _buildTitleText(context),
                const Spacer(),
                PrimaryTextField(
                  hintText: 'الأيميل',
                  prefixIcon: Icons.person,
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                ),
                24.heightBox,
                PrimaryTextField(
                  hintText: 'كلمة المرور',
                  isObscure: true,
                  prefixIcon: CupertinoIcons.padlock,
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      style: const ButtonStyle(),
                      child: const Text(
                        'نسيت كلمة المرور?',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    24.widthBox,
                  ],
                ),
                const Spacer(),
                AuthButton(
                    text: 'تسجيل الدخول',
                    onPressed: () {
                      login();
                    }),
                const Spacer(),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: 'هل لديك حساب ?  ',
                        style: TextStyle(
                            fontSize: 17,
                            color: Theme.of(context).colorScheme.onBackground)),
                    TextSpan(
                        text: 'انشاء حساب',
                        style: TextStyle(
                            fontSize: 17,
                            color: Theme.of(context).colorScheme.onBackground,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).pushNamed(SignUpScreen.id);
                          }),
                  ]),
                ),
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
          'مرحبا',
          softWrap: true,
          style: TextStyle(
              fontSize: 85,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onBackground),
        ),
        Text(
          'تسجيل الدخول الي حسابك',
          softWrap: true,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}
