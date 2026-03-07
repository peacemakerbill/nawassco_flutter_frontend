import 'package:flutter/material.dart';
import '../../../../models/store_manager_model.dart';

class InventoryAuthoritySection extends StatelessWidget {
  final StoreManager storeManager;

  const InventoryAuthoritySection({super.key, required this.storeManager});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // Inventory Authority Card
          _buildInventoryAuthorityCard(),
          const SizedBox(height: 16),

          // Approval Limits Card
          _buildApprovalLimitsCard(),
          const SizedBox(height: 16),

          // System Access Card
          _buildSystemAccessCard(),
          const SizedBox(height: 16),

          // Stock Control Authority Card
          _buildStockControlAuthorityCard(),
          const SizedBox(height: 16),

          // Procurement Authority Card
          _buildProcurementAuthorityCard(),
          const SizedBox(height: 16),

          // Stock Take Responsibilities Card
          _buildStockTakeResponsibilitiesCard(),
        ],
      ),
    );
  }

  Widget _buildInventoryAuthorityCard() {
    final authority = storeManager.inventoryAuthority;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Inventory Management Authority', Icons.inventory),
            const SizedBox(height: 16),

            _buildAuthorityRow('Inventory Management', authority.inventoryManagement,
                'Full authority over inventory management operations'),
            _buildAuthorityRow('Stock Adjustments Limit',
                'KES ${authority.stockAdjustments.toStringAsFixed(2)}',
                'Maximum value for stock adjustments per transaction'),
            _buildAuthorityRow('Write-off Authority',
                'KES ${authority.writeOffAuthority.toStringAsFixed(2)}',
                'Maximum value for inventory write-offs'),
            _buildAuthorityRow('Stock Transfer', authority.stockTransfer,
                'Authority to transfer stock between locations'),
            _buildAuthorityRow('Quality Hold', authority.qualityHold,
                'Authority to place items on quality hold'),
            _buildAuthorityRow('Disposal Authority', authority.disposalAuthority,
                'Authority to dispose of obsolete or damaged inventory'),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalLimitsCard() {
    final limits = storeManager.approvalLimits;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Financial Approval Limits', Icons.approval),
            const SizedBox(height: 16),

            _buildApprovalRow('Purchase Requisitions', limits.purchaseRequisitions,
                'Maximum value for purchase requisition approval'),
            _buildApprovalRow('Purchase Orders', limits.purchaseOrders,
                'Maximum value for purchase order approval'),
            _buildApprovalRow('Stock Issues', limits.stockIssues,
                'Maximum value for stock issue approval'),
            _buildApprovalRow('Stock Returns', limits.stockReturns,
                'Maximum value for stock return approval'),
            _buildApprovalRow('Inventory Adjustments', limits.inventoryAdjustments,
                'Maximum value for inventory adjustment approval'),
            _buildApprovalRow('Emergency Procurement', limits.emergencyProcurement,
                'Maximum value for emergency procurement approval'),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemAccessCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('System Access & Permissions', Icons.computer),
            const SizedBox(height: 16),

            if (storeManager.systemAccess.isEmpty)
              const Center(
                child: Text(
                  'No system access configured',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...storeManager.systemAccess.map((access) =>
                  _buildSystemAccessItem(access),
              ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStockControlAuthorityCard() {
    final authority = storeManager.stockControlAuthority;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Stock Control Authority', Icons.warehouse),
            const SizedBox(height: 16),

            _buildAuthorityRow('Stock Level Management', authority.stockLevelManagement,
                'Authority to set and manage stock levels'),
            _buildAuthorityRow('Reorder Point Setting', authority.reorderPointSetting,
                'Authority to set reorder points for inventory items'),
            _buildAuthorityRow('Safety Stock Setting', authority.safetyStockSetting,
                'Authority to set safety stock levels'),
            _buildAuthorityRow('Obsolescence Management', authority.obsolescenceManagement,
                'Authority to manage obsolete inventory'),
            _buildAuthorityRow('Cycle Counting', authority.cycleCounting,
                'Authority to conduct cycle counts'),

            // Inventory Accuracy Targets
            const SizedBox(height: 16),
            const Text(
              'Inventory Accuracy Targets:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (storeManager.inventoryAccuracyTargets.isEmpty)
              const Text(
                'No accuracy targets set',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              )
            else
              ...storeManager.inventoryAccuracyTargets.map((target) =>
                  _buildAccuracyTargetItem(target),
              ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProcurementAuthorityCard() {
    final authority = storeManager.procurementAuthority;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Procurement Authority', Icons.shopping_cart),
            const SizedBox(height: 16),

            _buildAuthorityRow('Can Approve Purchase Requisitions', authority.canApprovePR,
                'Authority to approve purchase requisitions'),
            _buildAuthorityRow('PR Value Limit',
                'KES ${authority.prValueLimit.toStringAsFixed(2)}',
                'Maximum value for PR approval'),
            _buildAuthorityRow('Can Approve Purchase Orders', authority.canApprovePO,
                'Authority to approve purchase orders'),
            _buildAuthorityRow('PO Value Limit',
                'KES ${authority.poValueLimit.toStringAsFixed(2)}',
                'Maximum value for PO approval'),
            _buildAuthorityRow('Can Select Suppliers', authority.canSelectSuppliers,
                'Authority to select and approve suppliers'),
            _buildAuthorityRow('Negotiation Authority',
                'KES ${authority.negotiationAuthority.toStringAsFixed(2)}',
                'Authority to negotiate with suppliers'),
          ],
        ),
      ),
    );
  }

  Widget _buildStockTakeResponsibilitiesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Stock Take Responsibilities', Icons.checklist),
            const SizedBox(height: 16),

            if (storeManager.stockTakeResponsibilities.isEmpty)
              const Center(
                child: Text(
                  'No stock take responsibilities defined',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...storeManager.stockTakeResponsibilities.map((responsibility) =>
                  _buildStockTakeItem(responsibility),
              ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemAccessItem(StoreSystemAccess access) {
    final daysUntilReview = access.reviewDate.difference(DateTime.now()).inDays;
    Color reviewColor = daysUntilReview <= 30 ? Colors.orange : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.system_security_update, size: 20, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                access.system.name.replaceAll('_', ' '),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Access Details
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSystemDetailRow('Access Level', access.accessLevel.name),
                    _buildSystemDetailRow('Granted Date',
                        access.grantedDate.toIso8601String().split('T')[0]),
                    _buildSystemDetailRow('Review Date',
                        access.reviewDate.toIso8601String().split('T')[0]),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Chip(
                    label: Text(
                      access.accessLevel.name,
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: _getAccessLevelColor(access.accessLevel),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$daysUntilReview days',
                    style: TextStyle(
                      fontSize: 10,
                      color: reviewColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'until review',
                    style: TextStyle(
                      fontSize: 8,
                      color: reviewColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Permissions
          if (access.permissions.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Permissions:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: access.permissions.map((permission) =>
                  Chip(
                    label: Text(
                      permission,
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: Colors.green[50],
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccuracyTargetItem(InventoryAccuracyTarget target) {
    final variance = target.currentAccuracy - target.targetAccuracy;
    Color varianceColor = variance >= 0 ? Colors.green : Colors.red;
    IconData varianceIcon = variance >= 0 ? Icons.trending_up : Icons.trending_down;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  target.warehouse,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: target.currentAccuracy / 100,
                        backgroundColor: Colors.grey[300],
                        color: target.currentAccuracy >= target.targetAccuracy
                            ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${target.currentAccuracy.toStringAsFixed(1)}%'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(varianceIcon, size: 16, color: varianceColor),
                  const SizedBox(width: 4),
                  Text(
                    '${variance >= 0 ? '+' : ''}${variance.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: varianceColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Target: ${target.targetAccuracy}%',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockTakeItem(StockTakeResponsibility responsibility) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  responsibility.responsibility,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Chip(
                      label: Text(responsibility.type),
                      backgroundColor: Colors.blue[50],
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(responsibility.frequency),
                      backgroundColor: Colors.green[50],
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${responsibility.performance.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: responsibility.performance >= 80 ? Colors.green :
                  responsibility.performance >= 60 ? Colors.orange : Colors.red,
                ),
              ),
              const SizedBox(height: 2),
              LinearProgressIndicator(
                value: responsibility.performance / 100,
                backgroundColor: Colors.grey[200],
                color: responsibility.performance >= 80 ? Colors.green :
                responsibility.performance >= 60 ? Colors.orange : Colors.red,
                minHeight: 4,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700]),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorityRow(String label, dynamic value, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: value is bool
                    ? Row(
                  children: [
                    Icon(
                      value ? Icons.check_circle : Icons.cancel,
                      color: value ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(value ? 'Yes' : 'No'),
                  ],
                )
                    : Text(
                  value.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 0, top: 4),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalRow(String label, double amount, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'KES ${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 0, top: 4),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAccessLevelColor(StoreAccessLevel level) {
    switch (level) {
      case StoreAccessLevel.ADMIN:
        return Colors.red[50]!;
      case StoreAccessLevel.SUPERVISOR:
        return Colors.orange[50]!;
      case StoreAccessLevel.OPERATOR:
        return Colors.blue[50]!;
      case StoreAccessLevel.VIEW:
        return Colors.green[50]!;
      default:
        return Colors.grey[50]!;
    }
  }
}