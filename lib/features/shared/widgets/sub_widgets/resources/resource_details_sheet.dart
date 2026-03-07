import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../models/resource_model.dart';
import '../../../providers/resource_provider.dart';
import '../../../utils/resources/file_type_icons.dart';

class ResourceDetailsSheet extends ConsumerStatefulWidget {
  final Resource resource;

  const ResourceDetailsSheet({super.key, required this.resource});

  @override
  ConsumerState<ResourceDetailsSheet> createState() =>
      _ResourceDetailsSheetState();
}

class _ResourceDetailsSheetState extends ConsumerState<ResourceDetailsSheet> {
  int _selectedFileIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedFileIndex = widget.resource.primaryFileIndex;
  }

  void _downloadFile() async {
    final notifier = ref.read(resourceProvider.notifier);
    final file = widget.resource.files[_selectedFileIndex];

    final result = await notifier.downloadFile(
      resourceId: widget.resource.id,
      fileIndex: _selectedFileIndex,
      fileName: file.fileName,
      onProgress: (progress) {
        // Show progress dialog
      },
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloaded: ${file.fileName}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _previewFile() {
    final notifier = ref.read(resourceProvider.notifier);
    final file = widget.resource.files[_selectedFileIndex];

    if (file.isImage || file.isPdf) {
      // Show preview dialog
    } else {
      _downloadFile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final resource = widget.resource;
    final selectedFile = resource.files[_selectedFileIndex];

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // Header
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                pinned: true,
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeader(context, resource),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const Spacer(),
                          if (resource.files.length > 1)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_selectedFileIndex + 1}/${resource.files.length}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  resource.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            resource.category.icon,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            resource.category.displayName,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: resource.resourceType.color
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            FileTypeIcons.getIconForType(
                                                resource.resourceType),
                                            size: 14,
                                            color: resource.resourceType.color,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            resource.resourceType.displayName,
                                            style: TextStyle(
                                              color:
                                                  resource.resourceType.color,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (resource.isFeatured) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Iconsax.star1,
                                              size: 14,
                                              color: Colors.amber,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              'Featured',
                                              style: TextStyle(
                                                color: Colors.amber,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (resource.status != ResourceStatus.published)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: resource.status.color
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                resource.status.displayName,
                                style: TextStyle(
                                  color: resource.status.color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Description
                      if (resource.description != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              resource.description!,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),

                      // Selected File Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected File',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      selectedFile.isImage
                                          ? Iconsax.gallery
                                          : selectedFile.isPdf
                                              ? Iconsax.document
                                              : selectedFile.isVideo
                                                  ? Iconsax.video
                                                  : Iconsax.document_text,
                                      size: 20,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedFile.fileName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${selectedFile.formattedSize} • ${selectedFile.mimeType}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: _downloadFile,
                                  icon: const Icon(
                                    Iconsax.document_download,
                                    color: Colors.blue,
                                  ),
                                  tooltip: 'Download',
                                ),
                                if (selectedFile.isImage || selectedFile.isPdf)
                                  IconButton(
                                    onPressed: _previewFile,
                                    icon: const Icon(
                                      Iconsax.eye,
                                      color: Colors.green,
                                    ),
                                    tooltip: 'Preview',
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Files List (if multiple)
                      if (resource.files.length > 1)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'All Files',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: resource.files.length,
                                itemBuilder: (context, index) {
                                  final file = resource.files[index];
                                  final isSelected =
                                      index == _selectedFileIndex;
                                  final isPrimary =
                                      index == resource.primaryFileIndex;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 1),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.blue.withValues(alpha: 0.05)
                                          : Colors.white,
                                      border: isSelected
                                          ? Border.all(
                                              color: Colors.blue
                                                  .withValues(alpha: 0.3))
                                          : null,
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        setState(() {
                                          _selectedFileIndex = index;
                                        });
                                      },
                                      leading: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            file.isImage
                                                ? Iconsax.gallery
                                                : file.isPdf
                                                    ? Iconsax.document
                                                    : file.isVideo
                                                        ? Iconsax.video
                                                        : Iconsax.document_text,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              file.fileName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: isSelected
                                                    ? Colors.blue
                                                    : Colors.black87,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isPrimary)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  left: 8),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'Primary',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      subtitle: Text(
                                        file.formattedSize,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (file.isImage || file.isPdf)
                                            IconButton(
                                              onPressed: () {
                                                // Preview file
                                              },
                                              icon: Icon(
                                                Iconsax.eye,
                                                size: 18,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          IconButton(
                                            onPressed: () {
                                              // Download single file
                                            },
                                            icon: Icon(
                                              Iconsax.document_download,
                                              size: 18,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),

                      // Metadata
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 3,
                            children: [
                              _DetailItem(
                                icon: Iconsax.calendar,
                                label: 'Created',
                                value: _formatDate(resource.createdAt),
                              ),
                              _DetailItem(
                                icon: Iconsax.cloud_add,
                                label: 'Total Files',
                                value: '${resource.filesCount} files',
                              ),
                              _DetailItem(
                                icon: Iconsax.document_download,
                                label: 'Downloads',
                                value:
                                    '${resource.downloadStats.totalDownloads}',
                              ),
                              _DetailItem(
                                icon: Iconsax.user,
                                label: 'Unique Users',
                                value: '${resource.downloadStats.uniqueUsers}',
                              ),
                              _DetailItem(
                                icon: Iconsax.lock,
                                label: 'Access',
                                value: resource.accessLevel.displayName,
                                color: resource.accessLevel.color,
                              ),
                              _DetailItem(
                                icon: Iconsax.global,
                                label: 'Language',
                                value: resource.language.toUpperCase(),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Tags
                      if (resource.tags.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            const Text(
                              'Tags',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: resource.tags.map((tag) {
                                return Chip(
                                  label: Text(tag),
                                  backgroundColor: Colors.grey[100],
                                  labelStyle: const TextStyle(fontSize: 12),
                                  visualDensity: VisualDensity.compact,
                                );
                              }).toList(),
                            ),
                          ],
                        ),

                      // Bottom Spacing
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Resource resource) {
    final primaryFile = resource.primaryFile;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.withValues(alpha: 0.8),
            Colors.blue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          // Background Image
          if (primaryFile?.isImage == true)
            Positioned.fill(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  primaryFile!.thumbnailUrl ?? primaryFile.fileUrl,
                  fit: BoxFit.cover,
                  opacity: const AlwaysStoppedAnimation(0.3),
                ),
              ),
            ),

          // Overlay Content
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      resource.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (resource.description != null)
                      Text(
                        resource.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (color ?? Colors.blue).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color ?? Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color ?? Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
