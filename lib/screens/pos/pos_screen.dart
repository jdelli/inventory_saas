import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory_saas/providers/pos_provider.dart';
import 'package:inventory_saas/providers/inventory_provider.dart';
import 'package:inventory_saas/providers/theme_provider.dart';
import 'package:inventory_saas/utils/theme.dart';
import 'package:inventory_saas/widgets/pos/pos_product_grid.dart';
import 'package:inventory_saas/widgets/pos/pos_cart_panel.dart';
import 'package:intl/intl.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  @override
  void initState() {
    super.initState();
    // Load products if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
      if (inventoryProvider.products.isEmpty) {
        inventoryProvider.loadProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => POSProvider(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            // Top Bar
            _buildTopBar(),
            
            // Main Content
            Expanded(
              child: Row(
                children: [
                  // Product Grid - 65%
                  Expanded(
                    flex: 65,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: const POSProductGrid(),
                    ),
                  ),
                  
                  // Cart Panel - 35%
                  const Expanded(
                    flex: 35,
                    child: POSCartPanel(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final now = DateTime.now();
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: AppTheme.textPrimary,
            tooltip: 'Back to Dashboard',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 20),
          
          // POS Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.point_of_sale, color: AppTheme.primaryColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Point of Sale',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Date & Time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Text(
                  '${dateFormat.format(now)} • ${timeFormat.format(now)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          
          // Actions
          Row(
            children: [
              IconButton(
                onPressed: () {
                   final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                   themeProvider.toggleTheme();
                },
                icon: Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) => Icon(
                    themeProvider.themeMode == ThemeMode.light
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    size: 20,
                  ),
                ),
                tooltip: 'Toggle Theme',
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.fullscreen, size: 20),
                tooltip: 'Fullscreen',
              ),
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor,
                child: const Text('C1', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
