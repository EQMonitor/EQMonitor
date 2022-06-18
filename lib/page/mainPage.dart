import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:eqmonitor/notifier/eew_content.notifier.dart';
import 'package:eqmonitor/page/eq_history_page.dart';
import 'package:eqmonitor/page/notification_history_page.dart';
import 'package:eqmonitor/utils/KyoshinMonitorlib/kyoshinMonitorlibTime.dart';
import 'package:eqmonitor/utils/map/customZoomPanBehavior.dart';
import 'package:eqmonitor/utils/updater/appUpdate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../utils/analyzedpoints.dart';
import '../utils/earthquake.dart';
import '../utils/map.dart';
import '../utils/messaging.dart';
import '../utils/svir/svir.dart';
import '../widget/map.dart';
import '../widget/on_eew.dart';

class IntroPage extends HookConsumerWidget {
  IntroPage({super.key});

  final Logger logger = Get.find<Logger>();
  final EarthQuake earthQuake = Get.find<EarthQuake>();
  final Svir svir = Get.find<Svir>();
  final KyoshinMonitorlibTime kmoniTime = Get.find<KyoshinMonitorlibTime>();
  final AppUpdate appUpdate = Get.find<AppUpdate>();
  final CustomZoomPanBehavior zoomPanBehavior =
      Get.find<CustomZoomPanBehavior>();
  final Messaging messaging = Get.find<Messaging>();
  final PackageInfo packageInfo = Get.find<PackageInfo>();
  final Key mapKey = const Key('mapKey');
  final MapData mapData = Get.find<MapData>();
  final RxInt page = 0.obs;
  final RxInt selectedIndex = (-1).obs;
  final RxBool showLegend = true.obs;
  final Rx<Color?> mapBackgroundColor = null.obs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Svir EEWのFetch Timer開始
    WidgetsBinding.instance.addPostFrameCallback((_){
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            kDebugMode ? const Color.fromARGB(255, 157, 0, 0) : null,
        title: Text('EQMonitor (Build${packageInfo.buildNumber})'),
        actions: [
          Obx(
            () => (appUpdate.hasUpdate.value)
                ? IconButton(
                    icon: const Icon(Icons.system_update),
                    color: Colors.redAccent,
                    tooltip: 'アップデートがあります',
                    onPressed: () async {
                      await Get.dialog<void>(
                        AlertDialog(
                          title: const Text('アップデートがあります'),
                          actions: [
                            TextButton.icon(
                              onPressed: () async {
                                await launchUrlString(
                                  appUpdate.updateApi.assetUrl,
                                );
                              },
                              icon: const Icon(Icons.download),
                              label: const Text('ダウンロードする'),
                            ),
                          ],
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                Text(appUpdate.updateApi.title),
                                SizedBox(
                                  height: context.height * 0.7,
                                  width: context.width * 0.8,
                                  child: Markdown(
                                    data: appUpdate.updateApi.body,
                                    selectable: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Container(),
          ),
          IconButton(
            onPressed: () async {
              await Get.toNamed<void>('/setting');
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          elevation: 10,
          selectedIndex: page.value,
          onDestinationSelected: (value) {
            page.value = value;
            HapticFeedback.mediumImpact();
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'リアルタイム震度',
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              label: '地震履歴',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_active),
              label: '通知履歴',
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(
        () => (page.value == 0)
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                    () => (showLegend.value)
                        ? Container(
                            margin: const EdgeInsets.all(3),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: GestureDetector(
                                onTap: () async => Get.defaultDialog(
                                  backgroundColor:
                                      const Color.fromARGB(255, 0, 0, 0)
                                          .withOpacity(0.9),
                                  title: '',
                                  content: Obx(
                                    () => Image.asset(
                                      (earthQuake.showShindo.value)
                                          ? 'assets/nied_jma_s_w_scale.png'
                                          : 'assets/nied_acmap_s_w_scale.png',
                                    ),
                                  ),
                                ),
                                child: Container(
                                  color:
                                      const Color(0xFFFFFFFF).withOpacity(0.15),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 10,
                                      sigmaY: 10,
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.all(2),
                                      child: Image.asset(
                                        (earthQuake.showShindo.value)
                                            ? 'assets/nied_jma_s_w_scale.png'
                                            : 'assets/nied_acmap_s_w_scale.png',
                                        height: Get.height * 0.1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  FloatingActionButton.extended(
                    onPressed: () async {
                      await Get.dialog<void>(
                        AlertDialog(
                          title: const Text('表示設定'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('マップに表示するデータ'),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Obx(
                                    () => ChoiceChip(
                                      label: const Text('リアルタイム震度'),
                                      selected: earthQuake.showShindo.value,
                                      selectedColor: Colors.blueAccent,
                                      onSelected: (b) {
                                        if (b) {
                                          earthQuake.showShindo.value =
                                              !earthQuake.showShindo.value;
                                        }
                                      },
                                    ),
                                  ),
                                  Obx(
                                    () => ChoiceChip(
                                      label: const Text('リアルタイム加速度'),
                                      selected: !earthQuake.showShindo.value,
                                      selectedColor: Colors.blueAccent,
                                      onSelected: (b) {
                                        if (b) {
                                          earthQuake.showShindo.value =
                                              !earthQuake.showShindo.value;
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              ElevatedButton(
                                onPressed: () async {},
                                child: const Text('Fetch DB'),
                              )
                            ],
                          ),
                          actions: const [],
                        ),
                      );
                    },
                    icon: const Icon(Icons.display_settings),
                    label: const Text('表示設定'),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: Obx(
          () => IndexedStack(
            index: page.value,
            children: <Widget>[
              Stack(
                children: [
                  Obx(
                    () => (mapData.isInited.value)
                        ? Obx(
                            () => RealtimeIntensityMap(
                              backgroundColor: mapBackgroundColor.value,
                            ),
                          )
                        : const Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                  ),
                  Obx(
                    () => (svir.svirResponse.value != null)
                        ? Obx(
                            () => (kmoniTime.now.value
                                            .difference(
                                              svir.svirResponse.value.head
                                                  .dateTime,
                                            )
                                            .inSeconds <=
                                        180 ||
                                    kDebugMode)
                                ? Align(
                                    alignment: Alignment.topCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        10,
                                        0,
                                        10,
                                        0,
                                      ),
                                      child: OnEEWWidget(
                                        eew: svir.svirResponse.value,
                                        now: kmoniTime.now.value,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      // child: NonEEW(),
                      // child: NonEEW(context),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.all(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          color: Colors.white.withOpacity(0.15),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 10,
                              sigmaY: 10,
                            ),
                            child: Obx(
                              () => Container(
                                margin: const EdgeInsets.all(10),
                                child: AutoSizeText(
                                  '観測点: ${earthQuake.numberOfAnalyzedPoint.value}点\n'
                                  '倍率: ${earthQuake.zoomLevel.value.toStringAsFixed(1)}\n'
                                  '最大震度: ${maxIntensity(earthQuake.analyzedPoint.value)}\n'
                                  '最大PGA: ${maxPga(earthQuake.analyzedPoint.value)}',
                                  maxLines: 4,
                                  minFontSize: 5,
                                  maxFontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              EqHistoryPage(),
              NotificationHistoryPage(),
            ],
          ),
        ),
      ),
    );
  }

  String maxIntensity(List<AnalyzedPoint> l) {
    double? max;
    String? maxPlaceName;
    String? maxPref;
    for (final e in l) {
      if (e.shindo == null) continue;
      if (max == null) {
        max = e.shindo;
        maxPlaceName = e.name;
        maxPref = e.pref;
      } else if (max < e.shindo!) {
        max = e.shindo;
        maxPref = e.pref;
        maxPlaceName = e.name;
      }
    }
    if (max == null) return '不明';
    return '${max.toStringAsFixed(2)}($maxPref $maxPlaceName)';
  }

  String maxPga(List<AnalyzedPoint> l) {
    double? max;
    String? maxPlaceName;
    String? maxPref;
    for (final e in l) {
      if (e.pga == null) continue;
      if (max == null) {
        max = e.pga;
        maxPref = e.pref;
        maxPlaceName = e.name;
      } else if (max < e.pga!) {
        max = e.pga;
        maxPref = e.pref;
        maxPlaceName = e.name;
      }
    }
    if (max == null) return '不明';
    return '${max.toStringAsFixed(2)}gal($maxPref $maxPlaceName)';
  }
}
