import 'package:flutter/material.dart';

Widget outLineText(String text,
    {required TextStyle style,
    int? maxLines,
    double outLineWidth = 3,
    Color outLineColor = Colors.white,
    TextAlign align = TextAlign.center}) {
  // 아웃라인의 경우.
  if (outLineWidth > 0) {
    TextStyle outlineStyle = style.copyWith(
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = outLineWidth
        ..color = outLineColor,
    );

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Text(text, textAlign: align, maxLines: maxLines, style: outlineStyle),
        Text(text, textAlign: align, maxLines: maxLines, style: style),
      ],
    );
  }
  return Text(text, textAlign: align, style: style);
}

class Txt extends StatefulWidget {
  final FontStyle fontStyle;
  final FontWeight fontWeight;
  final int maxlines;
  final double fontSize;
  final Color color;
  final TextAlign textAlign;
  final bool useoverflow;
  final bool upperCaseFirst;
  final bool useQuotes;
  final bool useFiler;
  final bool underlined;
  final bool fullUpperCase;
  final bool fullLowerCase;
  final dynamic text;
  final String fontFamily;

  const Txt({
    Key? key,
    this.fontStyle = FontStyle.normal,
    this.fontWeight = FontWeight.normal,
    this.maxlines = 1,
    this.fontSize = 16,
    required this.color,
    this.textAlign = TextAlign.center,
    this.fontFamily = 'Noto_Sans_KR',
    this.useoverflow = false,
    this.upperCaseFirst = false,
    this.useQuotes = false,
    this.useFiler = false,
    this.underlined = false,
    this.fullUpperCase = false,
    this.fullLowerCase = false,
    required this.text,
  }) : super(key: key);

  @override
  TxtState createState() => TxtState();
}

class TxtState extends State<Txt> {
  String finalText = "Null";

  @override
  Widget build(BuildContext context) {
    bool isString = widget.text is String;
    bool isNumber = widget.text is double || widget.text is int;
    bool isOthers = isString == false && isNumber == false;

    if (isString) {
      finalText = widget.text ?? "Error";
    } //when you forgot to set a value, "Error" will be shown
    if (isNumber) finalText = '${widget.text}';
    if (isOthers) finalText = "Invalid input ${widget.text}";

//John → john
    if (widget.fullLowerCase) finalText = finalText.toLowerCase();

//John → JOHN
    if (widget.fullUpperCase) finalText = finalText.toUpperCase();

//JOHN or john → John
    if (widget.upperCaseFirst && finalText.length > 1) {
      finalText =
          "${finalText[0].toUpperCase()}${finalText.substring(1, finalText.length).toLowerCase()}";
    }

//John → "John"
    if (widget.useQuotes) finalText = "❝$finalText❞";

//John*_-#![] → John
    if (widget.useFiler) {
      finalText = finalText
          .replaceAll("*", "")
          .replaceAll("_", "")
          .replaceAll("-", "")
          .replaceAll("#", "")
          .replaceAll("\n", "")
          .replaceAll("!", "")
          .replaceAll('[', '')
          .replaceAll(']', '');
    }

    return Text((finalText).toString(),
        overflow: widget.useoverflow ? TextOverflow.ellipsis : null,
        textAlign: widget.textAlign,
        maxLines: widget.maxlines,
        textScaleFactor:
            1, // This will keep your text size constant, when the user changes his device text size,
        style: TextStyle(
          decoration: widget.underlined ? TextDecoration.underline : null, //to underlined a text
          color: widget.color,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          fontStyle: widget.fontStyle,
          fontFamily: widget.fontFamily,
        ));
  }
}
