// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'dart:async';

import 'package:creta01/book_manager.dart';
import 'package:creta01/db/db_actions.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

//import 'bloc.navigation_bloc/navigation_bloc.dart';
import '../../common/buttons/basic_button.dart';
import '../../common/util/textfileds.dart';
import '../../constants/strings.dart';
import '../../db/rtdb_actions.dart';
import 'menu_item.dart' as my_menu;
import '../../common/util/logger.dart';
import '../../constants/styles.dart';
//import '../../db/creta_db.dart';
import '../../model/users.dart';
import 'package:creta01/common/util/my_utils.dart';

class SideBar extends StatefulWidget {
  final UserModel user;
  const SideBar({Key? key, required this.user}) : super(key: key);

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> with SingleTickerProviderStateMixin<SideBar> {
  AnimationController? _animationController;
  StreamController<bool>? isSidebarOpenedStreamController;
  Stream<bool>? isSidebarOpenedStream;
  StreamSink<bool>? isSidebarOpenedSink;
  final _animationDuration = const Duration(milliseconds: 500);

  bool _saveAsMode = false;
  bool _aleadyExist = false;
  final TextEditingController _saveAsController = TextEditingController();

  //sbool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: _animationDuration);
    isSidebarOpenedStreamController = PublishSubject<bool>();
    isSidebarOpenedStream = isSidebarOpenedStreamController!.stream;
    isSidebarOpenedSink = isSidebarOpenedStreamController!.sink;
  }

  @override
  void dispose() {
    _animationController!.dispose();
    isSidebarOpenedStreamController!.close();
    isSidebarOpenedSink!.close();
    super.dispose();
  }

  void onIconPressed() {
    logHolder.log('onIconPressed');
    final animationStatus = _animationController!.status;
    final isAnimationCompleted = animationStatus == AnimationStatus.completed;

    if (isAnimationCompleted) {
      isSidebarOpenedSink!.add(false);
      _animationController!.reverse();
    } else {
      isSidebarOpenedSink!.add(true);
      _animationController!.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    //const double screenWidth = 300;

    const double menuWidth = 320;
    const double clipWidth = 24;
    const double clipHeight = 90;

    String userName = 'Unknown';
    String email = 'Unknown';
    late List<dynamic> userList;

    return StreamBuilder(
        stream: RTDbActions.getUser(widget.user.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            logHolder.log("snapshot.hasError", level: 6);
            return errMsgWidget3(snapshot.error.toString());
          }
          if (snapshot.hasData == false) {
            logHolder.log("No data founded , first customer(1)", level: 6);
            return showWaitSign();
          }
          if (snapshot.data == null) {
            return errMsgWidget3('data is null');
          }
          userList = snapshot.data! as List<UserModel>;
          userName = (userList[0] as UserModel).name;
          email = (userList[0] as UserModel).id;

          // return FutureBuilder(
          //     future: CretaDB('creta_user').getData(widget.user.id),
          //     future: RTDbActions.getUser(widget.user.id),
          //     builder: (context, snapshot) {
          //       if (snapshot.hasData == false) {
          //         //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
          //         return showWaitSign();
          //       }
          //       if (snapshot.hasError) {
          //         //error가 발생하게 될 경우 반환하게 되는 부분
          //         return errMsgWidget2(snapshot);
          //       }
          //       userList = snapshot.data as List;
          //       if (userList.isNotEmpty) {
          //         logHolder.log("${widget.user.id} is not found");
          //         userName = userList[0]["name"];
          //         email = userList[0]["id"];
          //       }

          return StreamBuilder<bool>(
            initialData: false,
            stream: isSidebarOpenedStream,
            builder: (context, isSideBarOpenedAsync) {
              return AnimatedPositioned(
                //width: 400,
                duration: _animationDuration,
                top: 0,
                bottom: 0,
                left: isSideBarOpenedAsync.data! ? 0 : -(menuWidth - clipWidth),
                right:
                    isSideBarOpenedAsync.data! ? screenWidth - menuWidth : screenWidth - clipWidth,
                //left: isSideBarOpenedAsync.data! ? 0 : -screenWidth,
                //right: isSideBarOpenedAsync.data! ? 0 : 500,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: MyColors.primaryColor.withOpacity(0.8),
                        child: Column(
                          children: <Widget>[
                            GestureDetector(
                              onLongPressDown: (details) {
                                //logHolder.log("onLongPressDown", level: 6);
                                setState(() {});
                                //_isEditMode = true;
                              },
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CircleAvatar(
                                    backgroundImage: AssetImage(
                                      'assets/pilot.PNG',
                                    ),
                                    radius: 60,
                                  ),
                                  Text(
                                    userName,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    email,
                                    style: MyTextStyles.body1,
                                  ),
                                  Divider(
                                    height: 32,
                                    thickness: 0.5,
                                    color: Colors.white.withOpacity(0.3),
                                    indent: 32,
                                    endIndent: 32,
                                  ),
                                ],
                              ),
                            ),
                            ...menuList(),
                            //...(_isEditMode ? userInfoEditList() : menuList()),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0, -0.999),
                      child: GestureDetector(
                        onTap: () {
                          onIconPressed();
                        },
                        child: ClipPath(
                          clipper: CustomMenuClipper(),
                          child: Container(
                            width: clipWidth,
                            height: clipHeight,
                            color: MyColors.primaryColor.withOpacity(0.5),
                            alignment: Alignment.centerLeft,
                            child: AnimatedIcon(
                              progress: _animationController!.view,
                              icon: AnimatedIcons.menu_close,
                              color: MyColors.secondaryColor,
                              size: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  List<Widget> userInfoEditList() {
    return [
      Container(
        height: 400,
        color: Colors.amber,
      )
    ];
  }

  List<Widget> menuList() {
    return [
      my_menu.MenuItem(
        icon: Icons.create_new_folder,
        title: MyStrings.newBook,
        onTap: () {
          onIconPressed();
          //BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.homePageClickedEvent);
        },
      ),
      my_menu.MenuItem(
        icon: Icons.folder_open,
        title: MyStrings.open,
        onTap: () {
          onIconPressed();
          //BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.myAccountClickedEvent);
        },
      ),
      my_menu.MenuItem(
        onTap: () {},
        icon: Icons.last_page,
        title: MyStrings.recent,
      ),
      my_menu.MenuItem(
        onTap: () {},
        icon: Icons.paste,
        title: MyStrings.bring,
      ),
      Divider(
        height: 32,
        thickness: 0.5,
        color: Colors.white.withOpacity(0.3),
        indent: 32,
        endIndent: 32,
      ),
      my_menu.MenuItem(
        onTap: () {
          DbActions.saveAll();
        },
        icon: Icons.save,
        title: MyStrings.save,
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          my_menu.MenuItem(
              onTap: () {
                setState(() {
                  _saveAsMode = !_saveAsMode;
                });
              },
              icon: Icons.save_outlined,
              title: MyStrings.makeCopy),
          Visibility(
              visible: _saveAsMode,
              child: Column(
                children: [
                  myTextField(
                    bookManagerHolder!.defaultBook!.name.value,
                    hasBorder: true,
                    labelText: 'input new name',
                    controller: _saveAsController,
                    hasDeleteButton: false,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    basicButton(
                        name: MyStrings.apply,
                        onPressed: () {
                          _aleadyExist = !bookManagerHolder!.makeCopy(_saveAsController.text);
                          setState(() {
                            if (!_aleadyExist) {
                              _saveAsMode = !_saveAsMode;
                            }
                          });
                        },
                        iconData: Icons.done_outlined),
                    SizedBox(
                      width: 5,
                    ),
                    basicButton(
                        name: MyStrings.cancel,
                        onPressed: () {
                          setState(() {
                            _saveAsMode = !_saveAsMode;
                          });
                        },
                        iconData: Icons.close_outlined),
                  ]),
                  SizedBox(height: 10),
                  _aleadyExist ? Text(MyStrings.alreadyExist) : SizedBox(height: 5),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ))
        ],
      ),
      my_menu.MenuItem(
        onTap: () {},
        icon: Icons.send,
        title: MyStrings.publish,
      ),
      Divider(
        height: 32,
        thickness: 0.5,
        color: Colors.white.withOpacity(0.3),
        indent: 32,
        endIndent: 32,
      ),
      my_menu.MenuItem(
        onTap: () {},
        icon: Icons.book,
        title: MyStrings.bookPropChange,
      ),
    ];
  }

  bool makeCopy() {
    if (bookManagerHolder!.makeCopy(_saveAsController.text)) {
      return false; // not already exist
    }
    return true; // already exist
  }
}

class CustomMenuClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Paint paint = Paint();
    paint.color = Colors.white;

    final width = size.width;
    final height = size.height;

    Path path = Path();
    path.moveTo(0, 0);

    path.quadraticBezierTo(0, 8, 10, 16);
    path.quadraticBezierTo(width - 1, height / 2 - 20, width, height / 2);
    path.quadraticBezierTo(width - 1, height / 2 + 20, 10, height - 16);
    path.quadraticBezierTo(0, height - 8, 0, height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
