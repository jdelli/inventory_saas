import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory_saas/providers/sales_provider.dart';
import 'package:inventory_saas/utils/theme.dart';
import 'package:inventory_saas/widgets/common/sidebar.dart';
import 'package:inventory_saas/widgets/sales/orders_tab.dart';
import 'package:inventory_saas/widgets/sales/customers_tab.dart';
import 'package:inventory_saas/widgets/sales/invoices_tab.dart';
import 'package:inventory_saas/widgets/sales/ecommerce_tab.dart';

class SalesScreen extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  
  const SalesScreen({super.key, this.arguments});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> with TickerProviderStateMixin {
  bool _isSidebarExpanded = true;
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    _tabController.addListener(() {
      if (!mounted) return;
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    
    _loadData();
    _handleRouteArguments();
  }

  void _handleRouteArguments() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('tabIndex')) {
        final tabIndex = args['tabIndex'] as int;
        if (tabIndex >= 0 && tabIndex < 4) {
          _tabController.animateTo(tabIndex);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    await salesProvider.loadSalesOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Sidebar(
            isExpanded: _isSidebarExpanded,
            onToggle: () {
              setState(() {
                _isSidebarExpanded = !_isSidebarExpanded;
              });
            },
            currentRoute: const [
              '/sales/orders',
              '/sales/customers',
              '/sales/invoices',
              '/sales/ecommerce'
            ][_currentTabIndex],
          ),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // App Bar
                _buildAppBar(),
                
                // Content Area
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Sales Management',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          
          // Quick Actions
          Row(
            children: [
               IconButton(
                onPressed: () {},
                icon: const Icon(Icons.analytics_outlined, size: 20),
                tooltip: 'Sales Analytics',
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Create new order
                  _showCreateOrderDialog();
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Tab Bar
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              tabBarTheme: const TabBarThemeData(
                labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Poppins', fontSize: 14),
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.textSecondary,
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              tabs: const [
                Tab(text: 'Orders'),
                Tab(text: 'Customers'),
                Tab(text: 'Invoices'),
                Tab(text: 'E-commerce'),
              ],
            ),
          ),
        ),
        
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              OrdersTab(),
              CustomersTab(),
              InvoicesTab(),
              EcommerceTab(),
            ],
          ),
        ),
      ],
    );
  }

  void _showCreateOrderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Order'),
        content: const Text('This feature will be implemented soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
