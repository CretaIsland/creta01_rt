// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable

import 'package:flutter/material.dart';
import 'package:creta01/model/pages.dart';
import 'package:creta01/studio/properties/property_selector.dart';
//import 'package:flutter/rendering.dart';
import 'package:creta01/common/buttons/toggle_switch.dart';
import 'package:creta01/studio/pages/page_manager.dart';
import 'package:creta01/constants/strings.dart';
import 'package:creta01/constants/styles.dart';
import 'package:creta01/constants/constants.dart';
//import 'package:creta01/model/users.dart';
import 'package:creta01/common/util/textfileds.dart';
import 'package:creta01/common/util/logger.dart';
import 'package:creta01/common/util/my_utils.dart';
import 'package:creta01/common/undo/undo.dart';
//import 'package:creta01/common/libColor/tinyColor.dart';
//import 'package:creta01/common/colorPicker/widgets/color_picker.dart';
//import 'package:creta01/common/colorPicker/color_row.dart';
import 'package:creta01/studio/properties/properties_frame.dart';

class PageProperty extends PropertySelector {
  PageProperty(
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
  State<PageProperty> createState() => PagePropertyState();
}

class PagePropertyState extends State<PageProperty> {
  bool isSizeChangable = true;
  TextEditingController descCon = TextEditingController();
  TextEditingController widthCon = TextEditingController();
  TextEditingController heightCon = TextEditingController();
  TextEditingController colorCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    isSizeChangable = (_pageSizeIndex() == 4) ? true : false;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Padding(
        //   padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Text(
        //         MyStrings.pagePropTitle,
        //         style: MyTextStyles.body2,
        //       ),
        //     ],
        //   ),
        // ),
        // Divider(
        //   height: 5,
        //   thickness: 1,
        //   color: MyColors.divide,
        //   indent: 0,
        //   endIndent: 0,
        // ),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 6, 10, 1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.zero,
                width: layoutPropertiesWidth * 0.75,
                child: myTextField(
                  widget.selectedPage!.getDescription(),
                  limit: 24,
                  textAlign: TextAlign.start,
                  labelText: MyStrings.pageDesc,
                  controller: descCon,
                  style: MyTextStyles.body2,
                  onEditingComplete: _onTitleEditingComplete,
                ),
              ),
              writeButton(
                onPressed: _onTitleEditingComplete,
              ),
            ],
          ),
        ),
        Divider(
          height: 5,
          thickness: 1,
          color: MyColors.divide,
          indent: 14,
          endIndent: 14,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 25, top: 16),
          child: Text(
            MyStrings.landPort,
            style: MyTextStyles.subtitle2,
          ),
        ),
        Padding(
          // 가로, 세로
          padding: const EdgeInsets.only(left: 25, top: 12),
          child: ToggleSwitch(
            minHeight: 30.0,
            minWidth: 90.0,
            initialLabelIndex:
                widget.selectedPage!.width.value < widget.selectedPage!.height.value ? 1 : 0,
            cornerRadius: 20.0,
            radiusStyle: true,
            activeFgColor: MyColors.puple100,
            inactiveBgColor: MyColors.puple100,
            inactiveFgColor: MyColors.puple600,
            totalSwitches: 2,
            labels: [MyStrings.landscape, MyStrings.portrait],
            icons: [Icons.stay_current_landscape, Icons.stay_current_portrait],
            activeBgColors: [
              [MyColors.puple600],
              [MyColors.puple600]
            ],
            onToggle: (index) {
              logHolder.log('toggle button pressed = $index');
              if (index == 0) // 가로
              {
                if (widget.selectedPage!.width.value < widget.selectedPage!.height.value) {
                  _swapRatio(true);
                }
              } else if (index == 1) {
                if (widget.selectedPage!.width.value > widget.selectedPage!.height.value) {
                  _swapRatio(false);
                }
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 25, top: 12),
          child: Text(
            MyStrings.pageSize,
            style: MyTextStyles.subtitle2,
          ),
        ),
        Padding(
          // 페이지 크기 (해상도)
          padding: const EdgeInsets.only(left: 25, top: 12),
          child: ToggleSwitch(
            minHeight: 30.0,
            minWidth: 56.0,
            initialLabelIndex: _pageSizeIndex(),
            //cornerRadius: 4.0,
            cornerRadius: 20.0,
            radiusStyle: true,
            activeFgColor: MyColors.puple100,
            inactiveBgColor: MyColors.puple100,
            inactiveFgColor: MyColors.puple600,
            totalSwitches: 5,
            labels: ["HD", "FHD", "QHD", "UHD", ''],
            icons: [null, null, null, null, Icons.handyman_outlined],
            activeBgColors: [
              [MyColors.puple600],
              [MyColors.puple600],
              [MyColors.puple600],
              [MyColors.puple600],
              [MyColors.puple600]
            ],
            onToggle: (index) {
              //setState(() {
              mychangeStack.startTrans();
              switch (index) {
                case 0:
                  widget.selectedPage!.width.set(widget.isLandscape ? 1280 : 720);
                  widget.selectedPage!.height.set(widget.isLandscape ? 720 : 1280);
                  isSizeChangable = false;
                  break;
                case 1:
                  widget.selectedPage!.width.set(widget.isLandscape ? 1920 : 1080);
                  widget.selectedPage!.height.set(widget.isLandscape ? 1080 : 1920);
                  isSizeChangable = false;
                  break;
                case 2:
                  widget.selectedPage!.width.set(widget.isLandscape ? 2560 : 1440);
                  widget.selectedPage!.height.set(widget.isLandscape ? 1440 : 2560);
                  isSizeChangable = false;
                  break;
                case 3:
                  widget.selectedPage!.width.set(widget.isLandscape ? 3840 : 2160);
                  widget.selectedPage!.height.set(widget.isLandscape ? 2160 : 3840);
                  isSizeChangable = false;
                  break;
                default:
                  widget.selectedPage!.width.set(widget.isLandscape ? 1921 : 1081);
                  widget.selectedPage!.height.set(widget.isLandscape ? 1081 : 1921);
                  isSizeChangable = true;
                  break;
              }
              mychangeStack.endTrans();
              //});
              pageManagerHolder!.notify();
            },
          ),
        ),
        Padding(
          // 높이 너비
          padding: const EdgeInsets.fromLTRB(25, 18, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                MyStrings.width,
                style: MyTextStyles.subtitle2,
              ),
              Container(
                // 너비
                padding: EdgeInsets.zero,
                width: 75,
                height: 30,
                child: myTextField(
                  widget.selectedPage!.width.value.toString(),
                  enabled: isSizeChangable,
                  hasBorder: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.end,
                  limit: 5,
                  controller: widthCon,
                  style: MyTextStyles.body2,
                  hasDeleteButton: false,
                  onEditingComplete: () {
                    logHolder.log("textval = ${widthCon.text}");
                    //setState(() {
                    widget.selectedPage!.width.set(int.parse(widthCon.text));
                    //});
                    pageManagerHolder!.notify();
                  },
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                MyStrings.height,
                style: MyTextStyles.subtitle2,
              ),
              Container(
                padding: EdgeInsets.zero,
                width: 75,
                height: 30,
                child: myTextField(
                  widget.selectedPage!.height.value.toString(),
                  enabled: isSizeChangable,
                  hasBorder: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.end,
                  limit: 5,
                  controller: heightCon,
                  style: MyTextStyles.body2,
                  hasDeleteButton: false,
                  onEditingComplete: () {
                    logHolder.log("textval = ${heightCon.text}");
                    //setState(() {
                    widget.selectedPage!.height.set(int.parse(heightCon.text));
                    //});
                    pageManagerHolder!.notify();
                  },
                ),
              ),
              writeButton(
                // width,height를  Write 하는 icon
                onPressed: () {
                  mychangeStack.startTrans();
                  //setState(() {
                  widget.selectedPage!.width.set(int.parse(widthCon.text));
                  widget.selectedPage!.height.set(int.parse(heightCon.text));
                  //});
                  mychangeStack.endTrans();
                  pageManagerHolder!.notify();
                },
              ),
            ],
          ),
        ),
        Divider(
          height: 5,
          thickness: 1,
          color: MyColors.divide,
          indent: 14,
          endIndent: 14,
        ),
        Padding(
          // 배경 색상
          padding: const EdgeInsets.only(left: 25, top: 12, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                MyStrings.bgColor,
                style: MyTextStyles.subtitle2,
              ),
              SizedBox(
                width: 80,
              ),
              SizedBox(
                width: 100,
                height: 30,
                child: _showColorString(widget.selectedPage!.bgColor.value),
              ),
              writeButton(
                // color를  Write 하는 icon
                onPressed: _onColorEditingComplete,
              ),
            ],
          ),
        ),
        // Padding(
        //   // 배경 색상 처리부
        //   padding: const EdgeInsets.fromLTRB(25, 18, 20, 0),
        //   child: colorRow(
        //     context: context,
        //     value: widget.selectedPage!.bgColor.value,
        //     list: [
        //       for (int i = 0; i < currentUser.maxBgColor; i++)
        //         currentUser.bgColorList1[i],
        //     ],
        //     onPressed: (bg) {
        //       widget.selectedPage!.bgColor.set(bg);
        //       pageManagerHolder!.notify();;
        //     },
        //   ),

        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     IconButton(
        //       // 스포이드  spoid
        //       constraints: BoxConstraints(),
        //       iconSize: isSnippetStatus() ? 34 : 28,
        //       padding: EdgeInsets.only(right: 5),
        //       icon: Icon(Icons.colorize_rounded),
        //       color: isSnippetStatus()
        //           ? MyColors.primaryColor
        //           : MyColors.mediumIcon,
        //       onPressed: () {
        //         // setState(() {
        //         //   if (!isSnippetStatus()) {
        //         //     cursorManagerHolder!.setCursor(MyPageCursor.precise);
        //         //   } else {
        //         //     cursorManagerHolder!.setCursor(MyPageCursor.basic);
        //         //   }
        //         // });
        //       },
        //     ),
        //     ...colorList([
        //       for (int i = 0; i < currentUser.maxBgColor; i++)
        //         currentUser.bgColorList1[i],
        //     ]),
        //     IconButton(
        //       // 빠레뜨
        //       constraints: BoxConstraints(),
        //       iconSize: 30,
        //       padding: EdgeInsets.zero,
        //       icon: Icon(Icons.palette_outlined),
        //       color: MyColors.mediumIcon,
        //       onPressed: () {
        //         showColorPicker(
        //           context: context,
        //           selectedColor: widget.selectedPage!.bgColor.value,
        //           onColorSelected: (value) {
        //             //setState(() {
        //             logHolder.log(value.toString());
        //             widget.selectedPage!.bgColor.set(value);
        //             _setUserPallete(value);
        //             //});
        //             pageManagerHolder!.notify();;
        //           },
        //         );
        //       },
        //     ),
        //   ],
        // )
        //),
      ],
    );
  }

  void _onTitleEditingComplete() {
    logHolder.log("textval = ${descCon.text}");
    widget.selectedPage!.description.set(descCon.text);
    pageManagerHolder!.notify();
  }

  void _onColorEditingComplete() {
    logHolder.log("textval = ${colorCon.text}");
    widget.selectedPage!.bgColor.set(hexToColor(colorCon.text));
    pageManagerHolder!.notify();
  }

  Widget _showColorString(Color value) {
    logHolder.log('#${value.toString().substring(8, 16)}');
    return myTextField(
      '#${value.toString().substring(8, 16)}',
      limit: 9,
      controller: colorCon,
      style: MyTextStyles.body2,
      enabled: true,
      hasBorder: true,
      hasDeleteButton: false,
      onEditingComplete: _onColorEditingComplete,
    );
  }

  void _swapRatio(bool landScape) {
    int temp = widget.selectedPage!.width.value;
    mychangeStack.startTrans();
    //setState(() {
    widget.isLandscape = landScape;
    widget.selectedPage!.width.set(widget.selectedPage!.height.value);
    widget.selectedPage!.height.set(temp);
    //});
    mychangeStack.endTrans();
    pageManagerHolder!.notify();
  }

  int _pageSizeIndex() {
    int w = widget.selectedPage!.width.value;
    int h = widget.selectedPage!.height.value;
    // HD
    if (w == 720 && h == 1280 || w == 1280 && h == 720) {
      return 0;
    }
    // FHD
    if (w == 1080 && h == 1920 || w == 1920 && h == 1080) {
      return 1;
    }
    // QHD
    if (w == 2560 && h == 1440 || w == 1440 && h == 2560) {
      return 2;
    }
    // UHD
    if (w == 3840 && h == 2160 || w == 2160 && h == 3840) {
      return 3;
    }
    return 4;
  }

  bool isSnippetStatus() {
    //return cursorManagerHolder != null && cursorManagerHolder!.isSnippet();
    return false;
  }

  List<CircleAvatar> colorList(List<Color> list) {
    return list.map((bg) {
      //TinyColor tinyColor = TinyColor(bg);
      return CircleAvatar(
          radius: widget.selectedPage!.bgColor.value == bg ? 18 : 14,
          backgroundColor: widget.selectedPage!.bgColor.value == bg
              ? MyColors.primaryColor
              : MyColors.secondaryColor,
          //backgroundColor: MyColors.secondaryColor,
          child: IconButton(
            padding: EdgeInsets.zero,
            //constraints: BoxConstraints.tight(Size(20, 20)),
            constraints: BoxConstraints(),
            iconSize: widget.selectedPage!.bgColor.value == bg ? 35 : 26,
            icon: Icon(Icons.circle),
            // icon: Icon(widget.selectedPage!.bgColor.value == bg
            //     ? Icons.check_circle
            //     : Icons.circle),
            color: bg,
            onPressed: () {
              //setState(() {
              widget.selectedPage!.bgColor.set(bg);
              logHolder.log('color=${widget.selectedPage!.bgColor.value.toString()}');
              logHolder
                  .log('color=${widget.selectedPage!.bgColor.value.toString().substring(8, 16)}');
              //});
              pageManagerHolder!.notify();
            },
          ));
    }).toList();
  }
}
