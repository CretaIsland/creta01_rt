// ignore: implementation_imports
// ignore_for_file: prefer_final_fields

import 'package:creta01/book_manager.dart';
import 'package:flutter/material.dart';
//import 'package:video_player/video_player.dart';

import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:creta01/player/video/video_player_controller.dart';
import 'package:creta01/acc/acc.dart';
import 'package:creta01/model/contents.dart';
import 'package:creta01/model/model_enums.dart';
import 'package:creta01/player/abs_player.dart';
import 'package:creta01/common/util/logger.dart';
import 'package:creta01/common/util/my_utils.dart';

// ignore: must_be_immutable
class VideoPlayerWidget extends AbsPlayWidget {
  VideoPlayerWidget({
    required this.globalKey,
    required void Function() onAfterEvent,
    required ContentsModel model,
    required ACC acc,
    bool autoStart = true,
  }) : super(
            key: globalKey,
            onAfterEvent: onAfterEvent,
            acc: acc,
            model: model,
            autoStart: autoStart) {
    logHolder.log("VideoPlayerWidget(isAutoPlay=$autoStart)", level: 5);
  }

  final GlobalObjectKey<VideoPlayerWidgetState> globalKey;

  VideoPlayerController? wcontroller;
  VideoEventType prevEvent = VideoEventType.unknown;

  @override
  Future<void> init() async {
    logHolder.log('initVideo(${model!.name},${model!.remoteUrl})', level: 1);

    String uri = getURI(model!);
    String errMsg = '${model!.name} uri is null';
    if (uri.isEmpty) {
      logHolder.log(errMsg, level: 6);
    }
    logHolder.log("uri=$uri", level: 1);

    wcontroller = VideoPlayerController.network(uri,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
      ..initialize().then((_) {
        logHolder.log('initialize complete(${model!.name})');
        //setState(() {});
        logHolder.log('initialize complete(${wcontroller!.value.duration.inMilliseconds})');

        model!.videoPlayTime
            .set(wcontroller!.value.duration.inMilliseconds.toDouble(), noUndo: true, save: false);
        wcontroller!.setLooping(false);

        wcontroller!.onAfterVideoEvent = (event) {
          logHolder.log(
              'video event ${event.eventType.toString()}, ${event.duration.toString()},(${model!.name})');
          if (event.eventType == VideoEventType.completed) {
            // bufferingEnd and completed 가 시간이 다 되서 종료한 것임.

            logHolder.log('video completed(${model!.name})');
            model!.setPlayState(PlayState.end);
            onAfterEvent!.call();
          }
          prevEvent = event.eventType;
        };
        //wcontroller!.play();
      });
  }

  @override
  bool isInit() {
    return wcontroller!.value.isInitialized;
  }

  @override
  void invalidate() {
    if (globalKey.currentState != null) {
      globalKey.currentState!.invalidate();
    }
  }

  @override
  Future<void> play({bool byManual = false}) async {
    // while (model!.state == PlayState.disposed) {
    //   await Future.delayed(const Duration(milliseconds: 100));
    // }
    logHolder.log('play  ${model!.name}');
    model!.setPlayState(PlayState.start);
    await wcontroller!.play();
  }

  @override
  Future<void> pause({bool byManual = false}) async {
    // while (model!.state == PlayState.disposed) {
    //   await Future.delayed(const Duration(milliseconds: 100));
    // }
    logHolder.log('pause', level: 1);
    model!.setPlayState(PlayState.pause);
    await wcontroller!.pause();
  }

  @override
  Future<void> close() async {
    model!.setPlayState(PlayState.none);
    logHolder.log("videoController close()", level: 5);
    await wcontroller!.dispose();
  }

  @override
  Future<void> mute() async {
    if (model!.mute.value) {
      await wcontroller!.setVolume(1.0);
    } else {
      await wcontroller!.setVolume(0.0);
    }
    model!.mute.set(!model!.mute.value);
  }

  @override
  Future<void> setSound(double val) async {
    await wcontroller!.setVolume(1.0);
    model!.volume.set(val);
  }

  @override
  // ignore: no_logic_in_create_state
  VideoPlayerWidgetState createState() {
    logHolder.log('video createState (${model!.name}');
    return VideoPlayerWidgetState();
  }
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  void invalidate() {
    setState(() {});
  }

  Future<void> afterBuild() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      logHolder.log('afterBuild video', level: 1);
      if (widget.wcontroller != null && widget.model != null) {
        widget.model!.aspectRatio
            .set(widget.wcontroller!.value.aspectRatio, noUndo: true, save: false);
      }
      widget.afterBuild();
    });
  }

  @override
  void initState() {
    super.initState();
    afterBuild();
  }

  @override
  void dispose() {
    logHolder.log("video widget dispose,${widget.model!.name}", level: 5);
    //widget.wcontroller!.dispose();
    super.dispose();
    widget.model!.setPlayState(PlayState.disposed);
  }

  Future<bool> waitInit() async {
    bool isReady = widget.wcontroller!.value.isInitialized;
    while (!isReady) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (widget.autoStart) {
      logHolder.log('initState play--${widget.model!.name}---------------', level: 5);
      await widget.play();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    logHolder.log('VideoPlayerWidgetState', level: 1);
    // aspectorRatio 는 실제 비디오의  넓이/높이 이다.
    Size outSize = widget.getOuterSize(widget.wcontroller!.value.aspectRatio);
    if (bookManagerHolder!.isSilent()) {
      widget.wcontroller!.setVolume(0.0);
      widget.model!.mute.set(true, save: false, noUndo: true);
    }
    return FutureBuilder(
        future: waitInit(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData == false) {
            //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
            return showWaitSign();
          }
          if (snapshot.hasError) {
            //error가 발생하게 될 경우 반환하게 되는 부분
            return errMsgWidget(snapshot);
          }

          // return widget.getClipRect(
          //   outSize,
          //   VideoPlayer(widget.wcontroller!, key: ValueKey(widget.model!.url)),
          // );
          return widget.getClipRect(
            outSize,
            //Stack(
            //children: [
            VideoPlayer(widget.wcontroller!, key: ValueKey(widget.model!.url)),
            //BasicOverayWidget(controller: widget.wcontroller!),
            //],
            //),
          );
          // return ClipRRect(
          //   //clipper: MyContentsClipper(),
          //   borderRadius: BorderRadius.only(
          //     topRight: Radius.circular(widget.acc.radiusTopRight.value),
          //     topLeft: Radius.circular(widget.acc.radiusTopLeft.value),
          //     bottomRight: Radius.circular(widget.acc.radiusBottomRight.value),
          //     bottomLeft: Radius.circular(widget.acc.radiusBottomLeft.value),
          //   ),
          //   child: //// widget.wcontroller!.value.isInitialized ?
          //       SizedBox.expand(
          //           child: FittedBox(
          //     alignment: Alignment.center,
          //     fit: BoxFit.cover,
          //     child: SizedBox(
          //       //width: realSize.width,
          //       //height: realSize.height,
          //       width: outSize.width,
          //       height: outSize.height,
          //       child: VideoPlayer(widget.wcontroller!, key: ValueKey(widget.model!.url)),
          //       //child: VideoPlayer(controller: widget.wcontroller!),
          //     ),
          //   )),

          //   //: const Text('not init'),
          // );
        });
  }
}

// my clipper example
class MyContentsClipper extends CustomClipper<RRect> {
  @override
  RRect getClip(Size size) {
    logHolder.log('MyContentsClipper=$size', level: 1);
    return RRect.fromLTRBR(50, 50, 200, 200, const Radius.circular(20));
  }

  @override
  bool shouldReclip(covariant CustomClipper<RRect> oldClipper) {
    return false;
  }
}
