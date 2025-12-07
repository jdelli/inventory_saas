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
    
    // Set initial tab based on arguments if provided
    if (widget.arguments != null && widget.arguments!['tabIndex'] != null) {
      _currentTabIndex = widget.arguments!['tabIndex'];
      _tabController.index = _currentTabIndex;
    }
    
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    
    _loadData();
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.shopping_cart,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Sales Management',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          
          // Quick Actions
          Row(
            children: [
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  // TODO: Show sales analytics
                },
                icon: const Icon(Icons.analytics_outlined),
                tooltip: 'Sales Analytics',
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  // TODO: Show notifications
                },
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notifications',
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
          color: Theme.of(context).cardColor,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
            tabs: const [
              Tab(
                icon: Icon(Icons.receipt),
                text: 'Orders',
              ),
              Tab(
                icon: Icon(Icons.people),
                text: 'Customers',
              ),
              Tab(
                icon: Icon(Icons.description),
                text: 'Invoices',
              ),
              Tab(
                icon: Icon(Icons.store),
                text: 'E-commerce',
              ),
            ],
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
