import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:inventory_saas/models/cart_item.dart';
import 'package:inventory_saas/providers/pos_provider.dart';
import 'dart:ui';

enum POSPanelView { cart, payment, success }

class POSCartPanel extends StatefulWidget {
  const POSCartPanel({super.key});

  @override
  State<POSCartPanel> createState() => _POSCartPanelState();
}

class _POSCartPanelState extends State<POSCartPanel> with TickerProviderStateMixin {
  POSPanelView _currentView = POSPanelView.cart;
  String _amountString = '';
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  bool _isProcessing = false;
  String? _completedOrderId;

  double get _amountTendered => double.tryParse(_amountString) ?? 0;

  void _switchToPayment() {
    setState(() {
      _currentView = POSPanelView.payment;
      _amountString = '';
      _selectedMethod = PaymentMethod.cash;
    });
  }

  void _switchToCart() {
    setState(() => _currentView = POSPanelView.cart);
  }

  void _onNumpadTap(String value) {
    HapticFeedback.lightImpact();
    setState(() {
      if (value == 'C') {
        _amountString = '';
      } else if (value == '⌫') {
        if (_amountString.isNotEmpty) {
          _amountString = _amountString.substring(0, _amountString.length - 1);
        }
      } else if (value == '.') {
        if (!_amountString.contains('.')) {
          _amountString += _amountString.isEmpty ? '0.' : '.';
        }
      } else {
        if (_amountString.length < 10) _amountString += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            const Color(0xFFFAFBFC),
          ],
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
        child: _buildCurrentView(context),
      ),
    );
  }

  Widget _buildCurrentView(BuildContext context) {
    switch (_currentView) {
      case POSPanelView.cart:
        return _buildCartView(context);
      case POSPanelView.payment:
        return _buildPaymentView(context);
      case POSPanelView.success:
        return _buildSuccessView(context);
    }
  }

  // ==================== CART VIEW ====================
  Widget _buildCartView(BuildContext context) {
    return Consumer<POSProvider>(
      key: const ValueKey('CartView'),
      builder: (context, pos, _) => Column(
        children: [
          _buildCartHeader(pos),
          Expanded(
            child: pos.isEmpty ? _buildEmptyCart() : _buildCartItems(pos),
          ),
          _buildCartFooter(pos),
        ],
      ),
    );
  }

  Widget _buildCartHeader(POSProvider pos) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE2E8F0).withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          // Cart Icon - 3D Style
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Order',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  '${pos.totalItems} ${pos.totalItems == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (pos.heldOrders.isNotEmpty) _buildHeldBadge(pos.heldOrders.length),
        ],
      ),
    );
  }

  Widget _buildHeldBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCD34D)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.pause_circle_filled_rounded, size: 14, color: Color(0xFFD97706)),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFFD97706),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No items yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap products to add them here',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(POSProvider pos) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: pos.cartItems.length,
      itemBuilder: (_, i) => _buildCartItemCard(pos, pos.cartItems[i]),
    );
  }

  Widget _buildCartItemCard(POSProvider pos, CartItem item) {
    return Dismissible(
      key: Key(item.product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => pos.removeFromCart(item.product.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFCA5A5), Color(0xFFEF4444)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 20),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Compact Quantity Control - 3D Stepper
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStepperBtn(Icons.add, () => pos.incrementQuantity(item.product.id)),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  _buildStepperBtn(Icons.remove, () => pos.decrementQuantity(item.product.id)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₱${item.unitPrice.toStringAsFixed(2)} each',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            // Line Total
            Text(
              '₱${item.lineTotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: Color(0xFF2563EB),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: const Color(0xFF3B82F6)),
        ),
      ),
    );
  }

  Widget _buildCartFooter(POSProvider pos) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary Rows - Compact
          _buildSummaryRow('Subtotal', pos.subtotal),
          if (pos.globalDiscountAmount > 0)
            _buildSummaryRow('Discount', -pos.globalDiscountAmount, isNegative: true),
          _buildSummaryRow('VAT (${pos.taxPercent.toInt()}%)', pos.taxAmount),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          // Total Row - Prominent
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
                ),
                child: Text(
                  '₱${pos.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2563EB),
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Action Buttons - 3D
          Row(
            children: [
              // Hold Button - 3D Outline
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: OutlinedButton.icon(
                    onPressed: pos.isEmpty ? null : pos.holdOrder,
                    icon: const Icon(Icons.pause_rounded, size: 18),
                    label: const Text('Hold'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF475569),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: pos.isEmpty ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Charge Button - 3D Elevated
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: pos.isEmpty
                        ? null
                        : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                          ),
                    color: pos.isEmpty ? const Color(0xFFE2E8F0) : null,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: pos.isEmpty
                        ? null
                        : [
                            BoxShadow(
                              color: const Color(0xFF16A34A).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: pos.isEmpty ? null : _switchToPayment,
                    icon: const Icon(Icons.payments_rounded, size: 20),
                    label: const Text(
                      'Charge',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      disabledForegroundColor: const Color(0xFF94A3B8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
            ),
          ),
          Text(
            '${isNegative ? "-" : ""}₱${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isNegative ? const Color(0xFFEF4444) : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PAYMENT VIEW ====================
  Widget _buildPaymentView(BuildContext context) {
    return Consumer<POSProvider>(
      key: const ValueKey('PaymentView'),
      builder: (context, pos, _) {
        final total = pos.total;
        final change = _amountTendered - total;

        return Column(
          children: [
            _buildPaymentHeader(total),
            _buildPaymentMethods(),
            Expanded(child: _buildNumpad(total, change)),
            _buildPaymentAction(pos, total, change),
          ],
        );
      },
    );
  }

  Widget _buildPaymentHeader(double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Back Button - Glassmorphism
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: IconButton(
                        onPressed: _switchToCart,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                        constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Payment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Amount Due',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '₱${total.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final methods = [
      (PaymentMethod.cash, Icons.payments_rounded, 'Cash'),
      (PaymentMethod.card, Icons.credit_card_rounded, 'Card'),
      (PaymentMethod.gcash, Icons.phone_android_rounded, 'GCash'),
      (PaymentMethod.maya, Icons.account_balance_wallet_rounded, 'Maya'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: methods.map((m) {
          final isSelected = _selectedMethod == m.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedMethod = m.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      m.$2,
                      size: 20,
                      color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      m.$3,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNumpad(double total, double change) {
    if (_selectedMethod != PaymentMethod.cash) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.qr_code_2_rounded,
                size: 56,
                color: const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ready for ${_selectedMethod.name.toUpperCase()}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Amount Display - 3D Inset
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Amount Tendered',
                  style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  _amountString.isEmpty ? '₱0' : '₱$_amountString',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          // Change Indicator - 3D
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: change >= 0
                    ? [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)]
                    : [const Color(0xFFFEF2F2), const Color(0xFFFEE2E2)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: change >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  change >= 0 ? 'Change' : 'Remaining',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: change >= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                  ),
                ),
                Text(
                  '₱${change.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: change >= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
          // Numpad Grid - 3D Keys
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2,
              physics: const NeverScrollableScrollPhysics(),
              children: ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'C', '0', '⌫']
                  .map((v) => _buildNumpadKey(v))
                  .toList(),
            ),
          ),
          // Quick Amounts - 3D Pills
          const SizedBox(height: 8),
          Row(
            children: [total, 500.0, 1000.0, 2000.0].map((amt) {
              final isExact = amt == total;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _amountString = amt.toStringAsFixed(0)),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isExact ? const Color(0xFFECFDF5) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isExact ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          isExact ? 'Exact' : '₱${amt.toInt()}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isExact ? const Color(0xFF059669) : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNumpadKey(String value) {
    final isSpecial = value == 'C' || value == '⌫';
    return Material(
      color: isSpecial ? const Color(0xFFE2E8F0) : Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 0,
      child: InkWell(
        onTap: () => _onNumpadTap(value),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isSpecial ? const Color(0xFF64748B) : const Color(0xFF1E293B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentAction(POSProvider pos, double total, double change) {
    final canComplete = _selectedMethod != PaymentMethod.cash || _amountTendered >= total;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: canComplete
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                )
              : null,
          color: canComplete ? null : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(14),
          boxShadow: canComplete
              ? [
                  BoxShadow(
                    color: const Color(0xFF16A34A).withOpacity(0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: !canComplete || _isProcessing ? null : () => _completePayment(pos),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.transparent,
            disabledForegroundColor: const Color(0xFF94A3B8),
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _isProcessing
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Complete Payment',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _completePayment(POSProvider pos) async {
    setState(() => _isProcessing = true);
    try {
      final orderId = await pos.checkout(_selectedMethod, _amountTendered);
      _completedOrderId = orderId;
      setState(() {
        _currentView = POSPanelView.success;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // ==================== SUCCESS VIEW ====================
  Widget _buildSuccessView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success Icon - 3D Animated
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF16A34A).withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.check_rounded, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 24),
          const Text(
            'Payment Successful!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Order #${_completedOrderId ?? "-"}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          // New Order Button - 3D
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _currentView = POSPanelView.cart),
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: const Text(
                'New Order',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Print Receipt Button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.print_rounded),
              label: const Text('Print Receipt'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF475569),
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
