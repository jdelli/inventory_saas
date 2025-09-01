import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory_saas/providers/inventory_provider.dart';
import 'package:inventory_saas/models/product.dart';
import 'package:inventory_saas/utils/theme.dart';

class LowStockWidget extends StatelessWidget {
  const LowStockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        final lowStockProducts = inventoryProvider.lowStockProducts;
        final outOfStockProducts = inventoryProvider.outOfStockProducts;

        if (lowStockProducts.isEmpty && outOfStockProducts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  'All products are well stocked!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Out of Stock Section
            if (outOfStockProducts.isNotEmpty) ...[
              _buildSectionHeader('Out of Stock', AppTheme.primaryColor),
              const SizedBox(height: 12),
              ...outOfStockProducts.map((product) => _buildProductItem(context, product, true)),
              const SizedBox(height: 24),
            ],

            // Low Stock Section
            if (lowStockProducts.isNotEmpty) ...[
              _buildSectionHeader('Low Stock', AppTheme.warningColor),
              const SizedBox(height: 12),
              ...lowStockProducts.map((product) => _buildProductItem(context, product, false)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildProductItem(BuildContext context, Product product, bool isOutOfStock) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isOutOfStock ? AppTheme.errorColor : AppTheme.warningColor).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.inventory_2,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.sku,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Stock Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${product.currentStock} ${product.unit}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isOutOfStock ? AppTheme.errorColor : AppTheme.warningColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Min: ${product.minStockLevel}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 12),
          
          // Action Button
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to reorder/create PO
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Create purchase order for ${product.name}'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isOutOfStock ? AppTheme.errorColor : AppTheme.warningColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 32),
            ),
            child: Text(
              isOutOfStock ? 'Reorder' : 'Restock',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
