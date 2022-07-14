import 'package:creta01/acc/acc_manager.dart';
import 'package:creta01/model/model_enums.dart';
import 'package:creta01/studio/save_manager.dart';
import 'package:flutter/material.dart';

import '../../book_manager.dart';
import '../../common/buttons/basic_button.dart';
import '../../common/buttons/hover_buttons.dart';
import '../../common/util/logger.dart';
import '../../common/util/my_utils.dart';
import '../../common/util/textfileds.dart';
import '../../constants/constants.dart';
import '../../constants/strings.dart';
import '../../constants/styles.dart';
import '../../model/pages.dart';
import 'properties_frame.dart';
import 'property_selector.dart';

// ignore: must_be_immutable
class BookProperty extends PropertySelector {
  BookProperty(
    Key? key,
    PageModel? pselectedPage,
    bool pisNarrow,
    bool pisLandscape,
    PropertiesFrameState parent,
  ) : super(
          key: key,
          selectedPage: pselectedPage,
          isNarrow: pisNarrow,
          isLandscape: pisLandscape,
          parent: parent,
        );

  @override
  State<BookProperty> createState() => _BookPropertyState();
}

class _BookPropertyState extends State<BookProperty> {
  TextEditingController nameCon = TextEditingController();
  TextEditingController descCon = TextEditingController();
  TextEditingController hashCon = TextEditingController();
  bool _saveAsMode = false;
  bool _aleadyExist = false;
  String _copyResultMsg = "";
  final TextEditingController _saveAsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String name = '';
    String hash = '';
    String desc = '';
    bool readOnly = false;
    ScopeType scope = ScopeType.public;
    SecretLevel secretLevel = SecretLevel.public;
    bool isSilent = false;
    bool isAutoPlay = false;
    BookType bookType = BookType.signage;

    if (bookManagerHolder != null && bookManagerHolder!.defaultBook != null) {
      name = bookManagerHolder!.defaultBook!.name.value;
      hash = bookManagerHolder!.defaultBook!.hashTag.value;
      desc = bookManagerHolder!.defaultBook!.description.value;
      readOnly = bookManagerHolder!.defaultBook!.readOnly.value;
      scope = bookManagerHolder!.defaultBook!.scope.value;
      secretLevel = bookManagerHolder!.defaultBook!.secretLevel.value;
      isSilent = bookManagerHolder!.defaultBook!.isSilent.value;
      isAutoPlay = bookManagerHolder!.defaultBook!.isAutoPlay.value;
      bookType = bookManagerHolder!.defaultBook!.bookType.value;
    }

    return ListView(
      //mainAxisAlignment: MainAxisAlignment.start,
      //crossAxisAlignment: CrossAxisAlignment.start,
      //controller: _scrollController,
      children: [
        const SizedBox(
          height: 40,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 6, 22, 10),
          child:
              //Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //children: [
              Container(
            padding: EdgeInsets.zero,
            width: layoutPropertiesWidth * 0.75,
            child: myTextField(
              name,
              maxLines: null,
              limit: 128,
              textAlign: TextAlign.start,
              labelText: MyStrings.bookName,
              controller: nameCon,
              hasBorder: true,
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16),
              onEditingComplete: _onTitleEditingComplete,
            ),
          ),
          // writeButton(
          //   onPressed: _onTitleEditingComplete,
          // ),
          //],
          //),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 6, 22, 10),
          child:
              //Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //children: [
              Container(
            padding: EdgeInsets.zero,
            width: layoutPropertiesWidth * 0.75,
            child: myTextField(
              desc,
              limit: 1000,
              textAlign: TextAlign.start,
              labelText: MyStrings.desc,
              controller: descCon,
              hasBorder: true,
              maxLines: null,
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16),
              onEditingComplete: _onDescEditingComplete,
            ),
          ),
          // writeButton(
          //   onPressed: _onDescEditingComplete,
          // ),
          //],
          //),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 6, 22, 10),
          child:
              //Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //children: [
              Container(
            padding: EdgeInsets.zero,
            width: layoutPropertiesWidth * 0.75,
            child: myTextField(
              hash,
              maxLines: null,
              limit: 128,
              textAlign: TextAlign.start,
              labelText: MyStrings.hashTag,
              controller: hashCon,
              hasBorder: true,
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16),
              onEditingComplete: _onHashEditingComplete,
            ),
          ),
          // writeButton(
          //   onPressed: _onHashEditingComplete,
          // ),
          //],
          //),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 22),
          child: basicButton(
              alignment: Alignment.centerRight,
              name: MyStrings.save,
              iconData: Icons.save,
              onPressed: () {
                _onTitleEditingComplete();
                _onDescEditingComplete();
                _onHashEditingComplete();
              }),
        ),
        Padding(
          // 용도
          padding: const EdgeInsets.only(left: 22, top: 12),
          child: Row(
            children: [
              Text(
                MyStrings.bookType,
                style: MyTextStyles.subtitle2,
              ),
              const SizedBox(
                width: 22,
              ),
              Text(
                bookTypeToString(bookType),
                style: MyTextStyles.subtitle2.copyWith(fontSize: 20),
              ),
            ],
          ),
        ),

        Padding(
          // 읽기 전용
          padding: const EdgeInsets.fromLTRB(22, 0, 0, 0),
          child: myCheckBox(MyStrings.readOnly, readOnly, () async {
            if (await saveManagerHolder!.isInContentsUploading()) {
              showSlimDialog(context, MyStrings.contentsUploading2, bgColor: Colors.white);
              return;
            }
            if (bookManagerHolder!.toggleReadOnly(context)) {
              setState(() {});
            }
          }, 18, 2, 8, 2),
        ),

        Padding(
          // 자동 플레이
          padding: const EdgeInsets.fromLTRB(22, 0, 0, 0),
          child: myCheckBox(MyStrings.isAutoPlay, isAutoPlay, () {
            if (bookManagerHolder!.toggleIsAutoPlay()) {
              setState(() {});
            }
            accManagerHolder!.notifyAll();
          }, 18, 2, 8, 2),
        ),
        Padding(
          // Silent
          padding: const EdgeInsets.fromLTRB(22, 0, 0, 0),
          child: myCheckBox(MyStrings.isSilent, isSilent, () {
            if (bookManagerHolder!.toggleIsSilent()) {
              setState(() {});
            }
            accManagerHolder!.notifyAll();
          }, 18, 2, 8, 2),
        ),
        Padding(
          // 범위 scope
          padding: const EdgeInsets.fromLTRB(22, 0, 0, 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Text(MyStrings.scope),
            const SizedBox(
              width: 15,
            ),
            DropdownButton<ScopeType>(
              value: scope,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              //style: const TextStyle(color: Colors.deepPurple),
              underline: Container(height: 2, color: MyColors.primaryColor),
              onChanged: (ScopeType? newValue) {
                setState(() {
                  bookManagerHolder!.setScope(newValue!);
                });
              },
              items: <ScopeType>[
                ScopeType.public,
                ScopeType.onlyForMe,
                ScopeType.onlyForGroup,
                ScopeType.onlyForGroupAndChild,
                ScopeType.enterprise,
              ].map<DropdownMenuItem<ScopeType>>((ScopeType e) {
                return DropdownMenuItem<ScopeType>(value: e, child: Text(scopeTypeToString(e)));
              }).toList(),
            ),
          ]),
        ),
        Padding(
          // 비밀등급
          padding: const EdgeInsets.fromLTRB(22, 0, 0, 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Text(MyStrings.secretLevel),
            const SizedBox(
              width: 15,
            ),
            DropdownButton<SecretLevel>(
              value: secretLevel,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              //style: const TextStyle(color: Colors.deepPurple),
              underline: Container(height: 2, color: MyColors.primaryColor),
              onChanged: (SecretLevel? newValue) {
                setState(() {
                  bookManagerHolder!.setSecretLevel(newValue!);
                });
              },
              items: <SecretLevel>[
                SecretLevel.public,
                SecretLevel.confidential,
                SecretLevel.thirdClass,
                SecretLevel.secondClass,
                SecretLevel.topClass,
              ].map<DropdownMenuItem<SecretLevel>>((SecretLevel e) {
                return DropdownMenuItem<SecretLevel>(value: e, child: Text(secretLevelToString(e)));
              }).toList(),
            ),
          ]),
        ),
        // 사본 만들기
        Padding(
          padding: const EdgeInsets.only(left: 22, top: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              basicButton(
                  alignment: Alignment.centerLeft,
                  name: MyStrings.makeCopy,
                  iconData: Icons.copy,
                  onPressed: () {
                    setState(() {
                      _copyResultMsg = '';
                      _saveAsMode = !_saveAsMode;
                    });
                  }),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 26, 22, 6),
                  child: _saveAsMode
                      ? Column(
                          children: [
                            myTextField(
                              bookManagerHolder!.newNameMaker(name),
                              maxLines: 2,
                              limit: 128,
                              textAlign: TextAlign.start,
                              labelText: MyStrings.inputNewName,
                              controller: _saveAsController,
                              hasBorder: true,
                              style: MyTextStyles.body2.copyWith(fontSize: 20),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              basicButton(
                                  name: MyStrings.apply,
                                  onPressed: () {
                                    _copyResultMsg = '';
                                    _aleadyExist =
                                        !bookManagerHolder!.makeCopy(_saveAsController.text);
                                    setState(() {
                                      if (!_aleadyExist) {
                                        _copyResultMsg =
                                            MyStrings.copyResultMsg(_saveAsController.text);
                                        _saveAsMode = !_saveAsMode;
                                        bookManagerHolder!.addName(_saveAsController.text);
                                      }
                                    });
                                  },
                                  iconData: Icons.done_outlined),
                              const SizedBox(
                                width: 5,
                              ),
                              basicButton(
                                  name: MyStrings.cancel,
                                  onPressed: () {
                                    setState(() {
                                      _copyResultMsg = '';
                                      _saveAsMode = !_saveAsMode;
                                    });
                                  },
                                  iconData: Icons.close_outlined),
                            ]),
                            const SizedBox(height: 10),
                            _aleadyExist
                                ? Text(
                                    MyStrings.alreadyExist,
                                    style: MyTextStyles.body1.copyWith(color: MyColors.error),
                                  )
                                : const SizedBox(height: 5),
                          ],
                        )
                      : Text(
                          _copyResultMsg,
                          style: MyTextStyles.body1,
                        ))
            ],
          ),
        ),
        Padding(
            // 조횟수, 좋아요, 싫어요
            padding: const EdgeInsets.fromLTRB(22, 0, 0, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    HoverButton(
                        text: MyStrings.viewCount,
                        width: 100,
                        height: 30,
                        onEnter: () {},
                        onExit: () {},
                        onPressed: () {},
                        icon: const Icon(Icons.visibility_outlined)),
                    Text("${bookManagerHolder!.defaultBook!.viewCount.value}"),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    HoverButton(
                        text: MyStrings.like,
                        width: 100,
                        height: 30,
                        onEnter: () {},
                        onExit: () {},
                        onPressed: () {
                          setState(() {
                            bookManagerHolder!.defaultBook!.likeCount.set(
                                bookManagerHolder!.defaultBook!.likeCount.value + 1,
                                noUndo: true);
                          });
                        },
                        icon: const Icon(Icons.thumb_up_outlined)),
                    Text("${bookManagerHolder!.defaultBook!.likeCount.value}"),
                    const SizedBox(
                      width: 10,
                    ),
                    HoverButton(
                        text: MyStrings.dislike,
                        width: 100,
                        height: 30,
                        onEnter: () {},
                        onExit: () {},
                        onPressed: () {
                          setState(() {
                            bookManagerHolder!.defaultBook!.dislikeCount.set(
                                bookManagerHolder!.defaultBook!.dislikeCount.value + 1,
                                noUndo: true);
                          });
                        },
                        icon: const Icon(Icons.thumb_down_outlined)),
                    Text("${bookManagerHolder!.defaultBook!.dislikeCount.value}"),
                  ],
                ),
              ],
            )),
      ],
    );
  }

  void _onTitleEditingComplete() {
    logHolder.log("textval = ${nameCon.text}");
    bookManagerHolder!.setName(nameCon.text);
  }

  void _onDescEditingComplete() {
    logHolder.log("textval = ${descCon.text}", level: 5);
    bookManagerHolder!.setDesc(descCon.text);
  }

  void _onHashEditingComplete() {
    String hashTagForm = '# ${hashCon.text.replaceAll(',', ' #').replaceAll(' ', '')}';
    logHolder.log("textval = $hashTagForm");
    bookManagerHolder!.setHash(hashTagForm);
  }
}
