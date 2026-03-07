import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/meter_reading_model.dart';
import '../../../providers/meter_reading_provider.dart';
import 'meter_reading_card.dart';

class MeterReadingList extends ConsumerWidget {
  final List<MeterReading> readings;

  const MeterReadingList({super.key, required this.readings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (readings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.water_damage_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No meter readings found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a new reading or adjust your filters',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: readings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return MeterReadingCard(
          reading: readings[index],
          onTap: () {
            ref.read(meterReadingProvider.notifier).selectReading(readings[index]);
          },
        );
      },
    );
  }
}