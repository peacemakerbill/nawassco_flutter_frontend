import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/tender_model.dart';
import '../../../providers/tender_provider.dart';
import '../sub_screens/tender/create_tender_screen.dart';
import '../sub_screens/tender/tender_detail_screen.dart';


class TenderListContent extends ConsumerStatefulWidget {
  const TenderListContent({super.key});

  @override
  ConsumerState<TenderListContent> createState() => _TenderListContentState();
}

class _TenderListContentState extends ConsumerState<TenderListContent> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tenderProvider.notifier).getTenders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tenderState = ref.watch(tenderProvider);
    final tenderNotifier = ref.read(tenderProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tender Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => tenderNotifier.getTenders(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateTenderScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchFilterSection(tenderNotifier),

          // Statistics Cards
          _buildStatisticsSection(tenderState),

          // Tender List
          Expanded(
            child: _buildTenderList(tenderState, tenderNotifier),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilterSection(TenderProvider tenderNotifier) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search tenders...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  tenderNotifier.getTenders();
                },
              ),
            ),
            onChanged: (value) {
              tenderNotifier.getTenders(queryParams: {'search': value});
            },
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TenderStatus.values.map((status) {
                final statusName = status.name.replaceAll('_', ' ');
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(statusName),
                    selected: _selectedFilter == statusName,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected ? statusName : 'All';
                      });
                      tenderNotifier.getTenders(
                        queryParams: selected ? {'status': status.name} : null,
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(TenderState tenderState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Tenders',
              tenderState.tenders.length.toString(),
              Colors.blue,
              Icons.list_alt,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Active',
              tenderState.tenders
                  .where((t) => t.status == TenderStatus.PUBLISHED)
                  .length
                  .toString(),
              Colors.green,
              Icons.check_circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Draft',
              tenderState.tenders
                  .where((t) => t.status == TenderStatus.DRAFT)
                  .length
                  .toString(),
              Colors.orange,
              Icons.drafts,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTenderList(TenderState tenderState, TenderProvider tenderNotifier) {
    if (tenderState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tenderState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: 64),
            const SizedBox(height: 16),
            Text(
              'Error loading tenders',
              style: TextStyle(color: Colors.red[300], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              tenderState.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => tenderNotifier.getTenders(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (tenderState.tenders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tenders found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await tenderNotifier.getTenders();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tenderState.tenders.length,
        itemBuilder: (context, index) {
          final tender = tenderState.tenders[index];
          return _buildTenderCard(tender as Tender);
        },
      ),
    );
  }

  Widget _buildTenderCard(Tender tender) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TenderDetailScreen(tenderId: tender.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      tender.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(tender.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(tender.status).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      tender.status.name.replaceAll('_', ' '),
                      style: TextStyle(
                        color: _getStatusColor(tender.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Tender details
              Text(
                tender.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // Details row
              _buildDetailRow(
                Icons.numbers,
                'Reference: ${tender.referenceNumber ?? 'N/A'}',
              ),
              _buildDetailRow(
                Icons.category,
                'Category: ${tender.category.name.replaceAll('_', ' ')}',
              ),
              _buildDetailRow(
                Icons.business,
                'Department: ${tender.department}',
              ),
              const SizedBox(height: 8),

              // Dates and budget
              Row(
                children: [
                  Expanded(
                    child: _buildDateInfo(
                      'Opens',
                      tender.openingDate,
                      Icons.calendar_today,
                    ),
                  ),
                  Expanded(
                    child: _buildDateInfo(
                      'Closes',
                      tender.closingDate,
                      Icons.event_busy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Budget and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'KES ${tender.estimatedBudget.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, size: 20),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TenderDetailScreen(tenderId: tender.id),
                            ),
                          );
                        },
                      ),
                      if (tender.status == TenderStatus.DRAFT)
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () {
                            // Navigate to edit screen
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(String label, DateTime date, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                _formatDate(date),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(TenderStatus status) {
    switch (status) {
      case TenderStatus.DRAFT:
        return Colors.grey;
      case TenderStatus.UNDER_REVIEW:
        return Colors.orange;
      case TenderStatus.APPROVED:
        return Colors.blue;
      case TenderStatus.PUBLISHED:
        return Colors.green;
      case TenderStatus.ACTIVE:
        return Colors.lightGreen;
      case TenderStatus.CLOSED:
        return Colors.purple;
      case TenderStatus.AWARDED:
        return Colors.teal;
      case TenderStatus.COMPLETED:
        return Colors.indigo;
      case TenderStatus.CANCELLED:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}