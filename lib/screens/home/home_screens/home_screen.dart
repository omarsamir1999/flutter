import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:elshodaa_mall/constants/colors.dart';
import 'package:elshodaa_mall/screens/ad_state.dart';
import 'package:elshodaa_mall/screens/product_details_screen.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../constants/app_constants.dart';
import '../../../controller/category_controller.dart';
import '../../../controller/product_controller.dart';
import '../../../model/category.dart';
import '../../../model/product_model.dart';
import '../../product_list_page.dart';
import '../../profile_screen.dart';
import '../../special_offers.dart';
import '../../subcategory_screen.dart';
import '../../test.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final adManager = AdManager();

  bool isLoading = false;
  Map<String, dynamic> userData = {};
  String userName = '';
  int coins = 0;
  final ProductController _productController = ProductController();
  late List<Product> _products = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    adManager.addAds(true, true, true);
    fetchProducts();
    initSharedPreferences();
    addAds(true);
    adManager.showInterstitial();
  }

  Future<void> initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();

    getUserData();
  }

  void addAds(bool rewardedAd) {
    if (rewardedAd) {
      loadRewardedAd();
    }
  }

  void fetchProducts() async {
    try {
      final List<Product> products =
          await _productController.fetchProductsBySubcategory(2, 7);
      setState(() {
        _products = products;
      });
    } catch (e) {
      // Handle error
    }
  }

  RewardedAd? _rewardedAd;

  void loadRewardedAd() {
    RewardedAd.load(
        adUnitId: Platform.isAndroid
            ? "ca-app-pub-3666331986165105/2598676046"
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
          print(userData['coins']);
          updateCoins(userData['coins'] + 5).then((_) {
            getUserData();
          });
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

  Future<void> updateCoins(int newCoins) async {
    setState(() {
      isLoading = true;
    });

    String token = _prefs.getString('token') ?? '';
    final url = Uri.parse(
        'http://18.218.84.231:8080/api/v1/user/coins?coins=$newCoins');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'coins': newCoins}),
    );

    if (response.statusCode == 200) {
      setState(() {
        coins = newCoins; // Update the coins value
      });
    } else {
      print('فشل في تحديث قيمة الـ coins. الخطأ: ${response.statusCode}');
    }

    setState(() {
      isLoading = false;
    });
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
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(userData['name']);
    return SingleChildScrollView(
      child: Stack(children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8, left: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    height: 70,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            userData['name'] != null
                                ? "${userData['name']} مرحبا"
                                : "مرحبا",
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              adManager.showInterstitial();
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: AlertDialog(
                                      actions: [
                                        IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                        ),
                                      ],
                                      title: const Text(
                                        'زود نقاطك',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.green),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Center(
                                            child:
                                                Text('الاعلان الواحد = 5 نقاط'),
                                          ),
                                          const Center(
                                            child:
                                                Text('عملية الشراء = 5 نقاط'),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: () {
                                              showRewardedAd();
                                            },
                                            child: const Text('مشاهدة الإعلان'),
                                          ),
                                          const SizedBox(height: 16),
                                          BannerAdmob()
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.monetization_on,
                                  color: Colors.yellow,
                                  size: 25.0,
                                ),
                                Text(
                                  userData['coins'] != null
                                      ? userData['coins'].toString()
                                      : "0",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  ' نقاطي',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AccountPage(),
                              ),
                            );
                            adManager.showInterstitial();
                          },
                          child: userData['gender'] == "انثي"
                              ? const CircleAvatar(
                                  backgroundColor: CustomColors.customGrey,
                                  radius: 20,
                                  backgroundImage: AssetImage(
                                    "assets/images/pngwing.com.png",
                                  ),
                                )
                              : const CircleAvatar(
                                  backgroundColor: CustomColors.customGrey,
                                  radius: 20,
                                  backgroundImage: AssetImage(
                                    "assets/images/pngwing.com (1).png",
                                  ),
                                )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const ProductSearchWidget(),
            const SizedBox(
              height: 20,
            ),
            BannerAdmob(),
            4.heightBox,
            const Padding(
              padding: EdgeInsets.all(17.0),
              child: SpecialOffers(),
            ),
            12.heightBox,
            const MostPopularTitleText(),
            12.heightBox,
            ..._products
                .map((product) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsScreen(
                              productId: product.id,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.6),
                                  offset: const Offset(0, 50),
                                  spreadRadius: 2,
                                  blurRadius: 124),
                            ]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailsScreen(
                                      productId: product.id,
                                    ),
                                  ),
                                );
                                adManager.showInterstitial();
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "جنية "
                                    '${product.price.toStringAsFixed(2)} ',
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 16),
                                  ),
                                  16.widthBox,
                                ],
                              ),
                            ),
                            12.widthBox,
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Image.network(
                                  product.imageUrl,
                                  fit: BoxFit.fill,
                                ).p(8),
                              ),
                            ),
                          ],
                        ).p(8),
                      ).px(16),
                    ))
                .toList(),
            BannerAdmob(),
          ],
        ).py(8),
      ]),
    );
  }
}

class MostPopularTitleText extends StatelessWidget {
  const MostPopularTitleText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        'المنتجات الجديدة'.text.semiBold.xl2.make(),
      ],
    ).px(24);
  }
}

class ProductSearchWidget extends StatefulWidget {
  const ProductSearchWidget({Key? key}) : super(key: key);

  @override
  _ProductSearchWidgetState createState() => _ProductSearchWidgetState();
}

class _ProductSearchWidgetState extends State<ProductSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  void clearText() {
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade100,
            ),
            child: Row(
              children: [
                Flexible(
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          String productName = _searchController.text;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchResultsPage(
                                searchName: productName,
                              ),
                            ),
                          );
                          clearText();
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            CupertinoIcons.search,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 9),
                          child: TextField(
                            textAlign: TextAlign.right,
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: "ابحث عن المنتج",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        16.widthBox,
      ],
    ).px(24);
  }
}

typedef SpecialOffersOnTapSeeAll = void Function();

class SpecialOffers extends StatefulWidget {
  final SpecialOffersOnTapSeeAll? onTapSeeAll;
  const SpecialOffers({Key? key, this.onTapSeeAll}) : super(key: key);

  @override
  State<SpecialOffers> createState() => _SpecialOffersState();
}

class _SpecialOffersState extends State<SpecialOffers> {
  final List<SpecialOffer> specials = homeSpecialOffers;
  bool isLoading = false; // إضافة حالة التحميل
  final adManager = AdManager();

  int selectIndex = 0;
  int? categoryId;
  final CategoryController _categoryController = CategoryController();
  late List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    adManager.addAds(true, true, true);
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _categoryController.fetchCategories();
      setState(() {
        _categories = categories;
        isLoading = true;
        // تعيين حالة التحميل إلى false عند الانتهاء من الاسترداد
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        if (specials.isNotEmpty) // Check if specials list is not empty
          Stack(children: [
            Container(
              height: 181,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 149, 188, 255),
                borderRadius: BorderRadius.all(Radius.circular(32)),
              ),
              child: PageView.builder(
                itemBuilder: (context, index) {
                  if (index >= 0 && index < specials.length) {
                    // Check if index is valid
                    final data = specials[index];
                    return SpecialOfferWidget(context,
                        data: data, index: index);
                  } else {
                    return Container(); // Replace with appropriate fallback widget
                  }
                },
                itemCount: specials.length,
                allowImplicitScrolling: true,
                onPageChanged: (value) {
                  setState(() => selectIndex = value);
                },
              ),
            ),
            _buildPageIndicator(),
          ]),
        const SizedBox(height: 35),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: isLoading
              ? Row(
                  children: List.generate(_categories.length * 2 - 1, (index) {
                    if (index.isOdd) {
                      return const SizedBox(
                          width: 24); // وضع مسافة بنفس العرض بين العناصر
                    }
                    final data = _categories[index ~/ 2];
                    return GestureDetector(
                      onTap: () async {
                        setState(() {
                          categoryId = data.id;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MostPopularScreen(
                              categoryId: categoryId!,
                            ),
                          ),
                        );
                        // await AdsManager.loadUnityIntAd();
                        adManager.showInterstitial();
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.asset(
                                data.imageUrl,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                )
              : const CircularProgressIndicator(),
        )
      ],
    );
  }

  Widget _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < specials.length; i++) {
      list.add(i == selectIndex ? _indicator(true) : _indicator(false));
    }
    return Container(
      height: 181,
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: list,
      ),
    );
  }

  Widget _indicator(bool isActive) {
    return SizedBox(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        height: 4.0,
        width: isActive ? 16 : 4.0,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(2)),
          color: isActive ? const Color(0XFF101010) : const Color(0xFFBDBDBD),
        ),
      ),
    );
  }
}
