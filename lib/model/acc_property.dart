// ignore_for_file: prefer_final_fields
import 'package:flutter_neumorphic_null_safety/flutter_neumorphic.dart';
import '../common/undo/undo.dart';
import '../constants/styles.dart';
import '../model/models.dart';
import '../model/model_enums.dart';
import 'contents.dart';
import 'pages.dart';

enum CursorType {
  pointer,
  move,
  neResize,
  ncResize,
  nwResize,
  mwResize,
  swResize,
  scResize,
  seResize,
  meResize,

  neRadius,
  nwRadius,
  seRadius,
  swRadius,
}

//class ACCProperty extends ChangeNotifier {
class ACCProperty extends AbsModel {
  static Map<String, dynamic> sampleData = {
    "accType": 0,
    "animeType": 0,
    "bgColor": "Color(0xffd9d9d9)",
    "borderColor": "Color(0x00000000)",
    "borderWidth": 0,
    "boxType": 1,
    "containerOffset_dx": 352.0815003473027,
    "containerOffset_dy": 104.45473489233615,
    "containerSize_height": 360,
    "containerSize_width": 640,
    "contentRotate": false,
    "depth": 0,
    "fullscreen": false,
    "glassFill": 0,
    "hashTag": "",
    "intensity": 0.8,
    "isFixedRatio": false,
    "isRemoved": false,
    "lightSource_dx": -1,
    "lightSource_dy": -1,
    "mid": "ACC=74912c15-df8c-4fb2-a767-551da6c44f06",
    "opacity": 1,
    "order": 3,
    "parentMid": PageModel.sampleData["mid"]!,
    "primary": false,
    "radiusAll": 0,
    "radiusBottomLeft": 0,
    "radiusBottomRight": 0,
    "radiusTopLeft": 0,
    "radiusTopRight": 0,
    "resizable": true,
    "rotate": 0,
    "sourceRatio": false,
    "type": 3,
    "updateTime": "2022-06-28 15:21:46.220"
  };

  ACCType accType = ACCType.normal;

  //late UndoAble<bool> visible;
  late UndoAble<bool> resizable;
  late UndoAble<AnimeType> animeType;
  late UndoAble<double> radiusAll;
  late UndoAble<double> radiusTopLeft;
  late UndoAble<double> radiusTopRight;
  late UndoAble<double> radiusBottomLeft;
  late UndoAble<double> radiusBottomRight;

  late UndoAble<bool> primary;
  late UndoAble<bool> fullscreen;
  late UndoAble<Offset> containerOffset;
  late UndoAble<Size> containerSize;
  late UndoAble<double> rotate;
  late UndoAble<bool> contentRotate;
  late UndoAble<double> opacity;
  late UndoAble<bool> sourceRatio;
  late UndoAble<bool> isFixedRatio;
  late UndoAble<double> glassFill;
  late UndoAble<Color> bgColor;
  late UndoAble<Color> borderColor;
  late UndoAble<double> borderWidth;
  late UndoAble<LightSource> lightSource;
  late UndoAble<double> depth;
  late UndoAble<double> intensity;
  late UndoAble<BoxType> boxType;

  Map<String, ContentsModel> contentsMap = {}; // db get 전용

  ACCProperty({required ModelType type, required String parent, this.accType = ACCType.normal})
      : super(type: type, parent: parent) {
    //visible = UndoAble<bool>(true, mid);
    resizable = UndoAble<bool>(true, mid);
    animeType = UndoAble<AnimeType>(AnimeType.none, mid);
    radiusAll = UndoAble<double>(0, mid);
    radiusTopLeft = UndoAble<double>(0, mid);
    radiusTopRight = UndoAble<double>(0, mid);
    radiusBottomLeft = UndoAble<double>(0, mid);
    radiusBottomRight = UndoAble<double>(0, mid);

    primary = UndoAble<bool>(false, mid);
    fullscreen = UndoAble<bool>(false, mid);
    containerOffset = UndoAble<Offset>(const Offset(0, 0), mid); // 생성자에서 정한다.
    containerSize = UndoAble<Size>(const Size(0, 0), mid); // 생성자에서 정한다.
    rotate = UndoAble<double>(0, mid);
    contentRotate = UndoAble<bool>(false, mid);
    opacity = UndoAble<double>(1, mid);
    sourceRatio = UndoAble<bool>(false, mid);
    isFixedRatio = UndoAble<bool>(false, mid);
    glassFill = UndoAble<double>(0, mid);
    bgColor = UndoAble<Color>(MyColors.accBg, mid);
    borderColor = UndoAble<Color>(Colors.transparent, mid);
    borderWidth = UndoAble<double>(0, mid);
    lightSource = UndoAble<LightSource>(LightSource.topLeft, mid);
    depth = UndoAble<double>(0, mid);
    intensity = UndoAble<double>(0.8, mid);
    boxType = UndoAble<BoxType>(BoxType.rountRect, mid);

    save();
  }

  ACCProperty.copy(ACCProperty src, String parentId) : super(parent: parentId, type: src.type) {
    super.copy(src, parentId);
    //visible = UndoAble<bool>(src.visible.value, mid);
    accType = src.accType;
    resizable = UndoAble<bool>(src.resizable.value, mid);
    animeType = UndoAble<AnimeType>(src.animeType.value, mid);
    radiusAll = UndoAble<double>(src.radiusAll.value, mid);
    radiusTopLeft = UndoAble<double>(src.radiusTopLeft.value, mid);
    radiusTopRight = UndoAble<double>(src.radiusTopRight.value, mid);
    radiusBottomLeft = UndoAble<double>(src.radiusBottomLeft.value, mid);
    radiusBottomRight = UndoAble<double>(src.radiusBottomRight.value, mid);

    primary = UndoAble<bool>(src.primary.value, mid);
    fullscreen = UndoAble<bool>(src.fullscreen.value, mid);
    containerOffset = UndoAble<Offset>(src.containerOffset.value, mid);
    containerSize = UndoAble<Size>(src.containerSize.value, mid);
    rotate = UndoAble<double>(src.rotate.value, mid);
    contentRotate = UndoAble<bool>(src.contentRotate.value, mid);
    opacity = UndoAble<double>(src.opacity.value, mid);
    sourceRatio = UndoAble<bool>(src.sourceRatio.value, mid);
    isFixedRatio = UndoAble<bool>(src.isFixedRatio.value, mid);
    glassFill = UndoAble<double>(src.glassFill.value, mid);
    bgColor = UndoAble<Color>(src.bgColor.value, mid);
    borderColor = UndoAble<Color>(src.borderColor.value, mid);
    borderWidth = UndoAble<double>(src.borderWidth.value, mid);
    lightSource = UndoAble<LightSource>(src.lightSource.value, mid);
    depth = UndoAble<double>(src.depth.value, mid);
    intensity = UndoAble<double>(src.intensity.value, mid);
    boxType = UndoAble<BoxType>(src.boxType.value, mid);
  }

  ACCProperty.createEmptyModel(String srcMid, String pMid)
      : super(type: ModelType.acc, parent: pMid) {
    super.changeMid(srcMid);
    //visible = UndoAble<bool>(true, srcMid);
    resizable = UndoAble<bool>(true, srcMid);
    animeType = UndoAble<AnimeType>(AnimeType.none, srcMid);
    radiusAll = UndoAble<double>(0, srcMid);
    radiusTopLeft = UndoAble<double>(0, srcMid);
    radiusTopRight = UndoAble<double>(0, srcMid);
    radiusBottomLeft = UndoAble<double>(0, srcMid);
    radiusBottomRight = UndoAble<double>(0, srcMid);

    primary = UndoAble<bool>(false, srcMid);
    fullscreen = UndoAble<bool>(false, srcMid);
    containerOffset = UndoAble<Offset>(const Offset(100, 100), srcMid);
    containerSize = UndoAble<Size>(const Size(640, 480), srcMid);
    rotate = UndoAble<double>(0, srcMid);
    contentRotate = UndoAble<bool>(false, srcMid);
    opacity = UndoAble<double>(1, srcMid);
    sourceRatio = UndoAble<bool>(false, srcMid);
    isFixedRatio = UndoAble<bool>(false, srcMid);
    glassFill = UndoAble<double>(0, srcMid);
    bgColor = UndoAble<Color>(MyColors.accBg, srcMid);
    borderColor = UndoAble<Color>(Colors.transparent, srcMid);
    borderWidth = UndoAble<double>(0, srcMid);
    lightSource = UndoAble<LightSource>(LightSource.topLeft, srcMid);
    depth = UndoAble<double>(0, srcMid);
    intensity = UndoAble<double>(0.8, srcMid);
    boxType = UndoAble<BoxType>(BoxType.rountRect, srcMid);
  }

  @override
  void deserialize(Map<String, dynamic> map) {
    super.deserialize(map);
    accType = intToAccType(map["accType"] ?? 0);
    animeType.set(intToAnimeType(map["animeType"]), save: false);

    //visible.set(map["visible"], save: false);
    resizable.set(map["resizable"], save: false);
    radiusAll.set(map["radiusAll"], save: false);
    radiusTopLeft.set(map["radiusTopLeft"], save: false);
    radiusTopRight.set(map["radiusTopRight"], save: false);
    radiusBottomLeft.set(map["radiusBottomLeft"], save: false);
    radiusBottomRight.set(map["radiusBottomRight"], save: false);
    primary.set(map["primary"], save: false);
    fullscreen.set(map["fullscreen"], save: false);

    containerOffset.set(Offset(map["containerOffset_dx"] ?? 100, map["containerOffset_dy"] ?? 100),
        save: false);
    containerSize.set(Size(map["containerSize_width"] ?? 640, map["containerSize_height"] ?? 480),
        save: false);
    rotate.set(map["rotate"], save: false);
    contentRotate.set(map["contentRotate"], save: false);
    opacity.set(map["opacity"], save: false);
    sourceRatio.set(map["sourceRatio"], save: false);
    isFixedRatio.set(map["isFixedRatio"], save: false);
    glassFill.set(map["glassFill"] ?? 0, save: false);
    String? colorStr = map["bgColor"];
    if (colorStr != null && colorStr.length > 16) {
      // 'Color(0x000000ff)';
      bgColor.set(Color(int.parse(colorStr.substring(8, 16), radix: 16)), save: false);
    }
    String? borderColorStr = map["borderColor"];
    if (borderColorStr != null && borderColorStr.length > 16) {
      // 'Color(0x000000ff)';
      borderColor.set(Color(int.parse(borderColorStr.substring(8, 16), radix: 16)), save: false);
    }
    borderWidth.set(map["borderWidth"], save: false);
    lightSource.set(LightSource(map["lightSource_dx"] ?? -1, map["lightSource_dy"] ?? -1),
        save: false);
    depth.set(map["depth"], save: false);
    intensity.set(map["intensity"], save: false);
    boxType.set(intToBoxType(map["boxType"]), save: false);
  }

  ACCProperty makeCopy(String newParentId) {
    return ACCProperty.copy(this, newParentId)..saveModel();
  }

  @override
  Map<String, dynamic> serialize() {
    return super.serialize()
      ..addEntries({
        "accType": accTypeToInt(accType),
        "animeType": animeTypeToInt(animeType.value),
        //"visible": visible.value,
        "resizable": resizable.value,
        "radiusAll": radiusAll.value,
        "radiusTopLeft": radiusTopLeft.value,
        "radiusTopRight": radiusTopRight.value,
        "radiusBottomLeft": radiusBottomLeft.value,
        "radiusBottomRight": radiusBottomRight.value,
        "primary": primary.value,
        "fullscreen": fullscreen.value,
        "containerOffset_dx": containerOffset.value.dx,
        "containerOffset_dy": containerOffset.value.dy,
        "containerSize_width": containerSize.value.width,
        "containerSize_height": containerSize.value.height,
        "rotate": rotate.value,
        "contentRotate": contentRotate.value,
        "opacity": opacity.value,
        "sourceRatio": sourceRatio.value,
        "isFixedRatio": isFixedRatio.value,
        "glassFill": glassFill.value,
        "bgColor": bgColor.value.toString(),
        "borderColor": borderColor.value.toString(),
        "borderWidth": borderWidth.value,
        "lightSource_dx": lightSource.value.dx,
        "lightSource_dy": lightSource.value.dy,
        "depth": depth.value,
        "intensity": intensity.value,
        "boxType": boxTypeToInt(boxType.value),
      }.entries);
  }
}
