import 'dart:convert';
import 'dart:io';
import 'package:elshodaa_mall/screens/product_details_screen.dart';
import 'package:elshodaa_mall/screens/test.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;

class SearchResultsPage extends StatefulWidget {
  final String searchName;

  const SearchResultsPage({Key? key, required this.searchName})
      : super(key: key);

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  NativeAd? _nativeAd;

  bool _nativeAdIsLoaded = false;
  String? _versionString;
  // final double _adAspectRatioSmall = (91 / 355);
  final double _adAspectRatioMedium = (370 / 355);

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110'
      : 'ca-app-pub-3940256099942544/3986624511';

  List<dynamic> _products = [];
  bool _isLoading = true;
  int _page = 0;

  ScrollController _scrollController = ScrollController();
  void _loadAd() {
    setState(() {
      _nativeAdIsLoaded = false;
    });

    _nativeAd = NativeAd(
        adUnitId: _adUnitId,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            // ignore: avoid_print
            print('$NativeAd loaded.');
            setState(() {
              _nativeAdIsLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            // ignore: avoid_print
            print('$NativeAd failedToLoad: $error');
            ad.dispose();
          },
          onAdClicked: (ad) {},
          onAdImpression: (ad) {},
          onAdClosed: (ad) {},
          onAdOpened: (ad) {},
          onAdWillDismissScreen: (ad) {},
          onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
        ),
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
            templateType: TemplateType.medium,
            mainBackgroundColor: const Color(0xfffffbed),
            callToActionTextStyle: NativeTemplateTextStyle(
                textColor: Colors.white,
                style: NativeTemplateFontStyle.monospace,
                size: 16.0),
            primaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.black,
                style: NativeTemplateFontStyle.bold,
                size: 16.0),
            secondaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.black,
                style: NativeTemplateFontStyle.italic,
                size: 16.0),
            tertiaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.black,
                style: NativeTemplateFontStyle.normal,
                size: 16.0)))
      ..load();
  }

  void _loadVersionString() {
    MobileAds.instance.getVersionString().then((value) {
      setState(() {
        _versionString = value;
      });
    });
  }

  @override
  void initState() {
    _nativeAd?.dispose();
    _nativeAd?.load();
    super.initState();
    _loadAd();

    _loadVersionString();
    _searchProducts(widget.searchName, _page);

    // استمع لحدث التمرير وفحص إذا كان المُستخدم قد وصل إلى نهاية القائمة
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // قم بزيادة رقم الصفحة واستدعاء البيانات الجديدة
        setState(() {
          _page++;
        });
        _searchProducts(widget.searchName, _page);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  Future<void> _searchProducts(String name, int page) async {
    String apiUrl =
        'http://18.218.84.231:8080/api/v1/product/findByName/$name?page=$page&pageSize=500';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          if (page == 0) {
            // إذا كانت الصفحة الأولى، قم بتعيين البيانات المسترجعة مكان البيانات الحالية
            _products = jsonDecode(utf8.decode(response.bodyBytes));
          } else {
            // إذا كانت الصفحة غير الأولى، قم بإضافة البيانات المسترجعة إلى البيانات الحالية
            _products.addAll(jsonDecode(utf8.decode(response.bodyBytes)));
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    int itemCountWithAds = _products.length ~/ 4;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: _products.length + itemCountWithAds,
              itemBuilder: (context, index) {
                if (index % 5 == 4) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BannerAdmob(),
                  );
                }

                final productIndex = index - (index ~/ 5);
                final product = _products[productIndex];
                final name = product['name'];
                final price = product['price'];
                final image = product['imageUrl'];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailsScreen(productId: product['id']),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Card(
                          elevation: 7,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: 160,
                                      child: Text(
                                        name,
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'جنية ${price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    image,
                                    width: 160,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
