import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../public/auth/providers/auth_provider.dart';
import '../../providers/stock_movement_provider.dart';
import 'sub_widgets/stock/create_movement_dialog.dart';
import 'sub_widgets/stock/movement_summary_tab.dart';
import 'sub_widgets/stock/stock_movements_tab.dart';


class StockMovementContent extends ConsumerStatefulWidget {
  const StockMovementContent({super.key});

  @override
  ConsumerState<StockMovementContent> createState() => _StockMovementContentState();
}

class _StockMovementContentState extends ConsumerState<StockMovementContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stockMovementProvider.notifier).getStockMovements();
      ref.read(stockMovementProvider.notifier).getMovementSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final movementState = ref.watch(stockMovementProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Stock Movements',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
            tooltip: 'Refresh Data',
          ),
          if (authState.isAdmin || authState.isStoreManager)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateMovementDialog(context),
              tooltip: 'Create Movement',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Stats Overview Cards
          _buildStatsOverview(movementState),

          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF1E3A8A),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF1E3A8A),
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'All Movements'),
                Tab(text: 'Summary & Reports'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                StockMovementsTab(),
                MovementSummaryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(StockMovementState movementState) {
    final totalMovements = movementState.movements.length;
    final pendingMovements = movementState.movements.where((m) => m.status == 'pending').length;
    final completedMovements = movementState.movements.where((m) => m.status == 'completed').length;
    final totalValue = movementState.movements.fold(0.0, (sum, movement) => sum + movement.totalValue);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search movements by number or reference...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.grey),
                  onPressed: () => _showFilterDialog(context),
                ),
              ),
              onChanged: (value) {
                ref.read(stockMovementProvider.notifier).getStockMovements(search: value);
              },
            ),
          ),

          // Stats Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: [
              _buildStatCard(
                'Total Movements',
                totalMovements.toString(),
                Icons.move_to_inbox,
                Colors.blue,
              ),
              _buildStatCard(
                'Pending',
                pendingMovements.toString(),
                Icons.pending_actions,
                Colors.orange,
              ),
              _buildStatCard(
                'Completed',
                completedMovements.toString(),
                Icons.check_circle,
                Colors.green,
              ),
              _buildStatCard(
                'Total Value',
                'KES ${totalValue.toStringAsFixed(2)}',
                Icons.attach_money,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                if (title == 'Pending')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Action Needed',
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateMovementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateMovementDialog(
        onMovementCreated: () {
          _loadInitialData();
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const MovementFilterDialog(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

// Filter Dialog Widget
class MovementFilterDialog extends ConsumerWidget {
  const MovementFilterDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Filter Movements'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            // Add filter options here
            const Text('Movement filter options will be implemented here'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Apply filters
            Navigator.pop(context);
          },
          child: const Text('Apply Filters'),
        ),
      ],
    );
  }
}