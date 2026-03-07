import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../public/auth/providers/auth_provider.dart';
import '../../data/providers/news_provider.dart';
import 'news_dashboard.dart';
import 'news_list_screen.dart';
import 'news_editor_screen.dart';
import 'categories_screen.dart';
import 'comments_screen.dart';
import 'subscriptions_screen.dart';
import 'analytics_screen.dart';

class NewsMainScreen extends ConsumerStatefulWidget {
  const NewsMainScreen({super.key});

  @override
  ConsumerState<NewsMainScreen> createState() => _NewsMainScreenState();
}

class _NewsMainScreenState extends ConsumerState<NewsMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const NewsDashboard(),
    const NewsListScreen(),
    const CategoriesScreen(),
    const CommentsScreen(),
    const SubscriptionsScreen(),
    const AnalyticsScreen(),
  ];

  final List<String> _screenTitles = [
    'Dashboard',
    'All News',
    'Categories',
    'Comments',
    'Subscriptions',
    'Analytics',
  ];

  final List<IconData> _screenIcons = [
    Icons.dashboard,
    Icons.newspaper,
    Icons.category,
    Icons.comment,
    Icons.notifications,
    Icons.analytics,
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final isAdmin = user?['roles']?.contains('Admin') ?? false;
    final isManager = user?['roles']?.contains('Manager') ?? false;
    final canAccessAnalytics = isAdmin || isManager;

    // Filter screens based on permissions
    final availableScreens = _screens.asMap().entries.where((entry) {
      final index = entry.key;
      if (index == 5) {
        // Analytics screen
        return canAccessAnalytics;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitles[_selectedIndex]),
        backgroundColor: const Color(0xFF0D47A1),
        actions: [
          IconButton(
            onPressed: () {
              // Search functionality
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              // Refresh functionality
              ref.read(newsProvider.notifier).fetchNews();
            },
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help, size: 20),
                    SizedBox(width: 8),
                    Text('Help'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: availableScreens.map((entry) => entry.value).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D47A1),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        items: availableScreens.map((entry) {
          final originalIndex = entry.key;
          return BottomNavigationBarItem(
            icon: Icon(_screenIcons[originalIndex]),
            label: _screenTitles[originalIndex],
          );
        }).toList(),
      ),
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                // Navigate to news editor
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsEditorScreen(),
                  ),
                );
              },
              backgroundColor: const Color(0xFF0D47A1),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
