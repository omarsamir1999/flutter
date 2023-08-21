import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../controller/category_controller.dart';
import '../../model/category.dart';
import '../ad_state.dart';
import '../subcategory_screen.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final adManager = AdManager();

  int? categoryId;
  final CategoryController _categoryController = CategoryController();
  @override
  void initState() {
    super.initState();
    adManager.addAds(true, true, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Category>>(
        future: _categoryController.fetchCategories(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Category>> snapshot) {
          if (snapshot.hasData) {
            List<Category> categories = snapshot.data!;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: categories.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (BuildContext context, int index) {
                Category category = categories[index];
                return GestureDetector(
                  onTap: () {
                    adManager.showInterstitial();
                    setState(() {
                      categoryId = category.id;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MostPopularScreen(
                          categoryId: categoryId!,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        category.imageUrl,
                        width: 100,
                        height: 60,
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Failed to load categories'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: CustomColors.customGrey,
              ),
            );
          }
        },
      ),
    );
  }
}
