import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../public/auth/providers/auth_provider.dart';
import '../../data/providers/subscription_provider.dart';
import '../../data/providers/category_provider.dart';
import '../../data/models/news_subscription.dart';
import '../../../../core/utils/toast_utils.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabTitles = ['My Subscriptions', 'Categories', 'Authors', 'Breaking News'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    await ref.read(subscriptionProvider.notifier).fetchSubscriptions();
    await ref.read(categoryProvider.notifier).fetchCategories();
  }

  void _showSubscribeToCategory() {
    final categories = ref.read(categoryProvider).categories;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscribe to Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                leading: Icon(category.categoryIcon, color: category.categoryColor),
                title: Text(category.name),
                subtitle: Text('${category.stats?.newsCount ?? 0} articles'),
                trailing: ref.read(subscriptionProvider.notifier).isSubscribedToCategory(category.id)
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  _subscribeToCategory(category.id);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _subscribeToCategory(String categoryId) async {
    await ref.read(subscriptionProvider.notifier).subscribeToCategory(categoryId, null);
    ToastUtils.showSuccessToast('Subscribed to category');
  }

  Future<void> _subscribeToBreakingNews() async {
    await ref.read(subscriptionProvider.notifier).subscribeToBreakingNews(null);
    ToastUtils.showSuccessToast('Subscribed to breaking news');
  }

  Future<void> _subscribeToAllNews() async {
    await ref.read(subscriptionProvider.notifier).subscribeToAllNews(null);
    ToastUtils.showSuccessToast('Subscribed to all news');
  }

  void _toggleSubscriptionActive(String id) {
    ref.read(subscriptionProvider.notifier).toggleActive(id);
  }

  void _showSubscriptionSettings(NewsSubscription subscription) {
    final notificationPrefs = subscription.notificationPreferences;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('${subscription.typeLabel} Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text('On Publish'),
                  subtitle: const Text('Notify when new articles are published'),
                  value: notificationPrefs.onPublish,
                  onChanged: (value) {
                    setState(() {
                      // Update local state
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('On Breaking News'),
                  subtitle: const Text('Notify for breaking news'),
                  value: notificationPrefs.onBreakingNews,
                  onChanged: (value) {
                    setState(() {
                      // Update local state
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('On Author Post'),
                  subtitle: const Text('Notify when subscribed authors post'),
                  value: notificationPrefs.onAuthorPost,
                  onChanged: (value) {
                    setState(() {
                      // Update local state
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Digest Frequency', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                DropdownButtonFormField<DigestFrequency>(
                  value: notificationPrefs.digestFrequency,
                  items: DigestFrequency.values.map((freq) {
                    return DropdownMenuItem(
                      value: freq,
                      child: Text(freq.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        // Update local state
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Save settings
                  Navigator.pop(context);
                  ToastUtils.showSuccessToast('Settings updated');
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final user = ref.watch(authProvider).user;
    final userId = user?['id'];

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'News Subscriptions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage your news notifications',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Stats
                _buildSubscriptionStats(subscriptionState),
              ],
            ),
          ),

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
              tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
            ),
          ),

          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMySubscriptions(userId),
                  _buildCategoriesTab(),
                  _buildAuthorsTab(),
                  _buildBreakingNewsTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionStats(SubscriptionState state) {
    final totalSubscriptions = state.subscriptions.length;
    final activeCount = state.subscriptions.where((s) => s.isActive).length;
    final categoryCount = state.subscriptions.where((s) => s.type == NewsSubscriptionType.category).length;
    final authorCount = state.subscriptions.where((s) => s.type == NewsSubscriptionType.author).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatChip('Total', totalSubscriptions.toString(), Icons.notifications),
          const SizedBox(width: 12),
          _buildStatChip('Active', activeCount.toString(), Icons.check_circle, Colors.green),
          const SizedBox(width: 12),
          _buildStatChip('Categories', categoryCount.toString(), Icons.category, Colors.blue),
          const SizedBox(width: 12),
          _buildStatChip('Authors', authorCount.toString(), Icons.person, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon, [Color? color]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey),
          const SizedBox(width: 6),
          Text(
            '$value $label',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildMySubscriptions(String? userId) {
    final subscriptions = ref.watch(subscriptionProvider).subscriptions
        .where((s) => s.userId == userId)
        .toList();

    if (subscriptions.isEmpty) {
      return _buildEmptyState(
        icon: Icons.notifications_none,
        title: 'No subscriptions',
        message: 'Subscribe to categories, authors, or breaking news to stay updated',
        actionText: 'Browse Categories',
        onAction: _showSubscribeToCategory,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = subscriptions[index];
        return _buildSubscriptionCard(subscription);
      },
    );
  }

  Widget _buildCategoriesTab() {
    final categories = ref.watch(categoryProvider).categories;
    final subscriptionState = ref.watch(subscriptionProvider);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSubscribed = subscriptionState.subscriptions.any((s) =>
        s.type == NewsSubscriptionType.category &&
            s.categoryId == category.id &&
            s.isActive
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: category.categoryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.categoryIcon,
                color: category.categoryColor,
              ),
            ),
            title: Text(category.name),
            subtitle: Text(
              '${category.stats?.newsCount ?? 0} articles • ${category.description}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Switch(
              value: isSubscribed,
              onChanged: (value) {
                if (value) {
                  _subscribeToCategory(category.id);
                } else {
                  // Unsubscribe
                  final subscription = subscriptionState.subscriptions.firstWhere((s) =>
                  s.type == NewsSubscriptionType.category &&
                      s.categoryId == category.id
                  );
                  _toggleSubscriptionActive(subscription.id);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuthorsTab() {
    // In a real app, this would fetch authors from your user provider
    final authors = [
      {'id': '1', 'name': 'John Doe', 'articles': 24},
      {'id': '2', 'name': 'Jane Smith', 'articles': 18},
      {'id': '3', 'name': 'Robert Johnson', 'articles': 32},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: authors.length,
      itemBuilder: (context, index) {
        final author = authors[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text('${author['name']}'),
            subtitle: Text('${author['articles']} articles'),
            trailing: Switch(
              value: false, // Check subscription status
              onChanged: (value) {
                ToastUtils.showInfoToast('Subscribe to author functionality');
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBreakingNewsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notification_important, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Breaking News Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Get instant notifications for breaking news stories. You\'ll be the first to know about important updates.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _subscribeToBreakingNews,
            icon: const Icon(Icons.notifications_active),
            label: const Text('Subscribe to Breaking News'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(NewsSubscription subscription) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: subscription.isActive ? Colors.blue[50] : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(
            subscription.typeIcon,
            color: subscription.isActive ? Colors.blue : Colors.grey,
          ),
        ),
        title: Text(subscription.typeLabel),
        subtitle: _buildSubscriptionSubtitle(subscription),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _showSubscriptionSettings(subscription),
              icon: const Icon(Icons.settings, size: 20),
              tooltip: 'Settings',
            ),
            Switch(
              value: subscription.isActive,
              onChanged: (value) => _toggleSubscriptionActive(subscription.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionSubtitle(NewsSubscription subscription) {
    switch (subscription.type) {
      case NewsSubscriptionType.category:
        return Text(
          subscription.categoryName ?? 'Category',
          style: const TextStyle(fontSize: 12),
        );
      case NewsSubscriptionType.author:
        return Text(
          subscription.authorName ?? 'Author',
          style: const TextStyle(fontSize: 12),
        );
      case NewsSubscriptionType.breakingNews:
        return const Text(
          'Instant breaking news alerts',
          style: TextStyle(fontSize: 12),
        );
      case NewsSubscriptionType.all:
        return const Text(
          'All news articles',
          style: TextStyle(fontSize: 12),
        );
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }
}