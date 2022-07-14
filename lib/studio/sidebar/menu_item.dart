import 'package:flutter/material.dart';
import '../../constants/styles.dart';

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Function() onTap;

  const MenuItem({Key? key, required this.icon, required this.title, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color iconColor = MyColors.gray01;
    double iconSize = 20;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              color: iconColor,
              size: iconSize,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              title,
              style: MyTextStyles.subtitle1,
            )
          ],
        ),
      ),
    );
  }
}
