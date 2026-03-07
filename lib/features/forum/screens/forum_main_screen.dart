import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/forum_category.dart';
import '../models/forum_thread.dart';
import '../providers/forum_provider.dart';
import '../widgets/category_card.widget.dart';
import '../widgets/search_bar.widget.dart';
import '../widgets/thread_card.widget.dart';

class ForumMainScreen extends ConsumerStatefulWidget {
  final Function(String) onThreadTap;
  final VoidCallback onCreateThread;
  final Function(String) onCategorySelect;

  const ForumMainScreen({
    super.key,
    required this.onThreadTap,
    required this.onCreateThread,
    required this.onCategorySelect,
  });

  @override
  ConsumerState<ForumMainScreen> createState() => _ForumMainScreenState();
}

class _ForumMainScreenState extends ConsumerState<ForumMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _selectedFilter = 'latest';

  final List<String> _filterOptions = [
    'latest',
    'popular',
    'trending',
    'unanswered',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize forum data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(forumProvider.notifier).fetchCategories();
      ref.read(forumProvider.notifier).fetchThreads();
      ref.read(forumProvider.notifier).fetchPopularThreads();
      ref.read(forumProvider.notifier).fetchNotifications();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreThreads();
    }
  }

  void _loadMoreThreads() {
    final state = ref.read(forumProvider);
    if (!state.isLoading && state.currentPage < state.totalPages) {
      ref.read(forumProvider.notifier).fetchThreads(
            categoryId: state.selectedCategoryId,
            searchQuery: state.searchQuery,
            page: state.currentPage + 1,
          );
    }
  }

  void _handleSearch(String query) {
    if (query.isEmpty) {
      ref.read(forumProvider.notifier).clearSearch();
      setState(() => _isSearching = false);
    } else {
      ref.read(forumProvider.notifier).searchForum(query);
      setState(() => _isSearching = true);
    }
  }

  void _selectFilter(String filter) {
    setState(() => _selectedFilter = filter);
    ref.read(forumProvider.notifier).fetchThreads(
          sort: filter,
          categoryId: ref.read(forumProvider).selectedCategoryId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final forumState = ref.watch(forumProvider);
    final categories = forumState.categories;
    final threads = forumState.threads;
    final popularThreads = forumState.popularThreads;
    final isLoading = forumState.isLoading;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Header with search
        SliverAppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          floating: true,
          pinned: true,
          expandedHeight: 180,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0066FF).withValues(alpha: 0.8),
                    const Color(0xFF0066FF).withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community Forum',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join the conversation and share your thoughts',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: Container(
              color: const Color(0xFF0A0E17).withValues(alpha: 0.95),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // Search bar
                  ForumSearchBar(
                    controller: _searchController,
                    onSearch: _handleSearch,
                    onClear: () {
                      _searchController.clear();
                      _handleSearch('');
                    },
                  ),
                  const SizedBox(height: 16),

                  // Filter chips
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _filterOptions.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              filter.toUpperCase(),
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (_) => _selectFilter(filter),
                            backgroundColor: Colors.white.withValues(alpha: 0.05),
                            selectedColor: const Color(0xFF0066FF),
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF0066FF)
                                    : Colors.white.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Main content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Quick stats
                _buildQuickStats(forumState),
                const SizedBox(height: 30),

                // Categories section
                if (categories.isNotEmpty) ...[
                  _buildCategoriesSection(categories),
                  const SizedBox(height: 30),
                ],

                // Popular threads
                if (popularThreads.isNotEmpty && !_isSearching) ...[
                  _buildPopularThreadsSection(popularThreads),
                  const SizedBox(height: 30),
                ],

                // All threads header
                _buildThreadsHeader(threads.length),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Threads list
        if (threads.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final thread = threads[index];
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                      20, 4, 20, index == threads.length - 1 ? 80 : 4),
                  child: ThreadCard(
                    thread: thread,
                    onTap: () => widget.onThreadTap(thread.slug),
                  ),
                );
              },
              childCount: threads.length,
            ),
          )
        else if (!isLoading)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isSearching ? Icons.search_off : Icons.forum_outlined,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isSearching
                        ? 'No threads found for your search'
                        : 'No threads yet. Be the first to post!',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                  if (!_isSearching) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: widget.onCreateThread,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Create First Thread'),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickStats(ForumState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E293B).withValues(alpha: 0.6),
            const Color(0xFF0F172A).withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.forum, '${state.threads.length}', 'Threads'),
          _buildStatItem(
              Icons.chat_bubble,
              '${state.threads.fold(0, (sum, thread) => sum + thread.replyCount)}',
              'Replies'),
          _buildStatItem(
              Icons.people, '${state.categories.length}', 'Categories'),
          _buildStatItem(Icons.notifications,
              '${state.unreadNotificationsCount}', 'Alerts'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0066FF).withValues(alpha: 0.2),
                const Color(0xFF00CCFF).withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF00CCFF), size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(List<ForumCategory> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Categories',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () => widget.onCategorySelect(''),
              child: const Row(
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFF00CCFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16, color: Color(0xFF00CCFF)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: EdgeInsets.only(right: 12, left: index == 0 ? 0 : 0),
                child: CategoryCard(
                  category: category,
                  onTap: () => widget.onCategorySelect(category.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularThreadsSection(List<ForumThread> threads) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular This Week',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: threads.length,
            itemBuilder: (context, index) {
              final thread = threads[index];
              return Padding(
                padding: EdgeInsets.only(right: 16, left: index == 0 ? 0 : 0),
                child: PopularThreadCard(
                  thread: thread,
                  onTap: () => widget.onThreadTap(thread.slug),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildThreadsHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _isSearching ? 'Search Results' : 'Recent Discussions',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Text(
            '$count ${count == 1 ? 'Thread' : 'Threads'}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class PopularThreadCard extends StatelessWidget {
  final ForumThread thread;
  final VoidCallback onTap;

  const PopularThreadCard({
    super.key,
    required this.thread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E293B).withValues(alpha: 0.8),
                const Color(0xFF0F172A).withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0066FF).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        thread.categoryName,
                        style: const TextStyle(
                          color: Color(0xFF00CCFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      thread.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Excerpt
                    Text(
                      thread.excerpt,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 20),

                    // Stats
                    Row(
                      children: [
                        _buildStatIcon(
                            Icons.chat_bubble_outline, '${thread.replyCount}'),
                        const SizedBox(width: 12),
                        _buildStatIcon(
                            Icons.favorite_border, '${thread.likesCount}'),
                        const SizedBox(width: 12),
                        _buildStatIcon(Icons.remove_red_eye, '${thread.views}'),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Trending',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatIcon(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
