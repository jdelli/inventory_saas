import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory_saas/utils/theme.dart';
import 'package:inventory_saas/models/product.dart';
import 'dart:math';

class AddProductModal extends StatefulWidget {
  final Future<void> Function(Product) onProductAdded;

  const AddProductModal({
    super.key,
    required this.onProductAdded,
  });

  @override
  State<AddProductModal> createState() => _AddProductModalState();
}

class _AddProductModalState extends State<AddProductModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _currentStockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _maxStockController = TextEditingController();
  final _unitController = TextEditingController();
  final _weightController = TextEditingController();
  final _dimensionsController = TextEditingController();

  String _selectedCategory = 'Electronics';
  String _selectedBrand = 'Apple';
  String _selectedSupplier = 'Supplier A';
  String _selectedWarehouse = 'Main Warehouse';
  String _imageUrl = '';
  bool _isActive = true;
  bool _trackStock = true;
  bool _allowNegativeStock = false;
  bool _isSaving = false;

  final List<String> _categories = [
    'Electronics', 'Computers', 'Audio', 'Accessories', 'Software',
    'Mobile Phones', 'Tablets', 'Laptops', 'Desktops', 'Gaming'
  ];

  final List<String> _brands = [
    'Apple', 'Samsung', 'Dell', 'Sony', 'Microsoft', 'Logitech',
    'HP', 'Lenovo', 'Asus', 'Acer', 'Canon', 'Nikon'
  ];

  final List<String> _suppliers = [
    'Supplier A', 'Supplier B', 'Supplier C', 'Supplier D', 'Supplier E'
  ];

  final List<String> _warehouses = [
    'Main Warehouse', 'Secondary Warehouse', 'Store A', 'Store B', 'Store C'
  ];

  @override
  void initState() {
    super.initState();
    _unitController.text = 'pcs';
    _currentStockController.text = '0';
    _minStockController.text = '0';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _currentStockController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    _unitController.dispose();
    _weightController.dispose();
    _dimensionsController.dispose();
    super.dispose();
  }

  void _generateSKU() {
    if (_nameController.text.isNotEmpty && _selectedCategory.isNotEmpty) {
      final namePart = _nameController.text.toUpperCase().replaceAll(' ', '').substring(0, 
          _nameController.text.length > 6 ? 6 : _nameController.text.length);
      final categoryPart = _selectedCategory.substring(0, 3).toUpperCase();
      final randomPart = Random().nextInt(9999).toString().padLeft(4, '0');
      _skuController.text = '$categoryPart-$namePart-$randomPart';
    }
  }

  void _generateBarcode() {
    // Generate a random 13-digit barcode (EAN-13 format)
    final random = Random();
    String barcode = '';
    for (int i = 0; i < 12; i++) {
      barcode += random.nextInt(10).toString();
    }
    // Calculate check digit for EAN-13
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      int digit = int.parse(barcode[i]);
      sum += (i % 2 == 0) ? digit : digit * 3;
    }
    int checkDigit = (10 - (sum % 10)) % 10;
    barcode += checkDigit.toString();
    _barcodeController.text = barcode;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 800,
        height: MediaQuery.of(context).size.height * 0.9,
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
            Icons.add_box,
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
                'Add New Product',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Fill in the product details below',
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
            // Basic Information
            _buildSectionHeader('Basic Information'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField('Product Name', _nameController, 
                    validator: _validateRequired,
                    onChanged: (value) => _generateSKU(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildTextField('SKU', _skuController, validator: _validateRequired)),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _generateSKU,
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Generate SKU',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildTextField('Barcode', _barcodeController)),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _generateBarcode,
                        icon: const Icon(Icons.qr_code),
                        tooltip: 'Generate Barcode',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildDropdown('Category', _selectedCategory, _categories, (value) {
                  setState(() {
                    _selectedCategory = value!;
                    _generateSKU(); // Regenerate SKU when category changes
                  });
                })),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDropdown('Brand', _selectedBrand, _brands, (value) {
                  setState(() => _selectedBrand = value!);
                })),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Unit (pcs, kg, etc.)', _unitController, defaultValue: 'pcs')),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField('Description', _descriptionController, maxLines: 3),
            
            const SizedBox(height: 32),
            
            // Pricing
            _buildSectionHeader('Pricing'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('Cost Price (\$)', _costPriceController, 
                  validator: _validatePrice,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Selling Price (\$)', _sellingPriceController, 
                  validator: _validatePrice,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                )),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Stock Management
            _buildSectionHeader('Stock Management'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('Current Stock', _currentStockController, 
                  validator: _validateNumber, 
                  defaultValue: '0',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Minimum Stock', _minStockController, 
                  validator: _validateNumber, 
                  defaultValue: '0',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                )),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('Maximum Stock', _maxStockController, 
                  validator: _validateNumber,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildDropdown('Warehouse', _selectedWarehouse, _warehouses, (value) {
                  setState(() => _selectedWarehouse = value!);
                })),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDropdown('Supplier', _selectedSupplier, _suppliers, (value) {
                  setState(() => _selectedSupplier = value!);
                })),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Weight (kg)', _weightController)),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField('Dimensions (L x W x H cm)', _dimensionsController),
            
            const SizedBox(height: 32),
            
            // Settings
            _buildSectionHeader('Settings'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSwitch('Active Product', _isActive, (value) {
                    setState(() => _isActive = value);
                  }),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSwitch('Track Stock', _trackStock, (value) {
                    setState(() => _trackStock = value);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSwitch('Allow Negative Stock', _allowNegativeStock, (value) {
              setState(() => _allowNegativeStock = value);
            }),
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

  Widget _buildTextField(String label, TextEditingController controller, {
    String? Function(String?)? validator,
    int maxLines = 1,
    String? defaultValue,
    Function(String)? onChanged,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    if (defaultValue != null && controller.text.isEmpty) {
      controller.text = defaultValue;
    }
    
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
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

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
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
            onPressed: _isSaving ? null : _saveProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isSaving 
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('Adding...'),
                  ],
                )
              : const Text('Add Product'),
          ),
        ),
      ],
    );
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        print('📝 AddProductModal: Creating product object...');
        final product = await addProduct();
        
        print('📤 AddProductModal: Calling onProductAdded callback...');
        await widget.onProductAdded(product);
        print('✅ AddProductModal: Product added successfully, closing modal...');
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product "${product.name}" added successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } catch (e) {
        print('❌ AddProductModal: Error adding product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Public function to add a product
  /// Returns the created Product object
  /// Throws an exception if validation fails or product creation fails
  Future<Product> addProduct() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      throw Exception('Form validation failed');
    }

    // Create product object
    final product = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      sku: _skuController.text.trim(),
      barcode: _barcodeController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      brand: _selectedBrand,
      costPrice: double.tryParse(_costPriceController.text) ?? 0.0,
      sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0.0,
      currentStock: int.tryParse(_currentStockController.text) ?? 0,
      minStockLevel: int.tryParse(_minStockController.text) ?? 0,
      maxStockLevel: int.tryParse(_maxStockController.text) ?? 0,
      unit: _unitController.text.isNotEmpty ? _unitController.text : 'pcs',
      warehouse: _selectedWarehouse,
      location: 'A1-B1-C1', // Default location
      supplierId: _selectedSupplier,
      imageUrl: _imageUrl,
      isActive: _isActive,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Validate business logic
    if (product.costPrice > product.sellingPrice) {
      throw Exception('Cost price cannot be higher than selling price');
    }

    if (product.currentStock < 0 && !_allowNegativeStock) {
      throw Exception('Negative stock is not allowed');
    }

    if (product.minStockLevel > product.maxStockLevel && product.maxStockLevel > 0) {
      throw Exception('Minimum stock level cannot be higher than maximum stock level');
    }

    return product;
  }

  /// Public function to get current form data as a Product object
  /// This doesn't validate or save, just returns the current form state
  Product getCurrentFormData() {
    return Product(
      id: '', // Empty as this is not saved yet
      name: _nameController.text.trim(),
      sku: _skuController.text.trim(),
      barcode: _barcodeController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      brand: _selectedBrand,
      costPrice: double.tryParse(_costPriceController.text) ?? 0.0,
      sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0.0,
      currentStock: int.tryParse(_currentStockController.text) ?? 0,
      minStockLevel: int.tryParse(_minStockController.text) ?? 0,
      maxStockLevel: int.tryParse(_maxStockController.text) ?? 0,
      unit: _unitController.text.isNotEmpty ? _unitController.text : 'pcs',
      warehouse: _selectedWarehouse,
      location: 'A1-B1-C1',
      supplierId: _selectedSupplier,
      imageUrl: _imageUrl,
      isActive: _isActive,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Public function to check if the form has unsaved changes
  bool hasUnsavedChanges() {
    return _nameController.text.isNotEmpty ||
           _skuController.text.isNotEmpty ||
           _barcodeController.text.isNotEmpty ||
           _descriptionController.text.isNotEmpty ||
           _costPriceController.text.isNotEmpty ||
           _sellingPriceController.text.isNotEmpty ||
           _currentStockController.text != '0' ||
           _minStockController.text != '0' ||
           _maxStockController.text.isNotEmpty ||
           _unitController.text != 'pcs' ||
           _weightController.text.isNotEmpty ||
           _dimensionsController.text.isNotEmpty;
  }

  /// Public function to reset the form to initial state
  void resetForm() {
    setState(() {
      _nameController.clear();
      _skuController.clear();
      _barcodeController.clear();
      _descriptionController.clear();
      _costPriceController.clear();
      _sellingPriceController.clear();
      _currentStockController.text = '0';
      _minStockController.text = '0';
      _maxStockController.clear();
      _unitController.text = 'pcs';
      _weightController.clear();
      _dimensionsController.clear();
      _selectedCategory = 'Electronics';
      _selectedBrand = 'Apple';
      _selectedSupplier = 'Supplier A';
      _selectedWarehouse = 'Main Warehouse';
      _imageUrl = '';
      _isActive = true;
      _trackStock = true;
      _allowNegativeStock = false;
    });
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null || price < 0) {
      return 'Please enter a valid price';
    }
    return null;
  }

  String? _validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    final number = int.tryParse(value);
    if (number == null || number < 0) {
      return 'Please enter a valid number';
    }
    return null;
  }
}
