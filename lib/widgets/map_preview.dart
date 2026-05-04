import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';

class MapPreview extends StatefulWidget {
  final List<Place> places;

  const MapPreview({super.key, required this.places});

  @override
  State<MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<MapPreview> {
  final MapController _mapController = MapController();

  static const LatLng defaultLocation = LatLng(21.5433, 39.1728);

  LatLng currentLocation = defaultLocation;

  static const Map<String, LatLng> placeLocations = {
    'starbucks-salamah': LatLng(21.5740, 39.1575),
    'costa-salamah': LatLng(21.5762, 39.1538),
    'aziz-mall': LatLng(21.5655, 39.1843),
    'albaik-faisaliyah': LatLng(21.5674, 39.1840),
    'king-fahd-hospital': LatLng(21.5608, 39.1904),
    'starbucks-obhur-mall': LatLng(21.7178, 39.1060),
    'costa-red-sea-mall': LatLng(21.6278, 39.1116),
    'red-sea-mall': LatLng(21.6274, 39.1112),
    'albaik-shati': LatLng(21.6040, 39.1150),
    'fakeeh-hospital': LatLng(21.5292, 39.1826),
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    final userLatLng = LatLng(position.latitude, position.longitude);

    if (!mounted) return;

    setState(() {
      currentLocation = userLatLng;
    });

    _mapController.move(userLatLng, 14);
  }

  void _zoomIn() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom + 1,
    );
  }

  void _zoomOut() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom - 1,
    );
  }

  void _goToMyLocation() {
    _mapController.move(currentLocation, 14);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF7076EB).withOpacity(0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7076EB).withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: defaultLocation,
              initialZoom: 12.5,
            ),
            children: [
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  const Color(0xFF0B0626).withOpacity(0.75),
                  BlendMode.multiply,
                ),
                child: TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.app_nawaa',
                ),
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentLocation,
                    width: 56,
                    height: 56,
                    child: const _CurrentLocationMarker(),
                  ),
                  ...widget.places.map((place) {
                    final location = placeLocations[place.id];
                    if (location == null) return null;

                    return Marker(
                      point: location,
                      width: 46,
                      height: 46,
                      child: _PlaceMarker(place: place),
                    );
                  }).whereType<Marker>(),
                ],
              ),
            ],
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Column(
              children: [
                _MapButton(
                  icon: Icons.add,
                  onTap: _zoomIn,
                ),
                const SizedBox(height: 8),
                _MapButton(
                  icon: Icons.remove,
                  onTap: _zoomOut,
                ),
                const SizedBox(height: 8),
                _MapButton(
                  icon: Icons.my_location_rounded,
                  onTap: _goToMyLocation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1A1340).withOpacity(0.92),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: Colors.white,
            size: 19,
          ),
        ),
      ),
    );
  }
}

class _CurrentLocationMarker extends StatelessWidget {
  const _CurrentLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF7076EB).withOpacity(0.24),
          ),
        ),
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFF7076EB),
                Color(0xFF4CA8DA),
              ],
            ),
          ),
          child: const Icon(
            Icons.my_location_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
      ],
    );
  }
}

class _PlaceMarker extends StatelessWidget {
  final Place place;

  const _PlaceMarker({required this.place});

  @override
  Widget build(BuildContext context) {
    final color = switch (place.crowdLevel) {
      CrowdLevel.low => AppState.lowCrowdColor,
      CrowdLevel.medium => AppState.mediumCrowdColor,
      CrowdLevel.high => AppState.highCrowdColor,
    };

    return GestureDetector(
      onTap: () {
        final appState = context.read<AppState>();
        appState.setSelectedPlace(place);
        appState.goTo(AppScreen.placeDetails);
      },
      child: Tooltip(
        message: place.name,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.22),
              ),
            ),
            Container(
              width: 19,
              height: 19,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.45),
                    blurRadius: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}