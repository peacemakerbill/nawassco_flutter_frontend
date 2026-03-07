import 'package:flutter/material.dart';

class TenderDetailsWidget extends StatelessWidget {
  const TenderDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final tender = {
      'id': 'TDR-2024-001',
      'title': 'Water Pipe Supply - 6 inch HDPE',
      'description': 'Supply of high-density polyethylene pipes (6 inch diameter) for the Nakuru Water Distribution Network Expansion Project. The pipes must meet KS ISO 4427 standards and be suitable for potable water distribution.',
      'deadline': '2024-03-15',
      'openingDate': '2024-03-18',
      'value': 'KES 2,500,000',
      'category': 'Pipes & Fittings',
      'status': 'Open',
      'documents': ['Tender Notice.pdf', 'Technical Specifications.pdf', 'Bill of Quantities.xlsx', 'Terms and Conditions.pdf'],
      'requirements': [
        'Valid business registration certificate',
        'KRA PIN certificate',
        'Tax compliance certificate',
        'NCA registration (if applicable)',
        'Company profile with similar projects',
      ],
    };

    // Cast lists to their proper types
    final List<String> documents = tender['documents'] as List<String>;
    final List<String> requirements = tender['requirements'] as List<String>;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          tender['title'] as String,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0066A1),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0066A1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tender['status'] as String,
                          style: const TextStyle(
                            color: Color(0xFF0066A1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tender['description'] as String,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tender Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Tender ID', tender['id'] as String),
                  _buildInfoRow('Category', tender['category'] as String),
                  _buildInfoRow('Estimated Value', tender['value'] as String),
                  _buildInfoRow('Submission Deadline', tender['deadline'] as String),
                  _buildInfoRow('Bid Opening Date', tender['openingDate'] as String),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Required Documents',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...requirements.map((req) => _buildRequirementItem(req)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tender Documents',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...documents.map((doc) => _buildDocumentItem(doc)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 500;
              return isMobile
                  ? Column(
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0066A1),
                      side: const BorderSide(color: Color(0xFF0066A1)),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('DOWNLOAD DOCUMENTS'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066A1),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('SUBMIT QUOTATION'),
                  ),
                ],
              )
                  : Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0066A1),
                        side: const BorderSide(color: Color(0xFF0066A1)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('DOWNLOAD DOCUMENTS'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066A1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('SUBMIT QUOTATION'),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 500;
          return isMobile
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          )
              : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 150,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRequirementItem(String requirement) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Color(0xFF0066A1), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              requirement,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String document) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.picture_as_pdf, color: Colors.red[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              document,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download, size: 20),
            onPressed: () {},
            color: const Color(0xFF0066A1),
          ),
        ],
      ),
    );
  }
}