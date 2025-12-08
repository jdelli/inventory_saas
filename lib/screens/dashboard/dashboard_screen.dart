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
import 'package:inventory_saas/screens/pos/pos_screen.dart';

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
            currentRoute: '/dashboard',
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
                   Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const POSScreen()),
                  );
                },
                icon: const Icon(Icons.point_of_sale),
                tooltip: 'Point of Sale',
              ),
              const SizedBox(width: 8),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20), // Compact padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Here/s what\'s happening with your inventory today.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Statistics Cards
              _buildStatisticsCards(isWide),
              const SizedBox(height: 16),

              // Charts and Recent Activity
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sales Chart
                    Expanded(
                      flex: 3,
                      child: _buildSalesChartCard(),
                    ),
                    const SizedBox(width: 16),
                    // Recent Orders
                    Expanded(
                      flex: 2,
                      child: _buildRecentOrdersCard(),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildSalesChartCard(),
                    const SizedBox(height: 16),
                    _buildRecentOrdersCard(),
                  ],
                ),
                
              const SizedBox(height: 16),

              // Low Stock Alerts
              _buildLowStockCard(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSalesChartCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sales Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // Optional: Time range filter dropdown could go here
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'This Week',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SizedBox(
              height: 300,
              child: SalesChartWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrdersCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Orders',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SizedBox(
              height: 300,
              child: RecentOrdersWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppTheme.warningColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Low Stock Alerts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const LowStockWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(bool isWide) {
    return Consumer3<InventoryProvider, SalesProvider, SupplierProvider>(
      builder: (context, inventoryProvider, salesProvider, supplierProvider, child) {
        final cards = [
           StatCard(
             title: 'Total Products',
             value: inventoryProvider.totalProducts.toString(),
             icon: Icons.inventory_2_outlined,
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
             title: 'Low Stock',
             value: inventoryProvider.lowStockProducts.length.toString(),
             icon: Icons.warning_amber_rounded,
             color: AppTheme.warningColor,
             trend: '-3%',
             trendDirection: TrendDirection.down,
           ),
           StatCard(
             title: 'Suppliers',
             value: supplierProvider.activeSuppliers.length.toString(),
             icon: Icons.business_outlined,
             color: AppTheme.infoColor,
             trend: '+2%',
             trendDirection: TrendDirection.up,
           ),
        ];

        if (!isWide) {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: cards.map((card) => SizedBox(
              width: (MediaQuery.of(context).size.width - 40 - 16) / 2, // 2 columns with padding calc
              child: card,
            )).toList(),
          );
        }

        return Row(
          children: cards.map((card) => Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: card,
            ),
          )).toList()..last = Expanded(child: cards.last), // Remove padding from last item
        );
      },
    );
  }
}
