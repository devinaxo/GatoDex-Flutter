import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gatodex/l10n/app_localizations.dart';
import '../../utils/map_tile_helper.dart';

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
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      selectedLocation = LatLng(widget.initialLatitude!, widget.initialLongitude!);
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() => selectedLocation = point);
    widget.onLocationSelected(point.latitude, point.longitude);
  }

  void _clearLocation() {
    setState(() => selectedLocation = null);
    widget.onLocationSelected(null, null);
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError(AppLocalizations.of(context).locationPermissionDenied);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationError(AppLocalizations.of(context).locationPermissionPermanentlyDenied);
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError(AppLocalizations.of(context).locationServicesDisabled);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final currentLocation = LatLng(position.latitude, position.longitude);

      setState(() => selectedLocation = currentLocation);
      mapController.move(currentLocation, 15.0);
      widget.onLocationSelected(position.latitude, position.longitude);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).currentLocationSet), backgroundColor: Theme.of(context).colorScheme.primary, duration: const Duration(seconds: 2)),
        );
      }
    } catch (e) {
      _showLocationError(AppLocalizations.of(context).errorGettingLocation(e.toString()));
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _showLocationError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error, duration: const Duration(seconds: 4)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = selectedLocation ?? LatLng(40.7128, -74.0060);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n.tapMapToSelectLocation, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                ),
                IconButton(
                  onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                  icon: _isLoadingLocation
                      ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary))
                      : const Icon(Icons.my_location, size: 18),
                  tooltip: l10n.useMyCurrentLocation,
                  style: IconButton.styleFrom(padding: const EdgeInsets.all(8), minimumSize: const Size(32, 32), foregroundColor: colorScheme.primary),
                ),
                if (selectedLocation != null)
                  TextButton.icon(
                    onPressed: _clearLocation,
                    icon: const Icon(Icons.clear, size: 16),
                    label: Text(l10n.clear),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(0, 32), foregroundColor: colorScheme.primary),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
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
                      flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag | InteractiveFlag.doubleTapZoom,
                    ),
                  ),
                  children: [
                    MapTileHelper.buildTileLayer(isDark: isDark),
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
          ),
        ],
      ),
    );
  }
}
