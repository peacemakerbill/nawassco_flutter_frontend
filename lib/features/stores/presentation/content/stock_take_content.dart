import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../public/auth/providers/auth_provider.dart';
import '../../providers/stock_take_provider.dart';
import 'sub_widgets/stock/create_stock_take_dialog.dart';
import 'sub_widgets/stock/stock_take_performance_tab.dart';
import 'sub_widgets/stock/stock_takes_tab.dart';


class StockTakeContent extends ConsumerStatefulWidget {
  const StockTakeContent({super.key});

  @override
  ConsumerState<StockTakeContent> createState() => _StockTakeContentState();
}

class _StockTakeContentState extends ConsumerState<StockTakeContent>
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
      ref.read(stockTakeProvider.notifier).getStockTakes();
      ref.read(stockTakeProvider.notifier).getStockTakePerformance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stockTakeState = ref.watch(stockTakeProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Stock Take Management',
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
              onPressed: () => _showCreateStockTakeDialog(context),
              tooltip: 'Create Stock Take',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Stats Overview Cards
          _buildStatsOverview(stockTakeState),

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
                Tab(text: 'Stock Takes'),
                Tab(text: 'Performance'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                StockTakesTab(),
                StockTakePerformanceTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(StockTakeState stockTakeState) {
    final totalStockTakes = stockTakeState.stockTakes.length;
    final inProgressTakes = stockTakeState.stockTakes.where((st) => st.status == 'in_progress').length;
    final completedTakes = stockTakeState.stockTakes.where((st) => st.status == 'completed').length;
    final totalVariance = stockTakeState.stockTakes.fold(0.0, (sum, st) => sum + st.totalVarianceValue);

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
                hintText: 'Search stock takes by number...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.grey),
                  onPressed: () => _showFilterDialog(context),
                ),
              ),
              onChanged: (value) {
                ref.read(stockTakeProvider.notifier).getStockTakes(search: value);
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
                'Total Stock Takes',
                totalStockTakes.toString(),
                Icons.inventory,
                Colors.blue,
              ),
              _buildStatCard(
                'In Progress',
                inProgressTakes.toString(),
                Icons.timer,
                Colors.orange,
              ),
              _buildStatCard(
                'Completed',
                completedTakes.toString(),
                Icons.check_circle,
                Colors.green,
              ),
              _buildStatCard(
                'Total Variance',
                'KES ${totalVariance.toStringAsFixed(2)}',
                Icons.trending_up,
                totalVariance >= 0 ? Colors.red : Colors.green,
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
                if (title == 'In Progress')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Active',
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color == Colors.red || color == Colors.green ? color : Colors.black87,
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

  void _showCreateStockTakeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateStockTakeDialog(
        onStockTakeCreated: () {
          _loadInitialData();
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const StockTakeFilterDialog(),
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
class StockTakeFilterDialog extends ConsumerWidget {
  const StockTakeFilterDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Filter Stock Takes'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            // Add filter options here
            const Text('Stock take filter options will be implemented here'),
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