import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory_saas/providers/inventory_provider.dart';
import 'package:inventory_saas/models/product.dart';
import 'package:inventory_saas/utils/theme.dart';
import 'package:inventory_saas/widgets/inventory/add_product_modal.dart';
import 'package:inventory_saas/widgets/inventory/product_view_modal.dart';

class ProductsTab extends StatefulWidget {
  const ProductsTab({super.key});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedBrand = 'All';
  String _selectedStatus = 'All';

  final List<String> _categories = ['All', 'Electronics', 'Computers', 'Audio', 'Accessories', 'Software'];
  final List<String> _brands = ['All', 'Apple', 'Samsung', 'Dell', 'Sony', 'Microsoft', 'Logitech'];
  final List<String> _statuses = ['All', 'Active', 'Inactive', 'Low Stock', 'Out of Stock'];

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        if (inventoryProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (inventoryProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: AppTheme.errorColor, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${inventoryProvider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => inventoryProvider.loadProducts(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Search and Filters
            _buildSearchAndFilters(),
            
            // Statistics Cards
            _buildStatisticsCards(inventoryProvider),
            
            // Products Table
            Expanded(
              child: _buildProductsTable(inventoryProvider),
            ),
          ],
        );
      },
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
          // Header with Add Product Button
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products by name, SKU, or barcode...',
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
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showAddProductModal,
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Filters
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedBrand,
                  decoration: const InputDecoration(
                    labelText: 'Brand',
                    border: OutlineInputBorder(),
                  ),
                  items: _brands.map((brand) {
                    return DropdownMenuItem(
                      value: brand,
                      child: Text(brand),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBrand = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: _statuses.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
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

  Widget _buildStatisticsCards(InventoryProvider provider) {
    final filteredProducts = _getFilteredProducts(provider.products);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Products',
              filteredProducts.length.toString(),
              Icons.inventory_2,
              AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Low Stock',
              provider.lowStockProducts.length.toString(),
              Icons.warning,
              AppTheme.warningColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Out of Stock',
              provider.outOfStockProducts.length.toString(),
              Icons.error,
              AppTheme.errorColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Total Value',
              '\$${provider.totalStockValue.toStringAsFixed(0)}',
              Icons.attach_money,
              AppTheme.successColor,
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

  Widget _buildProductsTable(InventoryProvider provider) {
    final filteredProducts = _getFilteredProducts(provider.products);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2.5), // Product
            1: FlexColumnWidth(1.5), // SKU
            2: FlexColumnWidth(1.2), // Category
            3: FlexColumnWidth(1.2), // Stock
            4: FlexColumnWidth(1.0), // Cost
            5: FlexColumnWidth(1.0), // Price
            6: FlexColumnWidth(1.0), // Status
            7: FlexColumnWidth(1.0), // Actions
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
                _buildHeaderCell('Product'),
                _buildHeaderCell('SKU'),
                _buildHeaderCell('Category'),
                _buildHeaderCell('Stock'),
                _buildHeaderCell('Cost'),
                _buildHeaderCell('Price'),
                _buildHeaderCell('Status'),
                _buildHeaderCell('Actions'),
              ],
            ),
            // Data Rows
            ...filteredProducts.map((product) => TableRow(
              children: [
                _buildProductCell(product),
                _buildCell(product.sku),
                _buildCell(product.category),
                _buildStockCell(product),
                _buildCell('\$${product.costPrice.toStringAsFixed(2)}'),
                _buildCell('\$${product.sellingPrice.toStringAsFixed(2)}'),
                _buildStatusCell(product),
                _buildActionsCell(product),
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

  Widget _buildProductCell(Product product) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(product.imageUrl),
            radius: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  product.brand,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockCell(Product product) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Text('${product.currentStock} ${product.unit}'),
          if (product.isLowStock)
            Container(
              margin: const EdgeInsets.only(left: 4),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'LOW',
                style: TextStyle(
                  color: AppTheme.warningColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCell(Product product) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor(product).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _getStatusText(product),
          style: TextStyle(
            color: _getStatusColor(product),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildActionsCell(Product product) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit, size: 16),
            onPressed: () {
              // TODO: Edit product
            },
          ),
          IconButton(
            icon: const Icon(Icons.visibility, size: 16),
            onPressed: () => _showProductViewModal(product),
            tooltip: 'View Details',
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 16),
            onPressed: () {
              // TODO: Delete product
            },
          ),
        ],
      ),
    );
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    return products.where((product) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
                 if (!product.name.toLowerCase().contains(query) &&
             !product.sku.toLowerCase().contains(query) &&
             !product.barcode.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != 'All' && product.category != _selectedCategory) {
        return false;
      }

      // Brand filter
      if (_selectedBrand != 'All' && product.brand != _selectedBrand) {
        return false;
      }

      // Status filter
      if (_selectedStatus != 'All') {
        switch (_selectedStatus) {
          case 'Active':
            if (!product.isActive) return false;
            break;
          case 'Inactive':
            if (product.isActive) return false;
            break;
          case 'Low Stock':
            if (!product.isLowStock) return false;
            break;
          case 'Out of Stock':
            if (!product.isOutOfStock) return false;
            break;
        }
      }

      return true;
    }).toList();
  }

  Color _getStatusColor(Product product) {
    if (!product.isActive) return AppTheme.textSecondary;
    if (product.isOutOfStock) return AppTheme.errorColor;
    if (product.isLowStock) return AppTheme.warningColor;
    return AppTheme.successColor;
  }

  String _getStatusText(Product product) {
    if (!product.isActive) return 'Inactive';
    if (product.isOutOfStock) return 'Out of Stock';
    if (product.isLowStock) return 'Low Stock';
    return 'In Stock';
  }

  void _showAddProductModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddProductModal(
        onProductAdded: (product) async {
          // Add the product to the provider
          final provider = Provider.of<InventoryProvider>(context, listen: false);
          await provider.addProduct(product);
        },
      ),
    );
  }

  void _showProductViewModal(Product product) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ProductViewModal(product: product),
    );
  }
}
