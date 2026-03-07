import 'package:flutter/material.dart';

class ProfileCompletionWidget extends StatelessWidget {
  final double completion;

  const ProfileCompletionWidget({super.key, required this.completion});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Profile Completion',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${completion.toInt()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getCompletionColor(completion),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: completion / 100,
              backgroundColor: Colors.grey[200],
              color: _getCompletionColor(completion),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Text(
              _getCompletionMessage(completion),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (completion < 100) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildCompletionTips(completion),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCompletionColor(double completion) {
    if (completion >= 80) return Colors.green;
    if (completion >= 60) return Colors.blue;
    if (completion >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getCompletionMessage(double completion) {
    if (completion >= 80) return 'Excellent! Your profile is ready for recruiters.';
    if (completion >= 60) return 'Good! Complete a few more sections to improve your profile.';
    if (completion >= 40) return 'Keep going! Add more information to your profile.';
    return 'Get started! Add basic information to create your profile.';
  }

  List<Widget> _buildCompletionTips(double completion) {
    final tips = <Widget>[];

    if (completion < 20) {
      tips.add(_buildTip('Add your education history'));
      tips.add(_buildTip('Add work experience'));
      tips.add(_buildTip('Upload your resume'));
    } else if (completion < 40) {
      tips.add(_buildTip('Add your skills'));
      tips.add(_buildTip('Write a professional summary'));
      tips.add(_buildTip('Add your contact information'));
    } else if (completion < 60) {
      tips.add(_buildTip('Add certifications'));
      tips.add(_buildTip('Set job preferences'));
      tips.add(_buildTip('Add languages you know'));
    } else if (completion < 80) {
      tips.add(_buildTip('Add portfolio links'));
      tips.add(_buildTip('Add references'));
      tips.add(_buildTip('Complete your salary expectations'));
    }

    return tips;
  }

  Widget _buildTip(String text) {
    return Chip(
      label: Text(text),
      backgroundColor: Colors.blue[50],
      labelStyle: const TextStyle(fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }
}