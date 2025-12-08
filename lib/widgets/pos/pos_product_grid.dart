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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 2,
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
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Search products, SKU, or barcode...',
          hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.6)),
          prefixIcon: Icon(Icons.search, color: AppTheme.primaryColor),
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
              : Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.qr_code_scanner, size: 20, color: AppTheme.primaryColor),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: AppTheme.textSecondary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No products found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(4), // Add padding for shadows
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 0.7,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index]);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return _ProductCard(product: product);
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shadow blob
          Positioned(
            bottom: 25,
            child: Container(
              width: 50,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
                boxShadow: const [BoxShadow(blurRadius: 5)],
              ),
            ),
          ),
          Icon(
            Icons.inventory_2,
            size: 48,
            color: AppTheme.primaryColor.withOpacity(0.4),
          ),
        ],
      ),
    );
  }

  void _showAddedFeedback(String productName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$productName added to cart',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981), // Emerald Green
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(24),
        elevation: 10,
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final posProvider = Provider.of<POSProvider>(context, listen: false);
    final product = widget.product;
    final isOutOfStock = product.isOutOfStock;
    final isLowStock = product.isLowStock;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isOutOfStock ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -8.0 : 0.0), // Lift effect
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            // Dynamic shadow based on hover
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(_isHovered ? 0.2 : 0.0),
              blurRadius: _isHovered ? 20 : 0,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.08),
              blurRadius: _isHovered ? 25 : 15,
              offset: Offset(0, _isHovered ? 15 : 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: isOutOfStock
                ? null
                : () {
                    posProvider.addToCart(product);
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart'),
                        duration: const Duration(milliseconds: 600),
                        behavior: SnackBarBehavior.floating,
                        width: 280,
                        backgroundColor: AppTheme.successColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
            splashColor: AppTheme.primaryColor.withOpacity(0.1),
            highlightColor: AppTheme.primaryColor.withOpacity(0.05),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Area with subtle gradient backing
                    Expanded(
                      flex: 10,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFF5F7FA), // Light greyish blue
                              Color(0xFFE4E7EB), // Darker grey
                            ],
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (product.imageUrl.isNotEmpty)
                              Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                              )
                            else
                              _buildPlaceholderIcon(),
                          ],
                        ),
                      ),
                    ),
                    
                    // Content Area
                    Expanded(
                      flex: 9,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: Color(0xFFF0F0F0)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  margin: const EdgeInsets.only(bottom: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.textSecondary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    product.category.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textSecondary,
                                      letterSpacing: 0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D3748),
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Price',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '₱${product.sellingPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.primaryColor,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                // Add button icon
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: _isHovered ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.4),
                                        blurRadius: _isHovered ? 10 : 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Colors.white,
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
                
                // Stock Indicator (3D Badge)
                if(!isOutOfStock)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLowStock ? AppTheme.warningColor : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.layers, 
                          size: 12, 
                          color: isLowStock ? Colors.white : AppTheme.textSecondary
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product.currentStock}',
                          style: TextStyle(
                            color: isLowStock ? Colors.white : AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Out of Stock Overlay
                if (isOutOfStock)
                  Container(
                    color: Colors.white.withOpacity(0.6),
                    alignment: Alignment.center,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                             BoxShadow(
                              color: AppTheme.errorColor.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'OUT OF STOCK',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPlaceholderIcon() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shadow blob
          Positioned(
            bottom: 25,
            child: Container(
              width: 50,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
                boxShadow: const [BoxShadow(blurRadius: 5)],
              ),
            ),
          ),
          Icon(
            Icons.inventory_2,
            size: 48,
            color: AppTheme.primaryColor.withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}

