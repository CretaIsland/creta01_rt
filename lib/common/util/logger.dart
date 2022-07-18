// ignore_for_file: avoid_print, prefer_const_constructors
import 'dart:collection';
import 'package:flutter/material.dart';

MyLogger logHolder = MyLogger();

class MyLogger {
  bool showLog = false;
  int levelLimit = 6;
  int maxMsg = 100;
  final veiwerKey = GlobalKey<DebugBarState>();
  Queue<String> msgList = ListQueue();

  MyLogger() {
    msgList.add('ready');
  }

  log(String msg, {int level = 1, bool force = false}) {
    if (force || (level >= levelLimit)) {
      print(msg);
      if (showLog && veiwerKey.currentState != null) {
        msgList.add(msg);
        if (msgList.length >= maxMsg) {
          msgList.removeFirst();
        }
        //notifyListeners();
      }
    }
  }
}

class DebugBar extends StatefulWidget {
  const DebugBar({Key? key}) : super(key: key);
  @override
  DebugBarState createState() => DebugBarState();
}

class DebugBarState extends State<DebugBar> {
  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: Colors.red.withOpacity(0.7),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Icon(Icons.refresh)),
            ),
            Expanded(
              flex: 19,
              child: Scrollbar(
                thickness: 20,
                //hoverThickness: 25,
                //isAlwaysShown: true,
                thumbVisibility: true,
                //showTrackOnHover: true,
                child: ListView(
                  padding: EdgeInsets.only(left: 20),
                  shrinkWrap: true,
                  children: List.generate(logHolder.msgList.length, (index) {
                    return Text(logHolder.msgList.toList()[index]);
                  }),
                ),
              ),
            ),
          ]),
    );
  }
}
