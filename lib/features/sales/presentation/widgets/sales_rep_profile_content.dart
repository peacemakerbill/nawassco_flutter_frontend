import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/sales_representative_model.dart';
import '../../providers/sales_rep_provider.dart';
import 'sub_widgets/sales_rep/custom_widgets.dart';
import 'sub_widgets/sales_rep/sales_rep_form_widget.dart';

class SalesRepProfileContent extends ConsumerStatefulWidget {
  const SalesRepProfileContent({super.key});

  @override
  ConsumerState<SalesRepProfileContent> createState() =>
      _SalesRepProfileContentState();
}

class _SalesRepProfileContentState
    extends ConsumerState<SalesRepProfileContent> {
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(salesRepProvider.notifier).fetchCurrentUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salesRepProvider);
    final currentProfile = state.currentSalesRep;
    final isLoading = state.isLoading;

    return LoadingOverlay(
      isLoading: isLoading,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header
              _buildProfileHeader(currentProfile),
              const SizedBox(height: 24),

              // Profile Content
              if (currentProfile != null && !_isEditing) ...[
                _buildProfileView(currentProfile),
              ] else if (_isEditing || currentProfile == null) ...[
                _buildProfileForm(currentProfile),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(SalesRepresentative? profile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Profile Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1E3A8A),
                    const Color(0xFF3B82F6),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  profile?.personalDetails.firstName.substring(0, 1) ?? '?',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.fullName ?? 'Complete Your Profile',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (profile != null) ...[
                    Row(
                      children: [
                        StatusBadge(
                          status: SalesRepresentative.getStatusDisplayName(
                              profile.status),
                          color: SalesRepresentative.getStatusColor(
                              profile.status),
                        ),
                        const SizedBox(width: 12),
                        StatusBadge(
                          status: SalesRepresentative.getRoleDisplayName(
                              profile.salesRole),
                          color: SalesRepresentative.getRoleColor(
                              profile.salesRole),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          profile.employeeNumber,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const Text(
                      'You need to complete your sales representative profile to access all features.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (profile != null && !_isEditing) ...[
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit, color: Color(0xFF1E3A8A)),
                ),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView(SalesRepresentative profile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Personal Information
            _buildSectionHeader('Personal Information', Icons.person),
            const SizedBox(height: 16),
            _buildInfoGrid([
              _buildInfoItem('Full Name', profile.fullName, Icons.badge),
              _buildInfoItem(
                  'Date of Birth',
                  '${profile.personalDetails.dateOfBirth.day}/${profile.personalDetails.dateOfBirth.month}/${profile.personalDetails.dateOfBirth.year}',
                  Icons.cake),
              _buildInfoItem(
                  'Gender',
                  profile.personalDetails.gender.toUpperCase(),
                  Icons.transgender),
              _buildInfoItem('National ID', profile.personalDetails.nationalId,
                  Icons.credit_card),
            ]),
            const SizedBox(height: 24),

            // Contact Information
            _buildSectionHeader('Contact Information', Icons.contact_mail),
            const SizedBox(height: 16),
            _buildInfoGrid([
              _buildInfoItem('Work Email', profile.contactInformation.workEmail,
                  Icons.email),
              _buildInfoItem('Personal Email',
                  profile.contactInformation.personalEmail, Icons.mail_outline),
              _buildInfoItem('Work Phone', profile.contactInformation.workPhone,
                  Icons.phone),
              _buildInfoItem('Personal Phone',
                  profile.contactInformation.personalPhone, Icons.phone_iphone),
              _buildInfoItem(
                  'Address',
                  profile.contactInformation.address.formattedAddress,
                  Icons.location_on),
            ]),
            const SizedBox(height: 24),

            // Performance Metrics
            _buildSectionHeader('Performance Metrics', Icons.trending_up),
            const SizedBox(height: 16),
            _buildPerformanceGrid(profile),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm(SalesRepresentative? existingProfile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  existingProfile == null
                      ? 'Create Your Profile'
                      : 'Edit Profile',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                if (existingProfile != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SalesRepFormWidget(
              existingSalesRep: existingProfile,
              isSelfService: true,
              onSubmit: (data) async {
                final notifier = ref.read(salesRepProvider.notifier);
                final success = existingProfile == null
                    ? await notifier.createSalesRep(data)
                    : await notifier.updateCurrentProfile(data);

                if (success) {
                  if (existingProfile == null) {
                    await notifier.fetchCurrentUserProfile();
                  }
                  setState(() {
                    _isEditing = false;
                  });
                }
              },
              onCancel: existingProfile != null
                  ? () {
                      setState(() {
                        _isEditing = false;
                      });
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1E3A8A)),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(List<Widget> items) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 1200
          ? 3
          : MediaQuery.of(context).size.width > 800
              ? 2
              : 1,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 3,
      children: items,
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1E3A8A)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceGrid(SalesRepresentative profile) {
    final performance = profile.performance;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 1000
          ? 4
          : MediaQuery.of(context).size.width > 600
              ? 2
              : 1,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
            'Total Sales',
            'KES ${performance.totalSales.toStringAsFixed(2)}',
            Icons.attach_money,
            Colors.green),
        _buildMetricCard(
            'Monthly Average',
            'KES ${performance.monthlyAverage.toStringAsFixed(2)}',
            Icons.trending_up,
            Colors.blue),
        _buildMetricCard(
            'Conversion Rate',
            '${performance.conversionRate.toStringAsFixed(1)}%',
            Icons.compare_arrows,
            Colors.purple),
        _buildMetricCard(
            'Customer Satisfaction',
            '${performance.customerSatisfaction.toStringAsFixed(1)}/10',
            Icons.star,
            Colors.orange),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
