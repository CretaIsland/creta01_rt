// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

//import 'package:universal_html/html.dart' as html;

// class SplashEffect extends StatelessWidget {
//   final Widget child;
//   final Function() onTap;
//   final Function()? onLongPress;
//   final BorderRadius? borderRadius;
//   final bool isDisabled;

//   const SplashEffect({
//     Key? key,
//     required this.child,
//     required this.onTap,
//     this.isDisabled = false,
//     this.onLongPress,
//     this.borderRadius = const BorderRadius.all(Radius.circular(6)),
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     if (isDisabled) {
//       return child;
//     }
//     return Container(child: child);
//     // return Material(
//     //   type: MaterialType.transparency,
//     //   child: InkWell(
//     //     hoverColor: Colors.transparent,
//     //     borderRadius: borderRadius,
//     //     child: child,
//     //     onTap: onTap,
//     //     onLongPress: onLongPress,
//     //   ),
//     // );
//   }
// }

class CrossPlatformClick extends StatefulWidget {
  final Widget child;
  final Function(BuildContext context, PointerDownEvent event) onPointerDown;
  //final OverlayEntry parent;

  /// Normal touch, tap, right click for platforms.
  //final Function()? onNormalTap;

  /// A list of menu items for right click or long press.
  //final List<PopupMenuEntry<String>>? menuItems;
  //final Function(String? itemValue)? onMenuItemTapped;

  const CrossPlatformClick({
    Key? key,
    required this.child,
    required this.onPointerDown,
    //this.menuItems,
    //this.onNormalTap,
    //this.onMenuItemTapped}
  }) : super(key: key);

  @override
  State<CrossPlatformClick> createState() => _CrossPlatformClickState();
}

class _CrossPlatformClickState extends State<CrossPlatformClick> {
  /// We record this so that we can use long-press and location.
  //PointerDownEvent? _lastEvent;
  //OverlayEntry? entry;

  @override
  Widget build(BuildContext context) {
    final listener = Listener(
      onPointerDown: (event) => _onPointerDown(context, event),
      child: widget.child,
    );
    return listener;
    // return SplashEffect(
    //   isDisabled: widget.onNormalTap == null,
    //   borderRadius: BorderRadius.zero,
    //   onTap: widget.onNormalTap!,
    //   child: listener,
    //   onLongPress: () {
    //     if (_lastEvent != null) {
    //       _openMenu(context, _lastEvent!);
    //       return;
    //     }
    //     if (kDebugMode) {
    //       print("Last event was null, cannot open menu");
    //     }
    //   },
    // );
  }

  @override
  void initState() {
    super.initState();
    html.document.onContextMenu.listen((event) => event.preventDefault());
  }

  /// Callback when mouse clicked on `Listener` wrapped widget.
  //Future<void> _onPointerDown(BuildContext context, PointerDownEvent event) async {
  void _onPointerDown(BuildContext context, PointerDownEvent event) {
    // _lastEvent = event;

    // if (widget.menuItems == null) {
    //   return;
    // }

    // Check if right mouse button clicked
    if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton) {
      //return await _openMenu(context, event);
      widget.onPointerDown(context, event);
    }
  }

  // openMenu(BuildContext context, PointerDownEvent event) async {
  //   final overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
  //   final menuItem = await showMenu<String>(
  //     context: context,
  //     items: widget.menuItems ?? [],
  //     position: RelativeRect.fromSize(event.position & const Size(48.0, 48.0), overlay.size),
  //   );
  //   widget.onMenuItemTapped!(menuItem);
  // }

}
