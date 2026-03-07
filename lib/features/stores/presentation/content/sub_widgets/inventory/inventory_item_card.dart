import 'package:flutter/material.dart';
import '../../../../models/inventory/inventory_item_model.dart';

class InventoryItemCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const InventoryItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: _getStatusBorder(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Status Indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Item Code and Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.itemCode,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          item.itemName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Actions Menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Details Row
              Row(
                children: [
                  // Category
                  _buildDetailChip(
                    icon: Icons.category,
                    text: item.category.replaceAll('_', ' ').titleCase,
                  ),

                  const SizedBox(width: 8),

                  // Item Type
                  _buildDetailChip(
                    icon: Icons.label,
                    text: item.itemType.replaceAll('_', ' ').titleCase,
                  ),

                  const Spacer(),

                  // Movement Class
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getMovementClassColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.movementClass.replaceAll('_', ' ').titleCase,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getMovementClassColor(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Stock Information
              Row(
                children: [
                  // Current Stock
                  Expanded(
                    child: _buildStockInfo(
                      'Current Stock',
                      '${item.currentStock} ${item.unitOfMeasure}',
                      _getStockLevelColor(item.currentStock, item.minimumStock, item.maximumStock),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Min/Max Stock
                  Expanded(
                    child: _buildStockInfo(
                      'Min/Max',
                      '${item.minimumStock}/${item.maximumStock}',
                      Colors.grey,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Stock Value
                  Expanded(
                    child: _buildStockInfo(
                      'Value',
                      'KES ${item.stockValue.toStringAsFixed(0)}',
                      Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Stock Progress Bar
              LinearProgressIndicator(
                value: _getStockPercentage(item.currentStock, item.maximumStock),
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(_getStockLevelColor(
                  item.currentStock, item.minimumStock, item.maximumStock,
                )),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),

              const SizedBox(height: 4),

              // Stock Status Text
              Text(
                _getStockStatusText(item),
                style: TextStyle(
                  fontSize: 11,
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStockInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    if (item.isOutOfStock) return Colors.red;
    if (item.isCriticalStock) return Colors.orange;
    if (item.isLowStock) return Colors.yellow[700]!;
    return Colors.green;
  }

  Border? _getStatusBorder() {
    final color = _getStatusColor();
    if (item.isLowStock) {
      return Border.all(color: color.withOpacity(0.3), width: 1);
    }
    return null;
  }

  Color _getMovementClassColor() {
    switch (item.movementClass) {
      case 'fast_moving':
        return Colors.green;
      case 'slow_moving':
        return Colors.blue;
      case 'non_moving':
        return Colors.grey;
      case 'seasonal':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getStockLevelColor(double current, double min, double max) {
    final percentage = current / max;
    if (current <= min) return Colors.red;
    if (percentage < 0.3) return Colors.orange;
    if (percentage < 0.7) return Colors.yellow[700]!;
    return Colors.green;
  }

  double _getStockPercentage(double current, double max) {
    return max > 0 ? current / max : 0;
  }

  String _getStockStatusText(InventoryItem item) {
    if (item.isOutOfStock) return 'OUT OF STOCK';
    if (item.isCriticalStock) return 'CRITICAL STOCK';
    if (item.isLowStock) return 'LOW STOCK - REORDER NEEDED';
    if (item.currentStock > item.maximumStock * 0.9) return 'HIGH STOCK';
    return 'IN STOCK';
  }
}

// Extension for string capitalization
extension StringExtension on String {
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}