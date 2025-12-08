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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF0F4FA),
            const Color(0xFFE8EDF5),
            const Color(0xFFE4EAF4),
          ],
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.08, 0),
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 3D Icon Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF818CF8), Color(0xFF6366F1)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.5),
                  offset: const Offset(4, 4),
                  blurRadius: 12,
                ),
                BoxShadow(
                  color: const Color(0xFFA5B4FC).withOpacity(0.3),
                  offset: const Offset(-2, -2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Order',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${pos.totalItems} ${pos.totalItems == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (pos.heldOrders.isNotEmpty) _build3DHeldBadge(pos.heldOrders.length),
        ],
      ),
    );
  }

  Widget _build3DHeldBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFCD34D), Color(0xFFF59E0B)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.4),
            offset: const Offset(3, 3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.pause_circle_filled_rounded, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            '$count held',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
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
          // 3D Neumorphic circle
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDF5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFBEC8D9),
                  offset: const Offset(10, 10),
                  blurRadius: 25,
                ),
                const BoxShadow(
                  color: Colors.white,
                  offset: Offset(-10, -10),
                  blurRadius: 25,
                ),
              ],
            ),
            child: const Icon(Icons.shopping_bag_outlined, size: 44, color: Color(0xFF8494A9)),
          ),
          const SizedBox(height: 20),
          const Text(
            'No items yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF4A5568)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap products to add them here',
            style: TextStyle(fontSize: 13, color: Color(0xFF8494A9)),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(POSProvider pos) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: pos.cartItems.length,
      itemBuilder: (_, i) => _build3DCartItemCard(pos, pos.cartItems[i]),
    );
  }

  Widget _build3DCartItemCard(POSProvider pos, CartItem item) {
    return Dismissible(
      key: Key(item.product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => pos.removeFromCart(item.product.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFCA5A5), Color(0xFFEF4444)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withOpacity(0.4),
              offset: const Offset(4, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 22),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EDF5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFBEC8D9),
              offset: const Offset(5, 5),
              blurRadius: 15,
            ),
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-5, -5),
              blurRadius: 15,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFFF5F8FC), const Color(0xFFEEF2F8)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // 3D Quantity Stepper
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EDF5),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _build3DStepperBtn(Icons.add, () => pos.incrementQuantity(item.product.id)),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1E293B)),
                      ),
                    ),
                    _build3DStepperBtn(Icons.remove, () => pos.decrementQuantity(item.product.id)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₱${item.unitPrice.toStringAsFixed(2)} each',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              // 3D Price Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.35),
                      offset: const Offset(3, 3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  '₱${item.lineTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DStepperBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 16, color: const Color(0xFF3B82F6)),
        ),
      ),
    );
  }

  Widget _buildCartFooter(POSProvider pos) {
    return Container(
      margin: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF5),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBEC8D9),
            offset: const Offset(8, 8),
            blurRadius: 20,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-8, -8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFFF8FAFC), const Color(0xFFF0F4FA)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryRow('Subtotal', pos.subtotal),
            if (pos.globalDiscountAmount > 0)
              _buildSummaryRow('Discount', -pos.globalDiscountAmount, isNegative: true),
            _buildSummaryRow('VAT (${pos.taxPercent.toInt()}%)', pos.taxAmount),
            const SizedBox(height: 12),
            // 3D Divider
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, const Color(0xFFCCD5E3), Colors.transparent],
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Total Row - 3D Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EDF5),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      // Inset effect
                      BoxShadow(
                        color: const Color(0xFFCCD5E3),
                        offset: const Offset(3, 3),
                        blurRadius: 6,
                      ),
                      const BoxShadow(
                        color: Colors.white,
                        offset: Offset(-3, -3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Text(
                    '₱${pos.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2563EB),
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // 3D Action Buttons
            Row(
              children: [
                // Hold Button - 3D Neumorphic
                Expanded(
                  child: _build3DButton(
                    onPressed: pos.isEmpty ? null : pos.holdOrder,
                    label: 'Hold',
                    icon: Icons.pause_rounded,
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 12),
                // Charge Button - 3D Elevated
                Expanded(
                  flex: 2,
                  child: _build3DButton(
                    onPressed: pos.isEmpty ? null : _switchToPayment,
                    label: 'Charge',
                    icon: Icons.payments_rounded,
                    gradient: const [Color(0xFF22C55E), Color(0xFF16A34A)],
                    shadowColor: const Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DButton({
    required VoidCallback? onPressed,
    required String label,
    required IconData icon,
    bool isOutlined = false,
    List<Color>? gradient,
    Color? shadowColor,
  }) {
    final isDisabled = onPressed == null;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isOutlined || isDisabled
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient ?? [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                ),
          color: isOutlined ? const Color(0xFFE8EDF5) : (isDisabled ? const Color(0xFFE2E8F0) : null),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isDisabled
              ? null
              : isOutlined
                  ? [
                      BoxShadow(
                        color: const Color(0xFFBEC8D9),
                        offset: const Offset(4, 4),
                        blurRadius: 10,
                      ),
                      const BoxShadow(
                        color: Colors.white,
                        offset: Offset(-4, -4),
                        blurRadius: 10,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: (shadowColor ?? const Color(0xFF2563EB)).withOpacity(0.5),
                        offset: const Offset(4, 4),
                        blurRadius: 15,
                      ),
                      BoxShadow(
                        color: (gradient?.first ?? const Color(0xFF60A5FA)).withOpacity(0.3),
                        offset: const Offset(-2, -2),
                        blurRadius: 8,
                      ),
                    ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isDisabled
                  ? const Color(0xFF94A3B8)
                  : isOutlined
                      ? const Color(0xFF4A5568)
                      : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDisabled
                    ? const Color(0xFF94A3B8)
                    : isOutlined
                        ? const Color(0xFF4A5568)
                        : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
          Text(
            '${isNegative ? "-" : ""}₱${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isNegative ? const Color(0xFFEF4444) : const Color(0xFF374151),
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
            _build3DPaymentHeader(total),
            _build3DPaymentMethods(),
            Expanded(child: _build3DNumpad(total, change)),
            _build3DPaymentAction(pos, total, change),
          ],
        );
      },
    );
  }

  Widget _build3DPaymentHeader(double total) {
    return Container(
      margin: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.5),
            offset: const Offset(6, 6),
            blurRadius: 20,
          ),
          BoxShadow(
            color: const Color(0xFF818CF8).withOpacity(0.3),
            offset: const Offset(-3, -3),
            blurRadius: 12,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 3D Back Button
                GestureDetector(
                  onTap: _switchToCart,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 14),
                const Text('Payment', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 18),
            Text('Amount Due', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(
              '₱${total.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DPaymentMethods() {
    final methods = [
      (PaymentMethod.cash, Icons.payments_rounded, 'Cash'),
      (PaymentMethod.card, Icons.credit_card_rounded, 'Card'),
      (PaymentMethod.gcash, Icons.phone_android_rounded, 'GCash'),
      (PaymentMethod.maya, Icons.account_balance_wallet_rounded, 'Maya'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: methods.map((m) {
          final isSelected = _selectedMethod == m.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedMethod = m.$1),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EDF5),
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.4),
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
                child: Column(
                  children: [
                    Icon(m.$2, size: 22, color: isSelected ? Colors.white : const Color(0xFF64748B)),
                    const SizedBox(height: 6),
                    Text(
                      m.$3,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : const Color(0xFF4A5568),
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

  Widget _build3DNumpad(double total, double change) {
    if (_selectedMethod != PaymentMethod.cash) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EDF5),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: const Color(0xFFBEC8D9), offset: const Offset(8, 8), blurRadius: 20),
                  const BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 20),
                ],
              ),
              child: const Icon(Icons.qr_code_2_rounded, size: 60, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            Text(
              'Ready for ${_selectedMethod.name.toUpperCase()}',
              style: const TextStyle(fontSize: 15, color: Color(0xFF4A5568), fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // 3D Amount Display
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDF5),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: const Color(0xFFCCD5E3), offset: const Offset(4, 4), blurRadius: 10),
                const BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 10),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFFF5F8FC), const Color(0xFFEEF2F8)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Amount Tendered', style: TextStyle(fontSize: 11, color: Color(0xFF8494A9), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                    _amountString.isEmpty ? '₱0' : '₱$_amountString',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                  ),
                ],
              ),
            ),
          ),
          // 3D Change Indicator
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: change >= 0
                    ? [const Color(0xFF34D399), const Color(0xFF10B981)]
                    : [const Color(0xFFFCA5A5), const Color(0xFFEF4444)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: (change >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(0.4),
                  offset: const Offset(4, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(change >= 0 ? 'Change' : 'Remaining', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
                Text('₱${change.abs().toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
              ],
            ),
          ),
          // 3D Numpad Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.8,
              physics: const NeverScrollableScrollPhysics(),
              children: ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'C', '0', '⌫'].map((v) => _build3DNumpadKey(v)).toList(),
            ),
          ),
          // Quick Amounts
          const SizedBox(height: 10),
          Row(
            children: [total, 500.0, 1000.0, 2000.0].map((amt) {
              final isExact = amt == total;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _amountString = amt.toStringAsFixed(0)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EDF5),
                        gradient: isExact
                            ? const LinearGradient(colors: [Color(0xFF34D399), Color(0xFF10B981)])
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isExact
                            ? [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.4), offset: const Offset(3, 3), blurRadius: 8)]
                            : [
                                BoxShadow(color: const Color(0xFFBEC8D9), offset: const Offset(2, 2), blurRadius: 6),
                                const BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 6),
                              ],
                      ),
                      child: Text(
                        isExact ? 'Exact' : '₱${amt.toInt()}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isExact ? Colors.white : const Color(0xFF4A5568),
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

  Widget _build3DNumpadKey(String value) {
    final isSpecial = value == 'C' || value == '⌫';
    return GestureDetector(
      onTap: () => _onNumpadTap(value),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE8EDF5),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: const Color(0xFFBEC8D9), offset: const Offset(4, 4), blurRadius: 10),
            const BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 10),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSpecial
                  ? [const Color(0xFFE4EAF4), const Color(0xFFDFE6F0)]
                  : [const Color(0xFFF8FAFC), const Color(0xFFF0F4FA)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isSpecial ? const Color(0xFF64748B) : const Color(0xFF1E293B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _build3DPaymentAction(POSProvider pos, double total, double change) {
    final canComplete = _selectedMethod != PaymentMethod.cash || _amountTendered >= total;

    return Container(
      padding: const EdgeInsets.all(14),
      child: _build3DButton(
        onPressed: !canComplete || _isProcessing ? null : () => _completePayment(pos),
        label: _isProcessing ? 'Processing...' : 'Complete Payment',
        icon: Icons.check_circle_rounded,
        gradient: const [Color(0xFF22C55E), Color(0xFF16A34A)],
        shadowColor: const Color(0xFF16A34A),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    }
  }

  // ==================== SUCCESS VIEW ====================
  Widget _buildSuccessView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 3D Success Badge
          Container(
            padding: const EdgeInsets.all(24),
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
                  offset: const Offset(8, 8),
                  blurRadius: 25,
                ),
                BoxShadow(
                  color: const Color(0xFF34D399).withOpacity(0.3),
                  offset: const Offset(-4, -4),
                  blurRadius: 15,
                ),
              ],
            ),
            child: const Icon(Icons.check_rounded, size: 56, color: Colors.white),
          ),
          const SizedBox(height: 28),
          const Text(
            'Payment Successful!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Text(
            'Order #${_completedOrderId ?? "-"}',
            style: const TextStyle(fontSize: 15, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          // 3D Buttons
          _build3DButton(
            onPressed: () => setState(() => _currentView = POSPanelView.cart),
            label: 'New Order',
            icon: Icons.add_shopping_cart_rounded,
          ),
          const SizedBox(height: 12),
          _build3DButton(
            onPressed: () {},
            label: 'Print Receipt',
            icon: Icons.print_rounded,
            isOutlined: true,
          ),
        ],
      ),
    );
  }
}
