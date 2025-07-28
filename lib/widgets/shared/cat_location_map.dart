import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
    final LatLng location = LatLng(latitude, longitude);
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
              interactionOptions: const InteractionOptions(
                flags:
                    InteractiveFlag.pinchZoom |
                    InteractiveFlag.drag |
                    InteractiveFlag.doubleTapZoom,
              ),
            ),
            children: [
              // Map tile layer with dark mode filter
              ColorFiltered(
                colorFilter: isDark
                    ? ColorFilter.matrix([
                        -1.0, 0.0, 0.0, 0.0, 255.0, // Invert red
                        0.0, -1.0, 0.0, 0.0, 255.0, // Invert green  
                        0.0, 0.0, -1.0, 0.0, 255.0, // Invert blue
                        0.0, 0.0, 0.0, 1.0, 0.0,    // Keep alpha unchanged
                      ])
                    : ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                child: TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.gatodex',
                  maxZoom: 19,
                ),
              ),
              // Marker layer  
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
                        border: Border.all(
                          color: colorScheme.surface, 
                          width: 2
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.pets, 
                        color: colorScheme.onPrimary, 
                        size: 20
                      ),
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
