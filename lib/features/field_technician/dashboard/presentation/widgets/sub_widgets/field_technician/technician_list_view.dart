import 'package:flutter/material.dart';
import '../../../../models/field_technician.dart';
import 'technician_list_tile.dart';

class TechnicianListView extends StatelessWidget {
  final List<FieldTechnician> technicians;

  const TechnicianListView({super.key, required this.technicians});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TechnicianListTile(technician: technicians[index]),
          ),
          childCount: technicians.length,
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) => TechnicianListTile(technician: technicians[index]),
        childCount: technicians.length,
      ),
    );
  }
}