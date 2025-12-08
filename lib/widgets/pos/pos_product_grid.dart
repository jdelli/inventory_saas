import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:inventory_saas/models/product.dart';
import 'package:inventory_saas/providers/inventory_provider.dart';
import 'package:inventory_saas/providers/pos_provider.dart';
import 'dart:math' as math;

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
        final categories = ['All', ...inventoryProvider.products
            .map((p) => p.category)
            .toSet()];

        var filteredProducts = inventoryProvider.products.where((product) {
          final matchesSearch = _searchQuery.isEmpty ||
              product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.sku.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.barcode.contains(_searchQuery);

          final matchesCategory = _selectedCategory == 'All' ||
              product.category == _selectedCategory;

          return matchesSearch && matchesCategory && product.isActive;
        }).toList();

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFE8EDF5),
                const Color(0xFFDFE6F0),
                const Color(0xFFE2E9F3),
              ],
            ),
          ),
          child: Column(
            children: [
              // 3D Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Expanded(child: _build3DSearchBar()),
                    const SizedBox(width: 12),
                    _build3DScannerButton(),
                  ],
                ),
              ),

              // 3D Category Pills
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _build3DCategoryChip(category, isSelected),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Product Grid
              Expanded(
                child: filteredProducts.isEmpty
                    ? _buildEmptyState()
                    : _buildProductGrid(filteredProducts),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _build3DSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // Outer dark shadow (bottom-right)
          BoxShadow(
            color: const Color(0xFFBEC8D9),
            offset: const Offset(6, 6),
            blurRadius: 15,
            spreadRadius: 1,
          ),
          // Inner light shadow (top-left) - creates 3D inset effect
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-6, -6),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF0F4FA),
              const Color(0xFFE4EAF4),
            ],
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Search products, SKU, or barcode...',
            hintStyle: TextStyle(
              color: const Color(0xFF8494A9),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: const Icon(Icons.search_rounded, size: 22, color: Color(0xFF5B6B7F)),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF5B6B7F)),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _build3DScannerButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A8AF4), Color(0xFF2563EB)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.5),
              offset: const Offset(4, 4),
              blurRadius: 12,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: const Color(0xFF60A5FA).withOpacity(0.3),
              offset: const Offset(-2, -2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: const Icon(Icons.qr_code_scanner_rounded, size: 24, color: Colors.white),
      ),
    );
  }

  Widget _build3DCategoryChip(String category, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? null : const Color(0xFFE8EDF5),
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4A8AF4), Color(0xFF2563EB)],
                )
              : null,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.4),
                    offset: const Offset(3, 3),
                    blurRadius: 10,
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFFBEC8D9),
                    offset: const Offset(3, 3),
                    blurRadius: 8,
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    offset: Offset(-3, -3),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_circle, size: 16, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              category,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF4A5568),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDF5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFBEC8D9),
                  offset: const Offset(8, 8),
                  blurRadius: 20,
                ),
                const BoxShadow(
                  color: Colors.white,
                  offset: Offset(-8, -8),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Icon(Icons.inventory_2_outlined, size: 52, color: Color(0xFF8494A9)),
          ),
          const SizedBox(height: 20),
          const Text(
            'No products found',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF4A5568)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 0.72,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _Neumorphic3DCard(product: products[index]),
    );
  }
}

// ==================== Neumorphic 3D Product Card ====================
class _Neumorphic3DCard extends StatefulWidget {
  final Product product;
  const _Neumorphic3DCard({required this.product});

  @override
  State<_Neumorphic3DCard> createState() => _Neumorphic3DCardState();
}

class _Neumorphic3DCardState extends State<_Neumorphic3DCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _elevationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isOutOfStock = product.isOutOfStock;
    final isLowStock = product.isLowStock;
    final posProvider = Provider.of<POSProvider>(context, listen: false);

    return MouseRegion(
      onEnter: (_) {
        if (!isOutOfStock) {
          setState(() => _isHovered = true);
          _controller.forward();
        }
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      cursor: isOutOfStock ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) {
          if (!isOutOfStock) setState(() => _isPressed = true);
        },
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: isOutOfStock
            ? null
            : () {
                HapticFeedback.mediumImpact();
                posProvider.addToCart(product);
                _showAddedFeedback(product.name);
              },
        child: AnimatedBuilder(
          animation: _elevationAnimation,
          builder: (context, child) {
            final elevation = _elevationAnimation.value;

            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002) // Perspective
                ..rotateX(_isPressed ? 0.02 : -0.01 * elevation)
                ..rotateY(_isPressed ? -0.02 : 0.01 * elevation)
                ..translate(0.0, _isPressed ? 2.0 : -8.0 * elevation, 0.0),
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EDF5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _isPressed
                      ? [
                          // Pressed/Inset effect
                          BoxShadow(
                            color: const Color(0xFFBEC8D9),
                            offset: const Offset(2, 2),
                            blurRadius: 5,
                            spreadRadius: -2,
                          ),
                          const BoxShadow(
                            color: Colors.white,
                            offset: Offset(-2, -2),
                            blurRadius: 5,
                            spreadRadius: -2,
                          ),
                        ]
                      : [
                          // 3D elevated effect
                          BoxShadow(
                            color: const Color(0xFFB0BDD0).withOpacity(_isHovered ? 1.0 : 0.8),
                            offset: Offset(8 + 4 * elevation, 8 + 4 * elevation),
                            blurRadius: 20 + 10 * elevation,
                            spreadRadius: -2,
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(_isHovered ? 1.0 : 0.9),
                            offset: Offset(-6 - 2 * elevation, -6 - 2 * elevation),
                            blurRadius: 16 + 8 * elevation,
                            spreadRadius: 0,
                          ),
                          // Accent glow on hover
                          if (_isHovered)
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.2),
                              offset: const Offset(0, 8),
                              blurRadius: 20,
                              spreadRadius: -4,
                            ),
                        ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Card Content
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFF5F8FC),
                              const Color(0xFFEBF0F7),
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Product Image Area with 3D inset
                            Expanded(
                              flex: 5,
                              child: Container(
                                margin: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE4EAF4),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    // Inset shadow (top-left light)
                                    const BoxShadow(
                                      color: Color(0xFFF8FAFC),
                                      offset: Offset(-3, -3),
                                      blurRadius: 6,
                                    ),
                                    // Inset shadow (bottom-right dark)
                                    BoxShadow(
                                      color: const Color(0xFFCCD5E3),
                                      offset: const Offset(3, 3),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: product.imageUrl.isNotEmpty
                                      ? Image.network(
                                          product.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                                        )
                                      : _buildPlaceholder(),
                                ),
                              ),
                            ),

                            // Product Info
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Category Badge - 3D pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE4EAF4),
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFCCD5E3),
                                            offset: const Offset(1, 1),
                                            blurRadius: 2,
                                          ),
                                          const BoxShadow(
                                            color: Colors.white,
                                            offset: Offset(-1, -1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        product.category.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF5B6B7F),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    // Product Name
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E293B),
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),

                                    // Price & Add Button Row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Price',
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: Color(0xFF8494A9),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              '₱${product.sellingPrice.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF2563EB),
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // 3D Add Button
                                        _build3DAddButton(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Stock Badge - 3D Floating
                      if (!isOutOfStock)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isLowStock ? const Color(0xFFF59E0B) : const Color(0xFFF0F4FA),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: isLowStock
                                      ? const Color(0xFFF59E0B).withOpacity(0.4)
                                      : const Color(0xFFB0BDD0),
                                  offset: const Offset(3, 3),
                                  blurRadius: 8,
                                ),
                                if (!isLowStock)
                                  const BoxShadow(
                                    color: Colors.white,
                                    offset: Offset(-2, -2),
                                    blurRadius: 6,
                                  ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inventory_2_rounded,
                                  size: 11,
                                  color: isLowStock ? Colors.white : const Color(0xFF5B6B7F),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${product.currentStock}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isLowStock ? Colors.white : const Color(0xFF4A5568),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Out of Stock Overlay
                      if (isOutOfStock)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8EDF5).withOpacity(0.85),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Transform.rotate(
                                angle: -0.15,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFEF4444).withOpacity(0.5),
                                        offset: const Offset(4, 4),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'OUT OF STOCK',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _build3DAddButton() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isHovered
              ? [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)]
              : [const Color(0xFF60A5FA), const Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(_isHovered ? 0.5 : 0.35),
            offset: const Offset(3, 3),
            blurRadius: _isHovered ? 12 : 8,
          ),
          BoxShadow(
            color: const Color(0xFF60A5FA).withOpacity(0.2),
            offset: const Offset(-1, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: const Icon(Icons.add_rounded, size: 20, color: Colors.white),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEF2F7), Color(0xFFE4EAF4)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_rounded,
            size: 36,
            color: const Color(0xFF8494A9).withOpacity(0.5),
          ),
          const SizedBox(height: 6),
          Container(
            width: 45,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFCCD5E3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddedFeedback(String productName) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$productName added',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        width: 280,
        duration: const Duration(milliseconds: 1500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 12,
      ),
    );
  }
}
