import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:inventory_saas/models/cart_item.dart';
import 'package:inventory_saas/providers/pos_provider.dart';
import 'package:inventory_saas/utils/theme.dart';

enum POSPanelView { cart, payment, success }

class POSCartPanel extends StatefulWidget {
  const POSCartPanel({super.key});

  @override
  State<POSCartPanel> createState() => _POSCartPanelState();
}

class _POSCartPanelState extends State<POSCartPanel> with TickerProviderStateMixin {
  POSPanelView _currentView = POSPanelView.cart;
  
  // Payment State
  String _amountString = '';
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  bool _isProcessing = false;
  String? _completedOrderId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark 
            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
            : [Colors.white, const Color(0xFFF8FAFC)],
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
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
          Expanded(child: pos.isEmpty ? _buildEmptyCart() : _buildCartItems(pos)),
          _buildCartFooter(pos),
        ],
      ),
    );
  }

  Widget _buildCartHeader(POSProvider pos) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.receipt_long, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                Text(
                  '${pos.totalItems} ${pos.totalItems == 1 ? 'item' : 'items'}',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          if (pos.heldOrders.isNotEmpty)
            _buildHeldBadge(pos.heldOrders.length),
        ],
      ),
    );
  }

  Widget _buildHeldBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.pause_circle, size: 16, color: Color(0xFFD97706)),
          const SizedBox(width: 6),
          Text('$count held', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFD97706))),
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
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          Text('No items yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Tap products to add them here', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildCartItems(POSProvider pos) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Quantity Stepper
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildStepperBtn(Icons.add, () => pos.incrementQuantity(item.product.id)),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  _buildStepperBtn(Icons.remove, () => pos.decrementQuantity(item.product.id)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('₱${item.unitPrice.toStringAsFixed(2)} each', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            // Total
            Text('₱${item.lineTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () { HapticFeedback.selectionClick(); onTap(); },
        borderRadius: BorderRadius.circular(8),
        child: Padding(padding: const EdgeInsets.all(8), child: Icon(icon, size: 18, color: AppTheme.primaryColor)),
      ),
    );
  }

  Widget _buildCartFooter(POSProvider pos) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', pos.subtotal),
          if (pos.globalDiscountAmount > 0) _buildSummaryRow('Discount', -pos.globalDiscountAmount, isNegative: true),
          _buildSummaryRow('VAT (${pos.taxPercent.toInt()}%)', pos.taxAmount),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              Text('₱${pos.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: pos.isEmpty ? null : pos.holdOrder,
                  icon: const Icon(Icons.pause, size: 18),
                  label: const Text('Hold'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: pos.isEmpty ? null : _switchToPayment,
                    icon: const Icon(Icons.payments, size: 20),
                    label: const Text('Charge', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          Text('${isNegative ? "-" : ""}₱${amount.abs().toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w600, color: isNegative ? Colors.red : null)),
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _switchToCart,
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.15)),
              ),
              const SizedBox(width: 12),
              const Text('Payment', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Amount Due', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
          const SizedBox(height: 4),
          Text('₱${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w800, letterSpacing: -1)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final methods = [
      (PaymentMethod.cash, Icons.payments, 'Cash'),
      (PaymentMethod.card, Icons.credit_card, 'Card'),
      (PaymentMethod.gcash, Icons.phone_android, 'GCash'),
      (PaymentMethod.maya, Icons.account_balance_wallet, 'Maya'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: methods.map((m) {
          final isSelected = _selectedMethod == m.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedMethod = m.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300, width: isSelected ? 2 : 1),
                ),
                child: Column(
                  children: [
                    Icon(m.$2, size: 22, color: isSelected ? AppTheme.primaryColor : Colors.grey),
                    const SizedBox(height: 6),
                    Text(m.$3, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? AppTheme.primaryColor : Colors.grey)),
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
            Icon(Icons.qr_code_2, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Ready for ${_selectedMethod.name.toUpperCase()}', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Amount Tendered', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(height: 4),
                Text(_amountString.isEmpty ? '₱0' : '₱$_amountString', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
              ],
            ),
          ),
          // Change indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: change >= 0 ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: change >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(change >= 0 ? 'Change' : 'Remaining', style: TextStyle(fontWeight: FontWeight.w600, color: change >= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626))),
                Text('₱${change.abs().toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: change >= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626))),
              ],
            ),
          ),
          // Numpad Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.8,
              physics: const NeverScrollableScrollPhysics(),
              children: ['1','2','3','4','5','6','7','8','9','C','0','⌫'].map((v) => _buildNumpadKey(v)).toList(),
            ),
          ),
          // Quick amounts
          Row(
            children: [total, 500.0, 1000.0, 2000.0].map((amt) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: OutlinedButton(
                  onPressed: () => setState(() => _amountString = amt.toStringAsFixed(0)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide(color: amt == total ? const Color(0xFF10B981) : Colors.grey.shade300),
                    backgroundColor: amt == total ? const Color(0xFFECFDF5) : null,
                  ),
                  child: Text(amt == total ? 'Exact' : '₱${amt.toInt()}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: amt == total ? const Color(0xFF059669) : Colors.grey.shade700)),
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNumpadKey(String value) {
    final isSpecial = value == 'C' || value == '⌫';
    return Material(
      color: isSpecial ? const Color(0xFFE2E8F0) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        onTap: () => _onNumpadTap(value),
        borderRadius: BorderRadius.circular(12),
        child: Center(child: Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: isSpecial ? Colors.grey.shade700 : const Color(0xFF1E293B)))),
      ),
    );
  }

  Widget _buildPaymentAction(POSProvider pos, double total, double change) {
    final canComplete = _selectedMethod != PaymentMethod.cash || _amountTendered >= total;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: canComplete ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]) : null,
          color: canComplete ? null : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
          boxShadow: canComplete ? [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))] : null,
        ),
        child: ElevatedButton(
          onPressed: !canComplete || _isProcessing ? null : () => _completePayment(pos),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: _isProcessing
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.check_circle, size: 22), SizedBox(width: 10), Text('Complete Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))]),
        ),
      ),
    );
  }

  Future<void> _completePayment(POSProvider pos) async {
    setState(() => _isProcessing = true);
    try {
      final orderId = await pos.checkout(_selectedMethod, _amountTendered);
      _completedOrderId = orderId;
      setState(() { _currentView = POSPanelView.success; _isProcessing = false; });
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  // ==================== SUCCESS VIEW ====================
  Widget _buildSuccessView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 64, color: Colors.white),
          ),
          const SizedBox(height: 32),
          const Text('Payment Successful!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Order #${_completedOrderId ?? "-"}', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _currentView = POSPanelView.cart),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('New Order', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () { /* TODO: Print */ },
            icon: const Icon(Icons.print),
            label: const Text('Print Receipt'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          ),
        ],
      ),
    );
  }
}
