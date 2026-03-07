import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/news_provider.dart';
import '../../data/providers/category_provider.dart';
import '../tabs/all_news_tab.dart';
import '../tabs/featured_news_tab.dart';
import '../tabs/breaking_news_tab.dart';
import '../tabs/my_news_tab.dart';
import '../tabs/drafts_tab.dart';
import '../tabs/scheduled_tab.dart';
import '../../../public/auth/providers/auth_provider.dart';
import '../../../../core/utils/toast_utils.dart';

class NewsDashboard extends ConsumerStatefulWidget {
  const NewsDashboard({super.key});

  @override
  ConsumerState<NewsDashboard> createState() => _NewsDashboardState();
}

class _NewsDashboardState extends ConsumerState<NewsDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  final List<String> _tabTitles = [
    'All News',
    'Featured',
    'Breaking',
    'My News',
    'Drafts',
    'Scheduled',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await ref.read(newsProvider.notifier).fetchNews();
    await ref.read(categoryProvider.notifier).fetchCategories();
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onCreateNews() {
    // Navigate to news editor
    ToastUtils.showInfoToast('Navigate to news editor');
  }

  void _onSearch(String query) {
    ref.read(newsProvider.notifier).searchNews(query);
  }

  void _onFilter() {
    // Show filter dialog
    ToastUtils.showInfoToast('Show filter dialog');
  }

  void _onRefresh() async {
    await ref.read(newsProvider.notifier).fetchNews();
    ToastUtils.showSuccessToast('News refreshed');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final newsState = ref.watch(newsProvider);
    final isAdmin = user?['roles']?.contains('Admin') ?? false;
    final isManager = user?['roles']?.contains('Manager') ?? false;
    final canManageNews = isAdmin || isManager;

    return Scaffold(
      body: Column(
        children: [
          // Header with search and actions
          _buildHeader(context, canManageNews),

          // Tab bar
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
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF0D47A1),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF0D47A1),
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              onTap: _onTabChanged,
              tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                AllNewsTab(
                  news: newsState.displayNews,
                  isLoading: newsState.isLoading,
                  onRefresh: _onRefresh,
                ),
                FeaturedNewsTab(
                  featuredNews: newsState.featuredNews,
                  onRefresh: _onRefresh,
                ),
                BreakingNewsTab(
                  breakingNews: newsState.breakingNews,
                  onRefresh: _onRefresh,
                ),
                MyNewsTab(
                  userId: user?['id'] ?? '',
                  onRefresh: _onRefresh,
                ),
                DraftsTab(
                  onRefresh: _onRefresh,
                ),
                ScheduledTab(
                  onRefresh: _onRefresh,
                ),
              ],
            ),
          ),
        ],
      ),

      // Floating action button for creating news
      floatingActionButton: canManageNews
          ? FloatingActionButton.extended(
        onPressed: _onCreateNews,
        backgroundColor: const Color(0xFF0D47A1),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create News',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context, bool canManageNews) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D47A1), // Deep blue
            Color(0xFF1565C0), // Medium blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title and quick stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'News Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage and publish news articles',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (canManageNews)
                IconButton(
                  onPressed: _onRefresh,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'Refresh',
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Search bar
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: _onSearch,
                    decoration: const InputDecoration(
                      hintText: 'Search news...',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _onFilter,
                  icon: const Icon(Icons.filter_list, color: Colors.grey),
                  tooltip: 'Filter',
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Quick stats
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final newsState = ref.watch(newsProvider);
    final totalPublished = newsState.newsList.where((n) => n.isPublished).length;
    final totalDrafts = newsState.newsList.where((n) => n.isDraft).length;
    final totalPending = newsState.newsList.where((n) => n.isPendingReview).length;

    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            'Total',
            newsState.newsList.length.toString(),
            Icons.article,
            Colors.blue,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Published',
            totalPublished.toString(),
            Icons.public,
            Colors.green,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Drafts',
            totalDrafts.toString(),
            Icons.drafts,
            Colors.orange,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Pending',
            totalPending.toString(),
            Icons.pending,
            Colors.amber,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Featured',
            newsState.featuredNews.length.toString(),
            Icons.star,
            Colors.purple,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Breaking',
            newsState.breakingNews.length.toString(),
            Icons.notification_important,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}