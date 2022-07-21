// ignore_for_file: cascade_invocations, file_names

import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_preview/device_preview.dart';
import 'package:eqmonitor/model/db/city.model.dart';
import 'package:eqmonitor/model/db/eq_history.schema.dart';
import 'package:eqmonitor/model/db/error_log.model.dart';
import 'package:eqmonitor/page/eq_info_page.dart';
import 'package:eqmonitor/page/terms.dart';
import 'package:eqmonitor/utils/CustomImageLoader/custom_image_loader.dart';
import 'package:eqmonitor/utils/EQMonitorApi/history_lib.dart';
import 'package:eqmonitor/utils/image_cache/image_cache.dart';
import 'package:eqmonitor/utils/svir/svir.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './const/const.dart';
import 'firebase_options.dart';
import 'page/mainPage.dart';
import 'page/settingscreen.dart';
import 'page/splashscreen.dart';
import 'utils/KyoshinMonitorlib/kyoshinMonitorlibTime.dart';
import 'utils/auth.dart';
import 'utils/earthquake.dart';
import 'utils/map.dart';
import 'utils/map/customZoomPanBehavior.dart';
import 'utils/messaging.dart';
import 'utils/settings/notificationSettings.dart';
import 'utils/updater/appUpdate.dart';

// ダミーのProviderを用意する
final isarProvider = Provider<Isar>((_) {
  debugPrint('run isarprovider');
  throw UnimplementedError('アプリケーション起動時にmainでawaitして生成したインスタンスを使用する');
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.testMode = kDebugMode;
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // transparent status bar
    ),
  );
  //? Setup DB
  // final dir = await getApplicationSupportDirectory();
  //? End DB
  final prefs =
      Get.put<SharedPreferences>(await SharedPreferences.getInstance());
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final deviceInfo =
      Get.put<AndroidDeviceInfo>(await DeviceInfoPlugin().androidInfo);
  final crashlytics =
      Get.put<FirebaseCrashlytics>(FirebaseCrashlytics.instance);
  await crashlytics.sendUnsentReports();
  await crashlytics.setUserIdentifier(deviceInfo.androidId.toString());
  await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
  //* =======Isarデータベースを開く=======
  final dir = await getApplicationSupportDirectory();
  final isar = await Isar.open(
    schemas: <CollectionSchema<dynamic>>[
      CitySchema,
      EQHistorySchema,
      ErrorLogSchema,
    ],
    directory: dir.path,
    inspector: kDebugMode,
  );
  //* =================================
  FlutterError.onError = (details) async {
    FlutterError.dumpErrorToConsole(details);
    isar.writeTxnSync(
      (isar) => isar.errorLogs.putSync(
        ErrorLog()
          ..code = details.hashCode
          ..createdAt = DateTime.now()
          ..payload = details.toString(),
      ),
    );
    await FirebaseCrashlytics.instance.recordFlutterError(details);
  };

  Get.put<Logger>(
    Logger(
      level: Level.debug,
      printer: PrettyPrinter(
        printTime: true,
      ),
    ),
  );
  Get.put<FlutterSecureStorage>(const FlutterSecureStorage());
  Get.put<PackageInfo>(await PackageInfo.fromPlatform());
  Get.put<UserNotificationSettings>(await UserNotificationSettings().onInit());
  Get.put<FirebaseApp>(await Firebase.initializeApp());
  Get.put<FirebaseAuth>(FirebaseAuth.instance);
  Get.put<FirebaseMessaging>(FirebaseMessaging.instance);
  Get.put<FirebasePerformance>(FirebasePerformance.instance);
  Get.put<MapData>(MapData());
  Get.put<Messaging>(Messaging());
  Get.put<AuthStateUtils>(AuthStateUtils());
  Get.put<KyoshinMonitorlibTime>(KyoshinMonitorlibTime());
  Get.put<CustomZoomPanBehavior>(CustomZoomPanBehavior());
  //Get.put<EarthQuakeHistory>(await EarthQuakeHistory().onInit());
  final svir = Get.put<Svir>(Svir());
  svir.start();
  Get.put<AppUpdate>(AppUpdate());
  Get.put<FlutterSecureStorage>(const FlutterSecureStorage());
  Get.put<HistoryLib>(HistoryLib());
  Get.put<EarthQuake>(EarthQuake());
  Get.put<CustomImageLoader>(CustomImageLoader());

  final assetImageCache = Get.put<AssetImageCache>(AssetImageCache());
  await assetImageCache.onInit();

  runApp(
    DevicePreview(
      enabled: prefs.getBool('showDevicePreview') ?? false,
      builder: (context) => EQMonitorApp(
        isar: isar,
      ),
    ),
  );
}

class EQMonitorApp extends StatelessWidget {
  const EQMonitorApp({super.key, required this.isar});

  final Isar isar;

  @override
  Widget build(BuildContext context) => ProviderScope(
        overrides: <Override>[
          isarProvider.overrideWithValue(isar),
        ],
        child: GetMaterialApp(
          title: 'EQMonitor',
          theme: lightTheme(),
          darkTheme: darkTheme(),
          locale: DevicePreview.locale(context),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate
          ],
          supportedLocales: const [
            locale,
          ],
          useInheritedMediaQuery: true,
          builder: DevicePreview.appBuilder,
          initialRoute: '/splash',
          getPages: [
            GetPage<dynamic>(
              name: '/',
              page: IntroPage.new,
            ),
            GetPage<dynamic>(
              name: '/terms',
              page: TermsScreen.new,
            ),
            GetPage<dynamic>(
              name: '/splash',
              page: SplashScreen.new,
              transition: Transition.downToUp,
            ),
            GetPage<dynamic>(
              name: '/setting',
              page: SettingScreen.new,
            ),
            GetPage<dynamic>(
              name: '/eqinfo',
              page: EqInfoPage.new,
            ),
          ],
        ),
      );
}
