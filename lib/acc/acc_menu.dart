import 'package:creta01/acc/reorder_dialog.dart';
import 'package:creta01/book_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:creta01/model/model_enums.dart';
import 'package:creta01/common/util/logger.dart';
import 'package:creta01/common/util/my_utils.dart';
//import 'package:creta01/constants/styles.dart';
import 'package:creta01/common/buttons/hover_buttons.dart';
import 'package:creta01/player/play_manager.dart';
//import 'package:creta01/db/db_actions.dart';
//import '../book_manager.dart';
import '../common/notifiers/notifiers.dart';
//import '../model/contents.dart';
import '../model/contents.dart';
import '../studio/artboard/artboard_frame.dart';
//import '../studio/sidebar/my_widget_menu.dart';
import 'acc_manager.dart';
import 'acc.dart';
import 'youtube_dialog.dart';

YoutubeDialog? youtubeEditDialog;
//ReorderDialog? reorderDialog;

class ACCMenu {
  ContentsType _type = ContentsType.free;
  void setType(ContentsType t) {
    _type = t;
  }

  Offset position = const Offset(0, 0);
  Size size = const Size(410, 36);
  bool _visible = false;
  bool get visible => _visible;
  OverlayEntry? entry;
  String accMid = '';

  double buttonWidth = 30.0;
  double buttonHeight = 30.0;

  void notify() {
    logHolder.log("ACCMenu::notify();", level: 5);
    entry!.markNeedsBuild();
  }

  bool isShow() => _visible;

  void unshow(BuildContext context) {
    if (_visible == true) {
      accMid = '';
      _visible = false;
      if (entry != null) {
        entry!.remove();
        entry = null;
        //notify();;
      }
    }
  }

  Widget show(BuildContext context, ACC? acc) {
    logHolder.log('ACCMenu show', level: 5);

    Widget? overlayWidget;
    if (entry != null) {
      entry!.remove();
      entry = null;
    }
    _visible = true;
    entry = OverlayEntry(builder: (context) {
      if (acc != null) {
        accMid = acc.accModel.mid;
      }
      overlayWidget = showOverlay(context, acc);
      return overlayWidget!;
    });
    final overlay = Overlay.of(context)!;
    overlay.insert(entry!, below: stickMenuEntry);

    if (overlayWidget != null) {
      return overlayWidget!;
    }
    return Container(color: Colors.red);
  }

  String getOrder() {
    ACC? acc = accManagerHolder!.getCurrentACC();
    if (acc != null) {
      return '[${acc.accModel.order.value}]';
    }
    return '[]';
  }

  Widget showOverlay(BuildContext context, ACC? acc) {
    // double radiusTopRight = 10; // menu 는 10 정도의 round 값으로 고정한다.
    // double radiusTopLeft = 10;
    // double radiusBottomRight = 10;
    // double radiusBottomLeft = 10;

    //logHolder.log('showOverlay', level: 5);

    bool isReadOnly = bookManagerHolder!.defaultBook!.readOnly.value;

    return Visibility(
      visible: _visible,
      child: Positioned(
        left: position.dx,
        top: position.dy,
        height: size.height,
        width: size.width,
        //child:
        child: glassMorphic(
          radius: 10,
          glass: 10,
          child: Material(
            type: MaterialType.card,
            color: Colors.white.withOpacity(.5),
            //child: Container(
            //color: Colors.white.withOpacity(.5),
            //padding: const EdgeInsets.all(10),
            // decoration: BoxDecoration(
            //   color: Colors.white.withOpacity(0.5),
            // ),
            //decoBox(false, radiusTopLeft, radiusTopRight,radiusBottomLeft, radiusBottomRight),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  isReadOnly == false ? basicMenu(context, acc) : Container(),
                  menuByContentType(context, acc),
                ]),
          ),
          //),
        ),
      ),
    );
  }

  Widget basicMenu(BuildContext context, ACC? acc) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          HoverButton(
              width: buttonWidth,
              height: buttonHeight,
              onEnter: onEnter,
              onExit: onExit,
              onPressed: () {
                accManagerHolder!.up(context);
              },
              icon: const Icon(Icons.flip_to_front)),
          HoverButton(
              width: buttonWidth,
              height: buttonHeight,
              onEnter: onEnter,
              onExit: onExit,
              onPressed: () {
                accManagerHolder!.down(context);
              },
              icon: const Icon(Icons.flip_to_back)),
          HoverButton(
              width: buttonWidth,
              height: buttonHeight,
              onEnter: () {},
              onExit: () {},
              onPressed: () {
                accManagerHolder!.setPrimary();
                accManagerHolder!.notify();
                notify();
                logHolder.log('primary=${accManagerHolder!.isPrimary()}');
              },
              icon: Icon(Icons.star,
                  color: accManagerHolder!.isPrimary() ? Colors.red : Colors.black)),
          HoverButton(
              width: buttonWidth,
              height: buttonHeight,
              onEnter: () {},
              onExit: () {},
              onPressed: () {
                accManagerHolder!.removeACC(context);
              },
              icon: const Icon(Icons.delete)),
          HoverButton(
            width: buttonWidth,
            height: buttonHeight,
            onEnter: () {},
            onExit: () {},
            onPressed: () {
              accManagerHolder!.toggleFullscreen(context);
            },
            icon: Icon(accManagerHolder!.isFullscreen()
                ? Icons.fullscreen_exit_outlined
                : Icons.fullscreen), // fullscreen_exit,
          ),
          // edit 버튼
          (acc != null && acc.accModel.accType == ACCType.youtube)
              ? HoverButton.withIconWidget(
                  width: buttonWidth,
                  height: buttonHeight,
                  onEnter: () {},
                  onExit: () {},
                  onPressed: () {
                    onYoutubePressed(context, acc);
                  },
                  iconFile: "assets/youtube.png",
                )
              : HoverButton(
                  width: buttonWidth,
                  height: buttonHeight,
                  onEnter: () {},
                  onExit: () {},
                  onPressed: () {
                    if (acc != null && acc.accModel.accType != ACCType.text) {
                      // if (reorderDialog != null) {
                      //   reorderDialog!.closeDialog(context);
                      //   reorderDialog = null;
                      // }
                      // reorderDialog = ReorderDialog(acc: acc)..show(context);
                      ReorderDialog(acc: acc).show(context);
                    }
                  },
                  icon: const Icon(Icons.edit_outlined),
                )
        ],
      ),
    );
  }

  void onEnter() {
    accManagerHolder!.setACCOrderVisible(true);
  }

  void onExit() {
    accManagerHolder!.setACCOrderVisible(false);
  }

  void onYoutubePressed(BuildContext context, ACC? acc) {
    if (acc != null) {
      youtubeEditDialog ??= YoutubeDialog(
        onCancel: () {},
        onOK: (currentYoutubeInfo, orderMap, oldACC) async {
          if (oldACC != null) {
            ContentsModel? model = await oldACC.accChild.playManager.getCurrentModel();
            if (model != null) {
              model.name = currentYoutubeInfo.title;
              model.url = currentYoutubeInfo.videoId;
              youtubeEditDialog!.apply(oldACC, model);
            }
          }
        },
      );
      youtubeEditDialog!.init(acc);
      youtubeEditDialog!.show(context);
    }
  }

  Widget menuByContentType(BuildContext context, ACC? acc) {
    if (acc == null) {
      return Container();
    }
    logHolder.log('menuByContentType', level: 5);

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: FutureBuilder(
          future: acc.accChild.playManager.getCurrentData(),
          builder: (BuildContext context, AsyncSnapshot<CurrentData> snapshot) {
            if (snapshot.hasData == false) {
              //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
              return Container();
            }
            if (snapshot.hasError) {
              //error가 발생하게 될 경우 반환하게 되는 부분
              return errMsgWidget(snapshot);
            }
            if (snapshot.connectionState == ConnectionState.done) {
              if ((_type == ContentsType.video || snapshot.data!.type == ContentsType.video) ||
                  (_type == ContentsType.youtube || snapshot.data!.type == ContentsType.youtube) ||
                  (_type == ContentsType.text || snapshot.data!.type == ContentsType.text)) {
                return videoMenu(context, snapshot.data!.state, snapshot.data!.mute, acc);
              } else if (_type == ContentsType.image || snapshot.data!.type == ContentsType.image) {
                return imageMenu(context, snapshot.data!.state, snapshot.data!.mute, acc);
              }
            }
            return Container();
          }),
    );
  }

  Widget videoMenu(BuildContext context, PlayState state, bool mute, ACC? acc) {
    logHolder.log('videoMenu() $state ${acc!.accModel.mid}', level: 5);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HoverButton(
            onEnter: () {},
            onExit: () {},
            width: buttonWidth,
            height: buttonHeight,
            onPressed: () {
              accManagerHolder!.prev(context);
            },
            icon: const Icon(Icons.skip_previous)),
        HoverButton(
            onEnter: () {},
            onExit: () {},
            width: buttonWidth,
            height: buttonHeight,
            onPressed: () {
              accManagerHolder!.next(context);
            },
            icon: const Icon(Icons.skip_next)),
        HoverButton(
            onEnter: () {},
            onExit: () {},
            width: buttonWidth,
            height: buttonHeight,
            onPressed: () {
              if (state != PlayState.start) {
                accManagerHolder!.play(context);
              } else {
                accManagerHolder!.pause(context);
              }
              notify();
            },
            icon: Icon(state != PlayState.start ? Icons.play_arrow : Icons.pause)),
        //icon: const Icon(Icons.pause)),
        getProgressWidget(context, acc),
        HoverButton(
            onEnter: () {},
            onExit: () {},
            width: buttonWidth,
            height: buttonHeight,
            onPressed: () {
              accManagerHolder!.mute(context);
              notify();
            },
            icon: Icon(mute ? Icons.volume_off : Icons.volume_up)),
      ],
    );
  }

  Widget imageMenu(BuildContext context, PlayState state, bool mute, ACC? acc) {
    // if (progressHolder != null) {
    //   progressHolder!.setProgress(0);
    // }
    return ChangeNotifierProvider<ProgressNotifier>.value(
        value: progressHolder!,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HoverButton(
                onEnter: () {},
                onExit: () {},
                width: buttonWidth,
                height: buttonHeight,
                onPressed: () {
                  accManagerHolder!.prev(context);
                },
                icon: const Icon(Icons.skip_previous)),
            HoverButton(
                onEnter: () {},
                onExit: () {},
                width: buttonWidth,
                height: buttonHeight,
                onPressed: () {
                  accManagerHolder!.next(context);
                },
                icon: const Icon(Icons.skip_next)),
            HoverButton(
                onEnter: () {},
                onExit: () {},
                width: buttonWidth,
                height: buttonHeight,
                onPressed: () {
                  if (state != PlayState.start) {
                    accManagerHolder!.play(context, byManual: true);
                  } else {
                    accManagerHolder!.pause(context, byManual: true);
                  }
                  notify();
                },
                icon: Icon(state != PlayState.start ? Icons.play_arrow : Icons.pause)),
            getProgressWidget(context, acc),
            HoverButton(
                onEnter: () {},
                onExit: () {},
                width: buttonWidth,
                height: buttonHeight,
                onPressed: () {
                  // 누끼 버튼
                },
                icon: const Icon(Icons.person_remove_outlined)),
          ],
        ));
  }

  Widget getProgressWidget(BuildContext context, ACC? acc) {
    return FutureBuilder(
        future: acc!.getCurrentVideoProgress(),
        builder: (context, AsyncSnapshot<Widget?> snapshot) {
          if (snapshot.hasError) {
            logHolder.log("snapshot.hasError", level: 6);
            return const Text('progress error');
          }
          if (snapshot.hasData == false) {
            logHolder.log("No data founded , first customer(1)", level: 6);
            return Container();
          }
          if (snapshot.connectionState == ConnectionState.done) {
            logHolder.log("line 1");
          }
          logHolder.log('getProgressWidget', level: 5);
          return snapshot.data!;
        });
  }
}
