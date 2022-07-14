// ignore_for_file: must_be_immutable

import 'package:creta01/studio/pages/page_manager.dart';
import 'package:flutter/material.dart';

import 'package:creta01/common/util/logger.dart';
import 'package:uuid/uuid.dart';
//import 'package:creta01/constants/styles.dart';
//import 'package:creta01/db/db_actions.dart';
import '../common/buttons/basic_button.dart';
//import '../common/util/textfileds.dart';
import '../common/util/my_utils.dart';
import '../constants/strings.dart';
import '../constants/styles.dart';
import '../model/contents.dart';
import '../player/play_manager.dart';
import '../studio/artboard/artboard_frame.dart';
import 'acc.dart';

class ReorderDialog {
  final ACC acc;
  List<String> playList = [];

  ReorderDialog({required this.acc}) {
    clearInfo();
  }

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
        //videoIdController.dispose();
        //notify();;
      }
    }
  }

  void closeDialog(BuildContext context) {
    unshow(context);
  }

  void clearInfo() {
    playList.clear();
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
    return ThumbnailSwipList(
      acc: acc,
      playManager: acc.accChild.playManager,
      onApply: () {},
      onClose: () {
        closeDialog(context);
      },
    );
  }
}

class ThumbnailSwipList extends StatefulWidget {
  final ACC acc;
  final PlayManager playManager;
  final void Function() onClose;
  final void Function() onApply;

  final Map<int, int> idx2orderMap = {};
  //final Map<int, int> order2orderMap = {};

  ThumbnailSwipList(
      {Key? key,
      required this.acc,
      required this.playManager,
      required this.onApply,
      required this.onClose})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ThumbnailSwipListState();
  }
}

class ThumbnailSwipListState extends State<ThumbnailSwipList> {
  final ScrollController _scrollController = ScrollController(initialScrollOffset: 0.0);
  String _currentMid = '';
  //final List<Widget> _thumnailList = [];

  Size windowSize = const Size(240, 800);
  late double cardHeight;
  late double cardWidth;

  @override
  void initState() {
    super.initState();

    cardWidth = 210;
    cardHeight = cardWidth * (9 / 16);

    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    logHolder.log('screenSize=$screenSize', level: 5);

    //double posX = (screenSize.width - windowSize.width) / 2;
    //double posY = (screenSize.height - windowSize.height) / 2 + 30;

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
                          SizedBox(
                            width: windowSize.width - 14,
                            height: windowSize.height - 64,
                            //padding: const EdgeInsets.only(top: 10),
                            child: Scrollbar(
                              //isAlwaysShown: true,
                              thumbVisibility: true,
                              controller: _scrollController,
                              thickness: 20,
                              child: ReorderableListView(
                                scrollDirection: Axis.vertical,
                                buildDefaultDragHandles: false,
                                scrollController: _scrollController,
                                children: getList(),
                                onReorder: (oldIndex, newIndex) async {
                                  logHolder.log('old=$oldIndex,new=$newIndex', level: 5);
                                  int newOrder = widget.idx2orderMap[newIndex] ?? -1;
                                  int oldOrder = widget.idx2orderMap[oldIndex] ?? -1;

                                  if (newOrder < 0 && oldOrder < 0) return;
                                  //widget.idx2orderMap[oldIndex] = newOrder;
                                  //widget.idx2orderMap[newIndex] = oldOrder;
                                  //widget.order2orderMap[oldOrder] = newOrder;
                                  //widget.order2orderMap[newOrder] = oldOrder;

                                  await widget.playManager.swapOrder(oldOrder, newOrder);
                                  pageManagerHolder!.notify();
                                  widget.acc.notify();
                                  setState(() {});
                                },
                              ),
                            ),
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

  List<Widget> getList() {
    widget.idx2orderMap.clear();
    List<Widget> retval = [];
    int idx = 0;
    for (ContentsModel model in widget.playManager.getModelList()) {
      if (model.isRemoved.value == true) continue;
      widget.idx2orderMap[idx] = model.order.value;
      //widget.order2orderMap[model.order.value] = model.order.value;
      retval.add(eachCard(idx++, model));
    }
    if (retval.isEmpty) {
      return [emptyCard()];
    }
    return retval;
  }

  // void initList() {
  //   int idx = 0;
  //   _thumnailList.clear();
  //   for (ContentsModel model in widget.playManager.getModelList()) {
  //     if (model.isRemoved.value == true) continue;
  //     widget.idx2orderMap[idx] = model.order.value;
  //     //widget.order2orderMap[model.order.value] = model.order.value;
  //     _thumnailList.add(eachCard(idx++, model));
  //   }
  //   if (_thumnailList.isEmpty) {
  //     _thumnailList.add(emptyCard());
  //   }
  // }

  int getValidCount() {
    int count = 0;
    return count;
  }

  Widget eachCard(int pageIndex, ContentsModel info) {
    logHolder.log('eachCard($pageIndex)');
    try {
      return ReorderableDragStartListener(
        key: ValueKey(info.mid),
        index: pageIndex,
        child: GestureDetector(
          //key: ValueKey(info.videoId),
          onTapDown: (details) {
            setState(() {
              logHolder.log('selected = ${info.order.value}');
              _currentMid = info.mid;
              widget.acc.selectContents(context, widget.acc.accModel.mid, order: info.order.value);
            });
          },
          child: Card(
            color: MyColors.secondaryCompl,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  width: 2.0,
                  color:
                      info.mid == _currentMid ? MyColors.mainColor : MyColors.pageSmallBorderCompl),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: Container(
              width: cardWidth,
              height: cardHeight,
              padding: const EdgeInsets.all(8),
              child: Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  DecoratedBox(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(info.thumbnail!),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      child: Container()),
                  Container(
                    color: Colors.white.withOpacity(0.1),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //outLineText(
                          Text(
                            '${[info.order.value]}',
                            style: DefaultTextStyle.of(context).style.copyWith(
                                color: Colors.grey, fontSize: 20, decoration: TextDecoration.none),
                            maxLines: 1,
                          ),
                          //outLineText(
                          Text(
                            info.name,
                            style: DefaultTextStyle.of(context).style.copyWith(
                                color: Colors.grey, fontSize: 16, decoration: TextDecoration.none),
                            maxLines: 3,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    // 삭제 버튼
                    iconSize: MySizes.smallIcon,
                    onPressed: () {
                      info.isRemoved.set(true);
                      if (getValidCount() == 0) {
                        _currentMid = '';
                      } else {
                        if (info.mid == _currentMid) {
                          for (var info in widget.playManager.getModelList()) {
                            if (info.isRemoved.value == false) {
                              _currentMid = info.mid;
                              widget.acc.selectContents(context, info.mid, order: info.order.value);
                            }
                          }
                        }
                      }
                      setState(() {});
                      pageManagerHolder!.notify();
                      widget.acc.notify();
                    },
                    icon: const Icon(Icons.delete_outline),
                    color: MyColors.icon,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      logHolder.log("ReorderableDragStartListener error", level: 6);
      return emptyCard();
    }
  }

  Widget emptyCard() {
    logHolder.log('emptyCard()', level: 5);

    return ReorderableDragStartListener(
      key: ValueKey(const Uuid().v4()),
      index: 0,
      child: Card(
        color: MyColors.secondaryCompl,
        shape: const RoundedRectangleBorder(
          side: BorderSide(width: 2.0, color: MyColors.pageSmallBorderCompl),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Container(
          width: cardWidth,
          padding: const EdgeInsets.all(8),
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}
