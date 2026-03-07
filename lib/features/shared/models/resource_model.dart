import 'package:flutter/material.dart';

// ================================
// ENUMS
// ================================
enum ResourceType {
  document,
  image,
  video,
  audio,
  archive,
  other;

  String get displayName {
    switch (this) {
      case ResourceType.document:
        return 'Document';
      case ResourceType.image:
        return 'Image';
      case ResourceType.video:
        return 'Video';
      case ResourceType.audio:
        return 'Audio';
      case ResourceType.archive:
        return 'Archive';
      case ResourceType.other:
        return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case ResourceType.document:
        return Colors.blue;
      case ResourceType.image:
        return Colors.green;
      case ResourceType.video:
        return Colors.purple;
      case ResourceType.audio:
        return Colors.orange;
      case ResourceType.archive:
        return Colors.brown;
      case ResourceType.other:
        return Colors.grey;
    }
  }

  bool get isImage => this == ResourceType.image;

  bool get isDocument => this == ResourceType.document;

  bool get isVideo => this == ResourceType.video;

  bool get isAudio => this == ResourceType.audio;
}

enum ResourceCategory {
  bills('Bills', Icons.receipt),
  gallery('Gallery', Icons.photo_library),
  statements('Statements', Icons.description),
  forms('Forms', Icons.assignment),
  policies('Policies', Icons.policy),
  reports('Reports', Icons.assessment),
  brochures('Brochures', Icons.menu_book),
  guides('Guides', Icons.directions),
  tariffs('Tariffs', Icons.attach_money),
  notices('Notices', Icons.notifications),
  certificates('Certificates', Icons.verified),
  contracts('Contracts', Icons.gavel),
  licenses('Licenses', Icons.card_membership),
  training('Training', Icons.school),
  marketing('Marketing', Icons.campaign),
  other('Other', Icons.category);

  final String displayName;
  final IconData icon;

  const ResourceCategory(this.displayName, this.icon);
}

enum ResourceStatus {
  draft('Draft', Colors.grey),
  published('Published', Colors.green),
  archived('Archived', Colors.orange),
  expired('Expired', Colors.red),
  deleted('Deleted', Colors.red);

  final String displayName;
  final Color color;

  const ResourceStatus(this.displayName, this.color);
}

enum AccessLevel {
  public('Public', Icons.public, Colors.blue),
  customer('Customer', Icons.person, Colors.green),
  staff('Staff', Icons.badge, Colors.purple),
  management('Management', Icons.manage_accounts, Colors.orange),
  admin('Admin', Icons.security, Colors.red);

  final String displayName;
  final IconData icon;
  final Color color;

  const AccessLevel(this.displayName, this.icon, this.color);
}

// ================================
// MODELS
// ================================
class ResourceFile {
  final String id;
  final String fileUrl;
  final String fileName;
  final int fileSize;
  final String mimeType;
  final String fileExtension;
  final String checksum;
  final String? thumbnailUrl;
  final int sortOrder;
  final String uploadedBy;
  final DateTime uploadedAt;
  final String? description;
  final bool isPrimary;

  ResourceFile({
    required this.id,
    required this.fileUrl,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.fileExtension,
    required this.checksum,
    this.thumbnailUrl,
    this.sortOrder = 0,
    required this.uploadedBy,
    required this.uploadedAt,
    this.description,
    this.isPrimary = false,
  });

  factory ResourceFile.fromMap(Map<String, dynamic> map) {
    return ResourceFile(
      id: map['_id'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileName: map['fileName'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      mimeType: map['mimeType'] ?? '',
      fileExtension: map['fileExtension'] ?? '',
      checksum: map['checksum'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      sortOrder: map['sortOrder'] ?? 0,
      uploadedBy: map['uploadedBy'] is Map
          ? map['uploadedBy']['_id'] ?? ''
          : map['uploadedBy']?.toString() ?? '',
      uploadedAt:
      DateTime.parse(map['uploadedAt'] ?? DateTime.now().toIso8601String()),
      description: map['description'],
      isPrimary: map['isPrimary'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'fileExtension': fileExtension,
      'checksum': checksum,
      'thumbnailUrl': thumbnailUrl,
      'sortOrder': sortOrder,
      'description': description,
      'isPrimary': isPrimary,
    };
  }

  bool get isImage => mimeType.startsWith('image/');

  bool get isPdf => mimeType == 'application/pdf';

  bool get isVideo => mimeType.startsWith('video/');

  bool get isAudio => mimeType.startsWith('audio/');

  bool get isDocument =>
      mimeType.contains('document') ||
          mimeType.contains('text') ||
          fileExtension.toLowerCase() == 'pdf' ||
          fileExtension.toLowerCase() == 'doc' ||
          fileExtension.toLowerCase() == 'docx';

  String get formattedSize {
    if (fileSize < 1024) return '${fileSize} B';
    if (fileSize < 1048576) return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    if (fileSize < 1073741824)
      return '${(fileSize / 1048576).toStringAsFixed(2)} MB';
    return '${(fileSize / 1073741824).toStringAsFixed(2)} GB';
  }
}

class ResourceVersion {
  final int version;
  final List<ResourceFile> files;
  final String uploadedBy;
  final DateTime uploadedAt;
  final String? changeDescription;

  ResourceVersion({
    required this.version,
    required this.files,
    required this.uploadedBy,
    required this.uploadedAt,
    this.changeDescription,
  });

  factory ResourceVersion.fromMap(Map<String, dynamic> map) {
    return ResourceVersion(
      version: map['version'] ?? 1,
      files: List<ResourceFile>.from(
        (map['files'] as List<dynamic>).map((x) => ResourceFile.fromMap(x)),
      ),
      uploadedBy: map['uploadedBy'] is Map
          ? map['uploadedBy']['_id'] ?? ''
          : map['uploadedBy']?.toString() ?? '',
      uploadedAt:
      DateTime.parse(map['uploadedAt'] ?? DateTime.now().toIso8601String()),
      changeDescription: map['changeDescription'],
    );
  }
}

class DownloadStats {
  final int totalDownloads;
  final int uniqueUsers;
  final DateTime? lastDownloadedAt;
  final Map<String, int> userDownloads;

  DownloadStats({
    required this.totalDownloads,
    required this.uniqueUsers,
    this.lastDownloadedAt,
    required this.userDownloads,
  });

  factory DownloadStats.fromMap(Map<String, dynamic> map) {
    return DownloadStats(
      totalDownloads: map['totalDownloads'] ?? 0,
      uniqueUsers: map['uniqueUsers'] ?? 0,
      lastDownloadedAt: map['lastDownloadedAt'] != null
          ? DateTime.parse(map['lastDownloadedAt'])
          : null,
      userDownloads: Map<String, int>.from(map['userDownloads'] ?? {}),
    );
  }
}

class Resource {
  final String id;
  final String title;
  final String? description;
  final ResourceType resourceType;
  final ResourceCategory category;
  final ResourceStatus status;
  final List<ResourceFile> files;
  final int primaryFileIndex;
  final AccessLevel accessLevel;
  final List<String> allowedRoles;
  final List<String>? allowedServiceZones;
  final bool isFeatured;
  final bool requiresAuth;
  final List<String> tags;
  final List<String> keywords;
  final String language;
  final int version;
  final List<ResourceVersion> versions;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final DateTime? publishAt;
  final DateTime? unpublishAt;
  final DownloadStats downloadStats;
  final String slug;
  final String? metaTitle;
  final String? metaDescription;
  final int sortOrder;
  final String uploadedBy;
  final String updatedBy;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final DateTime? archivedAt;

  Resource({
    required this.id,
    required this.title,
    this.description,
    required this.resourceType,
    required this.category,
    required this.status,
    required this.files,
    required this.primaryFileIndex,
    required this.accessLevel,
    required this.allowedRoles,
    this.allowedServiceZones,
    required this.isFeatured,
    required this.requiresAuth,
    required this.tags,
    required this.keywords,
    required this.language,
    required this.version,
    required this.versions,
    this.validFrom,
    this.validUntil,
    this.publishAt,
    this.unpublishAt,
    required this.downloadStats,
    required this.slug,
    this.metaTitle,
    this.metaDescription,
    required this.sortOrder,
    required this.uploadedBy,
    required this.updatedBy,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    this.archivedAt,
  });

  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      id: map['_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      resourceType: ResourceType.values.firstWhere(
            (e) => e.name == (map['resourceType'] ?? 'document'),
        orElse: () => ResourceType.document,
      ),
      category: ResourceCategory.values.firstWhere(
            (e) => e.name == (map['category'] ?? 'other'),
        orElse: () => ResourceCategory.other,
      ),
      status: ResourceStatus.values.firstWhere(
            (e) => e.name == (map['status'] ?? 'draft'),
        orElse: () => ResourceStatus.draft,
      ),
      files: List<ResourceFile>.from(
        (map['files'] as List<dynamic>).map((x) => ResourceFile.fromMap(x)),
      ),
      primaryFileIndex: map['primaryFileIndex'] ?? 0,
      accessLevel: AccessLevel.values.firstWhere(
            (e) => e.name == (map['accessLevel'] ?? 'public'),
        orElse: () => AccessLevel.public,
      ),
      allowedRoles: List<String>.from(map['allowedRoles'] ?? []),
      allowedServiceZones: map['allowedServiceZones'] != null
          ? List<String>.from(map['allowedServiceZones'])
          : null,
      isFeatured: map['isFeatured'] ?? false,
      requiresAuth: map['requiresAuth'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
      keywords: List<String>.from(map['keywords'] ?? []),
      language: map['language'] ?? 'en',
      version: map['version'] ?? 1,
      versions: List<ResourceVersion>.from(
        (map['versions'] as List<dynamic>)
            .map((x) => ResourceVersion.fromMap(x)),
      ),
      validFrom:
      map['validFrom'] != null ? DateTime.parse(map['validFrom']) : null,
      validUntil:
      map['validUntil'] != null ? DateTime.parse(map['validUntil']) : null,
      publishAt:
      map['publishAt'] != null ? DateTime.parse(map['publishAt']) : null,
      unpublishAt: map['unpublishAt'] != null
          ? DateTime.parse(map['unpublishAt'])
          : null,
      downloadStats: DownloadStats.fromMap(map['downloadStats'] ?? {}),
      slug: map['slug'] ?? '',
      metaTitle: map['metaTitle'],
      metaDescription: map['metaDescription'],
      sortOrder: map['sortOrder'] ?? 0,
      uploadedBy: map['uploadedBy'] is Map
          ? map['uploadedBy']['_id'] ?? ''
          : map['uploadedBy']?.toString() ?? '',
      updatedBy: map['updatedBy'] is Map
          ? map['updatedBy']['_id'] ?? ''
          : map['updatedBy']?.toString() ?? '',
      reviewedBy: map['reviewedBy'] != null
          ? map['reviewedBy'] is Map
          ? map['reviewedBy']['_id'] ?? ''
          : map['reviewedBy']?.toString()
          : null,
      reviewedAt:
      map['reviewedAt'] != null ? DateTime.parse(map['reviewedAt']) : null,
      createdAt:
      DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
      DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      publishedAt: map['publishedAt'] != null
          ? DateTime.parse(map['publishedAt'])
          : null,
      archivedAt:
      map['archivedAt'] != null ? DateTime.parse(map['archivedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'resourceType': resourceType.name,
      'category': category.name,
      'files': files.map((x) => x.toMap()).toList(),
      'accessLevel': accessLevel.name,
      'allowedRoles': allowedRoles,
      'allowedServiceZones': allowedServiceZones,
      'tags': tags,
      'keywords': keywords,
      'language': language,
      'validFrom': validFrom?.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
      'publishAt': publishAt?.toIso8601String(),
      'unpublishAt': unpublishAt?.toIso8601String(),
      'isFeatured': isFeatured,
      'requiresAuth': requiresAuth,
      'metaTitle': metaTitle,
      'metaDescription': metaDescription,
      'sortOrder': sortOrder,
      'primaryFileIndex': primaryFileIndex,
    };
  }

  ResourceFile? get primaryFile =>
      files.isEmpty ? null : files[primaryFileIndex.clamp(0, files.length - 1)];

  String get formattedTotalSize {
    final totalSize = files.fold<int>(0, (sum, file) => sum + file.fileSize);
    if (totalSize < 1024) return '${totalSize} B';
    if (totalSize < 1048576)
      return '${(totalSize / 1024).toStringAsFixed(2)} KB';
    if (totalSize < 1073741824)
      return '${(totalSize / 1048576).toStringAsFixed(2)} MB';
    return '${(totalSize / 1073741824).toStringAsFixed(2)} GB';
  }

  int get filesCount => files.length;

  bool get isPublished => status == ResourceStatus.published;

  bool get isExpired =>
      validUntil != null && DateTime.now().isAfter(validUntil!);

  bool get isScheduled =>
      publishAt != null && DateTime.now().isBefore(publishAt!);

  bool canUserAccess(List<String> userRoles, String? serviceZone) {
    if (accessLevel == AccessLevel.public && !requiresAuth) {
      return true;
    }

    if (allowedRoles.isNotEmpty) {
      final hasAllowedRole =
      userRoles.any((role) => allowedRoles.contains(role));
      if (!hasAllowedRole) return false;
    }

    if (allowedServiceZones != null &&
        allowedServiceZones!.isNotEmpty &&
        serviceZone != null) {
      if (!allowedServiceZones!.contains(serviceZone)) {
        return false;
      }
    }

    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Resource && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}