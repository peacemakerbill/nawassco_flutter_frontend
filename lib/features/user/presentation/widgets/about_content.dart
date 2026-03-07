import 'package:flutter/material.dart';

class AboutContent extends StatefulWidget {
  const AboutContent({super.key});

  @override
  State<AboutContent> createState() => _AboutContentState();
}

class _AboutContentState extends State<AboutContent> with SingleTickerProviderStateMixin {
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
    return SafeArea(
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: 'Board of Directors'),
                Tab(text: "MD's Welcome"),
                Tab(text: 'Management Team'),
                Tab(text: 'Anti-Corruption'),
                Tab(text: 'Privacy Policy'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                BoardOfDirectorsTab(),
                MDWelcomeTab(),
                ManagementTeamTab(),
                AntiCorruptionTab(),
                PrivacyPolicyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BoardOfDirectorsTab extends StatelessWidget {
  const BoardOfDirectorsTab({super.key});

  @override
  Widget build(BuildContext context) {
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
}

class MDWelcomeTab extends StatelessWidget {
  const MDWelcomeTab({super.key});

  @override
  Widget build(BuildContext context) {
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
                    textAlign: TextAlign.center,
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
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Dr. James Maina', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Managing Director'),
                        Text('Nakuru Water and Sanitation Services Company',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.right),
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
}

class ManagementTeamTab extends StatelessWidget {
  const ManagementTeamTab({super.key});

  @override
  Widget build(BuildContext context) {
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: managementTeam.length,
      itemBuilder: (context, index) {
        final member = managementTeam[index];
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  member['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
}

class AntiCorruptionTab extends StatelessWidget {
  const AntiCorruptionTab({super.key});

  @override
  Widget build(BuildContext context) {
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

class PrivacyPolicyTab extends StatelessWidget {
  const PrivacyPolicyTab({super.key});

  @override
  Widget build(BuildContext context) {
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