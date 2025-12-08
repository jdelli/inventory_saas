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

class _POSScreenState extends State<POSScreen> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _tiltAnimation;

  @override
  void initState() {
    super.initState();
    _ensureAnimationsInitialized();
    
    // Load products if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
      if (inventoryProvider.products.isEmpty) {
        inventoryProvider.loadProducts();
      }
    });
  }

  void _ensureAnimationsInitialized() {
    if (_controller != null) return;
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _tiltAnimation = Tween<double>(begin: 0.1, end: 0.02).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeOutBack),
    );
    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to theme changes
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => POSProvider(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.3, -0.3),
              radius: 1.5,
              colors: isDark 
                ? [
                    const Color(0xFF2C3E50), // Slate Blue
                    const Color(0xFF1a252f), // Darker slate
                    const Color(0xFF0F172A), // Deep Navy
                  ]
                : [
                    const Color(0xFFF0F9FF), // Light Sky
                    const Color(0xFFE0F2FE), // Pale Blue
                    const Color(0xFFF1F5F9), // Light Grey
                  ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Column(
            children: [
              // Top Bar
              _buildTopBar(),

              // Main Workspace
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product Grid Area
                    Expanded(
                      flex: 65,
                      child: Container(
                       // Transparent container to let products float on background
                        padding: const EdgeInsets.only(left: 20, top: 10, bottom: 20, right: 10),
                        child: const POSProductGrid(),
                      ),
                    ),
                    
                    // Cart Panel Area (Floating Glass Effect)
                    Expanded(
                      flex: 35,
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 20, right: 20, left: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              offset: const Offset(-5, 10),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: const POSCartPanel(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final now = DateTime.now();
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              color: AppTheme.textPrimary,
              tooltip: 'Back to Dashboard',
            ),
          ),
          const SizedBox(width: 20),
          
          // POS Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                 BoxShadow(
                  color: const Color(0xFF4F46E5).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.point_of_sale, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Counter POS',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Date & Time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 18, color: AppTheme.primaryColor),
                const SizedBox(width: 10),
                Text(
                  '${dateFormat.format(now)}   ${timeFormat.format(now)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    fontFamily: 'RobotoMono', // Monospace for numbers looks cool if available, else fallback
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          
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
                    size: 24,
                  ),
                ),
                tooltip: 'Toggle Theme',
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'C1', 
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 14, 
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
