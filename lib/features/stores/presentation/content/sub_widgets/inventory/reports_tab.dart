// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../../providers/inventory_item_provider.dart';
//
// class ReportsTab extends ConsumerStatefulWidget {
//   const ReportsTab({super.key});
//
//   @override
//   ConsumerState<ReportsTab> createState() => _ReportsTabState();
// }
//
// class _ReportsTabState extends ConsumerState<ReportsTab> {
//   final List<Map<String, dynamic>> _reportCards = [
//     {
//       'title': 'Inventory Valuation',
//       'description': 'Total value of inventory by category and location',
//       'icon': Icons.attach_money,
//       'color': Colors.green,
//     },
//     {
//       'title': 'Stock Movement',
//       'description': 'Fast and slow moving items analysis',
//       'icon': Icons.trending_up,
//       'color': Colors.blue,
//     },
//     {
//       'title': 'Low Stock Report',
//       'description': 'Items below reorder point',
//       'icon': Icons.warning,
//       'color': Colors.orange,
//     },
//     {
//       'title': 'Category Analysis',
//       'description': 'Inventory distribution by category',
//       'icon': Icons.pie_chart,
//       'color': Colors.purple,
//     },
//     {
//       'title': 'Stock Aging',
//       'description': 'Items with no movement',
//       'icon': Icons.schedule,
//       'color': Colors.red,
//     },
//     {
//       'title': 'Supplier Performance',
//       'description': 'Lead times and delivery reliability',
//       'icon': Icons.local_shipping,
//       'color': Colors.teal,
//     },
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadReportsData();
//   }
//
//   void _loadReportsData() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(inventoryItemProvider.notifier).getInventoryValuation();
//       ref.read(inventoryItemProvider.notifier).getLowStockItems();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final inventoryState = ref.watch(inventoryItemProvider);
//
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Quick Stats
//           _buildQuickStats(inventoryState),
//
//           const SizedBox(height: 20),
//
//           // Reports Grid
//           Expanded(
//             child: GridView.builder(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 childAspectRatio: 1.2,
//               ),
//               itemCount: _reportCards.length,
//               itemBuilder: (context, index) => _buildReportCard(_reportCards[index]),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildQuickStats(InventoryItemState state) {
//     final totalValue = state.items.fold(0.0, (sum, item) => sum + item.stockValue);
//     final lowStockCount = state.items.where((item) => item.isLowStock).length;
//     final outOfStockCount = state.items.where((item) => item.isOutOfStock).length;
//     final totalItems = state.items.length;
//
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             const Text(
//               'Inventory Overview',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 16),
//             GridView.count(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               crossAxisCount: 4,
//               crossAxisSpacing: 16,
//               childAspectRatio: 2.5,
//               children: [
//                 _buildQuickStatItem('Total Items', totalItems.toString(), Icons.inventory_2, Colors.blue),
//                 _buildQuickStatItem('Total Value', 'KES ${totalValue.toStringAsFixed(0)}', Icons.attach_money, Colors.green),
//                 _buildQuickStatItem('Low Stock', lowStockCount.toString(), Icons.warning, Colors.orange),
//                 _buildQuickStatItem('Out of Stock', outOfStockCount.toString(), Icons.error, Colors.red),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildQuickStatItem(String title, String value, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: color.withOpacity(0.2)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.2),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, size: 16, color: color),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w700,
//                     color: color,
//                   ),
//                 ),
//                 Text(
//                   title,
//                   style: const TextStyle(fontSize: 10, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildReportCard(Map<String, dynamic> card) {
//     return Card(
//       elevation: 2,
//       child: InkWell(
//         onTap: () => _showReportDetails(card['title']),
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: card['color'].withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(card['icon'], color: card['color'], size: 24),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 card['title'],
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Expanded(
//                 child: Text(
//                   card['description'],
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: card['color'].withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Text(
//                   'View Report',
//                   style: TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w600,
//                     color: card['color'],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showReportDetails(String reportType) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.8,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: ReportDetailsSheet(reportType: reportType),
//       ),
//     );
//   }
// }
//
// class ReportDetailsSheet extends ConsumerWidget {
//   final String reportType;
//
//   const ReportDetailsSheet({super.key, required this.reportType});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final inventoryState = ref.watch(inventoryItemProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(reportType),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.download),
//             onPressed: () => _exportReport(),
//           ),
//           IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: _buildReportContent(inventoryState),
//       ),
//     );
//   }
//
//   Widget _buildReportContent(InventoryItemState state) {
//     switch (reportType) {
//       case 'Inventory Valuation':
//         return _buildValuationReport(state);
//       case 'Low Stock Report':
//         return _buildLowStockReport(state);
//       case 'Stock Movement':
//         return _buildMovementReport(state);
//       case 'Category Analysis':
//         return _buildCategoryAnalysis(state);
//       default:
//         return const Center(child: Text('Report content will be displayed here'));
//     }
//   }
//
//   Widget _buildValuationReport(InventoryItemState state) {
//     final valuationByCategory = <String, double>{};
//
//     for (final item in state.items) {
//       final category = item.category;
//       final value = item.stockValue;
//       valuationByCategory[category] = (valuationByCategory[category] ?? 0) + value;
//     }
//
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Inventory Valuation by Category',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 16),
//           ...valuationByCategory.entries.map((entry) => Card(
//             child: ListTile(
//               leading: const Icon(Icons.category, color: Colors.blue),
//               title: Text(entry.key.replaceAll('_', ' ').titleCase),
//               trailing: Text(
//                 'KES ${entry.value.toStringAsFixed(0)}',
//                 style: const TextStyle(fontWeight: FontWeight.w600),
//               ),
//             ),
//           )),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLowStockReport(InventoryItemState state) {
//     final lowStockItems = state.items.where((item) => item.isLowStock).toList();
//
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Low Stock Items (${lowStockItems.length})',
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 16),
//           if (lowStockItems.isEmpty)
//             const Center(child: Text('No low stock items found')),
//           ...lowStockItems.map((item) => Card(
//             child: ListTile(
//               leading: Icon(
//                 item.isCriticalStock ? Icons.error : Icons.warning,
//                 color: item.isCriticalStock ? Colors.red : Colors.orange,
//               ),
//               title: Text(item.itemName),
//               subtitle: Text('Current: ${item.currentStock} | Min: ${item.minimumStock}'),
//               trailing: Text('Reorder: ${item.reorderQuantity}'),
//             ),
//           )),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMovementReport(InventoryItemState state) {
//     final movementStats = <String, int>{};
//
//     for (final item in state.items) {
//       final movementClass = item.movementClass;
//       movementStats[movementClass] = (movementStats[movementClass] ?? 0) + 1;
//     }
//
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Stock Movement Analysis',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 16),
//           ...movementStats.entries.map((entry) => Card(
//             child: ListTile(
//               leading: _getMovementIcon(entry.key),
//               title: Text(entry.key.replaceAll('_', ' ').titleCase),
//               trailing: Text('${entry.value} items'),
//             ),
//           )),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCategoryAnalysis(InventoryItemState state) {
//     final categoryStats = <String, int>{};
//
//     for (final item in state.items) {
//       final category = item.category;
//       categoryStats[category] = (categoryStats[category] ?? 0) + 1;
//     }
//
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Inventory by Category',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 16),
//           ...categoryStats.entries.map((entry) => Card(
//             child: ListTile(
//               leading: const Icon(Icons.category, color: Colors.green),
//               title: Text(entry.key.replaceAll('_', ' ').titleCase),
//               trailing: Text('${entry.value} items'),
//             ),
//           )),
//         ],
//       ),
//     );
//   }
//
//   Icon _getMovementIcon(String movementClass) {
//     switch (movementClass) {
//       case 'fast_moving':
//         return const Icon(Icons.fast_forward, color: Colors.green);
//       case 'slow_moving':
//         return const Icon(Icons.slow_motion_video, color: Colors.blue);
//       case 'non_moving':
//         return const Icon(Icons.pause, color: Colors.grey);
//       case 'seasonal':
//         return const Icon(Icons.sunny_snowing, color: Colors.orange);
//       default:
//         return const Icon(Icons.trending_flat, color: Colors.grey);
//     }
//   }
//
//   void _exportReport() {
//     // Implement export functionality
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Report exported successfully')),
//     );
//   }
// }