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

class _POSCartPanelState extends State<POSCartPanel> {
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
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
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
      builder: (context, pos, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCartHeader(pos),
            const SizedBox(height: 8),
            Expanded(child: pos.isEmpty ? _buildEmptyCart() : _buildCartItems(pos)),
            const SizedBox(height: 12),
            _buildCartFooter(pos),
          ],
        ),
      ),
    );
  }

  Widget _buildCartHeader(POSProvider pos) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(Icons.receipt_long_rounded, color: colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Order',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  '${pos.totalItems} ${pos.totalItems == 1 ? 'item' : 'items'}',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
            const Spacer(),
            if (pos.heldOrders.isNotEmpty)
              Chip(
                label: Text('${pos.heldOrders.length} held'),
                avatar: const Icon(Icons.pause_circle_filled_rounded, size: 16),
                backgroundColor: colorScheme.secondaryContainer,
                labelStyle: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: colorScheme.surfaceContainerHighest,
            child: Icon(Icons.shopping_bag_outlined, size: 36, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Text('No items yet', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            'Tap products to add them here',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(POSProvider pos) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: pos.cartItems.length,
      itemBuilder: (_, i) => _buildCartItemCard(pos, pos.cartItems[i]),
    );
  }

  Widget _buildCartItemCard(POSProvider pos, CartItem item) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key(item.product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => pos.removeFromCart(item.product.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_rounded, color: colorScheme.onErrorContainer),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildQuantityStepper(
                onIncrement: () => pos.incrementQuantity(item.product.id),
                onDecrement: () => pos.decrementQuantity(item.product.id),
                quantity: item.quantity,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.product.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text('?${item.unitPrice.toStringAsFixed(2)} each'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '?${item.lineTotal.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      textAlign: TextAlign.right,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => pos.removeFromCart(item.product.id),
                      child: const Text('Remove'),
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

  Widget _buildQuantityStepper({
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required int quantity,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 78,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            tooltip: 'Decrease',
            onPressed: onDecrement,
            icon: const Icon(Icons.remove_rounded, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minHeight: 28, minWidth: 28),
            visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
          ),
          Text('$quantity', style: Theme.of(context).textTheme.titleMedium),
          IconButton(
            tooltip: 'Increase',
            onPressed: onIncrement,
            icon: const Icon(Icons.add_rounded, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minHeight: 28, minWidth: 28),
            visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
          ),
        ],
      ),
    );
  }

  Widget _buildCartFooter(POSProvider pos) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryRow('Subtotal', pos.subtotal, isMuted: true),
            if (pos.globalDiscountAmount > 0)
              _buildSummaryRow('Discount', -pos.globalDiscountAmount, isMuted: true, isNegative: true),
            _buildSummaryRow('VAT (${pos.taxPercent.toInt()}%)', pos.taxAmount, isMuted: true),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                Text(
                  '?${pos.total.toStringAsFixed(2)}',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.primary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: pos.isEmpty ? null : pos.holdOrder,
                    icon: const Icon(Icons.pause_rounded),
                    label: const Text('Hold'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: pos.isEmpty ? null : _switchToPayment,
                    icon: const Icon(Icons.payments_rounded),
                    label: const Text('Charge'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isNegative = false, bool isMuted = false}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: isMuted ? colorScheme.onSurfaceVariant : textTheme.bodyMedium?.color,
            ),
          ),
          Text(
            '${isNegative ? "-" : ""}?${amount.abs().toStringAsFixed(2)}',
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: isNegative ? colorScheme.error : textTheme.bodyLarge?.color,
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

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildPaymentHeader(total),
              const SizedBox(height: 12),
              _buildPaymentMethods(),
              const SizedBox(height: 12),
              Expanded(child: _buildNumpadOrReady(total, change)),
              const SizedBox(height: 12),
              _buildPaymentAction(pos, total, change),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentHeader(double total) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: _switchToCart,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    Text(
                      'Select method and enter tendered amount',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Amount Due', style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                Text(
                  '?${total.toStringAsFixed(2)}',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.primary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
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

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SegmentedButton<PaymentMethod>(
          segments: methods
              .map(
                (m) => ButtonSegment<PaymentMethod>(
                  value: m.$1,
                  icon: Icon(m.$2),
                  label: Text(m.$3),
                ),
              )
              .toList(),
          selected: {_selectedMethod},
          showSelectedIcon: false,
          onSelectionChanged: (value) => setState(() => _selectedMethod = value.first),
        ),
      ),
    );
  }

  Widget _buildNumpadOrReady(double total, double change) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (_selectedMethod != PaymentMethod.cash) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(Icons.qr_code_2_rounded, size: 42, color: colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 12),
            Text(
              'Ready for ${_selectedMethod.name.toUpperCase()}',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Amount Tendered', style: textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  _amountString.isEmpty ? '?0' : '?$_amountString',
                  textAlign: TextAlign.right,
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (change >= 0 ? colorScheme.tertiaryContainer : colorScheme.errorContainer),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(change >= 0 ? 'Change' : 'Remaining',
                          style: textTheme.labelLarge?.copyWith(
                            color: change >= 0 ? colorScheme.onTertiaryContainer : colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w700,
                          )),
                      Text(
                        '?${change.abs().toStringAsFixed(2)}',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: change >= 0 ? colorScheme.onTertiaryContainer : colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.8,
            physics: const NeverScrollableScrollPhysics(),
            children: ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'C', '0', '⌫']
                .map((v) => FilledButton.tonal(
                      onPressed: () => _onNumpadTap(v),
                      child: Text(
                        v,
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [total, 500.0, 1000.0, 2000.0].map((amt) {
            final isExact = amt == total;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(isExact ? 'Exact' : '?${amt.toInt()}'),
                  selected: _amountString == amt.toStringAsFixed(0),
                  onSelected: (_) => setState(() => _amountString = amt.toStringAsFixed(0)),
                  selectedColor: colorScheme.primaryContainer,
                  labelStyle: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isExact ? colorScheme.onPrimaryContainer : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPaymentAction(POSProvider pos, double total, double change) {
    final canComplete = _selectedMethod != PaymentMethod.cash || _amountTendered >= total;

    return FilledButton.icon(
      onPressed: !canComplete || _isProcessing ? null : () => _completePayment(pos),
      icon: const Icon(Icons.check_circle_rounded),
      label: Text(_isProcessing ? 'Processing...' : 'Complete Payment'),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      key: const ValueKey('SuccessView'),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(Icons.check_rounded, size: 48, color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 18),
          Text('Payment Successful!', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(
            'Order #${_completedOrderId ?? "-"}',
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => setState(() => _currentView = POSPanelView.cart),
            icon: const Icon(Icons.add_shopping_cart_rounded),
            label: const Text('New Order'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.print_rounded),
            label: const Text('Print Receipt'),
          ),
        ],
      ),
    );
  }
}
