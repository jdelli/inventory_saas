import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory_saas/providers/pos_provider.dart';
import 'package:inventory_saas/providers/inventory_provider.dart';
import 'package:inventory_saas/providers/theme_provider.dart';
import 'package:inventory_saas/widgets/pos/pos_product_grid.dart';
import 'package:inventory_saas/widgets/pos/pos_cart_panel.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> with SingleTickerProviderStateMixin {
  AnimationController? _fadeController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
      if (inventoryProvider.products.isEmpty) {
        inventoryProvider.loadProducts();
      }
    });
  }

  void _initAnimation() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController!,
      curve: Curves.easeOutCubic,
    );
    _fadeController!.forward();
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => POSProvider(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF8FAFC),
                Color(0xFFEEF2F6),
                Color(0xFFE2E8F0),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
            child: Column(
              children: [
                _buildCompactTopBar(),
                Expanded(
                  child: Row(
                    children: [
                      // Product Grid - 3D Inset Panel
                      Expanded(
                        flex: 68,
                        child: Container(
                          margin: const EdgeInsets.only(left: 16, bottom: 16, right: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              // Outer shadow for 3D lift
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                                spreadRadius: -4,
                              ),
                              // Inner highlight
                              BoxShadow(
                                color: Colors.white.withOpacity(0.9),
                                blurRadius: 0,
                                offset: const Offset(0, -1),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: const POSProductGrid(),
                          ),
                        ),
                      ),

                      // Cart Panel - Elevated 3D Card
                      Expanded(
                        flex: 32,
                        child: Container(
                          margin: const EdgeInsets.only(right: 16, bottom: 16, left: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              // Primary depth shadow
                              BoxShadow(
                                color: const Color(0xFF3B82F6).withOpacity(0.12),
                                blurRadius: 32,
                                offset: const Offset(-8, 12),
                                spreadRadius: -8,
                              ),
                              // Ambient shadow
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
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
      ),
    );
  }

  Widget _buildCompactTopBar() {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('hh:mm a');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          // Top highlight for 3D effect
          const BoxShadow(
            color: Colors.white,
            blurRadius: 0,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button - 3D Pressed Effect
          _build3DIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
            tooltip: 'Back',
          ),
          const SizedBox(width: 12),

          // POS Badge - Elevated 3D
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.storefront_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'POS Terminal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Date/Time Pill - Subtle 3D Inset
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                // Inset shadow effect
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule_rounded, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Text(
                  '${dateFormat.format(now)}  ${timeFormat.format(now)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Theme Toggle - 3D Switch
          _build3DIconButton(
            icon: Icons.light_mode_rounded,
            onTap: () {
              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              themeProvider.toggleTheme();
            },
            tooltip: 'Theme',
            isActive: true,
          ),
          const SizedBox(width: 8),

          // User Avatar - 3D Badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'C1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    bool isActive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isActive ? const Color(0xFFFCD34D) : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 18,
              color: isActive ? const Color(0xFFD97706) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}
