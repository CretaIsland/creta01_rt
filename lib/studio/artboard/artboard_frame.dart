// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

//import 'package:creta01/studio/properties/properties_frame.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:creta01/constants/styles.dart';
import 'package:creta01/acc/acc_manager.dart';
import 'package:creta01/studio/pages/page_manager.dart';
import 'package:creta01/model/pages.dart';
import 'package:creta01/common/util/logger.dart';
import 'package:creta01/common/drag_and_drop/drop_zone_widget.dart';

//import 'package:creta01/common/cursor/cursor_manager.dart';
import 'package:creta01/studio/sidebar/my_widget_menu.dart';

OverlayEntry? stickMenuEntry;

class ArtBoardScreen extends StatefulWidget {
  final bool isFullScreen;

  const ArtBoardScreen({Key? key, this.isFullScreen = false}) : super(key: key);

  @override
  State<ArtBoardScreen> createState() => ArtBoardScreenState();
}

class ArtBoardScreenState extends State<ArtBoardScreen> {
  double pageRatio = 9 / 16;
  double width = 0;
  double height = 0;
  double pageHeight = 0;
  double pageWidth = 0;

  Widget? _menuStick;
  Offset mousePosition = Offset.zero;

  //int _page = 0;
  final GlobalKey<MyMenuStickState> _widgetMenuKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    onPageSelected(pageManagerHolder!.getSelected());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      registerStickMenuOverlay(context);
    });
  }

  @override
  void dispose() {
    if (stickMenuEntry != null) {
      stickMenuEntry!.remove();
      stickMenuEntry = null;
    }
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
    if (widget.isFullScreen == false) stickMenuEntry!.markNeedsBuild();
  }

  void onPageSelected(PageModel? selectedPage) {
    if (selectedPage != null) {
      //logHolder.log('onPageSelected ${selectedPage.mid}', level: 5);
      pageRatio = selectedPage.getRatio();
      //Size realSize = selectedPage.getRealSize();
      //logHolder.log('onPageSelected ${selectedPage.mid}, $realSize', level: 5);
    }
  }

  Widget registerStickMenuOverlay(BuildContext context) {
    logHolder.log('registerMenuStickOverlay', level: 5);
    if (stickMenuEntry == null) {
      stickMenuEntry = OverlayEntry(builder: (context) {
        _menuStick = MyMenuStick(
          key: _widgetMenuKey,
          isVisible: !(widget.isFullScreen),
        );
        return _menuStick!;
      });
      final overlay = Overlay.of(context)!;
      overlay.insert(stickMenuEntry!);
    }
    if (_menuStick != null) {
      return _menuStick!;
    }
    return Container(color: Colors.red);
  }

  @override
  Widget build(BuildContext context) {
    logHolder.log("ArtBoardScreenState", level: 5);
    return Consumer<PageManager>(builder: (context, pageManager, child) {
      onPageSelected(pageManager.getSelected());

      return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        width = constraints.maxWidth * (widget.isFullScreen ? 1 : (7 / 8));
        height = constraints.maxHeight * (widget.isFullScreen ? 1 : (7 / 8));

        if (pageRatio > 1) {
          // 세로형
          pageHeight = height;
          pageWidth = pageHeight * (1 / pageRatio);
          if (height > width) {
            if (pageWidth > width) {
              pageWidth = width;
              pageHeight = pageWidth * pageRatio;
            }
          }
        } else {
          // 가로형
          pageWidth = width;
          pageHeight = pageWidth * pageRatio;
          if (height < width) {
            if (pageHeight > height) {
              pageHeight = height;
              pageWidth = pageHeight * (1 / pageRatio);
            }
          }
        }
        logHolder.log("ab:pageWidth=$pageWidth, pageHeight=$pageHeight");

        PageModel? model = pageManagerHolder!.getSelected();
        if (model == null) return Container();
        logHolder.log("build ArtBoardScreen", level: 5);
        return SafeArea(
          child: Container(
            padding: EdgeInsets.only(left: (widget.isFullScreen ? 0 : 20)),
            color: MyColors.bgColor,
            alignment: Alignment.center,
            child: Container(
              // real page area
              key: model.key,
              height: pageHeight,
              width: pageWidth,
              color: pageManagerHolder == null || pageManagerHolder!.getSelected() == null
                  ? MyColors.bgColor
                  : pageManagerHolder!.getSelected()!.bgColor.value,
              child: GestureDetector(
                onPanDown: (details) {
                  if (pageManagerHolder != null && accManagerHolder != null) {
                    accManagerHolder!.setCurrentMid('');
                    accManagerHolder!.notifyAll();
                    logHolder.log('artboard onPanDown : ${details.localPosition}', level: 5);
                    accManagerHolder!.unshowMenu(context);
                    pageManagerHolder!.setAsPage();
                  }
                },
                child: DropZoneWidget(
                  accId: '',
                  onDroppedFile: (model) {
                    logHolder.log('contents added ${model.mid}', level: 1);
                    model.isDynamicSize.set(true); // 동영상에 맞게 frame size 를 조절하라는 뜻
                    MyMenuStickState.createACC(context, model);
                    //accChild.playManager.push(this, model);
                  },
                ),
              ),
            ),
          ),

          // child: SingleChildScrollView(
          //   padding: const EdgeInsets.all(defaultPadding),
          //   child: Container(
          //     color: MyColors.white,
          //   ),
          // ),
        );
      });
    });
  }

  // ignore: non_constant_identifier_names
  Future<dynamic> ShowCapturedWidget(BuildContext context, Uint8List capturedImage) {
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text("Captured widget screenshot"),
        ),
        body: Center(child: capturedImage.isNotEmpty ? Image.memory(capturedImage) : Container()),
      ),
    );
  }
}
