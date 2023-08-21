import 'dart:convert';
import 'package:elshodaa_mall/screens/test.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../constants/colors.dart';
import 'ad_state.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  int _selectedIndex = 0;
  List<bool> _selections = [true, false];
  List<Map<String, dynamic>> _ordersPending = [];
  List<Map<String, dynamic>> _ordersDelivered = [];
  final adManager = AdManager();

  @override
  void initState() {
    super.initState();
    adManager.addAds(true, true, true);
    adManager.showInterstitial();
    fetchOrdersPending();
    fetchOrdersDelivered();
  }

  Future<void> fetchOrdersPending() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getInt(AppConstants.PHONE));

    try {
      final response = await http.get(
        Uri.parse(
            'http://18.118.26.112:8080/api/v1/order/pending/orderbyuser/${prefs.getInt(AppConstants.PHONE)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        setState(() {
          _ordersPending = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print('Failed to fetch orders. Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Failed to fetch orders. Error: $error');
    }
  }

  Future<void> fetchOrdersDelivered() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getInt(AppConstants.PHONE));

    try {
      final response = await http.get(
        Uri.parse(
            'http://18.118.26.112:8080/api/v1/order/delivered/orderbyuser/${prefs.getInt(AppConstants.PHONE)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        setState(() {
          _ordersDelivered = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print('Failed to fetch orders. Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Failed to fetch orders. Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        const SizedBox(
          height: 30,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ToggleButtons(
            borderColor: Colors.black,
            borderRadius: BorderRadius.circular(8),
            borderWidth: 2,
            selectedBorderColor: Colors.black,
            selectedColor: Colors.white,
            color: Colors.black,
            fillColor: Colors.black,
            isSelected: _selections,
            onPressed: (index) {
              setState(() {
                adManager.showInterstitial();

                _selectedIndex = index;
                _selections = List.generate(2, (i) => i == index);
              });
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Orders in Delivery'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Completed Orders'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
            child: _selectedIndex == 0
                ? (_ordersPending.isEmpty
                    ? Center(
                        child: Column(
                          children: [
                            const Center(
                              child: CircularProgressIndicator(
                                color: CustomColors.customGrey,
                              ),
                            ),
                            BannerAdmob()
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _ordersPending.length,
                        itemBuilder: (context, index) {
                          final order = _ordersPending[index];
                          final List<dynamic> orderItems = order['orderItems'];
                          return Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40)),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Card(
                                elevation: 7,
                                shadowColor: Colors.black,
                                child: ListTile(
                                  title: Column(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: 'Date: ',
                                          style: const TextStyle(
                                              color: Colors.black),
                                          children: [
                                            TextSpan(
                                              text: '${order['date']}',
                                              style: const TextStyle(
                                                  color: Colors.blue),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                      const SizedBox(height: 8),
                                      RichText(
                                        text: TextSpan(
                                          text: 'Order Status: ',
                                          style: const TextStyle(
                                              color: Colors.black),
                                          children: [
                                            TextSpan(
                                              text: '${order['orderStatus']}',
                                              style: const TextStyle(
                                                  color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: orderItems.length,
                                    itemBuilder: (context, itemIndex) {
                                      final orderItem = orderItems[itemIndex];
                                      final product = orderItem['product'];
                                      return ListTile(
                                        leading: GestureDetector(
                                          onTap: () {
                                            // تكبير الصورة عند الضغط عليها
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.memory(
                                              base64Decode(product['image']),
                                              fit: BoxFit.cover,
                                              width: 100,
                                              height: 100,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          product['name'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Price: ${product['price']}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ))
                : _ordersDelivered.isEmpty
                    ? Center(
                        child: Column(
                          children: [
                            const Center(
                              child: CircularProgressIndicator(
                                color: CustomColors.customGrey,
                              ),
                            ),
                            BannerAdmob()
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: _ordersDelivered.length,
                          itemBuilder: (context, index) {
                            final order = _ordersDelivered[index];
                            final List<dynamic> orderItems =
                                order['orderItems'];
                            return Card(
                              elevation: 7,
                              shadowColor: Colors.black,
                              child: ListTile(
                                title: Column(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: 'Date: ',
                                        style: const TextStyle(
                                            color: Colors.black),
                                        children: [
                                          TextSpan(
                                            text: '${order['date']}',
                                            style: const TextStyle(
                                                color: Colors.blue),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    const SizedBox(height: 8),
                                    RichText(
                                      text: TextSpan(
                                        text: 'Order Status: ',
                                        style: const TextStyle(
                                            color: Colors.black),
                                        children: [
                                          TextSpan(
                                            text: '${order['orderStatus']}',
                                            style: const TextStyle(
                                                color: Colors.green),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: orderItems.length,
                                  itemBuilder: (context, itemIndex) {
                                    final orderItem = orderItems[itemIndex];
                                    final product = orderItem['product'];
                                    return ListTile(
                                      leading: GestureDetector(
                                        onTap: () {
                                          // تكبير الصورة عند الضغط عليها
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.memory(
                                            base64Decode(product['image']),
                                            fit: BoxFit.cover,
                                            width: 72,
                                            height: 72,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        product['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Price: ${product['price']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      )),
      ]),
    );
  }
}
