import 'dart:math';
import 'package:flutter/material.dart';

class FloatingNotificationsWidget extends StatefulWidget {
  const FloatingNotificationsWidget({super.key});

  @override
  State<FloatingNotificationsWidget> createState() =>
      _FloatingNotificationsWidgetState();
}

class _FloatingNotificationsWidgetState
    extends State<FloatingNotificationsWidget> with TickerProviderStateMixin {
  bool _isExpanded = false;

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Important Service Update',
      'subtitle':
      'Water interruption scheduled for tomorrow in Bahati area from 8:00 AM to 4:00 PM',
      'time': '2 hours ago',
      'type': 'important',
      'actions': ['Hide this notification', 'View details', 'Share alert']
    },
    {
      'title': 'Bill Payment Reminder',
      'subtitle': 'Your water bill for January 2024 is due on 15th February',
      'time': '1 day ago',
      'type': 'controller',
    },
    {
      'title': 'Water Conservation Tips',
      'subtitle': 'Learn how to save water and reduce your bill this season',
      'time': '',
      'type': 'tips',
      'actions': ['Read more', 'Save for later']
    },
    {
      'title': 'New Service Connection',
      'subtitle': 'Your service connection application has been approved',
      'time': '3 days ago',
      'type': 'service',
    },
    {
      'title': 'Emergency Maintenance',
      'subtitle':
      'Urgent pipe repair in Lanet area. Water supply will be affected for 3 hours',
      'time': 'Just now',
      'type': 'emergency',
    },
    {
      'title': 'Mobile App Update',
      'subtitle':
      'New features available: Bill history, consumption analytics, and quick payments',
      'time': '1 week ago',
      'type': 'update',
    },
  ];

  final Color _primaryColor = const Color(0xFF0066CC);
  final Color _secondaryColor = const Color(0xFF00A651);
  final Color _accentColor = const Color(0xFFF57C00);
  final Color _backgroundColor = const Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenWidth < 600;

    // Position from top (you had top: 90). Keep it but ensure we compute available space.
    const double topOffset = 90;
    final double maxWidth = isSmallScreen ? screenWidth * 0.9 : 380.0;

    // make sure availableHeight fits on screen (account for topOffset and some margin)
    final double safeBottomGap = mediaQuery.padding.bottom + 12;
    final double maxAllowedHeight = screenHeight - topOffset - safeBottomGap;
    // also cap to 70% of screen height like you had
    final double prefHeight = screenHeight * 0.7;
    final double availableHeight = min(maxAllowedHeight, prefHeight);

    return Stack(
      children: [
        Positioned(
          top: topOffset,
          right: 18,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              alignment: Alignment.topRight,
              child: Container(
                width: _isExpanded ? maxWidth : 56,
                // Use constraints so container never exceeds availableHeight
                constraints: BoxConstraints(
                  maxHeight: _isExpanded ? availableHeight : 56,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: _primaryColor.withOpacity(0.2)),
                ),
                clipBehavior: Clip.hardEdge,
                child: _isExpanded ? _expandedContent(isSmallScreen, availableHeight) : _buildCollapsedView(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedView() {
    return InkWell(
      onTap: () => setState(() => _isExpanded = true),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primaryColor, _secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            const Center(
              child: Icon(Icons.water_drop, color: Colors.white, size: 24),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _accentColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  _notifications.length.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _expandedContent(bool isSmallScreen, double availableHeight) {
    // ClipRect ensures anything that briefly overflows is clipped.
    return ClipRect(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: availableHeight),
        child: Material(
          // Material to allow Ink effects if needed
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(isSmallScreen),
              // Flexible so ListView doesn't force more height than available
              Flexible(child: _buildNotificationsList(isSmallScreen)),
              _buildFooter(isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _secondaryColor],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.water_drop, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'NAWASSCO Alerts',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => setState(() => _isExpanded = false),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          )
        ],
      ),
    );
  }

  Widget _buildNotificationsList(bool isSmallScreen) {
    return Container(
      color: _backgroundColor,
      child: ListView.builder(
        // keep bottom padding small; footer is inside container so no need for big padding
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
        physics: const BouncingScrollPhysics(),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final n = _notifications[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: _buildNotificationItem(n, isSmallScreen),
          );
        },
      ),
    );
  }

  Widget _buildFooter(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'View All Alerts',
                style: TextStyle(
                  color: _primaryColor,
                  fontSize: isSmallScreen ? 12 : 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Container(width: 1, height: 16, color: Colors.grey.shade300),
          Expanded(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Preferences',
                style: TextStyle(
                  color: _secondaryColor,
                  fontSize: isSmallScreen ? 12 : 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> n, bool isSmallScreen) {
    final String title = n['title'] ?? '';
    final String subtitle = n['subtitle'] ?? '';
    final String time = n['time'] ?? '';
    final String type = n['type'] ?? '';

    Color getColor() {
      switch (type) {
        case 'important':
          return _primaryColor;
        case 'emergency':
          return _accentColor;
        case 'controller':
          return _secondaryColor;
        case 'service':
          return const Color(0xFF6A1B9A);
        case 'tips':
          return const Color(0xFF00796B);
        case 'update':
          return const Color(0xFF5D4037);
        default:
          return Colors.grey.shade700;
      }
    }

    IconData getIcon() {
      switch (type) {
        case 'important':
          return Icons.warning_amber;
        case 'emergency':
          return Icons.error;
        case 'controller':
          return Icons.receipt;
        case 'service':
          return Icons.build;
        case 'tips':
          return Icons.eco;
        case 'update':
          return Icons.update;
        default:
          return Icons.info;
      }
    }

    final actions =
    (n['actions'] is List) ? List<String>.from(n['actions']) : [];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: getColor().withOpacity(0.1),
                child: Icon(getIcon(), color: getColor(), size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: getColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (time.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 9 : 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
            ],
          ),
          if (actions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 24),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: actions
                    .map((a) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    a,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 9 : 10,
                      color: _primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
