import 'dart:ui';

import '../constants/strings.dart';

enum UserType {
  superAdmin,
  customerAdmin,
  siteAdimin,
}

enum ModelType { none, book, page, acc, contents }

int typeToInt(ModelType type) {
  switch (type) {
    case ModelType.none:
      return 0;
    case ModelType.book:
      return 1;
    case ModelType.page:
      return 2;
    case ModelType.acc:
      return 3;
    case ModelType.contents:
      return 4;
  }
}

ModelType intToType(int t) {
  switch (t) {
    case 0:
      return ModelType.none;
    case 1:
      return ModelType.book;
    case 2:
      return ModelType.page;
    case 3:
      return ModelType.acc;
    case 4:
      return ModelType.contents;
    default:
      return ModelType.none;
  }
}

enum BookType {
  signage,
  electricBoard,
  presentaion,
  nft,
  none,
}

int bookTypeToInt(BookType value) {
  switch (value) {
    case BookType.signage:
      return 0;
    case BookType.electricBoard:
      return 1;
    case BookType.presentaion:
      return 2;
    case BookType.nft:
      return 3;
    case BookType.none:
      return 99;
  }
}

String bookTypeToString(BookType value) {
  switch (value) {
    case BookType.signage:
      return MyStrings.signage;
    case BookType.electricBoard:
      return MyStrings.electricBoard;
    case BookType.presentaion:
      return MyStrings.presentation;
    case BookType.nft:
      return MyStrings.nft;
    case BookType.none:
      return MyStrings.none;
  }
}

BookType intToBookType(int t) {
  switch (t) {
    case 0:
      return BookType.signage;
    case 1:
      return BookType.electricBoard;
    case 2:
      return BookType.presentaion;
    case 3:
      return BookType.nft;
    default:
      return BookType.none;
  }
}

enum ContentsType {
  video,
  image,
  text,
  sheet,
  youtube,
  instagram,
  web,
  pdf,
  free,
}

int contentsTypeToInt(ContentsType value) {
  switch (value) {
    case ContentsType.video:
      return 0;
    case ContentsType.image:
      return 1;
    case ContentsType.text:
      return 2;
    case ContentsType.sheet:
      return 3;
    case ContentsType.youtube:
      return 4;
    case ContentsType.instagram:
      return 5;
    case ContentsType.web:
      return 6;
    case ContentsType.pdf:
      return 7;
    case ContentsType.free:
      return 99;
  }
}

ContentsType intToContentsType(int t) {
  switch (t) {
    case 0:
      return ContentsType.video;
    case 1:
      return ContentsType.image;
    case 2:
      return ContentsType.text;
    case 3:
      return ContentsType.sheet;
    case 4:
      return ContentsType.youtube;
    case 5:
      return ContentsType.instagram;
    case 6:
      return ContentsType.web;
    case 7:
      return ContentsType.pdf;
    default:
      return ContentsType.free;
  }
}

enum PlayState {
  none,
  init,
  start,
  pause,
  end,
  disposed,
  manualPlay,
}

enum AnimeType {
  none,
  carousel,
  flip,
  scale,
  enlarge,
}

int animeTypeToInt(AnimeType value) {
  switch (value) {
    case AnimeType.none:
      return 0;
    case AnimeType.carousel:
      return 1;
    case AnimeType.flip:
      return 2;
    case AnimeType.scale:
      return 3;
    case AnimeType.enlarge:
      return 4;
  }
}

AnimeType intToAnimeType(int t) {
  switch (t) {
    case 0:
      return AnimeType.none;
    case 1:
      return AnimeType.carousel;
    case 2:
      return AnimeType.flip;
    case 3:
      return AnimeType.scale;
    case 4:
      return AnimeType.enlarge;
    default:
      return AnimeType.none;
  }
}

enum BoxType {
  rect,
  rountRect,
  circle,
  beveled,
  stadium,
}

int boxTypeToInt(BoxType value) {
  switch (value) {
    case BoxType.rect:
      return 0;
    case BoxType.rountRect:
      return 1;
    case BoxType.circle:
      return 2;
    case BoxType.beveled:
      return 3;
    case BoxType.stadium:
      return 4;
  }
}

BoxType intToBoxType(int t) {
  switch (t) {
    case 0:
      return BoxType.rect;
    case 1:
      return BoxType.rountRect;
    case 2:
      return BoxType.circle;
    case 3:
      return BoxType.beveled;
    case 4:
      return BoxType.stadium;
    default:
      return BoxType.rect;
  }
}

enum InProgressType {
  done,
  saving,
  contentsUploading, /*thumbnailUploading*/
}

String inProgressTypeToMsg(InProgressType type) {
  switch (type) {
    case InProgressType.done:
      return MyStrings.doneMsg;
    case InProgressType.saving:
      return MyStrings.saving;
    case InProgressType.contentsUploading:
      return MyStrings.contentsUploading;
    // case InProgressType.thumbnailUploading:
    //   return MyStrings.thumbnailUploading;
  }
}

enum PropertyType {
  book,
  page,
  acc,
  contents,
  settings,
}

int propertyTypeToInt(PropertyType value) {
  switch (value) {
    case PropertyType.book:
      return 0;
    case PropertyType.page:
      return 1;
    case PropertyType.acc:
      return 2;
    case PropertyType.contents:
      return 3;
    case PropertyType.settings:
      return 4;
  }
}

enum ACCType {
  normal,
  youtube,
  text,
}

int accTypeToInt(ACCType value) {
  switch (value) {
    case ACCType.normal:
      return 0;
    case ACCType.youtube:
      return 1;
    case ACCType.text:
      return 2;
  }
}

ACCType intToAccType(int t) {
  switch (t) {
    case 0:
      return ACCType.normal;
    case 1:
      return ACCType.youtube;
    case 2:
      return ACCType.text;
  }
  return ACCType.normal;
}

enum ScopeType {
  public,
  onlyForMe,
  onlyForGroup,
  onlyForGroupAndChild,
  enterprise,
}

int scopeTypeToInt(ScopeType value) {
  switch (value) {
    case ScopeType.public:
      return 0;
    case ScopeType.onlyForMe:
      return 1;
    case ScopeType.onlyForGroup:
      return 2;
    case ScopeType.onlyForGroupAndChild:
      return 3;
    case ScopeType.enterprise:
      return 4;
  }
}

String scopeTypeToString(ScopeType value) {
  switch (value) {
    case ScopeType.public:
      return MyStrings.scopePublic;
    case ScopeType.onlyForMe:
      return MyStrings.scopeOnlyForMe;
    case ScopeType.onlyForGroup:
      return MyStrings.scopeOnlyForGroup;
    case ScopeType.onlyForGroupAndChild:
      return MyStrings.scopeOnlyForGroupAndChild;
    case ScopeType.enterprise:
      return MyStrings.scopeEnterprise;
  }
}

ScopeType intToScopeType(int t) {
  switch (t) {
    case 0:
      return ScopeType.public;
    case 1:
      return ScopeType.onlyForMe;
    case 2:
      return ScopeType.onlyForGroup;
    case 3:
      return ScopeType.onlyForGroupAndChild;
    case 4:
      return ScopeType.enterprise;
  }
  return ScopeType.public;
}

enum SecretLevel {
  public,
  confidential,
  thirdClass,
  secondClass,
  topClass,
}

int secretLevelToInt(SecretLevel value) {
  switch (value) {
    case SecretLevel.public:
      return 0;
    case SecretLevel.confidential:
      return 1;
    case SecretLevel.thirdClass:
      return 2;
    case SecretLevel.secondClass:
      return 3;
    case SecretLevel.topClass:
      return 4;
  }
}

SecretLevel intToSecretLevel(int t) {
  switch (t) {
    case 0:
      return SecretLevel.public;
    case 1:
      return SecretLevel.confidential;
    case 2:
      return SecretLevel.thirdClass;
    case 3:
      return SecretLevel.secondClass;
    case 4:
      return SecretLevel.topClass;
  }
  return SecretLevel.public;
}

String secretLevelToString(SecretLevel t) {
  switch (t) {
    case SecretLevel.public:
      return MyStrings.secretLevelPublic;
    case SecretLevel.confidential:
      return MyStrings.confidential;
    case SecretLevel.thirdClass:
      return MyStrings.thirdClass;
    case SecretLevel.secondClass:
      return MyStrings.secondClass;
    case SecretLevel.topClass:
      return MyStrings.topClass;
  }
}

enum TextLine {
  none,
  underline,
  overline,
  lineThrough,
}

int textLineToInt(TextLine value) {
  switch (value) {
    case TextLine.none:
      return 0;
    case TextLine.underline:
      return 1;
    case TextLine.overline:
      return 2;
    case TextLine.lineThrough:
      return 3;
  }
}

TextLine intToTextLine(int t) {
  switch (t) {
    case 0:
      return TextLine.none;
    case 1:
      return TextLine.underline;
    case 2:
      return TextLine.overline;
    case 3:
      return TextLine.lineThrough;
  }
  return TextLine.none;
}

TextDecoration getTextDecoration(TextLine value) {
  switch (value) {
    case TextLine.none:
      return TextDecoration.none;
    case TextLine.underline:
      return TextDecoration.underline;
    case TextLine.overline:
      return TextDecoration.overline;
    case TextLine.lineThrough:
      return TextDecoration.lineThrough;
  }
}

String textDecorationToString(TextLine value) {
  switch (value) {
    case TextLine.none:
      return MyStrings.none;
    case TextLine.underline:
      return MyStrings.underline;
    case TextLine.overline:
      return MyStrings.overline;
    case TextLine.lineThrough:
      return MyStrings.lineThrough;
  }
}

TextLine stringToTextDecoration(String value) {
  if (value == MyStrings.underline) {
    return TextLine.underline;
  }
  if (value == MyStrings.overline) {
    return TextLine.overline;
  }
  if (value == MyStrings.lineThrough) {
    return TextLine.lineThrough;
  }
  return TextLine.none;
}

enum TextAniType {
  none,
  tickerSide,
  tickerUpDown,
  rotate,
  fade,
  fidget,
  typewriter,
  wavy,
  colorize,
  textLiquidFill,
  bounce,
  shimmer,
}

int textAniTypeToInt(TextAniType value) {
  switch (value) {
    case TextAniType.none:
      return 0;
    case TextAniType.tickerSide:
      return 1;
    case TextAniType.tickerUpDown:
      return 2;
    case TextAniType.rotate:
      return 3;
    case TextAniType.fade:
      return 4;
    case TextAniType.fidget:
      return 5;
    case TextAniType.typewriter:
      return 6;
    case TextAniType.wavy:
      return 7;
    case TextAniType.colorize:
      return 8;
    case TextAniType.textLiquidFill:
      return 9;
    case TextAniType.bounce:
      return 10;
    case TextAniType.shimmer:
      return 11;
  }
}

TextAniType intToTextAniType(int t) {
  switch (t) {
    case 0:
      return TextAniType.none;
    case 1:
      return TextAniType.tickerSide;
    case 2:
      return TextAniType.tickerUpDown;
    case 3:
      return TextAniType.rotate;
    case 4:
      return TextAniType.fade;
    case 5:
      return TextAniType.fidget;
    case 6:
      return TextAniType.typewriter;
    case 7:
      return TextAniType.wavy;
    case 8:
      return TextAniType.colorize;
    case 9:
      return TextAniType.textLiquidFill;
    case 10:
      return TextAniType.bounce;
    case 11:
      return TextAniType.shimmer;
  }
  return TextAniType.none;
}

String textAniTypeToString(TextAniType value) {
  switch (value) {
    case TextAniType.none:
      return "none";
    case TextAniType.tickerSide:
      return MyStrings.tickerSide;
    case TextAniType.tickerUpDown:
      return MyStrings.tickerUpDown;
    case TextAniType.rotate:
      return MyStrings.rotateText;
    case TextAniType.fade:
      return MyStrings.fade;
    case TextAniType.fidget:
      return MyStrings.fidget;
    case TextAniType.typewriter:
      return MyStrings.typewriter;
    case TextAniType.wavy:
      return MyStrings.wavy;
    case TextAniType.colorize:
      return "colorize";
    case TextAniType.textLiquidFill:
      return "textLiquidFill";
    case TextAniType.bounce:
      return MyStrings.bounce;
    case TextAniType.shimmer:
      return MyStrings.shimmer;
  }
}

// enum TextAlign {
//   topLeft,
//   topCenter,
//   topRight,
//   centerLeft,
//   center,
//   centerRight,
//   bottomLeft,
//   bottomCenter,
//   bottomRight,
// }

int textAlignToInt(TextAlign value) {
  switch (value) {
    case TextAlign.left:
      return 0;
    case TextAlign.right:
      return 1;
    case TextAlign.center:
      return 2;
    case TextAlign.justify:
      return 3;
    case TextAlign.start:
      return 4;
    case TextAlign.end:
      return 5;
  }
}

TextAlign intToTextAlign(int t) {
  switch (t) {
    case 0:
      return TextAlign.left;
    case 1:
      return TextAlign.right;
    case 2:
      return TextAlign.center;
    case 3:
      return TextAlign.justify;
    case 4:
      return TextAlign.start;
    case 5:
      return TextAlign.end;
    case 6:
  }
  return TextAlign.center;
}

String getFontName(String font) {
  if (font == "NanumMyeongjo") {
    return MyStrings.fontNanum_Myeongjo;
  }
  if (font == "NotoSansKR") {
    return MyStrings.fontNoto_Sans_KR;
  }
  if (font == "Jua") {
    return MyStrings.fontJua;
  }
  if (font == "NanumGothic") {
    return MyStrings.fontNanum_Gothic;
  }
  if (font == "NanumPenScript") {
    return MyStrings.fontNanum_Pen_Script;
  }
  if (font == "NotoSansKR") {
    return MyStrings.fontNoto_Sans_KR;
  }
  if (font == "Macondo") {
    return MyStrings.fontMacondo;
  }
  return MyStrings.fontPretendard;
}

String getFontFamily(String font) {
  if (font == MyStrings.fontNanum_Myeongjo) {
    return "NanumMyeongjo";
  }
  if (font == MyStrings.fontNoto_Sans_KR) {
    return "NotoSansKR";
  }
  if (font == MyStrings.fontJua) {
    return "Jua";
  }
  if (font == MyStrings.fontNanum_Gothic) {
    return "NanumGothic";
  }
  if (font == MyStrings.fontNanum_Pen_Script) {
    return "NanumPenScript";
  }
  if (font == MyStrings.fontNoto_Sans_KR) {
    return "NotoSansKR";
  }
  if (font == MyStrings.fontMacondo) {
    return "Macondo";
  }

  return "Pretendard";
}
