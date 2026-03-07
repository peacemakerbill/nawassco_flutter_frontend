import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/consultancy_model.dart';
import '../../../../providers/consultancy_provider.dart';
import '../../../sub_widgets/consultancy/consultancy_application_form.dart';
import '../../../sub_widgets/consultancy/consultancy_card.dart';
import '../../../sub_widgets/consultancy/consultancy_detail_view.dart';

class ConsultancyApplicationContent extends ConsumerStatefulWidget {
  const ConsultancyApplicationContent({super.key});

  @override
  ConsumerState<ConsultancyApplicationContent> createState() => _ConsultancyApplicationContentState();
}

class _ConsultancyApplicationContentState extends ConsumerState<ConsultancyApplicationContent> {
  final _searchController = TextEditingController();
  ViewMode _viewMode = ViewMode.list;
  ConsultancyStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(consultancyProvider.notifier).fetchConsultancies();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearch(String query) {
    ref.read(consultancyProvider.notifier).setSearchQuery(query);
  }

  void _applyFilter(ConsultancyStatus? status) {
    setState(() {
      _selectedFilter = status;
    });
    ref.read(consultancyProvider.notifier).setFilterStatus(status);
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _selectedFilter = null;
    });
    ref.read(consultancyProvider.notifier).clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final consultancyState = ref.watch(consultancyProvider);
    final consultancies = consultancyState.filteredConsultancies;
    final selectedConsultancy = consultancyState.selectedConsultancy;

    if (selectedConsultancy != null) {
      return ConsultancyDetailView(consultancy: selectedConsultancy);
    }

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  Theme.of(context).primaryColor.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.business_center,
                      color: Theme.of(context).primaryColor,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Consultancy Services',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Apply for professional consultancy services',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (authState.isAuthenticated)
                      ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => SizedBox(
                              height: MediaQuery.of(context).size.height * 0.9,
                              child: ConsultancyApplicationForm(
                                onSuccess: () {
                                  Navigator.pop(context);
                                  ref.read(consultancyProvider.notifier).fetchConsultancies();
                                },
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Apply Now'),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Search and filter bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search consultancies...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: _applySearch,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<ConsultancyStatus>(
                      icon: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.filter_list,
                              color: Theme.of(context).primaryColor,
                            ),
                            if (_selectedFilter != null) ...[
                              const SizedBox(width: 4),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: null,
                          child: Text('All Statuses'),
                        ),
                        ...ConsultancyStatus.values.map((status) {
                          return PopupMenuItem(
                            value: status,
                            child: Row(
                              children: [
                                Icon(
                                  status.statusIcon,
                                  color: status.statusColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(status.displayName),
                              ],
                            ),
                          );
                        }),
                      ],
                      onSelected: _applyFilter,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Clear filters',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stats bar
          if (consultancies.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[50],
              child: Row(
                children: [
                  Text(
                    '${consultancies.length} consultancy project${consultancies.length != 1 ? 's' : ''} found',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  // View mode toggle
                  ToggleButtons(
                    isSelected: [
                      _viewMode == ViewMode.list,
                      _viewMode == ViewMode.grid,
                    ],
                    onPressed: (index) {
                      setState(() {
                        _viewMode = index == 0 ? ViewMode.list : ViewMode.grid;
                      });
                    },
                    children: const [
                      Icon(Icons.list),
                      Icon(Icons.grid_view),
                    ],
                    borderRadius: BorderRadius.circular(8),
                    constraints: const BoxConstraints(
                      minHeight: 40,
                      minWidth: 40,
                    ),
                  ),
                ],
              ),
            ),

          // Main content
          Expanded(
            child: consultancies.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_center_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    consultancyState.isLoading
                        ? 'Loading consultancies...'
                        : 'No consultancies found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (!authState.isAuthenticated) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Please login to apply for consultancy',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            )
                : _viewMode == ViewMode.list
                ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: consultancies.length,
              itemBuilder: (context, index) {
                final consultancy = consultancies[index];
                return ConsultancyCard(
                  consultancy: consultancy,
                  onTap: () {
                    ref.read(consultancyProvider.notifier)
                        .selectConsultancy(consultancy);
                  },
                );
              },
            )
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: consultancies.length,
              itemBuilder: (context, index) {
                final consultancy = consultancies[index];
                return ConsultancyCard(
                  consultancy: consultancy,
                  onTap: () {
                    ref.read(consultancyProvider.notifier)
                        .selectConsultancy(consultancy);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum ViewMode { list, grid }