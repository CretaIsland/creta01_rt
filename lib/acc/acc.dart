// ignore_for_file: prefer_final_fields
import 'dart:math';
// ignore: avoid_web_libraries_in_flutter

//import 'package:flutter/material.dart';
import 'package:creta01/book_manager.dart';
import 'package:creta01/player/play_manager.dart';
import 'package:flutter_neumorphic_null_safety/flutter_neumorphic.dart';

import 'package:creta01/common/util/my_utils.dart';
import 'package:creta01/studio/pages/page_manager.dart';
import 'package:creta01/studio/save_manager.dart';

import '../common/cursor/right_click.dart';
import '../widgets/abs_anime.dart';
import 'resizable.dart';
import '../model/acc_property.dart';
import 'acc_manager.dart';
import '../common/drag_and_drop/drop_zone_widget.dart';
import '../common/neumorphic/neumorphic.dart';
import '../common/util/logger.dart';
import '../common/undo/undo.dart';
import '../widgets/base_widget.dart';
import '../constants/styles.dart';
import '../constants/constants.dart';
import '../studio/artboard/artboard_frame.dart';
import '../model/model_enums.dart';
import '../model/pages.dart';

//import 'package:creta01/studio/pages/page_manager.dart';
class RotateCorner {
  CursorType cursor = CursorType.move;
  double dx = 0;
  double dy = 0;
}

class ACC {
  // extends ACCProperty {
  final BaseWidget accChild;
  late ACCProperty accModel;

  PageModel? page;
  OverlayEntry? entry;

  //bool? isVisible;
  bool actionStart = false;
  bool radiusActionStart = false;
  bool sizeActionStart = false;
  bool isHover = false;
  bool isCornered = false;
  bool isRadiused = false;
  final List<bool> isCornerHover = [false, false, false, false, false, false, false, false];
  final List<bool> isRadiusHover = [false, false, false, false];
  CursorType cursor = CursorType.pointer;

  static double _lastOffsetX = 40;
  static double _lastOffsetY = 40;

  Offset _prevOffset = Offset.zero;
  Size _prevSize = Size.zero;

  Color prevBgColor = Colors.transparent;
  double prevGlassFill = 0;
  double prevOpacity = 1;
  Color prevBorderColor = Colors.transparent;

  ACC({required this.page, required this.accChild, required int idx}) {
    accModel = ACCProperty(type: ModelType.acc, parent: page!.mid);
    if (accModel.containerSize.value.width == 0 && accModel.containerSize.value.height == 0) {
      accModel.containerSize
          .set(Size(page!.width.value / 3, page!.height.value / 3), save: false, noUndo: true);
    }
    if (accModel.containerOffset.value.dx == 0 && accModel.containerOffset.value.dy == 0) {
      accModel.containerOffset
          .set(Offset(page!.width.value / 8, page!.height.value / 8), save: false, noUndo: true);
    }
    accModel.order.set(idx); // 이 시점에 자동으로 save 가 된다.
  }

  ACC.fromProperty({required this.page, required this.accChild, required this.accModel});

  void saveAs(String newParentId) {
    accModel = ACCProperty.copy(accModel, newParentId)..save();
    // 여기서 playManger 를 saveAs 해주어야 한다.
  }

  void deserialize(Map<String, dynamic> map) {
    logHolder.log('deserialize ACC');
    accModel.deserialize(map);
  }

  Map<String, dynamic> serialize() {
    logHolder.log('serialize ACC', level: 1);
    return accModel.serialize();
  }

  void initSizeAndPosition() {
    Offset start = Offset(_lastOffsetX, _lastOffsetY);
    accModel.containerOffset.init(start);

    Size pageSize = page!.getRealSize();

    if (_lastOffsetX + accModel.containerSize.value.width >= pageSize.width) {
      _lastOffsetX = 20;
    } else {
      _lastOffsetX += 10;
    }
    if (_lastOffsetY + accModel.containerSize.value.height >= pageSize.height) {
      _lastOffsetY = 20;
    } else {
      _lastOffsetY += 10;
    }
    logHolder.log(
        "pageSize.height=${pageSize.height},containerSize+ =${accModel.containerSize.value.height},_lastOffsetY=$_lastOffsetY");
  }

  Widget registerOverlay(BuildContext context) {
    logHolder.log('registerOverlay', level: 5);
    Widget? overlayWidget;
    if (entry == null) {
      entry = OverlayEntry(
        builder: (context) {
          overlayWidget = showOverlay(context);
          return overlayWidget!;
        },
      );
      final overlay = Overlay.of(context)!;
      overlay.insert(entry!, below: stickMenuEntry);
      // } else {
      //   isVisible = true;
    }
    if (overlayWidget != null) {
      return overlayWidget!;
    }
    return Container(color: Colors.red);
  }

  Offset getRealOffset() {
    if (page != null) {
      Offset origin = page!.getPosition();
      Size ratio = page!.getRealRatio();
      double dx = ratio.width * accModel.containerOffset.value.dx + origin.dx;
      double dy = ratio.height * accModel.containerOffset.value.dy + origin.dy;
      return Offset(dx, dy);
    }
    return accModel.containerOffset.value;
  }

  Size getRealRatio() {
    if (page != null) {
      return page!.getRealRatio();
    }
    return const Size(1, 1);
  }

  Offset getRealOffsetWithGivenRatio(Size ratio) {
    if (page != null) {
      //logHolder.log("getRealOffsetWithGivenRatio($ratio)", level: 5);
      Offset origin = page!.getPosition();
      double dx = ratio.width * accModel.containerOffset.value.dx + origin.dx;
      double dy = ratio.height * accModel.containerOffset.value.dy + origin.dy;
      return Offset(dx, dy);
    }
    //logHolder.log("getRealOffsetWithGivenRatio(page is null)", level: 5);
    return accModel.containerOffset.value;
  }

  Size getRealSize() {
    if (page != null) {
      Size ratio = page!.getRealRatio();
      double width = ratio.width * accModel.containerSize.value.width;
      double height = ratio.height * accModel.containerSize.value.height;
      return Size(width, height);
    }
    return accModel.containerSize.value;
  }

  void _setContainerOffset(Offset offset) {
    // 자석기능
    double dx = offset.dx;
    double dy = offset.dy;
    if (dx <= magnetic) {
      dx = 0;
    }
    if (dy <= magnetic) {
      dy = 0;
    }

    double pw = page!.width.value.toDouble();
    double ph = page!.height.value.toDouble();

    if (dx + accModel.containerSize.value.width > pw - magnetic) {
      dx = pw - accModel.containerSize.value.width;
    }
    if (dy + accModel.containerSize.value.height > ph - magnetic) {
      dy = ph - accModel.containerSize.value.height;
    }

    accModel.containerOffset.set(Offset(dx, dy));
    //accManagerHolder!.notify();
  }

  void _setContainerOffsetAndSize(Offset offset, Size size) {
    double dx = offset.dx;
    double dy = offset.dy;
    if (dx <= magnetic) {
      dx = 0;
    }
    if (dy <= magnetic) {
      dy = 0;
    }
    double w = size.width;
    double h = size.height;
    double pw = page!.width.value.toDouble();
    double ph = page!.height.value.toDouble();
    if (w >= pw - magnetic) {
      w = pw;
    }
    if (h >= ph - magnetic) {
      h = ph;
    }

    if (dx + w > pw - magnetic) {
      w = pw - dx;
    }
    if (dy + h > ph - magnetic) {
      h = ph - dy;
    }

    accModel.containerOffset.set(Offset(dx, dy));
    accModel.containerSize.set(Size(w, h));
    //accManagerHolder!.notify();
  }

  void showACCMenu(BuildContext context, {String currentMid = ''}) {
    logHolder.log('showACCMenu', level: 5);
    if (accManagerHolder == null) {
      logHolder.log('accManagerHolder is null', level: 5);
      return;
    }
    if (accManagerHolder!.isMenuVisible()) {
      bool reshow = accManagerHolder!.isMenuHostChanged();
      logHolder.log('Menu Visible', level: 5);
      accManagerHolder!.unshowMenu(context);
      if (reshow) {
        accManagerHolder!.showMenu(context, this);
      } else {
        //setState 만 다시 해준다.  2022.4.18 skpark 이걸 해야...progress controll 이 바뀔텐데..
        // 테스트가 필요함...
        //accManagerHolder!.invalidateMenu(context, this);
      }
    } else {
      accManagerHolder!.showMenu(context, this, currentMid: currentMid);
    }
  }

  bool getVisibility() {
    return (!accModel.isRemoved.value &&
        pageManagerHolder != null &&
        pageManagerHolder!.isPageSelected(accModel.parentMid.value));
  }

  Widget showOverlay(BuildContext context) {
    //logHolder.log('showOverlay', level: 5);
    Size ratio = getRealRatio();
    Offset realOffset = getRealOffsetWithGivenRatio(ratio);
    Size realSize = getRealSize();
    bool isAccSelected = accManagerHolder!.isCurrentIndex(accModel.mid);
    double mouseMargin = resizeButtonSize / 2;
    Size marginSize = Size(realSize.width + resizeButtonSize, realSize.height + resizeButtonSize);
    bool isReadOnly = bookManagerHolder!.defaultBook!.readOnly.value;

    //logHolder.log('showOverlay: ${accModel.containerOffset.value}...', level: 6);

    //isVisible = getVisibility();
    return Visibility(
      visible: getVisibility(),
      child: Positioned(
        // left: realOffset.dx,
        // top: realOffset.dy,
        // height: realSize.height,
        // width: realSize.width,
        left: realOffset.dx - mouseMargin,
        top: realOffset.dy - mouseMargin,
        height: realSize.height + resizeButtonSize,
        width: realSize.width + resizeButtonSize,

        child: CrossPlatformClick(
          // 오른쪽 마우스 버튼 사용
          onPointerDown: onRightMouseButtonUp,
          child: isReadOnly
              ? GestureDetector(
                  onPanDown: (details) {
                    //onLongPressDown: (details) {
                    //logHolder.log("onLongPressDown(${accModel.mid})", level: 6);
                    selectContents(context, accModel.mid);
                  },
                  child: buildAccChild(context, mouseMargin, realSize, marginSize))
              : buildGesture(
                  context,
                  marginSize,
                  realSize,
                  ratio,
                  isAccSelected,
                  child: Stack(
                    children: [
                      buildAccChild(context, mouseMargin, realSize, marginSize),
                      buildCustomPaint(isAccSelected, realSize, marginSize),
                    ],
                  ),
                  //),
                ),
        ),
      ),
    );
  }

  dynamic onRightMouseButtonUp(BuildContext context, PointerDownEvent event) {
    logHolder.log('currentMid=${accModel.mid}', level: 5);
    String? currentMid = accManagerHolder!.getCurruntAccMid();
    if (currentMid == null || currentMid.isEmpty) {
      logHolder.log('currentMid=${accModel.mid} changed', level: 5);
      selectContents(context, accModel.mid);
    }
    showACCMenu(context, currentMid: accModel.mid);
  }

  void onDoubleClick() {
    logHolder.log('onDoubleTapDown', level: 5);
  }

  Widget buildGesture(
      BuildContext context, Size marginSize, Size realSize, Size ratio, bool isAccSelected,
      {required Widget child}) {
    return GestureDetector(
      //onDoubleTap: onDoubleClick,
      //onLongPressDown: (details) {
      onPanDown: (details) {
        //logHolder.log("onPanDown(${accModel.mid})", level: 5);

        //saveManagerHolder!.blockAutoSave();
        if (isCorners(details.localPosition, marginSize, resizeButtonSize) ||
            isRadius(details.localPosition, marginSize, resizeButtonSize / 2, realSize)) {
          accManagerHolder!.setCurrentMid(accModel.mid);
          return;
        }
        selectContents(context, accModel.mid);
        if (accModel.animeType.value == AnimeType.enlarge) {
          AbsAnime? anime = AbsAnime.get(accModel.mid);
          if (anime != null) {
            anime.action(realSize);
          }
        }
        accManagerHolder!.unshowMenu(context);
        //saveManagerHolder!.delayedReleaseAutoSave(500);
      },
      onPanStart: (details) {
        saveManagerHolder!.blockAutoSave(); // 자동 Save 를 막는다.
        actionStart = true;
        logHolder.log('onPanStart:${details.localPosition}', level: 1);
        //if (isCorners(details.localPosition, realSize, resizeButtonSize)) {
        if (isCorners(details.localPosition, marginSize, resizeButtonSize)) {
          isHover = false;
          isCornered = true;
          isRadiused = false;
          sizeActionStart = true;
          //} else if (isRadius(details.localPosition, realSize, resizeButtonSize / 4)) {
        } else if (isRadius(details.localPosition, marginSize, resizeButtonSize / 2, realSize)) {
          isRadiused = true;
          isHover = false;
          isCornered = false;
          radiusActionStart = true;
        } else {
          isCornered = false;
          isRadiused = false;
          isHover = true;
          sizeActionStart = true;
          radiusActionStart = false;
        }
        logHolder.log('onPanStart : ${details.localPosition}');
        mychangeStack.startTrans();
        //entry!.markNeedsBuild();
        accManagerHolder!.unshowMenu(context);
      },
      onPanUpdate: (details) {
        double dx = (details.delta.dx / ratio.width);
        double dy = (details.delta.dy / ratio.height);
        if (!resizeWidget(dx, dy, realSize, ratio, isAccSelected)) {
          if (_validationCheck(false, dx, dy, cursor, isAccSelected, ratio)) {
            _setContainerOffset(Offset((accModel.containerOffset.value.dx + dx),
                (accModel.containerOffset.value.dy + dy)));
            accManagerHolder!.notifyAsync();
          }
        }
        entry!.markNeedsBuild();
        //logHolder.log("accModel.accType = ${accModel.accType}", level: 5);
        if (accModel.accType == ACCType.text) {
          accChild.playManager.invalidate();
        }
      },
      onPanEnd: (details) async {
        await saveManagerHolder!.releaseAutoSave(); // 자동 Save를 풀어준다.
        actionStart = false;
        sizeActionStart = false;
        radiusActionStart = false;
        logHolder.log('onPanEnd:', level: 1);
        mychangeStack.endTrans();
        accManagerHolder!.notify();
        // if (accModel.accType == ACCType.text) {
        //   accChild.playManager.invalidate();
        // }
      },
      child: child,
    );
  }

  Widget buildAccChild(BuildContext context, double mouseMargin, Size realSize, Size marginSize) {
    //logHolder.log("buildAccChild ${accModel.glassFill.value}", level: 5);
    return Padding(
      padding: EdgeInsets.all(mouseMargin),
      child: Transform.rotate(
        angle: accModel.contentRotate.value ? 0 : accModel.rotate.value * (pi / 180),
        child: Opacity(
          // 만약 유리질일 경우에는 Opacity 객체를 사용해서는 안된다.
          // 테스트도 opacity 를 사용하지 않는다.
          opacity: accModel.glassFill.value > 0 || accModel.accType == ACCType.text
              ? 1
              : accModel.opacity.value,
          child: Stack(children: [
            glassMorphic(
              glass: accModel.glassFill.value,
              child: myNeumorphicButton(
                boxShape: _getBoxShape(realSize),
                borderColor: accModel.borderColor.value,
                borderWidth: accModel.borderWidth.value,
                intensity: accModel.intensity.value,
                lightSource: accModel.lightSource.value,
                depth: accModel.depth.value,
                //bgColor: accModel.bgColor.value.withOpacity(accModel.opacity.value),
                bgColor: (accModel.glassFill.value > 0 || accModel.accType == ACCType.text) &&
                        accModel.bgColor.value != Colors.transparent
                    ? accModel.bgColor.value.withOpacity(accModel.opacity.value)
                    : accModel.bgColor.value,
                onPressed: () {
                  // readOnly case 에서만 이부분이 호출된다.
                  logHolder.log('myNeumorphicButton onPressed', level: 5);
                  selectContents(context, accModel.mid);
                },
                child: Transform.rotate(
                  angle: accModel.contentRotate.value ? accModel.rotate.value * (pi / 180) : 0,
                  child: accChild,
                ),
              ),
            ),
            Visibility(
              visible: accManagerHolder!.orderVisible,
              child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                      height: realSize.height,
                      width: realSize.width,
                      color: Colors.white.withOpacity(0.5),
                      child: Center(
                          child: Text(
                        '${accModel.order.value}',
                        style: MyTextStyles.h3Eng,
                      )))),
            ),
            Visibility(
              visible: accModel.primary.value,
              child: const Icon(
                Icons.star,
                color: MyColors.mainColor,
                semanticLabel: 'Primary',
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget buildCustomPaint(bool isAccSelected, Size realSize, Size marginSize,
      {bool hasDropZone = true}) {
    return CustomPaint(
      painter: ResiablePainter(
          cursor,
          isAccSelected, //accManagerHolder!.isCurrentIndex(index),
          accModel.isFixedRatio.value,
          isInvisibleColorACC(),
          accModel.bgColor.value,
          //borderColor.value,
          accModel.resizable.value,
          realSize,
          isCornered,
          isRadiused,
          isHover,
          isCornerHover,
          isRadiusHover,
          accModel.radiusTopLeft.value,
          accModel.radiusTopRight.value,
          accModel.radiusBottomLeft.value,
          accModel.radiusBottomRight.value,
          accModel.accType),
      child: MouseRegion(
        opaque: false,
        onHover: (details) {
          //logHolder.log('Hover ${details.localPosition}',
          //    level: 1);
          //if (isCorners(details.localPosition, realSize, resizeButtonSize)) {
          if (isCorners(details.localPosition, marginSize, resizeButtonSize)) {
            isCornered = true;
            isRadiused = false;
            isHover = false;
            entry!.markNeedsBuild();
            //} else if (isRadius(details.localPosition, realSize, resizeButtonSize / 4)) {
          } else if (isRadius(details.localPosition, marginSize, resizeButtonSize / 2, realSize)) {
            isCornered = false;
            isRadiused = true;
            isHover = false;
            entry!.markNeedsBuild();
          } else {
            isCornered = false;
            isRadiused = false;
            if (!isHover) {
              isHover = true;
              entry!.markNeedsBuild();
            }
          }
        },
        onEnter: (details) {
          //logHolder.log('Enter ${details.localPosition}',
          //    level: 1);
          isHover = true;
          entry!.markNeedsBuild();
        },
        onExit: (details) {
          //logHolder.log('Exit', level: 1);
          if (!actionStart) {
            isHover = false;
            isCornered = false;
            isRadiused = false;
            clearCornerHover();
            entry!.markNeedsBuild();
          }
        },
        child: hasDropZone
            ? DropZoneWidget(
                accId: accModel.mid,
                onDroppedFile: (model) {
                  logHolder.log('contents added  ${model.mid}');
                  accChild.playManager.pushFromDropZone(this, model);
                  accChild.invalidate();
                },
              )
            : Container(),
      ),
    );
  }

  void selectContents(BuildContext context, String accMid, {int order = -1}) {
    if (order >= 0) {
      accChild.playManager.getModel(order: order).then((model) {
        if (model != null) {
          logHolder.log('Its contents click!!! ${model.mid}', level: 1);
          if (selectedModelHolder != null) selectedModelHolder!.setModel(model);
          if (pageManagerHolder != null) pageManagerHolder!.setAsContents();
          if (accManagerHolder != null) accManagerHolder!.setCurrentMid(accMid, setAsAcc: false);
          accChild.playManager.next(pause: true, until: order);
        } else {
          if (accManagerHolder != null) accManagerHolder!.setCurrentMid(accMid);
        }
        //_showACCMenu(context);
      });
    } else {
      accChild.playManager.getCurrentModel().then((model) {
        if (model != null) {
          logHolder.log('Its contents click!!! ${model.mid}', level: 5);
          if (selectedModelHolder != null) {
            selectedModelHolder!.setModel(model);
          }
          if (pageManagerHolder != null) pageManagerHolder!.setAsContents();
          if (accManagerHolder != null) accManagerHolder!.setCurrentMid(accMid, setAsAcc: false);
        } else {
          if (accManagerHolder != null) accManagerHolder!.setCurrentMid(accMid);
        }
        //_showACCMenu(context);
      });
    }
  }

  NeumorphicBoxShape _getBoxShape(Size realSize) {
    switch (accModel.boxType.value) {
      case BoxType.rountRect:
        return accModel.radiusAll.value == 0
            ? NeumorphicBoxShape.roundRect(BorderRadius.only(
                topLeft: Radius.circular(percentToRadius(accModel.radiusTopLeft.value, realSize)),
                topRight: Radius.circular(percentToRadius(accModel.radiusTopRight.value, realSize)),
                bottomLeft:
                    Radius.circular(percentToRadius(accModel.radiusBottomLeft.value, realSize)),
                bottomRight:
                    Radius.circular(percentToRadius(accModel.radiusBottomRight.value, realSize))))
            : NeumorphicBoxShape.roundRect(
                BorderRadius.circular(percentToRadius(accModel.radiusAll.value, realSize)));
      case BoxType.circle:
        return const NeumorphicBoxShape.circle();
      case BoxType.rect:
        return const NeumorphicBoxShape.rect();
      case BoxType.stadium:
        return const NeumorphicBoxShape.stadium();
      case BoxType.beveled:
        return NeumorphicBoxShape.beveled(BorderRadius.only(
            topLeft: Radius.circular(percentToRadius(accModel.radiusTopLeft.value, realSize)),
            topRight: Radius.circular(percentToRadius(accModel.radiusTopRight.value, realSize)),
            bottomLeft: Radius.circular(percentToRadius(accModel.radiusBottomLeft.value, realSize)),
            bottomRight:
                Radius.circular(percentToRadius(accModel.radiusBottomRight.value, realSize))));
      default:
        break;
    }
    return defaultBoxShape;
  }

  void invalidateContents() {
    //logHolder.log('invalidateContents');
    accChild.invalidate();
  }

  Future<void> pauseAllExceptCurrent() async {
    //logHolder.log('invalidateContents');
    await accChild.playManager.pauseAllExceptCurrent();
  }

  bool resizeWidget(double dx, double dy, Size realSize, Size ratio, bool isAccSelected) {
    if (dx == 0 && dy == 0) return false;

    switch (cursor) {
      case CursorType.neResize:
        return _sizeChanged(dx, dy, ratio, isAccSelected, 1);
      case CursorType.ncResize:
        return _sizeChanged(0, dy, ratio, isAccSelected, -1);
      case CursorType.nwResize:
        return _sizeChanged(dx, dy, ratio, isAccSelected, -1);
      case CursorType.mwResize:
        return _sizeChanged(dx, 0, ratio, isAccSelected, 1);
      case CursorType.swResize:
        return _sizeChanged(dx, dy, ratio, isAccSelected, 1);
      case CursorType.scResize:
        return _sizeChanged(0, dy, ratio, isAccSelected, 1);
      case CursorType.seResize:
        return _sizeChanged(dx, dy, ratio, isAccSelected, -1);
      case CursorType.meResize:
        return _sizeChanged(dx, 0, ratio, isAccSelected, -1);
      default:
        break;
    }
    return _radiusChanged(dx, dy, realSize);
  }

  bool _sizeChanged(double dx, double dy, Size ratio, bool isAccSelected, double fixedDirection) {
    double w = accModel.containerSize.value.width;
    double h = accModel.containerSize.value.height;
    double cx = accModel.containerOffset.value.dx;
    double cy = accModel.containerOffset.value.dy;

    bool isLimitW = false;
    bool isLimitH = false;
    if (accModel.isFixedRatio.value == true) {
      // dx,dy 중 크게 움직인 것에 따라 작게 움직인것의 비율이 결정된다.
      double ratio = w / h;
      double pageH = page!.height.value.toDouble();
      double pageW = page!.width.value.toDouble();

      if (dx.abs() >= dy.abs()) {
        // x좌표를 끌어당긴 경우
        dy = dx / ratio * fixedDirection;
        if (dy + cy + h > pageH) {
          // 한계에 부딧쳤기 때문에, 더 이상 값이 변할 수 없다.
          isLimitH = true;
        }
      } else {
        // y좌표를 끌어당긴 경우
        dx = dy * ratio * fixedDirection;
        if (dx + cx + w > pageW) {
          // 한계에 부딧쳤기 때문에, 더 이상 값이 변할 수 없다.
          isLimitW = true;
        }
      }
    }

    if (!_validationCheck(true, dx, dy, cursor, isAccSelected, ratio)) {
      return true;
    }

    Size afterSize = Size(w, h);
    Offset afterOffset = Offset(cx, cy);

    List<Size> afterSizeList = [
      Size((w - dx), (h - dy)), //ne
      Size(w + dx, (h - dy)), //nc
      Size((w + dx), (h - dy)), //nw
      Size((w + dx), h + dy), //mw
      Size((w + dx), (h + dy)), //sw
      Size(w + dx, (h + dy)), //sc
      Size((w - dx), (h + dy)), //se
      Size((w - dx), h + dy) //me
    ];

    List<Offset> afterOffsetList = [
      Offset((cx + dx), (cy + dy)), //ne
      Offset(cx, (cy + dy)), //nc
      Offset(cx, (cy + dy)), //nw
      Offset(cx, cy), //mw
      Offset(cx, cy), //sw
      Offset(cx, cy), //sc
      Offset((cx + dx), cy), //se
      Offset((cx + dx), cy), //me
    ];

    int i = 0;
    for (CursorType c in cursorList) {
      if (cursor == c) {
        afterSize = afterSizeList[i];
        afterOffset = afterOffsetList[i];
        break;
      }
      i++;
    }

    if (isLimitH && afterSize.height > accModel.containerSize.value.height) {
      return true;
    }
    if (isLimitW && afterSize.width > accModel.containerSize.value.width) {
      return true;
    }
    if (afterSize.width * ratio.width > minAccSize &&
        afterSize.height * ratio.height > minAccSize) {
      _setContainerOffsetAndSize(
          Offset(afterOffset.dx, afterOffset.dy), Size(afterSize.width, afterSize.height));
      accManagerHolder!.notifyAsync();
    }
    return true;
  }

  bool _radiusChanged(double dx, double dy, Size realSize) {
    double direction = 1;
    double newRadius = 0;
    switch (cursor) {
      case CursorType.neRadius:
        direction = (dx >= 0 && dy >= 0) ? 1 : -1;
        newRadius = accModel.radiusTopLeft.value;
        accModel.radiusAll.set(0);
        break;
      case CursorType.seRadius:
        direction = (dx >= 0 && dy <= 0) ? 1 : -1;
        newRadius = accModel.radiusBottomLeft.value;
        accModel.radiusAll.set(0);
        break;
      case CursorType.nwRadius:
        direction = (dx <= 0 && dy >= 0) ? 1 : -1;
        newRadius = accModel.radiusTopRight.value;
        accModel.radiusAll.set(0);
        break;
      case CursorType.swRadius:
        direction = (dx <= 0 && dy <= 0) ? 1 : -1;
        newRadius = accModel.radiusBottomRight.value;
        accModel.radiusAll.set(0);
        break;
      default:
        return false;
    }

    //newRadius += (dx.abs() + dy.abs()) * pi * direction;
    //newRadius += asin(dy.abs() / sqrt(dx * dx + dy * dy)) * (180 / pi) * direction;

    newRadius += getDeltaRadiusPercent(realSize, dx, dy, direction);

    if (newRadius < 0) newRadius = 0;
    if (newRadius > 100) newRadius = 100;

    switch (cursor) {
      case CursorType.neRadius:
        accModel.radiusTopLeft.set(newRadius);
        accManagerHolder!.notifyAsync();
        return true;
      case CursorType.seRadius:
        accModel.radiusBottomLeft.set(newRadius);
        accManagerHolder!.notifyAsync();
        return true;
      case CursorType.nwRadius:
        accModel.radiusTopRight.set(newRadius);
        accManagerHolder!.notifyAsync();
        return true;
      case CursorType.swRadius:
        accModel.radiusBottomRight.set(newRadius);
        accManagerHolder!.notifyAsync();
        return true;
      default:
        break;
    }
    return false;
  }

  bool isCorners(Offset point, Size widgetSize, double r) {
    for (int i = 0; i < 8; i++) {
      isCornerHover[i] = false;
    }
    List<Offset> centerList = ResiablePainter.getCornerCenters(widgetSize);
    int len = centerList.length;
    for (int i = 0; i < len; i++) {
      if (ResiablePainter.isCorner(point, centerList[i], r / 2)) {
        cursor = cursorList[i];
        isCornerHover[i] = true;
        return true;
      }
    }
    cursor = CursorType.move;
    return false;
  }

  bool isRadius(Offset point, Size widgetSize, double r, Size realSize) {
    for (int i = 0; i < 4; i++) {
      isRadiusHover[i] = false;
    }
    List<Rect> rectList = ResiablePainter.getRadiusRect(
        widgetSize,
        accModel.radiusTopLeft.value,
        accModel.radiusTopRight.value,
        accModel.radiusBottomRight.value,
        accModel.radiusBottomLeft.value,
        realSize);

    int i = 0;
    for (Rect rect in rectList) {
      if (ResiablePainter.isCorner(point, Offset(rect.left + r, rect.top + r), r)) {
        cursor = radiusList[i];
        isRadiusHover[i] = true;
        return true;
      }
      i++;
    }
    cursor = CursorType.move;
    return false;
  }

  double getDeltaRadiusPercent(Size realSize, double dx, double dy, double direction) {
    if (dx == 0 && dy == 0) return 0;

    //  움직인 거리를 구한후, Radius 를 퍼센트로 환산한 값을 구한다.
    // DB 에는 이 퍼센트값으로 저장된다.

    // height 가 짧은 직사각형으로 정규화한다.
    // 짧은 쪽이다.
    double height = realSize.height >= realSize.width ? realSize.width / 2 : realSize.height / 2;
    double maxR = sqrt(2) * height; //  rr = xx + yy 인데, x = y 이므로  rr = 2yy 이다.

    // 움직인 거리 move는
    double delta = sqrt(dx * dx + dy * dy);

    if (delta >= maxR) {
      return 100 * direction;
    }
    return (delta * 100) / maxR * direction;
  }

  double percentToRadius(double radiusPercent, Size realSize) {
    // height 가 짧은 직사각형으로 정규화한다.
    // 짧은 쪽이다.
    double height = realSize.height >= realSize.width ? realSize.width / 2 : realSize.height / 2;
    double maxR = sqrt(2) * height; //  rr = xx + yy 인데, x = y 이므로  rr = 2yy 이다.

    return (radiusPercent * maxR) / 100;
  }

  void clearCornerHover() {
    for (int i = 0; i < 8; i++) {
      isCornerHover[i] = false;
    }
    for (int i = 0; i < 4; i++) {
      isRadiusHover[i] = false;
    }
  }

  void notify() {
    logHolder.log("notify", level: 5);
    if (entry != null) {
      entry!.markNeedsBuild();
    } else {
      logHolder.log("Entry is null ${accModel.mid}", level: 6);
    }
  }

  Future<ContentsType> getCurrentContentsType() {
    return accChild.playManager.getCurrentContentsType();
  }

  Future<PlayState> getCurrentPlayState() {
    return accChild.playManager.getCurrentPlayState();
  }

  Future<Widget?> getCurrentVideoProgress() async {
    return await accChild.playManager.getCurrentVideoProgress();
  }

  Future<bool> getCurrentMute() {
    return accChild.playManager.getCurrentMute();
  }

  Future<double> getCurrentAspectRatio() {
    return accChild.playManager.getCurrentAspectRatio();
  }

  Future<bool> getCurrentDynamicSize() {
    return accChild.playManager.getCurrentDynmicSize();
  }

  Future<void> setCurrentDynamicSize(bool dynamicSize) async {
    await accChild.playManager.setCurrentDynmicSize(dynamicSize);
  }

  Future<void> next({bool pause = false}) async {
    await accChild.playManager.next(pause: pause);
  }

  Future<void> prev({bool pause = false}) async {
    await accChild.playManager.prev(pause: pause);
  }

  Future<void> pause({bool byManual = false}) async {
    await accChild.playManager.pause(byManual: byManual);
  }

  Future<void> mute() async {
    await accChild.playManager.mute();
  }

  Future<void> play({bool byManual = false}) async {
    await accChild.playManager.play(byManual: byManual);
  }

  void setBgColor(Color color) {
    accModel.bgColor.set(color);
    notify();
    accManagerHolder!.notifyAll();
  }

  bool _validationCheck(
      bool isSizeCheck, double dx, double dy, CursorType cursor, bool isAccSelected, Size ratio) {
    if (page == null) {
      return true;
    }

    Offset realOffset = getRealOffset();
    double realX = realOffset.dx;
    double realY = realOffset.dy;
    Size realSize = getRealSize();
    double realHeight = realSize.height; //-resizeButtonSize;
    double realWidth = realSize.width; //-resizeButtonSize;

    //CursorType newCursor = resetCornerPosition(rotate.value, cursor);

    double pageLeft = page!.origin.dx;
    double pageTop = page!.origin.dy;
    double pageRight = pageLeft + page!.realSize.width;
    double pageBottom = pageTop + page!.realSize.height;

    double border = accModel.borderWidth.value;
    double borderW = border * ratio.width;
    double borderH = border * ratio.height;

    double left = realX + dx + borderW;
    double top = realY + dy + borderH;
    double right = left + realWidth - (borderW * 2);
    double bottom = top + realHeight - (borderH * 2);

    List<bool> sizeConditions = [
      (dx < 0 && left < pageLeft) || (dy < 0 && top < pageTop), // neResize
      (dy < 0 && top < pageTop), // ncResize
      (dx > 0 && right > pageRight) || (dy < 0 && top < pageTop), // nwResize
      (dx > 0 && right > pageRight), // mwResize
      (dx > 0 && right > pageRight) || (dy > 0 && bottom > pageBottom), // swResize
      (dy > 0 && bottom > pageBottom), // scResize
      (dx < 0 && left < pageLeft) || (dy > 0 && bottom > pageBottom), // seResize
      (dx < 0 && left < pageLeft) // meResize
    ];

    int i = 0;
    if (isSizeCheck) {
      for (CursorType c in cursorList) {
        if (cursor == c) {
          if (sizeConditions[i]) {
            return false;
          }
        }
        i++;
      }

      // size validataion check
      switch (cursor) {
        case CursorType.nwResize:
        case CursorType.mwResize:
          if (realWidth + dx > page!.realSize.width) {
            return false;
          }
          break;
        case CursorType.scResize:
        case CursorType.seResize:
          if (realHeight + dy > page!.realSize.height) {
            return false;
          }
          break;
        case CursorType.swResize:
          if ((realWidth + dx > page!.realSize.width) ||
              (realHeight + dy > page!.realSize.height)) {
            return false;
          }
          break;
        default:
          break;
      }
      // if (realWidth + dx < minAccSize) {
      //   return false;
      // }
      // if (realHeight + dy < minAccSize) {
      //   return false;
      // }
    } else {
      List<bool> offsetConditions = [
        (dx < 0 && left < pageLeft),
        (dy < 0 && top < pageTop),
        (dx > 0 && right > pageRight),
        (dy > 0 && bottom > pageBottom),
      ];
      for (bool condition in offsetConditions) {
        if (condition) {
          return false;
        }
      }
      i++;
    }
    return true;
  }

  void toggleFullscreen() {
    accModel.fullscreen.set(!accModel.fullscreen.value);

    if (accModel.fullscreen.value) {
      Size pageSize = page!.getSize();

      _prevOffset = accModel.containerOffset.value;
      _prevSize = accModel.containerSize.value;
      _setContainerOffsetAndSize(const Offset(0, 0), pageSize);
      //containerOffset.set(start);
      //containerSize.set(pageSize);
    } else {
      _setContainerOffsetAndSize(_prevOffset, _prevSize);
      //containerOffset.set(_prevOffset);
      //containerSize.set(_prevSize);
    }
  }

  bool isFullscreen() {
    if (page != null) {
      if (accModel.containerSize.value.width.floor() == page!.width.value &&
          accModel.containerSize.value.height.floor() == page!.height.value) {
        accModel.fullscreen.set(true);
      } else {
        accModel.fullscreen.set(false);
      }
    }
    return accModel.fullscreen.value;
  }

  bool isInvisibleColorACC() {
    bool hasContents = false;
    if (accChild.playManager.isNotEmpty()) {
      hasContents = true;
    }
    if (hasContents) {
      return false;
    }
    // if (accModel.bgColor.value != Colors.transparent && accModel.bgColor.value != MyColors.pageBg) {
    //   return false;
    // }
    if (accModel.borderWidth.value > 0 &&
        accModel.borderColor.value != Colors.transparent &&
        accModel.borderColor.value != MyColors.pageBg) {
      return false;
    }
    return true;
  }

  // ratio 에 맞게 resize 한다.
  void resize(double ratio, {bool invalidate = true}) {
    // 원본에서 ratio = w / h 이다.
    //width 와 height 중 짧은 쪽을 기준으로 해서,
    // 반대편을 ratio 만큼 늘린다.
    if (ratio == 0) return;

    double w = accModel.containerSize.value.width;
    double h = accModel.containerSize.value.height;

    double pageHeight = page!.height.value.toDouble();
    double pageWidth = page!.width.value.toDouble();

    double dx = accModel.containerOffset.value.dx;
    double dy = accModel.containerOffset.value.dy;

    // ratio = w / h 이다.
    if (ratio >= 1) {
      // 콘텐츠의 가로가 더 길다.
      // 이 경우 페이지의 가로에 꽉차게 수정해준다.
      w = pageWidth;
      h = w / ratio;
      dx = 0;

      if (h > pageHeight) {
        h = pageHeight;
        w = h * ratio;
        dy = 0;
      }
      if (h == pageHeight) {
        dy = 0;
      }
    } else {
      // 콘텐츠의 세로가 더 길다.
      // 이 경우 페이지의 세로에 꽉차게 수정해준다.
      h = pageHeight;
      w = h * ratio;
      dy = 0;
      if (w > pageWidth) {
        w = pageWidth;
        h = w / ratio;
        dx = 0;
      }
      if (w == pageWidth) {
        dx = 0;
      }
    }

    mychangeStack.startTrans();
    accModel.containerOffset.set(Offset(dx, dy));
    accModel.containerSize.set(Size(w, h));
    mychangeStack.endTrans();

    if (invalidate) {
      notify();
    }
  }

  Future<void> resizeCurrent({bool invalidate = true}) async {
    double ratio = await getCurrentAspectRatio();
    if (ratio >= 0) {
      resize(ratio, invalidate: invalidate);
    }
  }

  bool hasContents() {
    //bool hasContents = false;
    if (accChild.playManager.isNotEmpty()) {
      return true;
    }
    return false;
  }

  void removeContents(String mid) {
    accChild.playManager.removeById(mid).then<bool>((value) {
      pageManagerHolder!.notify();
      accChild.invalidate();
      return value;
    });
  }
}
