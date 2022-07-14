import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

//import '../../theme.dart';
import '../../../constants/strings.dart';
import 'opacity_slider_thumb.dart';
import 'opacity_slider_track.dart';

//import 'package:creta01/constants/strings.dart';
//import 'package:creta01/common/colorPicker/widgets/selectors/channels/channel_slider.dart';
const double defaultRadius = 8.0;
const defaultBorderRadius = BorderRadius.all(Radius.circular(defaultRadius));

class OpacitySlider extends StatelessWidget {
  final double opacity;

  final Color selectedColor;

  final ValueChanged<double> onChange;

  const OpacitySlider({
    required this.opacity,
    required this.selectedColor,
    required this.onChange,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return FutureBuilder<ui.Image>(
      future: getGridImage(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    //width: 60,
                    child: Text(
                      MyStrings.opacity,
                      style: textTheme.bodyText1,
                    ),
                  ),
                  Expanded(
                    child: Theme(
                      data: opacitySliderTheme(selectedColor),
                      child: Slider(
                        value: opacity,
                        min: 0,
                        max: 1,
                        divisions: 100,
                        onChanged: onChange,
                      ),
                    ),
                  ),
                  Container(
                    //margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    // decoration: BoxDecoration(
                    //   color: theme.inputDecorationTheme.fillColor,
                    //   borderRadius: defaultBorderRadius,
                    // ),
                    // width: 60,
                    child: Text(
                      '${((1 - opacity) * 100).toInt()}%',
                      //textAlign: TextAlign.center,
                      style: textTheme.bodyText1,
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
    // return Padding(
    //   padding: const EdgeInsets.only(top: 4.0),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Padding(
    //         padding: const EdgeInsets.only(left: 8.0),
    //         child: Text(MyStrings.opacity, style: textTheme.subtitle2),
    //       ),
    //       Row(
    //         mainAxisSize: MainAxisSize.max,
    //         children: [
    //           Expanded(
    //             child: Theme(
    //               data: _sliderTheme(selectedColor, [
    //                 selectedColor.withOpacity(0),
    //                 selectedColor.withOpacity(1)
    //               ]),
    //               child: Slider(
    //                 value: opacity,
    //                 min: 0,
    //                 max: 1,
    //                 divisions: 100,
    //                 onChanged: onChange,
    //               ),
    //             ),
    //           ),
    //           Container(
    //             margin: const EdgeInsets.symmetric(horizontal: 8),
    //             padding: const EdgeInsets.all(8),
    //             decoration: BoxDecoration(
    //               color: theme.inputDecorationTheme.fillColor,
    //               borderRadius: defaultBorderRadius,
    //             ),
    //             width: 60,
    //             child: Text(
    //               '${((1 - opacity) * 100).toInt()}%',
    //               textAlign: TextAlign.center,
    //               style: textTheme.bodyText1,
    //             ),
    //           )
    //         ],
    //       ),
    //     ],
    //   ),
    // );
  }
}

ui.Image? _gridImage;

Future<ui.Image> getGridImage() {
  if (_gridImage != null) return Future.value(_gridImage!);
  final completer = Completer<ui.Image>();
  const AssetImage('assets/grid.png')
      .resolve(const ImageConfiguration())
      .addListener(ImageStreamListener((ImageInfo info, bool _) {
    _gridImage = info.image;
    completer.complete(_gridImage);
  }));
  return completer.future;
}

ThemeData opacitySliderTheme(Color color) => ThemeData.light().copyWith(
      sliderTheme: SliderThemeData(
        trackHeight: 24,
        thumbColor: Colors.white,
        trackShape: OpacitySliderTrack(color, gridImage: _gridImage!),
        thumbShape: OpacitySliderThumbShape(color),
      ),
    );

// ThemeData _sliderTheme(Color color, List<Color> colors) =>
//     ThemeData.light().copyWith(
//       sliderTheme: SliderThemeData(
//         trackHeight: 24,
//         thumbColor: Colors.white,
//         trackShape: ChannelSliderTrack(color, colors),
//       ),
//     );
