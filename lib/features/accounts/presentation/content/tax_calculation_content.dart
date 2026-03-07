import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/tax_calculation_provider.dart';
import 'sub_widgets/tax_calculation/tax_calculation_form.dart';
import 'sub_widgets/tax_calculation/tax_calculation_list.dart';
import 'sub_widgets/tax_calculation/tax_summary_widget.dart';

class TaxCalculationContent extends StatefulWidget {
  const TaxCalculationContent({super.key});

  @override
  State<TaxCalculationContent> createState() => _TaxCalculationContentState();
}

class _TaxCalculationContentState extends State<TaxCalculationContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Column(
          children: [
            // Header with Tabs
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.calculate,
                            color: Color(0xFF0D47A1), size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Tax Management',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        const Spacer(),
                        // Refresh button
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            final currentIndex = _tabController.index;
                            if (currentIndex == 0) {
                              ref
                                  .read(taxCalculationProvider.notifier)
                                  .getTaxCalculations();
                            } else if (currentIndex == 2) {
                              ref
                                  .read(taxCalculationProvider.notifier)
                                  .getTaxSummary();
                            }
                          },
                          tooltip: 'Refresh',
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
                      Tab(text: 'Calculations'),
                      Tab(text: 'Create New'),
                      Tab(text: 'Tax Summary'),
                    ],
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  TaxCalculationListWidget(),
                  TaxCalculationFormWidget(),
                  TaxSummaryWidget(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}