import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../models/training.model.dart';
import '../../../../../providers/training.provider.dart';

class CertificateUpload extends ConsumerStatefulWidget {
  final Training training;

  const CertificateUpload({super.key, required this.training});

  @override
  ConsumerState<CertificateUpload> createState() => _CertificateUploadState();
}

class _CertificateUploadState extends ConsumerState<CertificateUpload> {
  final ImagePicker _picker = ImagePicker();
  final Map<String, XFile?> _selectedCertificates = {};
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with participants who don't have certificates
    for (final participant in widget.training.participants) {
      if (participant.certificateUrl == null) {
        _selectedCertificates[participant.id] = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final participants = widget.training.participants;
    final pendingParticipants = participants.where((p) => p.certificateUrl == null).toList();
    final completedParticipants = participants.where((p) => p.certificateUrl != null).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Certificates'),
        actions: [
          if (_selectedCertificates.values.any((file) => file != null) && !_isUploading)
            IconButton(
              icon: const Icon(Icons.upload),
              onPressed: _uploadCertificates,
              tooltip: 'Upload Selected Certificates',
            ),
        ],
      ),
      body: Column(
        children: [
          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              border: Border(bottom: BorderSide(color: Colors.purple.shade100)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', participants.length.toString(), Colors.purple),
                _buildStatItem('Pending', pendingParticipants.length.toString(), Colors.orange),
                _buildStatItem('Issued', completedParticipants.length.toString(), Colors.green),
              ],
            ),
          ),

          // Upload progress
          if (_isUploading)
            const LinearProgressIndicator(),

          // Tab view
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: const [
                      Tab(text: 'Pending Certificates'),
                      Tab(text: 'Issued Certificates'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Pending tab
                        pendingParticipants.isEmpty
                            ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment_turned_in, size: 64, color: Colors.green),
                              SizedBox(height: 16),
                              Text(
                                'All certificates have been issued!',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                            : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: pendingParticipants.length,
                          itemBuilder: (context, index) {
                            final participant = pendingParticipants[index];
                            return _buildPendingCertificateCard(participant);
                          },
                        ),

                        // Issued tab
                        completedParticipants.isEmpty
                            ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment_late, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No certificates issued yet',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                            : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: completedParticipants.length,
                          itemBuilder: (context, index) {
                            final participant = completedParticipants[index];
                            return _buildIssuedCertificateCard(participant);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingCertificateCard(TrainingParticipant participant) {
    final selectedFile = _selectedCertificates[participant.id];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange.shade50,
                  child: Text(
                    participant.employeeName[0],
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participant.employeeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        participant.employeeNumber,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      Text(
                        participant.department,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(participant.statusText),
                  backgroundColor: participant.statusColor.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: participant.statusColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // File selection
            if (selectedFile == null)
              ElevatedButton.icon(
                onPressed: () => _selectCertificate(participant.id),
                icon: const Icon(Icons.attach_file),
                label: const Text('Select Certificate'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected: ${selectedFile.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectCertificate(participant.id),
                          icon: const Icon(Icons.change_circle),
                          label: const Text('Change File'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _uploadSingleCertificate(participant.id, selectedFile),
                          icon: const Icon(Icons.upload),
                          label: const Text('Upload'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssuedCertificateCard(TrainingParticipant participant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.verified, color: Colors.green),
        ),
        title: Text(participant.employeeName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(participant.employeeNumber),
            Text(
              'Status: ${participant.statusText}',
              style: TextStyle(
                color: participant.statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: () => _viewCertificate(participant.certificateUrl!),
              tooltip: 'View Certificate',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteCertificate(participant.id),
              tooltip: 'Delete Certificate',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectCertificate(String participantId) async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (file != null) {
      setState(() {
        _selectedCertificates[participantId] = file;
      });
    }
  }

  Future<void> _uploadSingleCertificate(String participantId, XFile file) async {
    setState(() => _isUploading = true);

    final participant = widget.training.participants.firstWhere((p) => p.id == participantId);
    final success = await ref.read(trainingProvider.notifier).uploadCertificate(
      widget.training.id,
      participant.employeeId,
      file,
    );

    setState(() {
      _isUploading = false;
      if (success) {
        _selectedCertificates.remove(participantId);
      }
    });
  }

  Future<void> _uploadCertificates() async {
    setState(() => _isUploading = true);

    for (final entry in _selectedCertificates.entries) {
      final participantId = entry.key;
      final file = entry.value;

      if (file != null) {
        final participant = widget.training.participants.firstWhere((p) => p.id == participantId);
        await ref.read(trainingProvider.notifier).uploadCertificate(
          widget.training.id,
          participant.employeeId,
          file,
        );
      }
    }

    setState(() {
      _isUploading = false;
      _selectedCertificates.clear();
      // Re-initialize for remaining pending certificates
      for (final participant in widget.training.participants) {
        if (participant.certificateUrl == null) {
          _selectedCertificates[participant.id] = null;
        }
      }
    });
  }

  Future<void> _viewCertificate(String certificateUrl) async {
    // Implement certificate viewing logic
    // This could open the certificate in a PDF viewer or web view
  }

  Future<void> _deleteCertificate(String participantId) async {
    // Implement certificate deletion logic
    // This would call the backend API
  }
}