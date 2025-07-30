import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerMap extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final Function(double?, double?) onLocationSelected;

  const LocationPickerMap({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  _LocationPickerMapState createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> {
  LatLng? selectedLocation;
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      selectedLocation = LatLng(widget.initialLatitude!, widget.initialLongitude!);
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      selectedLocation = point;
    });
    widget.onLocationSelected(point.latitude, point.longitude);
  }

  void _clearLocation() {
    setState(() {
      selectedLocation = null;
    });
    widget.onLocationSelected(null, null);
  }

  @override
  Widget build(BuildContext context) {
    final center = selectedLocation ?? LatLng(40.7128, -74.0060); // Default to NYC
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        children: [
          // Map controls
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: colorScheme.onSurfaceVariant),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Toca en el mapa para seleccionar ubicación',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (selectedLocation != null)
                  TextButton.icon(
                    onPressed: _clearLocation,
                    icon: Icon(Icons.clear, size: 16),
                    label: Text('Limpiar'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size(0, 32),
                      foregroundColor: colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          
          // Map
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Container(
                color: isDark ? Colors.black : Colors.white,
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: selectedLocation != null ? 13.0 : 2.0,
                    onTap: _onMapTap,
                    backgroundColor: isDark ? Colors.black : Colors.white,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom | 
                             InteractiveFlag.drag |
                             InteractiveFlag.doubleTapZoom,
                    ),
                  ),
                  children: [
                    // Map tile layer with dark mode filter
                    ColorFiltered(
                      colorFilter: isDark
                          ? ColorFilter.matrix([
                              -0.2126, -0.7152, -0.0722, 0, 255, // Red channel
                              -0.2126, -0.7152, -0.0722, 0, 255, // Green channel
                              -0.2126, -0.7152, -0.0722, 0, 255, // Blue channel
                              0, 0, 0, 1, 0, // Alpha channel
                            ])
                          : ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                      child: TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.devinaxo.gatodex',
                        maxZoom: 19,
                      ),
                    ),
                    // Marker layer
                    if (selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: selectedLocation!,
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
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
