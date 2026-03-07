import 'package:flutter/material.dart';
import '../../../models/supplier_model.dart';

class SupplierListWidget extends StatelessWidget {
  final List<Supplier> suppliers;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;
  final Function(Supplier) onEdit;
  final Function(Supplier) onView;
  final Function(Supplier) onApprove;
  final Function(Supplier) onBlacklist;

  const SupplierListWidget({
    super.key,
    required this.suppliers,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.onEdit,
    required this.onView,
    required this.onApprove,
    required this.onBlacklist,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (suppliers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.business, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No suppliers found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: suppliers.length,
        itemBuilder: (context, index) => _buildSupplierCard(suppliers[index]),
      ),
    );
  }

  Widget _buildSupplierCard(Supplier supplier) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplier.companyName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (supplier.tradingName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          supplier.tradingName!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text('Supplier #: ${supplier.supplierNumber}'),
                      Text('Reg #: ${supplier.registrationNumber}'),
                    ],
                  ),
                ),
                _buildStatusBadge(supplier.status),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(supplier.supplierTier),
                  backgroundColor: _getTierColor(supplier.supplierTier),
                ),
                Chip(
                  label: Text(supplier.riskRating),
                  backgroundColor: _getRiskColor(supplier.riskRating),
                ),
                ...supplier.nawasscoCategories.take(2).map((category) => Chip(
                  label: Text(category),
                  backgroundColor: Colors.blue[50],
                )),
                if (supplier.nawasscoCategories.length > 2)
                  Chip(
                    label: Text('+${supplier.nawasscoCategories.length - 2} more'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Contact: ${supplier.contactDetails['primaryEmail']}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                _buildActionButtons(supplier),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final statusColors = {
      'approved': Colors.green,
      'pending': Colors.orange,
      'draft': Colors.grey,
      'blacklisted': Colors.red,
      'rejected': Colors.red,
    };

    final color = statusColors[status.toLowerCase()] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getTierColor(String tier) {
    return switch (tier.toLowerCase()) {
      'tier_1' => Colors.green[50]!,
      'preferred' => Colors.blue[50]!,
      'strategic' => Colors.purple[50]!,
      _ => Colors.grey[50]!,
    };
  }

  Color _getRiskColor(String risk) {
    return switch (risk.toLowerCase()) {
      'low' => Colors.green[50]!,
      'medium' => Colors.orange[50]!,
      'high' => Colors.red[50]!,
      'very_high' => Colors.red[100]!,
      _ => Colors.grey[50]!,
    };
  }

  Widget _buildActionButtons(Supplier supplier) {
    return Row(
      children: [
        IconButton(
          onPressed: () => onView(supplier),
          icon: const Icon(Icons.visibility, size: 20),
          tooltip: 'View Details',
        ),
        if (supplier.status.toLowerCase() == 'pending') ...[
          IconButton(
            onPressed: () => onApprove(supplier),
            icon: const Icon(Icons.check, size: 20, color: Colors.green),
            tooltip: 'Approve',
          ),
          IconButton(
            onPressed: () => onBlacklist(supplier),
            icon: const Icon(Icons.block, size: 20, color: Colors.red),
            tooltip: 'Blacklist',
          ),
        ],
        if (supplier.status.toLowerCase() == 'blacklisted')
          IconButton(
            onPressed: () => onEdit(supplier),
            icon: const Icon(Icons.lock_open, size: 20, color: Colors.orange),
            tooltip: 'Reinstate',
          ),
        IconButton(
          onPressed: () => onEdit(supplier),
          icon: const Icon(Icons.edit, size: 20),
          tooltip: 'Edit',
        ),
      ],
    );
  }
}