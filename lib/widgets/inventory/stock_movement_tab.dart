import 'package:flutter/material.dart';
import 'package:inventory_saas/utils/theme.dart';
import 'package:inventory_saas/widgets/inventory/add_stock_movement_modal.dart';

// Re-export the StockMovement class and MovementType enum from the modal
export 'package:inventory_saas/widgets/inventory/add_stock_movement_modal.dart';

class StockMovementTab extends StatefulWidget {
  const StockMovementTab({super.key});

  @override
  State<StockMovementTab> createState() => _StockMovementTabState();
}

class _StockMovementTabState extends State<StockMovementTab> {
  String _selectedMovementType = 'All';
  String _selectedWarehouse = 'All';
  String _searchQuery = '';

  final List<String> _movementTypes = ['All', 'In', 'Out', 'Transfer', 'Adjustment'];
  final List<String> _warehouses = ['All', 'Main Warehouse', 'Secondary Warehouse', 'Store A', 'Store B'];

  final List<StockMovement> _movements = [
               StockMovement(
             id: 'mov_001',
             productId: 'prod_001',
             productName: 'iPhone 15 Pro',
             sku: 'IPH15PRO-256-BLK',
             movementType: MovementType.incoming,
             quantity: 50,
             previousStock: 15,
             newStock: 65,
             warehouse: 'Main Warehouse',
             reference: 'PO-2024-001',
             referenceType: 'Purchase Order',
             notes: 'Initial stock received from supplier',
             date: DateTime.now().subtract(const Duration(hours: 2)),
             userId: 'user_001',
             userName: 'John Smith',
           ),
    StockMovement(
      id: 'mov_002',
      productId: 'prod_002',
      productName: 'Samsung Galaxy S24',
      sku: 'SAMS24-128-BLK',
      movementType: MovementType.out,
      quantity: 3,
      previousStock: 8,
      newStock: 5,
      warehouse: 'Main Warehouse',
      reference: 'SO-2024-015',
      referenceType: 'Sales Order',
      notes: 'Customer order fulfillment',
      date: DateTime.now().subtract(const Duration(hours: 4)),
      userId: 'user_002',
      userName: 'Sarah Johnson',
    ),
    StockMovement(
      id: 'mov_003',
      productId: 'prod_003',
      productName: 'MacBook Pro 14"',
      sku: 'MBP14-512-SLV',
      movementType: MovementType.transfer,
      quantity: 2,
      previousStock: 5,
      newStock: 3,
      warehouse: 'Main Warehouse',
      reference: 'TR-2024-008',
      referenceType: 'Transfer',
      notes: 'Transferred to Store A',
      date: DateTime.now().subtract(const Duration(days: 1)),
      userId: 'user_001',
      userName: 'John Smith',
    ),
    StockMovement(
      id: 'mov_004',
      productId: 'prod_004',
      productName: 'Dell XPS 13',
      sku: 'DLLXPS13-256-BLK',
      movementType: MovementType.adjustment,
      quantity: -1,
      previousStock: 0,
      newStock: 0,
      warehouse: 'Main Warehouse',
      reference: 'ADJ-2024-003',
      referenceType: 'Adjustment',
      notes: 'Damaged item removed from inventory',
      date: DateTime.now().subtract(const Duration(days: 2)),
      userId: 'user_003',
      userName: 'Mike Wilson',
    ),
    StockMovement(
      id: 'mov_005',
      productId: 'prod_005',
      productName: 'AirPods Pro',
      sku: 'AIRPODS-PRO-WHT',
      movementType: MovementType.incoming,
      quantity: 25,
      previousStock: 25,
      newStock: 50,
      warehouse: 'Main Warehouse',
      reference: 'PO-2024-002',
      referenceType: 'Purchase Order',
      notes: 'Restock order received',
      date: DateTime.now().subtract(const Duration(days: 3)),
      userId: 'user_001',
      userName: 'John Smith',
    ),
    StockMovement(
      id: 'mov_006',
      productId: 'prod_001',
      productName: 'iPhone 15 Pro',
      sku: 'IPH15PRO-256-BLK',
      movementType: MovementType.out,
      quantity: 1,
      previousStock: 65,
      newStock: 64,
      warehouse: 'Main Warehouse',
      reference: 'SO-2024-016',
      referenceType: 'Sales Order',
      notes: 'Online order fulfillment',
      date: DateTime.now().subtract(const Duration(days: 4)),
      userId: 'user_002',
      userName: 'Sarah Johnson',
    ),
    StockMovement(
      id: 'mov_007',
      productId: 'prod_003',
      productName: 'MacBook Pro 14"',
      sku: 'MBP14-512-SLV',
      movementType: MovementType.incoming,
      quantity: 5,
      previousStock: 3,
      newStock: 8,
      warehouse: 'Main Warehouse',
      reference: 'PO-2024-003',
      referenceType: 'Purchase Order',
      notes: 'New stock received',
      date: DateTime.now().subtract(const Duration(days: 5)),
      userId: 'user_001',
      userName: 'John Smith',
    ),
    StockMovement(
      id: 'mov_008',
      productId: 'prod_002',
      productName: 'Samsung Galaxy S24',
      sku: 'SAMS24-128-BLK',
      movementType: MovementType.adjustment,
      quantity: 2,
      previousStock: 5,
      newStock: 7,
      warehouse: 'Main Warehouse',
      reference: 'ADJ-2024-004',
      referenceType: 'Adjustment',
      notes: 'Found additional stock in warehouse',
      date: DateTime.now().subtract(const Duration(days: 6)),
      userId: 'user_003',
      userName: 'Mike Wilson',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stock Movement',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track all inventory movements and changes',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
                             ElevatedButton.icon(
                 onPressed: _showAddMovementModal,
                 icon: const Icon(Icons.add),
                 label: const Text('Add Movement'),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: AppTheme.primaryColor,
                   foregroundColor: Colors.white,
                 ),
               ),
            ],
          ),
        ),

        // Statistics Cards
        _buildStatisticsCards(),

        // Search and Filters
        _buildSearchAndFilters(),

        // Movements Table
        Expanded(
          child: _buildMovementsTable(),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards() {
    final filteredMovements = _getFilteredMovements();
    final totalIn = filteredMovements
        .where((m) => m.movementType == MovementType.incoming)
        .fold(0, (sum, m) => sum + m.quantity);
    final totalOut = filteredMovements
        .where((m) => m.movementType == MovementType.out)
        .fold(0, (sum, m) => sum + m.quantity);
    final totalTransfers = filteredMovements
        .where((m) => m.movementType == MovementType.transfer)
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Movements',
              filteredMovements.length.toString(),
              Icons.swap_horiz,
              AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Stock In',
              totalIn.toString(),
              Icons.arrow_downward,
              AppTheme.successColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Stock Out',
              totalOut.toString(),
              Icons.arrow_upward,
              AppTheme.errorColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Transfers',
              totalTransfers.toString(),
              Icons.swap_horiz,
              AppTheme.infoColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search movements by product name, SKU, or reference...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filters
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedMovementType,
                  decoration: const InputDecoration(
                    labelText: 'Movement Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _movementTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMovementType = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedWarehouse,
                  decoration: const InputDecoration(
                    labelText: 'Warehouse',
                    border: OutlineInputBorder(),
                  ),
                  items: _warehouses.map((warehouse) {
                    return DropdownMenuItem(
                      value: warehouse,
                      child: Text(warehouse),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedWarehouse = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMovementsTable() {
    final filteredMovements = _getFilteredMovements();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.2), // Date
            1: FlexColumnWidth(2.0), // Product
            2: FlexColumnWidth(1.0), // Type
            3: FlexColumnWidth(0.8), // Quantity
            4: FlexColumnWidth(1.0), // Stock
            5: FlexColumnWidth(1.5), // Reference
            6: FlexColumnWidth(1.2), // User
            7: FlexColumnWidth(0.8), // Actions
          },
          border: TableBorder.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
          children: [
            // Header Row
            TableRow(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              children: [
                _buildHeaderCell('Date'),
                _buildHeaderCell('Product'),
                _buildHeaderCell('Type'),
                _buildHeaderCell('Quantity'),
                _buildHeaderCell('Stock'),
                _buildHeaderCell('Reference'),
                _buildHeaderCell('User'),
                _buildHeaderCell('Actions'),
              ],
            ),
            // Data Rows
            ...filteredMovements.map((movement) => TableRow(
              children: [
                _buildDateCell(movement),
                _buildProductCell(movement),
                _buildTypeCell(movement),
                _buildQuantityCell(movement),
                _buildStockCell(movement),
                _buildReferenceCell(movement),
                _buildCell(movement.userName),
                _buildActionsCell(movement),
              ],
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCell(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(text),
    );
  }

  Widget _buildDateCell(StockMovement movement) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDate(movement.date),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            _formatTime(movement.date),
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCell(StockMovement movement) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            movement.productName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            movement.sku,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCell(StockMovement movement) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getMovementTypeColor(movement.movementType).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getMovementTypeIcon(movement.movementType),
              size: 16,
              color: _getMovementTypeColor(movement.movementType),
            ),
            const SizedBox(width: 4),
            Text(
              _getMovementTypeText(movement.movementType),
              style: TextStyle(
                color: _getMovementTypeColor(movement.movementType),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityCell(StockMovement movement) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(
        '${movement.quantity > 0 ? '+' : ''}${movement.quantity}',
        style: TextStyle(
          color: movement.quantity > 0 ? AppTheme.successColor : AppTheme.errorColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStockCell(StockMovement movement) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text('${movement.previousStock} → ${movement.newStock}'),
    );
  }

  Widget _buildReferenceCell(StockMovement movement) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            movement.reference,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            movement.referenceType,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCell(StockMovement movement) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.visibility, size: 16),
            onPressed: () {
              // TODO: View movement details
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 16),
            onPressed: () {
              // TODO: Edit movement
            },
          ),
        ],
      ),
    );
  }

  List<StockMovement> _getFilteredMovements() {
    return _movements.where((movement) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!movement.productName.toLowerCase().contains(query) &&
            !movement.sku.toLowerCase().contains(query) &&
            !movement.reference.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Movement type filter
      if (_selectedMovementType != 'All' && 
          _getMovementTypeText(movement.movementType) != _selectedMovementType) {
        return false;
      }

      // Warehouse filter
      if (_selectedWarehouse != 'All' && movement.warehouse != _selectedWarehouse) {
        return false;
      }

      return true;
    }).toList();
  }

  Color _getMovementTypeColor(MovementType type) {
    switch (type) {
      case MovementType.incoming:
        return AppTheme.successColor;
      case MovementType.out:
        return AppTheme.errorColor;
      case MovementType.transfer:
        return AppTheme.infoColor;
      case MovementType.adjustment:
        return AppTheme.warningColor;
    }
  }

  IconData _getMovementTypeIcon(MovementType type) {
    switch (type) {
      case MovementType.incoming:
        return Icons.arrow_downward;
      case MovementType.out:
        return Icons.arrow_upward;
      case MovementType.transfer:
        return Icons.swap_horiz;
      case MovementType.adjustment:
        return Icons.tune;
    }
  }

  String _getMovementTypeText(MovementType type) {
    switch (type) {
      case MovementType.incoming:
        return 'In';
      case MovementType.out:
        return 'Out';
      case MovementType.transfer:
        return 'Transfer';
      case MovementType.adjustment:
        return 'Adjustment';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showAddMovementModal() {
    // Convert movements to the format expected by the modal
    final availableProducts = _movements.map((movement) => {
      'id': movement.productId,
      'name': movement.productName,
      'sku': movement.sku,
      'currentStock': movement.newStock, // Use the latest stock level
    }).toList();

    // Remove duplicates based on product ID
    final uniqueProducts = <String, Map<String, dynamic>>{};
    for (final product in availableProducts) {
      uniqueProducts[product['id'] as String] = product;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddStockMovementModal(
        availableProducts: uniqueProducts.values.toList(),
        onMovementAdded: (movement) {
          // Add the movement to the list
          setState(() {
            _movements.insert(0, movement); // Add at the beginning
          });
        },
      ),
    );
  }
}


