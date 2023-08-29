import 'package:flutter/material.dart';

class EmptyPage extends StatelessWidget {
  final String text;
  final String imagePath;
  const EmptyPage(
      {Key? key,
      required this.text,
      this.imagePath = "lib/assets/images/pngwing.com (5).png"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset(
          imagePath,
          height: MediaQuery.of(context).size.height * 0.40,
          width: MediaQuery.of(context).size.width * 0.40,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          text,
          style: const TextStyle(fontSize: 25),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
