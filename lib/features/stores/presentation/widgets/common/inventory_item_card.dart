import 'package:flutter/material.dart';

class InventoryItemCard extends StatelessWidget {
  final String code;
  final String name;
  final String category;
  final int quantity;
  final int minStock;
  final int maxStock;
  final double unitCost;
  final String status;
  final VoidCallback? onTap;

  const InventoryItemCard({
    super.key,
    required this.code,
    required this.name,
    required this.category,
    required this.quantity,
    required this.minStock,
    required this.maxStock,
    required this.unitCost,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = quantity <= minStock;
    final isOverstocked = quantity > maxStock;
    final totalValue = unitCost * quantity;

    Color getStatusColor() {
      if (isLowStock) return Colors.red;
      if (isOverstocked) return Colors.orange;
      return Colors.green;
    }

    String getStatusText() {
      if (isLowStock) return 'Low Stock';
      if (isOverstocked) return 'Overstocked';
      return 'In Stock';
    }

    IconData getStatusIcon() {
      if (isLowStock) return Icons.warning;
      if (isOverstocked) return Icons.inventory_2;
      return Icons.check_circle;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: getStatusColor().withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  getStatusIcon(),
                  color: getStatusColor(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: getStatusColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            getStatusText(),
                            style: TextStyle(
                              color: getStatusColor(),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      code,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quantity: $quantity',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Min: $minStock | Max: $maxStock',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'KES ${unitCost.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Total: KES ${totalValue.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}