// ignore_for_file: prefer_final_fields
//import 'package:creta01/common/util/logger.dart';
//import 'package:creta01/acc/acc_manager.dart';
import 'dart:math';
import 'package:creta01/book_manager.dart';
import 'package:creta01/player/play_manager.dart';
import 'package:flutter/material.dart';
import 'package:creta01/model/contents.dart';
import 'package:creta01/model/model_enums.dart';
import 'package:creta01/acc/acc.dart';
import 'package:creta01/studio/pages/page_manager.dart';
import 'package:blobs/blobs.dart';

import '../acc/acc_manager.dart';
import '../common/util/logger.dart';
import 'video/video_player_controller.dart';

// page (1) --> (n) acc (1) --> (1) baseWidget --> (1) PlayManager (n) absPlayWidget                                                                 (n) absPlayWidget

// ignore: must_be_immutable
abstract class AbsPlayWidget extends StatefulWidget {
  ContentsModel? model;
  ACC acc;
  bool autoStart;
  //BasicOverayWidget? videoProgress;

  AbsPlayWidget({
    Key? key,
    required this.onAfterEvent,
    required this.acc,
    required this.autoStart,
    this.model,
    //this.videoProgress,
  }) : super(key: key);

  // AbsPlayWidget.copy(AbsPlayWidget old, this.acc)
  //     : super(key: old.key) // 화면에서만 쓰이기 때문에  key 를 복사한다.
  // {
  //   autoStart = old.autoStart;
  //   model = ContentsModel.copy(old.model!, acc.accModel.mid,
  //       name: old.model!.name,
  //       mime: old.model!.mime,
  //       bytes: old.model!.bytes,
  //       url: old.model!.url,
  //       file: old.model!.file);
  // }

  void Function()? onAfterEvent;

  Future<void> init() async {}
  Future<void> play({bool byManual = false}) async {}
  Future<void> pause({bool byManual = false}) async {}
  Future<void> mute() async {}
  Future<void> setSound(double val) async {}
  Future<void> close() async {}
  Future<void> next() async {}
  Future<void> prev() async {}

  void invalidate() async {}
  bool isInit() {
    return true;
  }

  PlayState getPlayState() {
    return model!.playState;
  }

  ContentsModel getModel() {
    return model!;
  }

  Future<void> afterBuild() async {
    if (model == null) return;
    //model!.setPlayState(PlayState.init);
    if (model!.isDynamicSize.value) {
      model!.isDynamicSize.set(false, noUndo: true, save: false);
      acc.resize(model!.aspectRatio.value);
    }
    if (selectedModelHolder != null && pageManagerHolder != null) {
      if (await selectedModelHolder!.isSelectedModel(model!)) {
        pageManagerHolder!.setAsContents();
      }
    }
    if (accManagerHolder != null) {
      accManagerHolder!.resizeMenu(model!.contentsType);
    }
  }

  Size getOuterSize(double srcRatio) {
    Size realSize = acc.getRealSize();
    // aspectorRatio 는 실제 비디오의  넓이/높이 이다.
    //double videoRatio = wcontroller!.value.aspectRatio;

    double outerWidth = realSize.width;
    double outerHeight = realSize.height;

    if (!acc.accModel.sourceRatio.value) {
      if (srcRatio >= 1.0) {
        outerWidth = srcRatio * outerWidth;
        outerHeight = outerWidth * (1.0 / srcRatio);
      } else {
        outerHeight = (1.0 / srcRatio) * outerHeight;
        outerWidth = srcRatio * outerHeight;
      }
    }
    return Size(outerWidth, outerHeight);
  }

  Widget getClipRect(Size outSize, Widget child) {
    return ClipRRect(
      //clipper: MyContentsClipper(),
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(acc.accModel.radiusTopRight.value),
        topLeft: Radius.circular(acc.accModel.radiusTopLeft.value),
        bottomRight: Radius.circular(acc.accModel.radiusBottomRight.value),
        bottomLeft: Radius.circular(acc.accModel.radiusBottomLeft.value),
      ),
      child: SizedBox.expand(
          child: FittedBox(
        alignment: Alignment.center,
        fit: BoxFit.cover,
        child: SizedBox(
          //width: realSize.width,
          //height: realSize.height,
          width: outSize.width,
          height: outSize.height,
          child: child,
        ),
      )),
    );
  }

  Widget getBlob(Size outSize, Widget child) {
    return Blob.animatedRandom(
        size: sqrt(acc.getRealSize().width * acc.getRealSize().height),
        duration: const Duration(microseconds: 100),
        edgesCount: 5,
        minGrowth: 4,
        styles: BlobStyles(color: Colors.green, fillType: BlobFillType.stroke, strokeWidth: 2),
        child: child);
  }

  String getURI(ContentsModel model) {
    if (model.url.isNotEmpty) {
      return model.url;
    }
    if (model.remoteUrl != null && model.remoteUrl!.isNotEmpty) {
      return model.remoteUrl!;
    }
    return '';
  }
}

class BasicOverayWidget extends StatelessWidget {
  final VideoPlayerController controller;
  final double width;
  final double height;

  const BasicOverayWidget(
      {Key? key, required this.controller, required this.width, required this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        height: height,
        child: VideoProgressIndicator(controller, allowScrubbing: true));
  }
}

// ignore: must_be_immutable
class EmptyPlayWidget extends AbsPlayWidget {
  EmptyPlayWidget(
      {required GlobalObjectKey<EmptyPlayWidgetState> key,
      required void Function() onAfterEvent,
      required ACC acc})
      : super(
            key: key,
            onAfterEvent: onAfterEvent,
            acc: acc,
            autoStart: bookManagerHolder!.isAutoPlay()) {
    globalKey = key;
  }

  GlobalObjectKey<EmptyPlayWidgetState>? globalKey;

  @override
  Future<void> play({bool byManual = false}) async {
    model!.setPlayState(PlayState.start);
  }

  @override
  Future<void> pause({bool byManual = false}) async {
    model!.setPlayState(PlayState.pause);
  }

  @override
  Future<void> mute() async {}

  @override
  Future<void> setSound(double val) async {}

  @override
  Future<void> close() async {
    model!.setPlayState(PlayState.none);
  }

  @override
  void invalidate() {
    if (globalKey != null && globalKey!.currentState != null) {
      globalKey!.currentState!.invalidate();
    }
  }

  @override
  bool isInit() {
    return true;
  }

  @override
  PlayState getPlayState() {
    if (model == null) {
      logHolder.log("getPlayState model is null", level: 5);
      return PlayState.none;
    }
    return model!.prevState;
  }

  @override
  ContentsModel getModel() {
    return model!;
  }

  @override
  EmptyPlayWidgetState createState() => EmptyPlayWidgetState();
}

class EmptyPlayWidgetState extends State<EmptyPlayWidget> {
  void invalidate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
