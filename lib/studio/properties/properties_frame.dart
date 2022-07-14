// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, must_be_immutable, prefer_const_literals_to_create_immutables

//import 'package:flutter/cupertino.dart';
//import 'package:creta01/acc/acc_manager.dart';
import 'package:creta01/studio/properties/property_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/rendering.dart';
import 'package:creta01/studio/pages/page_manager.dart';
//import 'package:creta01/studio/save_manager.dart';
//import 'package:creta01/acc/acc_manager.dart';
//import 'package:creta01/studio/properties/page_property.dart';
import 'package:creta01/constants/styles.dart';
import 'package:creta01/model/pages.dart';
import 'package:creta01/model/model_enums.dart';
import 'package:creta01/common/util/logger.dart';

import '../../common/buttons/toggle_switch.dart';
import '../../common/undo/undo.dart';
import '../../constants/strings.dart';
import '../../player/play_manager.dart';

//import 'package:creta01/constants/strings.dart';

class PropertiesFrame extends StatefulWidget {
  final bool isNarrow;

  PropertiesFrame({Key? key, required this.isNarrow}) : super(key: key);

  @override
  State<PropertiesFrame> createState() => PropertiesFrameState();
}

class PropertiesFrameState extends State<PropertiesFrame> {
  PageModel? selectedPage;

  bool isLandscape = true;
  bool isSizeChangable = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    selectedPage = pageManagerHolder!.getSelected();
    if (selectedPage != null) {
      isLandscape = (selectedPage!.width.value >= selectedPage!.height.value);
    }
  }

  void invalidate() {
    logHolder.log('setState of properties frame');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // final TextStyle _segmentTextStyle =
    //     Theme.of(context).textTheme.caption ?? const TextStyle(fontSize: 12);

    // const Color _thumbColor = CupertinoDynamicColor.withBrightness(
    //   color: Color(0xFFFFFFFF),
    //   darkColor: Color(0xFF636366),
    // );

    // final Color? _thumbOnColor =
    //     ThemeData.estimateBrightnessForColor(_thumbColor) == Brightness.light
    //         ? Colors.black
    //         : Colors.white;

    return SafeArea(child: Consumer<PageManager>(builder: (context, pageManager, child) {
      _init();
      PropertySelector selector = PropertySelector.fromManager(
        pageManager: pageManager,
        selectedPage: selectedPage,
        isNarrow: widget.isNarrow,
        isLandscape: isLandscape,
        parent: this,
      );

      int selectedTab = propertyTypeToInt(pageManager.propertyType);
      selectedTab = selectedTab > 3 ? 3 : selectedTab;
      return Container(
        color: MyColors.white,
        child: Stack(children: [
          Padding(
            padding: EdgeInsets.only(
                left: 2, right: 2, bottom: 2, top: (pageManager.isSettings() ? 2 : 28)),
            child: Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                border: Border(
                  left:
                      BorderSide(width: 3, color: MyColors.primaryColor, style: BorderStyle.solid),
                  top: BorderSide(width: 3, color: MyColors.primaryColor, style: BorderStyle.solid),
                  right:
                      BorderSide(width: 3, color: MyColors.primaryColor, style: BorderStyle.solid),
                  bottom:
                      BorderSide(width: 3, color: MyColors.primaryColor, style: BorderStyle.solid),
                ),
              ),
              child: Stack(
                children: [
                  selector,
                  // Consumer<PageManager>(builder: (context, pageManager, child) {
                  //   _init();
                  //   PropertySelector selector = PropertySelector.fromManager(
                  //     pageManager: pageManager,
                  //     selectedPage: selectedPage,
                  //     isNarrow: widget.isNarrow,
                  //     isLandscape: isLandscape,
                  //     parent: this,
                  //   );
                  //   return selector;
                  // }),
                  // Consumer<ACCManager>(builder: (context, pageManager, child) {
                  //   // Dummy Consumer : 컨슈머가 late 하게 만들이지면 Provider 가 초기화가 안되기 때문에
                  //   //  더미 Consumber 를 하나 만들어 둔다.
                  //   //logHolder.log('Consumer of dummy accManager');
                  //   return Container();
                  // }),
                  Consumer<SelectedModel>(builder: (context, selectedModel, child) {
                    // Dummy Consumer : 컨슈머가 late 하게 만들이지면 Provider 가 초기화가 안되기 때문에
                    //  더미 Consumber 를 하나 만들어 둔다.
                    //logHolder.log('Consumer of dummy accManager');
                    return Container();
                  }),
                  // Consumer<SaveManager>(builder: (context, selectedModel, child) {
                  //   // Dummy Consumer : 컨슈머가 late 하게 만들이지면 Provider 가 초기화가 안되기 때문에
                  //   //  더미 Consumber 를 하나 만들어 둔다.
                  //   //logHolder.log('Consumer of dummy saveManager');
                  //   return Container();
                  // }),
                ],
              ),
            ),
          ),
          pageManager.isSettings()
              ? Container()
              : Container(
                  alignment: AlignmentDirectional.center,
                  height: 60,
                  //padding: const EdgeInsets.only(left: 10, top: 12),
                  child: Center(
                    child: ToggleSwitch(
                      minHeight: 36.0,
                      minWidth: 80.0,
                      initialLabelIndex: selectedTab,
                      cornerRadius: 8.0,
                      radiusStyle: true,
                      activeFgColor: Colors.black,
                      inactiveBgColor: MyColors.puple100,
                      inactiveFgColor: MyColors.puple600,
                      totalSwitches: 4,
                      labels: [
                        MyStrings.bookPropTitle,
                        MyStrings.pagePropTitle,
                        MyStrings.widgetPropTitle,
                        MyStrings.contentsPropTitle,
                      ],
                      // icons: [
                      //   Icons.import_contacts_outlined,
                      //   Icons.auto_stories_outlined,
                      //   Icons.widgets
                      // ],
                      activeBgColor: [
                        MyColors.primaryColor,
                        MyColors.primaryColor,
                        MyColors.primaryColor,
                        MyColors.primaryColor,
                      ],
                      borderColor: [
                        MyColors.primaryColor,
                        MyColors.primaryColor,
                        MyColors.primaryColor,
                        MyColors.primaryColor,
                      ],
                      borderWidth: 1,
                      onToggle: (index) {
                        //setState(() {
                        mychangeStack.startTrans();
                        switch (index) {
                          case 0:
                            pageManagerHolder!.setAsBook();
                            isSizeChangable = false;
                            break;
                          case 1:
                            pageManagerHolder!.setAsPage();
                            isSizeChangable = false;
                            break;
                          case 2:
                            pageManagerHolder!.setAsAcc();
                            isSizeChangable = false;
                            break;
                          case 3:
                            pageManagerHolder!.setAsContents();
                            isSizeChangable = false;
                            break;
                          default:
                            break;
                        }
                        mychangeStack.endTrans();
                      },
                    ),
                  ),
                ),
        ]),
      );
    }));
  }
}
