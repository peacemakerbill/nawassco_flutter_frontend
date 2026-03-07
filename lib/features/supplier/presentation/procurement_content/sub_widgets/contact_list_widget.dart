import 'package:flutter/material.dart';
import '../../../models/supplier_contact_model.dart';

class ContactListWidget extends StatelessWidget {
  final List<SupplierContact> contacts;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;
  final Function(SupplierContact) onEdit;
  final Function(SupplierContact) onDelete;
  final Function(SupplierContact) onSetPrimary;

  const ContactListWidget({
    super.key,
    required this.contacts,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (contacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.contacts, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No contacts found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contacts.length,
        itemBuilder: (context, index) => _buildContactCard(contacts[index]),
      ),
    );
  }

  Widget _buildContactCard(SupplierContact contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF0066A1),
                  child: Text(
                    '${contact.firstName[0]}${contact.lastName[0]}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${contact.firstName} ${contact.lastName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        contact.position,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (contact.isPrimary) _buildPrimaryBadge(),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(contact.department),
                  backgroundColor: Colors.blue[50],
                ),
                Chip(
                  label: Text(contact.preferredContactMethod),
                  backgroundColor: Colors.green[50],
                ),
                if (contact.isAuthorizedSignatory)
                  const Chip(
                    label: Text('Authorized Signatory'),
                    backgroundColor: Colors.orange,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                if (contact.canSubmitBids)
                  Chip(
                    label: const Text('Can Submit Bids'),
                    backgroundColor: Colors.purple[50],
                  ),
                if (contact.receiveTenderNotifications)
                  Chip(
                    label: const Text('Receives Tenders'),
                    backgroundColor: Colors.teal[50],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📧 ${contact.email}'),
                      Text('📞 ${contact.phone}'),
                      if (contact.mobile.isNotEmpty) Text('📱 ${contact.mobile}'),
                    ],
                  ),
                ),
                _buildActionButtons(contact),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 14, color: Colors.green),
          SizedBox(width: 4),
          Text(
            'Primary',
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(SupplierContact contact) {
    return Row(
      children: [
        if (!contact.isPrimary)
          IconButton(
            onPressed: () => onSetPrimary(contact),
            icon: const Icon(Icons.star_border, size: 20),
            tooltip: 'Set as Primary',
          ),
        IconButton(
          onPressed: () => onEdit(contact),
          icon: const Icon(Icons.edit, size: 20),
          tooltip: 'Edit',
        ),
        IconButton(
          onPressed: () => onDelete(contact),
          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
          tooltip: 'Delete',
        ),
      ],
    );
  }
}