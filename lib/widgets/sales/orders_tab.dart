import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory_saas/providers/sales_provider.dart';
import 'package:inventory_saas/models/sales_order.dart';
import 'package:inventory_saas/utils/theme.dart';
import 'package:inventory_saas/widgets/dashboard/stat_card.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  String _searchQuery = '';
  SalesOrderStatus? _statusFilter;
  PaymentStatus? _paymentFilter;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, child) {
        final filteredOrders = _getFilteredOrders(salesProvider);
        
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header and Filters
              _buildHeader(salesProvider),
              const SizedBox(height: 24),
              
              // Filters Row
              _buildFilters(),
              const SizedBox(height: 24),
              
              // Orders Table
              Expanded(
                child: _buildOrdersTable(filteredOrders, salesProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(SalesProvider salesProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sales Orders',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Manage and track all your sales orders',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            final cards = [
              StatCard(
                title: 'Total Orders',
                value: salesProvider.salesOrders.length.toString(),
                icon: Icons.receipt_long_outlined,
                color: AppTheme.primaryColor,
              ),
              StatCard(
                 title: 'Total Sales',
                 value: '\$${salesProvider.totalSales.toStringAsFixed(0)}',
                 icon: Icons.trending_up,
                 color: AppTheme.successColor,
               ),
               StatCard(
                 title: 'Outstanding',
                 value: '\$${salesProvider.totalOutstanding.toStringAsFixed(0)}',
                 icon: Icons.pending_outlined,
                 color: AppTheme.warningColor,
               ),
            ];

            if (!isWide) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: cards.map((card) => SizedBox(
                  width: (constraints.maxWidth - 12) / 2, 
                  child: card,
                )).toList(),
              );
            }

            return Row(
              children: cards.map((card) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: card,
                ),
              )).toList()..last = Expanded(child: cards.last),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        // Search
        Expanded(
          flex: 2,
          child: TextField(
            controller: _searchController,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search orders...',
              prefixIcon: const Icon(Icons.search, size: 18),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.clear, size: 16),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Status Filter
        Expanded(
          child: DropdownButtonFormField<SalesOrderStatus?>(
            value: _statusFilter,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Status',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All'),
              ),
              ...SalesOrderStatus.values.map((status) => DropdownMenuItem(
                value: status,
                child: Text(_getStatusText(status)),
              )),
            ],
            onChanged: (value) {
              setState(() {
                _statusFilter = value;
              });
            },
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Payment Filter
        Expanded(
          child: DropdownButtonFormField<PaymentStatus?>(
            value: _paymentFilter,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Payment',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All'),
              ),
              ...PaymentStatus.values.map((status) => DropdownMenuItem(
                value: status,
                child: Text(_getPaymentStatusText(status)),
              )),
            ],
            onChanged: (value) {
              setState(() {
                _paymentFilter = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersTable(List<SalesOrder> orders, SalesProvider salesProvider) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_outlined,
              size: 48,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 48,
          dataRowMinHeight: 48,
          dataRowMaxHeight: 56,
          columnSpacing: 24,
          horizontalMargin: 16,
          columns: [
            DataColumn(label: Text('ORDER #', style: _headerStyle())),
            DataColumn(label: Text('CUSTOMER', style: _headerStyle())),
            DataColumn(label: Text('STATUS', style: _headerStyle())),
            DataColumn(label: Text('PAYMENT', style: _headerStyle())),
            DataColumn(label: Text('TOTAL', style: _headerStyle())),
            DataColumn(label: Text('DATE', style: _headerStyle())),
            DataColumn(label: Text('ACTIONS', style: _headerStyle())),
          ],
          rows: orders.map((order) => _buildOrderRow(order, salesProvider)).toList(),
        ),
      ),
    );
  }

  TextStyle _headerStyle() {
    return TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppTheme.textSecondary,
    );
  }

  DataRow _buildOrderRow(SalesOrder order, SalesProvider salesProvider) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            order.orderNumber,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                order.customerName,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
              if (order.customerEmail.isNotEmpty)
                Text(
                  order.customerEmail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
        DataCell(
          _buildStatusChip(order.status),
        ),
        DataCell(
          _buildPaymentChip(order.paymentStatus),
        ),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '\$${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              if (order.outstandingAmount > 0)
                Text(
                  'Due: \$${order.outstandingAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppTheme.warningColor,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatDate(order.orderDate),
                style: const TextStyle(fontSize: 12),
              ),
              if (order.shipDate != null)
                Text(
                  'Ship: ${_formatDate(order.shipDate!)}',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _viewOrderDetails(order),
                icon: const Icon(Icons.visibility_outlined, size: 16),
                tooltip: 'View',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _editOrder(order),
                icon: const Icon(Icons.edit_outlined, size: 16),
                tooltip: 'Edit',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _showOrderActions(order, salesProvider),
                icon: const Icon(Icons.more_horiz, size: 16),
                tooltip: 'More',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(SalesOrderStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case SalesOrderStatus.draft:
        color = AppTheme.textSecondary;
        text = 'Draft';
        break;
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
        color = AppTheme.successColor;
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
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPaymentChip(PaymentStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case PaymentStatus.pending:
        color = AppTheme.warningColor;
        text = 'Pending';
        break;
      case PaymentStatus.partial:
        color = AppTheme.infoColor;
        text = 'Partial';
        break;
      case PaymentStatus.paid:
        color = AppTheme.successColor;
        text = 'Paid';
        break;
      case PaymentStatus.overdue:
        color = AppTheme.errorColor;
        text = 'Overdue';
        break;
      case PaymentStatus.refunded:
        color = AppTheme.textSecondary;
        text = 'Refunded';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<SalesOrder> _getFilteredOrders(SalesProvider salesProvider) {
    List<SalesOrder> orders = salesProvider.salesOrders;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      orders = salesProvider.searchSalesOrders(_searchQuery);
    }
    
    // Apply status filter
    if (_statusFilter != null) {
      orders = orders.where((order) => order.status == _statusFilter).toList();
    }
    
    // Apply payment filter
    if (_paymentFilter != null) {
      orders = orders.where((order) => order.paymentStatus == _paymentFilter).toList();
    }
    
    return orders;
  }

  String _getStatusText(SalesOrderStatus status) {
    switch (status) {
      case SalesOrderStatus.draft:
        return 'Draft';
      case SalesOrderStatus.pending:
        return 'Pending';
      case SalesOrderStatus.confirmed:
        return 'Confirmed';
      case SalesOrderStatus.processing:
        return 'Processing';
      case SalesOrderStatus.shipped:
        return 'Shipped';
      case SalesOrderStatus.delivered:
        return 'Delivered';
      case SalesOrderStatus.cancelled:
        return 'Cancelled';
      case SalesOrderStatus.completed:
        return 'Completed';
    }
  }

  String _getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.partial:
        return 'Partial';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.overdue:
        return 'Overdue';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewOrderDetails(SalesOrder order) {
    // TODO: Implement order details view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing order: ${order.orderNumber}')),
    );
  }

  void _editOrder(SalesOrder order) {
    // TODO: Implement order editing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing order: ${order.orderNumber}')),
    );
  }

  void _showOrderActions(SalesOrder order, SalesProvider salesProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Details'),
              onTap: () {
                Navigator.of(context).pop();
                _viewOrderDetails(order);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Order'),
              onTap: () {
                Navigator.of(context).pop();
                _editOrder(order);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping),
              title: const Text('Update Status'),
              onTap: () {
                Navigator.of(context).pop();
                _showStatusUpdateDialog(order, salesProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Update Payment'),
              onTap: () {
                Navigator.of(context).pop();
                _showPaymentUpdateDialog(order, salesProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Order', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteConfirmation(order, salesProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusUpdateDialog(SalesOrder order, SalesProvider salesProvider) {
    SalesOrderStatus selectedStatus = order.status;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current status: ${_getStatusText(order.status)}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<SalesOrderStatus>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'New Status',
                  border: OutlineInputBorder(),
                ),
                items: SalesOrderStatus.values.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(_getStatusText(status)),
                )).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedStatus = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await salesProvider.updateOrderStatus(order.id, selectedStatus);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showPaymentUpdateDialog(SalesOrder order, SalesProvider salesProvider) {
    PaymentStatus selectedStatus = order.paymentStatus;
    double paidAmount = order.paidAmount;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Payment Status'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Order total: \$${order.totalAmount.toStringAsFixed(2)}'),
              Text('Current paid: \$${order.paidAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<PaymentStatus>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Payment Status',
                  border: OutlineInputBorder(),
                ),
                items: PaymentStatus.values.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(_getPaymentStatusText(status)),
                )).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedStatus = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Paid Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  paidAmount = double.tryParse(value) ?? 0;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await salesProvider.updatePaymentStatus(order.id, selectedStatus, paidAmount);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(SalesOrder order, SalesProvider salesProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: Text('Are you sure you want to delete order ${order.orderNumber}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Order ${order.orderNumber} deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
