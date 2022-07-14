// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:creta01/acc/acc_manager.dart';
import 'package:creta01/common/util/logger.dart';
import 'package:creta01/model/users.dart';
import 'package:creta01/studio/pages/page_manager.dart';
import 'package:creta01/studio/save_manager.dart';
import 'package:creta01/player/play_manager.dart';

import '../book_manager.dart';
import '../common/notifiers/notifiers.dart';
//import '../db/rt_page.dart';
import 'studio_sub_screen.dart';

StudioMainScreen? studioMainHolder;

// ignore: must_be_immutable
class StudioMainScreen extends StatefulWidget {
  const StudioMainScreen({required this.mainScreenKey, required this.user})
      : super(key: mainScreenKey);
  final GlobalKey<MainScreenState> mainScreenKey;
  //final GlobalKey<MainScreenState> mainScreenKey;

  final UserModel user;

  @override
  State<StudioMainScreen> createState() => MainScreenState();

  void invalidate() {
    if (mainScreenKey.currentState != null) {
      mainScreenKey.currentState!.invalidate();
    }
  }
}

class MainScreenState extends State<StudioMainScreen> {
  List<LogicalKeyboardKey> keys = [];
  GlobalKey<StudioSubScreenState> subScreenKey = GlobalKey<StudioSubScreenState>();
  bool isFullScreen = false;

  void invalidate() {
    setState(() {});
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
    //   logHolder.log('afterBuild StudioMainScreen', level: 1);
    //   if (accManagerHolder!.registerOverayAll(widget.mainScreenKey.currentState!.context)) {
    //     setState(() {});
    //   }
    //   saveManagerHolder!.initTimer();
    // });
  }

  @override
  Widget build(BuildContext context) {
    logHolder.log('build StudioMainScreen', level: 5);
    //pageManagerHolder = PageManager(bookManagerHolder!.defaultBook!.mid);
    //accManagerHolder = ACCManager();
    progressHolder = ProgressNotifier();
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider<ACCManager>.value(
        //   value: accManagerHolder!,
        // ),
        ChangeNotifierProvider<ACCManager>(create: (context) {
          accManagerHolder = ACCManager();
          return accManagerHolder!;
        }),
        // ChangeNotifierProvider<PageManager>.value(
        //   value: pageManagerHolder!,
        // ),
        ChangeNotifierProvider<PageManager>(create: (context) {
          pageManagerHolder = PageManager(bookManagerHolder!.defaultBook!.mid);
          return pageManagerHolder!;
        }),
        ChangeNotifierProvider<SelectedModel>(
          create: (context) {
            logHolder.log('ChangeNotifierProvider<SelectedModel>', level: 1);
            selectedModelHolder = SelectedModel();
            return selectedModelHolder!;
          },
        ),
        ChangeNotifierProvider<SaveManager>.value(
          value: saveManagerHolder!,
        ),
        ChangeNotifierProvider<BookManager>.value(
          value: bookManagerHolder!,
        ),
        // ChangeNotifierProvider<ProgressNotifier>.value(
        //   value: progressHolder!,
        // ),
        // ChangeNotifierProvider<RTPages>(
        //   create: (context) {
        //     logHolder.log('ChangeNotifierProvider<RTPages>', level: 1);
        //     return RTPages(bookManagerHolder!.defaultBook!.mid);
        //   },
        // ),
      ],
      // child: RawKeyboardListener(
      //   autofocus: true,
      //   focusNode: FocusNode(),
      //   onKey: keyEventHandler,
      child: StudioSubScreen(key: subScreenKey, user: widget.user),
      // child: Consumer<RTPages>(
      //   builder: ((context, snapshot, child) {
      //     logHolder.log("page foundeded", level: 5);
      //     pageManagerHolder!.pushPages(snapshot.pages);

      //     logHolder.log(
      //         "bookManagerHolder!.defaultBook!=${bookManagerHolder!.defaultBook!.mid}, ${bookManagerHolder!.defaultBook!.viewCount.value}",
      //         level: 5);
      //     bookManagerHolder!.defaultBook!.viewCount.set(
      //         bookManagerHolder!.defaultBook!.viewCount.value + 1,
      //         noUndo: true,
      //         dontChangeBookTime: true);
      // child: StreamBuilder(
      //     stream: RTDbActions.getPages(bookManagerHolder!.defaultBook!.mid),
      //     builder: (context, snapshot) {
      //       if (snapshot.hasError) {
      //         logHolder.log("snapshot.hasError", level: 6);
      //         pageManagerHolder!.createFirstPage();
      //         return errMsgWidget3(snapshot.error.toString());
      //       }
      //       if (snapshot.hasData == false) {
      //         logHolder.log("No data founded , first customer(1)", level: 6);
      //         return showWaitSign();
      //       }
      //       if (snapshot.data == null) {
      //         pageManagerHolder!.createFirstPage();
      //         return errMsgWidget3('data is null');
      //       }
      //       logHolder.log("page foundeded", level: 1);
      //       pageManagerHolder!.pushPages(snapshot.data! as List<PageModel>);

      //       logHolder.log(
      //           "bookManagerHolder!.defaultBook!=${bookManagerHolder!.defaultBook!.mid}, ${bookManagerHolder!.defaultBook!.viewCount.value}",
      //           level: 5);
      //       bookManagerHolder!.defaultBook!.viewCount.set(
      //           bookManagerHolder!.defaultBook!.viewCount.value + 1,
      //           noUndo: true,
      //           dontChangeBookTime: true);
      // child: FutureBuilder<List<PageModel>>(
      //     future: DbActions.getPages(bookManagerHolder!.defaultBook!.mid),
      //     builder: (context, AsyncSnapshot<List<PageModel>> snapshot) {
      //       if (snapshot.hasError) {
      //         //error가 발생하게 될 경우 반환하게 되는 부분
      //         logHolder.log("data fetch error", level: 6);
      //         return errMsgWidget(snapshot);
      //       }
      //       if (snapshot.hasData == false) {
      //         logHolder.log("No data founded", level: 6);
      //         return Container();
      //       } else if (snapshot.connectionState == ConnectionState.done) {
      //         logHolder.log("page founded ${snapshot.data!.length}", level: 1);
      //         if (snapshot.data!.isEmpty) {
      //           pageManagerHolder!.createFirstPage();
      //         } else {
      //           pageManagerHolder!.pushPages(snapshot.data!);
      //         }

      //         logHolder.log(
      //             "bookManagerHolder!.defaultBook!=${bookManagerHolder!.defaultBook!.mid}, ${bookManagerHolder!.defaultBook!.viewCount.value}",
      //             level: 5);
      //         bookManagerHolder!.defaultBook!.viewCount.set(
      //             bookManagerHolder!.defaultBook!.viewCount.value + 1,
      //             noUndo: true,
      //             dontChangeBookTime: true);
      //       }

      //return StudioSubScreen(key: subScreenKey, user: widget.user);
      //}),
      //),
    );
    //)
  }

  void keyEventHandler(RawKeyEvent event) {
    final key = event.logicalKey;
    logHolder.log('key pressed $key', level: 5);
    if (event is RawKeyDownEvent) {
      if (keys.contains(key)) return;
      // textField 의 focus bug 때문에, delete  key 를 사용할 수 없다.
      // if (event.isKeyPressed(LogicalKeyboardKey.delete)) {
      //   logHolder.log('delete pressed');
      //   accManagerHolder!.removeACC(context);
      // }
      if (event.isKeyPressed(LogicalKeyboardKey.tab)) {
        logHolder.log('tab pressed');
        accManagerHolder!.nextACC(context);
      }
      if (event.isKeyPressed(LogicalKeyboardKey.f9)) {
        setState(() {
          logHolder.showLog = !logHolder.showLog;
        });
      }
      if (event.isKeyPressed(LogicalKeyboardKey.f10)) {
        logHolder.log("F10 pressed", level: 5);
        isFullScreen = !isFullScreen;
        subScreenKey.currentState!.setFullScreen(isFullScreen);
      }
      if (event.isKeyPressed(LogicalKeyboardKey.pageDown)) {
        if (pageManagerHolder != null) {
          pageManagerHolder!.next(context);
        }
        logHolder.log("pageDown pressed", level: 5);
      }
      if (event.isKeyPressed(LogicalKeyboardKey.pageUp)) {
        if (pageManagerHolder != null) {
          pageManagerHolder!.prev(context);
        }
        logHolder.log("pageUp pressed", level: 5);
      }
      keys.add(key);
      // Ctrl Key Area
      if ((keys.contains(LogicalKeyboardKey.controlLeft) ||
          keys.contains(LogicalKeyboardKey.controlRight))) {
        if (keys.contains(LogicalKeyboardKey.keyZ)) {
          logHolder.log('Ctrl+Z pressed');
          // undo
          accManagerHolder!.undo(null, context);
        } else if (keys.contains(LogicalKeyboardKey.keyY)) {
          logHolder.log('Ctrl+Y pressed');
          // redo
          accManagerHolder!.redo(null, context);
        } else if (keys.contains(LogicalKeyboardKey.keyC)) {
          logHolder.log('Ctrl+C pressed');
          // Copy
        } else if (keys.contains(LogicalKeyboardKey.keyV)) {
          logHolder.log('Ctrl+V pressed');
          // Paste
        }
      }
    } else {
      keys.remove(key);
    }
  }
}
