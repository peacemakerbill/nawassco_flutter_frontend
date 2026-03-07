import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/fixed_asset_provider.dart';
import 'sub_widgets/fixed_assets/fixed_asset_filters.dart';
import 'sub_widgets/fixed_assets/fixed_asset_form.dart';
import 'sub_widgets/fixed_assets/fixed_asset_list.dart';
import 'sub_widgets/fixed_assets/fixed_assets_summary.dart';

class FixedAssetsContent extends StatefulWidget {
  const FixedAssetsContent({super.key});

  @override
  State<FixedAssetsContent> createState() => _FixedAssetsContentState();
}

class _FixedAssetsContentState extends State<FixedAssetsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with Tabs
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
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.business_center,
                        color: Color(0xFF0D47A1), size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Fixed Assets Management',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    const Spacer(),
                    Consumer(
                      builder: (context, ref, child) {
                        final state = ref.watch(fixedAssetsProvider);
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: state.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () {
                                    ref
                                        .read(fixedAssetsProvider.notifier)
                                        .fetchAssets();
                                    ref
                                        .read(fixedAssetsProvider.notifier)
                                        .fetchAssetsSummary();
                                  },
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: const Color(0xFF0D47A1),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF0D47A1),
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Assets List'),
                  Tab(text: 'Summary Dashboard'),
                  Tab(text: 'Add New Asset'),
                ],
              ),
            ],
          ),
        ),
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              FixedAssetListTab(),
              FixedAssetsSummaryTab(),
              FixedAssetFormTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class FixedAssetListTab extends StatelessWidget {
  const FixedAssetListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        FixedAssetFilters(),
        Expanded(child: FixedAssetList()),
      ],
    );
  }
}

class FixedAssetsSummaryTab extends StatelessWidget {
  const FixedAssetsSummaryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const FixedAssetsSummaryWidget();
  }
}

class FixedAssetFormTab extends StatelessWidget {
  const FixedAssetFormTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: FixedAssetForm(),
      ),
    );
  }
}
