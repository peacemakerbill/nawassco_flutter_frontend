import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../models/water_source_model.dart';

class WaterSourceMap extends StatefulWidget {
  final List<WaterSource> waterSources;
  final Function(WaterSource) onSourceSelected;

  const WaterSourceMap({
    Key? key,
    required this.waterSources,
    required this.onSourceSelected,
  }) : super(key: key);

  @override
  State<WaterSourceMap> createState() => _WaterSourceMapState();
}

class _WaterSourceMapState extends State<WaterSourceMap> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  LatLng? _center;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    if (widget.waterSources.isNotEmpty) {
      final firstSource = widget.waterSources.first;
      _center = LatLng(
        firstSource.location.coordinates.latitude,
        firstSource.location.coordinates.longitude,
      );
      _createMarkers();
    } else {
      _center = const LatLng(-0.3031, 36.0800); // Default to Nakuru
    }
  }

  void _createMarkers() {
    _markers.clear();

    for (final source in widget.waterSources) {
      final marker = Marker(
        markerId: MarkerId(source.id),
        position: LatLng(
          source.location.coordinates.latitude,
          source.location.coordinates.longitude,
        ),
        infoWindow: InfoWindow(
          title: source.name,
          snippet: '${source.type.displayName} - ${source.status.displayName}',
        ),
        icon: _getMarkerIcon(source),
        onTap: () => widget.onSourceSelected(source),
      );
      _markers.add(marker);
    }

    setState(() {});
  }

  BitmapDescriptor _getMarkerIcon(WaterSource source) {
    // This is a simplified version. In production, you would create
    // custom bitmap descriptors for different source types/statuses.
    switch (source.status) {
      case SourceStatus.OPERATIONAL:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case SourceStatus.MAINTENANCE:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case SourceStatus.CONTAMINATED:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case SourceStatus.LIMITED:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_center == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _center!,
            zoom: 10,
          ),
          markers: _markers,
          onMapCreated: (controller) {
            _mapController = controller;
          },
          mapType: MapType.normal,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
        ),
        // Legend
        Positioned(
          top: 16,
          right: 16,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Legend',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildLegendItem('Operational', Colors.green),
                  _buildLegendItem('Maintenance', Colors.orange),
                  _buildLegendItem('Limited', Colors.yellow),
                  _buildLegendItem('Contaminated', Colors.red),
                  _buildLegendItem('Other', Colors.blue),
                ],
              ),
            ),
          ),
        ),
        // Source count
        Positioned(
          bottom: 16,
          left: 16,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                '${widget.waterSources.length} water sources',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}