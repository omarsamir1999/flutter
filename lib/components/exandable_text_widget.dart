import 'package:elshodaa_mall/components/small_text.dart';
import 'package:flutter/material.dart';

import '../utils/color.dart';
import '../utils/dimensions.dart';

class ExpandableTextWidget extends StatefulWidget {
  final String text;
  const ExpandableTextWidget({Key? key, required this.text}) : super(key: key);

  @override
  State<ExpandableTextWidget> createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  late String firstHalf;
  late String secondHalf;

  bool hiddenText = true;

  double textHeight = Dimensions.screenHeight / 5.63;

  @override
  void initState() {
    super.initState();
    if (widget.text.length > textHeight) {
      firstHalf = widget.text.substring(0, textHeight.toInt());
      secondHalf =
          widget.text.substring(textHeight.toInt() + 1, widget.text.length);
    } else {
      firstHalf = widget.text;
      secondHalf = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: secondHalf.isEmpty
          ? SmallText(
              color: Colors.black, size: Dimensions.iconSize16, text: firstHalf)
          : Column(
              children: [
                SmallText(
                    color: Colors.black54,
                    height: 1.7,
                    size: Dimensions.iconSize16,
                    text: hiddenText
                        ? ("$firstHalf.....")
                        : firstHalf + secondHalf),
                InkWell(
                  onTap: () {
                    setState(() {
                      hiddenText = !hiddenText;
                    });
                  },
                  child: Row(
                    children: [
                      const SmallText(
                        text: "Show more",
                        color: AppColors.mainColor,
                      ),
                      Icon(
                          hiddenText
                              ? Icons.arrow_drop_down
                              : Icons.arrow_drop_up_outlined,
                          color: AppColors.mainColor)
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
