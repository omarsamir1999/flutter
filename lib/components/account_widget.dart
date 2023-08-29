import 'package:flutter/material.dart';

import '../utils/dimensions.dart';
import 'app_icon.dart';
import 'big_text.dart';



class AccountWidget extends StatelessWidget {
  final AppIcon appIcon;
  final BigText bigText;
  const AccountWidget({required this.appIcon, required this.bigText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: Dimensions.width20,
          top: Dimensions.height10,
          bottom: Dimensions.font22),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          blurRadius: 1,
          offset: const Offset(0, 5),
          color: Colors.grey.withOpacity(0.2),
        )
      ]),
      child: Row(children: [
        appIcon,
        SizedBox(
          width: Dimensions.width10,
        ),
        bigText,
      ]),
    );
  }
}
