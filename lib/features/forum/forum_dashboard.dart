import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/create_thread_screen.dart';
import 'screens/forum_categories_screen.dart';
import 'screens/forum_main_screen.dart';
import 'screens/forum_notifications_screen.dart';
import 'screens/thread_detail_screen.dart';


class ForumDashboard extends ConsumerStatefulWidget {
  const ForumDashboard({super.key});

  @override
  ConsumerState<ForumDashboard> createState() => _ForumDashboardState();
}

class _ForumDashboardState extends ConsumerState<ForumDashboard> {
  int _selectedIndex = 0;
  bool _isSidebarOpen = false;
  String _currentRoute = '/forum';
  String? _currentThreadSlug;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.forum, 'label': 'Forum Home', 'route': '/forum'},
    {'icon': Icons.category, 'label': 'Categories', 'route': '/forum/categories'},
    {'icon': Icons.add_circle, 'label': 'New Thread', 'route': '/forum/new'},
    {'icon': Icons.notifications, 'label': 'Notifications', 'route': '/forum/notifications'},
    {'icon': Icons.search, 'label': 'Search', 'route': '/forum/search'},
    {'icon': Icons.trending_up, 'label': 'Popular', 'route': '/forum/popular'},
    {'icon': Icons.star, 'label': 'Featured', 'route': '/forum/featured'},
    {'icon': Icons.person, 'label': 'My Threads', 'route': '/forum/my-threads'},
    {'icon': Icons.bookmark, 'label': 'Bookmarks', 'route': '/forum/bookmarks'},
    {'icon': Icons.settings, 'label': 'Forum Settings', 'route': '/forum/settings'},
  ];

  void _navigateToRoute(String route, {String? threadSlug}) {
    setState(() {
      _currentRoute = route;
      _currentThreadSlug = threadSlug;
      _isSidebarOpen = false;

      // Update tab index
      final index = _menuItems.indexWhere((item) => item['route'] == route);
      if (index != -1) {
        _selectedIndex = index;
      }
    });
  }

  void _openThread(String slug) {
    _navigateToRoute('/forum/thread', threadSlug: slug);
  }

  Widget _getCurrentContent() {
    switch (_currentRoute) {
      case '/forum':
        return ForumMainScreen(
          onThreadTap: _openThread,
          onCreateThread: () => _navigateToRoute('/forum/new'),
          onCategorySelect: (categoryId) => _navigateToRoute('/forum/categories'),
        );
      case '/forum/categories':
        return ForumCategoriesScreen(
          onCategorySelect: (categoryId) {
            _navigateToRoute('/forum');
            // You would trigger category filtering here
          },
        );
      case '/forum/new':
        return CreateThreadScreen(
          onSuccess: () {
            _navigateToRoute('/forum');
            // Refresh threads after creation
          },
          onCancel: () => _navigateToRoute('/forum'),
        );
      case '/forum/notifications':
        return const ForumNotificationsScreen();
      case '/forum/thread':
        if (_currentThreadSlug != null) {
          return ThreadDetailScreen(
            threadSlug: _currentThreadSlug!,
            onBack: () => _navigateToRoute('/forum'),
          );
        }
        return _buildNotFound();
      default:
        return ForumMainScreen(
          onThreadTap: _openThread,
          onCreateThread: () => _navigateToRoute('/forum/new'),
          onCategorySelect: (categoryId) => _navigateToRoute('/forum/categories'),
        );
    }
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.blue.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            'Content not found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _navigateToRoute('/forum'),
            child: const Text('Return to Forum'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: Stack(
        children: [
          // Main content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(left: _isSidebarOpen && !isMobile ? 280 : 0),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0A0E17),
                    Color(0xFF121828),
                    Color(0xFF0A0E17),
                  ],
                ),
              ),
              child: _getCurrentContent(),
            ),
          ),

          // Sidebar
          if (!isMobile)
            _buildDesktopSidebar(),
          if (isMobile)
            _buildMobileSidebar(),

          // Top gradient overlay
          IgnorePointer(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A0E17).withValues(alpha: 0.8),
                    const Color(0xFF0A0E17).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _currentRoute == '/forum'
          ? FloatingActionButton.extended(
        onPressed: () => _navigateToRoute('/forum/new'),
        backgroundColor: const Color(0xFF0066FF),
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(Icons.add, size: 24),
        label: const Text('New Thread', style: TextStyle(fontWeight: FontWeight.w600)),
      )
          : null,
    );
  }

  Widget _buildDesktopSidebar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _isSidebarOpen ? 0 : -280,
      top: 0,
      bottom: 0,
      child: Material(
        elevation: 16,
        color: Colors.transparent,
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0F172A).withValues(alpha: 0.95),
                const Color(0xFF1E293B).withValues(alpha: 0.95),
              ],
            ),
            border: Border(
              right: BorderSide(color: Colors.blue.withValues(alpha: 0.1)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0066FF).withValues(alpha: 0.3),
                      const Color(0xFF0066FF).withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.blue.withValues(alpha: 0.2)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.forum, color: Colors.white.withValues(alpha: 0.9), size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Forum',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _isSidebarOpen ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSidebarOpen = !_isSidebarOpen;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Menu items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: _menuItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = _currentRoute == item['route'];

                    return _buildMenuItem(
                      icon: item['icon'],
                      label: item['label'],
                      isSelected: isSelected,
                      onTap: () => _navigateToRoute(item['route']),
                    );
                  }).toList(),
                ),
              ),

              // User info footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border(
                    top: BorderSide(color: Colors.blue.withValues(alpha: 0.1)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF0066FF),
                            Color(0xFF00CCFF),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Community Member',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Active in forum',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileSidebar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _isSidebarOpen ? 0 : -280,
      top: 0,
      bottom: 0,
      child: Material(
        elevation: 16,
        child: Container(
          width: 280,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F172A),
                Color(0xFF1E293B),
              ],
            ),
          ),
          child: Column(
            children: [
              // Header with close button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0066FF).withValues(alpha: 0.3),
                      const Color(0xFF0066FF).withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.forum, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Forum',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 24),
                      onPressed: () {
                        setState(() {
                          _isSidebarOpen = false;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Menu items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: _menuItems.map((item) {
                    final isSelected = _currentRoute == item['route'];
                    return _buildMenuItem(
                      icon: item['icon'],
                      label: item['label'],
                      isSelected: isSelected,
                      onTap: () => _navigateToRoute(item['route']),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected
            ? const Color(0xFF0066FF).withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? const Color(0xFF0066FF)
                      : Colors.white.withValues(alpha: 0.7),
                  size: 20,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.8),
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0066FF),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}