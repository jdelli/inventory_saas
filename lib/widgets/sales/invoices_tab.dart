import 'package:flutter/material.dart';
import 'package:inventory_saas/utils/theme.dart';

class InvoicesTab extends StatefulWidget {
  const InvoicesTab({super.key});

  @override
  State<InvoicesTab> createState() => _InvoicesTabState();
}

class _InvoicesTabState extends State<InvoicesTab> {
  String _searchQuery = '';
  String? _statusFilter;
  final TextEditingController _searchController = TextEditingController();

  // Dummy invoice data
  final List<Map<String, dynamic>> _invoices = [
    {
      'id': 'INV-2024-001',
      'orderNumber': 'SO-2024-001',
      'customerName': 'John Doe',
      'customerEmail': 'john.doe@email.com',
      'issueDate': '2024-01-15',
      'dueDate': '2024-02-15',
      'amount': 1295.98,
      'paidAmount': 1295.98,
      'status': 'paid',
      'paymentMethod': 'Credit Card',
    },
    {
      'id': 'INV-2024-002',
      'orderNumber': 'SO-2024-002',
      'customerName': 'Jane Smith',
      'customerEmail': 'jane.smith@email.com',
      'issueDate': '2024-01-18',
      'dueDate': '2024-02-18',
      'amount': 2894.97,
      'paidAmount': 1500.0,
      'status': 'partial',
      'paymentMethod': 'Bank Transfer',
    },
    {
      'id': 'INV-2024-003',
      'orderNumber': 'SO-2024-003',
      'customerName': 'Mike Johnson',
      'customerEmail': 'mike.johnson@email.com',
      'issueDate': '2024-01-22',
      'dueDate': '2024-02-22',
      'amount': 1958.97,
      'paidAmount': 0.0,
      'status': 'pending',
      'paymentMethod': 'Pending',
    },
    {
      'id': 'INV-2024-004',
      'orderNumber': 'SO-2024-004',
      'customerName': 'Sarah Wilson',
      'customerEmail': 'sarah.wilson@email.com',
      'issueDate': '2024-01-10',
      'dueDate': '2024-02-10',
      'amount': 1353.98,
      'paidAmount': 1353.98,
      'status': 'paid',
      'paymentMethod': 'PayPal',
    },
    {
      'id': 'INV-2024-005',
      'orderNumber': 'SO-2024-005',
      'customerName': 'David Brown',
      'customerEmail': 'david.brown@email.com',
      'issueDate': '2024-01-25',
      'dueDate': '2024-02-25',
      'amount': 899.99,
      'paidAmount': 0.0,
      'status': 'overdue',
      'paymentMethod': 'Pending',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredInvoices = _getFilteredInvoices();
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header and Stats
          _buildHeader(),
          const SizedBox(height: 24),
          
          // Search and Actions
          _buildSearchAndActions(),
          const SizedBox(height: 24),
          
          // Invoices Table
          Expanded(
            child: _buildInvoicesTable(filteredInvoices),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final totalInvoiced = _invoices.fold<double>(0, (sum, inv) => sum + inv['amount']);
    final totalPaid = _invoices.fold<double>(0, (sum, inv) => sum + inv['paidAmount']);
    final totalOutstanding = totalInvoiced - totalPaid;
    final overdueInvoices = _invoices.where((inv) => inv['status'] == 'overdue').length;
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invoices',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage invoices, track payments, and monitor outstanding balances',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        // Quick Stats
        Row(
          children: [
            _buildStatCard(
              'Total Invoiced',
              '\$${totalInvoiced.toStringAsFixed(0)}',
              Icons.receipt_long,
              AppTheme.primaryColor,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Total Paid',
              '\$${totalPaid.toStringAsFixed(0)}',
              Icons.payment,
              AppTheme.successColor,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Outstanding',
              '\$${totalOutstanding.toStringAsFixed(0)}',
              Icons.pending,
              AppTheme.warningColor,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Overdue',
              overdueInvoices.toString(),
              Icons.warning,
              AppTheme.errorColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndActions() {
    return Row(
      children: [
        // Search
        Expanded(
          flex: 2,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search invoices by ID, customer, or order number...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.clear),
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
        
        const SizedBox(width: 16),
        
        // Status Filter
        Expanded(
          child: DropdownButtonFormField<String?>(
            value: _statusFilter,
            decoration: InputDecoration(
              labelText: 'Invoice Status',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Statuses'),
              ),
              const DropdownMenuItem(
                value: 'paid',
                child: Text('Paid'),
              ),
              const DropdownMenuItem(
                value: 'partial',
                child: Text('Partial'),
              ),
              const DropdownMenuItem(
                value: 'pending',
                child: Text('Pending'),
              ),
              const DropdownMenuItem(
                value: 'overdue',
                child: Text('Overdue'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _statusFilter = value;
              });
            },
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Create Invoice Button
        ElevatedButton.icon(
          onPressed: () => _showCreateInvoiceDialog(),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Create Invoice'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoicesTable(List<Map<String, dynamic>> invoices) {
    if (invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                         Icon(
               Icons.receipt_long,
               size: 64,
               color: AppTheme.textSecondary,
             ),
            const SizedBox(height: 16),
            Text(
              'No invoices found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or create a new invoice',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
          columns: const [
            DataColumn(label: Text('Invoice #')),
            DataColumn(label: Text('Order #')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Issue Date')),
            DataColumn(label: Text('Due Date')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: invoices.map((invoice) => _buildInvoiceRow(invoice)).toList(),
        ),
      ),
    );
  }

  DataRow _buildInvoiceRow(Map<String, dynamic> invoice) {
    final outstandingAmount = invoice['amount'] - invoice['paidAmount'];
    final isOverdue = invoice['status'] == 'overdue' || 
                     (invoice['status'] == 'pending' && 
                      DateTime.parse(invoice['dueDate']).isBefore(DateTime.now()));
    
    return DataRow(
      cells: [
        DataCell(
          Text(
            invoice['id'],
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(
          Text(
            invoice['orderNumber'],
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                invoice['customerName'],
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                invoice['customerEmail'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            invoice['issueDate'],
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(
          Text(
            invoice['dueDate'],
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isOverdue ? AppTheme.errorColor : null,
            ),
          ),
        ),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '\$${invoice['amount'].toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (outstandingAmount > 0)
                Text(
                  'Outstanding: \$${outstandingAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.warningColor,
                  ),
                ),
            ],
          ),
        ),
        DataCell(
          _buildStatusChip(invoice['status']),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _viewInvoiceDetails(invoice),
                icon: const Icon(Icons.visibility, size: 18),
                tooltip: 'View Details',
              ),
              IconButton(
                onPressed: () => _downloadInvoice(invoice),
                icon: const Icon(Icons.download, size: 18),
                tooltip: 'Download',
              ),
              IconButton(
                onPressed: () => _showInvoiceActions(invoice),
                icon: const Icon(Icons.more_vert, size: 18),
                tooltip: 'More Actions',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'paid':
        color = AppTheme.successColor;
        text = 'Paid';
        break;
      case 'partial':
        color = AppTheme.infoColor;
        text = 'Partial';
        break;
      case 'pending':
        color = AppTheme.warningColor;
        text = 'Pending';
        break;
      case 'overdue':
        color = AppTheme.errorColor;
        text = 'Overdue';
        break;
      default:
        color = AppTheme.textSecondary;
        text = 'Unknown';
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

  List<Map<String, dynamic>> _getFilteredInvoices() {
    List<Map<String, dynamic>> invoices = _invoices;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      invoices = invoices.where((invoice) {
        final query = _searchQuery.toLowerCase();
        return invoice['id'].toLowerCase().contains(query) ||
               invoice['orderNumber'].toLowerCase().contains(query) ||
               invoice['customerName'].toLowerCase().contains(query) ||
               invoice['customerEmail'].toLowerCase().contains(query);
      }).toList();
    }
    
    // Apply status filter
    if (_statusFilter != null) {
      invoices = invoices.where((invoice) => invoice['status'] == _statusFilter).toList();
    }
    
    return invoices;
  }

  void _viewInvoiceDetails(Map<String, dynamic> invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invoice: ${invoice['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Invoice ID', invoice['id']),
            _buildDetailRow('Order Number', invoice['orderNumber']),
            _buildDetailRow('Customer', invoice['customerName']),
            _buildDetailRow('Email', invoice['customerEmail']),
            _buildDetailRow('Issue Date', invoice['issueDate']),
            _buildDetailRow('Due Date', invoice['dueDate']),
            _buildDetailRow('Total Amount', '\$${invoice['amount'].toStringAsFixed(2)}'),
            _buildDetailRow('Paid Amount', '\$${invoice['paidAmount'].toStringAsFixed(2)}'),
            _buildDetailRow('Outstanding', '\$${(invoice['amount'] - invoice['paidAmount']).toStringAsFixed(2)}'),
            _buildDetailRow('Status', invoice['status']),
            _buildDetailRow('Payment Method', invoice['paymentMethod']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _downloadInvoice(invoice);
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _downloadInvoice(Map<String, dynamic> invoice) {
    // TODO: Implement invoice download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading invoice: ${invoice['id']}')),
    );
  }

  void _showInvoiceActions(Map<String, dynamic> invoice) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice Actions',
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
                _viewInvoiceDetails(invoice);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download PDF'),
              onTap: () {
                Navigator.of(context).pop();
                _downloadInvoice(invoice);
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Send to Customer'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement email functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sending invoice ${invoice['id']} to ${invoice['customerEmail']}')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Record Payment'),
              onTap: () {
                Navigator.of(context).pop();
                _showPaymentDialog(invoice);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Invoice'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement edit functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Editing invoice: ${invoice['id']}')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Invoice', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteConfirmation(invoice);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDialog(Map<String, dynamic> invoice) {
    final amountController = TextEditingController(
      text: (invoice['amount'] - invoice['paidAmount']).toStringAsFixed(2),
    );
    String selectedMethod = 'Credit Card';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Payment'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Invoice: ${invoice['id']}'),
              Text('Customer: ${invoice['customerName']}'),
              Text('Outstanding: \$${(invoice['amount'] - invoice['paidAmount']).toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Payment Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Credit Card',
                  'Bank Transfer',
                  'PayPal',
                  'Cash',
                  'Check',
                ].map((method) => DropdownMenuItem(
                  value: method,
                  child: Text(method),
                )).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedMethod = value;
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
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement payment recording
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Payment recorded for invoice: ${invoice['id']}')),
              );
            },
            child: const Text('Record Payment'),
          ),
        ],
      ),
    );
  }

  void _showCreateInvoiceDialog() {
    // TODO: Implement create invoice functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create invoice feature coming soon')),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text('Are you sure you want to delete invoice ${invoice['id']}? This action cannot be undone.'),
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
                SnackBar(content: Text('Invoice ${invoice['id']} deleted')),
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
