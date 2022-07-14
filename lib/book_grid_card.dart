import 'package:creta01/book_manager.dart';
import 'package:creta01/common/util/logger.dart';
import 'package:creta01/constants/strings.dart';
import 'package:flutter/material.dart';
import 'common/buttons/basic_button.dart';
import 'common/util/my_utils.dart';
import 'constants/styles.dart';
import 'model/book.dart';
import 'main_util.dart';

// ignore: must_be_immutable
class BookGridCard extends StatefulWidget {
  final int index;
  final BookModel book;
  final String durationStr;
  final void Function() onTapdown;
  final void Function() onDelete;

  const BookGridCard({
    Key? key,
    required this.index,
    required this.book,
    required this.durationStr,
    required this.onTapdown,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<BookGridCard> createState() => _BookGridCardState();
}

class _BookGridCardState extends State<BookGridCard> {
  final double gridWidth = 328;
  final double gridHeight = 210;
  final double gridTitle = 48;

  bool deleteBook = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.transparent, //getColor(index),
        //padding: const EdgeInsets.all(8),
        child: //Container(color: getColor(index)),
            Card(
          shadowColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1.0, color: Colors.white),
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 8,

          child: Stack(children: [
            Column(children: [
              SizedBox(
                // background
                width: gridWidth,
                height: gridHeight - gridTitle,
                child: MainUtil.drawBackground(gridWidth, gridHeight - gridTitle, widget.book),
              ),
              Container(
                padding: const EdgeInsets.only(right: 10),
                height: gridTitle,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(flex: 1, child: Container()),
                    Expanded(
                      flex: 12,
                      child: Text(widget.book.name.value,
                          style: MyTextStyles.cardText1,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                    Expanded(flex: 1, child: Container()),
                    Expanded(
                      flex: 6,
                      child: Text(
                        widget.durationStr,
                        style: MyTextStyles.cardText2,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ]),
            HoverWidget(
              width: gridWidth,
              height: gridHeight,
              index: widget.index,
              book: widget.book,
              onTapdown: widget.onTapdown,
            ),
            Positioned(
              bottom: 15,
              right: 4,
              height: 30,
              width: 30,
              child: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  logHolder.log('Delete Book pressed', level: 5);
                  setState(() {
                    deleteBook = true;
                  });
                },
                color: MyColors.mainColor,
              ),
            ),
            deleteBook
                ? frostedEdged(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: widget.book.name.value,
                                  style: MyTextStyles.subtitle1.copyWith(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: '을  정말로 삭제하시겠습니까 ?',
                                  style: MyTextStyles.subtitle1.copyWith(
                                      fontSize: 20,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          basicButton(
                              name: "Yes",
                              iconData: Icons.done_outlined,
                              onPressed: () {
                                logHolder.log('Yes pressed', level: 5);
                                setState(() {
                                  deleteBook = false;
                                  bookManagerHolder!.removeBook(widget.book, widget.onDelete);
                                });
                              }),
                          basicButton(
                              name: "No",
                              iconData: Icons.close_outlined,
                              onPressed: () {
                                logHolder.log('No pressed', level: 5);
                                setState(() {
                                  deleteBook = false;
                                });
                              }),
                        ],
                      )
                    ],
                  ))
                : Container(),
          ]),

          //height: 200,
        ));
  }
}

class HoverWidget extends StatefulWidget {
  final double width;
  final double height;
  final int index;
  final BookModel? book;
  final void Function() onTapdown;
  final double hoverOpacity;
  final double normalOpacity;
  final Widget? hoverWidget;

  const HoverWidget({
    Key? key,
    this.book,
    required this.width,
    required this.height,
    required this.index,
    required this.onTapdown,
    this.hoverOpacity = 0.4,
    this.normalOpacity = 0.0,
    this.hoverWidget,
  }) : super(key: key);

  @override
  State<HoverWidget> createState() => _HoverWidgetState();
}

class _HoverWidgetState extends State<HoverWidget> {
  int hoverIndex = -1;
  // ignore: unused_field

  bool _isClikcked() {
    return widget.book != null && widget.book!.mid == bookManagerHolder!.defaultBook!.mid;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        widget.onTapdown();
        setState(() {});
      },
      child: MouseRegion(
        onEnter: (event) {},
        onHover: (event) {
          setState(() {
            hoverIndex = widget.index;
          });
        },
        onExit: (event) {
          setState(() {
            hoverIndex = -1;
          });
        },
        child: Container(
            width: widget.width,
            height: widget.height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(
                  (hoverIndex == widget.index) ? widget.hoverOpacity : widget.normalOpacity),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(
                  width: _isClikcked() ? 6.0 : 0.0, color: Colors.white, style: BorderStyle.solid),
            ),
            child: (widget.book == null && widget.hoverWidget != null)
                ? widget.hoverWidget!
                : (hoverIndex == widget.index && widget.book != null)
                    ? Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 50.0, right: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            outlineText(
                              widget.book!.description.value,
                              fontSize: 16,
                              textColor: Colors.black,
                              lineColor: Colors.white,
                              maxLines: 2,
                            ),
                            outlineText(
                              widget.book!.hashTag.value,
                              fontSize: 14,
                              textColor: Colors.black,
                              lineColor: Colors.white,
                              maxLines: 1,
                            ),
                            likeCountWidgetReadOnly(context,
                                viewCount: bookManagerHolder!.defaultBook!.viewCount.value,
                                likeCount: bookManagerHolder!.defaultBook!.likeCount.value,
                                dislikeCount: bookManagerHolder!.defaultBook!.dislikeCount.value,
                                color: Colors.black),
                            widget.book!.readOnly.value
                                ? outlineText(
                                    MyStrings.readOnlyContens,
                                    fontSize: 14,
                                    textColor: Colors.red,
                                    lineColor: Colors.white,
                                  )
                                : Container(),
                          ],
                        ),
                      )
                    : Container()),
      ),
    );
  }
}
