import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/fixed_asset_provider.dart';
import 'fixed_asset_card.dart';

class FixedAssetList extends ConsumerStatefulWidget {
  const FixedAssetList({super.key});

  @override
  ConsumerState<FixedAssetList> createState() => _FixedAssetListState();
}

class _FixedAssetListState extends ConsumerState<FixedAssetList> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    // Initial fetch - loads all assets for local filtering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fixedAssetsProvider.notifier).fetchAssets();
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // No need for load more with local filtering
    }
  }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) {
      _searchDebounce?.cancel();
    }

    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    // Update the filter in the provider - filtering happens locally
    ref.read(fixedAssetsProvider.notifier).updateFilters(searchQuery: query);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
    ref.read(fixedAssetsProvider.notifier).updateFilters(searchQuery: '');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fixedAssetsProvider);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    // Use displayedAssets which are filtered locally
    final displayedAssets = state.displayedAssets;

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _onSearchChanged(),
              decoration: InputDecoration(
                hintText: 'Search assets by name, number, location...',
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: _clearSearch,
                )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),

        // Loading indicator (full screen)
        if (state.isLoading && displayedAssets.isEmpty)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),

        // Error state
        if (state.error != null && displayedAssets.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.error!,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(fixedAssetsProvider.notifier).fetchAssets(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),

        // Assets list
        if (displayedAssets.isNotEmpty || (!state.isLoading && displayedAssets.isEmpty))
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // Refresh all assets from backend
                await ref.read(fixedAssetsProvider.notifier).fetchAssets();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 4 : 8,
                ),
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Grid/List View
                    if (displayedAssets.isNotEmpty) ...[
                      SliverLayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.crossAxisExtent > 600 ? 2 : 1;
                          final childAspectRatio = isSmallScreen
                              ? (crossAxisCount == 1 ? 1.3 : 1.2)
                              : (crossAxisCount == 1 ? 1.6 : 1.4);

                          return SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: isSmallScreen ? 8 : 12,
                              mainAxisSpacing: isSmallScreen ? 8 : 12,
                              childAspectRatio: childAspectRatio,
                            ),
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                final asset = displayedAssets[index];
                                return FixedAssetCard(asset: asset);
                              },
                              childCount: displayedAssets.length,
                            ),
                          );
                        },
                      ),

                      // End of list message
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              if (_isSearching && displayedAssets.isEmpty)
                                Column(
                                  children: [
                                    Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No assets found for "${_searchController.text}"',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    OutlinedButton(
                                      onPressed: _clearSearch,
                                      child: const Text('Clear Search'),
                                    ),
                                  ],
                                )
                              else if (displayedAssets.isNotEmpty)
                                Text(
                                  'Showing ${displayedAssets.length} of ${state.totalCount} assets',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[600]),
                                )
                              else
                                Column(
                                  children: [
                                    Icon(Icons.business_center_outlined,
                                        size: 64, color: Colors.grey[400]),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No assets found',
                                      style: TextStyle(fontSize: 18, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Add your first fixed asset to get started',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ] else if (!state.isLoading) ...[
                      // Empty state when no assets
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isSearching ? Icons.search_off : Icons.business_center_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isSearching
                                    ? 'No assets found for "${_searchController.text}"'
                                    : 'No assets found',
                                style: const TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isSearching
                                    ? 'Try a different search term'
                                    : 'Add your first fixed asset to get started',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              if (_isSearching) ...[
                                const SizedBox(height: 16),
                                OutlinedButton(
                                  onPressed: _clearSearch,
                                  child: const Text('Clear Search'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }
}