//import 'dart:ui' as ui;
// ignore_for_file: prefer_const_constructors, no_leading_underscores_for_local_identifiers

import 'dart:math';
//import 'package:creta01/common/util/logger.dart';
import 'package:flutter/material.dart';
import '../model/acc_property.dart';
import '../constants/styles.dart';
import '../common/util/my_utils.dart';
import '../model/model_enums.dart';

const double resizeButtonSize = 40.0;
List<CursorType> cursorList = [
  CursorType.neResize,
  CursorType.ncResize,
  CursorType.nwResize,
  CursorType.mwResize,
  CursorType.swResize,
  CursorType.scResize,
  CursorType.seResize,
  CursorType.meResize,
];
List<CursorType> radiusList = [
  CursorType.neRadius,
  CursorType.nwRadius,
  CursorType.swRadius,
  CursorType.seRadius,
];

class ResiablePainter extends CustomPainter {
  bool isAccSelected = false;
  bool isFixedRatio = false;
  bool isInvisibleColorACC = false;
  Color bgColor;
  final CursorType cursor;

  bool resizable = true;
  final Size widgetSize;
  final bool isCornered;
  final bool isRadiused;
  final bool isHover;
  final List<bool> isCornerHover;
  final List<bool> isRadiusHover;

  Offset delta = Offset.zero;
  final double radiusTopLeft;
  final double radiusTopRight;
  final double radiusBottomLeft;
  final double radiusBottomRight;
  final ACCType accType;
  //final List<bool> isEdgeHover;
  //final List<Rect> rect;
  //Size _realSize = const Size(0, 0);

  Paint bgPaint = Paint();
  Paint fgPaint = Paint();
  Paint selectPaint = Paint();
  Paint linePaint = Paint();
  Paint linePaintBg = Paint();
  Paint fixedPaint = Paint();

  ResiablePainter(
      this.cursor,
      this.isAccSelected,
      this.isFixedRatio,
      this.isInvisibleColorACC,
      this.bgColor,
      this.resizable,
      this.widgetSize,
      this.isCornered,
      this.isRadiused,
      this.isHover,
      this.isCornerHover,
      this.isRadiusHover,
      this.radiusTopLeft,
      this.radiusTopRight,
      this.radiusBottomLeft,
      this.radiusBottomRight,
      this.accType)
      : super() {
    bgPaint.color = MyColors.gray02.withOpacity(.7);
    fgPaint.color = Colors.white;
    selectPaint.color = MyColors.primaryColor;
    linePaint.color = MyColors.primaryColor;
    linePaintBg.color = MyColors.accBg;
    fixedPaint.color = Colors.blue;

    bgPaint.style = PaintingStyle.fill;
    fgPaint.style = PaintingStyle.stroke;
    selectPaint.style = PaintingStyle.fill;
    linePaint.style = PaintingStyle.stroke;
    linePaintBg.style = PaintingStyle.stroke;
    fixedPaint.style = PaintingStyle.stroke;

    bgPaint.strokeWidth = 2.0;
    fgPaint.strokeWidth = 2.0;
    selectPaint.strokeWidth = 3.0;
    linePaint.strokeWidth = 3.0;
    linePaintBg.strokeWidth = linePaint.strokeWidth;
    fixedPaint.strokeWidth = 2.0;

    // shader example !!!!
    // ..shader = LinearGradient(
    //   begin: Alignment.topRight,
    //   end: Alignment.bottomLeft,
    //   colors: [
    //     Colors.pink[900]!.withOpacity(0.5),
    //     Colors.pink[200]!.withOpacity(0.5),
    //   ],
    // ).createShader(Rect.fromLTRB(0, 0, r, r))

    // blus example !!!
    //..blendMode = BlendMode.darken
    //  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // resize 가 가능하게 하는...외곽선과 꼭지가 나오도록 한다.
    if (!resizable) {
      return;
    }

    double margin = resizeButtonSize / 2 + linePaint.strokeWidth;
    Rect rect = Rect.fromLTWH(
        margin,
        margin,
        size.width - resizeButtonSize - linePaint.strokeWidth * 2,
        size.height - resizeButtonSize - linePaint.strokeWidth * 2);
    if (isAccSelected) {
      canvas.drawRect(
          Rect.fromLTRB(
            rect.left + linePaint.strokeWidth / 2,
            rect.top + linePaint.strokeWidth / 2,
            rect.right - linePaint.strokeWidth / 2,
            rect.bottom - linePaint.strokeWidth / 2,
          ),
          linePaintBg);
      canvas.drawRect(rect, linePaint);
      // canvas.drawRect(
      //     Rect.fromLTRB(
      //       rect.left + 3,
      //       rect.top + 3,
      //       rect.right - 3,
      //       rect.bottom - 3,
      //     ),
      //     linePaintBg);
    } else if (isInvisibleColorACC) {
      dotRect(canvas, rect, strokeWidth: 1, color: MyColors.primaryColor, gap: 5);
    }

    if (isHover || isCornered) {
      List<Offset> centerList = getCornerCenters(size);
      int i = 0;
      for (Offset center in centerList) {
        drawCircleHandle(canvas, center, resizeButtonSize / 2, isCornerHover[i]);
        i++;
      }
    }
    if (accType != ACCType.youtube) {
      // youtube 는 corner radius 를 줄 수 없다.
      if (isHover || isRadiused) {
        List<Offset> bigList = [
          Offset(1.0 * pi, 0.5 * pi),
          Offset(1.5 * pi, 0.5 * pi),
          Offset(0.0 * pi, 0.5 * pi),
          Offset(0.5 * pi, 0.5 * pi),
        ];
        List<Offset> smallList = [
          Offset(1.1 * pi, 0.3 * pi),
          Offset(1.6 * pi, 0.3 * pi),
          Offset(0.1 * pi, 0.3 * pi),
          Offset(0.6 * pi, 0.3 * pi),
        ];
        List<Rect> arcList = getRadiusRect(
            size, radiusTopLeft, radiusTopRight, radiusBottomRight, radiusBottomLeft, widgetSize);

        for (int i = 0; i < 4; i++) {
          drawArcHandle(canvas, arcList[i], bigList[i].dx, bigList[i].dy, smallList[i].dx,
              smallList[i].dy, isRadiusHover[i]);
        }
      }
    }
  }

  void drawCircleHandle(Canvas canvas, Offset center, double radius, bool isSelected) {
    if (isSelected) {
      canvas.drawCircle(center, radius, selectPaint);
      canvas.drawCircle(center, radius - 2, fgPaint);
      if (isFixedRatio) drawFixedRatioSymbol(canvas, center, radius, cursor);
    } else {
      canvas.drawCircle(center, radius / 2, bgPaint);
      canvas.drawCircle(center, radius / 2 - 1, fgPaint);
    }
  }

  void drawFixedRatioSymbol(Canvas canvas, Offset center, double radius, CursorType cursor) {
    Offset left = Offset(center.dx - resizeButtonSize / 2, center.dy);
    Offset right = Offset(center.dx + resizeButtonSize / 2, center.dy);
    Offset up = Offset(center.dx, center.dy - resizeButtonSize / 2);
    Offset down = Offset(center.dx, center.dy + resizeButtonSize / 2);

    switch (cursor) {
      case CursorType.neResize:
        canvas.drawLine(center, right, fixedPaint);
        canvas.drawLine(center, down, fixedPaint);
        break;
      case CursorType.nwResize:
        canvas.drawLine(left, center, fixedPaint);
        canvas.drawLine(center, down, fixedPaint);
        break;
      case CursorType.seResize:
        canvas.drawLine(center, right, fixedPaint);
        canvas.drawLine(center, up, fixedPaint);
        break;
      case CursorType.swResize:
        canvas.drawLine(left, center, fixedPaint);
        canvas.drawLine(center, up, fixedPaint);
        break;
      case CursorType.ncResize:
      case CursorType.scResize:
        canvas.drawLine(left, right, fixedPaint);
        break;
      case CursorType.mwResize:
      case CursorType.meResize:
        canvas.drawLine(up, down, fixedPaint);
        break;
      default:
        break;
    }
  }

  void drawArcHandle(Canvas canvas, Rect rect, double bigStart, double bigEnd, double smallStart,
      double smallEnd, bool isSelected) {
    if (isSelected) {
      canvas.drawArc(rect, bigStart, bigEnd, true, selectPaint);
      canvas.drawArc(rect, bigStart, bigEnd, true, fgPaint);
    } else {
      canvas.drawArc(rect, smallStart, smallEnd, true, bgPaint);
      canvas.drawArc(rect, smallStart, smallEnd, true, fgPaint);
    }
  }

  void dotRect(Canvas canvas, Rect rect,
      {double strokeWidth = 5.0, Color color = Colors.red, double gap = 5.0}) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double left = rect.left;
    double top = rect.top;
    double right = rect.right;
    double bottom = rect.bottom;

    Path _topPath = getDashedPath(
      a: Point(left, top),
      b: Point(right, top),
      gap: gap,
    );

    Path _rightPath = getDashedPath(
      a: Point(right, top),
      b: Point(right, bottom),
      gap: gap,
    );

    Path _bottomPath = getDashedPath(
      a: Point(left, bottom),
      b: Point(right, bottom),
      gap: gap,
    );

    Path _leftPath = getDashedPath(
      a: Point(left, top),
      b: Point(left + 0.001, bottom),
      gap: gap,
    );

    canvas.drawPath(_topPath, dashedPaint);
    canvas.drawPath(_rightPath, dashedPaint);
    canvas.drawPath(_bottomPath, dashedPaint);
    canvas.drawPath(_leftPath, dashedPaint);
  }

  Path getDashedPath({
    required Point<double> a,
    required Point<double> b,
    required gap,
  }) {
    Size size = Size(b.x - a.x, b.y - a.y);
    Path path = Path();
    path.moveTo(a.x, a.y);
    bool shouldDraw = true;
    Point currentPoint = Point(a.x, a.y);

    num radians = atan(size.height / size.width);

    num dx = cos(radians) * gap < 0 ? cos(radians) * gap * -1 : cos(radians) * gap;

    num dy = sin(radians) * gap < 0 ? sin(radians) * gap * -1 : sin(radians) * gap;

    while (currentPoint.x <= b.x && currentPoint.y <= b.y) {
      shouldDraw
          ? path.lineTo(currentPoint.x.toDouble(), currentPoint.y.toDouble())
          : path.moveTo(currentPoint.x.toDouble(), currentPoint.y.toDouble());
      shouldDraw = !shouldDraw;
      currentPoint = Point(
        currentPoint.x + dx,
        currentPoint.y + dy,
      );
    }
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  static bool isCorner(Offset point, Offset center, double radius) {
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

  static List<Offset> getCornerCenters(Size size) {
    double r = resizeButtonSize;
    double margin = r / 2;

    double east = margin;
    double center = size.width / 2;
    double west = size.width - margin;

    double north = margin;
    double middle = size.height / 2;
    double south = size.height - margin;

    List<Offset> centerList = [
      // 시계방향으로 나열한다.
      Offset(east, north),
      Offset(center, north),
      Offset(west, north),
      Offset(west, middle),
      Offset(west, south),
      Offset(center, south),
      Offset(east, south),
      Offset(east, middle),
    ];
    return centerList;
  }

  static List<Rect> getRadiusRect(Size size, double radiusTopLeft, double radiusTopRight,
      double radiusBottomRight, double radiusBottomLeft, Size realSize) {
    double r = resizeButtonSize; // size of handle
    //double padding = r / 2; // mousePadding

    double left = resizeButtonSize;
    double top = resizeButtonSize;
    double right = size.width - resizeButtonSize - r;
    double bottom = size.height - resizeButtonSize - r;

    double ne = getRadiusPos(percentToRadius(radiusTopLeft, realSize));
    double nw = getRadiusPos(percentToRadius(radiusTopRight, realSize));
    double sw = getRadiusPos(percentToRadius(radiusBottomRight, realSize), minus: -1);
    double se = getRadiusPos(percentToRadius(radiusBottomLeft, realSize));

    List<Rect> arcList = [
      // left,top,width,height
      Rect.fromLTWH(left + ne, top + ne, r, r), //neResize
      Rect.fromLTWH(right - nw, top + nw, r, r), //nwResize
      Rect.fromLTWH(right + sw, bottom + sw, r, r), //swResize
      Rect.fromLTWH(left + se, bottom - se, r, r), //seResize
    ];
    return arcList;
  }
}
