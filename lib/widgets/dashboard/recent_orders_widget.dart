import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory_saas/providers/sales_provider.dart';
import 'package:inventory_saas/models/sales_order.dart';
import 'package:inventory_saas/utils/theme.dart';
import 'package:intl/intl.dart';

class RecentOrdersWidget extends StatelessWidget {
  const RecentOrdersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, child) {
        final recentOrders = salesProvider.salesOrders
            .take(5)
            .toList();

        if (recentOrders.isEmpty) {
          return const Center(
            child: Text('No recent orders'),
          );
        }

        return ListView.builder(
          itemCount: recentOrders.length,
          itemBuilder: (context, index) {
            final order = recentOrders[index];
            return _buildOrderItem(context, order);
          },
        );
      },
    );
  }

  Widget _buildOrderItem(BuildContext context, SalesOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.textSecondary.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  order.orderNumber,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildStatusChip(order.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.customerName ?? 'Unknown Customer',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${order.totalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                DateFormat('MMM dd').format(order.orderDate),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(SalesOrderStatus status) {
    Color color;
    String text;

    switch (status) {
      case SalesOrderStatus.pending:
        color = AppTheme.warningColor;
        text = 'Pending';
        break;
      case SalesOrderStatus.confirmed:
        color = AppTheme.infoColor;
        text = 'Confirmed';
        break;
      case SalesOrderStatus.processing:
        color = AppTheme.primaryColor;
        text = 'Processing';
        break;
      case SalesOrderStatus.shipped:
        color = AppTheme.secondaryColor;
        text = 'Shipped';
        break;
      case SalesOrderStatus.delivered:
        color = AppTheme.successColor;
        text = 'Delivered';
        break;
      case SalesOrderStatus.cancelled:
        color = AppTheme.errorColor;
        text = 'Cancelled';
        break;
      case SalesOrderStatus.completed:
        color = AppTheme.successColor;
        text = 'Completed';
        break;
      default:
        color = AppTheme.textSecondary;
        text = 'Draft';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
