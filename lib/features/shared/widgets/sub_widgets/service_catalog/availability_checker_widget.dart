import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/service_catalog_model.dart';

class AvailabilityCheckerWidget extends ConsumerStatefulWidget {
  final ServiceCatalog? service;
  final String? areaId;
  final String? customerType;

  const AvailabilityCheckerWidget({
    super.key,
    this.service,
    this.areaId,
    this.customerType,
  });

  @override
  ConsumerState<AvailabilityCheckerWidget> createState() =>
      _AvailabilityCheckerWidgetState();
}

class _AvailabilityCheckerWidgetState
    extends ConsumerState<AvailabilityCheckerWidget> {
  final _areaController = TextEditingController();
  final _customerTypeController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    if (widget.areaId != null) _areaController.text = widget.areaId!;
    if (widget.customerType != null)
      _customerTypeController.text = widget.customerType!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Check Availability',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Verify if this service is available in your area',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          // Form
          TextFormField(
            controller: _areaController,
            decoration: const InputDecoration(
              labelText: 'Area',
              hintText: 'Enter your area (e.g., Nakuru Town)',
              prefixIcon: Icon(Icons.location_city),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _customerTypeController.text.isNotEmpty
                ? _customerTypeController.text
                : CustomerType.residential.name,
            decoration: const InputDecoration(
              labelText: 'Customer Type',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: CustomerType.values.map((type) {
              return DropdownMenuItem(
                value: type.name,
                child: Text(type.displayName),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _customerTypeController.text = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // Check Button
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _checkAvailability,
            icon: _isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.search),
            label: Text(_isLoading ? 'Checking...' : 'Check Availability'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 48),
              backgroundColor: Colors.blue.shade600,
            ),
          ),

          // Result
          if (_result != null) ...[
            const SizedBox(height: 16),
            _buildResultCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final available = _result?['available'] == true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: available ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: available ? Colors.green.shade100 : Colors.red.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                available ? Icons.check_circle : Icons.error,
                color: available ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                available ? 'Service Available!' : 'Service Not Available',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      available ? Colors.green.shade800 : Colors.red.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_result?['reasons'] != null &&
              (_result!['reasons'] as List).isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reasons:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                ...(_result!['reasons'] as List).map((reason) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 2),
                    child: Text('• $reason'),
                  );
                }).toList(),
              ],
            ),
          if (available) const SizedBox(height: 12),
          if (available)
            ElevatedButton(
              onPressed: () {
                // Navigate to application
              },
              child: Text('Apply Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 40),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _checkAvailability() async {
    if (_areaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an area')),
      );
      return;
    }

    if (_customerTypeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select customer type')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // This would call the API
      // final result = await ref.read(serviceCatalogProvider.notifier)
      //     .validateAvailability(
      //       widget.service?.id ?? '',
      //       _areaController.text,
      //       _customerTypeController.text,
      //     );

      // Simulate API call
      await Future.delayed(Duration(seconds: 1));

      // Mock result
      final mockResult = {
        'available': true,
        'reasons': [],
      };

      setState(() {
        _result = mockResult;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking availability')),
      );
    }
  }

  @override
  void dispose() {
    _areaController.dispose();
    _customerTypeController.dispose();
    super.dispose();
  }
}
