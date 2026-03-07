import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/logout_confirm_dialog.dart';
import '../../../public/auth/providers/auth_provider.dart';
import '../../../public/profile/presentation/widgets/user_avatar.dart';
import '../../../supplier/presentation/procurement_content/supplier_category_management_content.dart';
import '../../../supplier/presentation/procurement_content/supplier_contact_management_content.dart';
import '../../../supplier/presentation/procurement_content/supplier_evaluation_management_content.dart';
import '../../../supplier/presentation/procurement_content/supplier_management_content.dart';
import '../widgets/procurement_team/contracts_content.dart';
import '../widgets/procurement_team/goods_receipt_notes_content.dart';
import '../widgets/procurement_team/invoice_list_content.dart';
import '../widgets/procurement_home_content.dart';
import '../widgets/procurement_team/procurement_officer_content.dart';
import '../widgets/procurement_team/purchase_orders_content.dart';
import '../widgets/procurement_team/purchase_requisitions_content.dart';
import '../widgets/suppliers/tender_application_list_content.dart';
import '../widgets/suppliers/tender_list_content.dart';
import 'widgets/procurement_sidebar.dart';

class ProcurementDashboard extends ConsumerStatefulWidget {
  const ProcurementDashboard({super.key});

  @override
  ConsumerState<ProcurementDashboard> createState() => _ProcurementDashboardState();
}

class _ProcurementDashboardState extends ConsumerState<ProcurementDashboard> {
  int _selectedIndex = 0;
  bool _isSidebarOpen = false;
  String _currentRoute = '/procurement';

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard, 'label': 'Dashboard', 'route': '/procurement'},
    {'icon': Icons.business, 'label': 'Supplier Management', 'route': '/procurement/suppliers'},
    {'icon': Icons.assignment, 'label': 'Tender Management', 'route': '/procurement/tenders'},
    {'icon': Icons.assignment_turned_in, 'label': 'Tender Applications', 'route': '/procurement/tender-applications'},
    {'icon': Icons.shopping_cart, 'label': 'Purchase Orders', 'route': '/procurement/purchase-orders'},
    {'icon': Icons.shopping_basket, 'label': 'Purchase Requisitions', 'route': '/procurement/purchase-requisitions'},
    {'icon': Icons.receipt_long, 'label': 'Goods Receipt Notes', 'route': '/procurement/goods-receipt-notes'},
    {'icon': Icons.receipt, 'label': 'Invoices', 'route': '/procurement/invoices'},
    {'icon': Icons.feed, 'label': 'Contracts', 'route': '/procurement/contracts'},
    {'icon': Icons.people, 'label': 'Procurement Officers', 'route': '/procurement/officers'},
    // Add supplier management sub-menu items
    {'icon': Icons.contacts, 'label': 'Supplier Contacts', 'route': '/procurement/supplier-contacts'},
    {'icon': Icons.assessment, 'label': 'Supplier Evaluations', 'route': '/procurement/supplier-evaluations'},
    {'icon': Icons.category, 'label': 'Supplier Categories', 'route': '/procurement/supplier-categories'},
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
      case '/procurement':
        return ProcurementHomeContent(onNavigate: _navigateToRoute);
      case '/procurement/suppliers':
        return const SupplierManagementContent();
      case '/procurement/tenders':
        return const TenderListContent();
      case '/procurement/tender-applications':
        return const TenderApplicationListContent();
      case '/procurement/purchase-orders':
        return const PurchaseOrdersContent();
      case '/procurement/purchase-requisitions':
        return const PurchaseRequisitionsPage();
      case '/procurement/goods-receipt-notes':
        return const GoodsReceiptNotesContent();
      case '/procurement/invoices':
        return const InvoiceListContent();
      case '/procurement/contracts':
        return const ContractsContent();
      case '/procurement/officers':
        return const ProcurementOfficerContent();
      case '/procurement/supplier-contacts':
        return const SUpplierContactManagementContent();
      case '/procurement/supplier-evaluations':
        return const SupplierEvaluationManagementContent();
      case '/procurement/supplier-categories':
        return const SupplierCategoryManagementContent();
      default:
        return ProcurementHomeContent(onNavigate: _navigateToRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authProvider).user;
    final profilePic = user?['profilePictureUrl'] as String?;
    final firstName = user?['firstName'] as String? ?? '';
    final lastName = user?['lastName'] as String? ?? '';
    final email = user?['email'] as String? ?? 'procurement@nawassco.co.ke';

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    final visibleTabs = _menuItems.take(4).toList();
    final moreTabs = _menuItems.skip(4).toList();

    // Ensure selected index is within bounds for visible tabs
    final safeSelectedIndex = _selectedIndex.clamp(0, visibleTabs.length - 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3468B6),
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
          if (!isMobile)
            _buildDesktopSidebar(firstName, lastName, email, profilePic),
          if (isMobile)
            _buildMobileSidebar(firstName, lastName, email, profilePic),
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
            // Check if "More" button is tapped (index 4 when we have 4 visible tabs + more)
            if (index == 4 && moreTabs.isNotEmpty) {
              _showMoreOptions(context, moreTabs);
            }
            // Check if it's a regular tab (not the "More" button)
            else if (index < visibleTabs.length) {
              final route = visibleTabs[index]['route'];
              _navigateToRoute(route);
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF295EB1),
          unselectedItemColor: Colors.black54,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          showUnselectedLabels: true,
          items: [
            ...visibleTabs.asMap().entries.map(
                  (entry) {
                final index = entry.key;
                final item = entry.value;
                return BottomNavigationBarItem(
                  icon: Icon(item['icon']),
                  label: item['label'],
                );
              },
            ).toList(),
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

  Widget _buildDesktopSidebar(String firstName, String lastName, String email, String? profilePic) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _isSidebarOpen ? 0 : -260,
      top: 0,
      bottom: 0,
      child: ProcurementSidebar(
        currentRoute: _currentRoute,
        menuItems: _menuItems,
        firstName: firstName,
        lastName: lastName,
        email: email,
        profilePic: profilePic,
        onNavigate: _navigateToRoute,
        onClose: () => setState(() => _isSidebarOpen = false),
      ),
    );
  }

  Widget _buildMobileSidebar(String firstName, String lastName, String email, String? profilePic) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _isSidebarOpen ? 0 : -260,
      top: 0,
      bottom: 0,
      child: ProcurementSidebar(
        currentRoute: _currentRoute,
        menuItems: _menuItems,
        firstName: firstName,
        lastName: lastName,
        email: email,
        profilePic: profilePic,
        onNavigate: _navigateToRoute,
        onClose: () => setState(() => _isSidebarOpen = false),
      ),
    );
  }

  void _showMoreOptions(BuildContext context, List<Map<String, dynamic>> items) {
    final itemHeight = 56.0; // Approximate height of each ListTile
    final headerHeight = 120.0; // Height of header content
    final maxHeight = MediaQuery.of(context).size.height * 0.8;
    final calculatedHeight = (items.length * itemHeight) + headerHeight;
    final sheetHeight = calculatedHeight > maxHeight ? maxHeight : calculatedHeight;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: sheetHeight,
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
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2767C5).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item['icon'], color: const Color(0xFF3168BA)),
                      ),
                      title: Text(
                        item['label'],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToRoute(item['route']);
                      },
                    );
                  },
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