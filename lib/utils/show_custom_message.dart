import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/big_text.dart';

void showCustomSnackbar(String message,
    {bool isError = true, String title = "Error"}) {
  Get.snackbar(title, message,
      titleText: BigText(
        text: title,
        color: Colors.white,
      ),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.redAccent);
}
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// import '../../utils/color.dart';
// import '../../utils/dimensions.dart';
// import '../../widgets/big_text.dart';
// import '../../widgets/icon_text_widget.dart';

// class ProductDetails extends StatefulWidget {
//   final int productId;
//   final String fromPage;

//   const ProductDetails({
//     Key? key,
//     required this.productId,
//     required this.fromPage,
//   }) : super(key: key);

//   @override
//   _ProductDetailsState createState() => _ProductDetailsState();
// }

// class _ProductDetailsState extends State<ProductDetails> {
//   late Future<Map<String, dynamic>> _product;

//   @override
//   void initState() {
//     super.initState();
//     _product = fetchProduct(widget.productId);
//   }

//   Future<Map<String, dynamic>> fetchProduct(int productId) async {
//     final url =
//         Uri.parse('http://13.48.249.132:8080/api/v1/product/$productId');
//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       final jsonData =
//           jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
//       return jsonData;
//     } else {
//       throw Exception('Failed to load product');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Product Details'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SafeArea(
//         child: FutureBuilder<Map<String, dynamic>>(
//           future: _product,
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               final product = snapshot.data!;
//               return buildProductDetails(product);
//             } else if (snapshot.hasError) {
//               return Center(
//                 child: Text('Failed to load product'),
//               );
//             } else {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }

//   Widget buildProductDetails(Map<String, dynamic> product) {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: Dimensions.height30),
//           Center(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: product['image'] != null
//                   ? Image.memory(
//                       base64Decode(product['image']),
//                       fit: BoxFit.cover,
//                       height: 250,
//                       width: double.infinity,
//                     )
//                   : Image.asset(
//                       "lib/assets/images/Image Banner 2.png",
//                       fit: BoxFit.cover,
//                       height: 250,
//                       width: double.infinity,
//                     ),
//             ),
//           ),
//           SizedBox(height: Dimensions.height20),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
//             child: BigText(
//               text: product['name'],
//               size: 24,
//             ),
//           ),
//           SizedBox(height: Dimensions.height20),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 IconAndTextWidget(
//                   icon: Icons.attach_money,
//                   text: product['price'].toString(),
//                   iconColor: AppColors.iconColor2,
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: Dimensions.height20),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {},
//                   child: const Text('Add to Cart'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {},
//                   child: const Text('Buy Now'),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: Dimensions.height20),
//         ],
//       ),
//     );
//   }
// }
