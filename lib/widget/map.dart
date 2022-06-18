import 'package:eqmonitor/utils/KyoshinMonitorlib/kyoshinMonitorlibTime.dart';
import 'package:eqmonitor/utils/image_cache/image_cache.dart';
import 'package:eqmonitor/utils/map/customZoomPanBehavior.dart';
import 'package:eqmonitor/utils/svir/svir.dart';
import 'package:eqmonitor/utils/updater/appUpdate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' hide Logger;

import '../private/keys.dart';
import '../utils/earthquake.dart';
import '../utils/map.dart';
import '../utils/messaging.dart';

class RealtimeIntensityMap extends StatelessWidget {
  RealtimeIntensityMap({super.key, required this.backgroundColor});

  final Color? backgroundColor;
  final Logger logger = Logger();
  final EarthQuake earthQuake = Get.find<EarthQuake>();
  final AppUpdate appUpdate = Get.find<AppUpdate>();
  final CustomZoomPanBehavior zoomPanBehavior =
      Get.find<CustomZoomPanBehavior>();
  final Messaging messaging = Get.find<Messaging>();
  final PackageInfo packageInfo = Get.find<PackageInfo>();
  final Key mapKey = const Key('mapKey');
  final MapData mapData = Get.find<MapData>();
  final AssetImageCache aic = Get.find<AssetImageCache>();
  final Svir svir = Get.find<Svir>();
  final KyoshinMonitorlibTime kmoniTime = Get.find<KyoshinMonitorlibTime>();

  String _urlTemplate() {
    // Stadia Maps source https://docs.stadiamaps.com/vector/
    return 'https://earthquake-alert.github.io/maps/pbf_japan/distlict_jma/{z}/{x}/{y}.pbf';
    return 'https://eqmonitorapi.yumnu.xyz/maps/pbf_japan/pref_jma/{z}/{x}/{y}.pbf';
    return 'https://github.com/earthquake-alert/maps/raw/master/pbf_japan/pref_jma/{z}/{x}/{y}.pbf';
    return 'https://tiles.stadiamaps.com/data/openmaptiles/{z}/{x}/{y}.pbf?api_key=$stadiaApiKey';

    // Mapbox source https://docs.mapbox.com/api/maps/vector-tiles/#example-request-retrieve-vector-tiles
    // return 'https://api.mapbox.com/v4/mapbox.mapbox-streets-v8/{z}/{x}/{y}.mvt?access_token=$apiKey',
  }

  VectorTileProvider _cachingTileProvider(String urlTemplate) {
    return MemoryCacheVectorTileProvider(
      delegate: NetworkVectorTileProvider(
        urlTemplate: urlTemplate,
        // this is the maximum zoom of the provider, not the
        // maximum of the map. vector tiles are rendered
        // to larger sizes to support higher zoom levels
        maximumZoom: 10,
      ),
      maxSizeBytes: 1024 * 1024 * 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(
          38.410427,
          141.503906,
        ),
        zoom: 1,
        minZoom: 1,
        maxZoom: 10,
        bounds: LatLngBounds(
          LatLng(20.422746, 122.933653),
          LatLng(45.557243, 153.986844),
        ),
        plugins: [VectorMapTilesPlugin()],
        interactiveFlags: InteractiveFlag.drag |
            InteractiveFlag.flingAnimation |
            InteractiveFlag.pinchZoom |
            InteractiveFlag.doubleTapZoom,
      ),
      layers: [
        VectorTileLayerOptions(
          theme: ProvidedThemes.lightTheme(),
          tileProviders: TileProviders(
            {
              'openmaptiles': _cachingTileProvider(_urlTemplate()),
            },
          ),
          logCacheStats: kDebugMode,
          showTileDebugInfo: kDebugMode,
        ),
      ],
      mapController: earthQuake.mapController,
    );

    /*   return SfMaps(
      layers: <MapLayer>[
        MapShapeLayer(
          source: MapData.japanSource,
          color: backgroundColor,
          zoomPanBehavior: earthQuake.mapZoomPanBehavior,
          initialMarkersCount: earthQuake.analyzedPoint.length +
              earthQuake.eewAnalyzedPoint.length,
          loadingBuilder: (context) => const Center(
            child: CircularProgressIndicator.adaptive(
              strokeWidth: 5,
            ),
          ),
          markerBuilder: (
            context,
            index,
          ) =>
              markerBuilder(
            context,
            index,
            earthQuake,
            aic,
            svir,
            kmoniTime,
          ),
          controller: earthQuake.mapShapeLayerController,
          /*sublayers: [
            MapShapeSublayer(
              source: MapData.areasSource,
              color: Colors.transparent,
              strokeWidth: 1,
            ),
          ],*/
        ),
      ],
    );*/
  }
}
