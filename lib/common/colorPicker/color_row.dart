// ignore_for_file: prefer_const_constructors
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:creta01/constants/styles.dart';
import 'package:creta01/model/users.dart';
import 'package:creta01/common/colorPicker/my_color_indicator.dart';

import '../../constants/strings.dart';
import '../slider/opacity/opacity_slider.dart';
import '../util/my_utils.dart';
import '../util/textfileds.dart';

Widget myColorPicker(
  BuildContext context,
  Color color, {
  double? opacity,
  double? glassFill,
  double? outLineWidth,
  double maxGlassFill = 30,
  double maxOutLine = 9,
  required TextEditingController controller,
  required void Function(Color value) favorateColorPick,
  required void Function(Color value) onColorChangedEnd,
  required void Function(Color value) onEditComplete,
  required void Function(double) onGlassChanged,
  required void Function(double) onOpacityChanged,
  required void Function(double) onOutLineChanged,
}) {
  return Container(
    padding: EdgeInsets.only(right: 20),
    alignment: Alignment.topCenter,
    child: Column(
        // 배경 색상
        children: [
          SizedBox(
            height: 10,
          ),
          favorateColors(
            context: context,
            value: color,
            list: [
              for (int i = 0; i < currentUser.maxBgColor; i++) currentUser.bgColorList1[i],
            ],
            onPressed: (bg) => favorateColorPick(bg),
          ),
          SizedBox(
            height: 10,
          ),
          ColorPicker(
            subheading: smallDivider(),
            pickersEnabled: const <ColorPickerType, bool>{
              ColorPickerType.both: false,
              ColorPickerType.primary: true,
              ColorPickerType.accent: true,
              ColorPickerType.bw: false,
              ColorPickerType.custom: false,
              ColorPickerType.wheel: true
            },
            pickerTypeLabels: <ColorPickerType, String>{
              ColorPickerType.primary: MyStrings.basicColor,
              ColorPickerType.accent: MyStrings.accentColor,
              ColorPickerType.wheel: MyStrings.customColor
            },
            color: color,
            onColorChanged: (bg) {},
            onColorChangeEnd: (bg) => onColorChangedEnd(bg),
            width: 22,
            height: 22,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            showColorName: false,
            showRecentColors: false,
            //maxRecentColors: currentUser.maxBgColor,
            //recentColors: currentUser.bgColorList1,
            //onRecentColorsChanged: (list) {
            //  currentUser.bgColorList1 = list;
            //},
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                MyStrings.bgColorCodeInput,
                style: MyTextStyles.subtitle2,
              ),
              SizedBox(
                width: 100,
                height: 30,
                child: myTextField(
                  '#${color.toString().substring(10, 16)}',
                  limit: 9,
                  controller: controller,
                  style: MyTextStyles.body2,
                  enabled: true,
                  hasBorder: true,
                  hasDeleteButton: false,
                  onEditingComplete: () {
                    _editComplete(controller, onEditComplete);
                  },
                ),
              ),
              writeButton(
                // color를  Write 하는 icon
                onPressed: () {
                  _editComplete(controller, onEditComplete);
                },
              ),
            ],
          ),
          // 유리느낌.
          glassFill != null
              ? doubleSlider(
                  title: MyStrings.glass,
                  value: glassFill,
                  onChanged: (val) => onGlassChanged(val),
                  onChangeStart: (val) {},
                  min: 0,
                  max: maxGlassFill,
                )
              : Container(),
          outLineWidth != null
              ? doubleSlider(
                  title: MyStrings.outlineWidth,
                  value: outLineWidth,
                  onChanged: (val) => onOutLineChanged(val),
                  onChangeStart: (val) {},
                  min: 0,
                  max: maxOutLine,
                )
              : Container(),
          opacity != null
              ? OpacitySlider(
                  selectedColor: MyColors.secondaryColor,
                  opacity: opacity,
                  onChange: (value) {
                    onOpacityChanged(value);
                  },
                )
              : Container(),
        ]),
  );
}

void _editComplete(TextEditingController colorCon, void Function(Color value) onEditComplete) {
  if (colorCon.text.isEmpty) {
    return;
  }
  String newVal = "";
  if (colorCon.text[0] == '#') {
    if (colorCon.text.length == 9) {
      newVal = colorCon.text;
    } else if (colorCon.text.length == 7) {
      newVal = '#ff${colorCon.text.substring(1)}';
    }
  } else {
    if (colorCon.text.length == 8) {
      newVal = '#${colorCon.text}';
    } else if (colorCon.text.length == 6) {
      newVal = '#ff${colorCon.text}';
    }
  }
  if (newVal.isNotEmpty) {
    Color color = hexToColor(newVal);
    onEditComplete(color);
    currentUser.setUserColorList(color);
  }
}

Widget favorateColors(
    {required BuildContext context,
    required Color value,
    required List<Color> list,
    required void Function(Color) onPressed}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      ...[
        for (int i = 0; i < currentUser.maxBgColor; i++) currentUser.bgColorList1[i],
      ].map((bg) {
        //TinyColor tinyColor = TinyColor(bg);
        return MyColorIndicator(
          color: bg == Color(0x00000000) ? Color(0xFFFFFFFF) : bg,
          onSelect: () {
            onPressed.call(bg);
          },
          isSelected: value == bg,
          useUnselectedIcon: bg == Color(0x00000000),
          width: 25,
          height: 25,
          borderRadius: 0,
          hasBorder: true,
          borderColor: bg == Color(0x00000000) ? Colors.black : MyColors.primaryColor,
          elevation: 5,
        );
        // CircleAvatar(
        //     radius: value == bg ? 18 : 14,
        //     backgroundColor: value == bg
        //         ? bg == Color(0x00000000)
        //             ? Color(0xFFFFFFFF)
        //             : MyColors.primaryColor
        //         : MyColors.secondaryColor,
        //     child: IconButton(
        //       padding: EdgeInsets.zero,
        //       //constraints: BoxConstraints.tight(Size(20, 20)),
        //       constraints: BoxConstraints(),
        //       iconSize: value == bg ? 34 : 24,
        //       icon: bg == Color(0x00000000)
        //           ? Icon(Icons.clear)
        //           : Icon(Icons.circle),
        //       color: bg == Color(0x00000000) ? Color(0xFF101010) : bg,
        //       onPressed: () {
        //         onPressed.call(bg);
        //       },
        //     ));
      }).toList()
    ],
  );
}

MyColorIndicator glassIcon(bool isSelected, Color bg, {required void Function() onClicked}) {
  return MyColorIndicator(
      color: bg == Color(0x00000000) ? Color(0xFFFFFFFF) : bg,
      onSelect: onClicked,
      isSelected: true, //acc.glass.value,
      width: 24,
      height: 24,
      borderRadius: 0,
      hasBorder: true,
      borderColor: bg == Color(0x00000000) ? Colors.black : MyColors.primaryColor,
      elevation: 5,
      selectedIcon: isSelected ? Icons.check : Icons.close);
}
