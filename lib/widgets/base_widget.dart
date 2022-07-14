//import 'dart:collection';
// ignore_for_file: must_be_immutable

import 'package:creta01/widgets/abs_anime.dart';
import 'package:creta01/widgets/enlarge_widget.dart';
import 'package:creta01/widgets/scale_anime.dart';
import 'package:flutter/material.dart';
//import 'package:carousel_slider/carousel_slider.dart';

import 'package:creta01/common/util/logger.dart';
import 'package:creta01/constants/constants.dart';
import 'package:creta01/player/play_manager.dart';
//import 'package:creta01/model/contents.dart';
import 'package:creta01/player/abs_player.dart';
import 'package:creta01/widgets/carousel_widget.dart';
import 'package:creta01/acc/acc.dart';
import 'package:creta01/model/model_enums.dart';

const int minCarouselCount = 3;

class BaseWidget extends StatefulWidget {
  late PlayManager playManager;
  ACC? _parentAcc;
  ACC? get acc => _parentAcc;
  void setParentAcc(ACC acc) {
    _parentAcc = acc;
  }

  // ignore: prefer_final_fields
  //List<AbsPlayWidget> _carouselList = [];

  BaseWidget({required this.baseWidgetKey}) : super(key: baseWidgetKey) {
    playManager = PlayManager(this);
  }
  final GlobalKey<BaseWidgetState> baseWidgetKey;

  @override
  BaseWidgetState createState() => BaseWidgetState();

  void invalidate() {
    if (baseWidgetKey.currentState != null) {
      logHolder.log('BaseWidget::invalidate');
      baseWidgetKey.currentState!.invalidate();
    }
    playManager.invalidate();
  }

  AnimeType getAnimeType() {
    if (acc != null) {
      return acc!.accModel.animeType.value;
    }
    return AnimeType.none;
  }

  bool isAnime() {
    if (getAnimeType() == AnimeType.none) {
      return false;
    }
    if (getAnimeType() == AnimeType.carousel) {
      if (!playManager.isValidCarousel()) {
        return false;
      }
    }
    return true;
  }

  bool isCarousel() {
    if (getAnimeType() == AnimeType.carousel) {
      if (playManager.isValidCarousel()) {
        return true;
      }
    }
    return false;
  }
}

class BaseWidgetState extends State<BaseWidget> {
  //AnimeCarousel? carousel;

  BaseWidgetState() : super() {
    logHolder.log("BaseWidgetState constructor", level: 1);
  }

  @override
  void initState() {
    widget.playManager.initTimer();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //initAnimeTimer();
    });

    //carousel = AnimeCarousel.create();
  }

  @override
  Widget build(BuildContext context) {
    logHolder.log('baseWidget build', level: 5);

    if (widget.isCarousel()) {
      widget.playManager.resetCarousel();
    } else {
      widget.playManager.setAutoStart();
    }
    return Container(
      color: Colors.transparent,
      child: FutureBuilder(
          future: widget.playManager.waitBuild(),
          builder: (BuildContext context, AsyncSnapshot<AbsPlayWidget?> snapshot) {
            if (snapshot.hasData == false || snapshot.data == null) {
              //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
              return Container();
            }
            if (snapshot.hasError) {
              //error가 발생하게 될 경우 반환하게 되는 부분
              return const Text('error');
            }

            if (snapshot.connectionState == ConnectionState.done) {
              logHolder.log(
                  'playTime===${snapshot.data!.model!.playTime.value} sec, ${snapshot.data!.model!.name}');

              // if (pageManagerHolder!.isContents() &&
              //     accManagerHolder!.isCurrentIndex(snapshot.data!.acc.index)) {
              //   selectedModelHolder!.setModel(snapshot.data!.model!);
              // }
              if (!widget.isAnime()) {
                return snapshot.data!;
              }

              switch (widget.getAnimeType()) {
                case AnimeType.carousel:
                  //logHolder.log('AnimeType.carousel start ${widget.playManager.currentIndex}');
                  //return carousel!.carouselWidget(
                  return carouselWidget(
                      context,
                      widget.acc!.accModel.containerSize.value.height,
                      widget.playManager.getPlayWidgetList(),
                      (index, reason) {}, // onPageChanged
                      widget.playManager.animePageChanger,
                      maxInteger, // 가장 큰 수를 넣는다.
                      widget.playManager.currentOrder); // 0은 첫번째 index(즉 0번째)가 가운데로 들어오라는 뜻이다.

                case AnimeType.flip:
                  logHolder.log('AnimeType.flip');
                  return snapshot.data!;
                case AnimeType.enlarge:
                  logHolder.log('AnimeType.enlarge');
                  EnlargeWidget anime = EnlargeWidget(
                    enlargeWidgetKey: GlobalObjectKey<EnlargeWidgetState>(widget.acc!.accModel.mid),
                    millisec: 3000,
                    child: snapshot.data!,
                  );
                  AbsAnime.push(widget.acc!.accModel.mid, anime);
                  return anime;
                case AnimeType.scale:
                  logHolder.log('AnimeType.scale');
                  ScaleAnime anime = ScaleAnime(
                    child: snapshot.data!,
                  );
                  AbsAnime.push(widget.acc!.accModel.mid, anime);
                  return anime;
                default:
                  //logHolder.log('AnimeType.normal');
                  return snapshot.data!;
              }
            }
            return Container();
          }),

      //imagePlayer.play(widget._currentModel!),
      //),
    );
  }

  @override
  void dispose() {
    logHolder.log("BaseWidgetState dispose");
    widget.playManager.cancelTimer();
    super.dispose();
  }

  void invalidate() {
    setState(() {});
  }
}
