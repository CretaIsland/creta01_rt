// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../../constants/styles.dart';

Widget basicButton({
  required void Function() onPressed,
  required String name,
  required IconData iconData,
  AlignmentGeometry alignment = Alignment.bottomRight,
  double height = MySizes.buttonHeight / 2,
}) {
  return Container(
    alignment: alignment,
    child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          elevation: 4.0,
          side: BorderSide(width: 1.0, color: MyColors.buttonBorder),
          backgroundColor: MyColors.buttonBG,
          //padding: EdgeInsets.zero,
          // padding: EdgeInsets.fromLTRB(
          //   MySizes.buttonHeight / 4,
          //   MySizes.buttonHeight / 4,
          //   MySizes.buttonHeight / 3,
          //   MySizes.buttonHeight / 5,
          // ),
        ),
        onPressed: onPressed,
        child: Row(
            // crossAxisAlignment: CrossAxisAlignment.end,
            // mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                iconData,
                size: height, //MySizes.imageIcon,
                color: MyColors.buttonFG,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                name,
                style: MyTextStyles.buttonText,
              ),
            ])),
  );
}

Widget basicButton2(
    {required void Function() onPressed,
    required String name,
    required TextStyle textStyle,
    double width = 166,
    double height = 44,
    Color borderColor = MyColors.buttonBorder,
    AlignmentGeometry alignment = Alignment.center}) {
  return Container(
    alignment: alignment,
    decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: 1,
        )),
    height: height,
    width: width,
    child: GestureDetector(
      onPanDown: (details) => onPressed(),
      child: Text(
        name,
        style: textStyle,
      ),
    ),
  );
}

class BasicButton3 extends StatefulWidget {
  final void Function() onPressed;
  final String name;
  final IconData iconData;
  final double height;

  const BasicButton3(
      {Key? key,
      required this.onPressed,
      required this.name,
      required this.iconData,
      this.height = MySizes.buttonHeight / 2})
      : super(key: key);

  @override
  State<BasicButton3> createState() => _BasicButton3State();
}

class _BasicButton3State extends State<BasicButton3> {
  @override
  Widget build(BuildContext context) {
    return basicButton3(
        onPressed: widget.onPressed,
        name: widget.name,
        iconData: widget.iconData,
        height: widget.height);
  }

  Widget basicButton3({
    required void Function() onPressed,
    required String name,
    required IconData iconData,
    required double height,
  }) {
    return Container(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
          onPanDown: (details) => onPressed(),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(
              iconData,
              size: height, //MySizes.imageIcon,
              color: Colors.white,
            ),
            SizedBox(
              width: 15,
            ),
            Text(
              name,
              style: MyTextStyles.h5,
            ),
          ])),
    );
  }
}

class IconOnlyButton extends StatefulWidget {
  final void Function() onPressed;
  final String iconPath;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;

  const IconOnlyButton(
      {Key? key,
      required this.onPressed,
      required this.iconPath,
      required this.width,
      required this.height,
      required this.padding})
      : super(key: key);

  @override
  State<IconOnlyButton> createState() => _IconOnlyButtonState();
}

class _IconOnlyButtonState extends State<IconOnlyButton> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        width: widget.width + (isHover ? widget.width * 0.1 : 0),
        height: widget.height + (isHover ? widget.height * 0.1 : 0),
        padding: widget.padding,
        color: isHover ? MyColors.hover : Colors.transparent,
        child: GestureDetector(
          onPanDown: (details) => widget.onPressed(),
          child: MouseRegion(
            onHover: (event) {
              setState(() {
                isHover = true;
              });
            },
            onExit: (event) {
              setState(() {
                isHover = false;
              });
            },
            child: Image.asset(widget.iconPath),
          ),
        ));
  }
}

IconButton logoIconButton(
    {required void Function() onPressed, double iconSize = MySizes.imageIcon}) {
  return IconButton(
      iconSize: iconSize,
      padding: EdgeInsets.only(left: 20, right: 20),
      icon: const ImageIcon(
        AssetImage(
          "assets/logo_en.png",
        ),

        //size: IconSizes.imageIcon,
      ),
      onPressed: onPressed //context.read<MenuController>().controlMenu,
      );
}

Widget logoIcon2({Color color = MyColors.mainColor, double size = 40}) {
  return ImageIcon(
    AssetImage(
      "assets/publish.png",
    ),
    color: color,
    size: size,
  );
}

Widget iconWithText(
    {required String text, required String iconImage, required void Function() onPressed}) {
  return ElevatedButton(
      style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: MaterialStateProperty.all(MyColors.primaryColor)),
      onPressed: onPressed,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        ImageIcon(
          AssetImage(
            iconImage,
          ),
          size: 20, //MySizes.imageIcon,
          color: MyColors.secondaryColor,
        ),
        SizedBox(
          width: 10,
        ),
        Text(text),
      ]));
}
