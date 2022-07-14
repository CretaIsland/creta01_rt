// ignore: implementation_imports
// ignore_for_file: prefer_final_fields

//import 'dart:math';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:creta01/constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:scroll_loop_auto_scroll/scroll_loop_auto_scroll.dart';
import 'package:shimmer/shimmer.dart';
//import 'package:text_to_speech/text_to_speech.dart';

import 'package:creta01/book_manager.dart';
import 'package:creta01/common/notifiers/notifiers.dart';
import 'package:creta01/common/util/logger.dart';
import 'package:flutter/material.dart';
import 'package:creta01/model/contents.dart';
import 'package:creta01/model/model_enums.dart';
import 'package:creta01/acc/acc.dart';
import 'package:creta01/player/abs_player.dart';
import 'package:uuid/uuid.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

//import '../../common/util/my_utils.dart';
import '../../common/util/my_utils.dart';
import '../../constants/styles.dart';
import 'tts.dart';

// ignore: must_be_immutable

class TextPlayerProgress extends StatefulWidget {
  final double width;
  final double height;
  final GlobalKey<TextPlayerProgressState> controllerKey;

  const TextPlayerProgress({required this.controllerKey, required this.width, required this.height})
      : super(key: controllerKey);

  @override
  State<TextPlayerProgress> createState() => TextPlayerProgressState();
}

class TextPlayerProgressState extends State<TextPlayerProgress> {
  void invalidate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressNotifier>(builder: (context, notifier, child) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: LinearProgressIndicator(
          value: notifier.progress,
          valueColor: const AlwaysStoppedAnimation<Color>(MyColors.playedColor),
          backgroundColor: notifier.progress == 0 ? MyColors.pgBackgroundColor : Colors.transparent,
        ),
      );
    });
  }
}

// ignore: must_be_immutable
class TextPlayerWidget extends AbsPlayWidget {
  TextPlayerWidget({
    required GlobalObjectKey<TextPlayerWidgetState> key,
    required ContentsModel model,
    required ACC acc,
    void Function()? onAfterEvent,
    bool autoStart = true,
  }) : super(key: key, onAfterEvent: onAfterEvent, acc: acc, model: model, autoStart: autoStart) {
    globalKey = key;
  }

  GlobalObjectKey<TextPlayerWidgetState>? globalKey;
  TextEditingController controller = TextEditingController();

  MyTTS? tts;

  @override
  Future<void> mute() async {
    model!.mute.set(!model!.mute.value);
  }

  @override
  Future<void> play({bool byManual = false}) async {
    logHolder.log('text play', level: 5);
    model!.setPlayState(PlayState.start);
    if (byManual) {
      model!.setManualState(PlayState.start);
    }
    if (model!.isTTS.value == true && model!.mute.value == false) {
      tts ??= MyTTS();
      tts!.setLang(code2TTSMap[model!.lang.value] ?? ttsCodes[0]);
      tts!.speak(model!.remoteUrl!);
    }
  }

  @override
  Future<void> pause({bool byManual = false}) async {
    model!.setPlayState(PlayState.pause);
    if (model!.isTTS.value == true && tts != null) {
      tts!.stop();
    }
  }

  @override
  Future<void> close() async {
    logHolder.log('Image close', level: 5);

    model!.setPlayState(PlayState.none);
    if (model!.isTTS.value == true && tts != null) {
      tts!.stop();
    }
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
  TextPlayerWidgetState createState() => TextPlayerWidgetState();
}

class TextPlayerWidgetState extends State<TextPlayerWidget> {
  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  void invalidate() {
    logHolder.log('TextPlayerWidgetState setState');
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
    String uri = widget.getURI(widget.model!);
    double fontSize = widget.model!.fontSize.value;

    if (widget.model!.isAutoSize.value == true &&
        (widget.model!.aniType.value != TextAniType.rotate ||
            widget.model!.aniType.value != TextAniType.bounce ||
            widget.model!.aniType.value != TextAniType.fade ||
            widget.model!.aniType.value != TextAniType.shimmer ||
            widget.model!.aniType.value != TextAniType.typewriter ||
            widget.model!.aniType.value != TextAniType.wavy ||
            widget.model!.aniType.value != TextAniType.fidget)) {
      fontSize = maxFontSize;
    }

    TextStyle style = DefaultTextStyle.of(context).style.copyWith(
        fontFamily: widget.model!.font.value,
        color: widget.model!.fontColor.value.withOpacity(widget.model!.opacity.value),
        fontSize: fontSize,
        decoration: getTextDecoration(widget.model!.line.value),
        fontWeight: widget.model!.isBold.value ? FontWeight.bold : FontWeight.normal,
        fontStyle: widget.model!.isItalic.value ? FontStyle.italic : FontStyle.normal);

    if (widget.model!.isAutoSize.value == false) {
      style.copyWith(
        fontSize: fontSize,
      );
    }
    return Center(
      child: Container(
        padding: EdgeInsets.fromLTRB(realSize.width * 0.05, realSize.height * 0.05,
            realSize.width * 0.05, realSize.height * 0.05),
        alignment: AlignmentDirectional.center,
        width: realSize.width,
        height: realSize.height,
        color: Colors.transparent,
        child: playText(uri, style, fontSize, realSize),
      ),
    );

    // AutoSize 인 경우
  }

  Widget playText(String text, TextStyle style, double fontSize, Size realSize) {
    //logHolder.log('playText ${widget.model!.outLineWidth.value} ${widget.model!.aniType.value}',level: 5);

    TextStyle? shadowStyle;
    if (widget.model!.shadowBlur.value > 0) {
      //logHolder.log('widget.model!.shadowBlur.value=${widget.model!.shadowBlur.value}', level: 5);
      shadowStyle = style.copyWith(shadows: [
        Shadow(
            color: widget.model!.shadowColor.value.withOpacity(widget.model!.shadowIntensity.value),
            offset: Offset(
                widget.model!.shadowBlur.value * 0.75, widget.model!.shadowBlur.value * 0.75),
            blurRadius: widget.model!.shadowBlur.value),
      ]);
    }

    if (widget.model!.aniType.value != TextAniType.none) {
      return animationText(
          text, shadowStyle ?? style, outLineAndShadowText(text, shadowStyle ?? style), realSize);
    }
    return outLineAndShadowText(text, shadowStyle ?? style);
  }

  TextStyle getOutLineStyle(TextStyle style) {
    return style.copyWith(
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = widget.model!.outLineWidth.value
        ..color = widget.model!.outLineColor.value,
    );
  }

  Widget outLineAndShadowText(String text, TextStyle style) {
    // 새도우의 경우.

    // 아웃라인의 경우.
    if (widget.model!.outLineWidth.value > 0) {
      TextStyle outlineStyle = getOutLineStyle(style);

      return Stack(
        alignment: AlignmentDirectional.center,
        children: [
          widget.model!.isAutoSize.value
              ? AutoSizeText(text, textAlign: widget.model!.align.value, style: outlineStyle)
              : Text(text, textAlign: widget.model!.align.value, style: outlineStyle),
          widget.model!.isAutoSize.value
              ? AutoSizeText(text, textAlign: widget.model!.align.value, style: style)
              : Text(text, textAlign: widget.model!.align.value, style: style),
        ],
      );
    }

    // 아웃라인도 아니고, 애니매이션도 아닌 경우.
    return widget.model!.isAutoSize.value
        ? AutoSizeText(text, textAlign: widget.model!.align.value, style: style)
        : Text(text, textAlign: widget.model!.align.value, style: style);
  }

  Widget animationText(String text, TextStyle style, Widget? textWidget, Size realSize) {
    int textSize = getStringSize(text);
    // duration 이 50 이면 실제로는 5초 정도에  문자열을 다 흘려보내다.
    // 따라서 문자열의 길이에  anyDuration / 10  정도의 값을 곱해본다.

    String key = const Uuid().v4();
    if (widget.model!.aniType.value != TextAniType.tickerSide &&
        widget.model!.aniType.value != TextAniType.tickerUpDown) {
      if (widget.model!.outLineWidth.value > 0) {
        style = style.copyWith(
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = widget.model!.outLineWidth.value
            ..color = widget.model!.outLineColor.value,
        );
      }
      if (widget.model!.aniType.value != TextAniType.shimmer) {
        style = style.copyWith(fontSize: getAutoFontSize(textSize, realSize));
      }
    }

    switch (widget.model!.aniType.value) {
      case TextAniType.tickerSide:
        {
          int duration = textSize * ((101 - widget.model!.anyDuration.value) / 10).ceil();
          return ScrollLoopAutoScroll(
              key: ValueKey(key),
              // ignore: sort_child_properties_last
              child: outLineAndShadowText(text.replaceAll('\n', ' '), style),
              scrollDirection: Axis.horizontal,
              delay: const Duration(seconds: 1),
              duration: Duration(seconds: duration),
              gap: 25,
              reverseScroll: false,
              duplicateChild: 25,
              enableScrollInput: true,
              delayAfterScrollInput: const Duration(seconds: 1));
        }
      case TextAniType.tickerUpDown:
        {
          int duration =
              (textSize * 0.5).ceil() * ((101 - widget.model!.anyDuration.value) / 10).ceil();
          return ScrollLoopAutoScroll(
              key: ValueKey(key),
              // ignore: sort_child_properties_last
              child: outLineAndShadowText(text, style),
              scrollDirection: Axis.vertical, //required
              delay: const Duration(seconds: 1),
              duration: Duration(seconds: duration),
              gap: 25,
              reverseScroll: false,
              duplicateChild: 25,
              enableScrollInput: true,
              delayAfterScrollInput: const Duration(seconds: 1));
        }
      case TextAniType.rotate:
        {
          int duration = 600 - widget.model!.anyDuration.value.round();

          return TextAnimator(
            text,
            key: ValueKey(key),
            atRestEffect: WidgetRestingEffects.rotate(),
            incomingEffect: WidgetTransitionEffects(
                blur: const Offset(2, 2), duration: Duration(milliseconds: duration)),
            outgoingEffect: WidgetTransitionEffects(
                blur: const Offset(2, 2), duration: Duration(milliseconds: duration)),
            style: style,
            textAlign: widget.model!.align.value,
          );
        }
      case TextAniType.bounce:
        {
          int duration = 2000 - (widget.model!.anyDuration.value * 10).round();
          return TextAnimator(
            text,
            key: ValueKey(key),
            incomingEffect: WidgetTransitionEffects.incomingScaleDown(
                duration: Duration(milliseconds: duration)),
            atRestEffect: WidgetRestingEffects.bounce(),
            //outgoingEffect: WidgetTransitionEffects.outgoingScaleUp(),
            // onIncomingAnimationComplete: (key) async {
            //   logHolder.log("TextAniType.bounce onIncomingAnimationComplete()", level: 5);
            //   await Future.delayed(Duration(milliseconds: duration * 8));
            //   setState(() {});
            // },
            style: style,
            textAlign: widget.model!.align.value,
          );
        }
      case TextAniType.fidget:
        {
          //int duration = 2000 - (widget.model!.anyDuration.value * 10).round();
          return TextAnimator(
            text,
            key: ValueKey(key),
            incomingEffect: WidgetTransitionEffects.incomingSlideInFromLeft(),
            atRestEffect: WidgetRestingEffects.fidget(),
            //outgoingEffect: WidgetTransitionEffects.outgoingSlideOutToBottom(),
            // onIncomingAnimationComplete: (key) async {
            //   logHolder.log("TextAniType.bounce onIncomingAnimationComplete()", level: 5);
            //   await Future.delayed(Duration(milliseconds: duration * 8));
            //   setState(() {});
            // },
            style: style,
            textAlign: widget.model!.align.value,
          );
        }
      case TextAniType.fade:
        {
          //int duration = 2000 - (widget.model!.anyDuration.value * 10).round();
          return TextAnimator(
            text,
            key: ValueKey(key),
            incomingEffect: WidgetTransitionEffects.incomingSlideInFromLeft(),
            atRestEffect: WidgetRestingEffects.pulse(),
            style: style,
            textAlign: widget.model!.align.value,
          );
        }
      case TextAniType.shimmer:
        {
          int duration = 11000 - (widget.model!.anyDuration.value * 100).round();
          return Shimmer.fromColors(
              key: ValueKey(key),
              period: Duration(milliseconds: duration),
              baseColor: widget.model!.fontColor.value,
              highlightColor: widget.model!.outLineColor.value,
              child: widget.model!.isAutoSize.value
                  ? AutoSizeText(text, textAlign: widget.model!.align.value, style: style)
                  : Text(text, textAlign: widget.model!.align.value, style: style));
        }
      case TextAniType.typewriter:
        {
          int duration = 505 - widget.model!.anyDuration.value.round() * 5;

          return AnimatedTextKit(
            key: ValueKey(key),
            repeatForever: true,
            animatedTexts: [
              TypewriterAnimatedText(text,
                  textAlign: widget.model!.align.value,
                  textStyle: style,
                  speed: Duration(milliseconds: duration)),
            ],
          );
        }
      case TextAniType.wavy:
        {
          int duration = 505 - widget.model!.anyDuration.value.round() * 5;

          return AnimatedTextKit(
            key: ValueKey(key),
            repeatForever: true,
            animatedTexts: [
              WavyAnimatedText(text,
                  textAlign: widget.model!.align.value,
                  textStyle: style,
                  speed: Duration(milliseconds: duration)),
            ],
          );
        }
      default:
        return widget.model!.isAutoSize.value
            ? AutoSizeText(
                text,
                textAlign: widget.model!.align.value,
                style: style,
              )
            : Text(
                text,
                textAlign: widget.model!.align.value,
                style: style,
              );
    }
  }

  double getAutoFontSize(int textSize, Size realSize) {
    double fontSize = widget.model!.fontSize.value;

    if (widget.model!.isAutoSize.value == false) {
      return fontSize;
    }
    // 텍스트 길이
    double entireWidth = fontSize * textSize; // 한줄로 했을때, 필요한 width
    int lineCount =
        (entireWidth / (0.9 * realSize.width)).ceil(); //  현재 폰트사이즈에서 현재 width 상황에서 필요한 라인수
    double idealWidth = fontSize * (textSize.toDouble() / lineCount.toDouble()); //
    double idealHeight = (lineCount + 1) * fontSize;

    // 이상적인 사이즈가 현재 사이즈보다 크다면, 폰트가 줄어들어야 하고,
    // 현재 사이즈보다 작다면,  폰트가 커져야 한다.
    double fontRatio = sqrt(realSize.width * realSize.height) / sqrt(idealWidth * idealHeight);
    return fontSize * fontRatio;
    //logHolder.log("font = ${widget.model!.font.value}, fontRatio=$fontRatio, fontSize=$fontSize",
    //    level: 5);
  }
}
