import 'dart:async';
//import 'package:creta01/book_manager.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:creta01/common/util/logger.dart';

//import '../creta_main.dart';
import '../model/acc_property.dart';
import '../model/book.dart';
import '../model/contents.dart';
import '../model/pages.dart';
import '../model/users.dart';

class CretaRTDB<T> {
  List<T> dataList = <T>[];
  final String colectionId;
  late DatabaseReference database;

  CretaRTDB(this.colectionId) {
    database = FirebaseDatabase.instance.ref();
  }

  Stream<List<T>> getList(
      {required String queryKey,
      required String queryValue,
      required T Function(String mid, String secondKey, Map<String, dynamic> value)
          deserializeFunction,
      required int Function(T, T)? sortFunction}) {
    logHolder.log('getList $colectionId $queryKey=$queryValue', level: 5);

    final dbStream = database.child(colectionId).orderByChild(queryKey).equalTo(queryValue).onValue;

    final streamToPub = dbStream.map((event) {
      logHolder.log('dbStream.map', level: 5);
      // if (event.snapshot.exists == false) {
      //   logHolder.log('creta_book not found', level: 5);
      //   return dataList;
      // }
      final dataMap = event.snapshot.value as Map<String, dynamic>;
      if (dataMap.isEmpty) {
        logHolder.log('book not found $queryKey=$queryValue', level: 5);
        return dataList;
      }

      dataMap.forEach((mapKey, mapValue) {
        bool isRemoved = mapValue["isRemoved"] ?? false;
        if (isRemoved) return;
        String? mid = mapValue["mid"] ?? '';
        //if (mid == null) return;
        //BookModel book = BookModel.createEmptyModel(mid, userId);
        //book.deserialize(value);
        dataList.add(deserializeFunction(mid!, queryValue, mapValue));
      });

      dataList.sort(
          // (a, b) => a.updateTime.compareTo(b.updateTime);
          sortFunction);

      //   dataList = dataMap.entries.map((ele) {
      //     String? mid = ele.value["mid"] ?? '';
      //     BookModel book = BookModel.createEmptyModel(mid!, userId);
      //     book.deserialize(ele.value);

      //     logHolder.log('book entries $mid', level: 5);
      //     return book;
      //   }).toList()
      //     ..sort((a, b) {
      //       return a.updateTime.compareTo(b.updateTime);
      //     });
      return dataList;
    });

    logHolder.log('dbStream return', level: 5);
    return streamToPub;
  }
}

class RTDbActions {
  static Future<void> createDefaultData(String userId) async {
    final database = FirebaseDatabase.instance.ref();

    await database
        .child('creta_user')
        .child('b49_sqisoft_com')
        //.push()
        .set(UserModel.sampleData)
        .then((value) => logHolder.log('creta_user created', level: 5))
        .catchError((error) => logHolder.log('creta_user : You got an error! $error', level: 5));

    await database
        .child('creta_book')
        .child(BookModel.sampleData['mid']!)
        //.push()
        .set(BookModel.sampleData)
        .then((value) => logHolder.log('creta_book created', level: 5))
        .catchError((error) => logHolder.log('creta_book : You got an error! $error', level: 5));

    await database
        .child('creta_page')
        .child(PageModel.sampleData['mid']!)
        //.push()
        .set(PageModel.sampleData)
        .then((value) => logHolder.log('creta_page created', level: 5))
        .catchError((error) => logHolder.log('creta_page : You got an error! $error', level: 5));

    await database
        .child('creta_acc')
        .child(ACCProperty.sampleData['mid']!)
        //.push()
        .set(ACCProperty.sampleData)
        .then((value) => logHolder.log('creta_acc created', level: 5))
        .catchError((error) => logHolder.log('creta_acc : You got an error! $error', level: 5));

    await database
        .child('creta_contents')
        .child(ContentsModel.sampleData['mid']!)
        //.push()
        .set(ContentsModel.sampleData)
        .then((value) => logHolder.log('creta_contents created', level: 5))
        .catchError(
            (error) => logHolder.log('creta_contents : You got an error! $error', level: 5));
  }

  static Stream<List<UserModel>> getUser(String userId) {
    return CretaRTDB<UserModel>('creta_user').getList(
        queryKey: 'id',
        queryValue: userId,
        //queryValue: userId.replaceAll(".", "_").replaceAll("@", "_"),
        deserializeFunction: (mid, secondKey, value) {
          UserModel book = UserModel(id: userId);
          book.name = value["name"] ?? "Lisa";
          return book;
        },
        sortFunction: (a, b) {
          return 1;
        });
  }

  static Stream<List<BookModel>> getMyBook(String userId) {
    return CretaRTDB<BookModel>('creta_book').getList(
        queryKey: 'userId',
        queryValue: userId,
        deserializeFunction: (mid, secondKey, value) {
          BookModel book = BookModel.createEmptyModel(mid, secondKey);
          book.deserialize(value);
          return book;
        },
        sortFunction: (a, b) {
          return b.updateTime.compareTo(a.updateTime);
        });
  }

  // static Stream<List<PageModel>> getPages(String bookMid) {
  //   logHolder.log('getPages', level: 5);

  //   if (bookManagerHolder!.defaultBook!.mid == bookMid) {
  //     bookManagerHolder!.defaultBook!.pageList.clear();
  //   }
  //   return CretaRTDB<PageModel>('creta_page').getList(
  //       queryKey: 'parentMid',
  //       queryValue: bookMid,
  //       deserializeFunction: (mid, secondKey, value) {
  //         PageModel page = PageModel.createEmptyModel(mid, secondKey);
  //         page.deserialize(value);
  //         //page.accPropertyList = getACCProperties(page);
  //         if (bookManagerHolder!.defaultBook!.mid == bookMid) {
  //           bookManagerHolder!.defaultBook!.pageList.add(page);
  //         }
  //         return page;
  //       },
  //       sortFunction: (a, b) {
  //         return a.updateTime.compareTo(b.updateTime);
  //       });
  // }

  // static Stream<List<ACCProperty>> getACCProperties(PageModel page) {
  //   return CretaRTDB<ACCProperty>('creta_acc').getList(
  //       queryKey: 'parentMid',
  //       queryValue: page.mid,
  //       deserializeFunction: (mid, secondKey, value) {
  //         ACCProperty accProperty = ACCProperty.createEmptyModel(mid, secondKey);
  //         accProperty.deserialize(value);
  //         //accProperty.contentsMap = await getContents(accProperty);
  //         return accProperty;
  //       },
  //       sortFunction: (a, b) {
  //         return a.updateTime.compareTo(b.updateTime);
  //       });
  // }

  // static Stream<List<ContentsModel>> getContents(ACCProperty accProperty) {
  //   return CretaRTDB<ContentsModel>('creta_contents').getList(
  //       queryKey: 'parentMid',
  //       queryValue: accProperty.mid,
  //       deserializeFunction: (mid, secondKey, value) {
  //         ContentsModel contents = ContentsModel.createEmptyModel(mid, secondKey);
  //         contents.deserialize(value);
  //         //retval[contents.order.value] = contents;
  //         return contents;
  //       },
  //       sortFunction: (a, b) {
  //         return a.updateTime.compareTo(b.updateTime);
  //       });
  // }

  //   static Future<SortedMap<int, ContentsModel>> getContents(ACCProperty accProperty) async {
//     SortedMap<int, ContentsModel> retval = SortedMap<int, ContentsModel>();
//     try {
//       QuerySnapshot<Object?> querySnapshot = await CretaDB('creta_contents')
//           .collectionRef
//           .where(
//             'parentMid',
//             isEqualTo: accProperty.mid,
//           )
//           .where('isRemoved', isEqualTo: false)
//           .orderBy('updateTime', descending: true)
//           .get();
//       List<dynamic> list = querySnapshot.docs;
//       // List<dynamic> list = await CretaDB('creta_contents')
//       //     .simpleQueryData(orderBy: 'updateTime', name: 'parentMid', value: accProperty.mid);
//       // logHolder.log('getContents(${list.length})', level: 1);
//       int idx = 0;
//       for (QueryDocumentSnapshot item in list) {
//         logHolder.log(item.data()!.toString(), level: 1);
//         Map<String, dynamic> map = item.data()! as Map<String, dynamic>;
//         String? mid = map["mid"];
//         if (mid == null) {
//           continue;
//         }
//         // bool? isRemoved = map["isRemoved"];
//         // if (isRemoved != null && isRemoved == true) {
//         //   logHolder.log("removed data skipped($mid!", level: 1);
//         //   continue;
//         // }
//         ContentsModel contents = ContentsModel.createEmptyModel(mid, accProperty.mid);
//         contents.deserialize(map);
//         retval[contents.order.value] = contents;
//         idx++;
//         logHolder.log('getContents($idx)th complete', level: 1);
//       }
//     } catch (e) {
//       logHolder.log("Data error $e", level: 6);
//     }
//     return retval;
//   }
}



//   static Future<List<ACCProperty>> getACCProperties(PageModel page) async {
//     List<ACCProperty> retval = [];
//     try {
//       QuerySnapshot<Object?> querySnapshot = await CretaDB('creta_acc')
//           .collectionRef
//           .where(
//             'parentMid',
//             isEqualTo: page.mid,
//           )
//           .where('isRemoved', isEqualTo: false)
//           .orderBy('updateTime', descending: true)
//           .get();
//       List<dynamic> list = querySnapshot.docs;
//       // List<dynamic> list = await CretaDB('creta_acc')
//       //     .simpleQueryData(orderBy: 'updateTime', name: 'parentMid', value: page.mid);
//       logHolder.log('getACCProperties(${list.length})', level: 1);

//       for (QueryDocumentSnapshot item in list) {
//         logHolder.log(item.data()!.toString(), level: 1);
//         Map<String, dynamic> map = item.data()! as Map<String, dynamic>;
//         String? mid = map["mid"];
//         if (mid == null) {
//           continue;
//         }
//         // bool? isRemoved = map["isRemoved"];
//         // if (isRemoved != null && isRemoved == true) {
//         //   logHolder.log("removed data skipped($mid!", level: 1);
//         //   continue;
//         // }
//         ACCProperty accProperty = ACCProperty.createEmptyModel(mid, page.mid);
//         accProperty.deserialize(map);
//         retval.add(accProperty);
//         accProperty.contentsMap = await getContents(accProperty);
//       }
//     } catch (e) {
//       logHolder.log("Data error $e", level: 6);
//     }
//     return retval;
//   }

// class RTDbActions {
//   static Future<void> createDefaultData(String userId) async {
//     logHolder.log('default creta_book created start 1', level: 5);

//     final database = FirebaseDatabase.instance.ref();

//     BookModel book = BookModel(MyStrings.initialName, userId, 'Creta creates', '#sample');
//     final Map<String, dynamic> defaultValue = book.serialize();
//     logHolder.log('default creta_book created start 3', level: 5);
//     await database
//         .child('creta_book')
//         .child(book.mid)
//         //.push()
//         .set(defaultValue)
//         .then((value) => logHolder.log('creta_book created', level: 5))
//         .catchError((error) => logHolder.log('You got an error! $error', level: 5));

//     logHolder.log('default creta_book created end', level: 5);
//   }

//   static Stream<List<BookModel>> getMyBook(String userId) {
//     final database = FirebaseDatabase.instance.ref();
//     logHolder.log('getMyBookStream $userId', level: 5);

//     final dbStream = database
//         .child('creta_book')
//         .orderByChild('userId')
//         .equalTo(userId)
//         .onValue;

//     final streamToPub = dbStream.map((event) {
//       logHolder.log('dbStream.map', level: 5);
//       List<BookModel> dataList = <BookModel>[];
//       // if (event.snapshot.exists == false) {
//       //   logHolder.log('creta_book not found', level: 5);
//       //   return dataList;
//       // }
//       final dataMap = event.snapshot.value as Map<String, dynamic>;
//       if (dataMap.isEmpty) {
//         logHolder.log('book not found $userId', level: 5);
//         return dataList;
//       }

//       dataMap.forEach((key, value) {
//         bool isRemoved = value["isRemoved"] ?? true;
//         if (isRemoved) return;
//         String? mid = value["mid"];
//         if (mid == null) return;
//         BookModel book = BookModel.createEmptyModel(mid, userId);
//         book.deserialize(value);
//         dataList.add(book);
//       });

//       dataList.sort((a, b) {
//         return a.updateTime.compareTo(b.updateTime);
//       });

//       //   dataList = dataMap.entries.map((ele) {
//       //     String? mid = ele.value["mid"] ?? '';
//       //     BookModel book = BookModel.createEmptyModel(mid!, userId);
//       //     book.deserialize(ele.value);

//       //     logHolder.log('book entries $mid', level: 5);
//       //     return book;
//       //   }).toList()
//       //     ..sort((a, b) {
//       //       return a.updateTime.compareTo(b.updateTime);
//       //     });
//       return dataList;
//     });

//     logHolder.log('dbStream return', level: 5);
//     return streamToPub;
//   }


  

//   static Future<List<PageModel>> getPages(String bookMid) async {
//     List<PageModel> retval = [];
//     try {
//       QuerySnapshot<Object?> querySnapshot = await CretaDB('creta_page')
//           .collectionRef
//           .where(
//             'parentMid',
//             isEqualTo: bookMid,
//           )
//           .where('isRemoved', isEqualTo: false)
//           .orderBy('updateTime', descending: true)
//           .get();
//       List<dynamic> list = querySnapshot.docs;
//       // List<dynamic> list = await CretaDB('creta_page')
//       //     .simpleQueryData(orderBy: 'updateTime', name: 'parentMid', value: bookMid);

//       logHolder.log('getPages(${list.length})', level: 1);

//       for (QueryDocumentSnapshot item in list) {
//         logHolder.log(item.data()!.toString(), level: 1);
//         Map<String, dynamic> map = item.data()! as Map<String, dynamic>;
//         String? mid = map["mid"];
//         if (mid == null) {
//           continue;
//         }
//         PageModel page = PageModel.createEmptyModel(mid, bookMid);
//         page.deserialize(map);
//         retval.add(page);
//         page.accPropertyList = await getACCProperties(page);
//       }
//     } catch (e) {
//       logHolder.log("Data error $e", level: 6);
//     }
//     return retval;
//   }

//   static Future<List<ACCProperty>> getACCProperties(PageModel page) async {
//     List<ACCProperty> retval = [];
//     try {
//       QuerySnapshot<Object?> querySnapshot = await CretaDB('creta_acc')
//           .collectionRef
//           .where(
//             'parentMid',
//             isEqualTo: page.mid,
//           )
//           .where('isRemoved', isEqualTo: false)
//           .orderBy('updateTime', descending: true)
//           .get();
//       List<dynamic> list = querySnapshot.docs;
//       // List<dynamic> list = await CretaDB('creta_acc')
//       //     .simpleQueryData(orderBy: 'updateTime', name: 'parentMid', value: page.mid);
//       logHolder.log('getACCProperties(${list.length})', level: 1);

//       for (QueryDocumentSnapshot item in list) {
//         logHolder.log(item.data()!.toString(), level: 1);
//         Map<String, dynamic> map = item.data()! as Map<String, dynamic>;
//         String? mid = map["mid"];
//         if (mid == null) {
//           continue;
//         }
//         // bool? isRemoved = map["isRemoved"];
//         // if (isRemoved != null && isRemoved == true) {
//         //   logHolder.log("removed data skipped($mid!", level: 1);
//         //   continue;
//         // }
//         ACCProperty accProperty = ACCProperty.createEmptyModel(mid, page.mid);
//         accProperty.deserialize(map);
//         retval.add(accProperty);
//         accProperty.contentsMap = await getContents(accProperty);
//       }
//     } catch (e) {
//       logHolder.log("Data error $e", level: 6);
//     }
//     return retval;
//   }

//   static Future<SortedMap<int, ContentsModel>> getContents(ACCProperty accProperty) async {
//     SortedMap<int, ContentsModel> retval = SortedMap<int, ContentsModel>();
//     try {
//       QuerySnapshot<Object?> querySnapshot = await CretaDB('creta_contents')
//           .collectionRef
//           .where(
//             'parentMid',
//             isEqualTo: accProperty.mid,
//           )
//           .where('isRemoved', isEqualTo: false)
//           .orderBy('updateTime', descending: true)
//           .get();
//       List<dynamic> list = querySnapshot.docs;
//       // List<dynamic> list = await CretaDB('creta_contents')
//       //     .simpleQueryData(orderBy: 'updateTime', name: 'parentMid', value: accProperty.mid);
//       // logHolder.log('getContents(${list.length})', level: 1);
//       int idx = 0;
//       for (QueryDocumentSnapshot item in list) {
//         logHolder.log(item.data()!.toString(), level: 1);
//         Map<String, dynamic> map = item.data()! as Map<String, dynamic>;
//         String? mid = map["mid"];
//         if (mid == null) {
//           continue;
//         }
//         // bool? isRemoved = map["isRemoved"];
//         // if (isRemoved != null && isRemoved == true) {
//         //   logHolder.log("removed data skipped($mid!", level: 1);
//         //   continue;
//         // }
//         ContentsModel contents = ContentsModel.createEmptyModel(mid, accProperty.mid);
//         contents.deserialize(map);
//         retval[contents.order.value] = contents;
//         idx++;
//         logHolder.log('getContents($idx)th complete', level: 1);
//       }
//     } catch (e) {
//       logHolder.log("Data error $e", level: 6);
//     }
//     return retval;
//   }

//   static Future<void> saveAll() async {
//     _storeChangedDataOnly(
//         bookManagerHolder!.defaultBook!, "creta_book", bookManagerHolder!.defaultBook!.serialize());

//     for (PageModel page in pageManagerHolder!.orderMap.values) {
//       if (page.isRemoved.value == false) {
//         _storeChangedDataOnly(page, "creta_page", page.serialize());
//       }
//     }
//     for (ACC acc in accManagerHolder!.orderMap.values) {
//       if (acc.accModel.isRemoved.value == false) {
//         _storeChangedDataOnly(acc.accModel, "creta_acc", acc.serialize());
//       }

//       for (ContentsModel contents in acc.accChild.playManager.getModelList()) {
//         if (contents.isRemoved.value == false) {
//           if (1 == await _storeChangedDataOnly(contents, "creta_contents", contents.serialize())) {
//             if (contents.file != null &&
//                 (contents.remoteUrl == null || contents.remoteUrl!.isEmpty)) {
//               // upload 되어 있지 않으므로 업로드한다.
//               if (saveManagerHolder != null) {
//                 saveManagerHolder!.pushUploadContents(contents);
//               }
//             }
//           }
//         }
//       }
//     }
//   }

//   static bool isBook(String mid) {
//     return (mid.length > bookPrefix.length && mid.substring(0, bookPrefix.length) == bookPrefix);
//   }

//   static bool isPage(String mid) {
//     return (mid.length > pagePrefix.length && mid.substring(0, pagePrefix.length) == pagePrefix);
//   }

//   static bool isACC(String mid) {
//     return (mid.length > accPrefix.length && mid.substring(0, accPrefix.length) == accPrefix);
//   }

//   static bool isContents(String mid) {
//     return (mid.length > contentsPrefix.length &&
//         mid.substring(0, contentsPrefix.length) == contentsPrefix);
//   }

//   static Future<bool> save(String mid) async {
//     logHolder.log('save($mid)', level: 5);
//     int retval = 1;
//     if (mid == bookManagerHolder!.defaultBook!.mid) {
//       logHolder.log("save mid($mid)", level: 5);
//       retval = await _storeChangedDataOnly(bookManagerHolder!.defaultBook!, "creta_book",
//           bookManagerHolder!.defaultBook!.serialize());
//       logHolder.log("save mid($mid)=$retval", level: 1);
//       return (retval == 1);
//     }

//     if (pageManagerHolder == null) {
//       logHolder.log("pageManagerHolder is not init", level: 6);
//       return false;
//     }
//     if (isPage(mid)) {
//       for (PageModel page in pageManagerHolder!.pageMap.values) {
//         if (page.mid == mid) {
//           retval = await _storeChangedDataOnly(page, "creta_page", page.serialize());
//         }
//       }
//       return (retval == 1);
//     }
//     if (accManagerHolder == null) {
//       logHolder.log("accManagerHolder is not init", level: 6);
//       return false;
//     }
//     if (isACC(mid)) {
//       logHolder.log("before save mid($mid)", level: 1);

//       for (ACC acc in accManagerHolder!.accMap.values) {
//         if (acc.accModel.mid == mid) {
//           logHolder.log("my mid($mid)", level: 1);
//           retval = await _storeChangedDataOnly(acc.accModel, "creta_acc", acc.serialize());
//         }
//       }
//       logHolder.log("after save mid($mid)", level: 1);
//       return (retval == 1);
//     }

//     if (isContents(mid)) {
//       for (ACC acc in accManagerHolder!.orderMap.values) {
//         if (acc.accModel.isRemoved.value == true) continue;
//         for (ContentsModel contents in acc.accChild.playManager.getModelList()) {
//           if (contents.mid != mid) {
//             continue;
//           }
//           retval = await _storeChangedDataOnly(contents, "creta_contents", contents.serialize());
//           if (1 == retval) {
//             if (contents.file != null &&
//                 (contents.remoteUrl == null || contents.remoteUrl!.isEmpty)) {
//               // upload 되어 있지 않으므로 업로드한다.
//               if (saveManagerHolder != null) {
//                 saveManagerHolder!.pushUploadContents(contents);
//               }
//             }
//           }
//         }
//       }
//     }

//     return (retval == 1);
//   }

//   static Future<bool> saveModel(AbsModel model) async {
//     int retval = 1;
//     String tableName = '';
//     if (isBook(model.mid)) {
//       tableName = "creta_book";
//     } else if (isPage(model.mid)) {
//       tableName = "creta_page";
//     } else if (isACC(model.mid)) {
//       tableName = "creta_acc";
//     } else if (isContents(model.mid)) {
//       tableName = "creta_contents";
//     }
//     if (tableName.isNotEmpty) {
//       retval = await _storeChangedDataOnly(model, tableName, model.serialize());
//       logHolder.log("create mid(${model.mid})=$retval", level: 5);
//     }
//     return (retval == 1);
//   }

//   static Future<int> _storeChangedDataOnly(
//       AbsModel model, String tableName, Map<String, dynamic> data) async {
//     if (model.checkDirty(data)) {
//       data["updateTime"] = DateTime.now();
//       bool succeed = await CretaDB(tableName).setData(model.mid, data);
//       model.clearDirty(succeed);
//       if (succeed) {
//         logHolder.log('succeed $tableName(${model.mid}) save', level: 1);
//         return 1;
//       }
//       logHolder.log('fail !! $tableName(${model.mid}) save', level: 6);
//       return -1;
//     }
//     logHolder.log('nothing changed !!! $tableName(${model.mid})', level: 1);
//     return 0;
//   }

//   static Future<bool> removeBook(BookModel book) async {
//     logHolder.log('removeBook(${book.mid})', level: 5);
//     List<PageModel> pageList = getPages(book.mid);
//     for (PageModel page in pageList) {
//       for (ACCProperty accModel in page.accPropertyList) {
//         for (ContentsModel contents in accModel.contentsMap.values) {
//           _storeIsRemovedOnly(contents, "creta_contents");
//         }
//         _storeIsRemovedOnly(accModel, "creta_acc");
//       }
//       _storeIsRemovedOnly(page, "creta_page");
//     }
//     return await _storeIsRemovedOnly(book, "creta_book");
//   }

//   static Future<bool> _storeIsRemovedOnly(AbsModel model, String tableName) async {
//     Map<String, dynamic> data = model.serialize();
//     data["updateTime"] = DateTime.now();
//     data["isRemoved"] = true;
//     bool succeed = await CretaDB(tableName).setData(model.mid, data);
//     if (succeed) {
//       logHolder.log('succeed $tableName($model.mid) isRemove=true', level: 1);
//       return true;
//     }
//     return false;
//   }
// }
