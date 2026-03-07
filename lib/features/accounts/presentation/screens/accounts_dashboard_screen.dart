import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/logout_confirm_dialog.dart';
import '../../../public/auth/providers/auth_provider.dart';
import '../../../public/profile/presentation/widgets/user_avatar.dart';
import '../content/bank_reconciliation_content.dart';
import '../content/budget_content.dart';
import '../content/chart_of_accounts_content.dart';
import '../content/dashboard_content.dart';
import '../content/fixed_assets_content.dart';
import '../content/journal_entry_content.dart';
import '../content/payment_content.dart';
import '../content/receipt_content.dart';
import '../content/tax_calculation_content.dart';
import '../content/accountants_management_content.dart';
import '../content/accountant_profile_content.dart';
import '../widgets/dashboard/accounts_sidebar.dart';

class AccountsDashboardScreen extends ConsumerStatefulWidget {
  const AccountsDashboardScreen({super.key});

  @override
  ConsumerState<AccountsDashboardScreen> createState() =>
      _AccountsDashboardScreenState();
}

class _AccountsDashboardScreenState
    extends ConsumerState<AccountsDashboardScreen> {
  int _selectedIndex = 0;
  bool _isSidebarOpen = false;
  String _currentRoute = '/accounts/dashboard';

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard, 'label': 'Dashboard', 'route': '/accounts/dashboard'},
    {'icon': Icons.payment, 'label': 'Payments', 'route': '/accounts/payments'},
    {'icon': Icons.calculate, 'label': 'Tax Calculation', 'route': '/accounts/tax-calculation'},
    {'icon': Icons.account_balance, 'label': 'Chart of Accounts', 'route': '/accounts/chart-of-accounts'},
    {'icon': Icons.business_center, 'label': 'Fixed Assets', 'route': '/accounts/fixed-assets'},
    {'icon': Icons.account_balance_wallet, 'label': 'Budget', 'route': '/accounts/budget'},
    {'icon': Icons.receipt_long, 'label': 'Receipts', 'route': '/accounts/receipts'},
    {'icon': Icons.book, 'label': 'Journal Entries', 'route': '/accounts/journal-entries'},
    {'icon': Icons.account_balance, 'label': 'Bank Reconciliation', 'route': '/accounts/bank-reconciliation'},
    {'icon': Icons.people_alt, 'label': 'Accountants Management', 'route': '/accounts/accountants-management'},
    {'icon': Icons.person, 'label': 'Accountant Profile', 'route': '/accounts/accountant-profile'},
  ];

  void _navigateToRoute(String route) {
    setState(() {
      _currentRoute = route;
      // Find the index in the visible tabs (first 4 items)
      final visibleTabs = _menuItems.take(4).toList();
      _selectedIndex = visibleTabs.indexWhere((item) => item['route'] == route);
      if (_selectedIndex == -1) {
        _selectedIndex = 0; // Default to first tab if not found in visible tabs
      }
      _isSidebarOpen = false;
    });
  }

  Widget _getCurrentContent() {
    switch (_currentRoute) {
      case '/accounts/dashboard':
        return DashboardContent(onNavigate: _navigateToRoute);
      case '/accounts/payments':
        return const PaymentContent();
      case '/accounts/tax-calculation':
        return const TaxCalculationContent();
      case '/accounts/chart-of-accounts':
        return const ChartOfAccountsContent();
      case '/accounts/fixed-assets':
        return const FixedAssetsContent();
      case '/accounts/budget':
        return const BudgetContent();
      case '/accounts/receipts':
        return const ReceiptContent();
      case '/accounts/journal-entries':
        return const JournalEntryContent();
      case '/accounts/bank-reconciliation':
        return const BankReconciliationContent();
      case '/accounts/accountants-management':
        return const AccountantsManagementContent();
      case '/accounts/accountant-profile':
        return const AccountantProfileContent();
      default:
        return DashboardContent(onNavigate: _navigateToRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authProvider).user;
    final profilePic = user?['profilePictureUrl'] as String?;

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    final visibleTabs = _menuItems.take(4).toList();
    final moreTabs = _menuItems.skip(4).toList();

    // Ensure selected index is within bounds for visible tabs
    final safeSelectedIndex = _selectedIndex.clamp(0, visibleTabs.length - 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3979CD),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        title: Text(
          _menuItems.firstWhere(
                (item) => item['route'] == _currentRoute,
            orElse: () => _menuItems.first,
          )['label'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: !isMobile
            ? IconButton(
          icon: Icon(
            _isSidebarOpen ? Icons.close : Icons.menu,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () {
            setState(() {
              _isSidebarOpen = !_isSidebarOpen;
            });
          },
        )
            : null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: UserAvatar(imageUrl: profilePic, radius: 18),
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white, size: 22),
            onPressed: () => context.go('/profile'),
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 22),
            onPressed: () => _showLogoutDialog(context, ref),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(left: _isSidebarOpen && !isMobile ? 260 : 0),
            child: _getCurrentContent(),
          ),

          // Sidebar overlay for mobile
          if (isMobile && _isSidebarOpen)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isSidebarOpen = false;
                });
              },
              child: Container(
                color: Colors.black54,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          // Sidebar - using the extracted widget
          if (!isMobile) _buildDesktopSidebar(),
          if (isMobile) _buildMobileSidebar(),
        ],
      ),
      bottomNavigationBar: isMobile
          ? Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: safeSelectedIndex, // Use the safe index
          onTap: (index) {
            if (index == 4 && moreTabs.isNotEmpty) {
              _showMoreOptions(context, moreTabs);
            } else if (index < visibleTabs.length) {
              final route = visibleTabs[index]['route'];
              _navigateToRoute(route);
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0D47A1),
          unselectedItemColor: Colors.black54,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          showUnselectedLabels: true,
          items: [
            ...visibleTabs
                .map(
                  (item) => BottomNavigationBarItem(
                icon: Icon(item['icon']),
                label: item['label'],
              ),
            )
                .toList(),
            if (moreTabs.isNotEmpty)
              const BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz),
                label: 'More',
              ),
          ],
        ),
      )
          : null,
    );
  }

  Widget _buildDesktopSidebar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _isSidebarOpen ? 0 : -260,
      top: 0,
      bottom: 0,
      child: AccountsSidebar(
        currentRoute: _currentRoute,
        menuItems: _menuItems,
        onNavigate: _navigateToRoute,
        onClose: () => setState(() => _isSidebarOpen = false),
      ),
    );
  }

  Widget _buildMobileSidebar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _isSidebarOpen ? 0 : -260,
      top: 0,
      bottom: 0,
      child: AccountsSidebar(
        currentRoute: _currentRoute,
        menuItems: _menuItems,
        onNavigate: _navigateToRoute,
        onClose: () => setState(() => _isSidebarOpen = false),
      ),
    );
  }

  void _showMoreOptions(
      BuildContext context, List<Map<String, dynamic>> items) {
    final itemHeight = 56.0; // Approximate height of each ListTile
    final headerHeight = 120.0; // Height of header content
    final maxHeight = MediaQuery.of(context).size.height * 0.8;
    final calculatedHeight = (items.length * itemHeight) + headerHeight;
    final sheetHeight =
    calculatedHeight > maxHeight ? maxHeight : calculatedHeight;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: sheetHeight, // Set dynamic height
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'More Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                // Use Expanded to take available space
                child: ListView(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  children: items
                      .map(
                        (item) => ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                          const Color(0xFF0D47A1).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item['icon'],
                            color: const Color(0xFF0D47A1)),
                      ),
                      title: Text(
                        item['label'],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(Icons.chevron_right,
                          color: Colors.grey),
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToRoute(item['route']);
                      },
                    ),
                  )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const LogoutConfirmDialog(),
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout(context);
    }
  }
}