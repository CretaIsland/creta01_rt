import 'dart:async';
import 'package:creta01/book_manager.dart';
//import 'package:sortedmap/sortedmap.dart';

import 'package:creta01/constants/constants.dart';
import 'package:creta01/common/util/logger.dart';
import 'package:creta01/acc/acc_manager.dart';
import 'package:creta01/acc/acc.dart';
import 'package:creta01/model/acc_property.dart';
import 'package:creta01/studio/pages/page_manager.dart';
import 'package:creta01/studio/save_manager.dart';
import 'package:creta01/model/pages.dart';
import 'package:creta01/model/contents.dart';
import 'package:creta01/model/models.dart';
import 'package:creta01/db/creta_db.dart';

//import '../creta_main.dart';
import '../model/book.dart';

class DbActions {
  // static Future<List<BookModel>> getMyBookList(String userId) async {
  //   logHolder.log('getMyBookList', level: 1);
  //   List<BookModel> retval = [];
  //   try {
  //     QuerySnapshot<Object?> querySnapshot = await CretaDB('creta_book')
  //         .collectionRef
  //         .where(
  //           'userId',
  //           isEqualTo: userId,
  //         )
  //         .where('isRemoved', isEqualTo: false)
  //         .orderBy('updateTime', descending: true)
  //         .get();
  //     List<dynamic> list = querySnapshot.docs;
  //     //List<dynamic> list = querySnapshot.docs.map((doc) => doc.data()).toList();
  //     // List<dynamic> list = await CretaDB('creta_book')
  //     //     .simpleQueryData(orderBy: 'updateTime', name: 'userId', value: userId);

  //     for (QueryDocumentSnapshot doc in list) {
  //       logHolder.log(doc.data()!.toString(), level: 1);
  //       Map<String, dynamic> map = doc.data()! as Map<String, dynamic>;
  //       String? mid = map["mid"];

  //       if (mid == null) {
  //         continue;
  //       }
  //       BookModel book = BookModel.createEmptyModel(mid, userId);
  //       book.deserialize(map);
  //       retval.add(book);
  //     }
  //   } catch (e) {
  //     logHolder.log("Data error $e", level: 6);
  //   }
  //   logHolder.log('getMyBookList end(${retval.length})', level: 1);
  //   return retval;
  // }

  // static Future<List<PageModel>> getPages(String bookMid) async {
  //   List<PageModel> retval = [];
  //   try {
  //     QuerySnapshot<Object?> querySnapshot = await CretaDB('creta_page')
  //         .collectionRef
  //         .where(
  //           'parentMid',
  //           isEqualTo: bookMid,
  //         )
  //         .where('isRemoved', isEqualTo: false)
  //         .orderBy('updateTime', descending: true)
  //         .get();
  //     List<dynamic> list = querySnapshot.docs;
  //     // List<dynamic> list = await CretaDB('creta_page')
  //     //     .simpleQueryData(orderBy: 'updateTime', name: 'parentMid', value: bookMid);

  //     logHolder.log('getPages(${list.length})', level: 1);

  //     for (QueryDocumentSnapshot item in list) {
  //       logHolder.log(item.data()!.toString(), level: 1);
  //       Map<String, dynamic> map = item.data()! as Map<String, dynamic>;
  //       String? mid = map["mid"];
  //       if (mid == null) {
  //         continue;
  //       }
  //       PageModel page = PageModel.createEmptyModel(mid, bookMid);
  //       page.deserialize(map);
  //       retval.add(page);
  //       page.accPropertyList = await getACCProperties(page);
  //     }
  //   } catch (e) {
  //     logHolder.log("Data error $e", level: 6);
  //   }
  //   return retval;
  // }

  // static Future<List<ACCProperty>> getACCProperties(PageModel page) async {
  //   List<ACCProperty> retval = [];
  //   try {
  //     QuerySnapshot<Object?> querySnapshot = await CretaDB('creta_acc')
  //         .collectionRef
  //         .where(
  //           'parentMid',
  //           isEqualTo: page.mid,
  //         )
  //         .where('isRemoved', isEqualTo: false)
  //         .orderBy('updateTime', descending: true)
  //         .get();
  //     List<dynamic> list = querySnapshot.docs;
  //     // List<dynamic> list = await CretaDB('creta_acc')
  //     //     .simpleQueryData(orderBy: 'updateTime', name: 'parentMid', value: page.mid);
  //     logHolder.log('getACCProperties(${list.length})', level: 1);

  //     for (QueryDocumentSnapshot item in list) {
  //       logHolder.log(item.data()!.toString(), level: 1);
  //       Map<String, dynamic> map = item.data()! as Map<String, dynamic>;
  //       String? mid = map["mid"];
  //       if (mid == null) {
  //         continue;
  //       }
  //       // bool? isRemoved = map["isRemoved"];
  //       // if (isRemoved != null && isRemoved == true) {
  //       //   logHolder.log("removed data skipped($mid!", level: 1);
  //       //   continue;
  //       // }
  //       ACCProperty accProperty = ACCProperty.createEmptyModel(mid, page.mid);
  //       accProperty.deserialize(map);
  //       retval.add(accProperty);
  //       accProperty.contentsMap = await getContents(accProperty);
  //     }
  //   } catch (e) {
  //     logHolder.log("Data error $e", level: 6);
  //   }
  //   return retval;
  // }

  // static Future<SortedMap<int, ContentsModel>> getContents(ACCProperty accProperty) async {
  //   SortedMap<int, ContentsModel> retval = SortedMap<int, ContentsModel>();
  //   try {
  //     QuerySnapshot<Object?> querySnapshot = await CretaDB('creta_contents')
  //         .collectionRef
  //         .where(
  //           'parentMid',
  //           isEqualTo: accProperty.mid,
  //         )
  //         .where('isRemoved', isEqualTo: false)
  //         .orderBy('updateTime', descending: true)
  //         .get();
  //     List<dynamic> list = querySnapshot.docs;
  //     // List<dynamic> list = await CretaDB('creta_contents')
  //     //     .simpleQueryData(orderBy: 'updateTime', name: 'parentMid', value: accProperty.mid);
  //     // logHolder.log('getContents(${list.length})', level: 1);
  //     int idx = 0;
  //     for (QueryDocumentSnapshot item in list) {
  //       logHolder.log(item.data()!.toString(), level: 1);
  //       Map<String, dynamic> map = item.data()! as Map<String, dynamic>;
  //       String? mid = map["mid"];
  //       if (mid == null) {
  //         continue;
  //       }
  //       // bool? isRemoved = map["isRemoved"];
  //       // if (isRemoved != null && isRemoved == true) {
  //       //   logHolder.log("removed data skipped($mid!", level: 1);
  //       //   continue;
  //       // }
  //       ContentsModel contents = ContentsModel.createEmptyModel(mid, accProperty.mid);
  //       contents.deserialize(map);
  //       retval[contents.order.value] = contents;
  //       idx++;
  //       logHolder.log('getContents($idx)th complete', level: 1);
  //     }
  //   } catch (e) {
  //     logHolder.log("Data error $e", level: 6);
  //   }
  //   return retval;
  // }

  static Future<void> saveAll() async {
    _storeChangedDataOnly(
        bookManagerHolder!.defaultBook!, "creta_book", bookManagerHolder!.defaultBook!.serialize());

    for (PageModel page in pageManagerHolder!.orderMap.values) {
      if (page.isRemoved.value == false) {
        _storeChangedDataOnly(page, "creta_page", page.serialize());
      }
    }
    for (ACC acc in accManagerHolder!.orderMap.values) {
      if (acc.accModel.isRemoved.value == false) {
        _storeChangedDataOnly(acc.accModel, "creta_acc", acc.serialize());
      }

      for (ContentsModel contents in acc.accChild.playManager.getModelList()) {
        if (contents.isRemoved.value == false) {
          if (1 == await _storeChangedDataOnly(contents, "creta_contents", contents.serialize())) {
            if (contents.file != null &&
                (contents.remoteUrl == null || contents.remoteUrl!.isEmpty)) {
              // upload 되어 있지 않으므로 업로드한다.
              if (saveManagerHolder != null) {
                saveManagerHolder!.pushUploadContents(contents);
              }
            }
          }
        }
      }
    }
  }

  static bool isBook(String mid) {
    return (mid.length > bookPrefix.length && mid.substring(0, bookPrefix.length) == bookPrefix);
  }

  static bool isPage(String mid) {
    return (mid.length > pagePrefix.length && mid.substring(0, pagePrefix.length) == pagePrefix);
  }

  static bool isACC(String mid) {
    return (mid.length > accPrefix.length && mid.substring(0, accPrefix.length) == accPrefix);
  }

  static bool isContents(String mid) {
    return (mid.length > contentsPrefix.length &&
        mid.substring(0, contentsPrefix.length) == contentsPrefix);
  }

  static Future<bool> save(String mid) async {
    logHolder.log('save($mid)', level: 5);
    int retval = 1;
    if (mid == bookManagerHolder!.defaultBook!.mid) {
      logHolder.log("save mid($mid)", level: 5);
      retval = await _storeChangedDataOnly(bookManagerHolder!.defaultBook!, "creta_book",
          bookManagerHolder!.defaultBook!.serialize());
      logHolder.log("save mid($mid)=$retval", level: 1);
      return (retval == 1);
    }

    if (pageManagerHolder == null) {
      logHolder.log("pageManagerHolder is not init", level: 6);
      return false;
    }
    if (isPage(mid)) {
      for (PageModel page in pageManagerHolder!.pageMap.values) {
        if (page.mid == mid) {
          retval = await _storeChangedDataOnly(page, "creta_page", page.serialize());
        }
      }
      return (retval == 1);
    }
    if (accManagerHolder == null) {
      logHolder.log("accManagerHolder is not init", level: 6);
      return false;
    }
    if (isACC(mid)) {
      logHolder.log("before save mid($mid)", level: 1);

      for (ACC acc in accManagerHolder!.accMap.values) {
        if (acc.accModel.mid == mid) {
          logHolder.log("my mid($mid)", level: 1);
          retval = await _storeChangedDataOnly(acc.accModel, "creta_acc", acc.serialize());
        }
      }
      logHolder.log("after save mid($mid)", level: 1);
      return (retval == 1);
    }

    if (isContents(mid)) {
      for (ACC acc in accManagerHolder!.orderMap.values) {
        if (acc.accModel.isRemoved.value == true) continue;
        //for (ContentsModel contents in acc.accChild.playManager.getModelList()) {
        ContentsModel? contents = acc.accChild.playManager.findContents(mid);
        if (contents == null) {
          continue;
        }
        logHolder.log('remoteUrl=${contents.remoteUrl}', level: 5);
        retval = await _storeChangedDataOnly(contents, "creta_contents", contents.serialize());
        if (1 == retval) {
          if (contents.file != null &&
              (contents.remoteUrl == null || contents.remoteUrl!.isEmpty)) {
            // upload 되어 있지 않으므로 업로드한다.
            if (saveManagerHolder != null) {
              saveManagerHolder!.pushUploadContents(contents);
            }
          }
        }
        //}
      }
    }

    return (retval == 1);
  }

  static Future<bool> saveModel(AbsModel model) async {
    int retval = 1;
    String tableName = '';
    if (isBook(model.mid)) {
      tableName = "creta_book";
    } else if (isPage(model.mid)) {
      tableName = "creta_page";
    } else if (isACC(model.mid)) {
      tableName = "creta_acc";
    } else if (isContents(model.mid)) {
      tableName = "creta_contents";
    }
    if (tableName.isNotEmpty) {
      retval = await _storeChangedDataOnly(model, tableName, model.serialize());
      logHolder.log("create mid(${model.mid})=$retval", level: 5);
    }
    return (retval == 1);
  }

  static Future<int> _storeChangedDataOnly(
      AbsModel model, String tableName, Map<String, dynamic> data) async {
    if (model.checkDirty(data)) {
      //data["updateTime"] = DateTime.now();
      data["updateTime"] = DateTime.now().toString();
      bool succeed = await CretaRTDB(tableName).setData(model.mid, data);
      model.clearDirty(succeed);
      if (succeed) {
        logHolder.log('succeed $tableName(${model.mid}) save', level: 1);
        return 1;
      }
      logHolder.log('fail !! $tableName(${model.mid}) save', level: 6);
      return -1;
    }
    logHolder.log('nothing changed !!! $tableName(${model.mid})', level: 1);
    return 0;
  }

  static Future<bool> removeBook(BookModel book) async {
    logHolder.log('removeBook(${book.mid})', level: 5);
    //List<PageModel> pageList = await getPages(book.mid);
    List<PageModel> pageList = bookManagerHolder!.defaultBook!.pageList;
    for (PageModel page in pageList) {
      if (page.isRemoved.value == true) continue;
      for (ACCProperty accModel in page.accModelMap.values) {
        for (ContentsModel contents in accModel.contentsMap.values) {
          _storeIsRemovedOnly(contents, "creta_contents");
        }
        _storeIsRemovedOnly(accModel, "creta_acc");
      }
      _storeIsRemovedOnly(page, "creta_page");
    }
    return await _storeIsRemovedOnly(book, "creta_book");
  }

  static Future<bool> _storeIsRemovedOnly(AbsModel model, String tableName) async {
    Map<String, dynamic> data = model.serialize();
    //data["updateTime"] = DateTime.now();
    data["updateTime"] = DateTime.now().toString();
    data["isRemoved"] = true;
    bool succeed = await CretaRTDB(tableName).setData(model.mid, data);
    if (succeed) {
      logHolder.log('succeed $tableName($model.mid) isRemove=true', level: 1);
      return true;
    }
    return false;
  }
}
