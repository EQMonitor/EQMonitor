import 'package:eqmonitor/utils/KyoshinMonitorlib/JmaIntensity.dart';
import 'package:flutter/material.dart' show Color;
import 'package:get/get.dart';

class AnalyzedPoint {
  AnalyzedPoint({
    required this.code,
    required this.name,
    required this.pref,
    required this.lat,
    required this.lon,
    required this.x,
    required this.y,
    required this.pointType,
    required this.shindoColor,
    required this.pgaColor,
    required this.shindo,
    required this.zoomLevel,
    required this.pga,
    required this.intensity,
  });

  final String code;
  final String name;
  final String pref;
  final double lat;
  final double lon;
  final int x;
  final int y;
  final PointType pointType;
  Color shindoColor;
  Color pgaColor;
  double? shindo;
  double zoomLevel;
  double? pga;
  JmaIntensity intensity;
}

enum PointType {
  Observer,
  Swave,
  Pwave,
  HypoCenter,
}
