import 'package:flutter/material.dart';
import 'package:inventory_saas/utils/theme.dart';

class CategoriesTab extends StatefulWidget {
  const CategoriesTab({super.key});

  @override
  State<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab> {
  final List<CategoryData> _categories = [
    CategoryData(
      id: 'cat_001',
      name: 'Electronics',
      description: 'Electronic devices and gadgets',
      productCount: 45,
      totalValue: 125000.00,
      color: Colors.blue,
      icon: Icons.devices,
      isActive: true,
    ),
    CategoryData(
      id: 'cat_002',
      name: 'Computers',
      description: 'Desktop and laptop computers',
      productCount: 28,
      totalValue: 89000.00,
      color: Colors.green,
      icon: Icons.computer,
      isActive: true,
    ),
    CategoryData(
      id: 'cat_003',
      name: 'Audio',
      description: 'Audio equipment and accessories',
      productCount: 32,
      totalValue: 45000.00,
      color: Colors.orange,
      icon: Icons.headphones,
      isActive: true,
    ),
    CategoryData(
      id: 'cat_004',
      name: 'Accessories',
      description: 'Computer and device accessories',
      productCount: 67,
      totalValue: 23000.00,
      color: Colors.purple,
      icon: Icons.cable,
      isActive: true,
    ),
    CategoryData(
      id: 'cat_005',
      name: 'Software',
      description: 'Software licenses and applications',
      productCount: 23,
      totalValue: 15000.00,
      color: Colors.red,
      icon: Icons.apps,
      isActive: true,
    ),
    CategoryData(
      id: 'cat_006',
      name: 'Networking',
      description: 'Network equipment and devices',
      productCount: 18,
      totalValue: 35000.00,
      color: Colors.teal,
      icon: Icons.router,
      isActive: true,
    ),
    CategoryData(
      id: 'cat_007',
      name: 'Gaming',
      description: 'Gaming consoles and accessories',
      productCount: 15,
      totalValue: 28000.00,
      color: Colors.indigo,
      icon: Icons.games,
      isActive: true,
    ),
    CategoryData(
      id: 'cat_008',
      name: 'Office Supplies',
      description: 'Office equipment and supplies',
      productCount: 89,
      totalValue: 12000.00,
      color: Colors.brown,
      icon: Icons.work,
      isActive: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with Add Category Button
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Categories',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your product categories and organization',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Add new category
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Category'),
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

        // Categories Grid
        Expanded(
          child: _buildCategoriesGrid(),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards() {
    final activeCategories = _categories.where((cat) => cat.isActive).length;
    final totalProducts = _categories.fold(0, (sum, cat) => sum + cat.productCount);
    final totalValue = _categories.fold(0.0, (sum, cat) => sum + cat.totalValue);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Categories',
              _categories.length.toString(),
              Icons.folder,
              AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Active Categories',
              activeCategories.toString(),
              Icons.check_circle,
              AppTheme.successColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Total Products',
              totalProducts.toString(),
              Icons.inventory_2,
              AppTheme.infoColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Total Value',
              '\$${totalValue.toStringAsFixed(0)}',
              Icons.attach_money,
              AppTheme.warningColor,
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

  Widget _buildCategoriesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(CategoryData category) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to category details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: category.isActive 
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: category.isActive 
                            ? AppTheme.successColor 
                            : AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Category name
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Description
              Text(
                category.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const Spacer(),
              
              // Statistics
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Products',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          category.productCount.toString(),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Value',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          '\$${category.totalValue.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Edit category
                      },
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: View products in category
                      },
                      child: const Text('View'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryData {
  final String id;
  final String name;
  final String description;
  final int productCount;
  final double totalValue;
  final Color color;
  final IconData icon;
  final bool isActive;

  CategoryData({
    required this.id,
    required this.name,
    required this.description,
    required this.productCount,
    required this.totalValue,
    required this.color,
    required this.icon,
    required this.isActive,
  });
}
