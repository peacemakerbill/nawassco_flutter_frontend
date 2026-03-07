import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../models/resource_model.dart';
import '../../../utils/resources/file_type_icons.dart';

class ResourceListItem extends StatelessWidget {
  final Resource resource;
  final VoidCallback onTap;
  final Function(ResourceFile, int) onPreview;
  final bool showStatus;

  const ResourceListItem({
    super.key,
    required this.resource,
    required this.onTap,
    required this.onPreview,
    this.showStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryFile = resource.primaryFile;
    final isImage = primaryFile?.isImage == true;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
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
                  color: isImage ? Colors.transparent : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: isImage && primaryFile != null
                      ? Image.network(
                          primaryFile.thumbnailUrl ?? primaryFile.fileUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildIconPlaceholder(),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        )
                      : _buildIconPlaceholder(),
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
                        if (resource.isFeatured)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.amber),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Iconsax.star1,
                                    size: 10, color: Colors.amber),
                                SizedBox(width: 2),
                                Text(
                                  'Featured',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.amber,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (showStatus &&
                            resource.status != ResourceStatus.published)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  resource.status.color.withValues(alpha: 0.1),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Category
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
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),

                        // Type
                        Row(
                          children: [
                            Icon(
                              FileTypeIcons.getIconForType(
                                  resource.resourceType),
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              resource.resourceType.displayName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),

                        // Size
                        Row(
                          children: [
                            const Icon(Iconsax.document,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              resource.formattedTotalSize,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Downloads
                        Row(
                          children: [
                            const Icon(
                              Iconsax.document_download,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${resource.downloadStats.totalDownloads}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),

                        // Action Button
                        if (primaryFile != null)
                          InkWell(
                            onTap: () => onPreview(
                                primaryFile, resource.primaryFileIndex),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    primaryFile.isImage
                                        ? Iconsax.eye
                                        : Iconsax.document_download,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    primaryFile.isImage ? 'View' : 'Download',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
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

  Widget _buildIconPlaceholder() {
    return Center(
      child: Icon(
        FileTypeIcons.getIconForResource(resource),
        size: 28,
        color: Colors.grey[400],
      ),
    );
  }
}
