// ignore_for_file: must_be_immutable
import 'package:flutter/cupertino.dart';
import '../player/abs_player.dart';
import 'abs_anime.dart';

class EnlargeWidget extends AbsAnime {
  final double iconWidth = 100;
  final double iconHeight = 100;
  double width = 100;
  double height = 100;
  final AbsPlayWidget child;
  final GlobalObjectKey<EnlargeWidgetState> enlargeWidgetKey;
  final int millisec;

  EnlargeWidget({
    required this.enlargeWidgetKey,
    required this.child,
    required this.millisec,
  }) : super(key: enlargeWidgetKey);

  @override
  State<EnlargeWidget> createState() => EnlargeWidgetState();

  @override
  void action(dynamic params) {
    enlargeWidgetKey.currentState!.toggleSize(params as Size);
  }
}

class EnlargeWidgetState extends State<EnlargeWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //initAnimeTimer();!
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: widget.millisec),
      width: widget.width,
      height: widget.height,
      curve: Curves.bounceOut,
      child: widget.child,
    );
  }

  void toggleSize(Size s) {
    setState(() {
      if (isIcon()) {
        widget.width = s.width;
        widget.height = s.height;
        return;
      }
      widget.width = widget.iconWidth;
      widget.height = widget.iconHeight;
    });
  }

  bool isIcon() {
    return widget.width == widget.iconWidth;
  }
}
