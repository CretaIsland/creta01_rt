import 'dart:ui';
import 'dart:math';
//import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_null_safety/flutter_neumorphic.dart';
//import 'package:clock_loader/clock_loader.dart';

import 'package:creta01/constants/styles.dart';
import 'package:creta01/common/util/logger.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
//import 'package:creta01/constants/constants.dart';

import '../../constants/strings.dart';
import '../buttons/hover_buttons.dart';

double getDeltaRadiusPercent(Size realSize, double dx, double dy, double direction) {
  if (dx == 0 && dy == 0) return 0;

  //  움직인 거리를 구한후, Radius 를 퍼센트로 환산한 값을 구한다.
  // DB 에는 이 퍼센트값으로 저장된다.

  // height 가 짧은 직사각형으로 정규화한다.
  // 짧은 쪽이다.
  double height = realSize.height >= realSize.width ? realSize.width / 2 : realSize.height / 2;
  double maxR = sqrt(2) * height; //  rr = xx + yy 인데, x = y 이므로  rr = 2yy 이다.

  // 움직인 거리 move는
  double delta = sqrt(dx * dx + dy * dy);

  if (delta >= maxR) {
    return 100 * direction;
  }
  return (delta * 100) / maxR * direction;
}

double percentToRadius(double radiusPercent, Size realSize) {
  // height 가 짧은 직사각형으로 정규화한다.
  // 짧은 쪽이다.
  double height = realSize.height >= realSize.width ? realSize.width / 2 : realSize.height / 2;
  double maxR = sqrt(2) * height; //  rr = xx + yy 인데, x = y 이므로  rr = 2yy 이다.

  return (radiusPercent * maxR) / 100;
}

Widget divider({double paddings = 0, double indent = 14, Color color = MyColors.divide}) {
  return Padding(
    padding: EdgeInsets.all(paddings),
    child: Divider(
      height: 5,
      thickness: 1,
      color: MyColors.divide,
      indent: indent,
      endIndent: indent,
    ),
  );
}

Divider smallDivider(
    {double height = 4, thickness = 1, double indent = 24, double endIndent = 24}) {
  return Divider(
    height: height,
    thickness: thickness,
    color: MyColors.divide,
    indent: indent,
    endIndent: endIndent,
  );
}

Widget doubleSlider({
  required String title,
  required double value,
  required double min,
  required double max,
  String? valueString,
  required void Function(double) onChanged,
  required void Function(double) onChangeStart,
}) {
  return Row(
    children: <Widget>[
      Text(
        title,
        style: MyTextStyles.subtitle2,
      ),
      Expanded(
        child: Slider(
          min: min,
          max: max,
          value: value,
          onChangeStart: onChangeStart,
          onChanged: (val) {
            onChanged.call(val);
            // setState(() {
            //   borderWidth = value;
            // });
          },
          activeColor: MyColors.mainColor,
          thumbColor: MyColors.white,
          inactiveColor: MyColors.primaryColor,
        ),
      ),
      SizedBox(
        width: 60,
        child: Text(valueString ?? value.floor().toString()),
      ),
    ],
  );
}

Widget buildSwitches(String title, bool value, void Function(bool) onChanged) {
  return Row(children: <Widget>[
    Text(
      title,
      style: MyTextStyles.subtitle2,
    ),
    const SizedBox(width: 15),
    Text(
      "on ",
      style: MyTextStyles.buttonText,
    ),
    NeumorphicSwitch(
      value: value,
      style: const NeumorphicSwitchStyle(
        activeThumbColor: MyColors.mainColor,
        thumbShape: NeumorphicShape.concave, // concave or flat with elevation
      ),
      onChanged: onChanged,
    ),
    Text(
      " off",
      style: MyTextStyles.buttonText,
    ),
  ]);
}

Widget myCheckBox(String title, bool value, void Function() onPressed, double left, double top,
    double right, double bottom,
    {bool isBold = false, bool isItalic = false, TextDecoration line = TextDecoration.none}) {
  return Row(
    children: [
      IconButton(
        padding: EdgeInsets.fromLTRB(left, top, right, bottom),
        iconSize: 30.0,
        icon: Icon(
          value == true ? Icons.task_alt_outlined : Icons.radio_button_unchecked_outlined,
          color: value == true ? MyColors.mainColor : Colors.grey,
        ),
        onPressed: onPressed,
      ),
      const SizedBox(
        width: 10,
      ),
      Text(
        title,
        style: MyTextStyles.subtitle2.copyWith(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          decoration: line,
        ),
      ),
    ],
  );
}

Widget frostedEdged({required Widget child, double radius = 15.0, double sigma = 10.0}) {
  return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma), child: child));
}

Widget glassMorphic({required double glass, required Widget child, double radius = 0}) {
  //logHolder.log("glassMorphic $glass", level: 5);
  return glass > 0
      ? ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child:
              BackdropFilter(filter: ImageFilter.blur(sigmaX: glass, sigmaY: glass), child: child))
      : child;
}

Widget infoCard(BuildContext context, String title, String msg, Color color) {
  return frostedEdged(
      child: Container(
          key: ValueKey<String>(title),
          // height: MediaQuery.of(context).size.height / 4,
          // width: MediaQuery.of(context).size.width / 1.2,
          // color: Colors.white.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 20.0, color: color, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  msg,
                  style: const TextStyle(fontSize: 18.0, color: Colors.black87),
                ),
              ],
            ),
          )));
}

void showCustomDialog(BuildContext context, String message) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext cxt) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Material(
            color: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Image.asset("assets/close.png")),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

void showSlimDialog(BuildContext context, String message, {Color bgColor = Colors.grey}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext cxt) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Material(
            color: bgColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            //child: Padding(
            //padding: const EdgeInsets.all(16),
            child: Expanded(
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Icon(Icons.warning),
                      const SizedBox(width: 16),
                      Container(
                        height: 40,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          message,
                          style: MyTextStyles.body1.copyWith(fontSize: 20),
                        ),
                      ),
                    ],
                  )),
            ),
            //),
          ),
        ),
      );
    },
  );
}

void simpleDialog(BuildContext context, String title, String msg, Color color) {
  showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
              height: 200, width: 400, child: Center(child: infoCard(context, title, msg, color))),
        );
      });
}

Color hexToColor(String hexString, {String alphaChannel = 'FF'}) {
  if (hexString.length >= 6) {
    if (hexString[0] == '#') {
      if (hexString.length == 7) {
        return Color(int.parse(hexString.replaceFirst('#', '0x$alphaChannel')));
      }
      return Color(int.parse(hexString.replaceFirst('#', '0x')));
    } else {
      if (hexString.length == 6) {
        return Color(int.parse('0x$alphaChannel$hexString'));
      }
      return Color(int.parse('0x$hexString'));
    }
  }
  return Colors.white;
}

Widget writeButton({required void Function() onPressed}) {
  return IconButton(
    // textField를  Write 하는 icon
    padding: EdgeInsets.zero,
    onPressed: onPressed,
    icon: const Icon(Icons.create_outlined),
    color: MyColors.icon,
    iconSize: MySizes.smallIcon,
  );
}

bool isInCircle(Offset point, Offset center, double radius) {
  // x2 + y2 = r2  이것이 원의 공식.   따라서 점이 원안에 있으려면  x2 + y2 <= r2 이다.
  // 그런데,  이것은 center 가  0,0 일때 얘기이고, 지금은 center 가 0,0 이 아니니까...
  // (x-center_x)^2 + (y - center_y)^2 < radius^2  이것이 된다.

  // 편차값을 구한다. (center 를  0,0 으로 만들어준다.)
  double R = radius;
  double dx = (point.dx - center.dx).abs();
  double dy = (point.dy - center.dy).abs();

  // 일단 편차가 반지름보다 크면, 굳이 제곱을 해볼 필요도 없기 때문에 걸러준다.
  if (dx > R) return false;
  if (dy > R) return false;

  // x+y 가 반지름보다도 작으면, 원을 벗어날 수가 없다. (내접 사각형을 생각해보라)
  if (dx + dy <= R) return true;

  // 마지막으로 위대한 피타고라스 선생의 공식을 적용한다.
  if (pow(dx, 2) + pow(dy, 2) > pow(R, 2)) return false;
  return true;
}

Offset moveOnCircle(double degree, double radius, Offset center) {
  var x1 = center.dx + radius * cos(degree * pi / 180);
  var y1 = center.dx + radius * sin(degree * pi / 180);
  return Offset(x1, y1);
}

Offset moveOnCircle2(double degree, double dx, double dy) {
  // center 를 (0,0) 로 산정한 케이스 이다.
  double radius = sqrt(dx * dx + dy * dy);
  var x1 = radius * cos(degree * pi / 180);
  var y1 = radius * sin(degree * pi / 180);
  return Offset(x1, y1);
}

double getRoundMoveAngle(Offset localPosition, double radius) {
  double degree = -4;

  //logHolder.log('getRoundMoveDegree:$localPosition');

  double dx = localPosition.dx.abs();
  double dy = localPosition.dy.abs();
  //double x = (dx % radius).abs();
  //double y = (dy % radius).abs();

  double rx = 0;
  double ry = 0;
  double divide = 0;

  if ((0 <= dx && dx < radius) && (0 <= dy && dy < radius)) {
    // 4/4 분면
    ry = radius - dy;
    rx = radius - dx;
    divide = 270;
  } else if ((radius <= dx && dx < radius * 2) && (0 <= dy && dy < radius)) {
    // 1/4 분면
    rx = radius - dy;
    ry = dx - radius;
    divide = 0;
  } else if ((radius <= dx && dx < radius * 2) && (radius <= dy && dy < radius * 2)) {
    // 2/4 분면
    ry = dy - radius;
    rx = dx - radius;
    divide = 90;
  } else if ((0 <= dx && dx < radius) && (radius <= dy && dy < radius * 2)) {
    // 3/4 분면
    rx = dy - radius;
    ry = radius - dx;
    divide = 180;
  } else {
    logHolder.log('out of bound');
    return -1;
  }

  double theta = 0;
  if (ry != 0 || rx != 0) {
    // // sin(t) = y /  sqrt( xx + yy);
    // // t = asin(  y /  sqrt( xx + yy));
    double buf = ry / sqrt(rx * rx + ry * ry);
    if (buf > 1.0 || buf < -1.0) {
      logHolder.log('ERROR Invalid asin input=$buf');
      return -2;
    }
    theta = asin(buf);
    // theta 는 radian (호의 길이) 이므로, 이를 각도로 변화해 준다.
    theta = (180 / pi) * theta;
  }
  // theta 는 90 을 넘을 수 없다.
  if (theta > 90 || theta < -90) {
    logHolder.log('ERROR Invalid theta=$theta');
    return -3;
  }

  degree = divide + theta;
  //logHolder.log('Update: $degree, $divide, theta=$theta');
  return degree;
}

double getRoundMoveAngle2(double dx, double dy) {
  if (dx == 0 && dy == 0) {
    return 0;
  }
  if (dx == 0) {
    return (((dy > 0) ? 180 : 0) + 270);
  }
  if (dy == 0) {
    return (((dx > 0) ? 90 : 270) + 270);
  }

  double degree = -4;
  double divide = 0;

  double rx = 0;
  double ry = 0;

  if (dx < 0 && dy < 0) {
    rx = dx.abs(); //-
    ry = dy.abs();
    // 4/4 분면
    divide = 270;
  } else if (dx > 0 && dy < 0) {
    // 1/4 분면
    rx = dy.abs(); //-
    ry = dx.abs();
    divide = 0;
  } else if (dx > 0 && dy > 0) {
    // 2/4 분면
    rx = dx.abs();
    ry = dy.abs(); //-
    divide = 90;
  } else if (dx < 0 && dy > 0) {
    // 3/4 분면
    rx = dy.abs();
    ry = dx.abs(); //-
    divide = 180;
  }

  double theta = 0;
  double buf = ry / sqrt(rx * rx + ry * ry);
  if (buf > 1.0 || buf < -1.0) {
    logHolder.log('ERROR Invalid asin input=$buf');
    return -2;
  }
  theta = asin(buf);
  // theta 는 radian (호의 길이) 이므로, 이를 각도로 변화해 준다.
  theta = (180 / pi) * theta;

  // theta 는 90 을 넘을 수 없다.
  if (theta > 90 || theta < -90) {
    logHolder.log('ERROR Invalid theta=$theta');
    return -3;
  }
  degree = divide + theta;
  //logHolder.log('Update: $degree, $divide, theta=$theta');
  return degree + 270;
}

Widget errMsgWidget(AsyncSnapshot<Object> snapshot) {
  logHolder.log('errMsg :  ${snapshot.error}');
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      'Error: ${snapshot.error}',
      style: const TextStyle(fontSize: 8),
    ),
  );
}

Widget errMsgWidget2(AsyncSnapshot<Object?> snapshot) {
  logHolder.log('errMsg :  ${snapshot.error}');
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      'Error: ${snapshot.error}',
      style: const TextStyle(fontSize: 8),
    ),
  );
}

Widget errMsgWidget3(String msg) {
  logHolder.log('errMsg :  $msg}');
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      'Error: $msg',
      style: const TextStyle(fontSize: 8),
    ),
  );
}

Widget showWaitSign() {
  // return const Center(
  //   child: Icon(
  //     Icons.cloud_upload_outlined,
  //     size: 80,
  //     color: Colors.white,
  //   ),
  // );
  return Center(
    child: SizedBox(
        width: 100,
        height: 100,
        child: LiquidCircularProgressIndicator()), // CircularProgressIndicator(),
    // child: ClockLoader(
    //   clockLoaderModel: ClockLoaderModel(
    //     shapeOfParticles: ShapeOfParticlesEnum.circle,
    //     mainHandleColor: Colors.grey.shade100,
    //     particlesColor: Colors.grey.shade100,
    //   ),
    // ),
    //
  );
}

Widget defaultBGImage() {
  //return Image.asset('assets/creta_default.png', fit: BoxFit.cover);
  return Image.asset('creta_default.png', fit: BoxFit.cover);
}

Widget noImage(String errMsg) {
  return Stack(
    alignment: AlignmentDirectional.center,
    children: [
      Image.asset('assets/no_image.png', fit: BoxFit.cover),
      Text(
        errMsg,
        style: MyTextStyles.body1,
      ),
    ],
  );
}

double getRadiusPos(double radius, {double minus = 1.0}) {
  double dx = 0;
  if (radius > 0) {
    dx = radius / (2 * pi) * minus;
    if (dx.abs() > 180 * pi) dx = 180 * pi * minus;
  }
  return dx;
}

Color strToColor(String colorStr) {
  if (colorStr.length > 16) {
    // 'Color(0x000000ff)';
    return Color(int.parse(colorStr.substring(8, 16), radix: 16));
  }
  return const Color(0xffffffff);
}

void naviPush(BuildContext context, Widget page) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (BuildContext context) {
        return page;
      },
    ),
  );
}

void naviPop(BuildContext context) {
  Navigator.pop(
    context,
  );
}

String dateToDurationString(DateTime updateTime) {
  Duration duration = DateTime.now().difference(updateTime);
  if (duration.inDays >= 365) {
    return '${((duration.inDays / 365) * 10).round()} ${MyStrings.yearBefore}';
  }
  if (duration.inDays >= 30) {
    return '${((duration.inDays / 30) * 10).round()} ${MyStrings.monthBefore}';
  }
  if (duration.inDays >= 1) {
    return '${duration.inDays} ${MyStrings.dayBefore}';
  }
  if (duration.inHours >= 1) {
    return '${duration.inHours} ${MyStrings.hourBefore}';
  }

  return '${duration.inMinutes} ${MyStrings.minBefore}';
}

double durationToMillisec(Duration duration) {
  return duration.inDays * 24 * 60 * 60 * 1000.0 +
      duration.inHours * 60 * 60 * 1000.0 +
      duration.inMinutes * 60 * 1000.0 +
      duration.inSeconds * 1000.0 +
      duration.inMilliseconds;
}

String durationToString(Duration duration) {
  String retval = '';
  if (duration.inDays > 0) retval += '${duration.inDays}${MyStrings.days} ';
  if (duration.inHours > 0) retval += '${duration.inHours}${MyStrings.hours} ';
  if (duration.inMinutes > 0) retval += '${duration.inMinutes}${MyStrings.minutes} ';
  if (duration.inSeconds > 0) retval += '${duration.inSeconds}${MyStrings.seconds}';
  return retval;
}

class SimpleRichText extends StatelessWidget {
  final String title;
  final String value;
  final TextStyle titleStyle;
  final TextStyle valueStyle;
  final double width;

  // ignore: use_key_in_widget_constructors
  const SimpleRichText(this.title, this.value, this.width,
      {this.titleStyle = MyTextStyles.f1, this.valueStyle = MyTextStyles.f1});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: RichText(
        maxLines: null,
        text: TextSpan(
          text: '$title : ',
          style: titleStyle,
          children: [
            TextSpan(text: value, style: valueStyle),
          ],
        ),
      ),
    );
  }
}

List<String> stringToList(String input) {
  return input.replaceAll("[", "").replaceAll("]", "").replaceAll(" ", "").split(',');
}

Widget likeCountWidget(
  BuildContext context, {
  required int viewCount,
  required int likeCount,
  required int dislikeCount,
  required void Function() onLikeCount,
  required void Function() onDislikeCount,
  Color color = Colors.white,
  MainAxisAlignment alignment = MainAxisAlignment.center,
}) {
  return Padding(
      // 조횟수, 좋아요, 싫어요
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 8),
      child: Row(
        mainAxisAlignment: alignment,
        children: [
          HoverButton(
              width: 30,
              height: 30,
              onEnter: () {},
              onExit: () {},
              onPressed: () {},
              icon: Icon(
                Icons.visibility_outlined,
                color: color,
              )),
          Text(
            "$viewCount",
            style: DefaultTextStyle.of(context).style.copyWith(color: color),
          ),
          const SizedBox(
            width: 10,
          ),
          HoverButton(
              width: 30,
              height: 30,
              onEnter: () {},
              onExit: () {},
              onPressed: onLikeCount,
              icon: Icon(Icons.thumb_up_outlined, color: color)),
          Text(
            "$likeCount",
            style: DefaultTextStyle.of(context).style.copyWith(color: color),
          ),
          const SizedBox(
            width: 10,
          ),
          HoverButton(
              width: 30,
              height: 30,
              onEnter: () {},
              onExit: () {},
              onPressed: onDislikeCount,
              icon: Icon(Icons.thumb_down_outlined, color: color)),
          Text(
            "$dislikeCount",
            style: DefaultTextStyle.of(context).style.copyWith(color: color),
          ),
        ],
      ));
}

Widget likeCountWidgetReadOnly(
  BuildContext context, {
  required int viewCount,
  required int likeCount,
  required int dislikeCount,
  Color color = Colors.white,
  MainAxisAlignment alignment = MainAxisAlignment.center,
}) {
  return Padding(
      // 조횟수, 좋아요, 싫어요
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 8),
      child: Row(
        mainAxisAlignment: alignment,
        children: [
          Icon(
            Icons.visibility_outlined,
            color: color,
          ),
          Text(
            "$viewCount",
            style: DefaultTextStyle.of(context).style.copyWith(color: color),
          ),
          const SizedBox(
            width: 10,
          ),
          Icon(Icons.thumb_up_outlined, color: color),
          Text(
            "$likeCount",
            style: DefaultTextStyle.of(context).style.copyWith(color: color),
          ),
          const SizedBox(
            width: 10,
          ),
          Icon(Icons.thumb_down_outlined, color: color),
          Text(
            "$dislikeCount",
            style: DefaultTextStyle.of(context).style.copyWith(color: color),
          ),
        ],
      ));
}

Widget outlineText(String text,
    {required double fontSize, required Color lineColor, required Color textColor, int? maxLines}) {
  return Stack(
    children: <Widget>[
      // Stroked text as border.
      Text(
        text,
        maxLines: maxLines,
        style: TextStyle(
            fontSize: fontSize,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = fontSize / 5
              ..color = lineColor),
      ),
      // Solid text as fill.
      Text(
        text,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
        ),
      ),
    ],
  );
}

Color stringToColor(String? colorStr, {Color defaultColor = Colors.transparent}) {
  if (colorStr != null && colorStr.length > 16) {
    // 'Color(0x000000ff)';
    return Color(int.parse(colorStr.substring(8, 16), radix: 16));
  }
  return defaultColor;
}

int getStringSize(String str) {
  int retval = 0;
  for (int byte in str.codeUnits.toList()) {
    if (byte > 256) {
      // It's 2 bytes character
      retval += 2;
    } else {
      retval++;
    }
  }
  return retval;
}

String shortenText(String initialText) {
  logHolder.log('shortenText($initialText)', level: 5);
  int textSize = getStringSize(initialText);
  String name = initialText;
  if (textSize > 40) {
    name = initialText.substring(0, (initialText.length / (textSize / 40).ceil()).round());
    name += "...";
  }
  logHolder.log('shortenText($name)', level: 5);
  return name;
}

// String isoLangCode(String input) {
//   if (input == MyStrings.korean) {
//     return 'ko';
//   }
//   if (input == MyStrings.japanese) {
//     return 'ja';
//   }
//   if (input == MyStrings.spainish) {
//     return 'es';
//   }
//   if (input == MyStrings.arab) {
//     return 'ar';
//   }
//   if (input == MyStrings.chinese) {
//     return 'zh-cn';
//   }
//   return 'en';
/*
아프리칸스어	af
알바니아어	sq
암하라어	am
아랍어	ar
아르메니아어	hy
아제르바이잔어	az
바스크어	eu
벨라루스어	be
벵골어	bn
보스니아어	bs
불가리아어	bg
카탈루냐어	ca
세부아노어	ceb(ISO-639-2)
중국어(간체)	zh-cn 또는 zh(BCP-47)
중국어(번체)	zh-TW(BCP-47)
코르시카어	co
크로아티아어	hr
체코어	cs
덴마크어	da
네덜란드어	nl
영어	en
에스페란토	eo
에스토니아어	et
핀란드어	fi
프랑스어	fr
프리지아어	fy
갈리시아어	gl
조지아어	ka
독일어	de
그리스어	el
구자라트어	gu
아이티 크리올어	ht
하우사어	ha
하와이어	haw(ISO-639-2)
히브리어	he 또는 iw
힌디어	hi
몽어	hmn(ISO-639-2)
헝가리어	hu
아이슬란드어	is
이그보어	ig
인도네시아어	id
아일랜드	ga
이탈리아어	it
일본어	ja
자바어	jv
칸나다어	kn
카자흐어	kk
크메르어	km
키냐르완다어	rw
한국어	ko
쿠르드어	ku
키르기스어	ky
라오어	lo
라틴어	la
라트비아어	lv
리투아니아어	lt
룩셈부르크어	lb
마케도니아어	mk
마다가스카르어	mg
말레이어	ms
말라얄람어	ml
몰타어	mt
마오리어	mi
마라타어	mr
몽골어	mn
미얀마어(버마어)	my
네팔어	ne
노르웨이어	no
니안자어(치츄어)	ny
오리야어	or
파슈토어	ps
페르시아어	fa
폴란드어	pl
포르투갈어(포르투갈, 브라질)	pt
펀자브어	pa
루마니아어	ro
러시아어	ru
사모아어	sm
스코틀랜드 게일어	gd
세르비아어	sr
세소토어	st
쇼나어	sn
신디어	sd
스리랑카어(싱할라어)	si
슬로바키아어	sk
슬로베니아어	sl
소말리어	so
스페인어	es
순다어	su
스와힐리어	sw
스웨덴어	sv
타갈로그어(필리핀어)	tl
타지크어	tg
타밀어	ta
타타르어	tt
텔루구어	te
태국어	th
터키어	tr
투르크멘어	tk
우크라이나어	uk
우르두어	ur
위구르어	ug
우즈베크	uz
베트남어	vi
웨일즈어	cy
코사어	xh
이디시어	yi
요루바어	yo
줄루어	zu
*/
//}
/*
String TTSLangCode(String input)
{

  if (input == MyStrings.korean) {
    return 'ko-KR';
  }
  if (input == MyStrings.japanese) {
    return 'ja-JP';
  }
  if (input == MyStrings.spainish) {
    return 'es-ES';
  }
  if (input == MyStrings.arab) {
    return 'ar';
  }
  if (input == MyStrings.chinese) {
    return 'zh-cn';
  }

  ['한국어','ko-KR','ko'],
  ['Deutsch (Deutschland)','de-DE','de'],
  ['English (US)','en-US','en'],
  ['Español (España)','es-ES','es'],
  ['Français (France)','fr-FR','fr'],
  ['हिंदी','hi-IN','hi'],
  ['Bahasa Indonesia','id-ID','id'],
  ['Italiano','it-IT','it'],
  ['日本語','ja-JP','ja'],
  ['Nederlands','nl-NL','nl'],
  ['Polski','pl-PL','pl'],  
  ['Português (Brasil)','pt-BR','pt'],
  ['Русский','ru-RU','ru'],
  ['中文 (中国大陆)','zh-CN','zh-cn'],
  ['中文 (台灣)','zh-TW','zh-tw'],


  한국어 ko-KR  ko
  Deutsch (Deutschland): de-DE  de
  English (US): en-US  en
  English (UK): en-GB
  Español (España): es-ES  es
  : es-US
  Français (France): fr-FR fr
  हिंदी: hi-IN  hi
  Bahasa Indonesia: id-ID  id
  Italiano: it-IT it
  日本語: ja-JP ja
  Nederlands: nl-NL  nl
  Polski: pl-PL pl  
  Português (Brasil): pt-BR  pt
  Русский: ru-RU ru
  中文 (中国大陆): zh-CN zh-cn
  : zh-HK
  中文 (台灣): zh-TW  zh-tw
 

 lang: 한국어
lang: Deutsch (Deutschland)
lang: English (US)
lang: English (UK)
lang: Español (España)
lang: Français (France)
lang: हिंदी
lang: Bahasa Indonesia
lang: Italiano
lang: 日本語
lang: Nederlands
lang: Polski
lang: Português (Brasil)
lang: Русский
lang: 中文 (中国大陆)
lang: 中文 (台灣)
}
*/