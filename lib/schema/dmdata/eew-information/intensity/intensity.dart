import 'appendix.dart';

import 'forecastmaxint.dart';
import 'region.dart';

/// `VXSE43`,`VXSE44`,`VXSE45`時に出現しますが、予測震度を計算していない場合や取消時には出現しません。
/// 震度の表現として、`0`,`1`,`2`,`3`,`4`,`5-`,`5+`,`6-`,`6+`,`7`,`over`,`不明`を使用します。
/// 長周期地震動階級の表現として、`0`,`1`,`2`,`3`,`4`,`over`,`不明`を使用します。
/// 震度または長周期地震動階級で程度以上を使用する場合は、フィールド`to`に`over`を入れ表現します。
class Intensity {
  Intensity({
    required this.maxint,
    required this.forecastMaxLpgmInt,
    required this.appendix,
    required this.region,
  });
  Intensity.fromJson(Map<String, dynamic> j)
      : maxint = ForecastMaxInt.fromJson(
          j['forecastMaxInt'] as Map<String, dynamic>,
        ),
        forecastMaxLpgmInt = (j['forecastMaxLpgmInt'].toString() == 'null')
            ? null
            : ForecastMaxInt.fromJson(
                j['forecastMaxLpgmInt'] as Map<String, dynamic>,
              ),
        appendix = (j['appendix'].toString() == 'null')
            ? null
            : Appendix.fromJson(j['appendix'] as Map<String, dynamic>),
        region = List.generate(
          (j['regions'] as List<dynamic>).length,
          (index) => Region.fromJson(
            (j['regions'] as List<dynamic>)[index] as Map<String, dynamic>,
          ),
        );

  /// 最大予測震度を記載する
  final ForecastMaxInt maxint;

  /// 最大予測長周期地震動階級を記載する
  final ForecastMaxInt? forecastMaxLpgmInt;

  /// 予測震度・予測長周期地震動階級付加要素
  final Appendix? appendix;

  /// 細分化地域内における予想
  final List<Region> region;
}
