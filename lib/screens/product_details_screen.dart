import 'dart:convert';
import 'package:elshodaa_mall/screens/test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

import '../components/buttons.dart';
import '../model/cart_item.dart';
import '../model/product_model.dart';
import 'ad_state.dart';
import 'home/cart_page.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({Key? key, required this.productId})
      : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final adManager = AdManager();

  String? units;
  String? size;

  Product? _product;
  int _quantity = 1;
  Future<Product> fetchProductById(int productId) async {
    final response = await http
        .get(Uri.parse('http://18.217.249.168:8080/api/v1/product/$productId'));
    if (response.statusCode == 200) {
      final responseData = json.decode(utf8.decode(response.bodyBytes));
      return Product.fromJson(responseData);
    } else {
      throw Exception('Failed to fetch product');
    }
  }

  Future<void> addToCart(Product product, int quantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cartList = prefs.getStringList('cartItems');
    List<CartItem> cartItems = [];
    if (cartList != null) {
      cartItems =
          cartList.map((item) => CartItem.fromJson(json.decode(item))).toList();
    }

    // تحقق من القيم المختارة للوحدات والحجم
    String? selectedUnits = units;
    String? selectedSize = size;

    CartItem cartItem = CartItem(
      productId: product.id,
      name: product.name,
      image: product.image,
      price: product.price,
      quantity: quantity,
      units: selectedUnits, // قيمة الوحدات المختارة
      size: selectedSize, // قيمة الحجم المختارة
    );
    cartItems.add(cartItem);

    // تحديث قائمة العناصر في ذاكرة التخزين المؤقتة
    List<String> updatedCartList =
        cartItems.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList('cartItems', updatedCartList);

    double totalPrice =
        cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);
    await prefs.setDouble('totalPrice', totalPrice);
  }

  @override
  void initState() {
    super.initState();
    fetchProductById(widget.productId).then((product) {
      setState(() {
        _product = product;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    late double priceUnits = _product!.price / _product!.units;
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 5,
              child: _product != null
                  ? Container(
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Colors.white],
                      )),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: Image.memory(
                                      base64Decode(_product!.image),
                                      fit: BoxFit.contain,
                                      height: 250,
                                      width: double.infinity,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _product!.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                  _product?.categoryName == "pharmacy"
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              child: DropdownButton<String>(
                                                underline: Container(),
                                                alignment:
                                                    Alignment.centerRight,
                                                value: units,
                                                elevation: 5,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                items: <String>[
                                                  'علبة',
                                                  '"شريط/أمبول"',
                                                ].map<DropdownMenuItem<String>>(
                                                    (String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                                hint: const Text(
                                                  "أختار الوحده",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                onChanged: (String? value) {
                                                  setState(() {
                                                    units = value ?? '';
                                                  });
                                                },
                                              ),
                                            ).px(12).py(2.5),
                                          ],
                                        )
                                      : const SizedBox(
                                          height: 0,
                                        ),
                                  const SizedBox(height: 16),
                                  _product?.categoryName == "shop1" ||
                                          _product?.categoryName == "zidan" ||
                                          _product?.categoryName == "Cute" ||
                                          _product?.categoryName == "frinds" ||
                                          _product?.categoryName == "sila"
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25)),
                                              child: DropdownButton<String>(
                                                underline: Container(),
                                                value: size,
                                                elevation: 8,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                items: _product!.sizes.map<
                                                    DropdownMenuItem<String>>(
                                                  (Size size) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: size.size,
                                                      child: Text(
                                                        size.size,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    );
                                                  },
                                                ).toList(),
                                                hint: const Text(
                                                  "اختر الحجم",
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                onChanged: (String? value) {
                                                  setState(() {
                                                    size = value;
                                                  });
                                                },
                                              ),
                                            ).px(12).py(2.5),
                                          ],
                                        )
                                      : const SizedBox(
                                          height: 0,
                                        ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  topRight: Radius.circular(32),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 35,
                                        child: IconButton(
                                          padding: const EdgeInsets.all(0),
                                          onPressed: () {
                                            setState(() {
                                              if (_quantity > 1) _quantity -= 1;
                                            });
                                          },
                                          icon: const Icon(
                                            CupertinoIcons.minus_circle,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                      _quantity.text.xl.semiBold.make(),
                                      SizedBox(
                                        width: 35,
                                        child: IconButton(
                                          padding: const EdgeInsets.all(0),
                                          onPressed: () {
                                            setState(() {
                                              _quantity += 1;
                                            });
                                          },
                                          icon: const Icon(
                                            CupertinoIcons.plus_circle,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      units == "شريط/أمبول"
                                          ? Text(
                                              ' جنيه ${priceUnits * _quantity}',
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.redAccent),
                                            )
                                          : Text(
                                              ' جنيه ${_product!.price * _quantity}',
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.redAccent),
                                            ),
                                    ],
                                  ).px(8),
                                  24.heightBox,
                                  PrimaryShadowedButton(
                                    onPressed: () {
                                      adManager.showInterstitial();
                                      addToCart(_product!, _quantity);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const CartScreen()),
                                      );
                                    },
                                    borderRadius: 16,
                                    color: Colors.black,
                                    child: 'اضافة الي عربة التسوق'
                                        .text
                                        .xl2
                                        .white
                                        .makeCentered()
                                        .py(16),
                                  ),
                                  16.heightBox,
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: BannerAdmob(),
            )
          ],
        ));
  }
}
