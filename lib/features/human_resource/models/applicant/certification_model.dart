class CertificationModel {
  final String? id;
  final String name;
  final String issuingAuthority;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String? credentialId;
  final String? credentialUrl;
  final bool isVerified;

  CertificationModel({
    this.id,
    required this.name,
    required this.issuingAuthority,
    required this.issueDate,
    this.expiryDate,
    this.credentialId,
    this.credentialUrl,
    this.isVerified = false,
  });

  factory CertificationModel.fromJson(Map<String, dynamic> json) {
    return CertificationModel(
      id: json['_id'],
      name: json['name'],
      issuingAuthority: json['issuingAuthority'],
      issueDate: DateTime.parse(json['issueDate']),
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      credentialId: json['credentialId'],
      credentialUrl: json['credentialUrl'],
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'issuingAuthority': issuingAuthority,
      'issueDate': issueDate.toIso8601String(),
      if (expiryDate != null) 'expiryDate': expiryDate!.toIso8601String(),
      if (credentialId != null) 'credentialId': credentialId,
      if (credentialUrl != null) 'credentialUrl': credentialUrl,
      'isVerified': isVerified,
    };
  }
}