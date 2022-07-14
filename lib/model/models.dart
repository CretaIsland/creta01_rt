import 'package:creta01/studio/save_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
//import '../common/util/logger.dart';
import '../../constants/constants.dart';
import '../common/undo/undo.dart';
import 'model_enums.dart';

abstract class AbsModel {
  static int lastPageIndex = 0;
  static int lastAccIndex = 0;
  static int lastContentsIndex = 0;
  final GlobalKey key = GlobalKey();

  late String _mid = '';
  String get mid => _mid; // mid 는 변경할 수 없으므로 set 함수는 없다.
  ModelType type = ModelType.none;
  DateTime updateTime = DateTime.now();

  late UndoAble<String> parentMid;
  late UndoAble<int> order;
  late UndoAble<String> hashTag;
  late UndoAble<bool> isRemoved;

  void genMid() {
    if (type == ModelType.page) {
      _mid = pagePrefix;
    } else if (type == ModelType.acc) {
      _mid = accPrefix;
    } else if (type == ModelType.contents) {
      _mid = contentsPrefix;
    } else if (type == ModelType.book) {
      _mid = bookPrefix;
    }
    _mid += const Uuid().v4();
  }

  AbsModel({required this.type, required String parent}) {
    genMid();
    parentMid = UndoAble<String>(parent, mid);
    order = UndoAble<int>(0, mid);
    hashTag = UndoAble<String>('', mid);
    isRemoved = UndoAble<bool>(false, mid);
  }

  void copy(AbsModel src, String pMid) {
    // copy 는 새로운 복사본 객체를 만드는
    genMid();
    type = src.type;
    parentMid = UndoAble<String>(pMid, mid);
    order = UndoAble<int>(src.order.value, mid);
    hashTag = UndoAble<String>(src.hashTag.value, mid);
    isRemoved = UndoAble<bool>(src.isRemoved.value, mid);
  }

  void copyFrom(AbsModel src) {
    // copyFrom 이 진짜 값을 복사하는 것이다.
    // 새로운 객체를 만들지 않는다.
    type = src.type;
    parentMid = UndoAble<String>(src.parentMid.value, mid);
    order = UndoAble<int>(src.order.value, mid);
    hashTag = UndoAble<String>(src.hashTag.value, mid);
    isRemoved = UndoAble<bool>(src.isRemoved.value, mid);
  }

  void changeMid(String newOne) {
    _mid = newOne;
    parentMid.changeMid(newOne);
    order.changeMid(newOne);
    hashTag.changeMid(newOne);
    isRemoved.changeMid(newOne);
  }

  void deserialize(Map<String, dynamic> map) {
    _mid = map["mid"] ?? '';
    parentMid.set(map["parentMid"] ?? '', save: false);
    type = intToType(map["type"] ?? 0);
    order.set(map["order"] ?? 0, save: false);
    hashTag.set(map["hashTag"] ?? '', save: false);
    isRemoved.set(map["isRemoved"] ?? false, save: false);
    //updateTime = map["updateTime"] == null ? DateTime.now().toString() : map["updateTime"].toDate();
    updateTime = map["updateTime"] == null ? DateTime.now() : DateTime.parse(map["updateTime"]);
  }

  Map<String, dynamic> serialize() {
    return {
      "mid": mid,
      "parentMid": parentMid.value,
      "type": typeToInt(type),
      "order": order.value,
      "hashTag": hashTag.value,
      "isRemoved": isRemoved.value,
      "updateTime": updateTime.toString(),
    };
  }

  // 모델과 상관없고,  Tree 가 초기에 펼쳐져있을지를 결정하기 위해 있을 뿐이다.
  bool expanded = true;

  // 모델의 내용이 변경되었을 때 true 값을 가진다.
  // ignore: prefer_final_fields
  bool _isDirty = false;
  bool get isDirty => _isDirty;
  void clearDirty(bool isClear) {
    _isDirty = !isClear;
  }

  // ignore: prefer_final_fields
  Map<String, dynamic> _oldMap = <String, dynamic>{};

  bool checkDirty(Map<String, dynamic> newMap) {
    if (mapEquals(_oldMap, newMap)) {
      _isDirty = false;
    } else {
      _isDirty = true;
    }
    _oldMap.addEntries(newMap.entries);
    return _isDirty;
  }

  bool isChanged(AbsModel newModel) {
    Map<String, dynamic> newMap = newModel.serialize();
    Map<String, dynamic> oldMap = serialize();
    return !mapEquals(newMap, oldMap);
  }

  void save() {
    // 객체가 Create 된것은 모두 Save 대상이다.
    if (saveManagerHolder != null) {
      saveManagerHolder!.pushChanged(mid, 'AbsModel');
    }
  }

  void saveModel() {
    // 객체가 Create 된것은 모두 Save 대상이다.
    if (saveManagerHolder != null) {
      saveManagerHolder!.pushCreated(this, 'saveModel');
    }
  }
}

// class ModelChanged extends ChangeNotifier {
//   static int changedPages = -1;

//   factory ModelChanged.sigleton() {
//     return ModelChanged();
//   }

//   ModelChanged() {
//     logHolder.log('PageModelChanged instantiate');
//   }

//   void repaintPages(int pageNo) {
//     changedPages = pageNo;
//     notifyListeners();
//   }
// }
