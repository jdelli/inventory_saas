import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:inventory_saas/models/cart_item.dart';
import 'package:inventory_saas/providers/pos_provider.dart';

enum POSPanelView { cart, payment, success }

class POSCartPanel extends StatefulWidget {
  const POSCartPanel({super.key});

  @override
  State<POSCartPanel> createState() => _POSCartPanelState();
}

class _POSCartPanelState extends State<POSCartPanel>
    with SingleTickerProviderStateMixin {
  POSPanelView _currentView = POSPanelView.cart;
  String _amountString = '';
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  bool _isProcessing = false;
  String? _completedOrderId;

  double get _amountTendered => double.tryParse(_amountString) ?? 0;

  void _switchToPayment() {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentView = POSPanelView.payment;
      _amountString = '';
      _selectedMethod = PaymentMethod.cash;
    });
  }

  void _switchToCart() {
    HapticFeedback.lightImpact();
    setState(() => _currentView = POSPanelView.cart);
  }

  void _onNumpadTap(String value) {
    HapticFeedback.selectionClick();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF151D2E) : Colors.white,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        child: _buildCurrentView(context, isDark),
      ),
    );
  }

  Widget _buildCurrentView(BuildContext context, bool isDark) {
    switch (_currentView) {
      case POSPanelView.cart:
        return _buildCartView(context, isDark);
      case POSPanelView.payment:
        return _buildPaymentView(context, isDark);
      case POSPanelView.success:
        return _buildSuccessView(context, isDark);
    }
  }

  // ==================== CART VIEW ====================
  Widget _buildCartView(BuildContext context, bool isDark) {
    return Consumer<POSProvider>(
      key: const ValueKey('CartView'),
      builder: (context, pos, _) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCartHeader(pos, isDark),
            const SizedBox(height: 16),
            Expanded(
              child: pos.isEmpty
                  ? _buildEmptyCart(isDark)
                  : _buildCartItems(pos, isDark),
            ),
            const SizedBox(height: 16),
            _buildCartFooter(pos, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCartHeader(POSProvider pos, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(isDark ? 0.2 : 0.08),
            colorScheme.primary.withOpacity(isDark ? 0.1 : 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary,
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
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Order',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${pos.totalItems} ${pos.totalItems == 1 ? 'item' : 'items'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    if (pos.heldOrders.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.pause_circle_rounded,
                              size: 14,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${pos.heldOrders.length} held',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.04)
                  : const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap products on the left to add them',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(POSProvider pos, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: pos.cartItems.length,
      itemBuilder: (_, i) => _buildCartItemCard(pos, pos.cartItems[i], isDark),
    );
  }

  Widget _buildCartItemCard(POSProvider pos, CartItem item, bool isDark) {
    return Dismissible(
      key: Key(item.product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        pos.removeFromCart(item.product.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFEF4444).withOpacity(0.0),
              const Color(0xFFEF4444).withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.04)
              : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : const Color(0xFF64748B).withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Quantity Stepper
            _buildQuantityStepper(
              onIncrement: () {
                HapticFeedback.selectionClick();
                pos.incrementQuantity(item.product.id);
              },
              onDecrement: () {
                HapticFeedback.selectionClick();
                pos.decrementQuantity(item.product.id);
              },
              quantity: item.quantity,
              isDark: isDark,
            ),
            const SizedBox(width: 12),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.product.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₱${item.unitPrice.toStringAsFixed(2)} each',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Price & Remove
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₱${item.lineTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.primary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    pos.removeFromCart(item.product.id);
                  },
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityStepper({
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required int quantity,
    required bool isDark,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStepperButton(
            icon: Icons.remove_rounded,
            onTap: onDecrement,
            isDark: isDark,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 36),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          _buildStepperButton(
            icon: Icons.add_rounded,
            onTap: onIncrement,
            isDark: isDark,
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    bool isPrimary = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isPrimary
          ? colorScheme.primary.withOpacity(0.1)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 18,
            color: isPrimary
                ? colorScheme.primary
                : isDark
                    ? Colors.white54
                    : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildCartFooter(POSProvider pos, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF64748B).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : const Color(0xFF64748B).withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary Rows
          _buildSummaryRow('Subtotal', pos.subtotal, isDark: isDark),
          if (pos.globalDiscountAmount > 0)
            _buildSummaryRow(
              'Discount',
              -pos.globalDiscountAmount,
              isDark: isDark,
              isNegative: true,
            ),
          _buildSummaryRow(
            'VAT (${pos.taxPercent.toInt()}%)',
            pos.taxAmount,
            isDark: isDark,
          ),

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  isDark
                      ? Colors.white.withOpacity(0.1)
                      : const Color(0xFFE2E8F0),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '₱${pos.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: colorScheme.primary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              // Hold Button
              Expanded(
                child: _buildActionButton(
                  icon: Icons.pause_rounded,
                  label: 'Hold',
                  onPressed: pos.isEmpty ? null : pos.holdOrder,
                  isDark: isDark,
                  isSecondary: true,
                ),
              ),
              const SizedBox(width: 12),
              // Charge Button
              Expanded(
                flex: 2,
                child: _buildActionButton(
                  icon: Icons.payments_rounded,
                  label: 'Charge ₱${pos.total.toStringAsFixed(2)}',
                  onPressed: pos.isEmpty ? null : _switchToPayment,
                  isDark: isDark,
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    required bool isDark,
    bool isNegative = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : const Color(0xFF64748B),
            ),
          ),
          Text(
            '${isNegative ? "-" : ""}₱${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isNegative
                  ? const Color(0xFFEF4444)
                  : isDark
                      ? Colors.white70
                      : const Color(0xFF475569),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required bool isDark,
    bool isPrimary = false,
    bool isSecondary = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDisabled = onPressed == null;

    Color backgroundColor;
    Color foregroundColor;

    if (isPrimary) {
      backgroundColor = isDisabled
          ? colorScheme.primary.withOpacity(0.3)
          : colorScheme.primary;
      foregroundColor = Colors.white;
    } else if (isSecondary) {
      backgroundColor = isDark
          ? Colors.white.withOpacity(isDisabled ? 0.03 : 0.08)
          : isDisabled
              ? const Color(0xFFF1F5F9)
              : Colors.white;
      foregroundColor = isDisabled
          ? (isDark ? Colors.white24 : const Color(0xFFCBD5E1))
          : (isDark ? Colors.white70 : const Color(0xFF475569));
    } else {
      backgroundColor = Colors.transparent;
      foregroundColor = isDark ? Colors.white70 : const Color(0xFF475569);
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14),
      elevation: isPrimary && !isDisabled ? 6 : 0,
      shadowColor: isPrimary ? colorScheme.primary.withOpacity(0.4) : null,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: isSecondary && !isDisabled
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.2)
                          : const Color(0xFF64748B).withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      spreadRadius: -1,
                    ),
                  ],
                )
              : isPrimary && !isDisabled
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    )
                  : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: foregroundColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== PAYMENT VIEW ====================
  Widget _buildPaymentView(BuildContext context, bool isDark) {
    return Consumer<POSProvider>(
      key: const ValueKey('PaymentView'),
      builder: (context, pos, _) {
        final total = pos.total;
        final change = _amountTendered - total;

        return Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent && _selectedMethod == PaymentMethod.cash) {
              final key = event.logicalKey;

              // Handle numpad and regular number keys
              if (key == LogicalKeyboardKey.numpad0 || key == LogicalKeyboardKey.digit0) {
                _onNumpadTap('0');
                return KeyEventResult.handled;
              } else if (key == LogicalKeyboardKey.numpad1 || key == LogicalKeyboardKey.digit1) {
                _onNumpadTap('1');
                return KeyEventResult.handled;
              } else if (key == LogicalKeyboardKey.numpad2 || key == LogicalKeyboardKey.digit2) {
                _onNumpadTap('2');
                return KeyEventResult.handled;
              } else if (key == LogicalKeyboardKey.numpad3 || key == LogicalKeyboardKey.digit3) {
                _onNumpadTap('3');
                return KeyEventResult.handled;
              } else if (key == LogicalKeyboardKey.numpad4 || key == LogicalKeyboardKey.digit4) {
                _onNumpadTap('4');
                return KeyEventResult.handled;
              } else if (key == LogicalKeyboardKey.numpad5 || key == LogicalKeyboardKey.digit5) {
                _onNumpadTap('5');
                return KeyEventResult.handled;
              } else if (key == LogicalKeyboardKey.numpad6 || key == LogicalKeyboardKey.digit6) {
                _onNumpadTap('6');
                return KeyEventResult.handled;
              } else if (key == LogicalKeyboardKey.numpad7 || key == LogicalKeyboardKey.digit7) {
                _onNumpadTap('7');
                return KeyEventResult.handled;
              } else if (key == LogicalKeyboardKey.numpad8 || key == LogicalKeyboardKey.digit8) {
                _onNumpadTap('8');
                return KeyEventResult.handled;
              } else if (key == LogicalKeyboardKey.numpad9 || key == LogicalKeyboardKey.digit9) {
                _onNumpadTap('9');
                return KeyEventResult.handled;
              } else if (key == LogicalKeyboardKey.numpadDecimal || key == LogicalKeyboardKey.period) {
                _onNumpadTap('.');
                return KeyEventResult.handled;
              } else if (key == LogicalKeyboardKey.backspace || key == LogicalKeyboardKey.delete) {
                _onNumpadTap('⌫');
                return KeyEventResult.handled;
              } else if (key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.keyC) {
                _onNumpadTap('C');
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildPaymentHeader(total, isDark),
                const SizedBox(height: 16),
                _buildPaymentMethods(isDark),
                const SizedBox(height: 16),
                Expanded(child: _buildNumpadOrReady(total, change, isDark)),
                const SizedBox(height: 16),
                _buildPaymentAction(pos, total, change, isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentHeader(double total, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF64748B).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          Material(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _switchToCart,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Select method & amount',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          // Amount Due
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Amount Due',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '₱${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(bool isDark) {
    final methods = [
      (PaymentMethod.cash, Icons.payments_rounded, 'Cash'),
      (PaymentMethod.card, Icons.credit_card_rounded, 'Card'),
      (PaymentMethod.gcash, Icons.phone_android_rounded, 'GCash'),
      (PaymentMethod.maya, Icons.account_balance_wallet_rounded, 'Maya'),
    ];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: methods.map((m) {
          final isSelected = _selectedMethod == m.$1;
          return Expanded(
            child: _buildPaymentMethodButton(
              method: m.$1,
              icon: m.$2,
              label: m.$3,
              isSelected: isSelected,
              isDark: isDark,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentMethodButton({
    required PaymentMethod method,
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool isDark,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected
          ? colorScheme.primary
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedMethod = method);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Colors.white
                    : isDark
                        ? Colors.white54
                        : const Color(0xFF64748B),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? Colors.white54
                          : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumpadOrReady(double total, double change, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_selectedMethod != PaymentMethod.cash) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.2),
                    colorScheme.primary.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.qr_code_2_rounded,
                size: 56,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Ready for ${_selectedMethod.name.toUpperCase()}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap complete when done',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Amount Display
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.04)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Amount Tendered',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                    ),
                  ),
                  if (_amountString.isNotEmpty)
                    GestureDetector(
                      onTap: () => _onNumpadTap('C'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _amountString.isEmpty ? '₱0.00' : '₱$_amountString',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: change >= 0
                      ? const Color(0xFF10B981).withOpacity(0.15)
                      : const Color(0xFFEF4444).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          change >= 0
                              ? Icons.check_circle_rounded
                              : Icons.error_rounded,
                          size: 18,
                          color: change >= 0
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          change >= 0 ? 'Change' : 'Remaining',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: change >= 0
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₱${change.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: change >= 0
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Numpad
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.6,
              physics: const NeverScrollableScrollPhysics(),
              children: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', '⌫']
                  .map((v) => _buildNumpadButton(v, isDark))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Quick Amount Buttons
        Row(
          children: [total, 500.0, 1000.0, 2000.0].map((amt) {
            final isExact = amt == total;
            final isSelected = _amountString == amt.toStringAsFixed(0);

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Material(
                  color: isSelected
                      ? colorScheme.primary
                      : isDark
                          ? Colors.white.withOpacity(0.06)
                          : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _amountString = amt.toStringAsFixed(0));
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        isExact ? 'Exact' : '₱${amt.toInt()}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : isDark
                                  ? Colors.white70
                                  : const Color(0xFF475569),
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
    );
  }

  Widget _buildNumpadButton(String value, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;
    final isAction = value == '⌫';
    final isDecimal = value == '.';

    return Material(
      color: isAction
          ? (isDark
              ? Colors.white.withOpacity(0.04)
              : const Color(0xFFF1F5F9))
          : (isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.white),
      borderRadius: BorderRadius.circular(12),
      elevation: isAction ? 0 : (isDark ? 2 : 4),
      shadowColor: isDark ? Colors.black : const Color(0xFF64748B).withOpacity(0.15),
      child: InkWell(
        onTap: () => _onNumpadTap(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isAction
                ? null
                : Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : const Color(0xFFE2E8F0),
                  ),
            boxShadow: isAction
                ? null
                : [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.3)
                          : const Color(0xFF64748B).withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      spreadRadius: -1,
                    ),
                  ],
          ),
          child: Center(
            child: value == '⌫'
                ? Icon(
                    Icons.backspace_outlined,
                    size: 22,
                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: isDecimal ? 36 : 22,
                      fontWeight: FontWeight.w700,
                      height: isDecimal ? 0.5 : 1.0,
                      color: isAction
                          ? (isDark
                              ? Colors.white54
                              : const Color(0xFF64748B))
                          : (isDark
                              ? Colors.white
                              : const Color(0xFF1E293B)),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentAction(
      POSProvider pos, double total, double change, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;
    final canComplete =
        _selectedMethod != PaymentMethod.cash || _amountTendered >= total;

    return Material(
      color: !canComplete || _isProcessing
          ? colorScheme.primary.withOpacity(0.3)
          : colorScheme.primary,
      borderRadius: BorderRadius.circular(16),
      elevation: canComplete && !_isProcessing ? 8 : 0,
      shadowColor: colorScheme.primary.withOpacity(0.4),
      child: InkWell(
        onTap: !canComplete || _isProcessing
            ? null
            : () => _completePayment(pos),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: canComplete && !_isProcessing
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: -4,
                    ),
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                )
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isProcessing) ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white70),
                  ),
                ),
                const SizedBox(width: 12),
              ] else ...[
                const Icon(
                  Icons.check_circle_rounded,
                  size: 22,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
              ],
              Text(
                _isProcessing ? 'Processing...' : 'Complete Payment',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completePayment(POSProvider pos) async {
    HapticFeedback.heavyImpact();
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
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  // ==================== SUCCESS VIEW ====================
  Widget _buildSuccessView(BuildContext context, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      key: const ValueKey('SuccessView'),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success Animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10B981),
                    const Color(0xFF059669),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 56,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Success Text
          Text(
            'Payment Successful!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Order #${_completedOrderId ?? "-"}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),

          const Spacer(),

          // Action Buttons
          Material(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                setState(() => _currentView = POSPanelView.cart);
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.add_shopping_cart_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'New Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.print_rounded,
                      size: 22,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Print Receipt',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
