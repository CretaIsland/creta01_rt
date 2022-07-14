import 'package:creta01/common/util/logger.dart';
import 'package:flutter/material.dart';
//import 'package:rive_loading/rive_loading.dart';
//import 'package:progress_indicators/progress_indicators.dart';
import 'package:creta01/studio/save_manager.dart';
import 'package:creta01/common/effect/wave_effect.dart';
import 'package:loading_animations/loading_animations.dart';

import '../constants/strings.dart';
import '../constants/styles.dart';
import '../model/model_enums.dart';

class SaveIndicator extends StatefulWidget {
  final bool isMainScreen;
  final ProgressState state;
  const SaveIndicator({Key? key, required this.state, this.isMainScreen = false}) : super(key: key);

  @override
  State<SaveIndicator> createState() => SaveIndicatorState();
}

class SaveIndicatorState extends State<SaveIndicator> {
  final double height = 40;
  Paint paint = Paint()..color = Colors.transparent;
  Color color = Colors.grey.withOpacity(0.1);

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    color = widget.isMainScreen ? Colors.red : Colors.grey.withOpacity(0.1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return Consumer<SaveManager>(builder: (context, saveManager, child) {
    //   return FutureBuilder(
    //       future: saveManagerHolder!.getProgress(),
    //       builder: (BuildContext context, AsyncSnapshot<ProgressState> snapshot) {
    //         if (snapshot.hasData == false) {
    //           //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
    //           return Container();
    //         }
    //         if (snapshot.hasError) {
    //           //error가 발생하게 될 경우 반환하게 되는 부분
    //           logHolder.log('FutureBuilder InProgressType error ', level: 6);
    //           return Container();
    //         }
    //         logHolder.log('SaveIndicatorState...${snapshot.data!.toString()}', level: 1);
    //         ProgressState state = snapshot.data!;
    //         showWidget(state);
    //       });
    // });
    return showState(widget.state);
  }

  Widget showState(ProgressState state) {
    switch (state.progressType) {
      case InProgressType.done:
        return Container(
          height: height,
          color: color,
        );
      case InProgressType.saving:
        logHolder.log('Saving...', level: 1);
        return aniIndicator(MyStrings.saving);
      case InProgressType.contentsUploading:
        logHolder.log('ContentsUploding...', level: 1);
        //return aniIndicator(MyStrings.contentsUploading,
        return indicator(MyStrings.contentsUploading,
            fileSize: state.fileSize, progress: state.progress);
      //return CretaUploader.getUploadIndicator(MyStrings.contentsUploading);
      // case InProgressType.thumbnailUploading:
      //   logHolder.log('ThumbnailUploding...', level: 1);
      //   return aniIndicator(MyStrings.thumbnailUploading);
    }
  }

  Widget waveIndicator(String text) {
    return Container(
      height: height,
      color: color,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          WaveEffect(height: height, blurIndex: 2),
          Text(
            text,
            style: TextStyle(fontSize: height / 2, color: Colors.white70, background: paint),
          ),
        ],
      ),
    );
  }

  Widget indicator(
    String text, {
    int fileSize = 0,
    double progress = 0,
  }) {
    if (fileSize > 0 && progress > 0) {
      text = '$text(fileSize: ${(fileSize / (1024 * 1024)).round()}MB, ${progress.round()}%)';
    }
    return Container(
      height: height,
      color: color,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          LinearProgressIndicator(
            value: progress / 100,
            color: MyColors.mainColor,
            backgroundColor: color,
            minHeight: height,
          ),
          //FadingText(
          Text(
            text,
            style: TextStyle(fontSize: height / 2, background: paint),
          ),
        ],
      ),
    );
  }

  Widget fadeIndicator(String text) {
    return Container(
      height: height,
      color: color,
      alignment: AlignmentDirectional.center,
      child: Text(
        text,
        style: TextStyle(fontSize: height / 2, color: Colors.black, background: paint),
      ),
    );
  }

  Widget aniIndicator(
    String text, {
    int fileSize = 0,
    double progress = 0,
  }) {
    if (fileSize > 0 && progress > 0) {
      text = '${progress.round()}%, $text(fileSize: ${(fileSize / 1024).round()})';
    }

    return Container(
      height: height,
      color: color,
      alignment: AlignmentDirectional.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingRotating.square(
            size: height / 2,
            backgroundColor: MyColors.primaryColor,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            text,
            style: TextStyle(fontSize: height / 2, background: paint),
          ),
        ],
      ),
    );
  }

  // Widget riveIndicator(String text) {
  //   return Container(
  //     height: 100,
  //     color: color,
  //     child: RiveLoading(
  //       name: 'new_file.riv',
  //       loopAnimation: text,
  //       endAnimation: 'success',
  //       width: 200,
  //       height: 200,
  //       fit: BoxFit.fill,
  //       until: () => Future.delayed(const Duration(seconds: 5)),
  //       onSuccess: (_) {
  //         logHolder.log('Finished');
  //       },
  //       onError: (err, stack) {
  //         logHolder.log('error: $err', level: 6);
  //       },
  //     ),
  //   );
  // }
}
