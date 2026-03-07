import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/service_catalog_model.dart';
import '../../../providers/service_catalog_provider.dart';
import '../../../utils/service_catalog/service_constants.dart';

class ServiceDetailsWidget extends ConsumerStatefulWidget {
  final String? serviceId;
  final ServiceCatalog? service;
  final bool showEditButton;
  final bool showBackButton;
  final VoidCallback? onEdit;
  final VoidCallback? onBack;

  const ServiceDetailsWidget({
    super.key,
    this.serviceId,
    this.service,
    this.showEditButton = false,
    this.showBackButton = true,
    this.onEdit,
    this.onBack,
  });

  @override
  ConsumerState<ServiceDetailsWidget> createState() => _ServiceDetailsWidgetState();
}

class _ServiceDetailsWidgetState extends ConsumerState<ServiceDetailsWidget> {
  late ServiceCatalog? _service;

  @override
  void initState() {
    super.initState();
    _service = widget.service;
    if (widget.serviceId != null && _service == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(serviceCatalogProvider.notifier).fetchServiceById(widget.serviceId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceCatalogProvider);
    final provider = ref.read(serviceCatalogProvider.notifier);

    _service ??= widget.service ?? state.selectedService;

    if (_service == null) {
      return _buildLoadingState();
    }

    final service = _service!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            leading: widget.showBackButton
                ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: widget.onBack ?? () => Navigator.pop(context),
            )
                : null,
            actions: [
              if (widget.showEditButton)
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: widget.onEdit,
                  tooltip: 'Edit Service',
                ),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: _shareService,
                tooltip: 'Share Service',
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.content_copy),
                      title: Text('Duplicate'),
                      onTap: () {
                        Navigator.pop(context);
                        provider.duplicateService(service.id);
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.archive),
                      title: Text('Archive'),
                      onTap: () {
                        Navigator.pop(context);
                        _archiveService(provider, service);
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete', style: TextStyle(color: Colors.red)),
                      onTap: () {
                        Navigator.pop(context);
                        _deleteService(provider, service);
                      },
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                service.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      service.category.color.withValues(alpha: 0.8),
                      service.category.color.withValues(alpha: 0.4),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Opacity(
                        opacity: 0.2,
                        child: Icon(
                          service.category.icon,
                          size: 200,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              service.serviceCode,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ServiceConstants.formatCurrency(service.pricing.basePrice),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Info
                    _buildSection(
                      title: 'Service Information',
                      icon: Icons.info,
                      color: theme.colorScheme.primary,
                      children: [
                        _buildInfoRow('Category', service.category.displayName),
                        _buildInfoRow('Type', service.type),
                        _buildInfoRow('Status', service.status.displayName),
                        _buildInfoRow('Created By', service.createdBy),
                        _buildInfoRow('Created', _formatDate(service.createdAt)),
                        _buildInfoRow('Last Updated', _formatDate(service.updatedAt)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Description
                    _buildSection(
                      title: 'Description',
                      icon: Icons.description,
                      color: Colors.blue,
                      children: [
                        Text(
                          service.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade700,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Pricing
                    _buildSection(
                      title: 'Pricing Details',
                      icon: Icons.monetization_on,
                      color: Colors.green,
                      children: [
                        _buildPricingDetails(service.pricing),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Eligibility
                    _buildSection(
                      title: 'Eligibility Criteria',
                      icon: Icons.verified_user,
                      color: Colors.orange,
                      children: [
                        _buildEligibilityDetails(service.eligibility),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Process Steps
                    if (service.process.steps.isNotEmpty)
                      Column(
                        children: [
                          _buildSection(
                            title: 'Service Process',
                            icon: Icons.timeline,
                            color: Colors.purple,
                            children: [
                              _buildProcessDetails(service.process),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),

                    // Requirements
                    if (service.requirements.isNotEmpty)
                      Column(
                        children: [
                          _buildSection(
                            title: 'Requirements',
                            icon: Icons.checklist,
                            color: Colors.red,
                            children: [
                              _buildRequirements(service.requirements),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),

                    // SLA
                    _buildSection(
                      title: 'Service Level Agreement',
                      icon: Icons.gpp_good,
                      color: Colors.teal,
                      children: [
                        _buildSLADetails(service.sla),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Availability Checker
                    _buildAvailabilityChecker(service),

                    const SizedBox(height: 32),

                    // Action Buttons
                    if (service.status == ServiceStatus.active)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _applyForService(context, service),
                              icon: Icon(Icons.send),
                              label: Text('Apply Now'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () => _contactSupport(service),
                            icon: Icon(Icons.support_agent),
                            label: Text('Contact Support'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading service details...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingDetails(PricingStructure pricing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Base Price
        Row(
          children: [
            const Text('Base Price:', style: TextStyle(fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(
              ServiceConstants.formatCurrency(pricing.basePrice),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Pricing Model: ${pricing.pricingModel}', style: TextStyle(color: Colors.grey)),

        // Variable Components
        if (pricing.variableComponents.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Variable Components:', style: TextStyle(fontWeight: FontWeight.w500)),
              ...pricing.variableComponents.map((vc) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(vc.component)),
                    Text('${vc.rate.toStringAsFixed(0)}/${vc.unit}'),
                  ],
                ),
              )),
            ],
          ),

        // Taxes
        if (pricing.taxes.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Taxes:', style: TextStyle(fontWeight: FontWeight.w500)),
              ...pricing.taxes.map((tax) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(tax.name)),
                    Text('${tax.rate}%'),
                    const SizedBox(width: 8),
                    Text(tax.description, style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              )),
            ],
          ),

        // Discounts
        if (pricing.discounts.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Discounts:', style: TextStyle(fontWeight: FontWeight.w500)),
              ...pricing.discounts.map((discount) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.discount, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '${discount.value}% ${discount.type} Discount',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      if (discount.condition != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Condition: ${discount.condition}',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              )),
            ],
          ),
      ],
    );
  }

  Widget _buildEligibilityDetails(EligibilityCriteria eligibility) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Customer Types
        ...eligibility.customerTypes.map((type) => Chip(
          label: Text(type.displayName),
          avatar: Icon(type.icon, size: 16),
          backgroundColor: Colors.blue.shade50,
        )),

        // Property Types
        ...eligibility.propertyTypes.map((type) => Chip(
          label: Text(type.replaceAll('_', ' ').toTitleCase()),
          backgroundColor: Colors.green.shade50,
        )),

        // Prerequisites
        ...eligibility.prerequisites.map((prereq) => Chip(
          label: Text(prereq),
          backgroundColor: Colors.orange.shade50,
        )),

        // Documentation
        ...eligibility.documentationRequired.map((doc) => Chip(
          label: Text(doc),
          backgroundColor: Colors.purple.shade50,
        )),
      ],
    );
  }

  Widget _buildProcessDetails(ServiceProcess process) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text('Estimated Duration:')),
            Text(
              '${process.estimatedDuration} days',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        if (process.approvalRequired)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.gpp_good, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Text('Approval Required'),
                if (process.approvalAuthority != null)
                  Text(' by ${process.approvalAuthority}'),
              ],
            ),
          ),
        const SizedBox(height: 16),
        ...process.steps.map((step) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${step.step}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.description,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Responsible: ${step.responsible}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const Spacer(),
                          Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${step.estimatedTime} hours',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildRequirements(List<ServiceRequirement> requirements) {
    return Column(
      children: requirements.map((req) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: req.mandatory ? Colors.red.shade50 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: req.mandatory ? Colors.red.shade100 : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              req.mandatory
                  ? Icon(Icons.error, color: Colors.red, size: 16)
                  : Icon(Icons.info, color: Colors.blue, size: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.requirement,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      req.description,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(req.type),
                labelStyle: TextStyle(fontSize: 10),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildSLADetails(ServiceLevelAgreement sla) {
    return Column(
      children: [
        _buildSLAStat(
          icon: Icons.timer,
          label: 'Response Time',
          value: '${sla.responseTime} hours',
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildSLAStat(
          icon: Icons.calendar_today,
          label: 'Resolution Time',
          value: '${sla.resolutionTime} days',
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildSLAStat(
          icon: Icons.verified,
          label: 'Availability',
          value: '${sla.availability}%',
          color: Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildSLAStat(
          icon: Icons.support_agent,
          label: 'Support Hours',
          value: sla.supportHours,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSLAStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityChecker(ServiceCatalog service) {
    final areaController = TextEditingController();
    final customerTypeController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Check Availability',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Check if this service is available in your area',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: areaController,
                  decoration: InputDecoration(
                    labelText: 'Area',
                    hintText: 'Enter your area',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField(
                  value: CustomerType.residential,
                  items: CustomerType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {},
                  decoration: InputDecoration(
                    labelText: 'Customer Type',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Check availability
              // This would call the API
            },
            icon: Icon(Icons.search),
            label: Text('Check Availability'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _shareService() async {
    // Implementation for sharing service
    final url = 'https://nawassco.com/services/${_service?.id}';
    final text = 'Check out ${_service?.name} on NAWASSCO: $url';

    if (await canLaunchUrl(Uri.parse('mailto:?subject=Service&body=$text'))) {
      await launchUrl(Uri.parse('mailto:?subject=Service&body=$text'));
    }
  }

  void _archiveService(ServiceCatalogProvider provider, ServiceCatalog service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Archive Service'),
        content: Text('Are you sure you want to archive ${service.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.updateServiceStatus(service.id, 'inactive');
            },
            child: Text('Archive'),
          ),
        ],
      ),
    );
  }

  void _deleteService(ServiceCatalogProvider provider, ServiceCatalog service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Service'),
        content: Text('Are you sure you want to delete ${service.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteService(service.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _applyForService(BuildContext context, ServiceCatalog service) {
    // Navigate to application form
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Apply for ${service.name}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // Application form would go here
          ],
        ),
      ),
    );
  }

  void _contactSupport(ServiceCatalog service) {
    launchUrl(Uri.parse('mailto:support@nawassco.com?subject=Inquiry about ${service.name}'));
  }
}

extension StringExtension on String {
  String toTitleCase() {
    return split('_').map((word) =>
    word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }
}