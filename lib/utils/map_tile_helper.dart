import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MapTileHelper {
  static const _darkModeMatrix = ColorFilter.matrix([
    -0.2126, -0.7152, -0.0722, 0, 255,
    -0.2126, -0.7152, -0.0722, 0, 255,
    -0.2126, -0.7152, -0.0722, 0, 255,
    0, 0, 0, 1, 0,
  ]);

  static const _identityFilter = ColorFilter.mode(
    Colors.transparent,
    BlendMode.multiply,
  );

  static Widget buildTileLayer({required bool isDark}) {
    return ColorFiltered(
      colorFilter: isDark ? _darkModeMatrix : _identityFilter,
      child: TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.devinaxo.gatodex',
        maxZoom: 19,
      ),
    );
  }
}
