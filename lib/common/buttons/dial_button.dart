// ignore_for_file: prefer_final_fields, no_logic_in_create_state

import 'package:creta01/common/util/logger.dart';
import 'package:creta01/common/util/my_utils.dart';
import 'package:creta01/common/util/textfileds.dart';
import 'package:creta01/constants/styles.dart';
import 'package:flutter/material.dart';
//import 'dart:async';
import 'dart:math';

// ignore: must_be_immutable
class DialView extends StatefulWidget {
  DialView({
    Key? key,
    required this.angle,
    required this.size,
    required this.onValueChanged,
  }) : super(key: key);

  final Size size;
  double angle;
  final void Function(double value)? onValueChanged;

  @override
  DialViewState createState() => DialViewState(size: size);
}

class DialViewState extends State<DialView> {
  Size size = Size.zero;

  DialViewState({required this.size});

  Offset handleOffset = Offset.zero;
  Offset center = Offset.zero;
  double radius = 100;
  bool dragStart = false;
  double handleRadius = 20;

  TextEditingController angleCon = TextEditingController();

  @override
  void initState() {
    radius = size.width / 2;
    handleRadius = radius / 5;
    // Timer.periodic(const Duration(seconds: 1), (timer) {
    //   setState(() {});
    // });

    //logHolder.log('initState');
    super.initState();
  }

  void resetHandle() {
    var centerX = size.width / 2;
    var centerY = size.height / 2;
    center = Offset(centerX, centerY);
    radius = min(centerX, centerY);
    handleOffset = moveOnCircle(widget.angle, radius - (handleRadius / 2) - 20, center);
    //logHolder.log('resetHandle=$handleOffset');
  }

  @override
  Widget build(BuildContext context) {
    //logHolder.log('build: $dragStart');
    resetHandle();
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Transform.rotate(
                angle: -pi / 2,
                child: CustomPaint(
                  painter: DialPainter(this),
                ),
              ),
            ),
            onHorizontalDragStart: (DragStartDetails start) {
              //RenderBox box = context.findRenderObject() as RenderBox;
              //Offset localOffset = box.globalToLocal(start.globalPosition);
              logHolder.log('Start:${start.localPosition}}, $handleOffset');

              // double movedAngle = getRoundMoveangle(start.localPosition, radius);
              // if (movedAngle >= 0) {
              //   setState(() {
              //     angle = movedAngle;
              //   });
              // }
              // 파이 좌표계를 일반 좌표계로 변환하는 공식
              //  x 와 y 를 뒤집고, x 에서 width 를 뺀뒤 절대값으로 치환한다.
              Offset trans = Offset(handleOffset.dy, (handleOffset.dx - size.width).abs());
              if (isInCircle(start.localPosition, trans, handleRadius + 4)) {
                setState(() {
                  dragStart = true;
                });
              }
            },
            onHorizontalDragUpdate: (DragUpdateDetails update) {
              if (dragStart) {
                double movedAngle = getRoundMoveAngle(update.localPosition, radius);
                if (movedAngle >= 0) {
                  setState(() {
                    widget.angle = movedAngle.roundToDouble();
                  });
                  if (widget.onValueChanged != null) {
                    widget.onValueChanged!.call(widget.angle);
                  }
                }
              }
            },
            onHorizontalDragEnd: (DragEndDetails end) {
              //ogHolder.log('End:${end.velocity}');
              setState(() {
                if (dragStart) {
                  dragStart = false;
                  if (widget.onValueChanged != null) {
                    widget.onValueChanged!.call(widget.angle);
                  }
                }
              });
            }),
        myNumberTextField(
            width: 120,
            textAlign: TextAlign.end,
            //textAlignVertical: TextAlignVertical.center,
            //hasBorder: true,
            hasDeleteButton: true,
            hasCounterButton: true,
            defaultValue: widget.angle,
            controller: angleCon,
            onEditingComplete: () {
              setState(() {
                widget.angle = double.parse(angleCon.text);
                if (widget.onValueChanged != null) {
                  widget.onValueChanged!.call(widget.angle);
                }
              });
            }),
      ],
    );
  }
}

class DialPainter extends CustomPainter {
  var dateTime = DateTime.now();

  final DialViewState state;

  DialPainter(this.state);

  //60 sec - 360, 1 sec - 6angle
  //12 hours  - 360, 1 hour - 30angles, 1 min - 0.5angles

  @override
  void paint(Canvas canvas, Size size) {
    //logHolder.log('paint ${state.angle}');
    // var centerX = size.width / 2;
    // var centerY = size.height / 2;
    // var center = Offset(centerX, centerY);
    // var radius = min(centerX, centerY);

    var fillBrush = Paint()
      ..color = Colors.grey.withOpacity(.9)
      ..isAntiAlias = true
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomLeft,
              colors: [Color(0xFFFCFCFC), Color(0xFF808080)])
          .createShader(Rect.fromCircle(center: state.center, radius: state.radius));
    //  RadialGradient(
    //   //center: Alignment.bottomLeft,
    //   colors: [Color(0xFFFAFAFA), Color(0xFFA0A0A0)],
    //   focal: Alignment.centerLeft,
    // ).createShader(
    //     Rect.fromCircle(center: state.center, radius: state.radius));

    //..maskFilter = const MaskFilter.blur(BlurStyle.solid, 5)
    //..strokeJoin = StrokeJoin.round;

    var outlineBrush = Paint()
      ..color = MyColors.secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    var centerFillBrush = Paint()
      ..color = Colors.grey
      ..isAntiAlias = true
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill
      ..shader = const RadialGradient(
        //..shader = const LinearGradient(
        //  begin: Alignment.topCenter,
        //  end: Alignment.bottomLeft,
        colors: [
          Color(0xFFF0F0F0),
          Color(0xFFEFEFEF),
          Color(0xFFECECEC),
          Color(0xFFE0E0E0),
          Color(0xFFC0C0C0),
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(state.handleOffset.dx + 2, state.handleOffset.dy + 2),
          radius: state.handleRadius));

    var dragBrush = Paint()
      ..color = MyColors.mainColor.withOpacity(.9)
      ..isAntiAlias = true
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill
      //..blendMode = BlendMode.darken
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 5)
      ..strokeJoin = StrokeJoin.round;

    // var minHandBrush = Paint()
    //   ..shader =
    //       const RadialGradient(colors: [Color(0xFF748EF6), Color(0xFF77DDFF)])
    //           .createShader(Rect.fromCircle(center: center, radius: radius))
    //   ..style = PaintingStyle.stroke
    //   ..strokeCap = StrokeCap.round
    //   ..strokeWidth = 8;

    // var hourHandBrush = Paint()
    //   ..shader =
    //       const RadialGradient(colors: [Color(0xFFEA74AB), Color(0xFFC279FB)])
    //           .createShader(Rect.fromCircle(center: center, radius: radius))
    //   ..style = PaintingStyle.stroke
    //   ..strokeCap = StrokeCap.round
    //   ..strokeWidth = 12;

    var dashBrush = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;

    canvas.drawCircle(state.center, state.radius, fillBrush);
    canvas.drawCircle(state.center, state.radius, outlineBrush);

    // var hourHandX = centerX +
    //     60 * cos((dateTime.hour * 30 + dateTime.minute * 0.5) * pi / 180);
    // var hourHandY = centerX +
    //     60 * sin((dateTime.hour * 30 + dateTime.minute * 0.5) * pi / 180);
    // canvas.drawLine(center, Offset(hourHandX, hourHandY), hourHandBrush);

    // var minHandX = centerX + 80 * cos(dateTime.minute * 6 * pi / 180);
    // var minHandY = centerX + 80 * sin(dateTime.minute * 6 * pi / 180);
    // canvas.drawLine(center, Offset(minHandX, minHandY), minHandBrush);

    // var secHandX = centerX + 80 * cos(dateTime.second * 6 * pi / 180);
    // var secHandY = centerX + 80 * sin(dateTime.second * 6 * pi / 180);
    // canvas.drawLine(center, Offset(secHandX, secHandY), secHandBrush);

    //canvas.drawCircle(
    //    Offset(center.dx, center.dy), 16, centerFillBrush);

    var centerX = state.center.dx;
    var centerY = state.center.dy;
    var outerCircleRadius = state.radius + 16;
    var innerCircleRadius = state.radius + 10;
    for (double i = 0; i < 360; i += 15) {
      //15도당 한줄
      double ext = 0;

      if (i % (6 * 15) == 0) {
        ext = 6;
        dashBrush.strokeWidth = 3;
      } else if (i % (3 * 15) == 0) {
        ext = 3;
        dashBrush.strokeWidth = 2;
      } else {
        dashBrush.strokeWidth = 1;
      }

      var x1 = centerX + (outerCircleRadius + ext) * cos(i * pi / 180);
      var y1 = centerY + (outerCircleRadius + ext) * sin(i * pi / 180);

      var x2 = centerX + innerCircleRadius * cos(i * pi / 180);
      var y2 = centerY + innerCircleRadius * sin(i * pi / 180);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dashBrush);
    }
    if (state.dragStart) {
      //logHolder.log('drag mode ${state.handleOffset}');
      canvas.drawCircle(state.handleOffset, state.handleRadius + 4, dragBrush);
    }
    canvas.drawCircle(state.handleOffset, state.handleRadius, centerFillBrush);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
