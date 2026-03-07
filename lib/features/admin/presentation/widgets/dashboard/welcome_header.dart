import 'package:flutter/material.dart';

class WelcomeHeader extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isMobile;

  const WelcomeHeader({
    super.key,
    required this.user,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final firstName = user['firstName'] ?? 'Admin';
    final lastName = user['lastName'] ?? '';
    final fullName = '$firstName $lastName'.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0066CC), Color(0xFF004799), Color(0xFF003366)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004799).withOpacity(0.6),
            blurRadius: 25,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $fullName',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 22 : 28,
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black45,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 6 : 8),
                Text(
                  'Welcome to your NAWASSCO Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w500,
                    shadows: const [
                      Shadow(
                        blurRadius: 5,
                        color: Colors.black26,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildStatusChip('Administrator', Icons.verified_user, Colors.green),
                    _buildStatusChip('System Access', Icons.security, Colors.blue),
                    _buildStatusChip('Active Session', Icons.circle, Colors.green),
                  ],
                ),
              ],
            ),
          ),
          if (!isMobile)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String text, IconData icon, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  blurRadius: 5,
                  color: Colors.black26,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}