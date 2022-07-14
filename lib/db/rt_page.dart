import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../book_manager.dart';
import '../common/util/logger.dart';
import '../model/pages.dart';

class RTPages extends ChangeNotifier {
  final String bookMid;

  final List<PageModel> _pages = [];

  final _db = FirebaseDatabase.instance.ref();
  List<PageModel> get pages => _pages;

  late StreamSubscription<DatabaseEvent> _pagesStream;
  //late StreamSubscription<DatabaseEvent> _accStream;

  RTPages(this.bookMid) {
    _listenToPages();
  }

  void _listenToPages() {
    logHolder.log('_listenToPages()', level: 5);
    _pagesStream =
        _db.child('creta_page').orderByChild('parentMid').equalTo(bookMid).onValue.listen((event) {
      if (event.snapshot.value != null) {
        final allpages = event.snapshot.value as Map<String, dynamic>;
        allpages.forEach((mapKey, mapValue) {
          bool isRemoved = mapValue["isRemoved"] ?? true;
          if (isRemoved) return;
          String? mid = mapValue["mid"];
          if (mid == null) return;
          PageModel page = PageModel.createEmptyModel(mid, bookMid);
          page.deserialize(mapValue);
          //_listenToACCs(page);
          //page.accPropertyList = getACCProperties(page);
          if (bookManagerHolder!.defaultBook!.mid == bookMid) {
            bookManagerHolder!.defaultBook!.pageList.add(page);
          }
          _pages.add(page);
        });
        // _pages.sort((a, b) {
        //   return a.updateTime.compareTo(b.updateTime);
        // });
        // _pages = allpages.values.map((ele) { return
        // Oder.fromRTDB(ele as Map<String, dynamic>)}).toList();
        logHolder.log('_listenToPages() --> notifyListeners', level: 5);
        notifyListeners();
      }
    });
  }

  // void _listenToACCs(PageModel page) {
  //   logHolder.log('_listenToACCs(${page.mid})', level: 5);

  //   _accStream =
  //       _db.child('creta_acc').orderByChild('parentMid').equalTo(page.mid).onValue.listen((event) {
  //     if (event.snapshot.value != null) {
  //       final allpages = event.snapshot.value as Map<String, dynamic>;
  //       allpages.forEach((mapKey, mapValue) {
  //         bool isRemoved = mapValue["isRemoved"] ?? true;
  //         if (isRemoved) return;
  //         String? mid = mapValue["mid"];
  //         if (mid == null) return;
  //         ACCProperty acc = ACCProperty.createEmptyModel(mid, page.mid);
  //         acc.deserialize(mapValue);
  //         page.accPropertyList.add(acc);
  //       });
  //       // _pages.sort((a, b) {
  //       //   return a.updateTime.compareTo(b.updateTime);
  //       // });
  //       // _pages = allpages.values.map((ele) { return
  //       // Oder.fromRTDB(ele as Map<String, dynamic>)}).toList();

  //       notifyListeners();
  //     }
  //   });
  //}

  @override
  void dispose() {
    _pagesStream.cancel();
    //_accStream.cancel();
    super.dispose();
  }
}
