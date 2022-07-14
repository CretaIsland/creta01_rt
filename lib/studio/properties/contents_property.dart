//import 'package:flutter/cupertino.dart';
//mport 'package:creta01/acc/acc_manager.dart';
// ignore_for_file: prefer_const_constructors

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:creta01/acc/acc_manager.dart';
import 'package:creta01/studio/properties/widget_property.dart';
import 'package:provider/provider.dart';
import 'package:flutter_neumorphic_null_safety/flutter_neumorphic.dart';
import 'package:scroll_loop_auto_scroll/scroll_loop_auto_scroll.dart';
import 'package:shimmer/shimmer.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import 'package:translator/translator.dart';

//import 'package:creta01/model/contents.dart';
//import 'package:creta01/common/util/logger.dart';
import 'package:creta01/common/util/textfileds.dart';
import 'package:creta01/model/contents.dart';
import 'package:creta01/model/model_enums.dart';
import 'package:creta01/player/play_manager.dart';
import 'package:creta01/model/pages.dart';
import 'package:creta01/studio/properties/property_selector.dart';

import 'package:creta01/studio/properties/properties_frame.dart';
import 'package:creta01/common/util/my_utils.dart';
import 'package:creta01/constants/strings.dart';
import 'package:creta01/constants/styles.dart';
import 'package:creta01/constants/constants.dart';
import 'package:uuid/uuid.dart';

import '../../common/colorPicker/color_row.dart';
import '../../common/util/logger.dart';
import '../../model/users.dart';
//import 'package:creta01/common/util/my_utils.dart';

// ignore: must_be_immutable
class ContentsProperty extends PropertySelector {
  ContentsProperty(
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
  State<ContentsProperty> createState() => ContentsPropertyState();
}

class ContentsPropertyState extends State<ContentsProperty> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController(initialScrollOffset: 0.0);

  TextEditingController secCon = TextEditingController();
  TextEditingController minCon = TextEditingController();
  TextEditingController hourCon = TextEditingController();
  TextEditingController textCon = TextEditingController();

  TextEditingController colorCon = TextEditingController();
  TextEditingController outlineCon = TextEditingController();
  TextEditingController shadowCon = TextEditingController();

  final List<ExapandableModel> _modelList = [];

  ExapandableModel fontColorModel = ExapandableModel(
    //title: '${MyStrings.bgColor}/${MyStrings.glass}/${MyStrings.opacity}',
    title: '${MyStrings.fontColor}/${MyStrings.opacity}',
    height: 450,
    width: 240,
  );

  ExapandableModel outlineModel = ExapandableModel(
    //title: '${MyStrings.bgColor}/${MyStrings.glass}/${MyStrings.opacity}',
    title: MyStrings.outline,
    height: 450,
    width: 240,
  );

  ExapandableModel shadowModel = ExapandableModel(
    //title: '${MyStrings.bgColor}/${MyStrings.glass}/${MyStrings.opacity}',
    title: MyStrings.shadow,
    height: 480,
    width: 240,
  );
  ExapandableModel aniModel = ExapandableModel(
    //title: '${MyStrings.bgColor}/${MyStrings.glass}/${MyStrings.opacity}',
    title: MyStrings.anime,
    height: 480,
    width: 240,
  );
  // ExapandableModel connectModel = ExapandableModel(
  //   //title: '${MyStrings.bgColor}/${MyStrings.glass}/${MyStrings.opacity}',
  //   title: MyStrings.connectContents,
  //   height: 480,
  //   width: 240,
  // );

  void unexpendAll(String expandModelName) {
    for (ExapandableModel model in _modelList) {
      if (expandModelName != model.title) {
        model.isSelected = false;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _modelList.add(fontColorModel);
    _modelList.add(outlineModel);
    _modelList.add(shadowModel);
    _modelList.add(aniModel);
    //_modelList.add(connectModel);
  }

  Future<ContentsModel> waitContents(SelectedModel selectedModel) async {
    ContentsModel? retval;

    while (retval == null) {
      retval = await selectedModel.getModel();
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return retval;
  }

  void _invalidateContents() {
    if (accManagerHolder != null && accManagerHolder!.getCurrentACC() != null) {
      accManagerHolder!.getCurrentACC()!.accChild.playManager.invalidate();
    }
  }

  void _printContents(String mid) {
    if (accManagerHolder != null && accManagerHolder!.getCurrentACC() != null) {
      accManagerHolder!.getCurrentACC()!.accChild.playManager.print(mid);
    }
  }

  @override
  Widget build(BuildContext context) {
    // return Scrollbar(
    //   key: ValueKey(Uuid().v4),
    //   thickness: 8.0,
    //   scrollbarOrientation: ScrollbarOrientation.left,
    //   thumbVisibility: true,
    //   controller: _scrollController,
    //   child:

    return Consumer<SelectedModel>(builder: (context, selectedModel, child) {
      logHolder.log('Consumer<SelectedModel>', level: 5);
      return FutureBuilder(
          future: waitContents(selectedModel),
          builder: (BuildContext context, AsyncSnapshot<ContentsModel> snapshot) {
            if (snapshot.hasData == false) {
              //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
              return showWaitSign();
            }
            if (snapshot.hasError) {
              //error가 발생하게 될 경우 반환하게 되는 부분
              return errMsgWidget(snapshot);
            }

            ContentsModel model = snapshot.data!;

            double millisec = model.playTime.value;
            if (model.isVideo()) {
              millisec = model.videoPlayTime.value;
            }
            double sec = (millisec / 1000);

            int textSize = 0;
            if (model.remoteUrl != null) {
              textSize = getStringSize(model.remoteUrl!);
            }

            double iconSize = 25;
            List<Widget> textPropList = [];
            if (model.contentsType == ContentsType.text) {
              // Text Row
              textPropList.add(textRow(model, textSize));
              // Text 번역
              textPropList.add(translateRow(model));
              // TTS Text to speach
              textPropList.add(Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: myCheckBox(MyStrings.TTS, model.isTTS.value, () {
                  setState(() {
                    model.isTTS.set(!model.isTTS.value);
                    _invalidateContents();
                  });
                }, 8, 2, 0, 2),
              ));
              // Font Row
              textPropList.add(fontRow(model));
              // Font Size
              textPropList.add(
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 0, 0),
                  child: doubleSlider(
                    title: MyStrings.fontSize,
                    value: model.fontSize.value,
                    onChanged: (val) {
                      setState(() {
                        model.fontSize.set(val);
                        _invalidateContents();
                      });
                    },
                    onChangeStart: (val) {},
                    min: 4,
                    max: maxFontSize,
                  ),
                ),
              );
              //}
              // 자동 사이즈
              textPropList.add(Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: myCheckBox(MyStrings.isAutoSize, model.isAutoSize.value, () {
                  setState(() {
                    model.isAutoSize.set(!model.isAutoSize.value);
                    _invalidateContents();
                  });
                }, 8, 2, 0, 2),
              ));

              textPropList.add(
                Padding(
                    padding: const EdgeInsets.fromLTRB(25, 25, 5, 10),
                    child: _showPlayTime(model, sec, millisec)),
              );
              textPropList.add(_baseTextProperty(model, iconSize));
              textPropList.add(divider());
              textPropList.add(fontColorExpander(model));
              textPropList.add(divider());
              textPropList.add(outlineExpander(model));
              textPropList.add(divider());
              textPropList.add(shadowExpander(model));
              textPropList.add(divider());
              textPropList.add(aniExpander(model));
              textPropList.add(divider());
              //textPropList.add(aniRow(context, model));
            }

            return ListView(controller: _scrollController, children: [
              _basicInfo(model, millisec, sec),
              SizedBox(height: 22),
              ...textPropList,
            ]);
          });

      //return ListView(controller: _scrollController, children: [
    });
    //);
    //);
  }

  Widget _baseTextProperty(ContentsModel model, double iconSize) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 10),
      child: Row(
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          Container(
              // 볼드
              margin: EdgeInsets.only(right: 2),
              color: model.isBold.value ? MyColors.primaryColor : Colors.transparent,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    model.isBold.set(!model.isBold.value);
                    _invalidateContents();
                  });
                },
                icon: Icon(Icons.format_bold_outlined),
                iconSize: iconSize,
              )),
          Container(
              // 이탤릭
              margin: EdgeInsets.only(right: 2),
              color: model.isItalic.value ? MyColors.primaryColor : Colors.transparent,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    model.isItalic.set(!model.isItalic.value);
                    _invalidateContents();
                  });
                },
                icon: Icon(Icons.format_italic_outlined),
                iconSize: iconSize,
              )),
          Container(
              // 언더라인
              margin: EdgeInsets.only(right: 2),
              color: model.line.value == TextLine.underline
                  ? MyColors.primaryColor
                  : Colors.transparent,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    model.line.set(model.line.value == TextLine.underline
                        ? TextLine.none
                        : TextLine.underline);
                    _invalidateContents();
                  });
                },
                icon: Icon(Icons.format_underlined_outlined),
                iconSize: iconSize,
              )),
          //Icon(Icons.format_underlined_outlined, size: 32.0),
          Container(
              // 좌로 정렬
              margin: EdgeInsets.only(right: 2),
              color:
                  model.align.value == TextAlign.left ? MyColors.primaryColor : Colors.transparent,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    model.align.set(
                        model.align.value == TextAlign.left ? TextAlign.center : TextAlign.left);
                    _invalidateContents();
                  });
                },
                icon: Icon(Icons.format_align_left_outlined),
                iconSize: iconSize,
              )),
          Container(
              // 가운데 정렬
              margin: EdgeInsets.only(right: 2),
              color: model.align.value == TextAlign.center
                  ? MyColors.primaryColor
                  : Colors.transparent,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    model.align.set(
                        model.align.value == TextAlign.center ? TextAlign.left : TextAlign.center);
                    _invalidateContents();
                  });
                },
                icon: Icon(Icons.format_align_center_outlined),
                iconSize: iconSize,
              )),
          Container(
              // 우로 정렬
              margin: EdgeInsets.only(right: 2),
              color:
                  model.align.value == TextAlign.right ? MyColors.primaryColor : Colors.transparent,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    model.align.set(
                        model.align.value == TextAlign.right ? TextAlign.center : TextAlign.right);
                    _invalidateContents();
                  });
                },
                icon: Icon(Icons.format_align_right_outlined),
                iconSize: iconSize,
              )),
          Container(
              // 퍼짐 정렬
              margin: EdgeInsets.only(right: 2),
              color: model.align.value == TextAlign.justify
                  ? MyColors.primaryColor
                  : Colors.transparent,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    model.align.set(model.align.value == TextAlign.justify
                        ? TextAlign.center
                        : TextAlign.justify);
                    _invalidateContents();
                  });
                },
                icon: Icon(Icons.format_align_justify_outlined),
                iconSize: iconSize,
              )),
        ],
      ),
    );
  }

  Widget _basicInfo(ContentsModel model, double millisec, double sec) {
    if (model.contentsType == ContentsType.text) return Container();

    return Padding(
        padding: const EdgeInsets.fromLTRB(25, 25, 5, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              model.name,
              style: MyTextStyles.h6.copyWith(color: MyColors.primaryText),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            smallDivider(height: 8, indent: 0, endIndent: 20),
            Text(
              '${model.contentsType}',
              style: MyTextStyles.subtitle1,
            ),
            Text(
              model.size,
              style: MyTextStyles.subtitle1,
            ),
            Text(
              'width/height.${(model.aspectRatio.value * 100).round() / 100}',
              style: MyTextStyles.subtitle2,
            ),
            model.contentsType == ContentsType.image
                // ||
                ? _showPlayTime(model, sec, millisec)
                : Text(
                    _toTimeString(sec),
                    style: MyTextStyles.subtitle1,
                  ),
            // Text(
            //   'sound.${model.volume}',
            // ),
          ],
        ));
  }

  Widget _showPlayTime(ContentsModel model, double sec, double millisec) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        smallDivider(height: 8, indent: 0, endIndent: 20),
        Row(
          children: [
            Text(
              MyStrings.playTime,
              style: MyTextStyles.subtitle1,
            ),
            SizedBox(
              width: 15,
            ),
            myCheckBox(MyStrings.forever, (millisec == playTimeForever), () {
              if (millisec != playTimeForever) {
                model.reservPlayTime();
                model.playTime.set(playTimeForever);
              } else {
                model.resetPlayTime();
              }
              setState(() {});
            }, 8, 2, 0, 2),
          ],
        ),
        Visibility(
          visible: millisec != playTimeForever,
          child: Row(
            children: [
              myNumberTextField2(
                  width: 50,
                  height: 84,
                  maxValue: 59,
                  defaultValue: (sec % 60),
                  controller: secCon,
                  onEditingComplete: () {
                    _updateTime(model);
                  }),
              SizedBox(width: 4),
              Text(
                MyStrings.seconds,
                style: MyTextStyles.subtitle2,
              ),
              SizedBox(width: 10),
              myNumberTextField2(
                  width: 50,
                  height: 84,
                  maxValue: 59,
                  defaultValue: (sec % (60 * 60) / 60).floorToDouble(),
                  controller: minCon,
                  onEditingComplete: () {
                    _updateTime(model);
                  }),
              SizedBox(width: 4),
              Text(
                MyStrings.minutes,
                style: MyTextStyles.subtitle2,
              ),
              SizedBox(width: 10),
              myNumberTextField2(
                  width: 50,
                  height: 84,
                  maxValue: 23,
                  defaultValue: (sec / (60 * 60)).floorToDouble(),
                  controller: hourCon,
                  onEditingComplete: () {
                    _updateTime(model);
                  }),
              SizedBox(width: 4),
              Text(
                MyStrings.hours,
                style: MyTextStyles.subtitle2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateTime(ContentsModel model) {
    setState(() {
      int sec = int.parse(secCon.text);
      int min = int.parse(minCon.text);
      int hour = int.parse(hourCon.text);
      model.playTime.set((hour * 60 * 60 + min * 60 + sec) * 1000);
    });
  }

  String _toTimeString(double sec) {
    return '${(sec / (60 * 60)).floor()} hour ${(sec % (60 * 60) / 60).floor()} min ${(sec % 60).floor()} sec';
  }

  Widget titleRow(double left, double top, double right, double bottom) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: Text(
        MyStrings.contentsPropTitle,
        style: MyTextStyles.body1,
      ),
    );
  }

  Widget textRow(ContentsModel model, int textSize) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 6, 10, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.zero,
            width: layoutPropertiesWidth * 0.75,
            child: myTextField(
              model.remoteUrl!,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              maxLines: textSize > 4 * 24 ? 4 : null, //한줄에 24자 정도 들어감
              limit: 4096,
              textAlign: TextAlign.start,
              labelText: MyStrings.text,
              controller: textCon,
              hasBorder: true,
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16),
              onEditingComplete: () {
                _onEditingComplete(model);
              },
            ),
          ),
          writeButton(
            onPressed: () {
              _onEditingComplete(model);
            },
          ),
        ],
      ),
    );
  }

  void _onEditingComplete(ContentsModel model) {
    _saveText(model, textCon.text);
  }

  void _saveText(ContentsModel model, String text) {
    logHolder.log("textval = $text", level: 5);
    model.remoteUrl = text;
    model.url = text;
    model.name = shortenText(model.remoteUrl!);
    //int textSize = getStringSize(model.remoteUrl!);
    //model.playTime.set(playTimeForever); //글자당 자동으로 1/4초를 할당한다.
    _printContents(model.mid);
    model.save(); //playTime 에서 set 되므로 save 하지 않는다.
    _invalidateContents();
  }

  Widget fontRow(ContentsModel model) {
    return Padding(
      // 폰트
      padding: const EdgeInsets.fromLTRB(22, 0, 0, 0),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(MyStrings.font),
        const SizedBox(
          width: 15,
        ),
        DropdownButton<String>(
          value: getFontName(model.font.value),
          icon: const Icon(Icons.arrow_downward),
          elevation: 16,
          //style: const TextStyle(color: Colors.deepPurple),
          underline: Container(height: 2, color: MyColors.primaryColor),
          onChanged: (String? newValue) {
            setState(() {
              String font = getFontFamily(newValue!);
              logHolder.log("fontFamily=$font", level: 5);
              model.font.set(font);
              _invalidateContents();
            });
          },
          items: <String>[
            MyStrings.fontPretendard,
            MyStrings.fontNoto_Sans_KR,
            MyStrings.fontNanum_Myeongjo,
            MyStrings.fontNanum_Gothic,
            MyStrings.fontNanum_Pen_Script,
            MyStrings.fontJua,
            MyStrings.fontMacondo,
          ].map<DropdownMenuItem<String>>((String e) {
            String font = getFontFamily(e);
            //logHolder.log("fontFamily====$font", level: 5);
            return DropdownMenuItem<String>(
                value: e, child: Text(e, style: TextStyle(fontFamily: font)));
          }).toList(),
        ),
      ]),
    );
  }

  Widget lineRow(ContentsModel model) {
    return Padding(
      // 폰트
      padding: const EdgeInsets.fromLTRB(22, 0, 0, 0),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(MyStrings.line),
        const SizedBox(
          width: 15,
        ),
        DropdownButton<String>(
          value: textDecorationToString(model.line.value),
          icon: const Icon(Icons.arrow_downward),
          elevation: 16,
          //style: const TextStyle(color: Colors.deepPurple),
          underline: Container(height: 2, color: MyColors.primaryColor),
          onChanged: (String? newValue) {
            setState(() {
              TextLine line = stringToTextDecoration(newValue!);
              model.line.set(line);
              _invalidateContents();
            });
          },
          items: <String>[
            MyStrings.none,
            MyStrings.underline,
            MyStrings.overline,
            MyStrings.lineThrough,
          ].map<DropdownMenuItem<String>>((String e) {
            TextLine line = stringToTextDecoration(e);
            return DropdownMenuItem<String>(
                value: e, child: Text(e, style: TextStyle(decoration: getTextDecoration(line))));
          }).toList(),
        ),
      ]),
    );
  }

  Widget fontColorExpander(ContentsModel model) {
    return fontColorModel.expandArea(
        child: fontColorRow(context, model),
        setStateFunction: () {
          setState(() {
            unexpendAll(fontColorModel.title);
            fontColorModel.toggleSelected();
          });
        },
        titleSize: 130,
        titleLineWidget: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            glassIcon(
                model.fontColor.value != Colors.transparent, //model.glassFill.value > 0,
                model.fontColor.value, onClicked: () {
              setState(() {
                if (model.fontColor.value != Colors.transparent) {
                  model.prevFontColor = model.fontColor.value;
                  model.fontColor.set(Colors.transparent);
                } else {
                  model.fontColor.set(model.prevFontColor);
                }
              });
              _invalidateContents();
            }),
            SizedBox(
              width: 20,
            ),
            Text(
              '${((1 - model.opacity.value) * 100).toInt()}%',
            ),
          ],
        ));
  }

  Widget fontColorRow(BuildContext context, ContentsModel model) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 22,
      ),
      child: myColorPicker(
        context,
        model.fontColor.value,
        opacity: model.opacity.value,
        controller: colorCon,
        //glassFill: model.glassFill.value,
        favorateColorPick: (value) {
          setState(() {
            model.fontColor.set(value);
          });
          _invalidateContents();
        },
        onColorChangedEnd: (value) {
          setState(() {
            model.fontColor.set(value);
          });
          _invalidateContents();
          currentUser.setUserColorList(value);
        },
        onEditComplete: (value) {
          setState(() {
            model.fontColor.set(value);
          });
          _invalidateContents();
        },
        onGlassChanged: (value) {},
        onOpacityChanged: (value) {
          setState(() {
            model.opacity.set(value);
          });
          _invalidateContents();
        },
        onOutLineChanged: (value) {},
      ),
    );
  }

  Widget outlineExpander(ContentsModel model) {
    return outlineModel.expandArea(
        child: outlineRow(context, model),
        setStateFunction: () {
          setState(() {
            unexpendAll(outlineModel.title);
            outlineModel.toggleSelected();
          });
        },
        titleSize: 150,
        titleLineWidget: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            glassIcon(
              model.outLineColor.value != Colors.transparent, //model.glassFill.value > 0,
              model.outLineColor.value,
              onClicked: () {
                setState(() {
                  //model.outLineColor.set(Colors.transparent);
                  if (model.outLineWidth.value != 0) {
                    model.prevOutLineWidth = model.outLineWidth.value;
                    model.outLineWidth.set(0);
                  } else {
                    model.outLineWidth.set(model.prevOutLineWidth);
                  }
                });
                _invalidateContents();
              },
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              '${model.outLineWidth.value.round()}',
            ),
            SizedBox(
              width: 28,
            ),
          ],
        ));
  }

  Widget outlineRow(BuildContext context, ContentsModel model) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 22,
      ),
      child: myColorPicker(
        context,
        model.outLineColor.value,
        outLineWidth: model.outLineWidth.value,
        controller: outlineCon,
        //glassFill: model.glassFill.value,
        favorateColorPick: (value) {
          setState(() {
            model.outLineColor.set(value);
            // 색상을 선택하면, 자동으로 두께를 잡아준다.
            if (model.outLineWidth.value == 0) {
              model.outLineWidth.set(5);
            }
          });
          _invalidateContents();
        },
        onColorChangedEnd: (value) {
          setState(() {
            model.outLineColor.set(value);
            // 색상을 선택하면, 자동으로 두께를 잡아준다.
            if (model.outLineWidth.value == 0) {
              model.outLineWidth.set(5);
            }
          });
          _invalidateContents();
          currentUser.setUserColorList(value);
        },
        onEditComplete: (value) {
          setState(() {
            model.outLineColor.set(value);
            // 색상을 선택하면, 자동으로 두께를 잡아준다.
            if (model.outLineWidth.value == 0) {
              model.outLineWidth.set(5);
            }
          });
          _invalidateContents();
        },
        onGlassChanged: (value) {},
        onOpacityChanged: (value) {},
        onOutLineChanged: (value) {
          setState(() {
            model.outLineWidth.set(value);
          });
          _invalidateContents();
        },
      ),
    );
  }

  Widget shadowExpander(ContentsModel model) {
    return shadowModel.expandArea(
        child: shadowRow(context, model),
        setStateFunction: () {
          setState(() {
            unexpendAll(shadowModel.title);
            shadowModel.toggleSelected();
          });
        },
        titleSize: 150,
        titleLineWidget: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            glassIcon(
              model.shadowColor.value != Colors.transparent,
              model.shadowColor.value,
              onClicked: () {
                setState(() {
                  //model.outLineColor.set(Colors.transparent);
                  if (model.shadowBlur.value != 0) {
                    model.prevShadowBlur = model.shadowBlur.value;
                    model.shadowBlur.set(0);
                  } else {
                    model.shadowBlur.set(model.prevShadowBlur);
                  }
                });
                _invalidateContents();
              },
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              '${model.shadowBlur.value.round()}',
            ),
            SizedBox(
              width: 28,
            ),
          ],
        ));
  }

  Widget shadowRow(BuildContext context, ContentsModel model) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 22,
      ),
      child: myColorPicker(
        context,
        model.shadowColor.value,
        outLineWidth: model.shadowBlur.value,
        opacity: model.shadowIntensity.value,
        controller: shadowCon,
        maxOutLine: 20,
        //glassFill: model.glassFill.value,
        favorateColorPick: (value) {
          setState(() {
            model.shadowColor.set(value);
            // 색상을 선택하면 자동으로 두께를 잡아준다.
            if (model.shadowBlur.value == 0) {
              model.shadowBlur.set(10);
            }
          });
          _invalidateContents();
        },
        onColorChangedEnd: (value) {
          setState(() {
            model.shadowColor.set(value);
            // 색상을 선택하면 자동으로 두께를 잡아준다.
            if (model.shadowBlur.value == 0) {
              model.shadowBlur.set(10);
            }
          });
          _invalidateContents();
          currentUser.setUserColorList(value);
        },
        onEditComplete: (value) {
          setState(() {
            model.shadowColor.set(value);
            // 색상을 선택하면 자동으로 두께를 잡아준다.
            if (model.shadowBlur.value == 0) {
              model.shadowBlur.set(10);
            }
          });
          _invalidateContents();
        },
        onGlassChanged: (value) {},
        onOpacityChanged: (value) {
          setState(() {
            model.shadowIntensity.set(value);
          });
          _invalidateContents();
        },
        onOutLineChanged: (value) {
          setState(() {
            model.shadowBlur.set(value);
          });
          _invalidateContents();
        },
      ),
    );
  }

  Widget aniExpander(ContentsModel model) {
    return aniModel.expandArea(
        align: AlignmentDirectional.centerStart,
        child: aniRow(context, model),
        setStateFunction: () {
          setState(() {
            unexpendAll(aniModel.title);
            aniModel.toggleSelected();
          });
        },
        titleSize: 120,
        titleLineWidget: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton(
              child: Text(textAniTypeToString(model.aniType.value)),
              onPressed: () {
                setState(() {
                  //model.outLineColor.set(Colors.transparent);
                  if (model.aniType.value != TextAniType.none) {
                    model.prevAniType = model.aniType.value;
                    model.aniType.set(TextAniType.none);
                  } else {
                    model.aniType.set(model.prevAniType);
                  }
                });
                _invalidateContents();
              },
            ),
          ],
        ));
  }

  Widget aniRow(BuildContext context, ContentsModel model) {
    return Padding(
        padding: const EdgeInsets.only(
          left: 0,
          right: 22,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 옆으로 흐르는 문자열
            Container(
                color: MyColors.secondaryColor, width: 250, height: 24, child: tickerSide(model)),
            smallDivider(height: 10),
            Container(
                color: MyColors.secondaryColor, width: 250, height: 24, child: tickerUpDown(model)),
            smallDivider(height: 10),
            Container(
                color: MyColors.secondaryColor, width: 250, height: 24, child: rotateText(model)),
            smallDivider(height: 10),
            Container(
                color: MyColors.secondaryColor, width: 250, height: 24, child: bounceText(model)),
            smallDivider(height: 10),
            Container(
                color: MyColors.secondaryColor, width: 250, height: 24, child: fidgetText(model)),
            smallDivider(height: 10),
            Container(
                color: MyColors.secondaryColor, width: 250, height: 24, child: fadeText(model)),
            smallDivider(height: 10),
            Container(
                color: MyColors.secondaryColor, width: 250, height: 24, child: shimmerText(model)),
            smallDivider(height: 10),
            Container(
                color: MyColors.secondaryColor,
                width: 250,
                height: 24,
                child: typewriterText(model)),
            smallDivider(height: 10),
            Container(
                color: MyColors.secondaryColor, width: 250, height: 24, child: wavyText(model)),
            smallDivider(height: 10),
            // 속도 슬라이더 바
            doubleSlider(
              title: MyStrings.speed,
              value: model.anyDuration.value,
              onChanged: (val) {
                setState(() {
                  model.anyDuration.set(val);
                  _invalidateContents();
                });
              },
              onChangeStart: (val) {},
              min: 0,
              max: 100,
            ),
          ],
        ));
  }

  // Widget connectExpander(ContentsModel model) {
  //   return connectModel.expandArea(
  //       align: AlignmentDirectional.centerStart,
  //       child: aniRow(context, model),
  //       setStateFunction: () {
  //         setState(() {
  //           unexpendAll(aniModel.title);
  //           aniModel.toggleSelected();
  //         });
  //       },
  //       titleSize: 120,
  //       titleLineWidget: Row(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: [
  //           TextButton(
  //             child: Text(textAniTypeToString(model.aniType.value)),
  //             onPressed: () {
  //               setState(() {
  //                 //model.outLineColor.set(Colors.transparent);
  //                 if (model.aniType.value != TextAniType.none) {
  //                   model.prevAniType = model.aniType.value;
  //                   model.aniType.set(TextAniType.none);
  //                 } else {
  //                   model.aniType.set(model.prevAniType);
  //                 }
  //               });
  //               _invalidateContents();
  //             },
  //           ),
  //         ],
  //       ));
  // }

  // Widget aniRow(BuildContext context, ContentsModel model) {
  //   return Padding(
  //     // animation choice
  //     padding: const EdgeInsets.fromLTRB(22, 0, 0, 0),
  //     child: Column(
  //       children: [
  //         Row(mainAxisAlignment: MainAxisAlignment.start, children: [
  //           Text(MyStrings.anime),
  //           const SizedBox(
  //             width: 15,
  //           ),
  //           DropdownButton<TextAniType>(
  //             value: model.aniType.value,
  //             icon: const Icon(Icons.arrow_downward),
  //             elevation: 16,
  //             //style: const TextStyle(color: Colors.deepPurple),
  //             underline: Container(height: 2, color: MyColors.primaryColor),
  //             onChanged: (TextAniType? newValue) {
  //               setState(() {
  //                 //model.outLineColor.set(Colors.transparent);
  //                 if (model.aniType.value != TextAniType.none) {
  //                   model.prevAniType = model.aniType.value;
  //                   model.aniType.set(TextAniType.none);
  //                 } else {
  //                   model.aniType.set(model.prevAniType);
  //                 }
  //               });
  //               _invalidateContents();
  //             },
  //             items: <TextAniType>[
  //               TextAniType.none,
  //               TextAniType.tickerSide,
  //               TextAniType.tickerUpDown,
  //             ].map<DropdownMenuItem<TextAniType>>((TextAniType e) {
  //               return DropdownMenuItem<TextAniType>(value: e, child: _aniMap[e]!);
  //             }).toList(),
  //           ),
  //         ]),
  //         doubleSlider(
  //           title: MyStrings.aniSpeed,
  //           value: model.anyDuration.value,
  //           onChanged: (val) {
  //             setState(() {
  //               model.anyDuration.set(val);
  //               _invalidateContents();
  //             });
  //           },
  //           onChangeStart: (val) {},
  //           min: 0,
  //           max: 100,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget tickerSide(ContentsModel model) {
    String text = "${MyStrings.tickerSide} ";
    int textSize = getStringSize(text);
    // duration 이 50 이면 실제로는 5-7초 정도에  문자열을 다 흘려보내다.
    // 따라서 문자열의 길이에  anyDuration / 10  정도의 값을 곱해본다.
    int duration = (textSize * 0.75).ceil() * ((101 - model.anyDuration.value) / 10).ceil();
    return TextButton(
        onPressed: () {
          setState(() {
            model.aniType.set(TextAniType.tickerSide);
            if (model.anyDuration.value == 0) {
              model.anyDuration.set(50);
            }
          });
          _invalidateContents();
        },
        child: ScrollLoopAutoScroll(
            key: ValueKey(Uuid().v4()),
            // ignore: sort_child_properties_last
            child: Text(
              text,
              textAlign: TextAlign.left,
            ), //required
            scrollDirection: Axis.horizontal, //required
            delay: Duration(seconds: 1),
            duration: Duration(seconds: duration),
            gap: 25,
            reverseScroll: false,
            duplicateChild: 25,
            enableScrollInput: true,
            delayAfterScrollInput: Duration(seconds: 1)));
  }

  Widget tickerUpDown(ContentsModel model) {
    String text = "${MyStrings.tickerSide} ";
    int textSize = getStringSize(text);
    // duration 이 50 이면 실제로는 5-7초 정도에  문자열을 다 흘려보내다.
    // 따라서 문자열의 길이에  anyDuration / 10  정도의 값을 곱해본다.
    int duration = (textSize * 0.75).ceil() * ((101 - model.anyDuration.value) / 10).ceil();
    return TextButton(
        onPressed: () {
          setState(() {
            model.aniType.set(TextAniType.tickerUpDown);
            if (model.anyDuration.value == 0) {
              model.anyDuration.set(50);
            }
          });
          _invalidateContents();
        },
        child: ScrollLoopAutoScroll(
            key: ValueKey(Uuid().v4()),
            // ignore: sort_child_properties_last
            child: Text(
              MyStrings.tickerUpDown,
              textAlign: TextAlign.left,
            ), //required
            scrollDirection: Axis.vertical, //required
            delay: Duration(seconds: 1),
            duration: Duration(seconds: duration),
            gap: 25,
            reverseScroll: false,
            duplicateChild: 25,
            enableScrollInput: true,
            delayAfterScrollInput: Duration(seconds: 1)));
  }

  Widget rotateText(ContentsModel model) {
    return TextButton(
      onPressed: () {
        setState(() {
          model.aniType.set(TextAniType.rotate);
          if (model.anyDuration.value == 0) {
            model.anyDuration.set(50);
          }
        });
        _invalidateContents();
      },
      child: TextAnimator(
        MyStrings.rotateText,
        atRestEffect: WidgetRestingEffects.rotate(),
        incomingEffect: WidgetTransitionEffects(
            blur: const Offset(2, 2), duration: const Duration(milliseconds: 600)),
        outgoingEffect: WidgetTransitionEffects(
            blur: const Offset(2, 2), duration: const Duration(milliseconds: 600)),
      ),
    );
  }

  Widget bounceText(ContentsModel model) {
    return TextButton(
      onPressed: () {
        setState(() {
          model.aniType.set(TextAniType.bounce);
          if (model.anyDuration.value == 0) {
            model.anyDuration.set(50);
          }
        });
        _invalidateContents();
      },
      child: TextAnimator(
        MyStrings.bounce,
        incomingEffect: WidgetTransitionEffects.incomingScaleDown(),
        atRestEffect: WidgetRestingEffects.bounce(),
        outgoingEffect: WidgetTransitionEffects.outgoingScaleUp(),
      ),
    );
  }

  Widget fidgetText(ContentsModel model) {
    return TextButton(
      onPressed: () {
        setState(() {
          model.aniType.set(TextAniType.fidget);
          if (model.anyDuration.value == 0) {
            model.anyDuration.set(50);
          }
        });
        _invalidateContents();
      },
      child: TextAnimator(
        MyStrings.fidget,
        incomingEffect: WidgetTransitionEffects.incomingSlideInFromLeft(),
        atRestEffect: WidgetRestingEffects.fidget(),
        outgoingEffect: WidgetTransitionEffects.outgoingSlideOutToBottom(),
      ),
    );
  }

  Widget fadeText(ContentsModel model) {
    return TextButton(
      onPressed: () {
        setState(() {
          model.aniType.set(TextAniType.fade);
          if (model.anyDuration.value == 0) {
            model.anyDuration.set(50);
          }
        });
        _invalidateContents();
      },
      child: TextAnimator(
        MyStrings.fade,
        incomingEffect: WidgetTransitionEffects.incomingSlideInFromLeft(),
        atRestEffect: WidgetRestingEffects.pulse(), // fade
        outgoingEffect: WidgetTransitionEffects.outgoingSlideOutToBottom(),
      ),
    );
  }

  Widget shimmerText(ContentsModel model) {
    return TextButton(
      onPressed: () {
        setState(() {
          model.aniType.set(TextAniType.shimmer);
          if (model.anyDuration.value == 0) {
            model.anyDuration.set(50);
          }
        });
        _invalidateContents();
      },
      child: Shimmer.fromColors(
          baseColor: model.fontColor.value,
          highlightColor: model.outLineColor.value,
          child: Text(MyStrings.shimmer)),
    );
  }

  Widget typewriterText(ContentsModel model) {
    return TextButton(
      onPressed: () {
        setState(() {
          model.aniType.set(TextAniType.typewriter);
          if (model.anyDuration.value == 0) {
            model.anyDuration.set(50);
          }
        });
        _invalidateContents();
      },
      child: AnimatedTextKit(
        onTap: () {
          setState(() {
            model.aniType.set(TextAniType.typewriter);
            if (model.anyDuration.value == 0) {
              model.anyDuration.set(50);
            }
          });
          _invalidateContents();
        },
        repeatForever: true,
        animatedTexts: [
          TypewriterAnimatedText(MyStrings.typewriter,
              textAlign: TextAlign.center,
              speed: Duration(milliseconds: 505 - model.anyDuration.value.round() * 5)),
        ],
      ),
    );
  }

  Widget wavyText(ContentsModel model) {
    return TextButton(
      onPressed: () {
        setState(() {
          model.aniType.set(TextAniType.wavy);
          if (model.anyDuration.value == 0) {
            model.anyDuration.set(50);
          }
        });
        _invalidateContents();
      },
      child: AnimatedTextKit(
        onTap: () {
          setState(() {
            model.aniType.set(TextAniType.wavy);
            if (model.anyDuration.value == 0) {
              model.anyDuration.set(50);
            }
          });
          _invalidateContents();
        },
        repeatForever: true,
        animatedTexts: [
          WavyAnimatedText(MyStrings.wavy,
              textAlign: TextAlign.center,
              speed: Duration(milliseconds: 505 - model.anyDuration.value.round() * 5)),
        ],
      ),
    );
  }

  Widget translateRow(ContentsModel model) {
    return Padding(
      // 번역
      padding: const EdgeInsets.fromLTRB(22, 0, 0, 0),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(MyStrings.translate),
        const SizedBox(
          width: 15,
        ),
        DropdownButton<String>(
          value: code2LangMap[model.lang.value] ?? languages[0],
          icon: const Icon(Icons.arrow_downward),
          elevation: 16,
          //style: const TextStyle(color: Colors.deepPurple),
          underline: Container(height: 2, color: MyColors.primaryColor),
          onChanged: (String? newValue) async {
            if (newValue == null || newValue == MyStrings.noTranslate) {
              return;
            }
            model.lang.set(lang2CodeMap[newValue]!, save: false, noUndo: true);
            Translation result = await model.remoteUrl!.translate(to: model.lang.value);
            setState(() {
              _saveText(model, result.text);
            });
          },
          items: languages.map<DropdownMenuItem<String>>((String e) {
            return DropdownMenuItem<String>(value: e, child: Text(e));
          }).toList(),
        ),
      ]),
    );
  }
}
