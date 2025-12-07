import 'package:flutter/material.dart';
import 'package:inventory_saas/utils/theme.dart';
import 'package:inventory_saas/widgets/dashboard/stat_card.dart';
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
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stock Movement',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Track inventory changes',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddMovementModal,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Movement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          // Statistics Cards
          _buildStatisticsCards(),

          const SizedBox(height: 24),

          // Search and Filters
          _buildSearchAndFilters(),

          const SizedBox(height: 24),

          // Movements Table
          _buildMovementsTable(),
        ],
      ),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        final cards = [
          StatCard(
            title: 'Total Movements',
            value: filteredMovements.length.toString(),
            icon: Icons.swap_horiz,
            color: AppTheme.primaryColor,
          ),
          StatCard(
            title: 'Stock In',
            value: totalIn.toString(),
            icon: Icons.arrow_downward,
            color: AppTheme.successColor,
          ),
          StatCard(
            title: 'Stock Out',
            value: totalOut.toString(),
            icon: Icons.arrow_upward,
            color: AppTheme.errorColor,
          ),
          StatCard(
            title: 'Transfers',
            value: totalTransfers.toString(),
            icon: Icons.sync_alt,
            color: AppTheme.infoColor,
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
    );
  }

  Widget _buildSearchAndFilters() {
    return Row(
      children: [
        // Search Bar
        Expanded(
          flex: 2,
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search movements...',
              prefixIcon: const Icon(Icons.search, size: 18),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
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
        ),
        
        const SizedBox(width: 12),
        
        // Filters
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedMovementType,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Type',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedWarehouse,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Warehouse',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
    );
  }

  Widget _buildMovementsTable() {
    final filteredMovements = _getFilteredMovements();
    
    if (filteredMovements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Icon(Icons.history, size: 48, color: AppTheme.textSecondary),
              const SizedBox(height: 16),
              const Text('No stock movements found'),
            ],
          ),
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
            DataColumn(label: Text('DATE', style: _headerStyle())),
            DataColumn(label: Text('PRODUCT', style: _headerStyle())),
            DataColumn(label: Text('TYPE', style: _headerStyle())),
            DataColumn(label: Text('QTY', style: _headerStyle())),
            DataColumn(label: Text('STOCK', style: _headerStyle())),
            DataColumn(label: Text('REF', style: _headerStyle())),
            DataColumn(label: Text('USER', style: _headerStyle())),
            DataColumn(label: Text('ACTIONS', style: _headerStyle())),
          ],
          rows: filteredMovements.map((movement) => DataRow(
            cells: [
              DataCell(_buildDateCell(movement)),
              DataCell(_buildProductCell(movement)),
              DataCell(_buildTypeCell(movement)),
              DataCell(_buildQuantityCell(movement)),
              DataCell(_buildStockCell(movement)),
              DataCell(_buildReferenceCell(movement)),
              DataCell(Text(movement.userName, style: const TextStyle(fontSize: 13))),
              DataCell(_buildActionsCell(movement)),
            ],
          )).toList(),
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

  Widget _buildDateCell(StockMovement movement) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatDate(movement.date),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        Text(
          _formatTime(movement.date),
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildProductCell(StockMovement movement) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          movement.productName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        Text(
          movement.sku,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeCell(StockMovement movement) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getMovementTypeColor(movement.movementType).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getMovementTypeColor(movement.movementType).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getMovementTypeIcon(movement.movementType),
            size: 14,
            color: _getMovementTypeColor(movement.movementType),
          ),
          const SizedBox(width: 4),
          Text(
            _getMovementTypeText(movement.movementType),
            style: TextStyle(
              color: _getMovementTypeColor(movement.movementType),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityCell(StockMovement movement) {
    return Text(
      '${movement.quantity > 0 ? '+' : ''}${movement.quantity}',
      style: TextStyle(
        color: movement.quantity > 0 ? AppTheme.successColor : AppTheme.errorColor,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }

  Widget _buildStockCell(StockMovement movement) {
    return Text(
      '${movement.previousStock} → ${movement.newStock}',
      style: const TextStyle(fontSize: 13),
    );
  }

  Widget _buildReferenceCell(StockMovement movement) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          movement.reference,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        Text(
          movement.referenceType,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsCell(StockMovement movement) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.visibility_outlined, size: 16),
          onPressed: () {
            // TODO: View movement details
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 16),
          onPressed: () {
            // TODO: Edit movement
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
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


