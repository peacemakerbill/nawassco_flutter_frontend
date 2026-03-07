import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/fixed_asset_model.dart';
import '../../../../providers/fixed_asset_provider.dart';
import 'fixed_asset_details.dart';
import 'fixed_asset_form.dart';

class FixedAssetCard extends ConsumerWidget {
  final FixedAsset asset;

  const FixedAssetCard({super.key, required this.asset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 4 : 8,
        vertical: 6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => FixedAssetDetails(assetId: asset.id),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  _buildCategoryIcon(),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.assetName,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          asset.assetNumber,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: isSmallScreen ? 18 : 20),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit Asset'),
                          ],
                        ),
                      ),
                      if (asset.status == AssetStatus.active ||
                          asset.status == AssetStatus.idle) ...[
                        if (asset.isDepreciable) ...[
                          const PopupMenuItem(
                            value: 'calculate_depreciation',
                            child: Row(
                              children: [
                                Icon(Icons.calculate, size: 18),
                                SizedBox(width: 8),
                                Text('Calculate Depreciation'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'post_depreciation',
                            child: Row(
                              children: [
                                Icon(Icons.post_add, size: 18),
                                SizedBox(width: 8),
                                Text('Post Depreciation'),
                              ],
                            ),
                          ),
                        ],
                        const PopupMenuItem(
                          value: 'dispose',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Dispose Asset',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ],
                    onSelected: (value) {
                      _handleMenuAction(value, context, ref);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: asset.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: asset.statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  asset.statusDisplayName,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 9 : 10,
                    fontWeight: FontWeight.w500,
                    color: asset.statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Financial Info - Responsive layout
              if (!isSmallScreen) ...[
                _buildInfoRow(
                    'Acquisition Cost', _formatCurrency(asset.acquisitionCost)),
                _buildInfoRow(
                    'Current Value', _formatCurrency(asset.currentBookValue)),
                _buildInfoRow('Accumulated Dep.',
                    _formatCurrency(asset.accumulatedDepreciation)),
                const SizedBox(height: 12),
              ] else ...[
                // Compact financial info for small screens
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatCurrency(asset.acquisitionCost),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Acquisition Cost',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatCurrency(asset.currentBookValue),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Current Value',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Location & Department - Responsive layout
              if (!isSmallScreen) ...[
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        asset.location,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.business, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        asset.department,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // Supplier Info (Optional)
                if (asset.supplierName != null && asset.supplierName!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.business, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          asset.supplierName!,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                // Purchase Order Info (Optional)
                if (asset.purchaseOrderNumber != null && asset.purchaseOrderNumber!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.receipt, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'PO: ${asset.purchaseOrderNumber!}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ] else ...[
                // Compact location info for small screens
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        asset.location,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.business, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        asset.department,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),
              // Actions - Responsive layout
              if (asset.status == AssetStatus.active ||
                  asset.status == AssetStatus.idle)
                Row(
                  children: [
                    if (!isSmallScreen) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _showQuickActions(context, ref);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          child: const Text(
                            'Quick Actions',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editAsset(context),
                        icon: const Icon(Icons.edit, size: 16),
                        label: Text(
                          isSmallScreen ? 'Edit' : 'Edit Asset',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                    if (!isSmallScreen) const SizedBox(width: 8),
                    if (!isSmallScreen)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showQuickActions(context, ref),
                          icon: const Icon(Icons.bolt, size: 16),
                          label: const Text(
                            'Actions',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    IconData icon;
    Color color;

    switch (asset.assetCategory) {
      case AssetCategory.land:
        icon = Icons.landscape;
        color = Colors.green;
        break;
      case AssetCategory.buildings:
        icon = Icons.business;
        color = Colors.blue;
        break;
      case AssetCategory.vehicles:
        icon = Icons.directions_car;
        color = Colors.orange;
        break;
      case AssetCategory.equipment:
        icon = Icons.build;
        color = Colors.purple;
        break;
      case AssetCategory.furniture:
        icon = Icons.chair;
        color = Colors.brown;
        break;
      case AssetCategory.computers:
        icon = Icons.computer;
        color = Colors.blueGrey;
        break;
      case AssetCategory.office_equipment:
        icon = Icons.print;
        color = Colors.teal;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return 'KES ${amount.toStringAsFixed(2)}';
  }

  void _handleMenuAction(String value, BuildContext context, WidgetRef ref) {
    switch (value) {
      case 'edit':
        _editAsset(context);
        break;
      case 'calculate_depreciation':
        _calculateDepreciation(context, ref);
        break;
      case 'post_depreciation':
        _postDepreciation(context, ref);
        break;
      case 'dispose':
        _disposeAsset(context, ref);
        break;
    }
  }

  void _showQuickActions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quick Actions - ${asset.assetName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            if (asset.isDepreciable && asset.status == AssetStatus.active) ...[
              _buildActionButton(
                context,
                Icons.calculate,
                'Calculate Depreciation',
                Colors.blue,
                    () {
                  Navigator.pop(context);
                  _calculateDepreciation(context, ref);
                },
              ),
              _buildActionButton(
                context,
                Icons.post_add,
                'Post Depreciation',
                Colors.green,
                    () {
                  Navigator.pop(context);
                  _postDepreciation(context, ref);
                },
              ),
            ],
            _buildActionButton(
              context,
              Icons.edit,
              'Edit Asset',
              Colors.orange,
                  () {
                Navigator.pop(context);
                _editAsset(context);
              },
            ),
            _buildActionButton(
              context,
              Icons.delete_outline,
              'Dispose Asset',
              Colors.red,
                  () {
                Navigator.pop(context);
                _disposeAsset(context, ref);
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context,
      IconData icon,
      String text,
      Color color,
      VoidCallback onPressed,
      ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  void _editAsset(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Color(0xFF0D47A1), size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Edit Fixed Asset',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: FixedAssetForm(initialAsset: asset),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _calculateDepreciation(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(fixedAssetsProvider.notifier)
        .calculateDepreciation(asset.id);
    if (result != null && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Depreciation Calculation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Asset: ${asset.assetName}'),
              const SizedBox(height: 16),
              _buildInfoRow('Depreciation Amount',
                  _formatCurrency(result.depreciationAmount)),
              _buildInfoRow(
                  'New Book Value', _formatCurrency(result.newBookValue)),
              _buildInfoRow('Accumulated Depreciation',
                  _formatCurrency(result.newAccumulatedDepreciation)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _postDepreciation(context, ref);
              },
              child: const Text('Post Depreciation'),
            ),
          ],
        ),
      );
    }
  }

  void _postDepreciation(BuildContext context, WidgetRef ref) async {
    final success =
    await ref.read(fixedAssetsProvider.notifier).postDepreciation(asset.id);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Depreciation posted for ${asset.assetName}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _disposeAsset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _AssetDisposalDialog(asset: asset),
    );
  }
}

class _AssetDisposalDialog extends ConsumerStatefulWidget {
  final FixedAsset asset;

  const _AssetDisposalDialog({required this.asset});

  @override
  ConsumerState<_AssetDisposalDialog> createState() =>
      _AssetDisposalDialogState();
}

class _AssetDisposalDialogState extends ConsumerState<_AssetDisposalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _disposalAmountController = TextEditingController();
  DateTime _disposalDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dispose Asset'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Asset: ${widget.asset.assetName}'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _disposalAmountController,
              decoration: const InputDecoration(
                labelText: 'Disposal Amount (KES)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter disposal amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Disposal Date',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  children: [
                    Text(_disposalDate.toLocal().toString().split(' ')[0]),
                    const Spacer(),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitDisposal,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Dispose Asset'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _disposalDate,
      firstDate: widget.asset.acquisitionDate,
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _disposalDate) {
      setState(() {
        _disposalDate = picked;
      });
    }
  }

  void _submitDisposal() async {
    if (_formKey.currentState!.validate()) {
      final disposalAmount =
          double.tryParse(_disposalAmountController.text) ?? 0;
      final success = await ref.read(fixedAssetsProvider.notifier).disposeAsset(
        widget.asset.id,
        _disposalDate,
        disposalAmount,
      );

      if (success && context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _disposalAmountController.dispose();
    super.dispose();
  }
}