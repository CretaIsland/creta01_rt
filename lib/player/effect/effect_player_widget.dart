// ignore: implementation_imports
// ignore_for_file: prefer_final_fields

//import 'dart:math';
import 'package:creta01/book_manager.dart';
import 'package:creta01/common/util/logger.dart';
import 'package:flutter/material.dart';
import 'package:creta01/model/contents.dart';
import 'package:creta01/model/model_enums.dart';
import 'package:creta01/acc/acc.dart';
import 'package:creta01/player/abs_player.dart';
import 'package:vitality/models/ItemBehaviour.dart';
import 'package:vitality/models/WhenOutOfScreenMode.dart';
import 'package:vitality/vitality.dart';
// ignore: must_be_immutable

// ignore: must_be_immutable
class EffectPlayerWidget extends AbsPlayWidget {
  EffectPlayerWidget({
    required GlobalObjectKey<EffectPlayerWidgetState> key,
    required ContentsModel model,
    required ACC acc,
    void Function()? onAfterEvent,
    bool autoStart = true,
  }) : super(key: key, onAfterEvent: onAfterEvent, acc: acc, model: model, autoStart: autoStart) {
    globalKey = key;
  }

  GlobalObjectKey<EffectPlayerWidgetState>? globalKey;

  @override
  Future<void> play({bool byManual = false}) async {
    //logHolder.log('text play', level: 6);
    model!.setPlayState(PlayState.start);
    if (byManual) {
      model!.setManualState(PlayState.start);
    }
  }

  @override
  Future<void> pause({bool byManual = false}) async {
    model!.setPlayState(PlayState.pause);
  }

  @override
  Future<void> close() async {
    logHolder.log('effect close', level: 6);
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
  ContentsModel getModel() {
    return model!;
  }

  @override
  EffectPlayerWidgetState createState() => EffectPlayerWidgetState();
}

class EffectPlayerWidgetState extends State<EffectPlayerWidget> {
  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  void invalidate() {
    logHolder.log('EffectPlayerWidgetState setState');
    setState(() {});
  }

//Future<Image> _getImageInfo(String url) async {

  Future<void> afterBuild() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      widget.afterBuild();
    });
  }

  @override
  void initState() {
    super.initState();
    afterBuild();
  }

  @override
  Widget build(BuildContext context) {
    if (bookManagerHolder!.isAutoPlay()) {
      widget.model!.setPlayState(PlayState.start);
    } else {
      widget.model!.setPlayState(PlayState.pause);
    }
    Size realSize = widget.acc.getRealSize();

    if (widget.model!.name == 'snow') {
      return Center(
        // child: Container(
        //   alignment: AlignmentDirectional.center,
        //   width: realSize.width,
        //   height: realSize.height,
        //   color: Colors.transparent,
        //child: const Text('this is effect widget'),
        child: Vitality.randomly(
          height: realSize.height,
          width: realSize.width,
          background: Colors.black.withOpacity(0.3),
          maxOpacity: 0.8,
          minOpacity: 0.3,
          itemsCount: 80,
          //enableXMovements: false,
          whenOutOfScreenMode: WhenOutOfScreenMode.Teleport,
          maxSpeed: 5,
          maxSize: 30,
          minSpeed: 0.5,
          randomItemsColors: const [Colors.white10, Colors.white, Colors.white24],
          randomItemsBehaviours: [
            ItemBehaviour(shape: ShapeType.Icon, icon: Icons.star),
            ItemBehaviour(shape: ShapeType.Icon, icon: Icons.ac_unit),
            ItemBehaviour(shape: ShapeType.Icon, icon: Icons.ac_unit_outlined),
          ],
        ),
        //),
      );
      // AutoSize 인 경우
    }

    return Container();
  }
}
