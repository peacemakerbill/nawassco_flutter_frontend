import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/contract_provider.dart';


class ContractDetailScreen extends ConsumerWidget {
  final String contractId;

  const ContractDetailScreen({super.key, required this.contractId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractAsync = ref.watch(contractProvider(contractId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contract Details'),
      ),
      body: contractAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(contractProvider(contractId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (contract) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailCard('Basic Information', [
                  _buildDetailRow('Contract Number', contract.contractNumber),
                  _buildDetailRow('Title', contract.title),
                  _buildDetailRow('Description', contract.description ?? 'N/A'),
                  _buildDetailRow('Type', contract.type),
                  _buildDetailRow('Category', contract.category ?? 'N/A'),
                  _buildDetailRow('Status', contract.status),
                ]),
                _buildDetailCard('Dates', [
                  _buildDetailRow('Start Date', _formatDate(contract.startDate)),
                  _buildDetailRow('End Date', _formatDate(contract.endDate)),
                  _buildDetailRow('Created', _formatDate(contract.createdAt)),
                  _buildDetailRow('Last Updated', _formatDate(contract.updatedAt)),
                ]),
                _buildDetailCard('Financial Information', [
                  _buildDetailRow('Contract Value', '${contract.currency} ${contract.contractValue.toStringAsFixed(2)}'),
                  _buildDetailRow('Renewable', contract.renewable ? 'Yes' : 'No'),
                  if (contract.renewable) ...[
                    _buildDetailRow('Renewal Count', '${contract.renewalCount}/${contract.maxRenewals}'),
                    _buildDetailRow('Renewal Allowed', contract.renewalAllowed ? 'Yes' : 'No'),
                  ],
                ]),
                _buildDetailCard('Parties', [
                  _buildDetailRow('Supplier', contract.supplierName),
                  _buildDetailRow('Procurement Officer', contract.procurementOfficerName ?? 'N/A'),
                  _buildDetailRow('Signatory', contract.signatoryName ?? 'N/A'),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}