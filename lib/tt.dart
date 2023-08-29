import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  List<dynamic> _data = [];
  Future<List<dynamic>> fetchData() async {
    final response = await http.get(Uri.parse(
        'http://18.118.26.112:8080/api/v1/product/subcategory/1?pageSize=2000'));

    if (response.statusCode == 200) {
      // تحويل البيانات من صيغة JSON إلى قائمة ديناميكية
      final List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('فشل في تحميل البيانات');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData().then((data) {
      setState(() {
        _data = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('صفحتي'),
      ),
      body: ListView.builder(
        itemCount: _data.length,
        itemBuilder: (context, index) {
          final item = _data[index];
          return ListTile(
            title: Text(item['name']),
            subtitle: Text('السعر: ${item['price']}'),
            // يمكنك إضافة صورة هنا باستخدام حزمة `cached_network_image`
            // إذا كنت ترغب في عرض الصورة المتوفرة في البيانات
          );
        },
      ),
    );
  }
}
