// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, sized_box_for_whitespace, must_be_immutable
import 'package:flutter/material.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class WaveEffect extends StatefulWidget {
  WaveEffect(
      {Key? key,
      required this.height,
      this.title = '',
      this.blurIndex = 0,
      this.bgColor = Colors.blueAccent,
      this.colorList})
      : super(key: key);

  final String title;
  final int blurIndex;
  final double height;
  final Color bgColor;

  List<List<Color>>? colorList;

  List<List<Color>> defaultColorList = [
    [Colors.cyan, Color.fromARGB(237, 54, 114, 244)],
    [Colors.blue, Color.fromARGB(50, 15, 0, 82)],
    [Colors.blue[800]!, Color.fromRGBO(0, 119, 255, 0.4)],
    [Colors.indigo, Color.fromARGB(84, 111, 59, 255)],
    // [Colors.red, Color(0xEEF44336)],
    // [Colors.red[800]!, Color(0x77E57373)],
    // [Colors.orange, Color(0x66FF9800)],
    // [Colors.yellow, Color(0x55FFEB3B)]
  ];

  @override
  WaveEffectState createState() => WaveEffectState();
}

class WaveEffectState extends State<WaveEffect> {
  final List<MaskFilter> _blurs = [
    MaskFilter.blur(BlurStyle.normal, 0.0),
    MaskFilter.blur(BlurStyle.normal, 10.0),
    MaskFilter.blur(BlurStyle.inner, 10.0),
    MaskFilter.blur(BlurStyle.outer, 10.0),
    MaskFilter.blur(BlurStyle.solid, 16.0),
  ];
  MaskFilter? _blur;

  @override
  Widget build(BuildContext context) {
    _blur = _blurs[widget.blurIndex];
    return Center(
      child: Container(
        height: widget.height,
        width: double.infinity,
        child: WaveWidget(
          config: CustomConfig(
            gradients: widget.colorList == null ? widget.defaultColorList : widget.colorList!,
            durations: [35000, 19440, 10800, 6000],
            heightPercentages: [0.20, 0.23, 0.25, 0.30],
            blur: _blur,
            gradientBegin: Alignment.bottomLeft,
            gradientEnd: Alignment.topRight,
          ),
          backgroundColor: widget.bgColor,
          //backgroundImage: backgroundImage,
          size: Size(double.infinity, double.infinity),
          waveAmplitude: 0,
        ),
      ),
    );
  }
}
