// ignore_for_file: use_build_context_synchronously

import 'package:creta01/book_manager.dart';
import 'package:creta01/creta_main.dart';
import 'package:creta01/studio/save_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:creta01/acc/acc_manager.dart';
import 'package:creta01/common/util/logger.dart';
import 'package:creta01/common/buttons/basic_button.dart';
import 'package:creta01/constants/styles.dart';
import 'package:creta01/studio/pages/page_manager.dart';
import 'package:creta01/studio/save_manager.dart';
import 'package:creta01/constants/constants.dart';

//import '../common/buttons/toggle_switch.dart';
import '../acc/acc_menu.dart';
import '../common/util/my_utils.dart';
import '../constants/strings.dart';
import '../model/model_enums.dart';
import '../model/users.dart';
import 'artboard/artboard_frame.dart';
import 'pages/pages_frame.dart';
import 'properties/properties_frame.dart';
import 'sidebar/my_widget_menu.dart';
import 'sidebar/sidebar.dart';

// ignore: must_be_immutable
class StudioSubScreen extends StatefulWidget {
  final UserModel user;
  bool isFullScreen = false;
  bool isEditMode = true;

  StudioSubScreen({required Key key, required this.user}) : super(key: key);

  @override
  State<StudioSubScreen> createState() => StudioSubScreenState();
}

class StudioSubScreenState extends State<StudioSubScreen> {
  bool isPlayed = false;

  void setFullScreen(bool f) {
    setState(() {
      logHolder.log("setFullScreen($f)", level: 5);
      widget.isFullScreen = f;
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      logHolder.log('afterBuild StudioSubScreen', level: 5);
      //if (accManagerHolder!.registerOverayAll(context)) {
      //setState(() {});
      saveManagerHolder!.initSaveTimer();
      saveManagerHolder!.initUploadTimer();
      //}
    });
  }

  @override
  void deactivate() {
    logHolder.log('deactivate StudioSubScreen', level: 6);
    if (accManagerHolder != null) {
      accManagerHolder!.unshowMenu(context);
      accManagerHolder!.destroyEntry(context);
    }
    super.deactivate();
  }

  @override
  void dispose() {
    logHolder.log('dispose StudioSubScreen', level: 6);
    if (saveManagerHolder != null) {
      saveManagerHolder!.stopTimer();
    }
    // if (accManagerHolder != null) {
    //   accManagerHolder!.unshowMenu(context);
    //   accManagerHolder!.destroyEntry(context);
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logHolder.log('build StudioSubScreen', level: 5);

    if (widget.isFullScreen) {
      return SafeArea(
          // child: Expanded(
          child: ArtBoardScreen(
        key: GlobalKey<ArtBoardScreenState>(),
        isFullScreen: true,
      ));
    }
    return Consumer<BookManager>(builder: (context, bookManager, child) {
      logHolder.log('Consumer<BookManager>', level: 5);
      return Scaffold(
        //key: context.read<MenuController>().scaffoldKey,
        appBar: buildAppBar(bookManager),
        //drawer: const SideMenu(),
        body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          bool isNarrow = (constraints.maxWidth <= minWindowWidth);
          bool isShort =
              (constraints.maxHeight <= (isNarrow ? minWindowHeight : minWindowHeight / 2));
          logHolder.log('LayoutBuilder()', level: 5);
          return SafeArea(
            child: Stack(children: [
              isNarrow ? narrowLayout(isShort, bookManager) : wideLayout(isShort, bookManager),
              SideBar(user: widget.user),
            ]),
            // child: Column(children: [
            //   Expanded(
            //     flex: 9,
            //     child: Stack(children: [
            //       isNarrow ? narrowLayout(isShort) : wideLayout(isShort),
            //       SideBar(user: widget.user),
            //     ]),
            //   ),
            //   logHolder.showLog ? DebugBar(key: logHolder.veiwerKey) : const SizedBox(height: 1),
            // ]),
          );
        }),
      );
    });
  }

  Widget wideLayout(bool isShort, BookManager bookManager) {
    logHolder.log('wideLayout()', level: 5);
    if (isShort) {
      return Container();
    }
    bool isReadOnly = bookManager.defaultBook!.readOnly.value;
    logHolder.log('wideLayout($isReadOnly)', level: 5);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // We want this side menu only for large screen
        isReadOnly
            ? Container()
            : const SizedBox(
                width: layoutPageWidth,
                child: PagesFrame(isNarrow: false),
              ),
        Expanded(
          child: //ArtBoardScreen(),
              Stack(
            children: [
              Consumer<ACCManager>(builder: (context, saveManager, child) {
                return Container(); // accManagerHolder 를 new 하기 위한 dummy consumer
              }),
              //Expanded(child: ArtBoardScreen(key: GlobalKey<ArtBoardScreenState>())),
              ArtBoardScreen(key: GlobalKey<ArtBoardScreenState>()),
              // const SizedBox(height: 40, child: SaveIndicator()),
              Consumer<SaveManager>(builder: (context, saveManager, child) {
                return FutureBuilder(
                    future: saveManagerHolder!.getProgress(),
                    builder: (BuildContext context, AsyncSnapshot<ProgressState> snapshot) {
                      if (snapshot.hasData == false) {
                        //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
                        return Container();
                      }
                      if (snapshot.hasError) {
                        //error가 발생하게 될 경우 반환하게 되는 부분
                        logHolder.log('FutureBuilder InProgressType error ', level: 6);
                        return Container();
                      }
                      logHolder.log('SaveIndicatorState...${snapshot.data!.toString()}', level: 1);
                      ProgressState state = snapshot.data!;

                      return SizedBox(height: 40, child: SaveIndicator(state: state));
                    });
              }),
            ],
          ),
        ),
        isReadOnly == false
            ? SizedBox(
                width: layoutPropertiesWidth,
                child: PropertiesFrame(isNarrow: false),
              )
            : Container()
      ],
    );
  }

  Widget narrowLayout(bool isShort, BookManager bookManager) {
    if (isShort) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // We want this side menu only for large screen
        const SizedBox(
          height: 200,
          child: PagesFrame(isNarrow: true),
        ),
        const Expanded(
          child: ArtBoardScreen(),
        ),
        SizedBox(
          height: 240,
          child: PropertiesFrame(isNarrow: false),
        ),
      ],
    );
  }

  PreferredSizeWidget buildAppBar(BookManager bookManager) {
    bool isNarrow = MediaQuery.of(context).size.width <= minWindowWidth;
    bool isReadOnly = bookManager.isReadOnly();
    double maxLeadingSize = 400;
    return AppBar(
      backgroundColor: MyColors.appbar,
      title: Center(
        child: Text(
          bookManager.defaultBook!.name.value,
          style: MyTextStyles.h5,
        ),
      ),
      leadingWidth: isNarrow ? 200 : maxLeadingSize,
      leading: isNarrow
          ? logoIcon()
          : isReadOnly
              ? appBarLeadingReadOnly()
              : appBarLeading(),
      actions: isNarrow ? [] : appBarAction(200),
    );
  }

  Widget logoIcon() {
    return IconOnlyButton(
        iconPath: "assets/logo_en.png",
        padding: const EdgeInsets.only(left: 15, right: 10),
        width: 110,
        height: 50,
        onPressed: () {
          goBackHome(context);
        });
  }

  Future<void> goBackHome(BuildContext context) async {
    if (saveManagerHolder != null) {
      ProgressState prgState = await saveManagerHolder!.getProgress();
      InProgressType prgType = prgState.progressType;
      if (InProgressType.done != prgType) {
        String msg = inProgressTypeToMsg(prgType);
        showSlimDialog(context, "$msg ${MyStrings.tryNextTime}", bgColor: Colors.white);
        return;
        //await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    // if (accManagerHolder != null) {
    //   accManagerHolder!.unshowMenu(context);
    //   accManagerHolder!.destroyEntry(context);
    // }
    if (youtubeDialog != null) {
      youtubeDialog!.closeDialog(context);
    }
    if (youtubeEditDialog != null) {
      youtubeEditDialog!.closeDialog(context);
    }
    naviPop(context);
    cretaMainHolder!.invalidate();
  }

  Widget appBarLeading() {
    return Row(children: [
      logoIcon(),
      IconButton(
        icon: const Icon(Icons.undo),
        onPressed: () {
          accManagerHolder!.undo(null, context);
          pageManagerHolder!.notify();
        },
      ),
      IconButton(
          onPressed: () {
            accManagerHolder!.redo(null, context);
            pageManagerHolder!.notify();
          },
          icon: const Icon(Icons.redo)),
      IconButton(onPressed: () {}, icon: const Icon(Icons.zoom_in)),
      IconButton(onPressed: () {}, icon: const Icon(Icons.zoom_out)),
      // ToggleSwitch(
      //   minHeight: 30.0,
      //   minWidth: 80.0,
      //   initialLabelIndex: widget.isEditMode ? 0 : 1,
      //   cornerRadius: 20.0,
      //   radiusStyle: true,
      //   activeFgColor: MyColors.puple100,
      //   inactiveBgColor: MyColors.puple100,
      //   inactiveFgColor: MyColors.puple600,
      //   totalSwitches: 2,
      //   labels: [MyStrings.editMode, MyStrings.viewMode],
      //   //icons: [Icons.stay_current_landscape, Icons.stay_current_portrait],
      //   activeBgColors: const [
      //     [MyColors.puple600],
      //     [MyColors.puple600]
      //   ],
      //   onToggle: (index) {
      //     logHolder.log('toggle button pressed = $index');
      //     widget.isEditMode = (index == 0);
      //     accManagerHolder!.notify();;
      //   },
      // ),

      //appBarTitle(400),
      //IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
    ]);
  }

  Widget appBarLeadingReadOnly() {
    return Row(children: [
      logoIcon(),
      IconButton(
          onPressed: () {
            if (pageManagerHolder != null) {
              setState(() {
                pageManagerHolder!.prev(context);
              });
            }
          },
          icon: const Icon(
            Icons.skip_previous_outlined,
            semanticLabel: "previos page",
          )),
      Text('${pageManagerHolder!.getPageIndex()} / ${pageManagerHolder!.getPageCount()}'),
      IconButton(
        icon: const Icon(Icons.skip_next_outlined),
        onPressed: () {
          if (pageManagerHolder != null) {
            setState(() {
              pageManagerHolder!.next(context);
            });
          }
        },
      ),

      iconWithText(
          text: MyStrings.editMode,
          iconImage: "assets/Publish.png",
          onPressed: () {
            bookManagerHolder!.defaultBook!.readOnly.set(false);
            bookManagerHolder!.notify();
            accManagerHolder!.notifyAll();
            accManagerHolder!.unshowMenu(context);
          }),

      //IconButton(onPressed: () {}, icon: const Icon(Icons.zoom_in)),
      //IconButton(onPressed: () {}, icon: const Icon(Icons.zoom_out)),
    ]);
  }

  Widget appBarTitle(double width) {
    return SizedBox(
      width: width,
      child: GestureDetector(
          onTapDown: (details) {},
          child: MouseRegion(
            onHover: (event) {},
            onExit: (event) {},
            child: Text(
              bookManagerHolder!.defaultBook!.name.value,
              style: MyTextStyles.h5,
            ),
          )),
    );
  }

  List<Widget> appBarAction(double width) {
    return [
      SizedBox(
        width: width,
      ),
      ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(MyColors.primaryColor),
          //foregroundColor: MaterialStateProperty.all(MyColors.critical),
        ),
        onPressed: () {
          setState(() {
            isPlayed = !isPlayed;
          });
        },
        child: Icon(isPlayed ? Icons.pause_presentation : Icons.slideshow),
      ),
      iconWithText(text: 'publish', iconImage: "assets/Publish.png", onPressed: () {}),
      ElevatedButton(
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(MyColors.primaryColor)),
        onPressed: () {
          pageManagerHolder!.setAsSettings();
        },
        child: const Icon(Icons.settings),
      ),
    ];
  }
}
