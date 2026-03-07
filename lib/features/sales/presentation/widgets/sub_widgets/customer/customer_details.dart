import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/customer.model.dart';
import '../../../../providers/customer_provider.dart';
import 'address_form.dart';
import 'contact_person_form.dart';
import 'service_form.dart';

class CustomerDetails extends ConsumerWidget {
  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onClose;

  const CustomerDetails({
    super.key,
    required this.customer,
    required this.onEdit,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(customer.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
            tooltip: 'Edit Customer',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
            tooltip: 'Close',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(context),
              const SizedBox(height: 24),
              _buildOverviewSection(context),
              const SizedBox(height: 24),
              _buildContactSection(context, ref),
              const SizedBox(height: 24),
              _buildBillingSection(context),
              const SizedBox(height: 24),
              _buildServicesSection(context, ref),
              const SizedBox(height: 24),
              _buildMetersSection(context),
              const SizedBox(height: 24),
              _buildDocumentsSection(context),
              const SizedBox(height: 24),
              _buildQuickActions(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getCustomerColor(customer.customerType)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _getCustomerColor(customer.customerType),
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    _getCustomerIcon(customer.customerType),
                    color: _getCustomerColor(customer.customerType),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.displayName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer.customerNumber,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(customer.status)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getStatusColor(customer.status),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        customer.status.displayName,
                        style: TextStyle(
                          color: _getStatusColor(customer.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: customer.hasOverdueBalance
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: customer.hasOverdueBalance
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                      child: Text(
                        customer.formattedBalance,
                        style: TextStyle(
                          color: customer.hasOverdueBalance
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip(
                  customer.customerType.displayName,
                  _getCustomerColor(customer.customerType),
                ),
                _buildChip(
                  customer.customerSegment.displayName,
                  Colors.deepPurple,
                ),
                _buildChip(
                  'Priority: ${customer.priorityLevel.displayName}',
                  _getPriorityColor(customer.priorityLevel),
                ),
                if (customer.isCommercial) _buildChip('Business', Colors.blue),
                if (customer.isGovernment) _buildChip('Government', Colors.red),
                if (customer.isIndustrial) _buildChip('Industrial', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: constraints.maxWidth < 600 ? 1.5 : 2,
                  children: [
                    _buildStatCard(
                      context,
                      'Active Services',
                      '${customer.activeServices.length}',
                      Icons.plumbing_outlined,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      context,
                      'Active Meters',
                      '${customer.activeMeters.length}',
                      Icons.speed_outlined,
                      Colors.green,
                    ),
                    _buildStatCard(
                      context,
                      'Credit Limit',
                      'KES ${customer.creditLimit.toStringAsFixed(0)}',
                      Icons.credit_card_outlined,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      context,
                      'Customer Since',
                      DateFormat('MMM yyyy').format(customer.customerSince),
                      Icons.calendar_today_outlined,
                      Colors.purple,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            if (customer.connectionDetails.previousProvider != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Previous Provider: ${customer.connectionDetails.previousProvider!}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Contact Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showAddAddressDialog(context, ref),
                  tooltip: 'Add Address',
                ),
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () => _showAddContactDialog(context, ref),
                  tooltip: 'Add Contact Person',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Primary Contact
            if (customer.primaryContact != null) ...[
              _buildContactCard(
                context,
                customer.primaryContact!,
                isPrimary: true,
              ),
              const SizedBox(height: 12),
            ],

            // Addresses
            if (customer.addresses.isNotEmpty) ...[
              Text(
                'Addresses',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...customer.addresses.map((address) => _buildAddressCard(
                context,
                address,
              )),
              const SizedBox(height: 16),
            ],

            // Contact Persons
            if (customer.contactPersons.isNotEmpty) ...[
              Text(
                'Additional Contacts',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...customer.contactPersons
                  .where((contact) => !contact.isPrimary)
                  .map((contact) => _buildContactCard(
                context,
                contact,
                isPrimary: false,
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBillingSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Billing & Payment',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 600 ? 2 : 3;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: constraints.maxWidth < 600 ? 1.8 : 2.2,
                  children: [
                    _buildInfoTile(
                      context,
                      'Billing Cycle',
                      customer.billingInformation.billingCycle.displayName,
                      Icons.calendar_view_month_outlined,
                    ),
                    _buildInfoTile(
                      context,
                      'Invoice Delivery',
                      customer.billingInformation.invoiceDelivery.displayName,
                      Icons.email_outlined,
                    ),
                    _buildInfoTile(
                      context,
                      'Payment Method',
                      customer.billingInformation.paymentMethod.displayName,
                      Icons.payment_outlined,
                    ),
                    _buildInfoTile(
                      context,
                      'Net Days',
                      '${customer.paymentTerms.netDays} days',
                      Icons.timer_outlined,
                    ),
                    _buildInfoTile(
                      context,
                      'Late Fee',
                      'KES ${customer.paymentTerms.latePaymentFee}',
                      Icons.money_off_outlined,
                    ),
                    if (customer.billingInformation.bankDetails != null)
                      _buildInfoTile(
                        context,
                        'Bank',
                        customer.billingInformation.bankDetails!.bankName ?? '',
                        Icons.account_balance_outlined,
                      ),
                  ],
                );
              },
            ),

            if (customer.paymentTerms.discountDays != null &&
                customer.paymentTerms.discountPercentage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.discount_outlined, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Discount: ${customer.paymentTerms.discountPercentage}% '
                            'if paid within ${customer.paymentTerms.discountDays} days',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Services',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showAddServiceDialog(context, ref),
                  tooltip: 'Add Service',
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (customer.services.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.plumbing_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No services added',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add services to track water supply and sanitation',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...customer.services.map((service) => _buildServiceCard(
                context,
                service,
                onEdit: () => _showEditServiceDialog(context, ref, service),
                onDelete: () => _showDeleteServiceDialog(context, ref, service),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildMetersSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meters',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (customer.meters.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.speed_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No meters installed',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Install meters to track water consumption',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: customer.meters.map((meter) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildMeterCard(context, meter),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documents',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (customer.documents.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No documents uploaded',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...customer.documents.map((doc) => _buildDocumentCard(
                context,
                doc,
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.email_outlined, size: 18),
                  label: const Text('Send Invoice'),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.phone_outlined, size: 18),
                  label: const Text('Call Customer'),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.message_outlined, size: 18),
                  label: const Text('Send SMS'),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.receipt_outlined, size: 18),
                  label: const Text('Generate Report'),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.print_outlined, size: 18),
                  label: const Text('Print Details'),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Share'),
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Customer'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showDeleteDialog(context, ref);
                },
                icon: const Icon(Icons.delete_outlined),
                label: const Text('Delete Customer'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
      BuildContext context,
      ContactPerson contact,
      {required bool isPrimary}
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isPrimary
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPrimary
              ? Theme.of(context).primaryColor
              : Colors.transparent,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isPrimary
                ? Theme.of(context).primaryColor
                : Theme.of(context).colorScheme.onSurfaceVariant,
            child: Text(
              contact.firstName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
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
                  '${contact.salutation} ${contact.firstName} ${contact.lastName}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  contact.position,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (contact.department != null)
                  Text(
                    contact.department!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                Row(
                  children: [
                    Icon(Icons.email_outlined, size: 12),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        contact.email,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      contact.phone,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isPrimary)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Primary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, CustomerAddress address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: address.isPrimary
            ? Colors.blue.withOpacity(0.1)
            : Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: address.isPrimary ? Colors.blue : Colors.transparent,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getAddressIcon(address.type),
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                address.type.displayName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (address.isPrimary)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Primary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(address.addressLine1),
          if (address.addressLine2 != null) Text(address.addressLine2!),
          Text('${address.city}, ${address.state} ${address.postalCode}'),
          Text(address.country),
          if (address.coordinates != null && address.coordinates!.latitude != null && address.coordinates!.longitude != null)
            Text(
              'Coordinates: ${address.coordinates!.latitude}, ${address.coordinates!.longitude}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
      BuildContext context,
      CustomerService service,
      {VoidCallback? onEdit, VoidCallback? onDelete}
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _getServiceStatusColor(service.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getServiceStatusColor(service.status),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getServiceIcon(service.serviceType),
                size: 20,
                color: _getServiceStatusColor(service.status),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.serviceType.displayName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Service #${service.serviceNumber}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getServiceStatusColor(service.status),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  service.status.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onEdit != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  onPressed: onEdit,
                ),
              ],
              if (onDelete != null) ...[
                IconButton(
                  icon: const Icon(Icons.delete_outlined, size: 16, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tariff: ${service.tariff}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Monthly Estimate: KES ${service.monthlyEstimate.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Start Date: ${DateFormat('MMM dd, yyyy').format(service.startDate)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (service.lastReadingDate != null)
                      Text(
                        'Last Reading: ${service.lastReading} on ${DateFormat('MMM dd, yyyy').format(service.lastReadingDate!)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tariff: ${service.tariff}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            'Monthly Estimate: KES ${service.monthlyEstimate.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Date: ${DateFormat('MMM dd, yyyy').format(service.startDate)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (service.lastReadingDate != null)
                            Text(
                              'Last Reading: ${service.lastReading} on ${DateFormat('MMM dd, yyyy').format(service.lastReadingDate!)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMeterCard(BuildContext context, CustomerMeter meter) {
    return Container(
      decoration: BoxDecoration(
        color: _getMeterStatusColor(meter.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getMeterStatusColor(meter.status),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            Icons.speed_outlined,
            size: 24,
            color: _getMeterStatusColor(meter.status),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meter #${meter.meterNumber}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Type: ${meter.meterType}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Location: ${meter.location}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getMeterStatusColor(meter.status),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  meter.status.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Reading: ${meter.currentReading ?? meter.initialReading}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, CustomerDocument doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            Icons.description_outlined,
            size: 24,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.documentName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Type: ${doc.documentType.displayName}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Uploaded: ${DateFormat('MMM dd, yyyy').format(doc.uploadDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getDocumentStatusColor(doc.status),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              doc.status.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  IconData _getAddressIcon(AddressType type) {
    return switch (type) {
      AddressType.billing => Icons.receipt_outlined,
      AddressType.service => Icons.plumbing_outlined,
      AddressType.mailing => Icons.mail_outlined,
      AddressType.physical => Icons.location_on_outlined,
    };
  }

  IconData _getServiceIcon(ServiceType type) {
    return switch (type) {
      ServiceType.water_supply => Icons.water_drop_outlined,
      ServiceType.sanitation => Icons.clean_hands_outlined,
      ServiceType.bulk_water => Icons.local_shipping_outlined,
      ServiceType.metered => Icons.speed_outlined,
      ServiceType.unmetered => Icons.water_outlined,
    };
  }

  Color _getServiceStatusColor(ServiceStatus status) {
    return switch (status) {
      ServiceStatus.active => Colors.green,
      ServiceStatus.pending => Colors.orange,
      ServiceStatus.suspended => Colors.red,
      ServiceStatus.disconnected => Colors.grey,
      ServiceStatus.closed => Colors.black,
    };
  }

  Color _getMeterStatusColor(MeterStatus status) {
    return switch (status) {
      MeterStatus.active => Colors.green,
      MeterStatus.inactive => Colors.grey,
      MeterStatus.faulty => Colors.red,
      MeterStatus.removed => Colors.black,
      MeterStatus.under_maintenance => Colors.orange,
    };
  }

  Color _getDocumentStatusColor(DocumentStatus status) {
    return switch (status) {
      DocumentStatus.pending => Colors.orange,
      DocumentStatus.verified => Colors.green,
      DocumentStatus.rejected => Colors.red,
      DocumentStatus.expired => Colors.grey,
    };
  }

  Color _getCustomerColor(CustomerType type) {
    return switch (type) {
      CustomerType.residential => const Color(0xFF2196F3),
      CustomerType.commercial => const Color(0xFF4CAF50),
      CustomerType.industrial => const Color(0xFFFF9800),
      CustomerType.institutional => const Color(0xFF9C27B0),
      CustomerType.government => const Color(0xFFF44336),
    };
  }

  IconData _getCustomerIcon(CustomerType type) {
    return switch (type) {
      CustomerType.residential => Icons.home_outlined,
      CustomerType.commercial => Icons.business_outlined,
      CustomerType.industrial => Icons.factory_outlined,
      CustomerType.institutional => Icons.school_outlined,
      CustomerType.government => Icons.account_balance_outlined,
    };
  }

  Color _getStatusColor(CustomerStatus status) {
    return switch (status) {
      CustomerStatus.active => const Color(0xFF4CAF50),
      CustomerStatus.prospect => const Color(0xFF2196F3),
      CustomerStatus.inactive => const Color(0xFF9E9E9E),
      CustomerStatus.suspended => const Color(0xFFFF9800),
      CustomerStatus.blacklisted => const Color(0xFFF44336),
    };
  }

  Color _getPriorityColor(PriorityLevel priority) {
    return switch (priority) {
      PriorityLevel.low => const Color(0xFF4CAF50),
      PriorityLevel.medium => const Color(0xFFFF9800),
      PriorityLevel.high => const Color(0xFFF44336),
      PriorityLevel.critical => const Color(0xFFD32F2F),
    };
  }

  void _showAddAddressDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddressForm(
        customerId: customer.id,
        onSuccess: () {
          ref.read(customerProvider.notifier).loadCustomer(customer.id);
        },
      ),
    );
  }

  void _showAddContactDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ContactPersonForm(
        customerId: customer.id,
        onSuccess: () {
          ref.read(customerProvider.notifier).loadCustomer(customer.id);
        },
      ),
    );
  }

  void _showAddServiceDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ServiceForm(
        customerId: customer.id,
        onSuccess: () {
          ref.read(customerProvider.notifier).loadCustomer(customer.id);
        },
      ),
    );
  }

  void _showEditServiceDialog(
      BuildContext context,
      WidgetRef ref,
      CustomerService service,
      ) {
    showDialog(
      context: context,
      builder: (context) => ServiceForm(
        customerId: customer.id,
        initialService: service,
        onSuccess: () {
          ref.read(customerProvider.notifier).loadCustomer(customer.id);
        },
      ),
    );
  }

  void _showDeleteServiceDialog(
      BuildContext context,
      WidgetRef ref,
      CustomerService service,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: const Text('Are you sure you want to delete this service?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(customerProvider.notifier)
                  .deleteService(customer.id, service.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: const Text('Are you sure you want to delete this customer? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(customerProvider.notifier)
                  .deleteCustomer(customer.id);
              if (success) {
                onClose();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}