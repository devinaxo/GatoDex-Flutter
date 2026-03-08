import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../utils/map_tile_helper.dart';

class CatLocationMap extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String catName;
  final double height;

  const CatLocationMap({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.catName,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final location = LatLng(latitude, longitude);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: isDark ? Colors.black : Colors.white,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: location,
              initialZoom: 13.0,
              backgroundColor: isDark ? Colors.black : Colors.white,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag | InteractiveFlag.doubleTapZoom,
              ),
            ),
            children: [
              MapTileHelper.buildTileLayer(isDark: isDark),
              MarkerLayer(
                markers: [
                  Marker(
                    point: location,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.surface, width: 2),
                        boxShadow: [
                          BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Icon(Icons.pets, color: colorScheme.onPrimary, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
