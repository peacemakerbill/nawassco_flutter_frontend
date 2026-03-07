import 'package:flutter/material.dart';

class TransactionRow extends StatelessWidget {
  final String type;
  final String itemCode;
  final String itemName;
  final int quantity;
  final String reference;
  final DateTime date;
  final String performedBy;
  final double totalValue;

  const TransactionRow({
    super.key,
    required this.type,
    required this.itemCode,
    required this.itemName,
    required this.quantity,
    required this.reference,
    required this.date,
    required this.performedBy,
    required this.totalValue,
  });

  @override
  Widget build(BuildContext context) {
    Color getTypeColor() {
      switch (type.toLowerCase()) {
        case 'receive':
          return Colors.green;
        case 'issue':
          return Colors.blue;
        case 'adjustment':
          return Colors.orange;
        case 'return':
          return Colors.purple;
        default:
          return Colors.grey;
      }
    }

    IconData getTypeIcon() {
      switch (type.toLowerCase()) {
        case 'receive':
          return Icons.inventory_2;
        case 'issue':
          return Icons.exit_to_app;
        case 'adjustment':
          return Icons.adjust;
        case 'return':
          return Icons.assignment_return;
        default:
          return Icons.swap_horiz;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: getTypeColor().withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              getTypeIcon(),
              color: getTypeColor(),
              size: 20,
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
                        itemName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: getTypeColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        type.toUpperCase(),
                        style: TextStyle(
                          color: getTypeColor(),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  itemCode,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Qty: $quantity • Ref: $reference',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'KES ${totalValue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'By: $performedBy',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}