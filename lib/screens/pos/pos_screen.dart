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
        backgroundColor: const Color(0xFFE8EDF5),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF0F4FA),
                Color(0xFFE8EDF5),
                Color(0xFFDFE6F0),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
            child: Column(
              children: [
                _build3DTopBar(),
                Expanded(
                  child: Row(
                    children: [
                      // Product Grid - 3D Neumorphic Panel
                      Expanded(
                        flex: 68,
                        child: Container(
                          margin: const EdgeInsets.only(left: 16, bottom: 16, right: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EDF5),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              // Dark shadow (bottom-right)
                              BoxShadow(
                                color: const Color(0xFFBEC8D9),
                                offset: const Offset(10, 10),
                                blurRadius: 25,
                                spreadRadius: 0,
                              ),
                              // Light shadow (top-left)
                              const BoxShadow(
                                color: Colors.white,
                                offset: Offset(-10, -10),
                                blurRadius: 25,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: const POSProductGrid(),
                          ),
                        ),
                      ),

                      // Cart Panel - 3D Neumorphic Card
                      Expanded(
                        flex: 32,
                        child: Container(
                          margin: const EdgeInsets.only(right: 16, bottom: 16, left: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EDF5),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              // Dark shadow (bottom-right)
                              BoxShadow(
                                color: const Color(0xFFBEC8D9),
                                offset: const Offset(10, 10),
                                blurRadius: 25,
                                spreadRadius: 0,
                              ),
                              // Light shadow (top-left)
                              const BoxShadow(
                                color: Colors.white,
                                offset: Offset(-10, -10),
                                blurRadius: 25,
                                spreadRadius: 0,
                              ),
                              // Accent glow
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.08),
                                offset: const Offset(0, 8),
                                blurRadius: 30,
                                spreadRadius: -5,
                              ),
                            ],
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
      ),
    );
  }

  Widget _build3DTopBar() {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('hh:mm a');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBEC8D9),
            offset: const Offset(6, 6),
            blurRadius: 18,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-6, -6),
            blurRadius: 18,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFFF8FAFC), const Color(0xFFF0F4FA)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Back Button - 3D Neumorphic
            _build3DNeumorphicButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(width: 14),

            // POS Badge - 3D Elevated Gradient
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4A8AF4), Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.5),
                    offset: const Offset(4, 4),
                    blurRadius: 14,
                  ),
                  BoxShadow(
                    color: const Color(0xFF60A5FA).withOpacity(0.3),
                    offset: const Offset(-2, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.storefront_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'POS Terminal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Date/Time - 3D Inset Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EDF5),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  // Inset effect
                  BoxShadow(
                    color: const Color(0xFFCCD5E3),
                    offset: const Offset(2, 2),
                    blurRadius: 5,
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    offset: Offset(-2, -2),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFF5B6B7F)),
                  const SizedBox(width: 10),
                  Text(
                    '${dateFormat.format(now)}  ${timeFormat.format(now)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151),
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Theme Toggle - 3D Neumorphic
            _build3DNeumorphicButton(
              icon: Icons.light_mode_rounded,
              onTap: () {
                final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                themeProvider.toggleTheme();
              },
              isAccent: true,
            ),
            const SizedBox(width: 10),

            // User Avatar - 3D Elevated Badge
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF34D399), Color(0xFF10B981)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.5),
                    offset: const Offset(4, 4),
                    blurRadius: 12,
                  ),
                  BoxShadow(
                    color: const Color(0xFF34D399).withOpacity(0.3),
                    offset: const Offset(-2, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'C1',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DNeumorphicButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isAccent = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFE8EDF5),
          borderRadius: BorderRadius.circular(12),
          gradient: isAccent
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                )
              : null,
          boxShadow: isAccent
              ? [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withOpacity(0.35),
                    offset: const Offset(3, 3),
                    blurRadius: 10,
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFFBEC8D9),
                    offset: const Offset(3, 3),
                    blurRadius: 8,
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    offset: Offset(-3, -3),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: isAccent ? const Color(0xFFD97706) : const Color(0xFF5B6B7F),
        ),
      ),
    );
  }
}
