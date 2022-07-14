import 'dart:async';

import 'package:flutter/material.dart';

import '../common/util/logger.dart';

abstract class AbsAnime extends StatefulWidget {
  static Map<String, AbsAnime> animeMap = <String, AbsAnime>{};

  static void push(String mid, AbsAnime anime) {
    animeMap[mid] = anime;
  }

  static AbsAnime? get(String mid) {
    return animeMap[mid];
  }

  const AbsAnime({Key? key}) : super(key: key);

  void action(dynamic params);

  @override
  State<AbsAnime> createState() => _AbsAnimeState();
}

class _AbsAnimeState extends State<AbsAnime> {
  Timer? _animeTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //initAnimeTimer();
    });
  }

  @override
  void dispose() {
    if (_animeTimer != null) {
      _animeTimer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  void initAnimeTimer() {
    _animeTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      int tick = timer.tick;
      if (tick == 10) {
        logHolder.log('AnimationTimer=$tick', level: 5);
        //.. 여기서 타이머가 필요한 작업을 한다.
        return;
      }
    });
  }
}
