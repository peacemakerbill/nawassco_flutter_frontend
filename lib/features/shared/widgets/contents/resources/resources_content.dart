import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../models/resource_model.dart';
import '../../../providers/resource_provider.dart';
import '../../dialogs/resources/file_preview_dialog.dart';
import '../../sub_widgets/resources/resource_details_sheet.dart';
import '../../sub_widgets/resources/resource_grid_item.dart';
import '../../sub_widgets/resources/resource_list_item.dart';

class ResourcesContent extends ConsumerStatefulWidget {
  const ResourcesContent({super.key});

  @override
  ConsumerState<ResourcesContent> createState() => _ResourcesContentState();
}

class _ResourcesContentState extends ConsumerState<ResourcesContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isGridView = true;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: ResourceCategory.values.length, vsync: this);
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(resourceProvider.notifier).loadResources();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(resourceProvider.notifier).search(_searchController.text);
  }

  void _onCategorySelected(ResourceCategory? category) {
    ref.read(resourceProvider.notifier).selectCategory(category);
    if (category != null) {
      final index = ResourceCategory.values.indexOf(category);
      if (index >= 0 && index < _tabController.length) {
        _tabController.animateTo(index);
      }
    }
  }

  void _showResourceDetails(Resource resource) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ResourceDetailsSheet(resource: resource),
    );
  }

  void _showFilePreview(Resource resource, ResourceFile file, int index) {
    showDialog(
      context: context,
      builder: (context) => FilePreviewDialog(
        resource: resource,
        file: file,
        fileIndex: index,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resourceProvider);
    final notifier = ref.read(resourceProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar Section
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: true,
            backgroundColor: Colors.white,
            elevation: 2,
            title: const Text(
              'Resources Library',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: Colors.blue,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: Icon(
                  _isGridView ? Iconsax.row_vertical : Iconsax.row_horizontal,
                  color: Colors.blue,
                ),
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Search Section
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search resources...',
                    prefixIcon: const Icon(Iconsax.search_normal, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Iconsax.close_circle, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        notifier.search('');
                      },
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
          ),

          // Categories Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _CategoriesTabBarDelegate(
              tabController: _tabController,
              onCategorySelected: _onCategorySelected,
              selectedCategory: state.selectedCategory,
            ),
          ),

          // Resources Grid/List
          if (state.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            )
          else if (state.error != null)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.warning_2, size: 64, color: Colors.orange),
                      const SizedBox(height: 16),
                      Text(
                        state.error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => notifier.loadResources(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Try Again',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (state.filteredResources.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.folder_open,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.searchQuery.isNotEmpty
                              ? 'No resources found for "${state.searchQuery}"'
                              : 'No resources available',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (state.selectedCategory != null || state.searchQuery.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              notifier.clearFilters();
                              _searchController.clear();
                            },
                            child: const Text('Clear filters'),
                          ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_isGridView)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final resource = state.filteredResources[index];
                        return ResourceGridItem(
                          resource: resource,
                          onTap: () => _showResourceDetails(resource),
                          onPreview: (file, fileIndex) =>
                              _showFilePreview(resource, file, fileIndex),
                        );
                      },
                      childCount: state.filteredResources.length,
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final resource = state.filteredResources[index];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          index == 0 ? 0 : 8,
                          16,
                          index == state.filteredResources.length - 1 ? 16 : 8,
                        ),
                        child: ResourceListItem(
                          resource: resource,
                          onTap: () => _showResourceDetails(resource),
                          onPreview: (file, fileIndex) =>
                              _showFilePreview(resource, file, fileIndex),
                        ),
                      );
                    },
                    childCount: state.filteredResources.length,
                  ),
                ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }
}

class _CategoriesTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final Function(ResourceCategory?) onCategorySelected;
  final ResourceCategory? selectedCategory;

  _CategoriesTabBarDelegate({
    required this.tabController,
    required this.onCategorySelected,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: ResourceCategory.values.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 16, right: 8),
                          child: FilterChip(
                            label: const Text('All'),
                            selected: selectedCategory == null,
                            onSelected: (_) => onCategorySelected(null),
                            backgroundColor: Colors.grey[100],
                            selectedColor: Colors.blue,
                            labelStyle: TextStyle(
                              color: selectedCategory == null
                                  ? Colors.white
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      }

                      final category = ResourceCategory.values[index - 1];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(category.displayName),
                          selected: selectedCategory == category,
                          onSelected: (_) => onCategorySelected(category),
                          backgroundColor: Colors.grey[100],
                          labelStyle: TextStyle(
                            color: selectedCategory == category
                                ? Colors.white
                                : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          avatar: selectedCategory == category
                              ? Icon(category.icon, size: 16, color: Colors.white)
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.grey[200]),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 49;

  @override
  double get minExtent => 49;

  @override
  bool shouldRebuild(covariant _CategoriesTabBarDelegate oldDelegate) {
    return oldDelegate.selectedCategory != selectedCategory;
  }
}