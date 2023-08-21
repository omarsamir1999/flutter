import 'package:flutter/material.dart';

class SpecialOffer {
  final String discount;
  final String title;
  final String detail;
  final String icon;

  SpecialOffer({
    required this.discount,
    required this.title,
    required this.detail,
    required this.icon,
  });
}

final homeSpecialOffers = <SpecialOffer>[
  SpecialOffer(
    discount: 'ضع اعلانك هنا',
    title: "Today’s Special!",
    detail: 'Get discount for every order, only valid for today',
    icon: 'assets/icon/products/sofa.png',
  ),
  SpecialOffer(
    discount: 'ضع اعلانك هنا',
    title: "Tomorrow will be better!",
    detail: 'Please give me a star!',
    icon: 'assets/icon/products/shiny_chair.png',
  ),
  SpecialOffer(
    discount: 'ضع اعلانك هنا',
    title: "Not discount today!",
    detail: 'If you have any problem, contact me',
    icon: 'assets/icon/products/lamp.png',
  ),
  SpecialOffer(
    discount: 'ضع اعلانك هنا',
    title: "It's for you!",
    detail: 'Wish you have a funny time',
    icon: 'assets/icon/products/plastic_chair@2x.png',
  ),
  SpecialOffer(
    discount: 'ضع اعلانك هنا',
    title: "Make yourself at home!",
    detail: 'If you have any confuse, let me now',
    icon: 'assets/icon/products/book_case@2x.png',
  ),
];

class SpecialOfferWidget extends StatelessWidget {
  const SpecialOfferWidget(
    this.context, {
    Key? key,
    required this.data,
    required this.index,
  }) : super(key: key);

  final SpecialOffer data;
  final BuildContext context;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.discount,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ],
            ),
          ),
        ),
        Image.asset(data.icon),
      ],
    );
  }
}
