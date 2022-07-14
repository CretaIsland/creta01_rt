import 'package:creta01/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:creta01/common/util/logger.dart';

import 'book_grid_card.dart';
import 'book_manager.dart';
import 'common/util/my_utils.dart';
import 'main_util.dart';
import 'model/book.dart';
import 'constants/strings.dart';
import 'model/users.dart';

class BookSliverGrid extends StatefulWidget {
  final double gridWidth;
  final double gridHeight;
  final UserModel user;
  final int maxCard;

  const BookSliverGrid(
      {Key? key,
      required this.gridWidth,
      required this.gridHeight,
      required this.user,
      required this.maxCard})
      : super(key: key);

  @override
  State<BookSliverGrid> createState() => _BookSliverGridState();
}

class _BookSliverGridState extends State<BookSliverGrid> {
  @override
  Widget build(BuildContext context) {
    return SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          // 첫번째 카드
          if (index == 0) {
            return Container(
              padding: const EdgeInsets.all(4),
              child: HoverWidget(
                index: index,
                width: widget.gridWidth,
                height: widget.gridHeight,
                normalOpacity: 0.2,
                hoverOpacity: 0.5,
                hoverWidget: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_outlined,
                      size: 100,
                      color: MyColors.primaryColor,
                    ),
                    Text(
                      MyStrings.newContentsBook,
                      style: MyTextStyles.buttonText2,
                    )
                  ],
                )),
                onTapdown: () {
                  logHolder.log("New button Pressed", level: 1);
                  bookManagerHolder!.createDefaultBook();
                  MainUtil.goToStudio(context, widget.user);
                },
              ),
            );
          }
          if (index >= bookManagerHolder!.bookList.length) {
            return Container(
              padding: const EdgeInsets.all(4),
              child: HoverWidget(
                index: index,
                width: widget.gridWidth,
                height: widget.gridHeight,
                normalOpacity: 0.2,
                hoverOpacity: 0.5,
                onTapdown: () {
                  // logHolder.log("New button Pressed", level: 1);
                  // widget.defaultBook = MainUtil.createDefaultBook();
                  // MainUtil.goToStudio(context, widget.user);
                },
              ),
            );
          }

          BookModel book = bookManagerHolder!.bookList[index - 1];
          return BookGridCard(
            index: index,
            book: book,
            durationStr: dateToDurationString(book.updateTime),
            onTapdown: () {
              bookManagerHolder!.setDefaultBook(book);
              MainUtil.goToStudio(context, widget.user);
            },
            onDelete: () {
              setState(() {});
            },
          );
          //return _emptyGridCard(index);
        }, childCount: widget.maxCard),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: widget.gridWidth + 8,
          mainAxisExtent: widget.gridHeight + 8,
          //mainAxisSpacing: 15,
          //crossAxisSpacing: 15
        ));
  }
}
