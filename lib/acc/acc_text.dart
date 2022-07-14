import 'package:creta01/acc/resizable.dart';
import 'package:creta01/common/util/logger.dart';
//mport 'package:creta01/model/model_enums.dart';
import 'package:creta01/widgets/base_widget.dart';
//import 'package:uuid/uuid.dart';

import 'package:creta01/model/pages.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_riverpod/flutter_riverpod.dart';

//import '../common/buttons/basic_button.dart';
//import '../common/util/logger.dart';
//import '../common/util/my_utils.dart';
//import '../common/util/textfileds.dart';
//import '../constants/strings.dart';
//import '../constants/styles.dart';
//import '../model/contents.dart';
//import '../player/video/youtuve_player_widget.dart';
import '../book_manager.dart';
import '../common/cursor/right_click.dart';
import '../model/acc_property.dart';
import '../model/contents.dart';
import '../model/model_enums.dart';
import '../player/abs_player.dart';
import 'acc_manager.dart';
import 'acc.dart';

class ACCText extends ACC {
  ACCText(
      {required PageModel? page,
      required BaseWidget accChild,
      required int idx,
      bool useDefaultSize = false})
      : super(page: page, accChild: accChild, idx: idx) {
    if (useDefaultSize) {
      accModel.containerSize.set(Size(page!.width.value * 0.6, page.width.value * 0.6 * (1 / 8)),
          save: false, noUndo: true);
      accModel.containerOffset
          .set(Offset(page.width.value * 0.9, page.height.value * 0.9), save: false, noUndo: true);
    }
  }

  bool isEditMode = false;
  TextEditingController controller = TextEditingController();

  ACCText.fromProperty(
      {required PageModel? page, required BaseWidget accChild, required ACCProperty accModel})
      : super.fromProperty(page: page, accChild: accChild, accModel: accModel);

  //bool _idInputVisible = true;

  @override
  Future<void> next({bool pause = false}) async {
    AbsPlayWidget? player = await accChild.playManager.getCurrent();
    logHolder.log('ACCYoutue.next()', level: 5);
    if (player != null) {
      player.next();
    } else {
      logHolder.log('Current YoutubePlayerWidget.is null', level: 5);
    }
  }

  @override
  Future<void> prev({bool pause = false}) async {
    AbsPlayWidget? player = await accChild.playManager.getCurrent();
    logHolder.log('ACCYoutue.prev()', level: 5);
    if (player != null) {
      player.prev();
    } else {
      logHolder.log('Current YoutubePlayerWidget.is null', level: 5);
    }
  }

  @override
  Widget showOverlay(BuildContext context) {
    //logHolder.log('showOverlay', level: 5);
    Size ratio = getRealRatio();
    Offset realOffset = getRealOffsetWithGivenRatio(ratio);
    Size realSize = getRealSize();
    bool isAccSelected = accManagerHolder!.isCurrentIndex(accModel.mid);
    double mouseMargin = resizeButtonSize / 2;
    Size marginSize = Size(realSize.width + resizeButtonSize, realSize.height + resizeButtonSize);
    bool isReadOnly = bookManagerHolder!.defaultBook!.readOnly.value;

    //logHolder.log('showOverlay: isReadOnly=$isReadOnly', level: 5);
    return Visibility(
      visible: getVisibility(),
      child: Positioned(
        // left: realOffset.dx,
        // top: realOffset.dy,
        // height: realSize.height,
        // width: realSize.width,
        left: realOffset.dx - mouseMargin,
        top: realOffset.dy - mouseMargin,
        height: realSize.height + resizeButtonSize,
        width: realSize.width + resizeButtonSize,
        child: CrossPlatformClick(
          // 오른쪽 마우스 버튼 사용
          onPointerDown: onRightMouseButtonUp,
          child: textWidget(
              context, isReadOnly, mouseMargin, realSize, marginSize, ratio, isAccSelected),
        ),
      ),
    );
  }

  Widget textWidget(BuildContext context, bool isReadOnly, double mouseMargin, Size realSize,
      Size marginSize, Size ratio, bool isAccSelected) {
    if (isReadOnly) {
      return buildAccChild(context, mouseMargin, realSize, marginSize);
    }
    if (isEditMode) {
      return buildTextField(context, realSize, mouseMargin);
    }
    return buildGesture(
      context,
      marginSize,
      realSize,
      ratio,
      isAccSelected,
      child: Stack(
        children: [
          buildAccChild(context, mouseMargin, realSize, marginSize),
          buildCustomPaint(isAccSelected, realSize, marginSize, hasDropZone: false),
        ],
      ),
    );
  }

  @override
  void onDoubleClick() {
    logHolder.log('onDoubleClick...', level: 5);
    isEditMode = true;
    notify();
  }

  Widget buildTextField(BuildContext context, Size realSize, double mouseMargin) {
    ContentsModel? model = accChild.playManager.getCurrentModelUnsafe();
    if (model == null) {
      return Container();
    }
    logHolder.log("buildTextField remoteUrl=${model.remoteUrl!}, url=${model.url}", level: 5);

    TextStyle style = DefaultTextStyle.of(context).style.copyWith(
        fontFamily: model.font.value,
        color: model.fontColor.value.withOpacity(model.opacity.value),
        fontSize: model.fontSize.value,
        decoration: getTextDecoration(model.line.value),
        fontWeight: model.isBold.value ? FontWeight.bold : FontWeight.normal,
        fontStyle: model.isItalic.value ? FontStyle.italic : FontStyle.normal);

    controller.text = model.remoteUrl!;
    return Stack(
      children: [
        Positioned(
          left: mouseMargin,
          top: mouseMargin,
          width: realSize.width,
          height: realSize.height,
          child: Material(
            child: SizedBox.expand(
              child: TextFormField(
                  //autofocus: true,
                  //initialValue: model.remoteUrl!,
                  expands: true,
                  controller: controller,
                  style: style,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  textAlignVertical: TextAlignVertical.center,
                  //limit: 120,
                  textAlign: model.align.value,
                  //enabled: true,
                  //hasBorder: true,
                  maxLines: null,
                  onTap: () {
                    logHolder.log("onTap", level: 5);
                  },
                  onChanged: (value) {
                    logHolder.log("onChanged($value)", level: 5);
                  },
                  onFieldSubmitted: (value) {
                    logHolder.log("onFieldSubmitted($value)", level: 5);
                  },
                  onEditingComplete: () {
                    logHolder.log("onEditingComplete", level: 5);
                    model.remoteUrl = controller.text;
                    isEditMode = false;
                    notify();
                  }),
            ),
          ),
        ),
      ],
    );
  }
}

// class InputYoutubeWidget extends StatefulWidget {
//   final ACC acc;
//   final double dx;
//   final double dy;
//   final double width;
//   final double height;
//   final void Function() onOK;
//   final void Function() onCancel;

//   const InputYoutubeWidget({
//     Key? key,
//     required this.acc,
//     required this.dx,
//     required this.dy,
//     required this.width,
//     required this.height,
//     required this.onOK,
//     required this.onCancel,
//   }) : super(key: key);

//   @override
//   State<InputYoutubeWidget> createState() => _InputYoutubeWidgetState();
// }

// class _InputYoutubeWidgetState extends State<InputYoutubeWidget> {
//   final TextEditingController _youtubeController = TextEditingController();
//   String errMsg = '';

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       left: widget.dx,
//       top: widget.dy,
//       height: widget.height,
//       width: widget.width,
//       child: glassMorphic(
//         radius: 10,
//         isGlass: true,
//         child: Material(
//           elevation: 2.0,
//           shadowColor: Colors.black,
//           type: MaterialType.card,
//           color: MyColors.primaryColor.withOpacity(.3),
//           child: Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 12),
//                   simpleTextField(
//                     controller: _youtubeController,
//                     hintText: MyStrings.inputYoutube,
//                     maxLine: 1,
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     errMsg,
//                     style: MyTextStyles.error,
//                   ),
//                   Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                     basicButton(
//                         name: MyStrings.apply,
//                         onPressed: () {
//                           String url = _youtubeController.text;
//                           if (url.isEmpty) {}

//                           logHolder.log("url=$url", level: 5);
//                           String youtubeId = '';
//                           if (url.length == 11) {
//                             youtubeId = url;
//                           } else if (url.length > 11) {
//                             String pattern = r'watch\?v=';
//                             int pos = url.lastIndexOf(RegExp(pattern));
//                             if (pos < 1) {
//                               setState(() {
//                                 errMsg = MyStrings.invalidAddress;
//                                 logHolder.log(errMsg, level: 6);
//                               });
//                               return;
//                             }
//                             youtubeId = url.substring(
//                                 pos + pattern.length - 1, pos + pattern.length - 1 + 11);
//                             logHolder.log('youtubeId=$youtubeId', level: 5);
//                           } else {
//                             setState(() {
//                               errMsg = MyStrings.invalidAddress;
//                               logHolder.log(errMsg, level: 6);
//                             });
//                             widget.onOK();
//                             return;
//                           }
//                           setState(() {
//                             ContentsModel model = ContentsModel(widget.acc.accModel.mid,
//                                 name: youtubeId, mime: 'youtube/html', bytes: 0, url: youtubeId);
//                             model.remoteUrl = youtubeId;
//                             widget.acc.accModel.accType = ACCType.youtube;
//                             widget.acc.accChild.playManager.pushFromDropZone(widget.acc, model);

//                             widget.acc.accChild.invalidate();
//                           });
//                         },
//                         iconData: Icons.done_outlined),
//                     const SizedBox(
//                       width: 5,
//                     ),
//                     basicButton(
//                         name: MyStrings.cancel,
//                         onPressed: () {
//                           setState(() {
//                             if (widget.acc.accChild.playManager.isEmpty()) {
//                               widget.acc.accModel.isRemoved.set(true);
//                               //accManagerHolder!.notify();;
//                             }
//                             widget.onCancel();
//                           });
//                         },
//                         iconData: Icons.close_outlined),
//                   ]),
//                 ]),
//           ),
//         ),
//       ),
//       //),
//     );
//   }

//   Widget displayYoutube(
//     ACC acc,
//     ContentsModel model,
//   ) {
//     YoutubePlayerWidget aWidget = YoutubePlayerWidget(
//       onInitialPlay: ((metadata) {
//         if (metadata.title.isNotEmpty) {
//           model.name = metadata.title;
//           double millisec = metadata.duration.inDays * 24 * 60 * 60 * 1000.0 +
//               metadata.duration.inHours * 60 * 60 * 1000.0 +
//               metadata.duration.inMinutes * 60 * 1000.0 +
//               metadata.duration.inSeconds * 1000.0 +
//               metadata.duration.inMilliseconds;
//           model.videoPlayTime.set(millisec);
//         }
//         if (metadata.videoId.isNotEmpty) {
//           model.remoteUrl = metadata.videoId;
//         }
//       }),
//       onAfterEvent: () {},
//       globalKey: GlobalObjectKey<YoutubePlayerWidgetState>(const Uuid().v4()),
//       model: model,
//       acc: acc,
//       autoStart: false, // (_currentIndex < 0) ? true : false,
//     );
//     aWidget.init();
//     return aWidget;
//   }
//}
