// import 'package:creta01/constants/strings.dart';
// import 'package:flutter/material.dart';
// import '../common/util/logger.dart';
// import '../common/undo/undo.dart';
//import '../constants/styles.dart';
//import 'package:creta01/model/users.dart';

import 'package:creta01/common/util/logger.dart';

import 'models.dart';
import 'model_enums.dart';
import '../common/undo/undo.dart';
import 'pages.dart';

// ignore: camel_case_types
class BookModel extends AbsModel {
  static Map<String, dynamic> sampleData = {
    "bookType": 0,
    "description": "You could do it simple and plain",
    "dislikeCount": 0,
    "hashTag": "#creta #sample",
    "isAutoPlay": true,
    "isRemoved": false,
    "isSilent": false,
    "likeCount": 0,
    "mid": "Book=fef4bfe2-2040-4350-bd5a-44911abde282",
    "name": "My First Creta Book",
    "order": 0,
    "parentMid": "",
    "readOnly": false,
    "scope": 0,
    "secretLevel": 0,
    "thumbnailAspectRatio": 1,
    "thumbnailType": 1,
    "thumbnailUrl":
        "https://www.devcreta.tk/thumbnail/b49@sqisoft.com/NTQ1OTc1NjVf7J6E7J6s67KULmpwZw",
    "type": 1,
    "updateTime": "2022-06-28 15:21:46.220",
    "userId": "b49@sqisoft.com",
    "viewCount": 0
  };

  late UndoAble<String> name;
  late UndoAble<ScopeType> scope;
  late UndoAble<SecretLevel> secretLevel;
  late UndoAble<bool> isSilent;
  late UndoAble<bool> isAutoPlay;
  late UndoAble<BookType> bookType;
  late UndoAble<String> description;
  late UndoAble<bool> readOnly;
  late UndoAble<String> thumbnailUrl;
  late UndoAble<ContentsType> thumbnailType;
  late UndoAble<double> thumbnailAspectRatio;
  late UndoAble<int> likeCount;
  late UndoAble<int> dislikeCount;
  late UndoAble<int> viewCount;
  String userId;

  List<PageModel> pageList = []; // db get 전용

  BookModel.createEmptyModel(String srcMid, this.userId) : super(type: ModelType.book, parent: '') {
    super.changeMid(srcMid);
    name = UndoAble<String>('', srcMid);
    thumbnailUrl = UndoAble<String>('', srcMid);
    thumbnailType = UndoAble<ContentsType>(ContentsType.free, srcMid);
    thumbnailAspectRatio = UndoAble<double>(1, srcMid);
    scope = UndoAble<ScopeType>(ScopeType.public, srcMid);
    secretLevel = UndoAble<SecretLevel>(SecretLevel.public, srcMid);
    isSilent = UndoAble<bool>(false, srcMid);
    isAutoPlay = UndoAble<bool>(false, srcMid);
    bookType = UndoAble<BookType>(BookType.signage, srcMid);
    readOnly = UndoAble<bool>(false, srcMid);
    likeCount = UndoAble<int>(0, srcMid);
    dislikeCount = UndoAble<int>(0, srcMid);
    viewCount = UndoAble<int>(0, srcMid);
    description =
        UndoAble<String>("You could do it simple and plain\n from 'Sure thing' of Miguel", srcMid);
  }

  BookModel(nameStr, this.userId, String desc, String hash)
      : super(type: ModelType.book, parent: '') {
    name = UndoAble<String>(nameStr, mid);
    thumbnailUrl = UndoAble<String>('', mid);
    thumbnailType = UndoAble<ContentsType>(ContentsType.free, mid);
    thumbnailAspectRatio = UndoAble<double>(1, mid);
    scope = UndoAble<ScopeType>(ScopeType.public, mid);
    secretLevel = UndoAble<SecretLevel>(SecretLevel.public, mid);
    isSilent = UndoAble<bool>(false, mid);
    isAutoPlay = UndoAble<bool>(false, mid);
    bookType = UndoAble<BookType>(BookType.signage, mid);
    readOnly = UndoAble<bool>(false, mid);
    likeCount = UndoAble<int>(0, mid);
    dislikeCount = UndoAble<int>(0, mid);
    viewCount = UndoAble<int>(0, mid);
    description =
        UndoAble<String>("You could do it simple and plain\n from 'Sure thing' of Miguel", mid);
    description.set(desc, save: false);
    hashTag.set(hash, save: false);
    save();
  }

  BookModel makeCopy(String newName) {
    BookModel newBook = BookModel(newName, userId, description.value, hashTag.value);
    newBook.bookType.set(bookType.value, save: false);
    newBook.scope.set(scope.value, save: false);
    newBook.secretLevel.set(secretLevel.value, save: false);
    newBook.isSilent.set(isSilent.value, save: false);
    newBook.isAutoPlay.set(isAutoPlay.value, save: false);
    newBook.readOnly.set(readOnly.value, save: false);
    newBook.thumbnailUrl.set(thumbnailUrl.value, save: false);
    newBook.thumbnailType.set(thumbnailType.value, save: false);
    newBook.thumbnailAspectRatio.set(thumbnailAspectRatio.value, save: false);
    logHolder.log('BookCopied(${newBook.mid}', level: 5);
    newBook.saveModel();
    return newBook;
  }

  @override
  void deserialize(Map<String, dynamic> map) {
    super.deserialize(map);
    name.set(map["name"] ?? '', save: false);
    userId = map["userId"] ?? '';
    scope.set(intToScopeType(map["scope"] ?? 0), save: false);
    secretLevel.set(intToSecretLevel(map["secretLevel"] ?? 0), save: false);
    isSilent.set(map["isSilent"] ?? false, save: false);
    isAutoPlay.set(map["isAutoPlay"] ?? false, save: false);
    readOnly.set(map["readOnly"] ?? false, save: false);
    bookType.set(intToBookType(map["bookType"] ?? BookType.none), save: false);
    description.set(map["description"] ?? '', save: false);
    thumbnailUrl.set(map["thumbnailUrl"] ?? '', save: false);
    thumbnailType.set(intToContentsType(map["thumbnailType"] ?? 99), save: false);
    thumbnailAspectRatio.set((map["thumbnailAspectRatio"] ?? 1), save: false);
    likeCount.set((map["likeCount"] ?? 0), save: false, noUndo: true);
    dislikeCount.set((map["dislikeCount"] ?? 0), save: false, noUndo: true);
    viewCount.set((map["viewCount"] ?? 0), save: false, noUndo: true);
  }

  @override
  Map<String, dynamic> serialize() {
    return super.serialize()
      ..addEntries({
        "name": name.value,
        "userId": userId,
        "scope": scopeTypeToInt(scope.value),
        "secretLevel": secretLevelToInt(secretLevel.value),
        "isSilent": isSilent.value,
        "isAutoPlay": isAutoPlay.value,
        "readOnly": readOnly.value,
        "bookType": bookTypeToInt(bookType.value),
        "description": description.value,
        "thumbnailUrl": thumbnailUrl.value,
        "thumbnailType": contentsTypeToInt(thumbnailType.value),
        "thumbnailAspectRatio": thumbnailAspectRatio.value,
        "likeCount": likeCount.value,
        "dislikeCount": dislikeCount.value,
        "viewCount": viewCount.value,
      }.entries);
  }
}
