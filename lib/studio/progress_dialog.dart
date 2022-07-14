// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import 'package:creta01/common/util/logger.dart';
//import 'package:creta01/constants/styles.dart';
//import 'package:creta01/db/db_actions.dart';
import '../common/buttons/basic_button.dart';
//import '../common/util/textfileds.dart';
import '../common/util/my_utils.dart';
import '../constants/strings.dart';
import '../constants/styles.dart';
import '../studio/artboard/artboard_frame.dart';

class ProgressDialog {
  ProgressDialog();

  bool _visible = false;
  bool get visible => _visible;
  OverlayEntry? entry;

  void notify() {
    logHolder.log("ReorderSelector::notify();", level: 5);
    entry!.markNeedsBuild();
  }

  bool isShow() => _visible;

  void unshow(BuildContext context) {
    if (_visible == true) {
      _visible = false;
      if (entry != null) {
        entry!.remove();
        entry = null;
      }
    }
  }

  void closeDialog(BuildContext context) {
    unshow(context);
  }

  Widget show(BuildContext context) {
    logHolder.log('ReorderSelectorDialog show', level: 5);

    Widget? overlayWidget;
    if (entry != null) {
      entry!.remove();
      entry = null;
    }
    _visible = true;
    entry = OverlayEntry(builder: (context) {
      overlayWidget = showOverlay(context);
      return overlayWidget!;
    });
    final overlay = Overlay.of(context)!;
    overlay.insert(entry!, below: stickMenuEntry);
    if (overlayWidget != null) {
      return overlayWidget!;
    }
    return Container(color: Colors.red);
  }

  Widget showOverlay(BuildContext context) {
    return ShowProgressWidget(
      onApply: () {},
      onClose: () {
        closeDialog(context);
      },
    );
  }
}

class ShowProgressWidget extends StatefulWidget {
  final void Function() onClose;
  final void Function() onApply;

  const ShowProgressWidget({Key? key, required this.onApply, required this.onClose})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ShowProgressWidgetState();
  }
}

class ShowProgressWidgetState extends State<ShowProgressWidget> {
  Size windowSize = const Size(600, 200);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    logHolder.log('screenSize=$screenSize', level: 5);

    return Container(
      width: screenSize.width,
      height: screenSize.height,
      color: Colors.transparent,
      child: Center(
        child: SizedBox(
            // Positioned(
            //     left: posX,
            //     top: posY,
            height: windowSize.height,
            width: windowSize.width,
            child: glassMorphic(
              radius: 10,
              glass: 10,
              child: Material(
                elevation: 5.0,
                shadowColor: Colors.black,
                type: MaterialType.card,
                color: MyColors.primaryColor.withOpacity(.3),
                child: Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: windowSize.width - 14,
                            height: windowSize.height - 64,
                            color: Colors.amber,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                            // basicButton(
                            //     name: MyStrings.apply,
                            //     onPressed: () {
                            //       widget.playManager.swapOrder(widget.order2orderMap);
                            //     },
                            //     iconData: Icons.done_outlined),
                            // const SizedBox(
                            //   width: 5,
                            // ),
                            basicButton(
                                name: MyStrings.close,
                                onPressed: () {
                                  widget.onClose();
                                },
                                iconData: Icons.close_outlined),
                          ]),
                        ])
                    //}),
                    ),
              ),

              //),
            )),
      ),
    );
  }
}
