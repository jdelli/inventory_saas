import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:inventory_saas/models/product.dart';
import 'package:inventory_saas/providers/inventory_provider.dart';
import 'package:inventory_saas/providers/pos_provider.dart';

class POSProductGrid extends StatefulWidget {
  const POSProductGrid({super.key});

  @override
  State<POSProductGrid> createState() => _POSProductGridState();
}

class _POSProductGridState extends State<POSProductGrid> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final Map<String, Color> _categoryColors = {};
  final List<Color> _palette = const [
    Color(0xFF3B82F6), // Blue
    Color(0xFF8B5CF6), // Purple
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFF6366F1), // Indigo
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        final categories = [
          'All',
          ...inventoryProvider.products.map((p) => p.category).toSet()
        ];

        final filteredProducts = inventoryProvider.products.where((product) {
          final matchesSearch = _searchQuery.isEmpty ||
              product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.sku.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.barcode.contains(_searchQuery);

          final matchesCategory =
              _selectedCategory == 'All' || product.category == _selectedCategory;
          return matchesSearch && matchesCategory && product.isActive;
        }).toList();

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF141B2F), const Color(0xFF0F1526)]
                  : [const Color(0xFFFDFEFF), const Color(0xFFF2F6FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // Search & Filter Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  children: [
                    Expanded(child: _buildSearchBar(isDark)),
                    const SizedBox(width: 12),
                    _buildFilterButton(isDark),
                  ],
                ),
              ),

              // Category Chips
              SizedBox(
                height: 46,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = _selectedCategory == category;
                    final color = category == 'All'
                        ? Theme.of(context).colorScheme.primary
                        : _categoryColors.putIfAbsent(
                            category,
                            () => _palette[index % _palette.length],
                          );

                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _buildCategoryChip(
                        category: category,
                        isSelected: isSelected,
                        color: color,
                        isDark: isDark,
                        onSelected: () =>
                            setState(() => _selectedCategory = category),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Products Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.25)
                                : const Color(0xFF94A3B8).withOpacity(0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                            spreadRadius: -6,
                          ),
                        ],
                      ),
                      child: Text(
                        '${filteredProducts.length} products',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF475569),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (_searchQuery.isNotEmpty || _selectedCategory != 'All')
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _selectedCategory = 'All';
                            _searchController.clear();
                          });
                        },
                        icon: Icon(
                          Icons.clear_all_rounded,
                          size: 16,
                          color: isDark
                              ? Colors.white60
                              : const Color(0xFF64748B),
                        ),
                        label: Text(
                          'Clear filters',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF475569),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Product Grid
              Expanded(
                child: filteredProducts.isEmpty
                    ? _buildEmptyState(isDark)
                    : _buildProductGrid(filteredProducts, isDark),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.white.withOpacity(0.06), Colors.white.withOpacity(0.03)]
              : [Colors.white, const Color(0xFFF4F8FF)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _searchFocus.hasFocus
              ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
              : isDark
                  ? Colors.white.withOpacity(0.08)
                  : const Color(0xFFE2E8F0),
          width: _searchFocus.hasFocus ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : const Color(0xFF94A3B8).withOpacity(0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
            spreadRadius: -8,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          hintText: 'Search by name, SKU, or barcode...',
          hintStyle: TextStyle(
            color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
                spreadRadius: -6,
              ),
            ],
          ),
          child: Row(
            children: const [
              Icon(
                Icons.tune_rounded,
                size: 18,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String category,
    required bool isSelected,
    required Color color,
    required bool isDark,
    required VoidCallback onSelected,
  }) {
    return Material(
      color: isSelected
          ? color.withOpacity(isDark ? 0.28 : 0.16)
          : isDark
              ? Colors.white.withOpacity(0.04)
              : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onSelected();
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? color.withOpacity(0.65)
                  : isDark
                      ? Colors.white.withOpacity(0.08)
                      : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                      spreadRadius: -6,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                category,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? color
                      : isDark
                          ? Colors.white70
                          : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.04)
                  : const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 0.72,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductCard(
          product: product,
          categoryColor: _categoryColors.putIfAbsent(
            product.category,
            () => _palette[index % _palette.length],
          ),
          isDark: isDark,
          onAdd: () {
            HapticFeedback.mediumImpact();
            Provider.of<POSProvider>(context, listen: false).addToCart(product);
            _showAddedFeedback(product.name, isDark);
          },
        );
      },
    );
  }

  void _showAddedFeedback(String productName, bool isDark) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Added to cart',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    productName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        width: 300,
        duration: const Duration(milliseconds: 1800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 8,
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Product product;
  final Color categoryColor;
  final bool isDark;
  final VoidCallback onAdd;

  const _ProductCard({
    required this.product,
    required this.onAdd,
    required this.categoryColor,
    required this.isDark,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isOutOfStock = product.isOutOfStock;
    final isLowStock = product.isLowStock;
    final isDark = widget.isDark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => _animController.forward(),
        onTapUp: (_) => _animController.reverse(),
        onTapCancel: () => _animController.reverse(),
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_hovered ? 0.008 : 0.0)
              ..rotateX(_hovered ? -0.008 : 0.0),
            alignment: FractionalOffset.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? (_hovered
                          ? [
                              Colors.white.withOpacity(0.08),
                              Colors.white.withOpacity(0.04),
                            ]
                          : [
                              Colors.white.withOpacity(0.05),
                              Colors.white.withOpacity(0.02),
                            ])
                      : (_hovered
                          ? [
                              Colors.white,
                              const Color(0xFFFAFBFC),
                            ]
                          : [
                              const Color(0xFFFDFDFD),
                              const Color(0xFFF5F7FA),
                            ]),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _hovered
                      ? widget.categoryColor.withOpacity(0.5)
                      : isDark
                          ? Colors.white.withOpacity(0.1)
                          : const Color(0xFFE2E8F0),
                  width: _hovered ? 2 : 1.5,
                ),
                boxShadow: _hovered
                    ? [
                        // Glow effect when hovered
                        BoxShadow(
                          color: widget.categoryColor.withOpacity(0.35),
                          blurRadius: 32,
                          offset: const Offset(0, 14),
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: widget.categoryColor.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        // Top highlight
                        BoxShadow(
                          color: Colors.white.withOpacity(isDark ? 0.04 : 0.9),
                          offset: const Offset(0, -1),
                          blurRadius: 4,
                        ),
                      ]
                    : [
                        // Elevated appearance at rest
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.5)
                              : const Color(0xFF64748B).withOpacity(0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                          spreadRadius: -4,
                        ),
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.4)
                              : const Color(0xFF64748B).withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                          spreadRadius: -2,
                        ),
                        // Top highlight for 3D effect
                        BoxShadow(
                          color: Colors.white.withOpacity(isDark ? 0.03 : 0.8),
                          offset: const Offset(0, -1),
                          blurRadius: 2,
                        ),
                        // Bottom edge
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.6)
                              : const Color(0xFF94A3B8).withOpacity(0.15),
                          offset: const Offset(0, 1),
                          blurRadius: 0,
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isOutOfStock ? null : widget.onAdd,
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Product Image Area
                      Expanded(
                        flex: 5,
                        child: Stack(
                          children: [
                            // Background gradient
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      widget.categoryColor.withOpacity(
                                          isDark ? 0.15 : 0.08),
                                      isDark
                                          ? Colors.transparent
                                          : const Color(0xFFFAFAFA),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                              ),
                            ),

                            // Product Image
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: product.imageUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          product.imageUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) =>
                                              _buildPlaceholder(isDark),
                                        ),
                                      )
                                    : _buildPlaceholder(isDark),
                              ),
                            ),

                            // Stock Badge
                            Positioned(
                              top: 10,
                              right: 10,
                              child: _buildStockBadge(
                                product: product,
                                isOutOfStock: isOutOfStock,
                                isLowStock: isLowStock,
                                isDark: isDark,
                              ),
                            ),

                            // Out of Stock Overlay
                            if (isOutOfStock)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.black.withOpacity(0.6)
                                        : Colors.white.withOpacity(0.75),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'OUT OF STOCK',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            // Quick Add Overlay
                            if (_hovered && !isOutOfStock)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        widget.categoryColor.withOpacity(0.9),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add_shopping_cart_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Quick Add',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Product Info
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category & SKU
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.categoryColor
                                          .withOpacity(isDark ? 0.2 : 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      product.category.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: widget.categoryColor,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      product.sku,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark
                                            ? Colors.white38
                                            : const Color(0xFF94A3B8),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Product Name
                              Expanded(
                                child: Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1E293B),
                                    height: 1.3,
                                  ),
                                ),
                              ),

                              // Price & Add Button
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Price',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isDark
                                                ? Colors.white38
                                                : const Color(0xFF94A3B8),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '₱${product.sellingPrice.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures()
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildAddButton(isOutOfStock, isDark),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockBadge({
    required Product product,
    required bool isOutOfStock,
    required bool isLowStock,
    required bool isDark,
  }) {
    Color bgColor;
    Color textColor;
    String text;
    IconData icon;

    if (isOutOfStock) {
      bgColor = const Color(0xFFEF4444);
      textColor = Colors.white;
      text = '0';
      icon = Icons.block_rounded;
    } else if (isLowStock) {
      bgColor = const Color(0xFFF59E0B);
      textColor = Colors.white;
      text = '${product.currentStock}';
      icon = Icons.warning_amber_rounded;
    } else {
      bgColor = widget.categoryColor;
      textColor = Colors.white;
      text = '${product.currentStock}';
      icon = Icons.inventory_2_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(bool isOutOfStock, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isOutOfStock
          ? (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9))
          : colorScheme.primary,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: isOutOfStock ? null : widget.onAdd,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_rounded,
                size: 16,
                color: isOutOfStock
                    ? (isDark ? Colors.white24 : const Color(0xFFCBD5E1))
                    : Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                'Add',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isOutOfStock
                      ? (isDark ? Colors.white24 : const Color(0xFFCBD5E1))
                      : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          Icons.inventory_2_rounded,
          size: 36,
          color: isDark ? Colors.white12 : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }
}
