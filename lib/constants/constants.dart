const String defaultSiteId = 'Anonymous';
const double defaultPadding = 16.0;

const double minWindowWidth = 850;
const double minWindowHeight = 500;

const double layoutPageWidth = 324;
const double layoutPropertiesWidth = 362;

const double minAccSize = 10;
const double magnetic = 4;

const int maxInteger = (1 << 63);
const double playTimeForever = -1;

const String pagePrefix = 'Page=';
const String accPrefix = 'ACC=';
const String contentsPrefix = 'Con=';
const String bookPrefix = 'Book=';

const double maxFontSize = 300;

// 언어명, TTS code, translate code
// List<List<String>> langCodes = [
//   ['한국어', 'ko-KR', 'ko'],
//   ['Deutsch (Deutschland)', 'de-DE', 'de'],
//   ['English (US)', 'en-US', 'en'],
//   ['Español (España)', 'es-ES', 'es'],
//   ['Français (France)', 'fr-FR', 'fr'],
//   ['हिंदी', 'hi-IN', 'hi'],
//   ['Bahasa Indonesia', 'id-ID', 'id'],
//   ['Italiano', 'it-IT', 'it'],
//   ['日本語', 'ja-JP', 'ja'],
//   ['Nederlands', 'nl-NL', 'nl'],
//   ['Polski', 'pl-PL', 'pl'],
//   ['Português (Brasil)', 'pt-BR', 'pt'],
//   ['Русский', 'ru-RU', 'ru'],
//   ['中文 (中国大陆)', 'zh-CN', 'zh-cn'],
//   ['中文 (台灣)', 'zh-TW', 'zh-tw'],
// ];

List<String> languages = [
  '한국어',
  'Deutsch (Deutschland)',
  'English (US)',
  'Español (España)',
  'Français (France)',
  'हिंदी',
  'Bahasa Indonesia',
  'Italiano',
  '日本語',
  'Nederlands',
  'Polski',
  'Português (Brasil)',
  'Русский',
  '中文 (中国大陆)',
  '中文 (台灣)',
];
List<String> langCodes = [
  'ko',
  'de',
  'en',
  'es',
  'fr',
  'hi',
  'id',
  'it',
  'ja',
  'nl',
  'pl',
  'pt',
  'ru',
  'zh-cn',
  'zh-tw',
];
List<String> ttsCodes = [
  'ko-KR',
  'de-DE',
  'en-US',
  'es-ES',
  'fr-FR',
  'hi-IN',
  'id-ID',
  'it-IT',
  'ja-JP',
  'nl-NL',
  'pl-PL',
  'pt-BR',
  'ru-RU',
  'zh-CN',
  'zh-TW',
];

Map<String, String> lang2CodeMap = {};
Map<String, String> code2LangMap = {};
Map<String, String> code2TTSMap = {};
void initLangMap() {
  lang2CodeMap.clear();
  code2LangMap.clear();
  code2TTSMap.clear();
  int len = languages.length;
  for (int i = 0; i < len; i++) {
    lang2CodeMap[languages[i]] = langCodes[i];
    code2LangMap[langCodes[i]] = languages[i];
    code2TTSMap[langCodes[i]] = ttsCodes[i];
  }
}
