// ignore_for_file: prefer_const_constructors
import 'package:creta01/acc/youtube_dialog.dart';
//import 'package:creta01/common/undo/undo.dart';
import 'package:creta01/model/contents.dart';
import 'package:flutter/material.dart';

import 'package:creta01/common/buttons/basic_button.dart';
import 'package:creta01/common/buttons/hover_buttons.dart';
import 'package:creta01/constants/styles.dart';
import 'package:creta01/constants/constants.dart';
import 'package:creta01/constants/strings.dart';
import 'package:creta01/common/util/my_text.dart';
import 'package:creta01/common/util/my_utils.dart';
import 'package:creta01/common/util/logger.dart';

import 'package:creta01/acc/acc_manager.dart';
import 'package:creta01/acc/acc.dart';
import 'package:creta01/studio/pages/page_manager.dart';

//import '../../book_manager.dart';
import '../../book_manager.dart';
import '../../model/model_enums.dart';

YoutubeDialog? youtubeDialog;

class MenuModel {
  //complex drawer menu
  final IconData icon;
  final String title;
  final List<String> submenus;
  void Function()? onPressed;
  final String? iconFile;

  MenuModel(this.icon, this.title, this.submenus, {this.iconFile});
}

class MyMenuStick extends StatefulWidget {
  final bool isVisible;

  const MyMenuStick({required Key key, this.isVisible = true}) : super(key: key);

  @override
  MyMenuStickState createState() => MyMenuStickState();
}

const double narrowWidth = 55;
const double wideWidth = 160;
const double subWidth = 125;

class MyMenuStickState extends State<MyMenuStick> {
  int selectedIndex = -1; //dont set it to 0
  bool isExpanded = false;
  bool isSubMenuOpen = false;

  //static int _keyIdx = 0;

  static List<MenuModel> menuModelList = [
    // MenuModel(Icons.grid_view, "Control", []),
    MenuModel(Icons.dashboard_customize_outlined, MyStrings.frame, []),
    MenuModel(Icons.rtt_outlined, MyStrings.text, []),
    MenuModel(Icons.auto_fix_high_outlined, MyStrings.effect, []),
    MenuModel(Icons.military_tech_outlined, MyStrings.badge, []),
    MenuModel(Icons.videocam_outlined, MyStrings.camera, []),
    MenuModel(Icons.wb_sunny_outlined, MyStrings.weather, []),
    MenuModel(Icons.schedule_outlined, MyStrings.clock, []),
    MenuModel(Icons.music_note, MyStrings.music, []),
    MenuModel(Icons.feed_outlined, MyStrings.news, []),
    MenuModel(Icons.brush, MyStrings.brush, []),
    MenuModel(
      Icons.add,
      MyStrings.youtube,
      [],
      iconFile: "assets/youtube.png",
    ),
  ];

  static void createACC(BuildContext context, ContentsModel model) {
    ACC acc = accManagerHolder!.createACC(context, pageManagerHolder!.getSelected()!);
    model.parentMid.set(acc.accModel.mid);
    acc.accChild.playManager.push(acc, model);
  }

  @override
  void initState() {
    super.initState();
    menuModelList[0].onPressed = framePressed;
    menuModelList[1].onPressed = textPressed;
    menuModelList[2].onPressed = effectPressed;
    menuModelList[3].onPressed = badgePressed;
    menuModelList[4].onPressed = cameraPressed;
    menuModelList[5].onPressed = weatherPressed;
    menuModelList[6].onPressed = clockPressed;
    menuModelList[7].onPressed = musicPressed;
    menuModelList[8].onPressed = newsPressed;
    menuModelList[9].onPressed = brushPressed;
    menuModelList[10].onPressed = youtubePressed;
  }

  @override
  Widget build(BuildContext context) {
    bool isReadOnly = bookManagerHolder!.defaultBook!.readOnly.value;
    return Visibility(
      visible: widget.isVisible && !isReadOnly,
      child: Positioned(
        left: layoutPageWidth + 12,
        top: 80,
        child: Material(
          type: MaterialType.card,
          color: Colors.transparent,
          child: frostedEdged(
            sigma: 10.0,
            radius: 8.0,
            //child: Padding(
            //padding: const EdgeInsets.only(left: 12, top: 10),
            child:
                // isReadOnly
                //     ? SizedBox(
                //         width: wideWidth,
                //         height: 75,
                //         // 읽기 전용일 경우
                //         //padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                //         child: myCheckBox(MyStrings.editMode, !isReadOnly, () {
                //           if (bookManagerHolder!.toggleReadOnly()) {
                //             setState(() {});
                //           }
                //         }, 18, 2, 8, 2),
                //       )
                //     :
                Container(
                    // decoration: simpleDeco(
                    //     8.0, 0.5, Colors.white.withOpacity(0.2), MyColors.white),
                    height: 620,
                    width: isExpanded
                        ? wideWidth
                        : isSubMenuOpen
                            ? narrowWidth + subWidth
                            : narrowWidth,
                    color: Colors.white.withOpacity(0.5),
                    child: row() //MyColors.compexDrawerCanvasColor,
                    ),
            //),
          ),
        ),
      ),
    );
  }

  Widget row() {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      isExpanded ? expandedMenu() : smallMenu(),
      isSubMenuOpen ? invisibleSubMenus() : Container(),
    ]);
  }

  Widget expandedMenu() {
    return Container(
      width: wideWidth,
      color: MyColors.complexDrawerBlack,
      child: Column(
        children: [
          controlTile(),
          Expanded(
            child: ListView.builder(
              itemCount: menuModelList.length,
              itemBuilder: (BuildContext context, int index) {
                //  if(index==0) return controlTile();

                MenuModel menuModel = menuModelList[index];

                return Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10),
                  child: menuModel.iconFile == null
                      ? HoverButton.withIconData(
                          hoverSize: 32,
                          width: 45,
                          height: 45,
                          onPressed: () {
                            setState(() {
                              isSubMenuOpen = menuModelList[index].submenus.isNotEmpty;
                              selectedIndex = index;
                            });
                            menuModel.onPressed!.call();
                          },
                          text: menuModel.title,
                          iconData: menuModel.icon,
                          iconColor: MyColors.mainColor,
                          iconHoverColor: MyColors.primaryText,
                          onEnter: () {},
                          onExit: () {})
                      : HoverButton.withIconWidget(
                          hoverSize: 32,
                          width: 45,
                          height: 45,
                          onPressed: () {
                            setState(() {
                              isSubMenuOpen = menuModelList[index].submenus.isNotEmpty;
                              selectedIndex = index;
                            });
                            menuModel.onPressed!.call();
                          },
                          text: menuModel.title,
                          iconFile: menuModel.iconFile,
                          onEnter: () {},
                          onExit: () {}),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget controlTile() {
    // return Padding(
    //   padding: const EdgeInsets.only(top: 15, left: 15),
    //   child: HoverButton.withIconWidget(
    //       hoverSize: 32,
    //       width: 45,
    //       height: 45,
    //       onPressed: () {
    //         expandOrShrinkDrawer.call();
    //       },
    //       text: "Widgets",
    //       iconWidget: logoIcon2(size: 40),
    //       onEnter: () {},
    //       onExit: () {}),
    // );

    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 15),
      child: Row(
        children: [
          IconButton(
            icon: logoIcon2(size: 60),
            padding: const EdgeInsets.all(0),
            onPressed: expandOrShrinkDrawer,
          ),
          Text("Widgets", style: MyTextStyles.body1)
        ],
      ),
    );
  }

  Widget smallMenu() {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      width: narrowWidth,
      color: MyColors.complexDrawerBlack,
      child: Column(
        children: [
          controlButton(), // 최상단 버튼,
          Expanded(
            child: ListView.builder(
                itemCount: menuModelList.length,
                itemBuilder: (contex, index) {
                  MenuModel menuModel = menuModelList[index];

                  return Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: menuModel.iconFile == null
                        ? HoverButton.withIconData(
                            hoverSize: 32,
                            width: 45,
                            height: 45,
                            onPressed: () {
                              setState(() {
                                isSubMenuOpen = menuModel.submenus.isNotEmpty;
                                selectedIndex = index;
                              });
                              menuModel.onPressed!.call();
                            },
                            iconData: menuModel.icon,
                            iconColor: MyColors.mainColor,
                            iconHoverColor: MyColors.primaryText,
                            onEnter: () {},
                            onExit: () {})
                        : HoverButton.withIconWidget(
                            hoverSize: 32,
                            width: 45,
                            height: 45,
                            onPressed: () {
                              setState(() {
                                isSubMenuOpen = menuModelList[index].submenus.isNotEmpty;
                                selectedIndex = index;
                              });
                              menuModel.onPressed!.call();
                            },
                            iconFile: menuModel.iconFile,
                            onEnter: () {},
                            onExit: () {}),
                  );

                  // return InkWell(
                  //   onTap: () {
                  //     setState(() {
                  //       isSubMenuOpen = menuModelList[index].submenus.isNotEmpty;
                  //       selectedIndex = index;
                  //     });
                  //   },
                  //   child: Container(
                  //     height: 45,
                  //     alignment: Alignment.center,
                  //     child:
                  //         Icon(menuModelList[index].icon, color: MyColors.primaryText),
                  //   ),
                  // );
                }),
          ),
        ],
      ),
    );
  }

  Widget invisibleSubMenus() {
    // List<MenuModel> _cmds = menuModelList..removeAt(0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: isExpanded ? 0 : subWidth,
      color: Colors.transparent, //MyColors.compexDrawerCanvasColor,
      child: Column(
        children: [
          Container(height: 95),
          Expanded(
            child: ListView.builder(
                itemCount: menuModelList.length,
                itemBuilder: (context, index) {
                  MenuModel cmd = menuModelList[index];
                  // if(index==0) return Container(height:95);
                  //controll button has 45 h + 20 top + 30 bottom = 95

                  bool selected = selectedIndex == index;
                  bool isValidSubMenu = selected && cmd.submenus.isNotEmpty;
                  return subMenuWidget([cmd.title, ...cmd.submenus], isValidSubMenu);
                }),
          ),
        ],
      ),
    );
  }

  Widget controlButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 15),
      child: InkWell(
        onTap: expandOrShrinkDrawer,
        child: Container(
          height: 45,
          alignment: Alignment.center,
          child: logoIcon2(size: 60),
          //FlutterLogo(size: 40,),
        ),
      ),
    );
  }

  Widget subMenuWidget(List<String> submenus, bool isValidSubMenu) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: isValidSubMenu ? submenus.length.toDouble() * 37.5 : 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: isValidSubMenu ? MyColors.complexDrawerBlueGrey : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          )),
      child: ListView.builder(
          padding: const EdgeInsets.all(6),
          itemCount: isValidSubMenu ? submenus.length : 0,
          itemBuilder: (context, index) {
            String subMenu = submenus[index];
            return sMenuButton(subMenu, index == 0);
          }),
    );
  }

  Widget sMenuButton(String subMenu, bool isTitle) {
    return InkWell(
      onTap: () {
        //handle the function
        //if index==0? donothing: doyourlogic here
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Txt(
          text: subMenu,
          fontSize: isTitle ? 17 : 14,
          color: isTitle ? MyColors.primaryText : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void expandOrShrinkDrawer() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void framePressed() {
    logHolder.log('frame Pressed');
    accManagerHolder!.createACC(context, pageManagerHolder!.getSelected()!);
  }

  void textPressed() {
    ACC acc = accManagerHolder!
        .createACC(context, pageManagerHolder!.getSelected()!, accType: ACCType.text);
    String initialText = MyStrings.inputText;
    // String initialText = "Look at you (yeah) 넌 못 감당해 날 (uh)"
    //     "기분은 coke like brr"
    //     "Look at my toe, 나의 ex 이름 tattoo"
    //     "I got to drink up now, 니가 싫다 해도 좋아 (ah!)"
    //     "Why are you cranky, boy?"
    //     "뭘 그리 찡그려 너"
    //     "Do you want a blond barbie doll?"
    //     "It's not here, I'm not a doll (like this if you can)"
    //     "미친 연이라 말해, what's the loss to me? Ya"
    //     "사정없이 까보라고 you'll lose to me ya"
    //     "사랑 그깟 거 따위 내 몸에 상처 하나도 어림없지"
    //     "너의 썩은 내 나는 향수나 뿌릴 바엔"
    //     "Yeah, I'm fu- tomboy"
    //     "(Uh, ah, uh)"
    //     "Yeah, I'll be the tomboy"
    //     "(Uh, ah)"
    //     "This is my attitude"
    //     "Yeah, I'll be the tomboy"
    //     "That's why"
    //     "I don't wanna play this ping pong"
    //     "I would rather film a TikTok"
    //     "Your mom raised you as a prince"
    //     "But this is queendom, right?"
    //     "I like dancing, I love my friends"
    //     "Sometimes we swear without cigarettes"
    //     "I like to eh, on drinking whiskey"
    //     "I won't change it, what the hell?"
    //     "미친 척이라 말해, what's the loss to me? Ya"
    //     "사정없이 씹으라고 you're lost to me ya"
    //     "사랑 그깟 거 따위 내 눈에 눈물 한 방울 어림없지"
    //     "너의 하찮은 말에 미소나 지을 바엔";
    int textSize = getStringSize(initialText);
    String name = shortenText(initialText);
    ContentsModel model = ContentsModel(acc.accModel.mid,
        name: name, mime: 'text/', bytes: textSize, url: initialText);

    model.remoteUrl = initialText;
    model.playTime.set(playTimeForever); // 영구히로 할당한다.
    model.parentMid.set(acc.accModel.mid);
    model.fontSize.set(36);

    //double width = acc.page!.width.value * 0.6;   // 1152
    //double height = width * (1 / 8);  // 144
    int lineCount = 1;
    double fontRatio = 1.0;
    double width = model.fontSize.value * textSize;
    double maxWidth = acc.page!.width.value * 0.9;
    double maxHeight = acc.page!.height.value * 0.9;
    if (width > maxWidth) {
      // width 를 줄이고 줄바꿈이 들어가야 한다.
      lineCount = (width / maxWidth).ceil(); //올림 2가 최소가 된다.
      width = maxWidth;
    } // 1152
    double height = (lineCount + 1) * model.fontSize.value * 2.6;
    if (height > maxHeight) {
      logHolder.log('height=$height, maxHeight=$maxHeight', level: 5);
      fontRatio = maxHeight / height;
      height = maxHeight;
      // 위젯에서 폰트 사이즈를 자동 조정하므로, 여기서는 자동조정하지 않는다.
      // if (model.isAutoAlign.value == true) {
      //   model.fontSize.set(model.fontSize.value * fontRatio);
      //   height = (lineCount + 1) * model.fontSize.value * 2.6;
      // }
    }

    logHolder.log('text Pressed $width, $height, $textSize, $lineCount, $fontRatio', level: 5);

    acc.accModel.containerSize.set(Size(width, height), save: false, noUndo: true);
    acc.accModel.accType = ACCType.text;
    acc.accModel.bgColor.set(Colors.transparent);
    acc.accChild.playManager.push(acc, model);
  }

  void effectPressed() {
    logHolder.log('effect Pressed');
  }

  void badgePressed() {
    logHolder.log('badge Pressed');
  }

  void cameraPressed() {
    logHolder.log('camera Pressed');
  }

  void weatherPressed() {
    logHolder.log('weather Pressed');
  }

  void clockPressed() {
    logHolder.log('clock Pressed');
  }

  void musicPressed() {
    logHolder.log('music Pressed');
  }

  void newsPressed() {
    logHolder.log('news Pressed');
  }

  void brushPressed() {
    logHolder.log('brush Pressed');
  }

  void youtubePressed() {
    logHolder.log('youtube Pressed....', level: 5);

    youtubeDialog ??= YoutubeDialog(
      onCancel: () {
        // if (acc.accChild.playManager.isEmpty()) {
        //   acc.accModel.isRemoved.set(true);
        //   accManagerHolder!.notify();;
        // }
      },
      onOK: (currentYoutubeInfo, orderMap, oldACC) async {
        ACC? acc;
        if (oldACC != null) {
          acc = oldACC;
        } else {
          acc = accManagerHolder!
              .createACC(context, pageManagerHolder!.getSelected()!, accType: ACCType.youtube);
          acc.accModel.isFixedRatio.set(true);
          acc.resizeCurrent();
        }
        ContentsModel model = ContentsModel(acc.accModel.mid,
            name: currentYoutubeInfo.title,
            mime: 'youtube/html',
            bytes: 0,
            url: currentYoutubeInfo.videoId);

        youtubeDialog!.apply(acc, model);
        // ContentsModel model = ContentsModel(acc.accModel.mid,
        //     name: currentYoutubeInfo.title,
        //     mime: 'youtube/html',
        //     bytes: 0,
        //     url: currentYoutubeInfo.videoId);

        // String subList = "[";
        // for (YoutubeInfo info in orderMap.values) {
        //   if (subList.length > 2) {
        //     subList += ",";
        //   }
        //   subList += info.serialize();
        // }
        // subList += "]";
        // subList.replaceAll('\n', '').replaceAll('\r', '');

        // model.subList.set(subList);

        // logHolder.log("subList=$subList", level: 5);
        // logHolder.log("thumbnail=${currentYoutubeInfo.thumbnail}", level: 5);

        // model.remoteUrl = currentYoutubeInfo.videoId;
        // model.thumbnail = currentYoutubeInfo.thumbnail;
        // model.videoPlayTime.set(currentYoutubeInfo.playTime);

        // acc.accModel.accType = ACCType.youtube;
        // await acc.accChild.playManager.pushFromDropZone(acc, model);
        // acc.accChild.invalidate();

        // bookManagerHolder!
        //     .setBookThumbnail(model.thumbnail!, ContentsType.image, model.aspectRatio.value);
      },
    );
    youtubeDialog!.clearInfo();
    youtubeDialog!.show(context);
  }
}
