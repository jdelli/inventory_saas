import 'package:flutter/material.dart';
import 'package:inventory_saas/utils/theme.dart';

enum MovementType { incoming, out, transfer, adjustment }

class StockMovement {
  final String id;
  final String productId;
  final String productName;
  final String sku;
  final MovementType movementType;
  final int quantity;
  final int previousStock;
  final int newStock;
  final String warehouse;
  final String reference;
  final String referenceType;
  final String notes;
  final DateTime date;
  final String userId;
  final String userName;

  StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.movementType,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    required this.warehouse,
    required this.reference,
    required this.referenceType,
    required this.notes,
    required this.date,
    required this.userId,
    required this.userName,
  });
}

class AddStockMovementModal extends StatefulWidget {
  final Function(StockMovement) onMovementAdded;
  final List<Map<String, dynamic>> availableProducts;

  const AddStockMovementModal({
    super.key,
    required this.onMovementAdded,
    required this.availableProducts,
  });

  @override
  State<AddStockMovementModal> createState() => _AddStockMovementModalState();
}

class _AddStockMovementModalState extends State<AddStockMovementModal> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  final _previousStockController = TextEditingController();

  String? _selectedProductId;
  String? _selectedProductName;
  String? _selectedSku;
  MovementType _selectedMovementType = MovementType.incoming;
  String _selectedWarehouse = 'Main Warehouse';
  String _selectedReferenceType = 'Purchase Order';
  DateTime _selectedDate = DateTime.now();
  String _userId = 'user_001';
  String _userName = 'John Smith';

  final List<String> _warehouses = [
    'Main Warehouse', 'Secondary Warehouse', 'Store A', 'Store B', 'Store C'
  ];

  final List<String> _referenceTypes = [
    'Purchase Order', 'Sales Order', 'Transfer', 'Adjustment', 'Return', 'Damage'
  ];

  @override
  void dispose() {
    _quantityController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    _previousStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 600,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            const SizedBox(height: 24),
            
            // Form
            Expanded(
              child: _buildForm(),
            ),
            
            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.swap_horiz,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Stock Movement',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Record inventory movement or adjustment',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Product Selection
            _buildSectionHeader('Product Information'),
            const SizedBox(height: 16),
            _buildProductDropdown(),
            const SizedBox(height: 16),
                         Row(
               children: [
                 Expanded(child: _buildReadOnlyField('SKU', _selectedSku ?? '')),
                 const SizedBox(width: 16),
                 Expanded(child: _buildTextField('Previous Stock', _previousStockController, enabled: false)),
               ],
             ),
            
            const SizedBox(height: 32),
            
            // Movement Details
            _buildSectionHeader('Movement Details'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildMovementTypeDropdown()),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Quantity', _quantityController, validator: _validateQuantity)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDropdown('Warehouse', _selectedWarehouse, _warehouses, (value) {
                  setState(() => _selectedWarehouse = value!);
                })),
                const SizedBox(width: 16),
                Expanded(child: _buildDatePicker()),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Reference Information
            _buildSectionHeader('Reference Information'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDropdown('Reference Type', _selectedReferenceType, _referenceTypes, (value) {
                  setState(() => _selectedReferenceType = value!);
                })),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Reference Number', _referenceController, validator: _validateRequired)),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField('Notes', _notesController, maxLines: 3),
            
            const SizedBox(height: 32),
            
            // Summary
            _buildSectionHeader('Summary'),
            const SizedBox(height: 16),
            _buildSummaryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildProductDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedProductId,
      decoration: InputDecoration(
        labelText: 'Select Product',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: widget.availableProducts.map((product) => DropdownMenuItem<String>(
        value: product['id'] as String,
        child: Text('${product['name']} (${product['sku']})'),
      )).toList(),
      onChanged: (value) {
        setState(() {
          _selectedProductId = value;
          final product = widget.availableProducts.firstWhere((p) => p['id'] == value);
          _selectedProductName = product['name'] as String;
          _selectedSku = product['sku'] as String;
          _previousStockController.text = (product['currentStock'] as int).toString();
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a product';
        }
        return null;
      },
    );
  }

  Widget _buildMovementTypeDropdown() {
    return DropdownButtonFormField<MovementType>(
      value: _selectedMovementType,
      decoration: InputDecoration(
        labelText: 'Movement Type',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: MovementType.values.map((type) => DropdownMenuItem(
        value: type,
        child: Row(
          children: [
            Icon(
              _getMovementTypeIcon(type),
              size: 16,
              color: _getMovementTypeColor(type),
            ),
            const SizedBox(width: 8),
            Text(_getMovementTypeText(type)),
          ],
        ),
      )).toList(),
      onChanged: (value) {
        setState(() => _selectedMovementType = value!);
      },
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      )).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {
    String? Function(String?)? validator,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }



  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDate(_selectedDate)),
            const Icon(Icons.calendar_today, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final previousStock = int.tryParse(_previousStockController.text) ?? 0;
    final newStock = _calculateNewStock(previousStock, quantity);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _getMovementTypeIcon(_selectedMovementType),
                color: _getMovementTypeColor(_selectedMovementType),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Stock Movement Summary',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem('Previous Stock', previousStock.toString()),
              ),
              Icon(
                Icons.arrow_forward,
                color: AppTheme.textSecondary,
                size: 16,
              ),
              Expanded(
                child: _buildSummaryItem('New Stock', newStock.toString()),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildSummaryItem('Movement', '${quantity > 0 ? '+' : ''}$quantity'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppTheme.textSecondary),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveMovement,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Add Movement'),
          ),
        ),
      ],
    );
  }

  void _saveMovement() {
    if (_formKey.currentState!.validate()) {
      final quantity = int.parse(_quantityController.text);
      final previousStock = int.parse(_previousStockController.text);
      final newStock = _calculateNewStock(previousStock, quantity);

      final movement = StockMovement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: _selectedProductId!,
        productName: _selectedProductName!,
        sku: _selectedSku!,
        movementType: _selectedMovementType,
        quantity: quantity,
        previousStock: previousStock,
        newStock: newStock,
        warehouse: _selectedWarehouse,
        reference: _referenceController.text,
        referenceType: _selectedReferenceType,
        notes: _notesController.text,
        date: _selectedDate,
        userId: _userId,
        userName: _userName,
      );

      widget.onMovementAdded(movement);
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock movement recorded successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  int _calculateNewStock(int previousStock, int quantity) {
    switch (_selectedMovementType) {
      case MovementType.incoming:
      case MovementType.adjustment:
        return previousStock + quantity;
      case MovementType.out:
        return previousStock - quantity;
      case MovementType.transfer:
        return previousStock - quantity; // Transfer out from current warehouse
    }
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
        return 'Stock In';
      case MovementType.out:
        return 'Stock Out';
      case MovementType.transfer:
        return 'Transfer';
      case MovementType.adjustment:
        return 'Adjustment';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }
    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'Please enter a valid number';
    }
    if (_selectedMovementType == MovementType.out && quantity <= 0) {
      return 'Quantity must be positive for stock out';
    }
    return null;
  }
}
