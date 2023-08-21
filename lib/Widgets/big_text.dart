import 'package:flutter/material.dart';

import 'dimensions.dart';

class BigText extends StatelessWidget {
  final Color? color;
  final String text;
  final double size;
  final TextOverflow overflow;
  const BigText(
      {this.color = const Color(0xff332d2b),
      required this.text,
      this.size = 0,
      this.overflow = TextOverflow.ellipsis});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: overflow,
      style: TextStyle(
          color: color,
          fontWeight: FontWeight.w400,
          fontFamily: 'Roboto',
          fontSize: size == 0 ? Dimensions.font20 : size),
    );
  }
}
