import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../models/resource_model.dart';
import '../../../providers/resource_provider.dart';
import '../../../utils/resources/file_type_icons.dart';
import '../../dialogs/resources/create_resource_dialog.dart';
import '../../dialogs/resources/delete_resource_dialog.dart';
import '../../dialogs/resources/file_preview_dialog.dart';
import '../../dialogs/resources/update_resource_dialog.dart';
import '../../sub_widgets/resources/resource_grid_item.dart';

class ResourcesManagement extends ConsumerStatefulWidget {
  const ResourcesManagement({super.key});

  @override
  ConsumerState<ResourcesManagement> createState() => _ResourcesManagementState();
}

class _ResourcesManagementState extends ConsumerState<ResourcesManagement> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;
  ResourceType? _selectedType;
  ResourceStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(resourceProvider.notifier);
      notifier.toggleManagementView();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(resourceProvider.notifier).search(_searchController.text);
  }

  void _showCreateResourceDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateResourceDialog(),
    ).then((_) {
      ref.read(resourceProvider.notifier).loadUserResources();
    });
  }

  void _showUpdateResourceDialog(Resource resource) {
    showDialog(
      context: context,
      builder: (context) => UpdateResourceDialog(resource: resource),
    ).then((_) {
      ref.read(resourceProvider.notifier).loadUserResources();
    });
  }

  void _showDeleteResourceDialog(Resource resource) {
    showDialog(
      context: context,
      builder: (context) => DeleteResourceDialog(resource: resource),
    ).then((_) {
      ref.read(resourceProvider.notifier).loadUserResources();
    });
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

  void _filterByType(ResourceType? type) {
    setState(() {
      _selectedType = type;
    });
    ref.read(resourceProvider.notifier).selectType(type);
  }

  void _filterByStatus(ResourceStatus? status) {
    setState(() {
      _selectedStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resourceProvider);
    final notifier = ref.read(resourceProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateResourceDialog,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Iconsax.add),
        label: const Text('New Resource'),
      ),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 2,
            title: const Text(
              'Manage Resources',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: Colors.blue,
              ),
            ),
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

          // Stats & Filters
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Stats Cards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _StatCard(
                        title: 'Total',
                        value: state.resources.length.toString(),
                        icon: Iconsax.document,
                        color: Colors.blue,
                      ),
                      _StatCard(
                        title: 'Published',
                        value: state.resources
                            .where((r) => r.status == ResourceStatus.published)
                            .length
                            .toString(),
                        icon: Iconsax.tick_circle,
                        color: Colors.green,
                      ),
                      _StatCard(
                        title: 'Draft',
                        value: state.resources
                            .where((r) => r.status == ResourceStatus.draft)
                            .length
                            .toString(),
                        icon: Iconsax.edit,
                        color: Colors.orange,
                      ),
                      _StatCard(
                        title: 'Featured',
                        value: state.resources
                            .where((r) => r.isFeatured)
                            .length
                            .toString(),
                        icon: Iconsax.star,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ),

                // Search & Filters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Container(
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
                            hintText: 'Search your resources...',
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<ResourceType>(
                                  value: _selectedType,
                                  hint: const Text('Filter by Type'),
                                  isExpanded: true,
                                  icon: const Icon(Iconsax.arrow_down_1, size: 16),
                                  items: [
                                    const DropdownMenuItem<ResourceType>(
                                      value: null,
                                      child: Text('All Types'),
                                    ),
                                    ...ResourceType.values.map((type) {
                                      return DropdownMenuItem<ResourceType>(
                                        value: type,
                                        child: Row(
                                          children: [
                                            Icon(
                                              FileTypeIcons.getIconForType(type),
                                              size: 20,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 8),
                                            Text(type.displayName),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                  onChanged: _filterByType,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<ResourceStatus>(
                                  value: _selectedStatus,
                                  hint: const Text('Filter by Status'),
                                  isExpanded: true,
                                  icon: const Icon(Iconsax.arrow_down_1, size: 16),
                                  items: [
                                    const DropdownMenuItem<ResourceStatus>(
                                      value: null,
                                      child: Text('All Status'),
                                    ),
                                    ...ResourceStatus.values.map((status) {
                                      return DropdownMenuItem<ResourceStatus>(
                                        value: status,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: status.color,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(status.displayName),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                  onChanged: _filterByStatus,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Resources List
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
                        onPressed: () => notifier.loadUserResources(),
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
                          Iconsax.document_upload,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No resources yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create your first resource to get started',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _showCreateResourceDialog,
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Iconsax.add, size: 18),
                              SizedBox(width: 8),
                              Text('Create Resource'),
                            ],
                          ),
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
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final resource = state.filteredResources[index];
                        return _ManagementGridItem(
                          resource: resource,
                          onEdit: () => _showUpdateResourceDialog(resource),
                          onDelete: () => _showDeleteResourceDialog(resource),
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
                        child: _ManagementListItem(
                          resource: resource,
                          onEdit: () => _showUpdateResourceDialog(resource),
                          onDelete: () => _showDeleteResourceDialog(resource),
                          onPreview: (file, fileIndex) =>
                              _showFilePreview(resource, file, fileIndex),
                        ),
                      );
                    },
                    childCount: state.filteredResources.length,
                  ),
                ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagementGridItem extends StatelessWidget {
  final Resource resource;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(ResourceFile, int) onPreview;

  const _ManagementGridItem({
    required this.resource,
    required this.onEdit,
    required this.onDelete,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ResourceGridItem(
          resource: resource,
          onTap: () => _showOptions(context),
          onPreview: onPreview,
          showStatus: true,
        ),
        Positioned(
          top: 8,
          right: 8,
          child: PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(Iconsax.more, size: 16),
            ),
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Iconsax.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Iconsax.trash, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ResourceOptionsSheet(
        resource: resource,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }
}

class _ManagementListItem extends StatelessWidget {
  final Resource resource;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(ResourceFile, int) onPreview;

  const _ManagementListItem({
    required this.resource,
    required this.onEdit,
    required this.onDelete,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showOptions(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: resource.primaryFile?.isImage == true
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    resource.primaryFile!.thumbnailUrl ?? resource.primaryFile!.fileUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(
                        FileTypeIcons.getIconForResource(resource),
                        size: 24,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
                    : Center(
                  child: Icon(
                    FileTypeIcons.getIconForResource(resource),
                    size: 24,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            resource.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: resource.status.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            resource.status.displayName,
                            style: TextStyle(
                              color: resource.status.color,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resource.description ?? 'No description',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          resource.category.icon,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          resource.category.displayName,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          FileTypeIcons.getIconForType(resource.resourceType),
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          resource.resourceType.displayName,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Iconsax.document, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${resource.filesCount} files',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
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

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ResourceOptionsSheet(
        resource: resource,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }
}

class _ResourceOptionsSheet extends StatelessWidget {
  final Resource resource;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ResourceOptionsSheet({
    required this.resource,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Iconsax.eye, color: Colors.blue),
            title: const Text('View Details'),
            onTap: () {
              Navigator.pop(context);
              // Show detailed view
            },
          ),
          ListTile(
            leading: const Icon(Iconsax.edit, color: Colors.orange),
            title: const Text('Edit Resource'),
            onTap: () {
              Navigator.pop(context);
              onEdit();
            },
          ),
          if (resource.status == ResourceStatus.draft)
            ListTile(
              leading: const Icon(Iconsax.send_2, color: Colors.green),
              title: const Text('Publish'),
              onTap: () {
                Navigator.pop(context);
                // Implement publish
              },
            ),
          if (resource.status == ResourceStatus.published)
            ListTile(
              leading: const Icon(Iconsax.archive, color: Colors.purple),
              title: const Text('Archive'),
              onTap: () {
                Navigator.pop(context);
                // Implement archive
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Iconsax.trash, color: Colors.red),
            title: const Text('Delete'),
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}