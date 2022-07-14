// ignore_for_file: prefer_const_constructors
import 'package:creta01/model/acc_property.dart';
import 'package:flutter/material.dart';
import 'package:creta01/constants/strings.dart';
import 'package:creta01/common/util/logger.dart';
import 'package:creta01/common/undo/undo.dart';
import 'book.dart';
import 'models.dart';
import 'model_enums.dart';

class PageModel extends AbsModel {
  static Map<String, dynamic> sampleData = {
    "bgColor": "Color(0xffffffff)",
    "description": "",
    "hashTag": "#creta #sample",
    "height": 1080,
    "isCircle": true,
    "isRemoved": false,
    "isUsed": true,
    "mid": "Page=0965c164-bd01-4f26-a596-b47a0b042ee7",
    "order": 0,
    "parentMid": BookModel.sampleData["mid"]!,
    "shortCut": "",
    "type": 2,
    "updateTime": "2022-06-28 15:21:46.220",
    "width": 1920
  };

  Offset origin = Offset.zero;
  Size realSize = Size(400, 400);

  late UndoAble<int> width;
  late UndoAble<int> height;
  late UndoAble<String> description;
  late UndoAble<String> shortCut;
  late UndoAble<Color> bgColor;
  late UndoAble<bool> isUsed;
  late UndoAble<bool> isCircle;

  Map<String, ACCProperty> accModelMap = {}; // db get 전용

  PageModel.copy(PageModel src, String parentId) : super(parent: parentId, type: src.type) {
    super.copy(src, parentId);
    width = UndoAble<int>(src.width.value, mid);
    height = UndoAble<int>(src.height.value, mid);
    description = UndoAble<String>(src.description.value, mid);
    shortCut = UndoAble<String>(src.shortCut.value, mid);
    bgColor = UndoAble<Color>(src.bgColor.value, mid);
    isUsed = UndoAble<bool>(src.isUsed.value, mid);
    isCircle = UndoAble<bool>(src.isCircle.value, mid);
  }

  PageModel(String bookId) : super(type: ModelType.page, parent: bookId) {
    width = UndoAble<int>(1920, mid);
    height = UndoAble<int>(1080, mid);
    description = UndoAble<String>('', mid);
    shortCut = UndoAble<String>('', mid);
    bgColor = UndoAble<Color>(Colors.white, mid);
    isUsed = UndoAble<bool>(true, mid);
    isCircle = UndoAble<bool>(true, mid);

    save();
  }

  PageModel.createEmptyModel(String srcMid, String pMid)
      : super(type: ModelType.page, parent: pMid) {
    super.changeMid(srcMid);
    width = UndoAble<int>(1920, srcMid);
    height = UndoAble<int>(1080, srcMid);
    description = UndoAble<String>('', srcMid);
    shortCut = UndoAble<String>('', srcMid);
    bgColor = UndoAble<Color>(Colors.white, srcMid);
    isUsed = UndoAble<bool>(true, srcMid);
    isCircle = UndoAble<bool>(true, srcMid);
  }

  PageModel makeCopy(String newParendId) {
    return PageModel.copy(this, newParendId)..saveModel();
  }

  @override
  void deserialize(Map<String, dynamic> map) {
    super.deserialize(map);
    width.set(map["width"], save: false);
    height.set(map["height"], save: false);
    shortCut.set(map["shortCut"], save: false);
    description.set(map["description"], save: false);
    isUsed.set(map["isUsed"], save: false);
    isCircle.set(map["isCircle"], save: false);
    String? colorStr = map["bgColor"];
    if (colorStr != null && colorStr.length > 16) {
      // 'Color(0x000000ff)';
      bgColor.set(Color(int.parse(colorStr.substring(8, 16), radix: 16)), save: false);
    }
  }

  @override
  Map<String, dynamic> serialize() {
    return super.serialize()
      ..addEntries({
        "width": width.value,
        "height": height.value,
        "description": description.value,
        "shortCut": shortCut.value,
        "bgColor": bgColor.value.toString(),
        "isUsed": isUsed.value,
        "isCircle": isCircle.value,
      }.entries);
  }

  double getRatio() {
    return height.value / width.value;
  }

  String getDescription() {
    if (description.value.isEmpty) {
      return '${MyStrings.title} ${mid.substring(mid.length - 4)}';
    }
    return description.value;
  }

  void printIt() {
    logHolder.log(
        'id=[$mid],width=[$width.value],height=[$height.value],pageNo=[$order.value],description=[$description.value],shortCut=[$shortCut.value], bgColor=[$bgColor.value]');
  }

  Offset getPosition() {
    if (key.currentContext != null) {
      RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
      origin = box.localToGlobal(Offset.zero); //this is global position
    }
    return origin; // 보관된 origin 값을 리턴한다.
  }

  Size getSize() {
    return Size(width.value.toDouble(), height.value.toDouble());
  }

  Size getRealSize() {
    if (key.currentContext != null) {
      RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
      realSize = box.size; //this is global position
    }
    //logHolder.log("kye.currentContext is null $realSize", level: 5);
    return realSize; //보관된 realSize 값을 리턴한다.
  }

  Future<bool> waitPageBuild() async {
    while (key.currentContext == null) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    getRealSize(); // 페이지 크기 계산 다시 해준다.
    logHolder.log('page build complete !!!', level: 5);
    return true;
  }

  Size getRealRatio() {
    Size size = getRealSize();
    return Size(size.width / width.value, size.height / height.value);
  }
}
