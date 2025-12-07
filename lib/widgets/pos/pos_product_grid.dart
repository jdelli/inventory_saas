import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory_saas/models/product.dart';
import 'package:inventory_saas/providers/inventory_provider.dart';
import 'package:inventory_saas/providers/pos_provider.dart';
import 'package:inventory_saas/utils/theme.dart';

class POSProductGrid extends StatefulWidget {
  const POSProductGrid({super.key});

  @override
  State<POSProductGrid> createState() => _POSProductGridState();
}

class _POSProductGridState extends State<POSProductGrid> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        // Get unique categories
        final categories = ['All', ...inventoryProvider.products
            .map((p) => p.category)
            .toSet()
            .toList()];

        // Filter products
        var filteredProducts = inventoryProvider.products.where((product) {
          final matchesSearch = _searchQuery.isEmpty ||
              product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.sku.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.barcode.contains(_searchQuery);
          
          final matchesCategory = _selectedCategory == 'All' ||
              product.category == _selectedCategory;
          
          return matchesSearch && matchesCategory && product.isActive;
        }).toList();

        return Column(
          children: [
            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 16),
            
            // Category Chips
            _buildCategoryChips(categories),
            const SizedBox(height: 16),
            
            // Product Grid
            Expanded(
              child: _buildProductGrid(filteredProducts),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search products, SKU, or barcode...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : const Icon(Icons.qr_code_scanner, color: AppTheme.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(List<String> categories) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: Theme.of(context).cardColor,
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index]);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final posProvider = Provider.of<POSProvider>(context, listen: false);
    final isOutOfStock = product.isOutOfStock;
    final isLowStock = product.isLowStock;

    return GestureDetector(
      onTap: isOutOfStock
          ? null
          : () {
              posProvider.addToCart(product);
              _showAddedFeedback(product.name);
            },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOutOfStock
                ? AppTheme.errorColor.withOpacity(0.3)
                : Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product Image/Icon area
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: product.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                            ),
                          )
                        : _buildPlaceholderIcon(),
                  ),
                ),
                
                // Content
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10), // Reduced padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₱${product.sellingPrice.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryColor,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Stock Indicator (Mini badge)
            if (!isOutOfStock)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isLowStock ? AppTheme.warningColor : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isLowStock ? Colors.transparent : Colors.grey.withOpacity(0.3),
                    ),
                    boxShadow: [
                      if (!isLowStock)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                        )
                    ],
                  ),
                  child: Text(
                    '${product.currentStock}',
                    style: TextStyle(
                      color: isLowStock ? Colors.white : AppTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            
            // Out of Stock Overlay
            if (isOutOfStock)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'OUT OF STOCK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Center(
      child: Icon(
        Icons.inventory_2,
        size: 40,
        color: AppTheme.primaryColor.withOpacity(0.5),
      ),
    );
  }

  void _showAddedFeedback(String productName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text('$productName added to cart'),
            ),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
