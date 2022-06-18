// ignore_for_file: library_prefixes

import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:eqmonitor/const/const.dart';
import 'package:eqmonitor/const/obspoints.dart';
import 'package:eqmonitor/utils/KyoshinMonitorlib/JmaIntensity.dart';
import 'package:eqmonitor/utils/KyoshinMonitorlib/UrlGenerator/RealTimeDataType.dart';
import 'package:eqmonitor/utils/KyoshinMonitorlib/UrlGenerator/WebApiUrlGenerators.dart';
import 'package:eqmonitor/utils/KyoshinMonitorlib/imageParser/jmaParser.dart';
import 'package:eqmonitor/utils/KyoshinMonitorlib/kyoshinMonitorlibTime.dart';
import 'package:eqmonitor/utils/map/customZoomPanBehavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

import 'analyzedpoints.dart';

class EarthQuake extends GetxController {
  final Logger logger = Get.find<Logger>();
  final SharedPreferences prefs = Get.find<SharedPreferences>();
  final WebApiUrlGenerator webApiUrlGenerator = WebApiUrlGenerator();
  final KyoshinMonitorlibTime kyoshinMonitorlibTime =
      Get.find<KyoshinMonitorlibTime>();

  final JmaImageParser jmaImageParser = JmaImageParser();

  final RxInt numberOfAnalyzedPoint = 0.obs;
  final RxString url = ''.obs;
  final RxList<AnalyzedPoint> analyzedPoint = <AnalyzedPoint>[].obs;
  final RxList<AnalyzedPoint> eewAnalyzedPoint = <AnalyzedPoint>[].obs;
  final RxDouble zoomLevel = 1.0.obs;
  final RxDouble iconSize = 3.6.obs;
  final RxString lastUpdateTimeString = '更新待ち'.obs;
  final MapShapeLayerController mapShapeLayerController =
      MapShapeLayerController();
  final MapZoomPanBehavior mapZoomPanBehavior = CustomZoomPanBehavior()
    ..enableDoubleTapZooming
    ..maxZoomLevel = 50;
  final df = DateFormat('yyyyMMdd/yyyyMMddHHmmss');
  final Rx<Queue<Uint8List>> imageQueue = Queue<Uint8List>().obs;

  final MapController mapController = MapController();

  /// 震度かPGAか
  final showShindo = true.obs;
  @override
  Future<void> onInit() async {
    super.onInit();
    Timer.periodic(
      const Duration(milliseconds: 1000),
      (timer) async => kyoshinMonitorlibTime.generateNowTime(),
    );
    // 仮で空っぽの観測点を配置しておく
    for (final obsPoint in OBSPoints) {
      analyzedPoint.add(
        AnalyzedPoint(
          code: obsPoint.code,
          name: obsPoint.name,
          pref: obsPoint.pref,
          lat: obsPoint.lat,
          lon: obsPoint.lon,
          x: obsPoint.x,
          y: obsPoint.y,
          pointType: PointType.Observer,
          shindoColor: const Color(0x00FFFFFF),
          pgaColor: const Color(0x00FFFFFF),
          shindo: null,
          zoomLevel: zoomLevel.value,
          pga: null,
          intensity: JmaIntensity.Int0,
        ),
      );
    }
    eewAnalyzedPoint.value = initEewPoints;
    Timer.periodic(
      const Duration(milliseconds: 1000),
      (_) async => updateEQData(),
    );
    Timer.periodic(const Duration(milliseconds: 250), (_) async {
      iconSize.value = mapZoomPanBehavior.zoomLevel * 0.6 + 3;
      jmaImageParser.zoomLevel.value =
          zoomLevel.value = mapZoomPanBehavior.zoomLevel;
    });
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    // 利用規約同意画面に飛ばすかどうか
    final String route;
    if (prefs.getBool('isAcceptTerm') ?? false) {
      route = '/';
    } else {
      route = '/terms';
    }
    await Get.offAllNamed<void>(route);

    await updateEQData();
  }

  Future<void> updateEQData() async {
    // PGA Update
    try {
      final shindoPic = await http.get(
        Uri.parse(
          webApiUrlGenerator.RealtimeBase(
            dt: kyoshinMonitorlibTime.now.value,
            type: RealtimeDataType.Shindo,
            sorb: 's',
          ),
        ),
      );
      final pgaPic = await http.get(
        Uri.parse(
          webApiUrlGenerator.RealtimeBase(
            dt: kyoshinMonitorlibTime.now.value,
            type: RealtimeDataType.Pga,
            sorb: 's',
          ),
        ),
      );
      if (shindoPic.statusCode != 200) {
        //logger.wtf('リアルタイム震度の画像を取得できませんでした。(status: ${shindoPic.statusCode})');
      }
      if (pgaPic.statusCode != 200) {
        //logger.wtf('PGAの取得に失敗');
      }
      analyzedPoint.value = jmaImageParser.imageParser(
        shindoPic: (imageQueue.value.isEmpty)
            ? shindoPic.bodyBytes
            : imageQueue.value.removeFirst(),
        pgaPic: pgaPic.bodyBytes,
        isPng: imageQueue.value.isNotEmpty,
      );
      mapShapeLayerController.updateMarkers(
        List<int>.generate(
          analyzedPoint.length + eewAnalyzedPoint.length,
          (i) => i,
        ),
      );
      lastUpdateTimeString.value = DateFormat('yyyy/MM/dd HH:mm:ss')
          .format(kyoshinMonitorlibTime.now.value);
      numberOfAnalyzedPoint.value =
          analyzedPoint.where((p0) => p0.shindo != null).length;
    } on Exception {
      //logger.w(e);
      analyzedPoint.value = jmaImageParser.imageParser(
        pgaPic: [],
        shindoPic: [],
        isPng: false,
      );
      mapShapeLayerController.updateMarkers(
        List<int>.generate(
          analyzedPoint.length + eewAnalyzedPoint.length,
          (i) => i,
        ),
      );
      lastUpdateTimeString.value = DateFormat('yyyy/MM/dd HH:mm:ss')
          .format(kyoshinMonitorlibTime.now.value);
      numberOfAnalyzedPoint.value = 0;
    }
  }
}

class OBSPoint {
  OBSPoint({
    required this.code,
    required this.name,
    required this.pref,
    required this.lat,
    required this.lon,
    required this.x,
    required this.y,
  });

  OBSPoint.fromList(List<dynamic> lis)
      : code = lis[0].toString(),
        name = lis[1].toString(),
        pref = lis[2].toString(),
        lat = double.parse(lis[3].toString()),
        lon = double.parse(lis[4].toString()),
        x = int.parse(lis[5].toString()),
        y = int.parse(lis[6].toString());

  final String code;
  final String name;
  final String pref;
  final double lat;
  final double lon;
  final int x;
  final int y;
}
