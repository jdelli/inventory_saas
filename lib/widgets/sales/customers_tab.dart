import 'package:flutter/material.dart';
import 'package:inventory_saas/utils/theme.dart';

class CustomersTab extends StatefulWidget {
  const CustomersTab({super.key});

  @override
  State<CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends State<CustomersTab> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Dummy customer data
  final List<Map<String, dynamic>> _customers = [
    {
      'id': 'cust_001',
      'name': 'John Doe',
      'email': 'john.doe@email.com',
      'phone': '+1-555-0101',
      'address': '123 Main St, New York, NY 10001',
      'totalOrders': 15,
      'totalSpent': 8500.50,
      'lastOrder': '2024-01-15',
      'status': 'active',
    },
    {
      'id': 'cust_002',
      'name': 'Jane Smith',
      'email': 'jane.smith@email.com',
      'phone': '+1-555-0102',
      'address': '456 Oak Ave, Los Angeles, CA 90210',
      'totalOrders': 8,
      'totalSpent': 4200.75,
      'lastOrder': '2024-01-20',
      'status': 'active',
    },
    {
      'id': 'cust_003',
      'name': 'Mike Johnson',
      'email': 'mike.johnson@email.com',
      'phone': '+1-555-0103',
      'address': '789 Pine St, Chicago, IL 60601',
      'totalOrders': 3,
      'totalSpent': 1958.97,
      'lastOrder': '2024-01-22',
      'status': 'active',
    },
    {
      'id': 'cust_004',
      'name': 'Sarah Wilson',
      'email': 'sarah.wilson@email.com',
      'phone': '+1-555-0104',
      'address': '321 Elm St, Miami, FL 33101',
      'totalOrders': 22,
      'totalSpent': 12500.25,
      'lastOrder': '2024-01-18',
      'status': 'active',
    },
    {
      'id': 'cust_005',
      'name': 'David Brown',
      'email': 'david.brown@email.com',
      'phone': '+1-555-0105',
      'address': '654 Maple Dr, Seattle, WA 98101',
      'totalOrders': 0,
      'totalSpent': 0.0,
      'lastOrder': 'Never',
      'status': 'inactive',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCustomers = _getFilteredCustomers();
    
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
          
          // Customers Table
          Expanded(
            child: _buildCustomersTable(filteredCustomers),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final activeCustomers = _customers.where((c) => c['status'] == 'active').length;
    final totalRevenue = _customers.fold<double>(0, (sum, c) => sum + c['totalSpent']);
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customers',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your customer relationships and track customer data',
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
              'Total Customers',
              _customers.length.toString(),
              Icons.people,
              AppTheme.primaryColor,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Active Customers',
              activeCustomers.toString(),
              Icons.person_add,
              AppTheme.successColor,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Total Revenue',
              '\$${totalRevenue.toStringAsFixed(0)}',
              Icons.trending_up,
              AppTheme.infoColor,
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
              hintText: 'Search customers by name, email, or phone...',
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
        
        // Add Customer Button
        ElevatedButton.icon(
          onPressed: () => _showAddCustomerDialog(),
          icon: const Icon(Icons.person_add, size: 18),
          label: const Text('Add Customer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomersTable(List<Map<String, dynamic>> customers) {
    if (customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No customers found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or add a new customer',
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
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Contact')),
            DataColumn(label: Text('Orders')),
            DataColumn(label: Text('Total Spent')),
            DataColumn(label: Text('Last Order')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: customers.map((customer) => _buildCustomerRow(customer)).toList(),
        ),
      ),
    );
  }

  DataRow _buildCustomerRow(Map<String, dynamic> customer) {
    return DataRow(
      cells: [
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                customer['name'],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'ID: ${customer['id']}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
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
                customer['email'],
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                customer['phone'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            customer['totalOrders'].toString(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(
          Text(
            '\$${customer['totalSpent'].toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(
          Text(
            customer['lastOrder'],
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(
          _buildStatusChip(customer['status']),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _viewCustomerDetails(customer),
                icon: const Icon(Icons.visibility, size: 18),
                tooltip: 'View Details',
              ),
              IconButton(
                onPressed: () => _editCustomer(customer),
                icon: const Icon(Icons.edit, size: 18),
                tooltip: 'Edit Customer',
              ),
              IconButton(
                onPressed: () => _showCustomerActions(customer),
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
      case 'active':
        color = AppTheme.successColor;
        text = 'Active';
        break;
      case 'inactive':
        color = AppTheme.textSecondary;
        text = 'Inactive';
        break;
      default:
        color = AppTheme.warningColor;
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

  List<Map<String, dynamic>> _getFilteredCustomers() {
    if (_searchQuery.isEmpty) return _customers;
    
    return _customers.where((customer) {
      final query = _searchQuery.toLowerCase();
      return customer['name'].toLowerCase().contains(query) ||
             customer['email'].toLowerCase().contains(query) ||
             customer['phone'].contains(query);
    }).toList();
  }

  void _viewCustomerDetails(Map<String, dynamic> customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Customer: ${customer['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('ID', customer['id']),
            _buildDetailRow('Name', customer['name']),
            _buildDetailRow('Email', customer['email']),
            _buildDetailRow('Phone', customer['phone']),
            _buildDetailRow('Address', customer['address']),
            _buildDetailRow('Total Orders', customer['totalOrders'].toString()),
            _buildDetailRow('Total Spent', '\$${customer['totalSpent'].toStringAsFixed(2)}'),
            _buildDetailRow('Last Order', customer['lastOrder']),
            _buildDetailRow('Status', customer['status']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
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
            width: 100,
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

  void _editCustomer(Map<String, dynamic> customer) {
    // TODO: Implement customer editing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing customer: ${customer['name']}')),
    );
  }

  void _showCustomerActions(Map<String, dynamic> customer) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Actions',
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
                _viewCustomerDetails(customer);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Customer'),
              onTap: () {
                Navigator.of(context).pop();
                _editCustomer(customer);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('View Orders'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Navigate to customer orders
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Viewing orders for ${customer['name']}')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Send Email'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement email functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sending email to ${customer['email']}')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Customer', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteConfirmation(customer);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement add customer functionality
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Customer added successfully')),
              );
            },
            child: const Text('Add Customer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${customer['name']}? This action cannot be undone.'),
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
                SnackBar(content: Text('Customer ${customer['name']} deleted')),
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
