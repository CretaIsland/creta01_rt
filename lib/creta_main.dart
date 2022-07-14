// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:creta01/book_sliver_grid.dart';
import 'package:creta01/constants/constants.dart';
import 'package:creta01/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:creta01/common/util/logger.dart';
import 'package:creta01/model/users.dart';

import 'book_manager.dart';
import 'common/buttons/basic_button.dart';
import 'common/buttons/hover_buttons.dart';
import 'common/util/my_utils.dart';
import 'db/rtdb_actions.dart';
import 'main_util.dart';
import 'model/book.dart';
import 'studio/save_manager.dart';

CretaMainScreen? cretaMainHolder;

// ignore: must_be_immutable
class CretaMainScreen extends StatefulWidget {
  const CretaMainScreen({required this.mainScreenKey, required this.user})
      : super(key: mainScreenKey);

  final UserModel user;
  final GlobalKey<CretaMainScreenState> mainScreenKey;

  void invalidate() {
    mainScreenKey.currentState!.invalidate();
  }

  @override
  State<CretaMainScreen> createState() => CretaMainScreenState();
}

class CretaMainScreenState extends State<CretaMainScreen> {
  final double titleHeight = 150;
  final double gridWidth = 328;
  final double gridTitle = 70;
  final double gridHeight = 140 + 70;

  final int maxCard = 48;

  //bool isEmptyCardHover = false;

  void invalidate() {
    setState(() {});
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    bookManagerHolder = BookManager();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      logHolder.log('afterBu!ild CretaMainScreen', level: 1);
      initLangMap(); // 자동번역을 위한 Language map 을 등록해 둔다.
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color getColor(
    int index,
  ) {
    final color = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple
    ];
    return color[index % color.length];
  }

  renderSliverAppbar(double height) {
    return SliverAppBar(
      title: Text('Creta'),
      expandedHeight: height,
      collapsedHeight: height / 4,
      pinned: true,
      // flexibleSpace: widget.book.thumbnailUrl != null
      //     ? Image.network(widget.book.thumbnailUrl!, fit: BoxFit.cover)
      //     : Image.asset('assets/creta_default.png', fit: BoxFit.cover),
    );
  }

  SliverList renderSliverList(double height) {
    // delegate 는 함수포인터가 온다.
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return Container(
          color: Colors.transparent,
          height: height,
        );
      }, childCount: 1),
    );
  }

  // Widget _emptyGridCard(int index) {
  //   return Card(
  //     color: Colors.white.withOpacity(0.2),
  //     //shadowColor: Colors.white,
  //     shape: RoundedRectangleBorder(
  //       side: const BorderSide(width: 1.0, color: Colors.white),
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     elevation: 8,
  //     child: Center(
  //         child: Icon(
  //       Icons.add_outlined,
  //       size: 100,
  //       color: Colors.grey,
  //     )),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    saveManagerHolder = SaveManager();
    return Scaffold(
      //key: context.read<MenuController>().scaffoldKey,
      //appBar: buildAppBar(),
      //drawer: const SideMenu(),
      body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        //bool isNarrow = (constraints.maxWidth <= minWindowWidth);
        //bool isShort =
        //    (constraints.maxHeight <= (isNarrow ? minWindowHeight : minWindowHeight / 2));

        //return SafeArea(
        //return
        //int count = 48;

        //double viewHeight = ((count / gridWidth) + 1) * gridHeight + listHeight + titleHeight;
        double marginHeight = constraints.maxHeight - titleHeight - (gridHeight * 1.2);

        // return FutureBuilder(
        //     future: DbActions.getMyBookList(widget.user.id),
        //     builder: (context, AsyncSnapshot<List<BookModel>> snapshot) {
        //       if (snapshot.hasError) {
        //         logHolder.log("snapshot.hasError", level: 6);
        //         return errMsgWidget(snapshot);
        //       }
        //       if (snapshot.hasData == false) {
        //         logHolder.log("No data founded , first customer(1)", level: 6);
        //         return showWaitSign();
        //       }
        //       if (snapshot.connectionState == ConnectionState.done) {
        //         logHolder.log("line 1");
        //         bookManagerHolder!.selectBook(snapshot.data!);
        //       }
        return StreamBuilder(
            stream: RTDbActions.getMyBook(widget.user.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                logHolder.log("snapshot.hasError", level: 6);
                return adminWidget(snapshot.error.toString());
              }
              if (snapshot.hasData == false) {
                logHolder.log("No data founded , first customer(1)", level: 6);
                return showWaitSign();
              }
              if (snapshot.data == null) {
                return errMsgWidget3('data is null');
              }
              bookManagerHolder!.selectBook(snapshot.data! as List<BookModel>);
              logHolder.log("data founded", level: 5);
              return Stack(
                children: [
                  // 배경
                  SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    //child: Image.asset('assets/creta_default.png', fit: BoxFit.cover),
                    child: Stack(
                      children: [
                        MainUtil.drawBackground(constraints.maxWidth, constraints.maxHeight,
                            bookManagerHolder!.defaultBook!),
                        Container(
                          decoration: BoxDecoration(
                            //color: Colors.black.withOpacity(0.4),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Colors.black.withOpacity(0.8),
                                  Colors.black.withOpacity(0.7),
                                  Colors.black.withOpacity(0.6),
                                  Colors.black.withOpacity(0.5),
                                  Colors.black.withOpacity(0.3),
                                  Colors.black.withOpacity(0.2),
                                  Colors.black.withOpacity(0.1),
                                  Colors.black.withOpacity(0.0),
                                  Colors.black.withOpacity(0.0),
                                  Colors.black.withOpacity(0.0),
                                  Colors.black.withOpacity(0.0),
                                  Colors.black.withOpacity(0.0),
                                ]),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            //color: Colors.black.withOpacity(0.4),
                            gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.center,
                                colors: [
                                  Colors.black.withOpacity(0.9),
                                  Colors.black.withOpacity(0.8),
                                  Colors.black.withOpacity(0.7),
                                  Colors.black.withOpacity(0.4),
                                  Colors.black.withOpacity(0.3),
                                  Colors.black.withOpacity(0.2),
                                  Colors.black.withOpacity(0.1),
                                  Colors.black.withOpacity(0.0),
                                  Colors.black.withOpacity(0.0),
                                  Colors.black.withOpacity(0.0),
                                  Colors.black.withOpacity(0.0),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 리스트
                  Container(
                    padding: EdgeInsets.only(top: titleHeight, left: 600, right: 30),
                    color: Colors.transparent,
                    child: CustomScrollView(
                      slivers: [
                        //renderSliverAppbar(appHeight),
                        renderSliverList(marginHeight), // 마진 부위
                        BookSliverGrid(
                          gridHeight: gridHeight,
                          gridWidth: gridWidth,
                          user: widget.user,
                          maxCard: maxCard,
                        ),
                      ],
                    ),
                  ),
                  // 상단 영역
                  SizedBox(
                      //color: Colors.white.withOpacity(0.1),
                      width: constraints.maxWidth,
                      height: titleHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 로고
                          Container(
                              //color: Colors.white,
                              padding: EdgeInsets.only(left: 103, top: 81),
                              child: Image.asset('assets/logo_en.png',
                                  fit: BoxFit.cover, width: 230, height: 60)),
                          // 우측 상단 메뉴
                          Container(
                            alignment: Alignment.topRight,
                            padding: EdgeInsets.only(right: 20, top: 17),
                            //color: Colors.yellow,
                            child: Row(
                              children: [
                                // New Button
                                // Container(
                                //   child: basicButton2(
                                //     onPressed: () {
                                //       logHolder.log("New button Pressed", level: 1);
                                //       widget.defaultBook = MainUtil.createDefaultBook();
                                //       MainUtil.goToStudio(context, widget.user);
                                //     },
                                //     name: '새 콘텐츠북 만들기',
                                //     textStyle: MyTextStyles.buttonText2,
                                //     borderColor: Colors.purple[100]!,
                                //   ),
                                // ),
                                // 사용자 로고
                                Container(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Icon(Icons.account_circle, size: 30, color: Colors.white),
                                ),
                                // 사용자 정보
                                Container(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    widget.user.name,
                                    style: MyTextStyles.userId,
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.only(left: 5),
                                  icon: Icon(Icons.arrow_drop_down_outlined),
                                  iconSize: 30,
                                  color: Colors.white,
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                  // 좌측
                  Positioned(
                      left: 90,
                      top: 242,
                      width: 450,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bookManagerHolder!.defaultBook!.name.value,
                              style: MyTextStyles.h3, maxLines: 3, overflow: TextOverflow.ellipsis),
                          SizedBox(
                            height: 20,
                          ),
                          Text(bookManagerHolder!.defaultBook!.userId, style: MyTextStyles.h5),
                          SizedBox(
                            height: 20,
                          ),
                          Text(bookManagerHolder!.defaultBook!.description.value,
                              style: MyTextStyles.h5, maxLines: 2),
                          // style: TextStyle(
                          //   color: Colors.white,
                          //   fontFamily: 'Macondo',
                          //   fontWeight: FontWeight.normal,
                          //   fontSize: 20,
                          // ),
                          //maxLines: 2),
                          SizedBox(
                            height: 20,
                          ),
                          Text(bookManagerHolder!.defaultBook!.hashTag.value,
                              style:
                                  DefaultTextStyle.of(context).style.copyWith(color: Colors.white),
                              maxLines: 2),
                          likeCountWidget(context,
                              viewCount: bookManagerHolder!.defaultBook!.viewCount.value,
                              likeCount: bookManagerHolder!.defaultBook!.likeCount.value,
                              dislikeCount: bookManagerHolder!.defaultBook!.dislikeCount.value,
                              alignment: MainAxisAlignment.start, onLikeCount: () {
                            setState(() {
                              bookManagerHolder!.defaultBook!.likeCount.set(
                                  bookManagerHolder!.defaultBook!.likeCount.value + 1,
                                  noUndo: true);
                            });
                          }, onDislikeCount: () {
                            setState(() {
                              bookManagerHolder!.defaultBook!.dislikeCount.set(
                                  bookManagerHolder!.defaultBook!.dislikeCount.value + 1,
                                  noUndo: true);
                            });
                          }),

                          // Padding(
                          //     // 조횟수, 좋아요, 싫어요
                          //     padding: const EdgeInsets.fromLTRB(0, 22, 0, 10),
                          //     child: Row(
                          //       children: [
                          //         HoverButton(
                          //             // text: MyStrings.viewCount,
                          //             // textStyle: DefaultTextStyle.of(context)
                          //             //     .style
                          //             //     .copyWith(color: Colors.white),
                          //             width: 30,
                          //             height: 30,
                          //             onEnter: () {},
                          //             onExit: () {},
                          //             onPressed: () {},
                          //             icon: const Icon(
                          //               Icons.visibility_outlined,
                          //               color: Colors.white,
                          //             )),
                          //         Text(
                          //           "${bookManagerHolder!.defaultBook!.viewCount.value}",
                          //           style: DefaultTextStyle.of(context)
                          //               .style
                          //               .copyWith(color: Colors.white),
                          //         ),
                          //         const SizedBox(
                          //           width: 10,
                          //         ),
                          //         HoverButton(
                          //             // text: MyStrings.like,
                          //             // textStyle: DefaultTextStyle.of(context)
                          //             //     .style
                          //             //     .copyWith(color: Colors.white),
                          //             width: 30,
                          //             height: 30,
                          //             onEnter: () {},
                          //             onExit: () {},
                          //             onPressed: () {
                          //               setState(() {
                          //                 bookManagerHolder!.defaultBook!.likeCount.set(
                          //                     bookManagerHolder!.defaultBook!.likeCount.value + 1,
                          //                     noUndo: true);
                          //               });
                          //             },
                          //             icon:
                          //                 const Icon(Icons.thumb_up_outlined, color: Colors.white)),
                          //         Text(
                          //           "${bookManagerHolder!.defaultBook!.likeCount.value}",
                          //           style: DefaultTextStyle.of(context)
                          //               .style
                          //               .copyWith(color: Colors.white),
                          //         ),
                          //         const SizedBox(
                          //           width: 10,
                          //         ),
                          //         HoverButton(
                          //             // text: MyStrings.dislike,
                          //             // textStyle: DefaultTextStyle.of(context)
                          //             //     .style
                          //             //     .copyWith(color: Colors.white),
                          //             width: 30,
                          //             height: 30,
                          //             onEnter: () {},
                          //             onExit: () {},
                          //             onPressed: () {
                          //               setState(() {
                          //                 bookManagerHolder!.defaultBook!.dislikeCount.set(
                          //                     bookManagerHolder!.defaultBook!.dislikeCount.value +
                          //                         1,
                          //                     noUndo: true);
                          //               });
                          //             },
                          //             icon: const Icon(Icons.thumb_down_outlined,
                          //                 color: Colors.white)),
                          //         Text(
                          //           "${bookManagerHolder!.defaultBook!.dislikeCount.value}",
                          //           style: DefaultTextStyle.of(context)
                          //               .style
                          //               .copyWith(color: Colors.white),
                          //         ),
                          //       ],
                          //     )),
                          SizedBox(
                            height: 20,
                          ),
                          HoverButton(
                              width: 203,
                              height: 56,
                              normalSize: 20,
                              hoverSize: 32,
                              onPressed: () {
                                logHolder.log("시작하기 clicked", level: 1);
                                MainUtil.goToStudio(context, widget.user);
                              },
                              icon: Icon(
                                Icons.east_outlined,
                                color: Colors.white,
                              ),
                              text: '시작하기',
                              textStyle: MyTextStyles.h6,
                              border: 1,
                              borderColor: Colors.purple[100]!,
                              bgColor: Colors.purple[600]!,
                              iconRight: true,
                              align: MainAxisAlignment.center,
                              onEnter: () {},
                              onExit: () {}),
                          SizedBox(
                            height: 100,
                          ),
                          BasicButton3(
                            onPressed: () {
                              logHolder.log('edit pressed', level: 1);
                            },
                            name: '콘텐츠북 편집',
                            iconData: Icons.edit,
                            height: 32,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          BasicButton3(
                            onPressed: () {},
                            name: '단말 목록',
                            iconData: Icons.important_devices_outlined,
                            height: 32,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          BasicButton3(
                            onPressed: () {},
                            name: '콘텐츠북 관리',
                            iconData: Icons.import_contacts_outlined,
                            height: 32,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          BasicButton3(
                            onPressed: () {},
                            name: '사용자 관리',
                            iconData: Icons.people_outline_outlined,
                            height: 32,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          BasicButton3(
                            onPressed: () {},
                            name: '광고 관리',
                            iconData: Icons.live_tv_outlined,
                            height: 32,
                          ),
                        ],
                      )),
                  Positioned(
                      top: 10,
                      left: 10,
                      child: TextButton(
                        onPressed: () {},
                        child: Text("Ver 0.11.1",
                            style: MyTextStyles.body1.copyWith(color: Colors.white)),
                      )),
                ],
              );
            });
      }),
    );
  }

  Widget adminWidget(String msg) {
    logHolder.log('errMsg :  $msg}');
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          children: [
            Text(
              'Error: $msg',
              style: const TextStyle(fontSize: 8),
            ),
            ElevatedButton(
                onPressed: () {
                  // 임시 어드민 페이지 이동
                  RTDbActions.createDefaultData(widget.user.id);
                },
                child: Text("Create Default Book")),
          ],
        ),
      ),
    );
  }
}
