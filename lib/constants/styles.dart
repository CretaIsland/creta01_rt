//import 'package:acc_design2/my_chewie/my_chewie.dart';
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:math';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bordered_text/bordered_text.dart';
import 'package:like_button/like_button.dart';

class MySizes {
  static const double wideButtonWidth = 160;
  static const double buttonWidth = 100;
  static const double buttonHeight = 48;
  static const double imageIcon = 120;
  static const Radius buttonRadius = Radius.circular(4.0 * 2 * pi);
  static const double smallIcon = 18;
}

/// //////////////////////////////////////////////////////////////
/// Styles - Contains the design system for the entire app.
/// Includes paddings, text styles, timings etc. Does not include colors, check [AppTheme] file for that.

/// MyFonts - A list of Font Families, this is uses by the MyTextStyles class to create concrete styles.
class MyFonts {
  static const String raleway = "Raleway";
  static const String fraunces = "Fraunces";
  //static const f1 = 'Noto_Sans_KR';
  static const f1 = 'Pretendard';
  static const f2 = 'NanumMyeongjo';
  static const f3 = 'NanumGothic';
  static const f4 = 'Jua';
  static const f5 = 'NanumPenScript';
}

/// Font MySizes
/// You can use these directly if you need, but usually there should be a predefined style in MyTextStyles.
class MyFontsSize {
  /// Provides the ability to nudge the app-wide font scale in either direction
  static double get scale => 1;
  static double get s10 => 10 * scale;
  static double get s11 => 11 * scale;
  static double get s12 => 12 * scale;
  static double get s14 => 14 * scale;
  static double get s16 => 16 * scale;
  static double get s20 => 20 * scale;
  static double get s24 => 24 * scale;
  static double get s48 => 48 * scale;
}

class MyButtonStyle {
  static ButtonStyle b1 = OutlinedButton.styleFrom(
    elevation: 2,
    shadowColor: MyColors.secondaryColor,
  );
}

class MyTextStyles {
  /// Declare a base style for each Family
  ///
  ///
  static const body1 = TextStyle(
      fontFamily: MyFonts.f1,
      fontWeight: FontWeight.normal,
      fontSize: 16,
      height: 24 / 16,
      letterSpacing: 0.5,
      color: MyColors.primaryText);

  static const body1Hover = TextStyle(
      fontFamily: MyFonts.f1,
      fontWeight: FontWeight.normal,
      fontSize: 16,
      height: 24 / 16,
      letterSpacing: 0.5,
      color: MyColors.secondaryText);

  static TextStyle get cardText1 => myTextStyle.copyWith(
      color: Colors.black,
      fontSize: MyFontsSize.s16,
      // shadows: <Shadow>[
      //   Shadow(
      //     offset: Offset(5.0, 5.0),
      //     //blurRadius: 8.0,
      //     color: Color.fromARGB(255, 255, 255, 255),
      //   ),
      //   Shadow(
      //     offset: Offset(5.0, 5.0),
      //     //blurRadius: 8.0,
      //     color: Color.fromARGB(255, 255, 0, 0),
      //   ),
      // ],
      height: 1.5,
      letterSpacing: 0.05,
      fontWeight: FontWeight.w400);

  static TextStyle get cardText2 => myTextStyle.copyWith(
      color: Colors.grey,
      fontSize: MyFontsSize.s16,
      height: 1.5,
      letterSpacing: 0.05,
      fontWeight: FontWeight.w400);

  static const TextStyle f1 = TextStyle(fontFamily: MyFonts.f1, fontWeight: FontWeight.normal);
  static const TextStyle f2 = TextStyle(fontFamily: MyFonts.f2, fontWeight: FontWeight.normal);
  static const TextStyle f3 = TextStyle(fontFamily: MyFonts.f3, fontWeight: FontWeight.normal);
  static const TextStyle f4 = TextStyle(fontFamily: MyFonts.f4, fontWeight: FontWeight.normal);
  static const TextStyle f5 = TextStyle(fontFamily: MyFonts.f5, fontWeight: FontWeight.normal);

  static TextStyle myTextStyle = f1.copyWith(color: MyColors.primaryText);

  static TextStyle get error => myTextStyle.copyWith(
      color: Colors.red,
      fontSize: MyFontsSize.s20,
      height: 1.5,
      letterSpacing: 0.05,
      fontWeight: FontWeight.w400);

  static TextStyle get info => myTextStyle.copyWith(
      color: Colors.blue,
      fontSize: MyFontsSize.s20,
      height: 1.5,
      letterSpacing: 0.05,
      fontWeight: FontWeight.w400);

  static TextStyle get buttonText => myTextStyle.copyWith(
      color: MyColors.buttonFG,
      fontSize: MyFontsSize.s14,
      height: 1.5,
      letterSpacing: 0.05,
      fontWeight: FontWeight.w400);

  static TextStyle get buttonText2 => myTextStyle.copyWith(
      color: Colors.purple[100],
      fontSize: MyFontsSize.s16,
      height: 1.5,
      letterSpacing: 0.05,
      fontWeight: FontWeight.w400);

  static TextStyle get description => myTextStyle.copyWith(
      color: MyColors.puple900,
      fontSize: MyFontsSize.s14,
      height: 1.5,
      letterSpacing: 0,
      fontWeight: FontWeight.w500);

  static TextStyle get userId => myTextStyle.copyWith(
      color: Colors.white,
      fontSize: MyFontsSize.s14,
      height: 1.5,
      letterSpacing: 0,
      fontWeight: FontWeight.w500);

  static TextStyle get h3 => myTextStyle.copyWith(
      color: Colors.white,
      fontSize: MyFontsSize.s48,
      height: 1.5,
      letterSpacing: 0,
      fontWeight: FontWeight.w500);

  static TextStyle get h5 => myTextStyle.copyWith(
      color: Colors.white,
      fontSize: MyFontsSize.s24,
      height: 1.5,
      letterSpacing: 0,
      fontWeight: FontWeight.w500);

  static TextStyle get h6 => myTextStyle.copyWith(
      color: Colors.white,
      fontSize: MyFontsSize.s20,
      height: 1.5,
      letterSpacing: 0,
      fontWeight: FontWeight.w500);

  static TextStyle get symbol => myTextStyle.copyWith(
      color: MyColors.puple900,
      fontSize: MyFontsSize.s20,
      height: 1.5,
      letterSpacing: 0,
      fontWeight: FontWeight.w500);

  static TextStyle get h3Eng =>
      myTextStyle.copyWith(fontFamily: MyFonts.raleway, fontSize: MyFontsSize.s48, height: 72 / 48);

  static TextStyle get subtitle1 =>
      myTextStyle.copyWith(fontSize: MyFontsSize.s16, height: 24 / 16, letterSpacing: 0.15);
  static TextStyle get subtitle2 =>
      myTextStyle.copyWith(fontSize: MyFontsSize.s14, height: 21 / 14, letterSpacing: 0.1);

  static TextStyle get body2 =>
      myTextStyle.copyWith(fontSize: MyFontsSize.s14, height: 21 / 14, letterSpacing: 0.25);
  static TextStyle get deco1 => myTextStyle.copyWith(
      fontSize: MyFontsSize.s24,
      height: 24 / 16,
      letterSpacing: 0.5,
      decorationStyle: TextDecorationStyle.double);
}

class MyColors {
  static const Color playedColor = Color.fromRGBO(255, 0, 0, 0.7);
  static const Color bufferedColor = Color.fromRGBO(50, 50, 200, 0.2);
  static const Color pgBackgroundColor = Color.fromRGBO(200, 200, 200, 0.5);

  static const Color hover = Color(0xffD9D9D9);
  static const Color border = Color(0xff722ED1);
  static const Color divide = Color(0xffD9D9D9);
  static const Color artBoardBgColor = Color(0xFFE3E3E3);
  static const Color pageBg = white;
  //static const Color accBg = Color(0xff9E9E9E);
  static const Color accBg = Color(0xffD9D9D9);
  static const Color buttonBorder = border;
  static const Color buttonFG = Color(0xFF722ED1);
  static const Color buttonBG = secondaryColor;
  static const Color pageSmallBG = secondaryColor;
  static const Color appbar = primaryColor;
  static const Color pageSmallBG2 = puple300;
  static const Color pageSmallBorder = divide;
  static const Color pageSmallBorderCompl = gray02;

  static const Color puple900 = Color(0xff22075E);

  //static const primaryColor = Color(0xFFBA68C8); // puble 300 0xFFBA68C8
  static const mainColor = puple600; // puble 300 0xFFBA68C8
  static const primaryColor = puple300; // puble 300 0xFFBA68C8
  static const primaryCompl = gray02; // puble 300 0xFFBA68C8
  static const secondaryColor = puple100; // Puple 100 0xFFF9F0FF
  static const secondaryCompl = gray03; // Puple 100 0xFFF9F0FF
  static const bgColor = Color(0xFFE5E5E5);

  static const Color gray01 = Color(0xff3A3B41);
  static const Color gray02 = Color(0xffD3D3D3);
  static const Color gray03 = Color(0xffF1F1F1);
  static const Color white = Color(0xffffffff);
  static const Color primaryText = Color(0xff262626);
  static const Color icon = Color(0xff262626);
  static const Color mediumIcon = Color(0xff868686);
  static const Color secondaryText = Color(0xff595959);
  static const Color diabledText = Color(0xff8C8C8C);
  static const Color outline = Color(0xffD9D9D9);
  static const Color active = Color(0xff722ED1);
  static const Color error = Color(0xffF6222E);
  static const Color succcess = Color(0xff53C41A);

  static const Color puple600 = Color(0xff722ED1);
  static const Color puple300 = Color(0xffD3ADF7);
  static const Color puple100 = Color(0xffF9F0FF);

  static const Color critical = Color(0xffff0000);

////////////////////////////
  // static const Color compexDrawerScaffoldColor = Color(0xfe3e9f7);
  static const Color compexDrawerCanvasColor = Color(0xffe3e9f7);
  //static const Color complexDrawerBlack = Color(0xff11111d);
  static const Color complexDrawerBlack = Colors.transparent;
  //static const Color complexDrawerBlueGrey = Color(0xff1d1b31);
  static const Color complexDrawerBlueGrey = Colors.transparent;
}

/// Used for all animations in the  app
class Times {
  static const Duration fastest = Duration(milliseconds: 150);
  static const fast = Duration(milliseconds: 250);
  static const medium = Duration(milliseconds: 350);
  static const slow = Duration(milliseconds: 700);
  static const slower = Duration(milliseconds: 1000);
}

class Insets {
  static double scale = 1;
  static double offsetScale = 1;
  // Regular paddings
  static double get xs => 4 * scale;
  static double get sm => 8 * scale;
  static double get med => 12 * scale;
  static double get lg => 16 * scale;
  static double get xl => 32 * scale;
  // Offset, used for the edge of the window, or to separate large sections in the app
  static double get offset => 40 * offsetScale;
}

class Corners {
  static const double sm = 3;
  static const BorderRadius smBorder = BorderRadius.all(smRadius);
  static const Radius smRadius = Radius.circular(sm);

  static const double med = 5;
  static const BorderRadius medBorder = BorderRadius.all(medRadius);
  static const Radius medRadius = Radius.circular(med);

  static const double lg = 8;
  static const BorderRadius lgBorder = BorderRadius.all(lgRadius);
  static const Radius lgRadius = Radius.circular(lg);
}

class Strokes {
  static const double thin = 1;
  static const double thick = 4;
}

class Shadows {
  static List<BoxShadow> get universal => [
        BoxShadow(color: const Color(0xff333333).withOpacity(.15), spreadRadius: 0, blurRadius: 10),
      ];
  static List<BoxShadow> get small => [
        BoxShadow(
            color: const Color(0xff333333).withOpacity(.15),
            spreadRadius: 0,
            blurRadius: 3,
            offset: const Offset(0, 1)),
      ];
}

/// MyTextStyles - All the core text styles for the app should be declared here.
/// Don't try and create every variant in existence here, just the high level ones.
/// More specific variants can be created on the fly using `style.copyWith()`
/// `newStyle = MyTextStyles.body1.copyWith(lineHeight: 2, color: Colors.red)
///
BorderSide basicBorderSide = const BorderSide(color: MyColors.secondaryColor);

BoxDecoration simpleDeco(double radius, double width, Color bgColor, Color borderColor) {
  return BoxDecoration(
    color: bgColor,
    borderRadius: BorderRadius.all(Radius.circular(radius)),
    border: Border(
      left: BorderSide(width: width, color: borderColor, style: BorderStyle.solid),
      top: BorderSide(width: width, color: borderColor, style: BorderStyle.solid),
      right: BorderSide(width: width, color: borderColor, style: BorderStyle.solid),
      bottom: BorderSide(width: width, color: borderColor, style: BorderStyle.solid),
    ),
  );
}

BoxDecoration decoBox(bool isHover, double radiusTopLeft, double radiusTopRight,
    double radiusBottomLeft, double radiusBottomRight) {
  return BoxDecoration(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(radiusTopLeft),
        topRight: Radius.circular(radiusTopRight),
        bottomLeft: Radius.circular(radiusBottomLeft),
        bottomRight: Radius.circular(radiusBottomRight),
      ),
      //gradient: const LinearGradient(
      //    begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFECF6FF), Color(0xFFCADBEB)]),
      //color: Colors.white.withOpacity(0.2),
      color: Colors.white,
      // border: Border(
      //   left: BorderSide(width: 1, color: isHover ? Colors.red : Colors.grey, style: BorderStyle.solid),
      //   top: BorderSide(width: 1, color: isHover ? Colors.red : Colors.grey, style: BorderStyle.solid),
      //   right: BorderSide(width: 1, color: isHover ? Colors.red : Colors.grey, style: BorderStyle.solid),
      //   bottom: BorderSide(width: 1, color: isHover ? Colors.red : Colors.grey, style: BorderStyle.solid),
      // ),
      boxShadow: [
        BoxShadow(
          blurRadius: 24,
          spreadRadius: 5,
          offset: const Offset(20, 10),
          //color: isHover ? Colors.pink.withOpacity(0.2) : Color(0xFF3F6080).withOpacity(.2),
          color: Colors.pink.withOpacity(0.2),
        ),
        BoxShadow(
          blurRadius: 24,
          spreadRadius: 5,
          offset: const Offset(-10, -5),
          //color: isHover ? Colors.pink.withOpacity(0.2) : Color(0xFFFFFFFF),
          color: Colors.pink.withOpacity(0.2),
        ),
      ]);
}

Widget borderText(
  String msg,
  Color fgColor,
  double fontSize,
) {
  return BorderedText(
    //strokeWidth: 15.0,
    //strokeColor: Colors.black,
    child: Text(
      msg,
      // textAlign: TextAlign.center,
      // maxLines: 1,
      // overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: fgColor,
        fontSize: fontSize,
        fontWeight: FontWeight.normal,
        fontFamily: MyFonts.f1,
      ),
    ),
  );
}

Widget myLikeButton() {
  return LikeButton(
      size: MySizes.buttonHeight,
      circleColor: const CircleColor(start: Color(0xff00ddff), end: Color(0xff0099cc)),
      bubblesColor: const BubblesColor(
        dotPrimaryColor: Color(0xff33b5e5),
        dotSecondaryColor: Color(0xff0099cc),
      ),
      likeBuilder: (bool isLiked) {
        isLiked = true;
        return const ImageIcon(
          AssetImage(
            "Publish.png",
          ),
          size: MySizes.imageIcon,
          color: MyColors.secondaryColor,
        );
      },
      likeCount: 0,
      countBuilder: (int? count, bool isLiked, String text) {
        return const Text(
          "publish",
        );
      },
      onTap: (bool liked) async {
        return !liked;
      });
}

Widget animatedButton(String name, ImageIcon icon) {
  return Container(
    height: MySizes.buttonHeight,
    width: MySizes.wideButtonWidth,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 12.0,
            offset: Offset(0.0, 5.0),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff33ccff),
            Color(0xffff99cc),
          ],
        )),
    child: Center(
      child: Row(children: [
        icon,
        Text(
          name,
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ]),
    ),
  );
}
