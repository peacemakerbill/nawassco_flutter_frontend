import 'package:flutter/material.dart';

import '../../../models/outage.dart';

class OutageMapWidget extends StatefulWidget {
  final List<Outage> outages;
  final Function(String) onZoneSelected;

  const OutageMapWidget({
    super.key,
    required this.outages,
    required this.onZoneSelected,
  });

  @override
  State<OutageMapWidget> createState() => _OutageMapWidgetState();
}

class _OutageMapWidgetState extends State<OutageMapWidget> {
  final Map<String, Color> _zoneColors = {
    'Nakuru East': Colors.red,
    'Bahati': Colors.orange,
    'Molo': Colors.blue,
    'Naivasha': Colors.green,
    'Gilgil': Colors.purple,
    'Njoro': Colors.teal,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Outage Map',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    const Text('Interactive Map'),
                    Text(
                      '${widget.outages.length} active outages shown',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _buildZoneChips(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildZoneChips() {
    // Count outages per zone
    final zoneCounts = <String, int>{};
    for (var outage in widget.outages) {
      for (var area in outage.affectedAreas) {
        zoneCounts[area.zone] = (zoneCounts[area.zone] ?? 0) + 1;
      }
    }

    // Add all zones with their counts
    final zones = [
      'Nakuru East',
      'Bahati',
      'Molo',
      'Naivasha',
      'Gilgil',
      'Njoro',
    ];

    return zones.map((zone) {
      final count = zoneCounts[zone] ?? 0;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ActionChip(
          avatar: CircleAvatar(
            backgroundColor: _zoneColors[zone],
            radius: 8,
          ),
          label: Text('$zone ($count)'),
          onPressed: () => widget.onZoneSelected(zone),
        ),
      );
    }).toList();
  }
}
