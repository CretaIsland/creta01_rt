import 'dart:developer';

//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../common/util/logger.dart';

// ignore: must_be_immutable
class YoutubeApp extends StatefulWidget {
  final void Function(YoutubeMetaData metadata, String thumbnail) onInitialPlay;
  final double width;
  final double height;
  final bool isTest;
  final String videoId;
  final List<String> playList;

  const YoutubeApp(
      {Key? key,
      required this.videoId,
      required this.playList,
      required this.width,
      required this.height,
      required this.onInitialPlay,
      this.isTest = false})
      : super(key: key);

  @override
  YoutubeAppState createState() => YoutubeAppState();
}

class YoutubeAppState extends State<YoutubeApp> {
  late YoutubePlayerController _controller;
  YoutubePlayerIFrame? player;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  void close() {
    _controller.stop();
    //_controller.close();
  }

  @override
  void initState() {
    super.initState();
    //inBuild();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      logHolder.log('afterBuild YoutubePlayerController');
      // if (player!.controller != null) {
      //   player!.controller!.nextVideo();

      // } else {
      //   logHolder.log('controller is null');
      // }
    });
  }

  @override
  void didUpdateWidget(covariant YoutubeApp oldWidget) {
    logHolder.log('didUpdateWidget called');
    super.didUpdateWidget(oldWidget);
  }

  void inBuild() {
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      params: YoutubePlayerParams(
        loop: true,
        mute: true,
        playlist: widget.playList,
        autoPlay: true,
        showControls: true,
        showFullscreenButton: false,
        desktopMode: true,
        privacyEnhanced: true,
        useHybridComposition: true,
        strictRelatedVideos: true,
      ),
    );
    _controller.onEnterFullscreen = () {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      log('Entered Fullscreen');
    };
    _controller.onExitFullscreen = () {
      log('Exited Fullscreen');
    };
  }

  @override
  Widget build(BuildContext context) {
    logHolder.log('build called', level: 5);
    inBuild();
    player = YoutubePlayerIFrame(
      key: ValueKey(const Uuid().v4()),
      controller: _controller,
    );
    // player!.controller!.listen(
    //   (event) {
    //     if (event.playerState == PlayerState.ended) {
    //       logHolder.log('listen, end video');
    //     }
    //   },
    // );
    return YoutubePlayerControllerProvider(
        // Passing controller to widgets below.
        controller: _controller,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: show(),
          // child: player!,
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget show() {
    return Stack(alignment: AlignmentDirectional.bottomEnd, children: [
      widget.isTest
          ? YoutubeValueBuilder(
              key: ValueKey(const Uuid().v4()),
              buildWhen: (o, n) => (o.metaData.title != n.metaData.title),
              builder: (context, value) {
                String thumbnail = YoutubePlayerController.getThumbnail(
                  //videoId: _controller.params.playlist.first,
                  videoId: value.metaData.videoId,
                  quality: ThumbnailQuality.medium,
                );

                widget.onInitialPlay.call(value.metaData, thumbnail);
                //_controller.setVolume(100);
                //_controller.unMute();
                return Container(); // 화면에는 아무 표시도 하지 않는다.
              })
          : Container(),
      player!,
    ]);
  }
}

class YoutubeSimpleApp extends YoutubeApp {
  const YoutubeSimpleApp({
    Key? key,
    required String videoId,
    required List<String> playList,
    required double width,
    required double height,
    required void Function(YoutubeMetaData metadata, String thumbnail) onInitialPlay,
  }) : super(
            key: key,
            videoId: videoId,
            playList: playList,
            width: width,
            height: height,
            onInitialPlay: onInitialPlay,
            isTest: false);
}
