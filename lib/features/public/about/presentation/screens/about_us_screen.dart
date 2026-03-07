import 'package:flutter/material.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Board of Directors'),
            Tab(text: "MD's Welcome"),
            Tab(text: 'Management Team'),
            Tab(text: 'Anti-Corruption'),
            Tab(text: 'Privacy Policy'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBoardOfDirectors(),
          _buildMDWelcome(),
          _buildManagementTeam(),
          _buildAntiCorruptionPolicy(),
          _buildPrivacyPolicy(),
        ],
      ),
    );
  }

  Widget _buildBoardOfDirectors() {
    final directors = [
      {'name': 'Dr. John Kamau', 'position': 'Chairman'},
      {'name': 'Prof. Jane Wanjiku', 'position': 'Vice Chairman'},
      {'name': 'Eng. Michael Otieno', 'position': 'Director - Finance'},
      {'name': 'Ms. Sarah Mwangi', 'position': 'Director - Operations'},
      {'name': 'Mr. David Kimani', 'position': 'Director - Technical'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: directors.length,
      itemBuilder: (context, index) {
        final director = directors[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(director['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(director['position']!),
          ),
        );
      },
    );
  }

  Widget _buildMDWelcome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome to NAWASSCO',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'On behalf of the Board of Directors, Management and Staff of Nakuru Water and Sanitation Services Company (NAWASSCO), I extend a warm welcome to you.',
                    style: TextStyle(fontSize: 16, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Our commitment is to provide sustainable, reliable, and affordable water and sanitation services to the residents of Nakuru County while maintaining the highest standards of service delivery.',
                    style: TextStyle(fontSize: 16, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'We continue to invest in modern infrastructure, embrace technology, and train our staff to ensure we meet and exceed customer expectations.',
                    style: TextStyle(fontSize: 16, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Dr. James Maina', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Managing Director'),
                        Text('Nakuru Water and Sanitation Services Company'),
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

  Widget _buildManagementTeam() {
    final managementTeam = [
      {'name': 'Dr. James Maina', 'position': 'Managing Director'},
      {'name': 'Grace Nyong\'o', 'position': 'Finance Manager'},
      {'name': 'Peter Kariuki', 'position': 'Technical Manager'},
      {'name': 'Lucy Wambui', 'position': 'HR Manager'},
      {'name': 'Robert Omondi', 'position': 'Operations Manager'},
      {'name': 'Susan Chebet', 'position': 'Commercial Manager'},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: managementTeam.length,
      itemBuilder: (context, index) {
        final member = managementTeam[index];
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  member['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  member['position']!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAntiCorruptionPolicy() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Anti-Corruption and Misconduct Policy',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPolicySection(
                    'Policy Statement',
                    'NAWASSCO maintains a zero-tolerance policy towards corruption, bribery, and misconduct in any form. We are committed to conducting our business with integrity, transparency, and accountability.',
                  ),
                  _buildPolicySection(
                    'Scope',
                    'This policy applies to all employees, directors, contractors, suppliers, and any parties acting on behalf of NAWASSCO.',
                  ),
                  _buildPolicySection(
                    'Prohibited Activities',
                    '• Bribery and corruption\n• Fraud and embezzlement\n• Conflict of interest\n• Misuse of company assets\n• Manipulation of records',
                  ),
                  _buildPolicySection(
                    'Reporting Mechanism',
                    'Employees and stakeholders are encouraged to report any suspicious activities through our confidential reporting channels including hotlines, email, and direct reporting to the Ethics Committee.',
                  ),
                  _buildPolicySection(
                    'Whistleblower Protection',
                    'NAWASSCO ensures protection for whistleblowers against any form of victimization, harassment, or retaliation for reporting in good faith.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicy() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Privacy Policy',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPolicySection(
                    'Information Collection',
                    'We collect personal information necessary for service provision including contact details, payment information, service readings, and usage data.',
                  ),
                  _buildPolicySection(
                    'Use of Information',
                    'Your information is used for service delivery, controller, customer support, regulatory compliance, and service improvement.',
                  ),
                  _buildPolicySection(
                    'Data Protection',
                    'We implement robust security measures including encryption, access controls, and regular security audits to protect your personal information.',
                  ),
                  _buildPolicySection(
                    'Information Sharing',
                    'We do not sell or share your personal information with third parties except as required by law, for essential service provision, or with your explicit consent.',
                  ),
                  _buildPolicySection(
                    'Your Rights',
                    'You have the right to access, correct, or delete your personal information. You may also object to processing or request data portability.',
                  ),
                  _buildPolicySection(
                    'Contact Us',
                    'For privacy-related inquiries, contact our Data Protection Officer at dpo@nawassco.co.ke',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(height: 1.5, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}