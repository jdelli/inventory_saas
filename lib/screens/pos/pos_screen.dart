import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:inventory_saas/providers/pos_provider.dart';
import 'package:inventory_saas/providers/inventory_provider.dart';
import 'package:inventory_saas/providers/theme_provider.dart';
import 'package:inventory_saas/widgets/pos/pos_cart_panel.dart';
import 'package:inventory_saas/widgets/pos/pos_product_grid.dart';
import 'package:intl/intl.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _fadeController;
  Animation<double>? _fadeAnimation;
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _startClock();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final inventoryProvider = Provider.of<InventoryProvider>(
        context,
        listen: false,
      );
      if (inventoryProvider.products.isEmpty) {
        inventoryProvider.loadProducts();
      }
    });
  }

  void _initAnimation() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController!,
      curve: Curves.easeOutCubic,
    );
    _fadeController!.forward();
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => POSProvider(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(child: _buildBackground(isDark, colorScheme)),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTopBar(context),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Row(
                          children: [
                            // Product Grid - Left Panel (3D Effect)
                            Expanded(
                              flex: 68,
                              child: Transform(
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001) // Perspective
                                  ..rotateY(-0.01) // Slight Y rotation
                                  ..rotateX(0.005), // Slight X rotation
                                alignment: FractionalOffset.center,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isDark
                                          ? [
                                              const Color(0xFF1A2332),
                                              const Color(0xFF0F1625),
                                              const Color(0xFF0A0F1C),
                                            ]
                                          : [
                                              const Color(0xFFFFFFFF),
                                              const Color(0xFFF8FBFF),
                                              const Color(0xFFF2F6FA),
                                            ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      width: 2,
                                      color: isDark
                                          ? Colors.white.withOpacity(0.12)
                                          : const Color(0xFFE2E8F0),
                                    ),
                                    boxShadow: [
                                      // Primary depth shadow
                                      BoxShadow(
                                        color: isDark
                                            ? Colors.black.withOpacity(0.6)
                                            : const Color(0xFF1F2937).withOpacity(0.15),
                                        blurRadius: 48,
                                        offset: const Offset(-8, 24),
                                        spreadRadius: -2,
                                      ),
                                      // Mid shadow
                                      BoxShadow(
                                        color: isDark
                                            ? Colors.black.withOpacity(0.5)
                                            : const Color(0xFF1E293B).withOpacity(0.1),
                                        blurRadius: 28,
                                        offset: const Offset(-4, 12),
                                      ),
                                      // Ambient shadow
                                      BoxShadow(
                                        color: isDark
                                            ? Colors.black.withOpacity(0.4)
                                            : const Color(0xFF64748B).withOpacity(0.08),
                                        blurRadius: 16,
                                        offset: const Offset(-2, 6),
                                      ),
                                      // Inner highlight
                                      BoxShadow(
                                        color: isDark
                                            ? Colors.white.withOpacity(0.03)
                                            : Colors.white.withOpacity(0.8),
                                        blurRadius: 12,
                                        offset: const Offset(2, -2),
                                        spreadRadius: -4,
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: const POSProductGrid(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Cart Panel - Right Panel (3D Glass Effect)
                            Expanded(
                              flex: 32,
                              child: Transform(
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001) // Perspective
                                  ..rotateY(0.01) // Slight Y rotation (opposite direction)
                                  ..rotateX(0.005), // Slight X rotation
                                alignment: FractionalOffset.center,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isDark
                                          ? [
                                              const Color(0xFF1C2638).withOpacity(0.95),
                                              const Color(0xFF151D30).withOpacity(0.95),
                                              const Color(0xFF0D1423).withOpacity(0.95),
                                            ]
                                          : [
                                              Colors.white.withOpacity(0.98),
                                              const Color(0xFFF9FBFE).withOpacity(0.98),
                                              const Color(0xFFF3F7FB).withOpacity(0.98),
                                            ],
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      width: 2,
                                      color: isDark
                                          ? Colors.white.withOpacity(0.15)
                                          : Colors.white.withOpacity(0.9),
                                    ),
                                    boxShadow: [
                                      // Primary depth shadow
                                      BoxShadow(
                                        color: isDark
                                            ? Colors.black.withOpacity(0.65)
                                            : const Color(0xFF1F2937).withOpacity(0.18),
                                        blurRadius: 52,
                                        offset: const Offset(8, 26),
                                        spreadRadius: -2,
                                      ),
                                      // Mid shadow
                                      BoxShadow(
                                        color: isDark
                                            ? Colors.black.withOpacity(0.55)
                                            : const Color(0xFF1E293B).withOpacity(0.12),
                                        blurRadius: 32,
                                        offset: const Offset(4, 14),
                                      ),
                                      // Ambient shadow
                                      BoxShadow(
                                        color: isDark
                                            ? Colors.black.withOpacity(0.45)
                                            : const Color(0xFF64748B).withOpacity(0.1),
                                        blurRadius: 18,
                                        offset: const Offset(2, 8),
                                      ),
                                      // Glass reflection highlight
                                      BoxShadow(
                                        color: isDark
                                            ? Colors.white.withOpacity(0.05)
                                            : Colors.white,
                                        blurRadius: 16,
                                        offset: const Offset(-2, -3),
                                        spreadRadius: -6,
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
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
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('EEEE, MMMM d');
    final timeFormat = DateFormat('hh:mm:ss a');
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(-0.005), // Slight tilt for depth
      alignment: FractionalOffset.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF1A2435),
                    const Color(0xFF141D2E),
                    const Color(0xFF0F1625),
                  ]
                : [
                    Colors.white,
                    const Color(0xFFFAFCFF),
                    const Color(0xFFF5F8FB),
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            width: 2,
            color: isDark
                ? Colors.white.withOpacity(0.12)
                : const Color(0xFFE8ECF1),
          ),
          boxShadow: [
            // Top bevel highlight
            BoxShadow(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.95),
              offset: const Offset(0, -1),
              blurRadius: 3,
              spreadRadius: 0,
            ),
            // Main depth shadow
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.55)
                  : const Color(0xFF64748B).withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
              spreadRadius: -2,
            ),
            // Mid shadow for layering
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.45)
                  : const Color(0xFF64748B).withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 5),
              spreadRadius: -1,
            ),
            // Bottom edge for bevel
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.7)
                  : const Color(0xFF94A3B8).withOpacity(0.18),
              offset: const Offset(0, 1),
              blurRadius: 0,
            ),
          ],
        ),
      child: Row(
        children: [
          // Back Button
          _buildIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back to Dashboard',
            isDark: isDark,
          ),
          const SizedBox(width: 16),

          // Store Info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'POS Terminal',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Downtown Branch',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.white60
                              : const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white24
                              : const Color(0xFFCBD5E1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        'Station A1',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.white60
                              : const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          
          const Spacer(),
          
          // Today's Stats Section
          Consumer<POSProvider>(
            builder: (context, posProvider, _) {
              return Row(
                children: [
                  // Total Sales Today
                  _buildStatCard(
                    icon: Icons.trending_up_rounded,
                    label: 'Sales Today',
                    value: currencyFormat.format(posProvider.todayTotalSales),
                    color: const Color(0xFF10B981),
                    isDark: isDark,
                    theme: theme,
                    isLoading: posProvider.statsLoading,
                  ),
                  const SizedBox(width: 10),
                  // Total Customers
                  _buildStatCard(
                    icon: Icons.people_rounded,
                    label: 'Customers',
                    value: posProvider.todayTotalCustomers.toString(),
                    color: const Color(0xFF8B5CF6),
                    isDark: isDark,
                    theme: theme,
                    isLoading: posProvider.statsLoading,
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(width: 10),

          // Quick Actions
          _buildActionButton(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Scan',
            onPressed: () {},
            isDark: isDark,
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 10),

          // Date & Time Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.04)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dateFormat.format(_currentTime),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                    Text(
                      timeFormat.format(_currentTime),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Theme Toggle
          _buildIconButton(
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            onPressed: () {
              HapticFeedback.lightImpact();
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
            isDark: isDark,
          ),
          const SizedBox(width: 10),

          // User Avatar
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.person_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Cashier 1',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
    required ThemeData theme,
    bool isLoading = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? color.withOpacity(0.12)
            : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white54 : const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
              isLoading
                  ? SizedBox(
                      width: 50,
                      height: 14,
                      child: LinearProgressIndicator(
                        backgroundColor: color.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    )
                  : Text(
                      value,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    required bool isDark,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    return Material(
      color: isDark
          ? colorScheme.primary.withOpacity(0.15)
          : colorScheme.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(bool isDark, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0A0F1A), const Color(0xFF0F172A)]
              : [const Color(0xFFEFF4FF), const Color(0xFFF8FBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -40,
            child: _buildGlowCircle(
              colorScheme.primary.withOpacity(isDark ? 0.12 : 0.16),
              240,
            ),
          ),
          Positioned(
            bottom: -160,
            right: -60,
            child: _buildGlowCircle(
              colorScheme.secondary.withOpacity(isDark ? 0.12 : 0.16),
              280,
            ),
          ),
          Positioned(
            top: 120,
            right: 220,
            child: _buildGlowCircle(
              Colors.white.withOpacity(isDark ? 0.05 : 0.4),
              160,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: size * 0.35,
            spreadRadius: size * 0.15,
          ),
        ],
      ),
    );
  }
}
