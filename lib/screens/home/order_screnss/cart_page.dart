import 'dart:convert';
import 'dart:io';
import 'package:elshodaa_mall/screens/home/main_home.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/connect.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../constants/app_constants.dart';
import '../../../model/cart_item.dart';
import '../../ad_state.dart';
import '../../login.dart';
import '../../test.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int counter = 0;
  List<CartItem> _cartItems = [];
  final adManager = AdManager();
  late String city = "";
  late SharedPreferences _prefs;
  int coins = 0;
  int deliveryVideoPrice = 10;
  Future<void> initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    // Call the methods that require _prefs initialization
    fetchUserData();
    setState(() {
      if (city == "الشهداء" || city == "سرسنا" || city == "ميت شهاله") {
        deliveryPrice = 5;
      } else if (city == "دنشواي") {
        deliveryPrice = 15;
        deliveryVideoPrice = 10;
      } else if (city == "أبو كلس" || city == "الجلابطه") {
        deliveryPrice = 18;
        deliveryVideoPrice = 14;
      } else if (city == "كفر سرسموس" || city == "ابشادي") {
        deliveryPrice = 26;
        deliveryVideoPrice = 22;
      } else if (city == "دناصور") {
        deliveryPrice = 24;
        deliveryVideoPrice = 20;
      } else if (city == "كفر عشما") {
        deliveryPrice = 12;
        deliveryVideoPrice = 8;
      } else if (city == "عشما" || city == "كفر الجماله" || city == "شمياطس") {
        deliveryPrice = 17;
        deliveryVideoPrice = 13;
      } else if (city == "سلامون" || city == "كمشيش") {
        deliveryPrice = 20;
        deliveryVideoPrice = 15;
      } else if (city == "العراقيه" || city == "سرسموس") {
        deliveryPrice = 25;
        deliveryVideoPrice = 20;
      } else if (city == "س الجوابر") {
        deliveryPrice = 22;
        deliveryVideoPrice = 17;
      }
    });
  }

  void fetchUserData() {
    final Map<String, dynamic> userData =
        json.decode(_prefs.getString('userData') ?? '');
    city = userData['city'] ?? '';
    setState(() {
      coins = userData['coins'] ?? 0;
    });
  }

  Future<void> getCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cartList = prefs.getStringList('cartItems');
    if (cartList != null) {
      setState(() {
        _cartItems = cartList
            .map((item) => CartItem.fromJson(json.decode(item)))
            .toList();
      });
    }
  }

  int deliveryPrice = 0;
  Future<void> sendPostRequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var connect = GetConnect();
    List<dynamic> orderItems = [];
    if (prefs.getInt(AppConstants.PHONE) != null) {
      for (var cartItem in _cartItems) {
        orderItems.add({
          "productId": cartItem.productId,
          "quantity": cartItem.quantity,
          "details": cartItem.size ?? cartItem.units ?? ""
        });
      }
      await connect.post('http://18.218.84.231:8080/api/v1/order', {
        "userId": prefs.getInt(AppConstants.PHONE),
        "orderItemDtoList": orderItems,
        "deliveryPrice": deliveryPrice,
      });

      // clear cartItems after successful checkout
      await prefs.remove('cartItems');

      setState(() {
        _cartItems = []; // update the cart items list
      });
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => const LoginScreen()),
      );
    }
  }

  bool isLoading = false;
  Future<void> updateCoins(int coins) async {
    setState(() {
      isLoading = true;
    });
    _prefs.getInt(AppConstants.PHONE) ?? 0;

    String token = _prefs.getString('token') ?? '';
    final url =
        Uri.parse('http://18.218.84.231:8080/api/v1/user/coins?coins=$coins');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'coins': coins}),
    );

    if (response.statusCode == 200) {
      print('تم تحديث قيمة الـ coins بنجاح');
    } else {
      print('فشل في تحديث قيمة الـ coins. الخطأ: ${response.statusCode}');
    }
  }

  RewardedAd? _rewardedAd;
  void loadRewardedAd() {
    RewardedAd.load(
        adUnitId: Platform.isAndroid
            ? "ca-app-pub-3940256099942544/5224354917"
            : "ca-app-pub-3940256099942544/5224354917",
        request: const AdRequest(),
        rewardedAdLoadCallback:
            RewardedAdLoadCallback(onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
        }, onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
        }));
  }

  void showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (RewardedAd ad) {
          print("Ad onAdShowedFullScreenContent");
        },
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          ad.dispose();
          loadRewardedAd();
          sendPostRequest();
          updateCoins(coins + 5);
          Navigator.of(context).pop();
          // Call sendPostRequest after the rewarded ad is dismissed
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          ad.dispose();
          loadRewardedAd();
        },
      );

      _rewardedAd!.setImmersiveMode(true);
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {},
      );
    }
  }

  Future<void> removeFromCart(int productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cartList = prefs.getStringList('cartItems');
    if (cartList != null) {
      List<CartItem> updatedCartItems =
          cartList.map((item) => CartItem.fromJson(json.decode(item))).toList();
      updatedCartItems.removeWhere((item) => item.productId == productId);
      List<String> updatedCartList =
          updatedCartItems.map((item) => json.encode(item.toJson())).toList();
      await prefs.setStringList('cartItems', updatedCartList);
      getCartItems();
    }
  }

  void addAds(bool rewardedAd) {
    if (rewardedAd) {
      loadRewardedAd();
    }
  }

  @override
  void initState() {
    super.initState();
    getCartItems();
    addAds(true);
    initSharedPreferences();
  }

  @override
  void dispose() {
    adManager.disposeAds();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(deliveryPrice);
    double totalPrice =
        _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (ModalRoute.of(context)!.settings.name == '/product_details') {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserDashboard(),
                ),
              );
            }
          },
        ),
      ),
      body: _cartItems.isNotEmpty
          ? Column(
              children: [
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = _cartItems[index];
                      double totalPrice = cartItem.price * cartItem.quantity;
                      return ListTile(
                        leading: Image.network(
                          cartItem.imageUrl,
                          fit: BoxFit.contain,
                          width: 100,
                          height: 200,
                        ),
                        title: Text(
                          cartItem.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Price: \$${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            removeFromCart(cartItem.productId);
                          },
                        ),
                      );
                    },
                  ),
                ),
                BannerAdmob(),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[200],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'القيمه الاجماليه: ${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () {
                          if (totalPrice > 50 &&
                              (city == "الشهداء" ||
                                  city == "سرسنا" ||
                                  city == "ميت شهاله")) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  actions: [
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                    )
                                  ],
                                  title: const Text('طلب الأوردر '),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                          'شاهد الاعلان واحصل علي توصيل مجاني '),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          deliveryPrice = 0;

                                          setState(() {
                                            counter++;
                                            if (counter > 3) {
                                              updateCoins(coins + 5);
                                              sendPostRequest();
                                              Navigator.of(context).pop();
                                            } else {
                                              showRewardedAd();
                                            }
                                          });
                                        },
                                        child: const Text('مشاهدة الإعلان'),
                                      ),
                                      Text(
                                          "اطلب الاوردر مقابل $deliveryPrice جنيه توصيل "),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          updateCoins(coins + 5);
                                          sendPostRequest();
                                        },
                                        child: const Text('أطلب الأن'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          } else if (totalPrice < 50 &&
                              (city == "الشهداء" ||
                                  city == "سرسنا" ||
                                  city == "ميت شهاله")) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  actions: [
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                    )
                                  ],
                                  title: const Text('طلب الأوردر '),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                          "اطلب الاوردر مقابل $deliveryPrice جنيه توصيل "),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          updateCoins(coins + 5);
                                          sendPostRequest();
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('أطلب الأن'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          } else if (totalPrice < 100 &&
                              (city != "الشهداء" ||
                                  city != "سرسنا" ||
                                  city != "ميت شهاله")) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  actions: [
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                    )
                                  ],
                                  title: const Text('طلب الأوردر '),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                          "اطلب الاوردر مقابل $deliveryPrice جنيه توصيل "),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            if (city == "دنشواي") {
                                              deliveryPrice = 15;
                                            } else if (city == "أبو كلس" ||
                                                city == "الجلابطه") {
                                              deliveryPrice = 18;
                                            } else if (city == "كفر سرسموس" ||
                                                city == "ابشادي") {
                                              deliveryPrice = 26;
                                            } else if (city == "دناصور") {
                                              deliveryPrice = 24;
                                            } else if (city == "كفر عشما") {
                                              deliveryPrice = 12;
                                            } else if (city == "عشما" ||
                                                city == "كفر الجماله" ||
                                                city == "شمياطس") {
                                              deliveryPrice = 17;
                                            } else if (city == "سلامون" ||
                                                city == "كمشيش") {
                                              deliveryPrice = 20;
                                            } else if (city == "العراقيه" ||
                                                city == "سرسموس") {
                                              deliveryPrice = 25;
                                            } else if (city == "س الجوابر") {
                                              deliveryPrice = 22;
                                            }
                                          });
                                          updateCoins(coins + 5);
                                          sendPostRequest();
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('أطلب الأن'),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      const Text(
                                          "يتم اضافه جنيه على كل محل عند الشراء من أكثر من محل"),
                                    ],
                                  ),
                                );
                              },
                            );
                          } else if (totalPrice > 100 &&
                              (city != "الشهداء" ||
                                  city != "سرسنا" ||
                                  city != "ميت شهاله")) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  actions: [
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                    )
                                  ],
                                  title: const Text('طلب الأوردر '),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                          'شاهد الاعلان واحصل علي توصيل مقابل $deliveryVideoPrice جنيه توصيل '),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            if (city == "دنشواي") {
                                              deliveryPrice = 10;
                                            } else if (city == "أبو كلس" ||
                                                city == "الجلابطه") {
                                              deliveryPrice = 14;
                                            } else if (city == "كفر سرسموس" ||
                                                city == "ابشادي") {
                                              deliveryPrice = 22;
                                            } else if (city == "دناصور") {
                                              deliveryPrice = 20;
                                            } else if (city == "كفر عشما") {
                                              deliveryPrice = 8;
                                            } else if (city == "عشما" ||
                                                city == "كفر الجماله" ||
                                                city == "شمياطس") {
                                              deliveryPrice = 13;
                                            } else if (city == "سلامون" ||
                                                city == "كمشيش") {
                                              deliveryPrice = 15;
                                            } else if (city == "العراقيه" ||
                                                city == "سرسموس") {
                                              deliveryPrice = 20;
                                            } else if (city == "س الجوابر") {
                                              deliveryPrice = 17;
                                            }
                                          });
                                          setState(() {
                                            counter++;
                                            if (counter > 3) {
                                              updateCoins(coins + 5);
                                              sendPostRequest();
                                              Navigator.of(context).pop();
                                            } else {
                                              showRewardedAd();
                                            }
                                          });
                                        },
                                        child: const Text('مشاهدة الإعلان'),
                                      ),
                                      Text(
                                          "اطلب الاوردر مقابل $deliveryPrice جنيه توصيل "),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            if (city == "دنشواي") {
                                              deliveryPrice = 15;
                                            } else if (city == "أبو كلس" ||
                                                city == "الجلابطه") {
                                              deliveryPrice = 18;
                                            } else if (city == "كفر سرسموس" ||
                                                city == "ابشادي") {
                                              deliveryPrice = 26;
                                            } else if (city == "دناصور") {
                                              deliveryPrice = 24;
                                            } else if (city == "كفر عشما") {
                                              deliveryPrice = 12;
                                            } else if (city == "عشما" ||
                                                city == "كفر الجماله" ||
                                                city == "شمياطس") {
                                              deliveryPrice = 17;
                                            } else if (city == "سلامون" ||
                                                city == "كمشيش") {
                                              deliveryPrice = 20;
                                            } else if (city == "العراقيه" ||
                                                city == "سرسموس") {
                                              deliveryPrice = 25;
                                            } else if (city == "س الجوابر") {
                                              deliveryPrice = 22;
                                            }
                                          });
                                          updateCoins(coins + 5);
                                          sendPostRequest();
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('أطلب الأن'),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      const Text(
                                          "يتم اضافه جنيه على كل محل عند الشراء من أكثر من محل"),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        },
                        child: const Text('أطلب ألان'),
                      ),
                    ],
                  ),
                )
              ],
            )
          : const Center(
              child: Text(
                'عربة التسوق فارغه',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}
