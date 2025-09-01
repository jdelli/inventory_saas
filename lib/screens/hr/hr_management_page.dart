import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/hr_provider.dart';
import '../../models/employee.dart';
import '../../utils/theme.dart';

class HRManagementPage extends StatefulWidget {
  const HRManagementPage({super.key});

  @override
  State<HRManagementPage> createState() => _HRManagementPageState();
}

class _HRManagementPageState extends State<HRManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDepartment = '';
  String _selectedStatus = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HRProvider>().loadEmployees();
      context.read<HRProvider>().loadStatistics();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HR Management'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEmployeeDialog(context),
          ),
        ],
      ),
      body: Consumer<HRProvider>(
        builder: (context, hrProvider, child) {
          if (hrProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (hrProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${hrProvider.error}'),
                  ElevatedButton(
                    onPressed: () => hrProvider.loadEmployees(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Statistics Cards
              _buildStatisticsCards(hrProvider),
              
              // Search and Filters
              _buildSearchAndFilters(hrProvider),
              
              // Employee List
              Expanded(
                child: _buildEmployeeList(hrProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatisticsCards(HRProvider hrProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Employees',
              hrProvider.employees.length.toString(),
              Icons.people,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Active',
              hrProvider.activeEmployeesCount.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Average Salary',
              '\$${hrProvider.averageSalary.toStringAsFixed(0)}',
              Icons.attach_money,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(HRProvider hrProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search employees...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  hrProvider.searchEmployees('');
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => hrProvider.searchEmployees(value),
          ),
          
          const SizedBox(height: 16),
          
          // Filters
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDepartment.isEmpty ? null : _selectedDepartment,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('All Departments'),
                    ),
                    ...hrProvider.uniqueDepartments.map((dept) =>
                      DropdownMenuItem(
                        value: dept,
                        child: Text(dept),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedDepartment = value ?? '';
                    });
                    hrProvider.filterByDepartment(_selectedDepartment);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus.isEmpty ? null : _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('All Status'),
                    ),
                    const DropdownMenuItem(
                      value: 'active',
                      child: Text('Active'),
                    ),
                    const DropdownMenuItem(
                      value: 'inactive',
                      child: Text('Inactive'),
                    ),
                    const DropdownMenuItem(
                      value: 'terminated',
                      child: Text('Terminated'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value ?? '';
                    });
                    hrProvider.filterByStatus(_selectedStatus);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeList(HRProvider hrProvider) {
    final employees = hrProvider.filteredEmployees;
    
    if (employees.isEmpty) {
      return const Center(
        child: Text('No employees found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(employee.status),
              child: Text(
                employee.firstName[0] + employee.lastName[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(employee.fullName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(employee.position),
                Text(employee.department),
                Text('ID: ${employee.employeeId}'),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Text('View Details'),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                if (employee.status == 'active')
                  const PopupMenuItem(
                    value: 'terminate',
                    child: Text('Terminate'),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
              onSelected: (value) => _handleEmployeeAction(value, employee),
            ),
            onTap: () => _showEmployeeDetails(employee),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.orange;
      case 'terminated':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _handleEmployeeAction(String action, Employee employee) {
    switch (action) {
      case 'view':
        _showEmployeeDetails(employee);
        break;
      case 'edit':
        _showEditEmployeeDialog(context, employee);
        break;
      case 'terminate':
        _showTerminateEmployeeDialog(employee);
        break;
      case 'delete':
        _showDeleteEmployeeDialog(employee);
        break;
    }
  }

  void _showEmployeeDetails(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(employee.fullName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Employee ID', employee.employeeId),
              _buildDetailRow('Email', employee.email),
              _buildDetailRow('Phone', employee.phone),
              _buildDetailRow('Department', employee.department),
              _buildDetailRow('Position', employee.position),
              _buildDetailRow('Hire Date', DateFormat('MMM dd, yyyy').format(employee.hireDate)),
              _buildDetailRow('Salary', '\$${employee.salary.toStringAsFixed(2)}'),
              _buildDetailRow('Status', employee.status.toUpperCase()),
              if (employee.address != null)
                _buildDetailRow('Address', employee.address!),
              if (employee.emergencyContact != null)
                _buildDetailRow('Emergency Contact', employee.emergencyContact!),
              if (employee.emergencyPhone != null)
                _buildDetailRow('Emergency Phone', employee.emergencyPhone!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddEmployeeDialog(BuildContext context) {
    // Implementation for adding employee
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Employee'),
        content: const Text('Employee form will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Add employee logic
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditEmployeeDialog(BuildContext context, Employee employee) {
    // Implementation for editing employee
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${employee.fullName}'),
        content: const Text('Edit form will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Edit employee logic
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTerminateEmployeeDialog(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminate Employee'),
        content: Text('Are you sure you want to terminate ${employee.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<HRProvider>().terminateEmployee(
                employee.id,
                DateTime.now(),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Terminate'),
          ),
        ],
      ),
    );
  }

  void _showDeleteEmployeeDialog(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<HRProvider>().deleteEmployee(employee.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
