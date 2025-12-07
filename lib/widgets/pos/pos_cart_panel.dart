import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory_saas/models/cart_item.dart';
import 'package:inventory_saas/providers/pos_provider.dart';
import 'package:inventory_saas/utils/theme.dart';
import 'package:inventory_saas/widgets/pos/pos_payment_dialog.dart';

class POSCartPanel extends StatelessWidget {
  const POSCartPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<POSProvider>(
      builder: (context, posProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              left: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
          ),
          child: Column(
            children: [
              // Header
              _buildHeader(context, posProvider),
              
              const Divider(height: 1),

              // Cart Items
              Expanded(
                child: posProvider.isEmpty
                    ? _buildEmptyCart(context)
                    : _buildCartItems(context, posProvider),
              ),
              
              const Divider(height: 1),

              // Summary & Actions
              _buildSummary(context, posProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, POSProvider posProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Order',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                '${posProvider.totalItems} items',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const Spacer(),
          // Held Orders Badge
          if (posProvider.heldOrders.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.warningColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.pause, color: AppTheme.warningColor, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${posProvider.heldOrders.length}',
                    style: const TextStyle(
                      color: AppTheme.warningColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_shopping_cart,
              size: 32,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Cart is empty',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan or select products',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(BuildContext context, POSProvider posProvider) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: posProvider.cartItems.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        return _buildCartItem(context, posProvider, posProvider.cartItems[index]);
      },
    );
  }

  Widget _buildCartItem(BuildContext context, POSProvider posProvider, CartItem item) {
    return Dismissible(
      key: Key(item.product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        posProvider.removeFromCart(item.product.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.errorColor,
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 20,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Quantity Controls (Vertical for compactness)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildQuantityButton(
                    context,
                    icon: Icons.add,
                    onPressed: () => posProvider.incrementQuantity(item.product.id),
                  ),
                  Container(
                    width: 32,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  _buildQuantityButton(
                    context,
                    icon: Icons.remove,
                    onPressed: () => posProvider.decrementQuantity(item.product.id),
                  ),
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
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₱${item.unitPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            
            // Line Total
            Text(
              '₱${item.lineTotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(BuildContext context, {required IconData icon, required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 32,
          height: 24,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 14,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, POSProvider posProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          // Summary Lines
          _buildSummaryLine(context, 'Subtotal', posProvider.subtotal),
          if (posProvider.globalDiscountAmount > 0)
            _buildSummaryLine(
              context, 
              'Discount (${posProvider.globalDiscountPercent.toStringAsFixed(0)}%)', 
              -posProvider.globalDiscountAmount,
              isNegative: true,
            ),
          _buildSummaryLine(
            context, 
            'VAT (${posProvider.taxPercent.toStringAsFixed(0)}%)', 
            posProvider.taxAmount,
          ),
          
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                '₱${posProvider.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: posProvider.isEmpty ? null : () {
                    // Quick Action: Hold
                    posProvider.holdOrder();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Hold'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: posProvider.isEmpty ? null : () {
                    showDialog(
                      context: context,
                      builder: (context) => const POSPaymentDialog(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Charge',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(BuildContext context, String label, double amount, {bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            '${isNegative ? '-' : ''}₱${amount.abs().toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isNegative ? AppTheme.errorColor : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, POSProvider posProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.warningColor),
            SizedBox(width: 8),
            Text('Clear Cart?'),
          ],
        ),
        content: const Text('This will remove all items from the current order.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              posProvider.clearCart();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
