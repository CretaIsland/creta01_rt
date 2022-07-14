//import 'package:uuid/uuid.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:flutter/material.dart';

import '../common/util/logger.dart';
import '../common/undo/undo.dart';
import '../common/util/my_utils.dart';
import '../constants/styles.dart';
import 'acc_property.dart';
import 'models.dart';
import 'model_enums.dart';

class ContentsModel extends AbsModel {
  static Map<String, dynamic> sampleData = {
    "align": 2,
    "aniType": 0,
    "anyDuration": 0,
    "aspectRatio": 1.7777777777777777,
    "bytes": 12978395,
    "contentsType": 0,
    "font": "Pretendard",
    "fontColor": "Color(0xff000000)",
    "fontSize": 14,
    "glassFill": 0,
    "hashTag": "",
    "isAutoSize": true,
    "isBold": false,
    "isDynamicSize": false,
    "isItalic": false,
    "isRemoved": false,
    "isTTS": false,
    "lang": "kr",
    "lastModifiedTime": "",
    "letterSpacing": 0,
    "line": 0,
    "mid": "Con=0043f218-37df-4889-8710-c186cfcf9917",
    "mime": "video/mp4",
    "mute": true,
    "name": "creep12.mp4",
    "opacity": 1,
    "order": 36,
    "outLineColor": "Color(0x00000000)",
    "outLineWidth": 0,
    "parentMid": ACCProperty.sampleData["mid"]!,
    "playTime": 5000,
    "prevPlayTime": 5000,
    "remoteUrl": "https://www.devcreta.tk/media/b49@sqisoft.com/MTI5NzgzOTVfY3JlZXAxMi5tcDQ",
    "shadowBlur": 0,
    "shadowColor": "Color(0x00000000)",
    "shadowIntensity": 0.5,
    "subList": "",
    "thumbnail": "https://www.devcreta.tk/thumbnail/b49@sqisoft.com/MTI5NzgzOTVfY3JlZXAxMi5qcGc",
    "type": 4,
    "updateTime": "2022-06-28 15:21:46.220",
    "url": "",
    "videoPlayTime": 295404,
    "volume": 100,
    "wordSpacing": 0
  };

  double prevShadowBlur = 0;
  TextAniType prevAniType = TextAniType.none;
  Color prevFontColor = Colors.transparent;
  double prevOutLineWidth = 0;

  late String name; // aaa.jpg
  late int bytes;
  late String url;
  late String mime;
  File? file;
  String? remoteUrl;
  String? thumbnail;
  ContentsType contentsType = ContentsType.free;
  String lastModifiedTime = "";

  late UndoAble<String> subList;
  late UndoAble<double> playTime; // 1000 분의 1초 milliseconds
  late UndoAble<double> videoPlayTime; // 1000 분의 1초 milliseconds
  late UndoAble<bool> mute;
  late UndoAble<double> volume;
  late UndoAble<double> aspectRatio;
  late UndoAble<bool> isDynamicSize; // 동영상의 크기에 맞게 frame 사이즈를 변경해야 하는 경우

// text 관련
  late UndoAble<String> font;
  late UndoAble<bool> isBold; //bold
  late UndoAble<bool> isAutoSize; //자동 크기
  late UndoAble<double> glassFill; // 글라스질
  late UndoAble<double> opacity; // 투명도
  late UndoAble<double> fontSize;
  late UndoAble<Color> fontColor;
  late UndoAble<Color> shadowColor;
  late UndoAble<double> shadowBlur;
  late UndoAble<double> shadowIntensity; //opactity 0..1 1에 가까울수록 진해진다.
  late UndoAble<double> outLineWidth;
  late UndoAble<Color> outLineColor;
  late UndoAble<bool> isItalic;
  late UndoAble<TextLine> line;
  late UndoAble<double> letterSpacing;
  late UndoAble<double> wordSpacing;
  late UndoAble<TextAniType> aniType;
  late UndoAble<TextAlign> align; // 정렬
  late UndoAble<double> anyDuration;
  late UndoAble<bool> isTTS;
  late UndoAble<String> lang;

  ContentsModel(String accId,
      {required this.name, required this.mime, required this.bytes, required this.url, this.file})
      : super(type: ModelType.contents, parent: accId) {
    genType();

    subList = UndoAble<String>('', mid); // 1000 분의 1초 milliseconds
    playTime = UndoAble<double>(5000, mid); // 1000 분의 1초 milliseconds
    videoPlayTime = UndoAble<double>(5000, mid); // 1000 분의 1초 milliseconds
    mute = UndoAble<bool>(false, mid);
    volume = UndoAble<double>(100, mid);
    aspectRatio = UndoAble<double>(1, mid);
    isDynamicSize = UndoAble<bool>(false, mid); //

    font = UndoAble<String>(MyFonts.f1, mid);
    isBold = UndoAble<bool>(false, mid); //bold
    isAutoSize = UndoAble<bool>(true, mid); //bold
    glassFill = UndoAble<double>(0, mid);
    opacity = UndoAble<double>(1, mid);
    fontSize = UndoAble<double>(14, mid);
    fontColor = UndoAble<Color>(Colors.black, mid);
    shadowColor = UndoAble<Color>(Colors.transparent, mid);
    shadowBlur = UndoAble<double>(0, mid);
    shadowIntensity = UndoAble<double>(0.5, mid);
    outLineWidth = UndoAble<double>(0, mid);
    outLineColor = UndoAble<Color>(Colors.transparent, mid);
    isItalic = UndoAble<bool>(false, mid);
    line = UndoAble<TextLine>(TextLine.none, mid);
    letterSpacing = UndoAble<double>(0, mid);
    wordSpacing = UndoAble<double>(0, mid);
    aniType = UndoAble<TextAniType>(TextAniType.none, mid);
    align = UndoAble<TextAlign>(TextAlign.center, mid);
    anyDuration = UndoAble<double>(0, mid);
    isTTS = UndoAble<bool>(false, mid);
    lang = UndoAble<String>('kr', mid);

    save();
  }

  ContentsModel.copy(ContentsModel src, String parentId,
      {required this.name, required this.mime, required this.bytes, required this.url, this.file})
      : super(parent: parentId, type: src.type) {
    super.copy(src, parentId);
    subList = UndoAble<String>(src.subList.value, mid); // 1000 분의 1초 milliseconds
    playTime = UndoAble<double>(src.playTime.value, mid); // 1000 분의 1초 milliseconds
    videoPlayTime = UndoAble<double>(src.videoPlayTime.value, mid); // 1000 분의 1초 milliseconds
    mute = UndoAble<bool>(src.mute.value, mid);
    volume = UndoAble<double>(src.volume.value, mid);
    aspectRatio = UndoAble<double>(src.aspectRatio.value, mid);
    isDynamicSize = UndoAble<bool>(src.isDynamicSize.value, mid); //

    if (src.remoteUrl != null) remoteUrl = src.remoteUrl;
    if (src.thumbnail != null) thumbnail = src.thumbnail;
    contentsType = src.contentsType;
    lastModifiedTime = DateTime.now().toString();

    font = UndoAble<String>(src.font.value, mid);
    isBold = UndoAble<bool>(src.isBold.value, mid); //bold
    isAutoSize = UndoAble<bool>(src.isAutoSize.value, mid); //bold
    glassFill = UndoAble<double>(src.glassFill.value, mid);
    opacity = UndoAble<double>(src.opacity.value, mid);
    fontSize = UndoAble<double>(src.fontSize.value, mid);
    fontColor = UndoAble<Color>(src.fontColor.value, mid);
    shadowColor = UndoAble<Color>(src.shadowColor.value, mid);
    shadowBlur = UndoAble<double>(src.shadowBlur.value, mid);
    shadowIntensity = UndoAble<double>(src.shadowIntensity.value, mid);
    outLineWidth = UndoAble<double>(src.outLineWidth.value, mid);
    outLineColor = UndoAble<Color>(src.outLineColor.value, mid);
    isItalic = UndoAble<bool>(src.isItalic.value, mid);
    line = UndoAble<TextLine>(src.line.value, mid);
    letterSpacing = UndoAble<double>(src.letterSpacing.value, mid);
    wordSpacing = UndoAble<double>(src.wordSpacing.value, mid);
    align = UndoAble<TextAlign>(src.align.value, mid);
    aniType = UndoAble<TextAniType>(src.aniType.value, mid);
    anyDuration = UndoAble<double>(src.anyDuration.value, mid);
    isTTS = UndoAble<bool>(src.isTTS.value, mid);
    lang = UndoAble<String>(src.lang.value, mid);
  }

  ContentsModel.createEmptyModel(String srcMid, String pMid)
      : super(type: ModelType.contents, parent: pMid) {
    super.changeMid(srcMid);
    subList = UndoAble<String>('', srcMid); // 1000 분의 1초 milliseconds
    playTime = UndoAble<double>(5000, srcMid); // 1000 분의 1초 milliseconds
    videoPlayTime = UndoAble<double>(5000, srcMid); // 1000 분의 1초 milliseconds
    mute = UndoAble<bool>(false, srcMid);
    volume = UndoAble<double>(100, srcMid);
    aspectRatio = UndoAble<double>(1, srcMid);
    isDynamicSize = UndoAble<bool>(false, srcMid); //

    font = UndoAble<String>(MyFonts.f1, srcMid);
    isBold = UndoAble<bool>(false, srcMid); //bold
    isAutoSize = UndoAble<bool>(true, srcMid); //bold
    glassFill = UndoAble<double>(0, srcMid);
    opacity = UndoAble<double>(1, srcMid);
    fontSize = UndoAble<double>(14, srcMid);
    fontColor = UndoAble<Color>(Colors.black, srcMid);
    shadowColor = UndoAble<Color>(Colors.transparent, srcMid);
    shadowBlur = UndoAble<double>(0, srcMid);
    shadowIntensity = UndoAble<double>(0.5, srcMid);
    outLineWidth = UndoAble<double>(0, srcMid);
    outLineColor = UndoAble<Color>(Colors.transparent, srcMid);
    isItalic = UndoAble<bool>(false, srcMid);
    line = UndoAble<TextLine>(TextLine.none, srcMid);
    letterSpacing = UndoAble<double>(0, srcMid);
    wordSpacing = UndoAble<double>(0, srcMid);
    align = UndoAble<TextAlign>(TextAlign.center, srcMid);
    aniType = UndoAble<TextAniType>(TextAniType.none, srcMid);
    anyDuration = UndoAble<double>(0, srcMid);
    isTTS = UndoAble<bool>(false, srcMid);
    lang = UndoAble<String>('kr', srcMid);
  }

  // ignore: prefer_final_fields
  PlayState _playState = PlayState.none;
  // ignore: prefer_final_fields
  PlayState _prevState = PlayState.none;
  PlayState _manualState = PlayState.none;
  PlayState get playState => _playState;
  PlayState get prevState => _prevState;
  PlayState get manualState => _manualState;
  void setPlayState(PlayState s) {
    _prevState = _playState;
    _playState = s;
    _manualState = _playState;
  }

  void setManualState(PlayState s) {
    _manualState = s;
  }

  double progress = 0.0;

  //  playTime 이전 값, 영구히 에서 되돌릴때를 대비해서 가지고 있다.
  double prevPlayTime = 5000;
  void reservPlayTime() {
    prevPlayTime = playTime.value;
  }

  void resetPlayTime() {
    playTime.set(prevPlayTime);
  }

  @override
  void deserialize(Map<String, dynamic> map) {
    super.deserialize(map);
    name = map["name"];
    bytes = map["bytes"];
    //url = map["url"];  // url 의 desialize 하지 않는다.
    url = ""; // url 의 desialize 하지 않는다.  즉 DB 로 부터 가져오지 않는다.
    mime = map["mime"];

    subList.set(map["subList"] ?? '', save: false);
    playTime.set(map["playTime"], save: false);
    videoPlayTime.set(map["videoPlayTime"], save: false);
    mute.set(map["mute"], save: false);
    volume.set(map["volume"], save: false);
    contentsType = intToContentsType(map["contentsType"]);
    aspectRatio.set(map["aspectRatio"], save: false);
    isDynamicSize.set(map["isDynamicSize"] ?? false, save: false);
    lastModifiedTime = map["lastModifiedTime"];
    prevPlayTime = map["prevPlayTime"];
    remoteUrl = map["remoteUrl"] ?? '';
    thumbnail = map["thumbnail"] ?? '';

    font.set(map["font"] ?? MyFonts.f1, save: false);
    isBold.set(map["isBold"] ?? false, save: false);
    isAutoSize.set(map["isAutoSize"] ?? true, save: false);
    glassFill.set(map["glassFill"] ?? 0, save: false);
    opacity.set(map["opacity"] ?? 1, save: false);
    fontSize.set(map["fontSize"] ?? 14, save: false);
    fontColor.set(stringToColor(map["fontColor"], defaultColor: Colors.black), save: false);
    shadowColor.set(stringToColor(map["shadowColor"], defaultColor: Colors.transparent),
        save: false);
    shadowBlur.set(map["shadowBlur"] ?? 0, save: false);
    shadowIntensity.set(map["shadowIntensity"] ?? 0.5, save: false);
    outLineWidth.set(map["outLineWidth"] ?? 0, save: false);
    outLineColor.set(stringToColor(map["outLineColor"], defaultColor: Colors.transparent),
        save: false);
    isItalic.set(map["isItalic"] ?? false, save: false);
    line.set(intToTextLine(map["line"] ?? 0), save: false);
    letterSpacing.set(map["letterSpacing"] ?? 0, save: false);
    wordSpacing.set(map["wordSpacing"] ?? 0, save: false);
    align.set(intToTextAlign(map["align"] ?? 2), save: false);
    aniType.set(intToTextAniType(map["aniType"] ?? 0), save: false);
    anyDuration.set(map["anyDuration"] ?? 0, save: false);
    isTTS.set(map["isTTS"] ?? false, save: false);
    lang.set(map["lang"] ?? 'kr', save: false);
  }

  @override
  Map<String, dynamic> serialize() {
    return super.serialize()
      ..addEntries({
        "name": name,
        "bytes": bytes,
        "url": url,
        "mime": mime,
        "subList": subList.value,
        "playTime": playTime.value,
        "videoPlayTime": videoPlayTime.value,
        "mute": mute.value,
        "volume": volume.value,
        "contentsType": contentsTypeToInt(contentsType),
        "aspectRatio": aspectRatio.value,
        "isDynamicSize": isDynamicSize.value,
        "prevPlayTime": prevPlayTime,
        "lastModifiedTime": (file != null) ? file!.lastModifiedDate.toString() : '',
        "remoteUrl": (remoteUrl != null) ? remoteUrl : '',
        "thumbnail": (thumbnail != null) ? thumbnail : '',
        "font": font.value,
        "isBold": isBold.value,
        "isAutoSize": isAutoSize.value,
        "glassFill": glassFill.value,
        "opacity": opacity.value,
        "fontSize": fontSize.value,
        "fontColor": fontColor.value.toString(),
        "shadowColor": shadowColor.value.toString(),
        "shadowBlur": shadowBlur.value,
        "shadowIntensity": shadowIntensity.value,
        "outLineWidth": outLineWidth.value,
        "outLineColor": outLineColor.value.toString(),
        "isItalic": isItalic.value,
        "line": textLineToInt(line.value),
        "letterSpacing": letterSpacing.value,
        "wordSpacing": wordSpacing.value,
        "align": textAlignToInt(align.value),
        "aniType": textAniTypeToInt(aniType.value),
        "anyDuration": anyDuration.value,
        "isTTS": isTTS.value,
        "lang": lang.value,
      }.entries);
  }

  String get size {
    final kb = bytes / 1024;
    final mb = kb / 1024;

    return mb > 1 ? '${mb.toStringAsFixed(2)} MB' : '${kb.toStringAsFixed(2)} KB';
  }

  void genType() {
    if (mime.startsWith('video')) {
      logHolder.log('video type');
      contentsType = ContentsType.video;
    } else if (mime.startsWith('image')) {
      logHolder.log('image type');
      contentsType = ContentsType.image;
    } else if (mime.endsWith('sheet')) {
      logHolder.log('sheet type');
      contentsType = ContentsType.sheet;
    } else if (mime.startsWith('text')) {
      logHolder.log('text type');
      contentsType = ContentsType.text;
    } else if (mime.startsWith('youtube')) {
      logHolder.log('youtube type');
      contentsType = ContentsType.youtube;
    } else if (mime.startsWith('instagram')) {
      logHolder.log('instagram type');
      contentsType = ContentsType.instagram;
    } else if (mime.startsWith('pdf')) {
      logHolder.log('pdf type');
      contentsType = ContentsType.pdf;
    } else {
      logHolder.log('ERROR: unknown type');
      contentsType = ContentsType.free;
    }
  }

  bool isVideo() {
    return (contentsType == ContentsType.video);
  }

  bool isImage() {
    return (contentsType == ContentsType.image);
  }

  bool isText() {
    return (contentsType == ContentsType.text);
  }

  bool isSheet() {
    return (contentsType == ContentsType.sheet);
  }

  bool isYoutube() {
    return (contentsType == ContentsType.youtube);
  }

  bool isInstagram() {
    return (contentsType == ContentsType.instagram);
  }

  bool isWeb() {
    return (contentsType == ContentsType.web);
  }

  bool isPdf() {
    return (contentsType == ContentsType.pdf);
  }

  void printIt() {
    logHolder.log('name=[$name],mime=[$mime],bytes=[$bytes],url=[$url]');
  }
}
