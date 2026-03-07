import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showMenuButton;
  final VoidCallback? onMenuPressed;
  final List<Widget> actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color backgroundColor;
  final Color titleColor;
  final double elevation;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showMenuButton = true,
    this.onMenuPressed,
    this.actions = const [],
    this.showBackButton = false,
    this.onBackPressed,
    this.backgroundColor = const Color(0xFF0D47A1),
    this.titleColor = Colors.white,
    this.elevation = 4,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      scrolledUnderElevation: elevation,
      title: Row(
        children: [
          // Company Logo/Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.water_drop,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      leading: _buildLeading(context),
      actions: _buildActions(),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              backgroundColor,
              Color.alphaBlend(backgroundColor.withOpacity(0.8), const Color(0xFF1976D2)),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(12),
        ),
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (showBackButton) {
      return IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: 'Back',
      );
    }

    if (showMenuButton) {
      return IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: onMenuPressed,
        tooltip: 'Menu',
      );
    }

    return null;
  }

  List<Widget> _buildActions() {
    final actionWidgets = <Widget>[];

    // Add any custom actions
    actionWidgets.addAll(actions);

    // Add spacing if there are actions
    if (actionWidgets.isNotEmpty) {
      actionWidgets.add(const SizedBox(width: 8));
    }

    return actionWidgets;
  }
}

// Specialized AppBar variants for different use cases

class TechnicianAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int notificationCount;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onProfilePressed;
  final String? technicianName;
  final bool isOnline;

  const TechnicianAppBar({
    super.key,
    required this.title,
    this.notificationCount = 0,
    this.onNotificationsPressed,
    this.onProfilePressed,
    this.technicianName,
    this.isOnline = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      actions: [
        // Online Status Indicator
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isOnline ? Colors.green : Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                isOnline ? 'Online' : 'Offline',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Notifications Button
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white),
              onPressed: onNotificationsPressed,
              tooltip: 'Notifications',
            ),
            if (notificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    notificationCount > 9 ? '9+' : notificationCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),

        // Profile Menu
        if (technicianName != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              icon: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.3),
                child: Text(
                  technicianName!.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    onProfilePressed?.call();
                    break;
                  case 'settings':
                  // Handle settings
                    break;
                  case 'logout':
                  // Handle logout
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text('My Profile'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      const Icon(Icons.settings, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text('Settings'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class WorkOrderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String workOrderId;
  final WorkOrderStatus status;
  final VoidCallback? onStatusChange;
  final VoidCallback? onShare;
  final VoidCallback? onPrint;

  const WorkOrderAppBar({
    super.key,
    required this.workOrderId,
    required this.status,
    this.onStatusChange,
    this.onShare,
    this.onPrint,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: 'Work Order #$workOrderId',
      showBackButton: true,
      actions: [
        // Status Badge
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(status).withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _getStatusColor(status)),
          ),
          child: Text(
            _getStatusText(status),
            style: TextStyle(
              color: _getStatusColor(status),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Share Button
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: onShare,
          tooltip: 'Share',
        ),

        // Print Button
        IconButton(
          icon: const Icon(Icons.print, color: Colors.white),
          onPressed: onPrint,
          tooltip: 'Print',
        ),

        // More Options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            switch (value) {
              case 'edit':
              // Handle edit
                break;
              case 'history':
              // Handle history
                break;
              case 'export':
              // Handle export
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'history',
              child: Row(
                children: [
                  Icon(Icons.history, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('View History'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Export PDF'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(WorkOrderStatus status) {
    return switch (status) {
      WorkOrderStatus.assigned => Colors.blue,
      WorkOrderStatus.inProgress => Colors.orange,
      WorkOrderStatus.completed => Colors.green,
      WorkOrderStatus.cancelled => Colors.grey,
      WorkOrderStatus.onHold => Colors.purple,
    };
  }

  String _getStatusText(WorkOrderStatus status) {
    return switch (status) {
      WorkOrderStatus.assigned => 'ASSIGNED',
      WorkOrderStatus.inProgress => 'IN PROGRESS',
      WorkOrderStatus.completed => 'COMPLETED',
      WorkOrderStatus.cancelled => 'CANCELLED',
      WorkOrderStatus.onHold => 'ON HOLD',
    };
  }
}

class EmergencyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String emergencyType;
  final VoidCallback? onEmergencyCall;
  final VoidCallback? onSupervisorCall;
  final bool isCritical;

  const EmergencyAppBar({
    super.key,
    required this.emergencyType,
    this.onEmergencyCall,
    this.onSupervisorCall,
    this.isCritical = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: isCritical ? Colors.red : Colors.orange,
      elevation: 8,
      title: Row(
        children: [
          const Icon(Icons.warning, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCritical ? 'EMERGENCY ALERT' : 'PRIORITY ALERT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  emergencyType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        if (onEmergencyCall != null)
          IconButton(
            icon: const Icon(Icons.emergency, color: Colors.white),
            onPressed: onEmergencyCall,
            tooltip: 'Emergency Call',
          ),
        if (onSupervisorCall != null)
          IconButton(
            icon: const Icon(Icons.supervisor_account, color: Colors.white),
            onPressed: onSupervisorCall,
            tooltip: 'Call Supervisor',
          ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isCritical ? Colors.red : Colors.orange,
              Color.alphaBlend(
                (isCritical ? Colors.red : Colors.orange).withOpacity(0.7),
                Colors.red[800]!,
              ),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(4),
        child: LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}

// AppBar with search functionality
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onMenuPressed;
  final bool autoFocus;
  final String hintText;

  const SearchAppBar({
    super.key,
    required this.title,
    required this.onSearchChanged,
    this.onMenuPressed,
    this.autoFocus = false,
    this.hintText = 'Search...',
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoFocus) {
      _isSearching = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0D47A1),
      elevation: 4,
      leading: _isSearching
          ? IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: _cancelSearch,
      )
          : IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: widget.onMenuPressed,
      ),
      title: _isSearching
          ? TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
        onChanged: widget.onSearchChanged,
      )
          : Text(
        widget.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        if (_isSearching)
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: _clearSearch,
          )
        else
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _startSearch,
          ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0D47A1),
              const Color(0xFF1976D2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _cancelSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      widget.onSearchChanged('');
    });
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onSearchChanged('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// WorkOrderStatus enum for the WorkOrderAppBar
enum WorkOrderStatus {
  assigned,
  inProgress,
  completed,
  cancelled,
  onHold,
}