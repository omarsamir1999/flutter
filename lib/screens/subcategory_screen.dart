import 'dart:async';
import 'dart:convert';
import 'package:elshodaa_mall/screens/product_details_screen.dart';
import 'package:elshodaa_mall/screens/product_list_page.dart';
import 'package:elshodaa_mall/screens/test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rxdart/rxdart.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../controller/category_controller.dart';
import '../../controller/product_controller.dart';
import '../../model/category.dart';
import '../../model/product_model.dart';
import 'ad_state.dart';

class MostPopularScreen extends StatefulWidget {
  final int categoryId;

  const MostPopularScreen({Key? key, required this.categoryId})
      : super(key: key);

  @override
  _MostPopularScreenState createState() => _MostPopularScreenState();
}

class _MostPopularScreenState extends State<MostPopularScreen> {
  final TextEditingController _searchController = TextEditingController();

  final adManager = AdManager();

  late BehaviorSubject<List<Product>> _productStreamController;
  Stream<List<Product>> get _productStream => _productStreamController.stream;

  int _selectedIndex = 0;
  List<Category> categories = [];
  List<Subcategory> subcategories = [];
  int currentPage = 0;
  int totalPages = 200;
  final ScrollController _scrollController = ScrollController();
  List<bool> subcategoryLoadingStates = [];
  bool isLoading = false;
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  @override
  void initState() {
    super.initState();

    fetchCategories();
    adManager.addAds(true, true, true);
    _bannerAd = BannerAd(
        adUnitId: "ca-app-pub-3666331986165105/7356153486",
        size: AdSize.banner,
        listener: BannerAdListener(onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        }, onAdFailedToLoad: ((ad, error) {
          print("faild to load ads ${error.message}");
          _isBannerAdReady = false;
          ad.dispose();
        })),
        request: const AdRequest())
      ..load();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        loadMoreProducts();
      }
    });

    _productStreamController = BehaviorSubject<List<Product>>.seeded([]);
  }

  @override
  void dispose() {
    _productStreamController.close();
    super.dispose();
  }

  Future<void> fetchCategories() async {
    try {
      List<Category> fetchedCategories =
          await CategoryController().fetchCategories();
      setState(() {
        categories = fetchedCategories;
        Category selectedCategory = categories.firstWhere(
          (category) => category.id == widget.categoryId,
          orElse: () => categories[0],
        );
        subcategories = selectedCategory.subcategories;
        subcategoryLoadingStates =
            List.generate(subcategories.length, (index) => false);

        if (subcategories.isNotEmpty) {
          fetchProducts(subcategories[0].id, 0);
          currentPage = 0;
        }
      });
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> fetchProducts(int subcategoryId, int page) async {
    setState(() {
      isLoading = true;
      if (page == 0) {
        _productStreamController
            .add([]); // Clear the previous products on the first page
      }
    });

    try {
      List<Product> fetchedProducts = await ProductController()
          .fetchProductsBySubcategory(subcategoryId, page);
      setState(() {
        if (page == 0) {
          _productStreamController.add(fetchedProducts);
        } else {
          List<Product> updatedProducts =
              _productStreamController.value + fetchedProducts;
          _productStreamController.add(updatedProducts);
        }
        isLoading = false;
      });
    } catch (error) {
      print('Error: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  void loadMoreProducts() {
    if (!isLoading && currentPage < totalPages) {
      int nextPage = currentPage + 1;
      for (int i = 0; i < 10; i++) {
        fetchProducts(subcategories[_selectedIndex].id, nextPage + i);
      }
      setState(() {
        currentPage = nextPage + 3;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSubcategoryList(),
          const SizedBox(
            height: 16,
          ),
          search(),
          const SizedBox(
            height: 16,
          ),
          _buildBannerAd(),
          const SizedBox(
            height: 16,
          ),
          Expanded(
            child: Stack(
              children: [
                _buildProductListView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          itemCount: subcategories.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) =>
              _buildSubcategoryItem(index),
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(width: 12);
          },
        ),
      ),
    );
  }

  Widget _buildSubcategoryItem(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          subcategoryLoadingStates =
              List.generate(subcategories.length, (i) => i == index);
          fetchProducts(subcategories[index].id, 0);
          currentPage = 0;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: _selectedIndex == index ? Colors.blue : Colors.grey.shade300,
        ),
        child: Text(
          subcategories[index].name,
          style: TextStyle(
            color: _selectedIndex == index ? Colors.white : Colors.black,
            fontWeight: _selectedIndex == index ? FontWeight.bold : null,
          ),
        ),
      ),
    );
  }

  Widget _buildProductListView() {
    bool _reachedEnd = false;
    return StreamBuilder<List<Product>>(
      stream: _productStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Product> products = snapshot.data!;
          int adFrequency = 4; // عدد العناصر قبل إظهار الإعلان

          if (products.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: products.length + (products.length ~/ adFrequency),
            itemBuilder: (context, index) {
              if (index % (adFrequency + 1) == adFrequency) {
                // إذا كان الفهرس يقع بعد أربعة عناصر، قم ببناء إعلان الـ AdMob
                return BannerAdmob();
              } else {
                // إلا إذا كان الفهرس يقع على عنصر منتج، قم ببناء عنصر المنتج
                int productIndex = index - (index ~/ (adFrequency + 1));
                final product = products[productIndex];

                // التحقق مما إذا كان الوصول إلى النهاية تم بالفعل
                if (index >=
                        products.length +
                            (products.length ~/ adFrequency) -
                            1 &&
                    !_reachedEnd) {
                  _reachedEnd = true;
                  // اعرض CircularProgressIndicator عند الوصول للنهاية
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailsScreen(productId: product.id),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 7,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 160,
                                child: Text(
                                  product.name,
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Text(
                                'جنية ${product.price.toStringAsFixed(2)}',
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
                            child: Image.memory(
                              base64Decode(product.image),
                              width: 160,
                              height: 160,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildBannerAd() {
    if (_isBannerAdReady) {
      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(8),
        child: SizedBox(
          height: _bannerAd.size.height.toDouble(),
          width: _bannerAd.size.width.toDouble(),
          child: AdWidget(ad: _bannerAd),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget search() {
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
