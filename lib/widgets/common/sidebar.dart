import 'package:flutter/material.dart';
import 'package:inventory_saas/utils/theme.dart';
import 'package:inventory_saas/screens/dashboard/dashboard_screen.dart';
import 'package:inventory_saas/screens/inventory/inventory_screen.dart';
import 'package:inventory_saas/screens/sales/sales_screen.dart';
import 'package:inventory_saas/screens/pos/pos_screen.dart';

class Sidebar extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback? onToggle;
  final String currentRoute;

  const Sidebar({
    super.key,
    required this.isExpanded,
    this.onToggle,
    required this.currentRoute,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int _selectedIndex = 0;
  Map<int, bool> _expandedItems = {};

  final List<SidebarItem> _menuItems = [
    SidebarItem(
      title: 'Dashboard',
      icon: Icons.dashboard,
      route: '/dashboard',
    ),
    SidebarItem(
      title: 'Point of Sale',
      icon: Icons.point_of_sale,
      route: '/pos',
    ),
    SidebarItem(
      title: 'Inventory',
      icon: Icons.inventory_2,
      route: '/inventory',
      children: [
        SidebarItem(title: 'Products', icon: Icons.category, route: '/inventory/products'),
        SidebarItem(title: 'Categories', icon: Icons.folder, route: '/inventory/categories'),
        SidebarItem(title: 'Stock Movement', icon: Icons.swap_horiz, route: '/inventory/movement'),
        SidebarItem(title: 'Barcode Scanner', icon: Icons.qr_code_scanner, route: '/inventory/scanner'),
      ],
    ),
    SidebarItem(
      title: 'Sales',
      icon: Icons.shopping_cart,
      route: '/sales',
      children: [
        SidebarItem(title: 'Orders', icon: Icons.receipt, route: '/sales/orders'),
        SidebarItem(title: 'Customers', icon: Icons.people, route: '/sales/customers'),
        SidebarItem(title: 'Invoices', icon: Icons.description, route: '/sales/invoices'),
        SidebarItem(title: 'E-commerce', icon: Icons.store, route: '/sales/ecommerce'),
      ],
    ),
    SidebarItem(
      title: 'Purchasing',
      icon: Icons.shopping_bag,
      route: '/purchasing',
      children: [
        SidebarItem(title: 'Purchase Orders', icon: Icons.assignment, route: '/purchasing/orders'),
        SidebarItem(title: 'Suppliers', icon: Icons.business, route: '/purchasing/suppliers'),
        SidebarItem(title: 'Receiving', icon: Icons.local_shipping, route: '/purchasing/receiving'),
      ],
    ),
    SidebarItem(
      title: 'Warehouse',
      icon: Icons.warehouse,
      route: '/warehouse',
      children: [
        SidebarItem(title: 'Locations', icon: Icons.location_on, route: '/warehouse/locations'),
        SidebarItem(title: 'Zones', icon: Icons.grid_on, route: '/warehouse/zones'),
        SidebarItem(title: 'Shipping', icon: Icons.local_shipping, route: '/warehouse/shipping'),
      ],
    ),
    SidebarItem(
      title: 'Analytics',
      icon: Icons.analytics,
      route: '/analytics',
      children: [
        SidebarItem(title: 'Reports', icon: Icons.assessment, route: '/analytics/reports'),
        SidebarItem(title: 'Charts', icon: Icons.show_chart, route: '/analytics/charts'),
        SidebarItem(title: 'Forecasting', icon: Icons.trending_up, route: '/analytics/forecasting'),
      ],
    ),
    SidebarItem(
      title: 'Integrations',
      icon: Icons.integration_instructions,
      route: '/integrations',
      children: [
        SidebarItem(title: 'Accounting', icon: Icons.account_balance, route: '/integrations/accounting'),
        SidebarItem(title: 'CRM', icon: Icons.people_alt, route: '/integrations/crm'),
        SidebarItem(title: 'Payment Gateways', icon: Icons.payment, route: '/integrations/payments'),
      ],
    ),
    SidebarItem(
      title: 'Settings',
      icon: Icons.settings,
      route: '/settings',
      children: [
        SidebarItem(title: 'General', icon: Icons.tune, route: '/settings/general'),
        SidebarItem(title: 'Users', icon: Icons.people, route: '/settings/users'),
        SidebarItem(title: 'Notifications', icon: Icons.notifications, route: '/settings/notifications'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _updateSelection();
  }

  @override
  void didUpdateWidget(Sidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) {
      _updateSelection();
    }
  }

  void _updateSelection() {
    for (int i = 0; i < _menuItems.length; i++) {
      final item = _menuItems[i];
      if (item.route == widget.currentRoute) {
        _selectedIndex = i;
        return;
      }
      for (int j = 0; j < item.children.length; j++) {
        if (item.children[j].route == widget.currentRoute) {
          _selectedIndex = i;
          _expandedItems[i] = true;
          return;
        }
      }
    }
    // Fallback: Check for partial matches or default
    // If route is '/inventory', match index 2
    for (int i = 0; i < _menuItems.length; i++) {
       if (widget.currentRoute.startsWith(_menuItems[i].route)) {
         _selectedIndex = i;
         if (_menuItems[i].children.isNotEmpty) {
           _expandedItems[i] = true;
         }
         return;
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.isExpanded ? 280 : 70,
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          // Logo Section
          _buildLogoSection(),
          
          // Navigation Menu
          Expanded(
            child: _buildNavigationMenu(),
          ),
          
          // Footer
          if (widget.isExpanded) _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Hamburger Button
          IconButton(
            onPressed: widget.onToggle,
            icon: Icon(
              widget.isExpanded ? Icons.menu_open : Icons.menu,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            tooltip: widget.isExpanded ? 'Collapse Sidebar' : 'Expand Sidebar',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          if (widget.isExpanded) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.inventory_2,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Inventory SaaS',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationMenu() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: _menuItems.length,
      itemBuilder: (context, index) {
        final item = _menuItems[index];
        return _buildMenuItem(item, index);
      },
    );
  }

  Widget _buildMenuItem(SidebarItem item, int index) {
    final isSelected = _selectedIndex == index;
    final hasChildren = item.children.isNotEmpty;
    final isExpanded = _expandedItems[index] ?? false;
    final isSidebarExpanded = widget.isExpanded;

    return Column(
      children: [
        // Main Menu Item
        Container(
          height: 44, // Compact height
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {
                setState(() {
                  if (hasChildren) {
                    if (isSidebarExpanded) {
                       _expandedItems[index] = !isExpanded;
                    } else {
                       // If collapsed, clicking parent with children might need different behavior (e.g. show popup)
                       // For now, toggle expansion which will only be visible if Sidebar is expanded
                       widget.onToggle?.call(); // Auto-expand sidebar
                       _expandedItems[index] = true;
                    }
                  } else {
                    _selectedIndex = index;
                    _navigateToRoute(item.route);
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected && !hasChildren 
                      ? AppTheme.primaryColor 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 20,
                      color: isSelected && !hasChildren 
                          ? Colors.white 
                          : isSelected 
                              ? AppTheme.primaryColor 
                              : AppTheme.textSecondary,
                    ),
                    if (isSidebarExpanded) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected && !hasChildren
                                ? Colors.white
                                : isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.textPrimary,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasChildren)
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 16,
                          color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Submenu Items (if expanded)
        if (hasChildren && isExpanded && isSidebarExpanded)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            child: Column(
              children: item.children.asMap().entries.map((entry) {
                final childIndex = entry.key;
                final child = entry.value;
                return _buildSubMenuItem(child, index, childIndex);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildSubMenuItem(SidebarItem item, int parentIndex, int childIndex) {
    final isActive = item.route == widget.currentRoute;
    
    return Container(
      height: 36,
      margin: const EdgeInsets.only(left: 16, right: 8, top: 1),
      decoration: BoxDecoration(
        border: Border(
           left: BorderSide(
             color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary.withOpacity(0.2),
             width: isActive ? 2 : 1,
           ),
        ),
      ),
      child: Material(
        color: isActive ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedIndex = parentIndex;
            });
            _navigateToRoute(item.route);
          },
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(6),
            bottomRight: Radius.circular(6),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isActive ? AppTheme.primaryColor : null,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToRoute(String route) {
    switch (route) {
      case '/dashboard':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
        break;
      case '/pos':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const POSScreen()),
        );
        break;
      case '/inventory':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const InventoryScreen()),
        );
        break;
      case '/inventory/products':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const InventoryScreen(),
            settings: const RouteSettings(arguments: {'tabIndex': 0}),
          ),
        );
        break;
      case '/inventory/categories':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const InventoryScreen(),
            settings: const RouteSettings(arguments: {'tabIndex': 1}),
          ),
        );
        break;
      case '/inventory/movement':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const InventoryScreen(),
            settings: const RouteSettings(arguments: {'tabIndex': 2}),
          ),
        );
        break;
      case '/inventory/scanner':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const InventoryScreen(),
            settings: const RouteSettings(arguments: {'tabIndex': 3}),
          ),
        );
        break;
      case '/sales':
      case '/sales/orders':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SalesScreen(),
            settings: const RouteSettings(arguments: {'tabIndex': 0}),
          ),
        );
        break;
      case '/sales/customers':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SalesScreen(),
            settings: const RouteSettings(arguments: {'tabIndex': 1}),
          ),
        );
        break;
      case '/sales/invoices':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SalesScreen(),
            settings: const RouteSettings(arguments: {'tabIndex': 2}),
          ),
        );
        break;
      case '/sales/ecommerce':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SalesScreen(),
            settings: const RouteSettings(arguments: {'tabIndex': 3}),
          ),
        );
        break;
      default:
        // For now, just show a placeholder
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigating to: $route'),
            duration: const Duration(seconds: 1),
          ),
        );
        break;
    }
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.textSecondary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor,
                child: const Icon(
                  Icons.person,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin User',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'admin@inventory.com',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'v1.0.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarItem {
  final String title;
  final IconData icon;
  final String route;
  final List<SidebarItem> children;

  SidebarItem({
    required this.title,
    required this.icon,
    required this.route,
    this.children = const [],
  });
}
