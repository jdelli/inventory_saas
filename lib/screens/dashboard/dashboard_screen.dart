import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory_saas/providers/auth_provider.dart';
import 'package:inventory_saas/providers/inventory_provider.dart';
import 'package:inventory_saas/providers/sales_provider.dart';
import 'package:inventory_saas/providers/supplier_provider.dart';
import 'package:inventory_saas/providers/theme_provider.dart';
import 'package:inventory_saas/utils/theme.dart';
import 'package:inventory_saas/widgets/dashboard/stat_card.dart';
import 'package:inventory_saas/widgets/dashboard/recent_orders_widget.dart';
import 'package:inventory_saas/widgets/dashboard/low_stock_widget.dart';
import 'package:inventory_saas/widgets/dashboard/sales_chart_widget.dart';
import 'package:inventory_saas/widgets/common/sidebar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isSidebarExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load all data when dashboard opens
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);

    await Future.wait([
      inventoryProvider.loadProducts(),
      salesProvider.loadSalesOrders(),
      supplierProvider.loadSuppliers(),
    ]);
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
            Icons.dashboard,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Dashboard',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // User Menu
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // TODO: Show notifications
                },
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notifications',
              ),
              const SizedBox(width: 8),
              // Theme Toggle
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return IconButton(
                    onPressed: () {
                      themeProvider.toggleTheme();
                    },
                    icon: Icon(
                      themeProvider.themeMode == ThemeMode.light 
                          ? Icons.dark_mode_outlined 
                          : Icons.light_mode_outlined,
                    ),
                    tooltip: themeProvider.themeMode == ThemeMode.light 
                        ? 'Switch to Dark Mode' 
                        : 'Switch to Light Mode',
                  );
                },
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor,
                child: const Icon(
                  Icons.person,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Message
          Text(
            'Welcome back!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s what\'s happening with your inventory today.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Statistics Cards
          _buildStatisticsCards(),
          const SizedBox(height: 32),

          // Charts and Recent Activity
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sales Chart
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales Overview',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(
                          height: 300,
                          child: SalesChartWidget(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              
              // Recent Orders
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Orders',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(
                          height: 300,
                          child: RecentOrdersWidget(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Low Stock Alerts
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Low Stock Alerts',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const LowStockWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Consumer3<InventoryProvider, SalesProvider, SupplierProvider>(
      builder: (context, inventoryProvider, salesProvider, supplierProvider, child) {
        return GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
                         StatCard(
               title: 'Total Products',
               value: inventoryProvider.totalProducts.toString(),
               icon: Icons.inventory_2,
               color: AppTheme.primaryColor,
               trend: '+12%',
               trendDirection: TrendDirection.up,
             ),
             StatCard(
               title: 'Total Sales',
               value: '\$${salesProvider.totalSales.toStringAsFixed(0)}',
               icon: Icons.trending_up,
               color: AppTheme.successColor,
               trend: '+8.5%',
               trendDirection: TrendDirection.up,
             ),
             StatCard(
               title: 'Low Stock Items',
               value: inventoryProvider.lowStockProducts.length.toString(),
               icon: Icons.warning,
               color: AppTheme.warningColor,
               trend: '-3%',
               trendDirection: TrendDirection.down,
             ),
             StatCard(
               title: 'Active Suppliers',
               value: supplierProvider.activeSuppliers.length.toString(),
               icon: Icons.business,
               color: AppTheme.infoColor,
               trend: '+2%',
               trendDirection: TrendDirection.up,
             ),
          ],
        );
      },
    );
  }
}
