// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:elshodaa_mall/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<dynamic> messages = [];
  Timer? timer;
  Timer? timer1;
  String inputMessage = '';
  bool isLoading = false;
  Map<String, dynamic> userData = {};
  late SharedPreferences _prefs;
  ScrollController scrollController = ScrollController();
  File? selectedImage;
  late String base64Image;
  bool pageOpen = false;
  final msgController = TextEditingController();
  ValueNotifier<String> textFieldValue = ValueNotifier<String>('');
  Future<void> fetchMessages() async {
    final response = await http.get(Uri.parse(
        'http://18.218.84.231:8080/api/v1/messages?rootEmail=pharmacygmail.com&clientEmail=${userData['email']}'));

    if (response.statusCode == 200) {
      setState(() {
        messages = json.decode(utf8.decode(response.bodyBytes));
      });
    } else {
      print('Failed to fetch messages. Error: ${response.statusCode}');
    }
  }

  void clearText() {
    msgController.clear();
  }

  Future<void> postDataWithImage() async {
    var url = Uri.parse('http://18.218.84.231:8080/api/v1/messages');
    var headers = {'Content-Type': 'application/json'};
    var body = jsonEncode({
      'emailRoot': 'pharmacygmail.com',
      'emailClient': userData['email'],
      'content': textFieldValue.value,
      'root_sender': false,
      "image": base64Image
    });

    var response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      print('تم إرسال البيانات بنجاح');
    } else {
      print('حدث خطأ أثناء إرسال البيانات');
    }
  }

  Future<void> postDataWithText() async {
    var url = Uri.parse('http://18.218.84.231:8080/api/v1/messages');
    var headers = {'Content-Type': 'application/json'};
    var body = jsonEncode({
      'emailRoot': 'pharmacygmail.com',
      'emailClient': userData['email'],
      'content': textFieldValue.value,
      'root_sender': false,
    });

    var response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      print('تم إرسال البيانات بنجاح');
    } else {
      print('حدث خطأ أثناء إرسال البيانات');
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
      setState(() {
        userData = userData;
      });
      await _prefs.setInt(AppConstants.PHONE, userData['userId'] ?? 0);
    } else {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => const AccountPage(),
      //   ),
      // );
    }
  }

  Future<void> getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        selectedImage = File(pickedImage.path);
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('الصورة المختارة'),
            content: Image.file(selectedImage!), // عرض الصورة المختارة
            actions: [
              TextButton(
                child: const Text('إرسال'),
                onPressed: () {
                  // قم بتحويل الصورة إلى Base64
                  List<int> imageBytes = selectedImage!.readAsBytesSync();
                  base64Image = base64Encode(imageBytes);
                  postDataWithImage();

                  // قم بإرسال الصورة هنا
                  // يمكنك استخدام base64Image كمعلومة إضافية في الرسالة لإرسال الصورة
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    getUserData();
  }

  @override
  void initState() {
    super.initState();
    initSharedPreferences();

    fetchMessages();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      fetchMessages();
    });

    pageOpen = true;
    if (pageOpen) {
      Timer.periodic(const Duration(seconds: 2), (timer1) {
        setState(() {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        });
        timer1.cancel(); // لإيقاف العد التنازلي بعد تنفيذه مرة واحدة
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: CustomColors.customGrey,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(30.0),
              child: ListView.builder(
                itemCount: messages.length,
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 10, bottom: 120),
                itemBuilder: (context, index) {
                  bool isMe = !messages[index]['rootSender'];
                  String message = messages[index]['content'];
                  bool isPicture = messages[index]['picture'];
                  String? picture = messages[index]['imageUrl'];

                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: ChatBubble(
                      clipper: ChatBubbleClipper1(
                        type: isMe
                            ? BubbleType.sendBubble
                            : BubbleType.receiverBubble,
                      ),
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      margin: const EdgeInsets.only(top: 20),
                      backGroundColor: isMe ? Colors.blue : Colors.white,
                      child: isPicture && picture != null
                          ? InkWell(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ShowImage(
                                    imageUrl: messages[index]['imageUrl'],
                                  ),
                                ),
                              ),
                              child: Container(
                                color: Colors.white,
                                width: 200,
                                height: 200,
                                child: Image.network(
                                  picture, // يفترض أن القيمة هنا تحتوي على URL للصورة
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          : Text(
                              message,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width *
                      0.81, // تعيين عرض Container بنسبة مئوية من عرض الشاشة
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.grey.shade300,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.camera_enhance),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('اختر صورة'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        GestureDetector(
                                          child: const Text('الكاميرا'),
                                          onTap: () {
                                            getImage(ImageSource.camera);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        const SizedBox(height: 10),
                                        GestureDetector(
                                          child: const Text('المعرض'),
                                          onTap: () {
                                            getImage(ImageSource.gallery);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                      Expanded(
                        flex: 5,
                        child: TextField(
                          controller: msgController,
                          textAlign: TextAlign.right,
                          decoration: const InputDecoration(
                            hintText: 'اكتب رسالتك...',
                            border: InputBorder.none,
                          ),
                          onChanged: (text) {
                            textFieldValue.value = text;
                          },
                        ),
                      ),
                      const SizedBox(width: 8.0),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    scrollController.animateTo(
                        scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeInBack);
                    postDataWithText();
                    setState(() {
                      scrollController.jumpTo(
                          scrollController.position.maxScrollExtent + 300);
                    });
                    clearText();
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl),
      ),
    );
  }
}
