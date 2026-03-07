import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/vehicle.dart';
import '../../../providers/vehicle_provider.dart';
import '../sub_widgets/vehicle/vehicle_details_widget.dart';
import '../sub_widgets/vehicle/vehicle_form_widget.dart';
import '../sub_widgets/vehicle/vehicle_list_widget.dart';
import '../sub_widgets/vehicle/vehicle_metrics_widget.dart';

class VehicleContent extends ConsumerStatefulWidget {
  const VehicleContent({super.key});

  @override
  ConsumerState<VehicleContent> createState() => _VehicleContentState();
}

class _VehicleContentState extends ConsumerState<VehicleContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  VehicleView _currentView = VehicleView.list;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToView(VehicleView view, {Vehicle? vehicle}) {
    setState(() {
      _currentView = view;
      if (vehicle != null) {
        ref.read(vehicleProvider.notifier).selectVehicle(vehicle);
      }
    });
  }

  void _goBack() {
    setState(() {
      _currentView = VehicleView.list;
      ref.read(vehicleProvider.notifier).selectVehicle(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vehicleProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _buildCurrentView(state),
          ),
        ],
      ),
      floatingActionButton: _currentView == VehicleView.list
          ? FloatingActionButton(
        onPressed: () => _navigateToView(VehicleView.create),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentView != VehicleView.list) ...[
            IconButton(
              onPressed: _goBack,
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back to list',
            ),
            const SizedBox(width: 8),
          ],
          const Icon(Icons.directions_car, color: Colors.blue, size: 28),
          const SizedBox(width: 12),
          Text(
            _getHeaderTitle(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          if (_currentView == VehicleView.list) ...[
            _buildViewToggle(),
            const SizedBox(width: 16),
            _buildFilterButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentView(VehicleState state) {
    switch (_currentView) {
      case VehicleView.list:
        return VehicleListWidget(
          onVehicleSelected: (vehicle) => _navigateToView(VehicleView.details, vehicle: vehicle),
          onCreateNew: () => _navigateToView(VehicleView.create),
        );
      case VehicleView.details:
        return VehicleDetailsWidget(
          onEdit: () => _navigateToView(VehicleView.edit),
          onBack: _goBack,
        );
      case VehicleView.create:
        return VehicleFormWidget(
          onSave: () => _navigateToView(VehicleView.list),
          onCancel: _goBack,
        );
      case VehicleView.edit:
        return VehicleFormWidget(
          isEditing: true,
          onSave: () => _navigateToView(VehicleView.details),
          onCancel: _goBack,
        );
      case VehicleView.metrics:
        return const VehicleMetricsWidget();
    }
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildViewOption('List', VehicleView.list),
          const SizedBox(width: 8),
          _buildViewOption('Metrics', VehicleView.metrics),
        ],
      ),
    );
  }

  Widget _buildViewOption(String text, VehicleView view) {
    final isSelected = _currentView == view;
    return GestureDetector(
      onTap: () => setState(() => _currentView = view),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list, color: Colors.blue),
      onSelected: (value) {
        // Handle filter selection
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'all', child: Text('All Vehicles')),
        const PopupMenuItem(value: 'available', child: Text('Available')),
        const PopupMenuItem(value: 'in_use', child: Text('In Use')),
        const PopupMenuItem(value: 'maintenance', child: Text('Under Maintenance')),
      ],
    );
  }

  String _getHeaderTitle() {
    switch (_currentView) {
      case VehicleView.list:
        return 'Vehicle Fleet';
      case VehicleView.details:
        return 'Vehicle Details';
      case VehicleView.create:
        return 'Add New Vehicle';
      case VehicleView.edit:
        return 'Edit Vehicle';
      case VehicleView.metrics:
        return 'Fleet Metrics';
    }
  }
}

enum VehicleView {
  list,
  details,
  create,
  edit,
  metrics,
}