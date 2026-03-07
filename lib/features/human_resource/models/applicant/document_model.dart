class DocumentModel {
  final String? id;
  final String name;
  final String type;
  final String url;
  final DateTime uploadDate;
  final bool isPrimary;
  final int fileSize;
  final String? description;

  DocumentModel({
    this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.uploadDate,
    required this.isPrimary,
    required this.fileSize,
    this.description,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['_id'],
      name: json['name'],
      type: json['type'],
      url: json['url'],
      uploadDate: DateTime.parse(json['uploadDate']),
      isPrimary: json['isPrimary'] ?? false,
      fileSize: json['fileSize'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'type': type,
      'url': url,
      'uploadDate': uploadDate.toIso8601String(),
      'isPrimary': isPrimary,
      'fileSize': fileSize,
      if (description != null) 'description': description,
    };
  }
}