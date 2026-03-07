import 'package:flutter/material.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Get in Touch'),
            const SizedBox(height: 20),

            // Contact Information
            _buildContactCard(
              Icons.location_on,
              'Head Office',
              'NAWASSCO Plaza\nMoi Road, Nakuru\nP.O. Box 1256-20100\nNakuru, Kenya',
            ),

            _buildContactCard(
              Icons.phone,
              'Phone Numbers',
              'Customer Care: +254-720-123456\nEmergency: +254-734-567890\nLandline: 051-2212345',
            ),

            _buildContactCard(
              Icons.email,
              'Email Addresses',
              'info@nawassco.co.ke\ncustomercare@nawassco.co.ke\nemergency@nawassco.co.ke',
            ),

            _buildContactCard(
              Icons.access_time,
              'Working Hours',
              'Monday - Friday: 8:00 AM - 5:00 PM\nSaturday: 9:00 AM - 1:00 PM\nEmergency Services: 24/7',
            ),

            const SizedBox(height: 30),
            _buildSectionTitle('Send us a Message'),
            const SizedBox(height: 16),

            // Contact Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField(
                      decoration: const InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'customer-care', child: Text('Customer Care')),
                        DropdownMenuItem(value: 'controller', child: Text('Billing')),
                        DropdownMenuItem(value: 'technical', child: Text('Technical Support')),
                        DropdownMenuItem(value: 'complaints', child: Text('Complaints')),
                      ],
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Send Message'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            _buildSectionTitle('Branch Offices'),
            const SizedBox(height: 16),

            _buildBranchCard('Main Office', 'NAWASSCO Plaza, Moi Road, Nakuru'),
            _buildBranchCard('Bahati Branch', 'Bahati Shopping Centre, Along Nakuru-Nyahururu Road'),
            _buildBranchCard('Molo Branch', 'Molo Town, Opposite Molo Police Station'),
            _buildBranchCard('Naivasha Branch', 'Naivasha Town, Next to Naivasha Sub-County Hospital'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(content),
      ),
    );
  }

  Widget _buildBranchCard(String title, String address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.business, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(address),
        trailing: IconButton(
          icon: const Icon(Icons.directions, color: Colors.blue),
          onPressed: () {},
        ),
      ),
    );
  }
}