import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.radius = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: theme.colorScheme.surfaceVariant,
        backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImageProvider(imageUrl!)
            : null,
        child: imageUrl == null || imageUrl!.isEmpty
            ? Icon(
          Icons.person_rounded,
          size: radius * 0.8,
          color: theme.colorScheme.onSurfaceVariant,
        )
            : null,
      ),
    );
  }
}