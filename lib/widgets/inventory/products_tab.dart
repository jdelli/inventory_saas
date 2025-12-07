import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory_saas/providers/inventory_provider.dart';
import 'package:inventory_saas/models/product.dart';
import 'package:inventory_saas/utils/theme.dart';
import 'package:inventory_saas/widgets/inventory/add_product_modal.dart';
import 'package:inventory_saas/widgets/inventory/product_view_modal.dart';
import 'package:inventory_saas/widgets/dashboard/stat_card.dart';

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
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          final cards = [
             StatCard(
               title: 'Total Products',
               value: filteredProducts.length.toString(),
               icon: Icons.inventory_2_outlined,
               color: AppTheme.primaryColor,
             ),
             StatCard(
               title: 'Low Stock',
               value: provider.lowStockProducts.length.toString(),
               icon: Icons.warning_amber_rounded,
               color: AppTheme.warningColor,
             ),
             StatCard(
               title: 'Out of Stock',
               value: provider.outOfStockProducts.length.toString(),
               icon: Icons.error_outline,
               color: AppTheme.errorColor,
             ),
             StatCard(
               title: 'Total Value',
               value: '\$${provider.totalStockValue.toStringAsFixed(0)}',
               icon: Icons.attach_money,
               color: AppTheme.successColor,
             ),
          ];

          if (!isWide) {
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: cards.map((card) => SizedBox(
                width: (constraints.maxWidth - 12) / 2, // 2 columns approx
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
    );
  }

  Widget _buildProductsTable(InventoryProvider provider) {
    final filteredProducts = _getFilteredProducts(provider.products);
    
    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(3), // Product
            1: FlexColumnWidth(1.5), // SKU
            2: FlexColumnWidth(1.5), // Category
            3: FlexColumnWidth(1.2), // Stock
            4: FlexColumnWidth(1.0), // Cost
            5: FlexColumnWidth(1.0), // Price
            6: FlexColumnWidth(1.2), // Status
            7: FixedColumnWidth(100), // Actions
          },
          border: TableBorder(
            horizontalInside: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1), width: 1),
            bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1), width: 1),
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            // Header Row
            TableRow(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1)),
              ),
              children: [
                _buildHeaderCell('Product'),
                _buildHeaderCell('SKU'),
                _buildHeaderCell('Category'),
                _buildHeaderCell('Stock'),
                _buildHeaderCell('Cost'),
                _buildHeaderCell('Price'),
                _buildHeaderCell('Status'),
                _buildHeaderCell('Actions', alignRight: true),
              ],
            ),
            // Data Rows
            ...filteredProducts.map((product) => TableRow(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              children: [
                _buildProductCell(product),
                _buildCell(product.sku),
                _buildCell(product.category),
                _buildStockCell(product),
                _buildCell('₱${product.costPrice.toStringAsFixed(2)}'),
                _buildCell('₱${product.sellingPrice.toStringAsFixed(2)}', isBold: true),
                _buildStatusCell(product),
                _buildActionsCell(product),
              ],
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, {bool alignRight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCell(String text, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildProductCell(Product product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: product.imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(product.imageUrl, fit: BoxFit.cover),
                )
              : const Icon(Icons.image_not_supported_outlined, size: 16, color: AppTheme.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (product.brand != 'Generic')
                  Text(
                    product.brand,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Text(
            '${product.currentStock}',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
          const SizedBox(width: 4),
          Text(
            product.unit,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCell(Product product) {
    Color color = _getStatusColor(product);
    String text = _getStatusText(product);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildActionsCell(Product product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 16),
            onPressed: () {
              // TODO: Edit
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Edit',
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 16),
            onPressed: () => _showProductViewModal(product),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'View',
          ),
          const SizedBox(width: 12),
           IconButton(
            icon: const Icon(Icons.delete_outline, size: 16, color: AppTheme.textSecondary),
            onPressed: () {
               // TODO: Delete
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Delete',
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
