import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory_saas/providers/inventory_provider.dart';
import 'package:inventory_saas/utils/theme.dart';
import 'package:inventory_saas/widgets/common/sidebar.dart';
import 'package:inventory_saas/widgets/inventory/products_tab.dart';
import 'package:inventory_saas/widgets/inventory/categories_tab.dart';
import 'package:inventory_saas/widgets/inventory/stock_movement_tab.dart';
import 'package:inventory_saas/widgets/inventory/barcode_scanner_tab.dart';
import 'package:inventory_saas/widgets/inventory/add_product_modal.dart';
import 'package:inventory_saas/models/product.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  bool _isSidebarExpanded = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
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
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    await inventoryProvider.loadProducts();
  }

  void _showAddProductModal() {
    showDialog(
      context: context,
      builder: (context) => AddProductModal(
        onProductAdded: (Product product) async {
          final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
          await inventoryProvider.addProduct(product);
        },
      ),
    );
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
              '/inventory/products',
              '/inventory/categories',
              '/inventory/movement',
              '/inventory/scanner'
            ][_selectedTabIndex],
          ),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // App Bar with Hamburger Button
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
            Icons.inventory_2_outlined,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Inventory Management',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          // Quick Actions
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.file_upload_outlined, size: 18),
                label: const Text('Import'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.file_download_outlined, size: 18),
                label: const Text('Export'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _showAddProductModal,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                Tab(text: 'All Products'),
                Tab(text: 'Categories'),
                Tab(text: 'Stock Movement'),
                Tab(text: 'Scanner'),
              ],
            ),
          ),
        ),
        
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              const ProductsTab(),
              const CategoriesTab(),
              const StockMovementTab(),
              const BarcodeScannerTab(),
            ],
          ),
        ),
      ],
    );
  }
}
