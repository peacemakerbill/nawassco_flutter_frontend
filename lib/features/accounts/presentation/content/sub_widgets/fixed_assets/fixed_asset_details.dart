import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/fixed_asset_model.dart';
import '../../../../providers/fixed_asset_provider.dart';

class FixedAssetDetails extends ConsumerStatefulWidget {
  final String assetId;

  const FixedAssetDetails({super.key, required this.assetId});

  @override
  ConsumerState<FixedAssetDetails> createState() => _FixedAssetDetailsState();
}

class _FixedAssetDetailsState extends ConsumerState<FixedAssetDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Fetch asset details when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fixedAssetsProvider.notifier).fetchAssetById(widget.assetId);
      ref
          .read(fixedAssetsProvider.notifier)
          .fetchDepreciationSchedule(widget.assetId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fixedAssetsProvider);
    final asset = state.selectedAsset;

    if (asset == null && state.isLoading) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (asset == null) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Failed to load asset details',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(fixedAssetsProvider.notifier)
                    .fetchAssetById(widget.assetId),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
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
                _buildCategoryIcon(asset),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.assetName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        asset.assetNumber,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: asset.statusColor.withOpacity(0.1),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: asset.statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  asset.statusDisplayName,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: asset.statusColor,
                  ),
                ),
                const Spacer(),
                if (asset.insured)
                  Row(
                    children: [
                      const Icon(Icons.security, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'Insured',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Tabs
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF0D47A1),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF0D47A1),
              labelStyle: const TextStyle(fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Financial'),
                Tab(text: 'Depreciation'),
                Tab(text: 'Maintenance'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(asset),
                _buildFinancialTab(asset),
                _buildDepreciationTab(asset, state),
                _buildMaintenanceTab(asset),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(FixedAsset asset) {
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 24, color: color),
    );
  }

  Widget _buildOverviewTab(FixedAsset asset) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Information
          _buildSectionTitle('Basic Information'),
          const SizedBox(height: 12),
          _buildInfoCard([
            _buildInfoItem('Asset Category', asset.categoryDisplayName),
            _buildInfoItem('Description', asset.description),
            _buildInfoItem('Location', asset.location),
            _buildInfoItem('Department', asset.department),
          ]),

          const SizedBox(height: 20),

          // Acquisition Details
          _buildSectionTitle('Acquisition Details'),
          const SizedBox(height: 12),
          _buildInfoCard([
            _buildInfoItem(
                'Acquisition Date', _formatDate(asset.acquisitionDate)),
            _buildInfoItem(
                'Acquisition Cost', _formatCurrency(asset.acquisitionCost)),
          ]),

          const SizedBox(height: 20),

          // Supplier & Purchase Order Details - NEW SECTION
          if ((asset.supplierName != null && asset.supplierName!.isNotEmpty) ||
              (asset.purchaseOrderNumber != null &&
                  asset.purchaseOrderNumber!.isNotEmpty)) ...[
            _buildSectionTitle('Supplier & Purchase Order'),
            const SizedBox(height: 12),
            _buildInfoCard([
              if (asset.supplierName != null && asset.supplierName!.isNotEmpty)
                _buildInfoItem('Supplier Name', asset.supplierName!),
              if (asset.purchaseOrderNumber != null &&
                  asset.purchaseOrderNumber!.isNotEmpty)
                _buildInfoItem('Purchase Order Number', asset.purchaseOrderNumber!),
            ]),
            const SizedBox(height: 20),
          ],

          // Insurance Information
          if (asset.insured) ...[
            _buildSectionTitle('Insurance Information'),
            const SizedBox(height: 12),
            _buildInfoCard([
              _buildInfoItem('Insurance Value',
                  _formatCurrency(asset.insuranceValue ?? 0)),
              if (asset.insuranceExpiry != null)
                _buildInfoItem(
                    'Insurance Expiry', _formatDate(asset.insuranceExpiry!)),
            ]),
            const SizedBox(height: 20),
          ],

          // Metadata
          _buildSectionTitle('Metadata'),
          const SizedBox(height: 12),
          _buildInfoCard([
            _buildInfoItem(
                'Created By',
                asset.createdBy != null
                    ? '${asset.createdBy!['firstName']} ${asset.createdBy!['lastName']}'
                    : 'System'),
            _buildInfoItem('Created Date', _formatDate(asset.createdAt)),
            _buildInfoItem('Last Updated', _formatDate(asset.updatedAt)),
          ]),
        ],
      ),
    );
  }

  Widget _buildFinancialTab(FixedAsset asset) {
    final depreciationPercent = asset.acquisitionCost > 0
        ? (asset.accumulatedDepreciation / asset.acquisitionCost) * 100
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial Summary
          _buildSectionTitle('Financial Summary'),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildFinancialMetric(
                      'Acquisition Cost', asset.acquisitionCost),
                  const SizedBox(height: 12),
                  _buildFinancialMetric(
                      'Current Book Value', asset.currentBookValue),
                  const SizedBox(height: 12),
                  _buildFinancialMetric('Accumulated Depreciation',
                      asset.accumulatedDepreciation),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: depreciationPercent / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      depreciationPercent > 50 ? Colors.red : Colors.orange,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0%',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '${depreciationPercent.toStringAsFixed(1)}% Depreciated',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '100%',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Depreciation Settings
          _buildSectionTitle('Depreciation Settings'),
          const SizedBox(height: 12),
          _buildInfoCard([
            _buildInfoItem('Depreciation Method',
                _getDepreciationMethodName(asset.depreciationMethod)),
            _buildInfoItem('Useful Life', '${asset.usefulLife} years'),
            _buildInfoItem(
                'Salvage Value', _formatCurrency(asset.salvageValue)),
            _buildInfoItem('Depreciable Amount',
                _formatCurrency(asset.acquisitionCost - asset.salvageValue)),
          ]),

          const SizedBox(height: 20),

          // Quick Actions
          if (asset.status == AssetStatus.active && asset.isDepreciable) ...[
            _buildSectionTitle('Quick Actions'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _calculateDepreciation(asset),
                    icon: const Icon(Icons.calculate, size: 18),
                    label: const Text('Calculate Depreciation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _postDepreciation(asset),
                    icon: const Icon(Icons.post_add, size: 18),
                    label: const Text('Post Depreciation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (asset.status == AssetStatus.active ||
              asset.status == AssetStatus.idle) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _disposeAsset(asset),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Dispose Asset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDepreciationTab(FixedAsset asset, FixedAssetsState state) {
    final schedule = state.depreciationSchedule;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!asset.isDepreciable) ...[
            const Center(
              child: Column(
                children: [
                  Icon(Icons.trending_flat, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'This asset is not depreciable',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Depreciation method is set to "No Depreciation"',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            // Depreciation Summary
            _buildSectionTitle('Depreciation Schedule'),
            const SizedBox(height: 12),

            if (schedule == null && state.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (schedule == null)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Failed to load depreciation schedule'),
                  ],
                ),
              )
            else
              _buildDepreciationSchedule(schedule),

            const SizedBox(height: 20),

            // Annual Depreciation Calculation
            _buildSectionTitle('Annual Depreciation'),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDepreciationCalculation(
                      'Annual Depreciation',
                      _calculateAnnualDepreciation(asset),
                    ),
                    const SizedBox(height: 12),
                    _buildDepreciationCalculation(
                      'Monthly Depreciation',
                      _calculateAnnualDepreciation(asset) / 12,
                    ),
                    const SizedBox(height: 12),
                    _buildDepreciationCalculation(
                      'Daily Depreciation',
                      _calculateAnnualDepreciation(asset) / 365,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMaintenanceTab(FixedAsset asset) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Maintenance History
          _buildSectionTitle('Maintenance History'),
          const SizedBox(height: 12),

          if (asset.lastMaintenanceDate == null)
            _buildEmptyState(
              Icons.build,
              'No Maintenance Records',
              'Maintenance history will appear here when maintenance is performed on this asset.',
            )
          else
            _buildInfoCard([
              _buildInfoItem(
                  'Last Maintenance', _formatDate(asset.lastMaintenanceDate!)),
              if (asset.nextMaintenanceDate != null)
                _buildInfoItem('Next Maintenance Due',
                    _formatDate(asset.nextMaintenanceDate!)),
            ]),

          const SizedBox(height: 20),

          // Schedule Maintenance
          _buildSectionTitle('Schedule Maintenance'),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Schedule maintenance for this asset to ensure optimal performance and longevity.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _scheduleMaintenance(asset),
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Schedule Maintenance'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Service Records
          _buildSectionTitle('Service Records'),
          const SizedBox(height: 12),
          _buildEmptyState(
            Icons.assignment,
            'No Service Records',
            'Service and repair records will appear here when services are performed.',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0D47A1),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialMetric(String label, double value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          _formatCurrency(value),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0D47A1),
          ),
        ),
      ],
    );
  }

  Widget _buildDepreciationCalculation(String label, double value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          _formatCurrency(value),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildDepreciationSchedule(DepreciationSchedule schedule) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Schedule Header
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Year',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Depreciation',
                    style: TextStyle(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Accumulated',
                    style: TextStyle(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Book Value',
                    style: TextStyle(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            // Schedule Rows
            ...schedule.schedule.take(10).map((period) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Year ${period['year']}'),
                  ),
                  Expanded(
                    child: Text(
                      _formatCurrency(period['depreciationAmount']),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _formatCurrency(period['accumulatedDepreciation']),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _formatCurrency(period['bookValue']),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: period['bookValue'] <=
                            (schedule.asset['salvageValue'] as num)
                                .toDouble()
                            ? Colors.green
                            : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            if (schedule.schedule.length > 10) ...[
              const Divider(height: 1),
              const SizedBox(height: 8),
              Text(
                '... and ${schedule.schedule.length - 10} more years',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String description) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return 'KES ${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDepreciationMethodName(DepreciationMethod method) {
    switch (method) {
      case DepreciationMethod.straight_line:
        return 'Straight Line';
      case DepreciationMethod.declining_balance:
        return 'Declining Balance';
      case DepreciationMethod.units_of_production:
        return 'Units of Production';
      case DepreciationMethod.none:
        return 'No Depreciation';
    }
  }

  double _calculateAnnualDepreciation(FixedAsset asset) {
    if (!asset.isDepreciable) return 0;

    switch (asset.depreciationMethod) {
      case DepreciationMethod.straight_line:
        return (asset.acquisitionCost - asset.salvageValue) / asset.usefulLife;
      case DepreciationMethod.declining_balance:
        final rate = 2 / asset.usefulLife; // Double declining balance
        return asset.currentBookValue * rate;
      case DepreciationMethod.units_of_production:
        return (asset.acquisitionCost - asset.salvageValue) / asset.usefulLife;
      case DepreciationMethod.none:
        return 0;
    }
  }

  void _calculateDepreciation(FixedAsset asset) async {
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
              const SizedBox(height: 12),
              _buildInfoItem('Depreciation Amount',
                  _formatCurrency(result.depreciationAmount)),
              _buildInfoItem(
                  'New Book Value', _formatCurrency(result.newBookValue)),
              _buildInfoItem('Accumulated Depreciation',
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
                _postDepreciation(asset);
              },
              child: const Text('Post Depreciation'),
            ),
          ],
        ),
      );
    }
  }

  void _postDepreciation(FixedAsset asset) async {
    final success =
    await ref.read(fixedAssetsProvider.notifier).postDepreciation(asset.id);
    if (success && context.mounted) {
      // Refresh asset data
      ref.read(fixedAssetsProvider.notifier).fetchAssetById(asset.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Depreciation posted for ${asset.assetName}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _disposeAsset(FixedAsset asset) {
    showDialog(
      context: context,
      builder: (context) => AssetDisposalDialog(asset: asset),
    );
  }

  void _scheduleMaintenance(FixedAsset asset) {
    // Implementation for scheduling maintenance
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Maintenance'),
        content: const Text('Maintenance scheduling feature coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Reuse the AssetDisposalDialog from earlier
class AssetDisposalDialog extends ConsumerStatefulWidget {
  final FixedAsset asset;

  const AssetDisposalDialog({super.key, required this.asset});

  @override
  ConsumerState<AssetDisposalDialog> createState() =>
      _AssetDisposalDialogState();
}

class _AssetDisposalDialogState extends ConsumerState<AssetDisposalDialog> {
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
        Navigator.pop(context); // Close disposal dialog
        Navigator.pop(context); // Close details sheet
      }
    }
  }

  @override
  void dispose() {
    _disposalAmountController.dispose();
    super.dispose();
  }
}