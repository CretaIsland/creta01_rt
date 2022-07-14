// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_treeview/flutter_treeview.dart';

import '../../acc/acc_manager.dart';
import '../../constants/styles.dart';
import '../../constants/strings.dart';
import '../../common/util/logger.dart';
import 'package:creta01/common/buttons/basic_button.dart';
import 'package:creta01/common/tree/my_tree_view.dart';
import 'package:creta01/studio/pages/page_manager.dart';
import 'package:creta01/model/pages.dart';
import 'package:creta01/widgets/card_flip.dart';
import 'page_list.dart';
import 'page_manager.dart';

// ignore: must_be_immutable
class PagesFrame extends StatefulWidget {
  final bool isNarrow;
  static bool isListType = false;

  const PagesFrame({Key? key, required this.isNarrow}) : super(key: key);

  @override
  State<PagesFrame> createState() => _PageScreenState();
}

class _PageScreenState extends State<PagesFrame> {
  List<Node>? _nodes;
  bool docsOpen = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      logHolder.log('after build _PageScreenState........', level: 5);
      await accManagerHolder!.isACCInit();
      // ignore: use_build_context_synchronously
      accManagerHolder!.registerOverlayAll(context);
      initACCTimer();
    });
  }

  void initACCTimer() {
    if (_timer != null) {
      return;
    }
    _timer = Timer.periodic(const Duration(milliseconds: 1000), _timerExpired);
  }

  Future<void> _timerExpired(Timer timer) async {
    if (await accManagerHolder!.isACCChanged() == false) {
      return;
    }
    logHolder.log('change registerOverayAll', level: 7);
    accManagerHolder!.setIsACCChanged(false);
    accManagerHolder!.changeOverlayAll(context);
  }

  @override
  void dispose() {
    logHolder.log('PagesFrame.dispose', level: 6);
    if (_nodes != null) _nodes!.clear();
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    logHolder.log('_PageScreenState width=$width, height=$height', level: 5);

    return SafeArea(
      child: Container(
        color: MyColors.white,
        child: Stack(alignment: AlignmentDirectional.bottomEnd, children: [
          Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 6, 10, 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(MyStrings.pages, style: MyTextStyles.body2),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        PagesFrame.isListType = !PagesFrame.isListType;
                      });
                    },
                    icon: Icon(PagesFrame.isListType ? Icons.list_alt : Icons.grid_view),
                    color: MyColors.icon,
                    iconSize: MySizes.smallIcon,
                  ),
                ],
              ),
            ),
            Divider(
              height: 5,
              thickness: 1,
              color: MyColors.divide,
              indent: 0,
              endIndent: 0,
            ),
            // Expanded(
            //   child: Container(
            //     padding: EdgeInsets.all(5),
            //     //color: MyColors.artBoardBgColor,
            //     child: isListType
            //         ? PageSwipList(key: GlobalKey<PageSwipListState>())
            //         : Container(
            //             color: Colors.red,
            //             width: 310,
            //             height: 500,
            //             child: Text('second page'),
            //           ),
            //   ),
            // ),
            TwinCardFlip(
                key: UniqueKey(),
                firstPage: SizedBox(
                  //color: Colors.blue,
                  width: 310,
                  height: height - 140,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    //color: MyColors.artBoardBgColor,
                    child: PageSwipList(key: GlobalKey<PageSwipListState>()),
                  ),
                ),
                secondPage: Consumer<PageManager>(builder: (context, pageManager, child) {
                  logHolder.log('Consumer build PageSwipListState ${pageManager.pageIndex}',
                      level: 7);

                  pageManager.reorderMap();
                  List<PageModel> items = pageManager.orderMap.values.toList();

                  if (items.isEmpty) {
                    logHolder.log('item is empty');
                    return Container();
                  }

                  getSampleNode(pageManager.getSelected());

                  return SizedBox(
                      //color: Colors.blue,
                      width: 310,
                      height: height - 140,
                      child: MyTreeView(
                        key: UniqueKey(),
                        nodes: _nodes!,
                        pageManager: pageManager,
                      ));
                }),
                flip: PagesFrame.isListType)
          ]),
          Padding(
            padding: EdgeInsets.only(right: 17, bottom: 40),
            child: Consumer<PageManager>(builder: (context, pageManager, child) {
              return basicButton(
                  name: MyStrings.pageAdd,
                  iconData: Icons.add,
                  onPressed: () {
                    logHolder.log('createPage()');
                    pageManager.createPage();
                    setState(() {});
                  });
            }),
          ),
        ]),
      ),
    );
    //});
    // child: SingleChildScrollView(
    //   padding: const EdgeInsets.all(defaultPadding),
    //   child: Container(
    //     color: MyColors.white,
    //   ),
    // ),
  }

  void getSampleNode(PageModel? selectedModel) {
    //bool docsOpen = true;
//     _nodes = [
//       Node(
//         label: 'documents',
//         key: 'docs',
//         expanded: docsOpen,
//         // ignore: dead_code
//         icon: docsOpen ? Icons.folder_open : Icons.folder,
//         children: [
//           Node(
//             label: 'personal',
//             key: 'd3',
//             icon: Icons.input,
//             iconColor: Colors.red,
//             children: [
//               Node(
//                 label: 'Poems.docx',
//                 key: 'pd1',
//                 icon: Icons.insert_drive_file,
//               ),
//               Node(
//                 label: 'Job Hunt',
//                 key: 'jh1',
//                 icon: Icons.input,
//                 children: [
//                   Node(
//                     label: 'Resume.docx',
//                     key: 'jh1a',
//                     icon: Icons.insert_drive_file,
//                   ),
//                   Node(
//                     label: 'Cover Letter.docx',
//                     key: 'jh1b',
//                     icon: Icons.insert_drive_file,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           Node(
//             label: 'Inspection.docx',
//             key: 'd1',
// //          icon: Icons.insert_drive_file),
//           ),
//           Node(label: 'Invoice.docx', key: 'd2', icon: Icons.insert_drive_file),
//         ],
//       ),
//       Node(label: 'MeetingReport.xls', key: 'mrxls', icon: Icons.insert_drive_file),
//       Node(
//           label: 'MeetingReport.pdf',
//           key: 'mrpdf',
//           iconColor: Colors.green.shade300,
//           selectedIconColor: Colors.white,
//           icon: Icons.insert_drive_file),
//       Node(label: 'Demo.zip', key: 'demo', icon: Icons.archive),
//       Node(
//         label: 'empty folder',
//         key: 'empty',
//         parent: true,
//       ),
//     ];

    if (pageManagerHolder != null) {
      logHolder.log('pageManagerHolder is inited', level: 1);
      if (_nodes != null) {
        _nodes!.clear();
      }
      _nodes = pageManagerHolder!.toNodes(selectedModel);
    } else {
      logHolder.log('pageManagerHolder is not inited', level: 1);
      _nodes = [
        Node(
            label: 'samples',
            key: 'key',
            expanded: docsOpen,
            icon: docsOpen ? Icons.folder_open : Icons.folder,
            children: []),
      ];
    }
  }
}
