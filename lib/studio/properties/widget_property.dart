// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable
//import 'dart:html';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter/cupertino.dart';
import 'package:creta01/studio/pages/page_manager.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter_neumorphic_null_safety/flutter_neumorphic.dart';

import 'package:creta01/acc/acc.dart';
import 'package:creta01/acc/acc_manager.dart';
import 'package:creta01/model/model_enums.dart';
import 'package:creta01/model/pages.dart';
import 'package:creta01/studio/properties/property_selector.dart';
import 'package:creta01/studio/properties/contents_property.dart';
import 'package:creta01/constants/strings.dart';
import 'package:creta01/constants/styles.dart';
import 'package:creta01/model/users.dart';
import 'package:creta01/common/util/textfileds.dart';
import 'package:creta01/common/util/logger.dart';
import 'package:creta01/common/util/my_utils.dart';
import 'package:creta01/common/undo/undo.dart';
import 'package:creta01/common/colorPicker/color_row.dart';
import 'package:creta01/studio/properties/properties_frame.dart';
//import 'package:creta01/common/buttons/wave_slider.dart';
import 'package:creta01/common/buttons/dial_button.dart';
import 'package:creta01/common/neumorphic/neumorphic.dart';
import 'package:creta01/common/buttons/basic_button.dart';

class ExapandableModel {
  ExapandableModel({
    required this.title,
    required this.height,
    required this.width,
  });
  bool isSelected = false;
  String title;
  Widget? child;
  double height;
  double width;

  void toggleSelected() {
    isSelected = !isSelected;
  }

  Widget expandArea({
    double left = 25,
    double top = 6,
    double right = 0,
    double bottom = 0,
    required Widget child,
    required void Function() setStateFunction,
    void Function()? closeOthers,
    double titleSize = 120,
    Widget? titleLineWidget,
    bool open = false,
    AlignmentDirectional align = AlignmentDirectional.center,
  }) {
    if (open) {
      if (closeOthers != null) {
        closeOthers.call();
        isSelected = true;
      }
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTapDown: (details) {
                  setStateFunction.call();
                },
                child: SizedBox(
                  width: titleSize,
                  child: Text(
                    title,
                    style: MyTextStyles.subtitle2,
                  ),
                ),
              ),
              if (titleLineWidget != null) titleLineWidget,
              IconButton(
                onPressed: setStateFunction,
                icon: Icon(isSelected ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
              ),
            ],
          ),
          isSelected
              ? AnimatedContainer(
                  alignment: align,
                  duration: Duration(milliseconds: 500),
                  height: height,
                  //alignment: Alignment.center,
                  child: child)
              : Container(),
        ],
      ),
    );
  }
}

class WidgetProperty extends PropertySelector {
  WidgetProperty(
    Key? key,
    PageModel? pselectedPage,
    bool pisNarrow,
    bool pisLandscape,
    PropertiesFrameState parent,
  ) : super(
          key: key,
          selectedPage: pselectedPage,
          isNarrow: pisNarrow,
          isLandscape: pisLandscape,
          parent: parent,
        );
  @override
  State<WidgetProperty> createState() => WidgetPropertyState();
}

class WidgetPropertyState extends State<WidgetProperty> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController(initialScrollOffset: 0.0);

  late AnimationController _aniIconController;

  TextEditingController descCon = TextEditingController();
  TextEditingController widthCon = TextEditingController();
  TextEditingController heightCon = TextEditingController();
  TextEditingController colorCon = TextEditingController();
  TextEditingController xCon = TextEditingController();
  TextEditingController yCon = TextEditingController();

  bool isSizeChangable = true;
  final List<ExapandableModel> _modelList = [];

  ExapandableModel animeModel = ExapandableModel(
    title: MyStrings.anime,
    height: 260,
    width: 240,
  );

  ExapandableModel bgColorModel = ExapandableModel(
    title: '${MyStrings.bgColor}/${MyStrings.glass}/${MyStrings.opacity}',
    height: 480,
    width: 240,
  );
  // ExapandableModel opacityModel = ExapandableModel(
  //   title: MyStrings.opacity,
  //   height: 64,
  //   width: 240,
  // );
  ExapandableModel sizePosModel = ExapandableModel(
    title: MyStrings.widgetSize,
    height: 180,
    width: 240,
  );
  ExapandableModel cornerModel = ExapandableModel(
    title: MyStrings.radius,
    height: 260,
    width: 240,
  );
  ExapandableModel rotateModel = ExapandableModel(
    title: MyStrings.rotate,
    height: 270,
    width: 240,
  );
  ExapandableModel borderModel = ExapandableModel(
    title: MyStrings.border,
    height: 440,
    width: 240,
  );

  void unexpendAll(String expandModelName) {
    for (ExapandableModel model in _modelList) {
      if (expandModelName != model.title) {
        model.isSelected = false;
      }
    }
  }

  @override
  void initState() {
    _aniIconController = AnimationController(
        animationBehavior: AnimationBehavior.preserve,
        vsync: this,
        duration: Duration(milliseconds: 1000));

    _modelList.add(animeModel);
    _modelList.add(bgColorModel);
    //_modelList.add(opacityModel);
    _modelList.add(sizePosModel);
    _modelList.add(cornerModel);
    _modelList.add(rotateModel);
    _modelList.add(borderModel);

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (accWasNotSelected != null) {
        logHolder.log('afterBuild WidgetPropertyState', level: 5);
        accWasNotSelected!.notify();
        accWasNotSelected = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thickness: 8.0,
      scrollbarOrientation: ScrollbarOrientation.left,
      thumbVisibility: true,
      //isAlwaysShown: true,
      controller: _scrollController,
      child: Consumer<ACCManager>(builder: (context, accManager, child) {
        //logHolder.log('Consumer of real accManager');

        ACC? acc = accManager.getCurrentACC();
        if (acc == null) {
          return Container();
        }

        return ListView(
          //mainAxisAlignment: MainAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.start,
          controller: _scrollController,
          children: [
            //_titleRow(25, 15, 12, 10),
            //divider(),
            _primaryRow(acc, 25, 25, 12, 5),
            divider(),
            _sourceRatioRow(acc, 25, 5, 12, 5),
            divider(),
            sizePosModel.expandArea(
                open: acc.sizeActionStart,
                closeOthers: () {
                  unexpendAll(sizePosModel.title);
                },
                child: _sizePosRow(context, acc),
                setStateFunction: () {
                  setState(() {
                    unexpendAll(sizePosModel.title);
                    sizePosModel.toggleSelected();
                  });
                },
                titleSize: 100,
                titleLineWidget: Text(
                  '${acc.accModel.containerOffset.value.dx.roundToDouble()},${acc.accModel.containerOffset.value.dy.roundToDouble()},${acc.accModel.containerSize.value.width.roundToDouble()} x ${acc.accModel.containerSize.value.height.roundToDouble()}',
                  style: MyTextStyles.subtitle1,
                )),
            divider(),
            bgColorModel.expandArea(
                child: _bgColorRow(context, acc),
                setStateFunction: () {
                  setState(() {
                    unexpendAll(bgColorModel.title);
                    bgColorModel.toggleSelected();
                  });
                },
                titleSize: 150,
                titleLineWidget: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    glassIcon(
                      acc.accModel.bgColor.value != Colors.transparent,
                      acc.accModel.bgColor.value,
                      onClicked: () {
                        setState(() {
                          if (acc.accModel.bgColor.value == Colors.transparent &&
                              acc.accModel.glassFill.value == 0 &&
                              acc.accModel.opacity.value == 1) {
                            acc.accModel.bgColor.set(acc.prevBgColor);
                            acc.accModel.glassFill.set(acc.prevGlassFill);
                            acc.accModel.opacity.set(acc.prevOpacity);
                          } else {
                            acc.prevBgColor = acc.accModel.bgColor.value;
                            acc.prevGlassFill = acc.accModel.glassFill.value;
                            acc.prevOpacity = acc.accModel.opacity.value;

                            acc.accModel.bgColor.set(Colors.transparent);
                            acc.accModel.glassFill.set(0);
                            acc.accModel.opacity.set(1);
                          }
                        });
                        acc.notify();
                      },
                    ),
                    acc.accModel.glassFill.value > 0
                        ? Icon(Icons.blur_on_rounded)
                        : SizedBox(
                            width: 20,
                          ),
                    Text(
                      '${((1 - acc.accModel.opacity.value) * 100).toInt()}%',
                    ),
                  ],
                )),
            divider(),
            // opacityModel.expandArea(
            //     child: _opacityRow(context, acc),
            //     titleLineWidget: Row(children: [
            //       Text(
            //         '${((1 - acc.accModel.opacity.value) * 100).round()} %',
            //         style: MyTextStyles.subtitle1,
            //       ),
            //     ]),
            //     setStateFunction: () {
            //       setState(() {
            //         unexpendAll(opacityModel.title);
            //         opacityModel.toggleSelected();
            //       });
            //     }),
            // divider(),
            rotateModel.expandArea(
                child: _rotateRow(context, acc),
                titleLineWidget: Text(
                  '${acc.accModel.rotate.value} °',
                  style: MyTextStyles.subtitle1,
                ),
                setStateFunction: () {
                  setState(() {
                    unexpendAll(rotateModel.title);
                    rotateModel.toggleSelected();
                  });
                }),
            divider(),
            animeModel.expandArea(
                child: _animeRow(context, acc),
                titleLineWidget: acc.accModel.animeType.value != AnimeType.none
                    ? Row(children: [
                        Text(_getAnimeName(acc.accModel.animeType.value)),
                        SizedBox(
                          width: 10,
                        ),
                        IconButton(
                            padding: EdgeInsets.zero,
                            icon: AnimatedIcon(
                              icon: _getAnimeIcon(acc.accModel.animeType.value),
                              progress: _aniIconController,
                              size: 30,
                              color: MyColors.primaryColor,
                            ),
                            //Icon(),
                            onPressed: () {
                              if (_aniIconController.isAnimating) {
                                _aniIconController.stop();
                              } else {
                                _aniIconController.repeat();
                                // _aniIconController.forward().then(
                                //   (value) async {
                                //     await Future.delayed(Duration(seconds: 1));
                                //     _aniIconController.reverse();
                                //   },
                                // );
                              }
                            }),
                      ])
                    : null,
                setStateFunction: () {
                  setState(() {
                    unexpendAll(animeModel.title);
                    animeModel.toggleSelected();
                  });
                }),
            divider(),
            borderModel.expandArea(
                child: _borderRow(context, acc),
                titleLineWidget: colorPickerIcon(
                    acc.accModel.borderColor.value, acc.accModel.borderWidth.value > 0, () {
                  setState(() {
                    if (acc.accModel.borderColor.value != Colors.transparent) {
                      acc.prevBorderColor = acc.accModel.borderColor.value;
                      acc.accModel.borderColor.set(Colors.transparent);
                      acc.notify();
                    } else {
                      if (acc.prevBorderColor != Colors.transparent) {
                        acc.accModel.borderColor.set(acc.prevBorderColor);
                        acc.notify();
                      }
                    }
                  });
                }),
                setStateFunction: () {
                  setState(() {
                    unexpendAll(borderModel.title);
                    borderModel.toggleSelected();
                    accManagerHolder!.unshowMenu(context); // border 를 잘 보기 위해 unshow 한다.
                  });
                }),
            divider(),
            cornerModel.expandArea(
                open: acc.radiusActionStart,
                closeOthers: () {
                  unexpendAll(cornerModel.title);
                },
                child: // Youtube 는 둥근모서리를 사용할 수 없다.
                    acc.accModel.accType == ACCType.youtube
                        ? Container()
                        : _cornerRow(context, acc),
                titleLineWidget: Text(
                  '${acc.accModel.radiusTopLeft.value.round()},${acc.accModel.radiusTopRight.value.round()},${acc.accModel.radiusBottomLeft.value.round()},${acc.accModel.radiusBottomRight.value.round()}',
                  style: MyTextStyles.subtitle1,
                ),
                setStateFunction: () {
                  setState(() {
                    unexpendAll(cornerModel.title);
                    cornerModel.toggleSelected();
                  });
                }),
            divider(),
            acc.hasContents() && pageManagerHolder!.isContents()
                ? ContentsProperty(widget.key, widget.selectedPage, widget.isNarrow,
                    widget.isLandscape, widget.parent)
                : Container(),
          ],
        );
      }),
    );
  }

  // Widget _titleRow(double left, double top, double right, double bottom) {
  //   return Padding(
  //     padding: EdgeInsets.fromLTRB(left, top, right, bottom),
  //     child: Text(
  //       MyStrings.widgetPropTitle,
  //       style: MyTextStyles.body1,
  //     ),
  //   );
  // }

  Widget _primaryRow(ACC acc, double left, double top, double right, double bottom) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: Row(
        children: [
          Text(
            MyStrings.primary,
            style: MyTextStyles.subtitle2,
          ),
          IconButton(
            padding: EdgeInsets.fromLTRB(18, 2, 8, 2),
            iconSize: 32.0,
            icon: Icon(
              acc.accModel.primary.value != true
                  ? Icons.star_outline_outlined
                  : Icons.star_outlined,
              color: acc.accModel.primary.value != true ? Colors.grey : MyColors.mainColor,
            ),
            onPressed: () {
              accManagerHolder!.setPrimary();
              setState(() {});
            },
          )
        ],
      ),
    );
  }

  Widget _sourceRatioRow(ACC acc, double left, double top, double right, double bottom) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: Row(
        children: [
          Text(
            acc.accModel.sourceRatio.value == true
                ? MyStrings.sourceRatio
                : MyStrings.sourceRatioToggle,
            style: MyTextStyles.subtitle2,
          ),
          IconButton(
            padding: EdgeInsets.fromLTRB(18, 2, 8, 2),
            iconSize: 32.0,
            icon: Icon(
              acc.accModel.sourceRatio.value == true
                  ? Icons.image_aspect_ratio_outlined
                  : Icons.aspect_ratio_outlined,
              color: acc.accModel.sourceRatio.value == true ? Colors.grey : MyColors.mainColor,
            ),
            onPressed: () {
              acc.accModel.sourceRatio.set(!acc.accModel.sourceRatio.value);
              //acc.notify();;
              acc.invalidateContents();
              setState(() {});
            },
          )
        ],
      ),
    );
  }

  Widget _locationRow(ACC acc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 30,
          child: Text(
            'X',
            style: MyTextStyles.subtitle2,
          ),
        ),
        myNumberTextField(
          // x 좌표
          defaultValue: acc.accModel.containerOffset.value.dx.roundToDouble(),
          controller: xCon,
          onEditingComplete: () {
            logHolder.log("textval = ${xCon.text}");
            setState(() {
              acc.accModel.containerOffset
                  .set(Offset(double.parse(xCon.text), acc.accModel.containerOffset.value.dy));
              acc.notify();
            });
          },
        ),
        SizedBox(
          width: 10,
        ),
        SizedBox(
          width: 30,
          child: Text(
            'Y',
            style: MyTextStyles.subtitle2,
          ),
        ),
        myNumberTextField(
          // y 좌표
          defaultValue: acc.accModel.containerOffset.value.dy.roundToDouble(),
          controller: yCon,
          onEditingComplete: () {
            logHolder.log("textval = ${yCon.text}");
            setState(() {
              acc.accModel.containerOffset
                  .set(Offset(acc.accModel.containerOffset.value.dx, double.parse(yCon.text)));
              acc.notify();
            });
          },
        ),
        writeButton(
          // x,y 좌표를  Write 하는 icon
          onPressed: () {
            mychangeStack.startTrans();
            acc.accModel.containerOffset
                .set(Offset(double.parse(xCon.text), double.parse(yCon.text)));
            mychangeStack.endTrans();
            acc.notify();
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _sizeRow(ACC acc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 30,
          child: Text(
            MyStrings.width,
            style: MyTextStyles.subtitle2,
          ),
        ),
        myNumberTextField(
          // 너비
          defaultValue: acc.accModel.containerSize.value.width.roundToDouble(),
          controller: widthCon,
          onEditingComplete: () {
            logHolder.log("textval = ${widthCon.text}");
            setState(() {
              acc.accModel.containerSize
                  .set(Size(double.parse(widthCon.text), acc.accModel.containerSize.value.height));
              acc.notify();
            });
          },
        ),
        SizedBox(
          width: 10,
        ),
        SizedBox(
          width: 30,
          child: Text(
            MyStrings.height,
            style: MyTextStyles.subtitle2,
          ),
        ),
        myNumberTextField(
          // 높이
          defaultValue: acc.accModel.containerSize.value.height.roundToDouble(),
          controller: heightCon,
          onEditingComplete: () {
            setState(() {
              acc.accModel.containerSize
                  .set(Size(acc.accModel.containerSize.value.width, double.parse(heightCon.text)));
              acc.notify();
            });
            logHolder.log("textval = ${heightCon.text}");
          },
        ),
        writeButton(
          // width,height를  Write 하는 icon
          onPressed: () {
            mychangeStack.startTrans();
            acc.accModel.containerSize
                .set(Size(double.parse(widthCon.text), double.parse(heightCon.text)));
            mychangeStack.endTrans();
            acc.notify();
            setState(() {});
          },
        ),
      ],
    );
  }

  // Widget _opacityRow(BuildContext context, ACC acc) {
  //   return Container(
  //     alignment: Alignment.center,
  //     child: Column(
  //       children: [
  //         OpacitySlider(
  //           selectedColor: MyColors.secondaryColor,
  //           opacity: acc.accModel.opacity.value,
  //           onChange: (value) {
  //             //logHolder.log('onValueChanged: $value');
  //             acc.accModel.opacity.set(value);
  //             acc.notify();
  //             setState(() {});
  //           },
  //         ),
  //         SizedBox(
  //           width: 15,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _rotateRow(BuildContext context, ACC acc) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
          alignment: Alignment.center,
          child: DialView(
            angle: acc.accModel.rotate.value,
            size: Size(190, 190),
            onValueChanged: (value) {
              //logHolder.log('onValueChanged: $value');
              acc.accModel.rotate.set(value);
              acc.notify();
              setState(() {});
            },
          )),
      myCheckBox(MyStrings.contentsRotate, acc.accModel.contentRotate.value, () {
        acc.accModel.contentRotate.set(!acc.accModel.contentRotate.value);
        acc.notify();
        //acc.invalidateContents();
        setState(() {});
      }, 18, 2, 8, 2),
    ]);
  }

  // void _editComplete() {
  //   if (colorCon.text.isEmpty) {
  //     return;
  //   }
  //   if (colorCon.text[0] == '#') {
  //     if (colorCon.text.length == 9) {
  //       acc.setBgColor(hexToColor(colorCon.text));
  //     } else if (colorCon.text.length == 7) {
  //       String newVal = '#ff${colorCon.text.substring(1)}';
  //       acc.setBgColor(hexToColor(newVal));
  //     }
  //   } else {
  //     if (colorCon.text.length == 8) {
  //       String newVal = '#${colorCon.text}';
  //       acc.setBgColor(hexToColor(newVal));
  //     } else if (colorCon.text.length == 6) {
  //       String newVal = '#ff${colorCon.text}';
  //       acc.setBgColor(hexToColor(newVal));
  //     }
  //   }
  //   currentUser.setUserColorList(acc.accModel.bgColor.value);
  // }

  Widget _bgColorRow(BuildContext context, ACC acc) {
    return myColorPicker(
      context,
      acc.accModel.bgColor.value,
      opacity: acc.accModel.opacity.value,
      glassFill: acc.accModel.glassFill.value,
      controller: colorCon,
      favorateColorPick: (value) {
        acc.setBgColor(value);
      },
      onColorChangedEnd: (value) {
        acc.setBgColor(value);
        currentUser.setUserColorList(value);
      },
      onEditComplete: (value) {
        acc.setBgColor(value);
      },
      onGlassChanged: (value) {
        setState(() {
          acc.accModel.glassFill.set(value);
          if (acc.accModel.glassFill.value > 0) {
            if (acc.accModel.bgColor.value == Colors.transparent) {
              // 바탕색이 투명일때, 유리질을 선택하면, 바탕색을 힌색으로 잡아준다.
              acc.accModel.bgColor.set(Colors.white);
            }
            if (acc.accModel.opacity.value == 1) {
              // opacity 가 안잡혀 있으면 자동으로 잡아준다.
              acc.accModel.opacity.set(0.5);
            }
          }
        });
        acc.notify();
      },
      onOpacityChanged: (value) {
        //logHolder.log('onValueChanged: $value');
        acc.accModel.opacity.set(value);
        acc.notify();
        setState(() {});
      },
      onOutLineChanged: (value) {},
    );

    // return Container(
    //   padding: EdgeInsets.only(right: 20),
    //   alignment: Alignment.topCenter,
    //   child: Column(
    //       // 배경 색상
    //       children: [
    //         SizedBox(
    //           height: 10,
    //         ),
    //         favorateColors(
    //           context: context,
    //           value: acc.accModel.bgColor.value,
    //           list: [
    //             for (int i = 0; i < currentUser.maxBgColor; i++) currentUser.bgColorList1[i],
    //           ],
    //           onPressed: (bg) {
    //             acc.setBgColor(bg);
    //             //pageManagerHolder!.notify();;
    //           },
    //         ),
    //         SizedBox(
    //           height: 10,
    //         ),
    //         ColorPicker(
    //           subheading: smallDivider(),
    //           pickersEnabled: const <ColorPickerType, bool>{
    //             ColorPickerType.both: false,
    //             ColorPickerType.primary: true,
    //             ColorPickerType.accent: true,
    //             ColorPickerType.bw: false,
    //             ColorPickerType.custom: false,
    //             ColorPickerType.wheel: true
    //           },
    //           pickerTypeLabels: <ColorPickerType, String>{
    //             ColorPickerType.primary: MyStrings.basicColor,
    //             ColorPickerType.accent: MyStrings.accentColor,
    //             ColorPickerType.wheel: MyStrings.customColor
    //           },
    //           color: acc.accModel.bgColor.value,
    //           onColorChanged: (bg) {},
    //           onColorChangeEnd: (bg) {
    //             acc.setBgColor(bg);
    //             currentUser.setUserColorList(bg);
    //           },
    //           width: 22,
    //           height: 22,
    //           padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
    //           showColorName: false,
    //           showRecentColors: false,
    //           //maxRecentColors: currentUser.maxBgColor,
    //           //recentColors: currentUser.bgColorList1,
    //           //onRecentColorsChanged: (list) {
    //           //  currentUser.bgColorList1 = list;
    //           //},
    //         ),
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               MyStrings.bgColorCodeInput,
    //               style: MyTextStyles.subtitle2,
    //             ),
    //             SizedBox(
    //               width: 100,
    //               height: 30,
    //               child: myTextField(
    //                 '#${acc.accModel.bgColor.value.toString().substring(10, 16)}',
    //                 limit: 9,
    //                 controller: colorCon,
    //                 style: MyTextStyles.body2,
    //                 enabled: true,
    //                 hasBorder: true,
    //                 hasDeleteButton: false,
    //                 onEditingComplete: () {
    //                   _editComplete(acc);
    //                 },
    //               ),
    //             ),
    //             writeButton(
    //               // color를  Write 하는 icon
    //               onPressed: () {
    //                 _editComplete(acc);
    //               },
    //             ),
    //           ],
    //         ),
    //         doubleSlider(
    //           title: MyStrings.glass,
    //           value: acc.accModel.glassFill.value,
    //           onChanged: (val) {
    //             setState(() {
    //               acc.accModel.glassFill.set(val);
    //               if (acc.accModel.glassFill.value > 0) {
    //                 if (acc.accModel.bgColor.value == Colors.transparent) {
    //                   // 바탕색이 투명일때, 유리질을 선택하면, 바탕색을 힌색으로 잡아준다.
    //                   acc.accModel.bgColor.set(Colors.white);
    //                 }
    //                 if (acc.accModel.opacity.value == 1) {
    //                   // opacity 가 안잡혀 있으면 자동으로 잡아준다.
    //                   acc.accModel.opacity.set(0.5);
    //                 }
    //               }
    //             });
    //             acc.notify();
    //           },
    //           onChangeStart: (val) {},
    //           min: 0,
    //           max: 30,
    //         ),
    //         // Row(children: [
    //         //   Text(
    //         //     MyStrings.glass,
    //         //     style: MyTextStyles.subtitle2,
    //         //   ),
    //         //   SizedBox(width: 32),
    //         //   glassIcon(
    //         //     acc.accModel.glassFill.value > 0,
    //         //     acc.accModel.bgColor.value,
    //         //   ),
    //         // ]),
    //       ]),
    // );
  }

  Widget _sizePosRow(BuildContext context, ACC acc) {
    return Container(
        alignment: Alignment.topCenter,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _locationRow(acc),
              _sizeRow(acc),
              acc.hasContents()
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: basicButton(
                        onPressed: () {
                          //acc.setCurrentDynamicSize(true);
                          acc.accModel.isFixedRatio.set(true);
                          acc.resizeCurrent();
                          accManagerHolder!.unshowMenu(context);
                          setState(() {});
                        },
                        name: MyStrings.fitToContents,
                        iconData: Icons.fit_screen_outlined,
                        alignment: Alignment.centerLeft,
                      ),
                    )
                  : Container(),
              myCheckBox(MyStrings.isFixedRatio, acc.accModel.isFixedRatio.value, () {
                // Youtube 는 가로세로비를 바꿀 수 없다.
                if (acc.accModel.accType == ACCType.youtube) {
                  return;
                }

                acc.accModel.isFixedRatio.set(!acc.accModel.isFixedRatio.value);
                accManagerHolder!.unshowMenu(context);
                acc.notify();
                setState(() {});
              }, 10, 0, 10, 0),
              SizedBox(
                height: 10,
              )
            ]));
  }

  Widget _borderRow(BuildContext context, ACC acc) {
    return Container(
        alignment: Alignment.topCenter,
        child: Column(children: [
          SizedBox(height: 10),
          ColorPicker(
            subheading: smallDivider(),
            pickersEnabled: const <ColorPickerType, bool>{
              ColorPickerType.both: false,
              ColorPickerType.primary: true,
              ColorPickerType.accent: true,
              ColorPickerType.bw: true,
              ColorPickerType.custom: false,
              ColorPickerType.wheel: false
            },
            pickerTypeLabels: <ColorPickerType, String>{
              ColorPickerType.primary: MyStrings.basicColor,
              ColorPickerType.accent: MyStrings.accentColor,
              ColorPickerType.bw: MyStrings.bwColor,
              //ColorPickerType.wheel: MyStrings.customColor
            },
            color: acc.accModel.borderColor.value,
            onColorChanged: (bg) {},
            onColorChangeEnd: (bg) {
              acc.accModel.borderColor.set(bg);
              acc.notify();
              setState(() {
                if (acc.accModel.borderWidth.value == 0) {
                  acc.accModel.borderWidth.set(1);
                }
                //_borderColorVisible = false;
              });
            },
            width: 22,
            height: 22,
            padding: const EdgeInsets.fromLTRB(0, 8, 20, 0),
            showColorName: false,
            showRecentColors: false,
            //maxRecentColors: currentUser.maxBgColor,
            //recentColors: currentUser.bgColorList1,
            //onRecentColorsChanged: (list) {
            //  currentUser.bgColorList1 = list;
            //},
          ),
          borderWidthSelector(
              borderWidth: acc.accModel.borderWidth.value,
              onChanged: (value) {
                setState(() {
                  //autoChangeBgColor(acc);
                  acc.accModel.borderWidth.set(value);
                  acc.notify();
                });
              },
              onChangeStart: (_) {
                accManagerHolder!.unshowMenu(context);
              }),
          depthSelector(
              depth: acc.accModel.depth.value,
              onChanged: (value) {
                setState(() {
                  autoChangeBgColor(acc);
                  acc.accModel.depth.set(value);
                  acc.notify();
                });
              },
              onChangeStart: (_) {
                accManagerHolder!.unshowMenu(context);
              }),
          intensitySelector(
              intensity: acc.accModel.intensity.value,
              onChanged: (value) {
                setState(() {
                  autoChangeBgColor(acc);
                  acc.accModel.intensity.set(value);
                  acc.notify();
                });
              },
              onChangeStart: (_) {
                accManagerHolder!.unshowMenu(context);
              }),

          lightSourceDxWidgets(
              lightSourceDx: acc.accModel.lightSource.value.dx,
              onChanged: (value) {
                setState(() {
                  autoChangeBgColor(acc);
                  acc.accModel.lightSource.set(acc.accModel.lightSource.value.copyWith(dx: value));
                  acc.notify();
                });
              },
              onChangeStart: (_) {
                accManagerHolder!.unshowMenu(context);
              }),
          lightSourceDyWidgets(
              lightSourceDy: acc.accModel.lightSource.value.dy,
              onChanged: (value) {
                setState(() {
                  autoChangeBgColor(acc);
                  acc.accModel.lightSource.set(acc.accModel.lightSource.value.copyWith(dy: value));
                  acc.notify();
                });
              },
              onChangeStart: (_) {
                accManagerHolder!.unshowMenu(context);
              }),
          // ]),
        ]));
  }

  void autoChangeBgColor(ACC acc) {
    // 투명하거나,  유리질이거나, bg에 opacity 같은 것들이 잡혀있으면,
    // 보더 값이 먹지 않으므로, 자동으로 해제해 준다.
    if (acc.accModel.bgColor.value == Colors.transparent) {
      acc.accModel.bgColor.set(MyColors.bgColor);
    } else {
      // if (acc.bgColor.value.opacity > 0) {
      //   acc.bgColor.value.withOpacity(0);
      // }
    }
    acc.accModel.glassFill.set(0);
  }

  Widget _cornerRow(BuildContext context, ACC acc) {
    return Padding(
      padding: const EdgeInsets.only(right: 25),
      child: Container(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              radiusWidget(
                  radius: acc.accModel.radiusAll.value,
                  title: MyStrings.radiusAll,
                  onChanged: (val) {
                    setState(() {
                      acc.accModel.radiusAll.set(val);
                      acc.accModel.radiusTopLeft.set(val);
                      acc.accModel.radiusTopRight.set(val);
                      acc.accModel.radiusBottomLeft.set(val);
                      acc.accModel.radiusBottomRight.set(val);
                      acc.notify();
                    });
                  },
                  onChangeStart: (val) {}),
              radiusWidget(
                  radius: acc.accModel.radiusTopLeft.value,
                  title: MyStrings.radiusTopLeft,
                  onChanged: (val) {
                    setState(() {
                      acc.accModel.radiusAll.set(0);
                      acc.accModel.radiusTopLeft.set(val);
                      acc.notify();
                    });
                  },
                  onChangeStart: (val) {}),
              radiusWidget(
                  radius: acc.accModel.radiusTopRight.value,
                  title: MyStrings.radiusTopRight,
                  onChanged: (val) {
                    setState(() {
                      acc.accModel.radiusAll.set(0);
                      acc.accModel.radiusTopRight.set(val);
                      acc.notify();
                    });
                  },
                  onChangeStart: (val) {}),
              radiusWidget(
                  radius: acc.accModel.radiusBottomLeft.value,
                  title: MyStrings.radiusBottomLeft,
                  onChanged: (val) {
                    setState(() {
                      acc.accModel.radiusAll.set(0);
                      acc.accModel.radiusBottomLeft.set(val);
                      acc.notify();
                    });
                  },
                  onChangeStart: (val) {}),
              radiusWidget(
                  radius: acc.accModel.radiusBottomRight.value,
                  title: MyStrings.radiusBottomRight,
                  onChanged: (val) {
                    setState(() {
                      acc.accModel.radiusAll.set(0);
                      acc.accModel.radiusBottomRight.set(val);
                      acc.notify();
                    });
                  },
                  onChangeStart: (val) {}),
            ],
          )),
    );
  }

  Widget _animeRow(BuildContext context, ACC acc) {
    return Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    acc.accModel.animeType.set(AnimeType.none);
                    acc.invalidateContents();
                    setState(() {});
                  },
                  icon: Icon(Icons.not_interested),
                  iconSize: acc.accModel.animeType.value == AnimeType.none ? 36 : 24,
                  color: acc.accModel.animeType.value == AnimeType.none
                      ? MyColors.primaryColor
                      : MyColors.secondaryColor,
                ),
                IconButton(
                  onPressed: () {
                    _aniIconController.forward().then((value) async {
                      await Future.delayed(Duration(seconds: 1));
                      _aniIconController.reverse();
                    });
                    acc.accModel.animeType.set(AnimeType.carousel);
                    acc.invalidateContents();
                    setState(() {});
                  },
                  iconSize: acc.accModel.animeType.value == AnimeType.carousel ? 36 : 24,
                  icon: Icon(Icons.view_carousel_outlined),
                  //icon: AnimatedIcon(
                  //icon: AnimatedIcons.view_list,
                  //progress: _aniIconController,
                ),
                IconButton(
                  onPressed: () {
                    _aniIconController.forward().then((value) async {
                      await Future.delayed(Duration(seconds: 1));
                      _aniIconController.reverse();
                    });
                    acc.accModel.animeType.set(AnimeType.flip);
                    acc.invalidateContents();
                    setState(() {});
                  },
                  iconSize: acc.accModel.animeType.value == AnimeType.flip ? 36 : 24,
                  icon: Icon(Icons.flip_outlined),
                  //icon: AnimatedIcon(
                  //icon: AnimatedIcons.view_list,
                  //progress: _aniIconController,
                ),
                IconButton(
                  onPressed: () {
                    _aniIconController.forward().then((value) async {
                      await Future.delayed(Duration(seconds: 1));
                      _aniIconController.reverse();
                    });
                    acc.accModel.animeType.set(AnimeType.enlarge);
                    acc.invalidateContents();
                    setState(() {});
                  },
                  iconSize: acc.accModel.animeType.value == AnimeType.enlarge ? 36 : 24,
                  icon: Icon(Icons.expand),
                  //icon: AnimatedIcon(
                  //icon: AnimatedIcons.view_list,
                  //progress: _aniIconController,
                ),
                IconButton(
                  onPressed: () {
                    _aniIconController.forward().then((value) async {
                      await Future.delayed(Duration(seconds: 1));
                      _aniIconController.reverse();
                    });
                    acc.accModel.animeType.set(AnimeType.scale);
                    acc.invalidateContents();
                    setState(() {});
                  },
                  iconSize: acc.accModel.animeType.value == AnimeType.scale ? 36 : 24,
                  icon: Icon(Icons.expand),
                  //icon: AnimatedIcon(
                  //icon: AnimatedIcons.view_list,
                  //progress: _aniIconController,
                ),
              ],
            )
          ],
        ));
  }

  AnimatedIconData _getAnimeIcon(AnimeType type) {
    switch (type) {
      case AnimeType.carousel:
        return AnimatedIcons.list_view;
      case AnimeType.flip:
        return AnimatedIcons.add_event;
      case AnimeType.enlarge:
        return AnimatedIcons.ellipsis_search;
      case AnimeType.scale:
        return AnimatedIcons.event_add;
      default:
        return AnimatedIcons.close_menu;
    }
  }

  String _getAnimeName(AnimeType type) {
    switch (type) {
      case AnimeType.carousel:
        return MyStrings.animeCarousel;
      case AnimeType.flip:
        return MyStrings.animeFlip;
      case AnimeType.enlarge:
        return MyStrings.animeEnlarge;
      case AnimeType.scale:
        return MyStrings.animeScale;
      default:
        return "";
    }
  }

  // IconButton _glassIcon(double left, ACC acc, Color bg) {
  //   return IconButton(
  //     padding: EdgeInsets.fromLTRB(left, 0, 0, 0),
  //     iconSize: 32.0,
  //     icon: Icon(
  //       acc.glass.value == false
  //           ? Icons.circle //Icons.blur_off_rounded
  //           : Icons.blur_on_rounded,
  //       color: bg,
  //       //color: acc.glass.value == false ? Colors.grey : Colors.red,
  //     ),
  //     onPressed: () {
  //       acc.glass.set(!acc.glass.value);
  //       if (acc.glass.value == true) {
  //         if (acc.bgColor.value == Colors.transparent) {
  //           // 바탕색이 투명일때, 유리질을 선택하면, 바탕색을 힌색으로 잡아준다.
  //           acc.bgColor.set(Colors.white);
  //         }
  //       }
  //       acc.notify();;
  //       setState(() {});
  //     },
  //   );
  // }
}
