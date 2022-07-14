// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:developer';

//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
//import 'package:video_player/video_player.dart';

import 'package:creta01/player/abs_player.dart';
import 'package:creta01/acc/acc.dart';
import 'package:creta01/model/contents.dart';
import 'package:creta01/common/util/logger.dart';

import '../../book_manager.dart';
import '../../common/util/my_utils.dart';
import '../../model/model_enums.dart';
// import 'widgets/meta_data_section.dart';
// import 'widgets/play_pause_button_bar.dart';
// import 'widgets/player_state_section.dart';
// import 'widgets/source_input_section.dart';
// import 'widgets/volume_slider.dart';

// ignore: must_be_immutable
class YoutubePlayerWidget extends AbsPlayWidget {
  final GlobalObjectKey<YoutubePlayerWidgetState> globalKey;
  final List<String> playList;
  // 'QMhVtPmPAW8',
  // 'uBY1AoiF5Vo',
  // 'puUxEKMub2g',
  // 'UUUWIGx3hDE',
  // 'Fm5iP0S1z9w',
  // 'CM4CkVFmTds',
  // 'uR8Mrt1IpXg',
  // 'ZeerrnuLi5E',
  //  'Jh4QFaPmdss'
  //];

  String videoId = 'Jh4QFaPmdss';

  YoutubePlayerWidget({
    Key? key,
    required this.globalKey,
    required this.playList,
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
    logHolder.log("YoutubePlayerWidget(url=${model.url})", level: 5);
    if (model.remoteUrl != null) {
      logHolder.log("YoutubePlayerWidget(remoteUrl=${model.remoteUrl!})", level: 5);
    }
    videoId = model.remoteUrl ?? model.url;
    //playList.add(videoId);
  }

  late YoutubePlayerController wcontroller;
  bool isReady = false;

  @override
  Future<void> init() async {
    bool isReadOnly = bookManagerHolder!.defaultBook!.readOnly.value;

    logHolder.log('initYoutube(${model!.name},$videoId), ${playList.toString()}', level: 5);
    wcontroller = YoutubePlayerController(
      initialVideoId: videoId,
      params: YoutubePlayerParams(
        loop: true,
        mute: autoStart && (isReadOnly == false),
        playlist: playList,
        autoPlay: autoStart && (isReadOnly == false),
        showControls: true,
        showFullscreenButton: false,
        desktopMode: true,
        privacyEnhanced: false,
        useHybridComposition: false,
        strictRelatedVideos: false,
      ),
    );
    wcontroller.onEnterFullscreen = () {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      log('Entered Fullscreen');
    };
    wcontroller.onExitFullscreen = () {
      log('Exited Fullscreen');
    };
    //getThumbnail();
    isReady = true;
    if (autoStart) {
      model!.setPlayState(PlayState.start);
      model!.mute.set(true, save: false);
    } else {
      model!.setPlayState(PlayState.init);
      model!.mute.set(false, save: false);
    }
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
    logHolder.log('play  ${model!.name}', level: 5);
    model!.setPlayState(PlayState.start);
    wcontroller.play();
  }

  @override
  Future<void> pause({bool byManual = false}) async {
    // while (model!.state == PlayState.disposed) {
    //   await Future.delayed(const Duration(milliseconds: 100));
    // }
    logHolder.log('pause', level: 1);
    model!.setPlayState(PlayState.pause);
    wcontroller.pause();
  }

  @override
  Future<void> close() async {
    model!.setPlayState(PlayState.none);
    logHolder.log("videoController close()", level: 5);
    await wcontroller.close();
  }

  @override
  Future<void> mute() async {
    if (model!.mute.value) {
      wcontroller.mute();
    } else {
      wcontroller.unMute();
    }
    model!.mute.set(!model!.mute.value);
  }

  @override
  Future<void> setSound(double val) async {
    wcontroller.setVolume(val.round());
    model!.volume.set(val);
  }

  void getThumbnail() {
    if (model!.thumbnail == null || model!.thumbnail!.isEmpty) {
      model!.thumbnail = YoutubePlayerController.getThumbnail(
        //videoId: widget.wcontroller.params.playlist.first,
        videoId: videoId,
        quality: ThumbnailQuality.medium,
      );

      logHolder.log("youtube thumbnail= ${model!.thumbnail!}", level: 5);
    }
  }

  @override
  Future<void> next() async {
    logHolder.log('YoutubePlayerWidget.next()', level: 5);
    wcontroller.nextVideo();
  }

  @override
  Future<void> prev() async {
    logHolder.log('YoutubePlayerWidget.prev()', level: 5);
    wcontroller.previousVideo();
  }

  @override
  YoutubePlayerWidgetState createState() => YoutubePlayerWidgetState();
}

class YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  YoutubePlayerIFrame? player;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  void invalidate() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      print('afterBuild Yout!ubePlayerController');
      player!.controller!.listen((event) {
        if (event.playerState == PlayerState.ended) {
          print('listen, ${event.playerState}');
          widget.model!.setPlayState(PlayState.end);
          widget.onAfterEvent!.call();
        }
      });
      // setState(() {
      // });
      // if (player!.controller != null) {
      //   player!.controller!.nextVideo();

      // } else {
      //   print('controller is null');
      // }
    });
  }

  @override
  void didUpdateWidget(covariant YoutubePlayerWidget oldWidget) {
    print('didUpdateWidget called');
    super.didUpdateWidget(oldWidget);
  }

  Future<bool> waitInit() async {
    //bool isReady = widget.wcontroller.value.isReady;
    while (!widget.isReady) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (widget.autoStart) {
      logHolder.log('initState play--${widget.model!.name}---------------', level: 5);
      await widget.play();
    }
    logHolder.log('waitInit()', level: 5);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    print('build called');
    player = YoutubePlayerIFrame(
      controller: widget.wcontroller,
    );
    print('player initialized aspectRatio=${player!.aspectRatio}');
    //widget.getThumbnail();

    Size outSize = widget.getOuterSize(player!.aspectRatio);
    if (bookManagerHolder!.isSilent()) {
      widget.wcontroller.setVolume(0);
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
          return YoutubePlayerControllerProvider(
              // Passing controller to widgets below.
              controller: widget.wcontroller,
              child: Scaffold(
                body: show(outSize),
              ));
        });
  }

  Widget show(Size outSize) {
    return Stack(children: [
      widget.getClipRect(
        outSize,
        player!,
        //getThumbnail(),
      ),
      YoutubeValueBuilder(
          buildWhen: (o, n) => (o.metaData != n.metaData),
          builder: (context, value) {
            //widget.onInitialPlay.call(value.metaData);
            return Container(); // 화면에는 아무 표시도 하지 않는다.
          })
      //)
    ]);
  }

  // Widget show(Size outSize) {
  //   return widget.getClipRect(
  //     outSize,
  //     player!,
  //   );
  // }

  Widget getThumbnail() {
    return Material(
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(widget.model!.thumbnail!
                // YoutubePlayerController.getThumbnail(
                //   //videoId: widget.wcontroller.params.playlist.first,
                //   videoId: widget.videoId,
                //   quality: ThumbnailQuality.medium,
                // ),
                ),
            fit: BoxFit.fitWidth,
          ),
        ),
        // child: const Center(
        //   child: CircularProgressIndicator(),
        // ),
      ),
    );
  }

  @override
  void dispose() {
    logHolder.log('Youtube dispose', level: 5);
    //widget.wcontroller.close();
    widget.model!.setPlayState(PlayState.disposed);
    super.dispose();
  }
}
