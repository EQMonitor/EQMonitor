import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:eqmonitor/utils/KyoshinMonitorlib/JmaIntensity.dart';
import 'package:eqmonitor/utils/analyzedpoints.dart';
import 'package:flutter/material.dart';

ThemeData darkTheme() {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.grey[900],
    useMaterial3: true,
  );
}

ThemeData lightTheme() {
  return ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.white,
    useMaterial3: true,
    primaryColor: materialWhite,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
  );
}

extension BoolParsing on String {
  bool parseBool({bool defaultValue = true}) {
    if (toLowerCase() == 'true') {
      return true;
    } else if (toLowerCase() == 'false') {
      return false;
    }
    return defaultValue;
  }
}

const locale = Locale('ja', 'JP');

const MaterialColor materialWhite = MaterialColor(
  0xFFFFFFFF,
  <int, Color>{
    50: Color(0xFFFFFFFF),
    100: Color(0xFFFFFFFF),
    200: Color(0xFFFFFFFF),
    300: Color(0xFFFFFFFF),
    400: Color(0xFFFFFFFF),
    500: Color(0xFFFFFFFF),
    600: Color(0xFFFFFFFF),
    700: Color(0xFFFFFFFF),
    800: Color(0xFFFFFFFF),
    900: Color(0xFFFFFFFF),
  },
);

// RGBColorから震度の値に変換するのに使用
const Map<List<int>, double> colorMap = {
  [0, 0, 205]: -3,
  [0, 7, 209]: -2.9,
  [0, 14, 214]: -2.8,
  [0, 21, 218]: -2.7,
  [0, 28, 223]: -2.6,
  [0, 36, 227]: -2.5,
  [0, 43, 231]: -2.4,
  [0, 50, 236]: -2.3,
  [0, 57, 240]: -2.2,
  [0, 64, 245]: -2.1,
  [0, 72, 250]: -2,
  [0, 85, 238]: -1.9,
  [0, 99, 227]: -1.8,
  [0, 112, 216]: -1.7,
  [0, 126, 205]: -1.6,
  [0, 140, 194]: -1.5,
  [0, 153, 183]: -1.4,
  [0, 167, 172]: -1.3,
  [0, 180, 161]: -1.2,
  [0, 194, 150]: -1.1,
  [0, 208, 139]: -1,
  [6, 212, 130]: -0.9,
  [12, 216, 121]: -0.8,
  [18, 220, 113]: -0.7,
  [25, 224, 104]: -0.6,
  [31, 228, 96]: -0.5,
  [37, 233, 88]: -0.4,
  [44, 237, 79]: -0.3,
  [50, 241, 71]: -0.2,
  [56, 245, 62]: -0.1,
  [63, 250, 54]: 0,
  [75, 250, 49]: 0.1,
  [88, 250, 45]: 0.2,
  [100, 251, 41]: 0.3,
  [113, 251, 37]: 0.4,
  [125, 252, 33]: 0.5,
  [138, 252, 28]: 0.6,
  [151, 253, 24]: 0.7,
  [163, 253, 20]: 0.8,
  [176, 254, 16]: 0.9,
  [189, 255, 12]: 1,
  [195, 254, 10]: 1.1,
  [202, 254, 9]: 1.2,
  [208, 254, 8]: 1.3,
  [215, 254, 7]: 1.4,
  [222, 255, 5]: 1.5,
  [228, 254, 4]: 1.6,
  [235, 255, 3]: 1.7,
  [241, 254, 2]: 1.8,
  [248, 255, 1]: 1.9,
  [255, 255, 0]: 2,
  [254, 251, 0]: 2.1,
  [254, 248, 0]: 2.2,
  [254, 244, 0]: 2.3,
  [254, 241, 0]: 2.4,
  [255, 238, 0]: 2.5,
  [254, 234, 0]: 2.6,
  [255, 231, 0]: 2.7,
  [254, 227, 0]: 2.8,
  [255, 224, 0]: 2.9,
  [255, 221, 0]: 3,
  [254, 213, 0]: 3.1,
  [254, 205, 0]: 3.2,
  [254, 197, 0]: 3.3,
  [254, 190, 0]: 3.4,
  [255, 182, 0]: 3.5,
  [254, 174, 0]: 3.6,
  [255, 167, 0]: 3.7,
  [254, 159, 0]: 3.8,
  [255, 151, 0]: 3.9,
  [255, 144, 0]: 4,
  [254, 136, 0]: 4.1,
  [254, 128, 0]: 4.2,
  [254, 121, 0]: 4.3,
  [254, 113, 0]: 4.4,
  [255, 106, 0]: 4.5,
  [254, 98, 0]: 4.6,
  [255, 90, 0]: 4.7,
  [254, 83, 0]: 4.8,
  [255, 75, 0]: 4.9,
  [255, 68, 0]: 5,
  [254, 61, 0]: 5.1,
  [253, 54, 0]: 5.2,
  [252, 47, 0]: 5.3,
  [251, 40, 0]: 5.4,
  [250, 33, 0]: 5.5,
  [249, 27, 0]: 5.6,
  [248, 20, 0]: 5.7,
  [247, 13, 0]: 5.8,
  [246, 6, 0]: 5.9,
  [245, 0, 0]: 6,
  [238, 0, 0]: 6.1,
  [230, 0, 0]: 6.2,
  [223, 0, 0]: 6.3,
  [215, 0, 0]: 6.4,
  [208, 0, 0]: 6.5,
  [200, 0, 0]: 6.6,
  [192, 0, 0]: 6.7,
  [185, 0, 0]: 6.8,
  [177, 0, 0]: 6.9,
  [170, 0, 0]: 7.0,
};

List<NotificationChannel> notificationChannels = [
  NotificationChannel(
    channelGroupKey: 'fromdev',
    channelKey: 'fromdev',
    channelName: '開発者からのお知らせ',
    channelDescription: '開発者からなにか連絡があった時に使用されます。',
    channelShowBadge: true,
    enableVibration: true,
    playSound: true,
    importance: NotificationImportance.High,
  ),
  //! EEW
  NotificationChannel(
    channelGroupKey: 'eew',
    channelKey: 'eew_alert',
    channelName: '緊急地震速報(警報)',
    channelDescription: '緊急地震速報(警報)通知',
    defaultColor: const Color.fromARGB(255, 190, 0, 0),
    ledColor: const Color.fromARGB(255, 190, 0, 0),
    channelShowBadge: true,
    defaultPrivacy: NotificationPrivacy.Public,
    playSound: true,
    criticalAlerts: true,
    enableVibration: true,
    soundSource: 'resource://raw/res_eew',
    importance: NotificationImportance.Max,
  ),
  NotificationChannel(
    channelGroupKey: 'eew',
    channelKey: 'eew_forecast',
    channelName: '緊急地震速報(予報)',
    channelDescription: '緊急地震速報(予報)通知',
    defaultColor: const Color.fromARGB(255, 255, 59, 59),
    ledColor: const Color.fromARGB(255, 255, 59, 59),
    channelShowBadge: true,
    defaultPrivacy: NotificationPrivacy.Public,
    playSound: true,
    criticalAlerts: true,
    enableVibration: true,
    soundSource: 'resource://raw/res_eq1',
    importance: NotificationImportance.Max,
  ),
  //! 地震通知
  NotificationChannel(
    channelGroupKey: 'earthquake',
    channelKey: 'VZSE40',
    channelName: '地震・津波に関するお知らせ',
    channelDescription: '地震・津波の試験・訓練配信のお知らせ、自治体震度データの入電停止等のお知らせ、その他を発表',
    channelShowBadge: true,
    defaultPrivacy: NotificationPrivacy.Public,
    playSound: true,
    enableVibration: true,
    soundSource: 'resource://raw/res_eq1',
    importance: NotificationImportance.Low,
  ),
  NotificationChannel(
    channelGroupKey: 'tsunami',
    channelKey: 'VTSE41',
    channelName: '津波警報・注意報・予報',
    channelDescription:
        '影響をもたらす津波が到達すると予測された地域、または影響がなくなった地域に対して、津波警報・注意報・予報の発表・切替及び解除について、予報区ごとに予想の高さや津波到達時間、震源要素等を発表',
    channelShowBadge: true,
    defaultPrivacy: NotificationPrivacy.Public,
    playSound: true,
    enableVibration: true,
    importance: NotificationImportance.High,
  ),
  NotificationChannel(
    channelGroupKey: 'tsunami',
    channelKey: 'VTSE51',
    channelName: '津波情報',
    channelDescription: '各地の満潮時刻、津波到達予想時刻に関する情報及び地上観測点における津波観測に関する情報を発表',
    channelShowBadge: true,
    defaultPrivacy: NotificationPrivacy.Public,
    playSound: true,
    enableVibration: true,
    importance: NotificationImportance.High,
  ),
  NotificationChannel(
    channelGroupKey: 'tsunami',
    channelKey: 'VTSE52',
    channelName: '沖合の津波情報',
    channelDescription: '沖合の観測点における津波観測に関する情報を発表',
    channelShowBadge: true,
    defaultPrivacy: NotificationPrivacy.Public,
    playSound: true,
    enableVibration: true,
    importance: NotificationImportance.High,
  ),
  NotificationChannel(
    channelGroupKey: 'tsunami',
    channelKey: 'WEPA60',
    channelName: '国際津波関連情報(国内向け)',
    channelDescription:
        '北西太平洋域でM6.5以上の地震が発生した場合、北西太平洋域の各国が津波警報等の発表に資するための支援情報として発表するものを複製した国内向け配信',
    channelShowBadge: true,
    defaultPrivacy: NotificationPrivacy.Public,
    playSound: true,
    enableVibration: true,
    importance: NotificationImportance.High,
  ),
  NotificationChannel(
    channelGroupKey: 'earthquake',
    channelKey: 'VXSE51',
    channelName: '震度速報',
    channelDescription: '震度3以上の地域を90秒程度で第1報を通知',
    channelShowBadge: true,
    defaultPrivacy: NotificationPrivacy.Public,
    playSound: true,
    enableVibration: true,
    importance: NotificationImportance.High,
  ),
  NotificationChannel(
    channelGroupKey: 'earthquake',
    channelKey: 'VXSE52',
    channelName: '震源に関する情報',
    channelDescription: '震源速報、津波の有無を通知',
    channelShowBadge: true,
    defaultPrivacy: NotificationPrivacy.Public,
    playSound: true,
    enableVibration: true,
    importance: NotificationImportance.High,
  ),
  NotificationChannel(
    channelGroupKey: 'earthquake',
    channelKey: 'VXSE53',
    channelName: '震源・震度に関する情報',
    channelDescription: '震源要素・各地の震度、海外で発生した大きな地震の震源要素等、津波の有無を通知',
    channelShowBadge: true,
    defaultPrivacy: NotificationPrivacy.Public,
    playSound: true,
    enableVibration: true,
    importance: NotificationImportance.High,
  ),
  NotificationChannel(
    channelGroupKey: 'earthquake',
    channelKey: 'VXSE56',
    channelName: '地震の活動状況等に関する情報',
    channelDescription: '地震の活動状況等に関する情報や、伊豆東部の地震活動に関する情報などの解説情報を発表',
    channelShowBadge: true,
    defaultPrivacy: NotificationPrivacy.Public,
    playSound: true,
    enableVibration: true,
    importance: NotificationImportance.High,
  ),
  NotificationChannel(
    channelGroupKey: 'earthquake',
    channelKey: 'VXSE60',
    channelName: '地震回数に関する情報',
    channelDescription: '顕著な地震に対して、有感地震の回数経過状況を発表',
    channelShowBadge: true,
    defaultPrivacy: NotificationPrivacy.Public,
    playSound: true,
    enableVibration: true,
    importance: NotificationImportance.High,
  ),
  NotificationChannel(
    channelGroupKey: 'earthquake',
    channelKey: 'VXSE61',
    channelName: '顕著な地震の震源要素更新のお知らせ',
    channelDescription: '顕著な地震に対して、震源要素をより正確にした情報を発表',
    channelShowBadge: true,
    defaultPrivacy: NotificationPrivacy.Public,
    playSound: true,
    enableVibration: true,
    importance: NotificationImportance.High,
  ),
  NotificationChannel(
    channelGroupKey: 'earthquake',
    channelKey: 'VXSE62',
    channelName: '長周期地震動に関する観測情報',
    channelDescription: '長周期地震動階級1以上を観測した地震について、観測した要素などを地震発生後10分程度で発表',
    channelShowBadge: true,
    defaultPrivacy: NotificationPrivacy.Public,
    playSound: true,
    enableVibration: true,
    importance: NotificationImportance.High,
  ),
  NotificationChannel(
    channelGroupKey: 'earthquake',
    channelKey: 'VYSE50',
    channelName: '南海トラフ地震臨時情報',
    channelDescription: '南海トラフ沿いで異常な現象が観測され、その現象が南海トラフ沿いの大規模な地震発生が警戒される場合に発表',
    channelShowBadge: true,
    defaultPrivacy: NotificationPrivacy.Public,
    playSound: true,
    enableVibration: true,
    importance: NotificationImportance.High,
  ),
  NotificationChannel(
    channelGroupKey: 'earthquake',
    channelKey: 'VYSE51',
    channelName: '南海トラフ地震関連解説情報(定例外)',
    channelDescription:
        '南海トラフ沿いで異常な現象が観測され、その現象が南海トラフ沿いの大規模な地震と関連するかどうか調査を開始・解説・終了した場合等に発表',
    channelShowBadge: true,
    defaultPrivacy: NotificationPrivacy.Public,
    playSound: true,
    enableVibration: true,
    importance: NotificationImportance.High,
  ),
  NotificationChannel(
    channelGroupKey: 'earthquake',
    channelKey: 'VYSE52',
    channelName: '南海トラフ地震関連解説情報(定例)',
    channelDescription: '南海トラフ沿いの地震に関する評価検討会の定例会合における調査結果の発表',
    channelShowBadge: true,
    defaultPrivacy: NotificationPrivacy.Public,
    playSound: true,
    enableVibration: true,
    importance: NotificationImportance.High,
  ),
];

List<NotificationChannelGroup>? channelGroups = [
  NotificationChannelGroup(
    channelGroupKey: 'eew',
    channelGroupName: '緊急地震速報',
  ),
  NotificationChannelGroup(
    channelGroupKey: 'earthquake',
    channelGroupName: '地震通知',
  ),
  NotificationChannelGroup(
    channelGroupKey: 'tsunami',
    channelGroupName: '津波通知',
  ),
  NotificationChannelGroup(
    channelGroupKey: 'fromdev',
    channelGroupName: '開発者からのお知らせ',
  ),
];

enum Topics {
  /// ## 緊急地震速報
  eew,

  /// ## 震度速報
  VXSE51,

  /// ## 震源に関する情報
  VXSE52,

  /// ## 震源・震度に関する情報
  VXSE53,

  /// ## 長周期地震動に関する情報
  VXSE62,

  /// ## 地震・津波に関するお知らせ
  VZSE40,

  /// ## 利用者全員への緊急連絡
  everyone,
}

const List<String> prefectures = [
  '北海道',
  '青森県',
  '岩手県',
  '宮城県',
  '秋田県',
  '山形県',
  '福島県',
  '茨城県',
  '栃木県',
  '群馬県',
  '埼玉県',
  '千葉県',
  '東京都',
  '神奈川県',
  '新潟県',
  '富山県',
  '石川県',
  '福井県',
  '山梨県',
  '長野県',
  '岐阜県',
  '静岡県',
  '愛知県',
  '三重県',
  '滋賀県',
  '京都府',
  '大阪府',
  '兵庫県',
  '奈良県',
  '和歌山県',
  '鳥取県',
  '島根県',
  '岡山県',
  '広島県',
  '山口県',
  '徳島県',
  '香川県',
  '愛媛県',
  '高知県',
  '福岡県',
  '佐賀県',
  '長崎県',
  '熊本県',
  '大分県',
  '宮崎県',
  '鹿児島県',
  '沖縄県',
];

final List<AnalyzedPoint> initEewPoints = <AnalyzedPoint>[
  // 震央
  AnalyzedPoint(
    code: 'eew1HypoCenter',
    name: '震央',
    pref: 'pref',
    lat: 0,
    lon: 0,
    x: 0,
    y: 0,
    pointType: PointType.HypoCenter,
    shindoColor: Colors.transparent,
    pgaColor: Colors.transparent,
    shindo: null,
    zoomLevel: 0,
    pga: null,
    intensity: JmaIntensity.Unknown,
  ),
  // P波到達予想円
  AnalyzedPoint(
    code: 'eew1Pwave',
    name: 'P波',
    pref: 'pref',
    lat: 0,
    lon: 0,
    x: 0,
    y: 0,
    pointType: PointType.Pwave,
    shindoColor: Colors.transparent,
    pgaColor: Colors.transparent,
    shindo: null,
    zoomLevel: 0,
    pga: null,
    intensity: JmaIntensity.Unknown,
  ),
  // S波到達予想円
  AnalyzedPoint(
    code: 'eew1Swave',
    name: 'S波',
    pref: 'pref',
    lat: 0,
    lon: 0,
    x: 0,
    y: 0,
    pointType: PointType.Swave,
    shindoColor: Colors.transparent,
    pgaColor: Colors.transparent,
    shindo: null,
    zoomLevel: 0,
    pga: null,
    intensity: JmaIntensity.Unknown,
  ),
];