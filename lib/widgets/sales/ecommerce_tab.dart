import 'package:flutter/material.dart';
import 'package:inventory_saas/utils/theme.dart';
import 'package:inventory_saas/widgets/dashboard/stat_card.dart';

class EcommerceTab extends StatefulWidget {
  const EcommerceTab({super.key});

  @override
  State<EcommerceTab> createState() => _EcommerceTabState();
}

class _EcommerceTabState extends State<EcommerceTab> {
  String _searchQuery = '';
  String? _platformFilter;
  final TextEditingController _searchController = TextEditingController();

  // Dummy e-commerce data
  final List<Map<String, dynamic>> _platforms = [
    {
      'id': 'shopify_001',
      'name': 'Shopify Store',
      'platform': 'Shopify',
      'url': 'https://mystore.myshopify.com',
      'status': 'active',
      'totalSales': 15420.50,
      'totalOrders': 89,
      'lastSync': '2024-01-25 14:30',
      'products': 156,
      'customers': 234,
    },
    {
      'id': 'woo_001',
      'name': 'WordPress WooCommerce',
      'platform': 'WooCommerce',
      'url': 'https://mystore.com',
      'status': 'active',
      'totalSales': 8920.75,
      'totalOrders': 45,
      'lastSync': '2024-01-25 12:15',
      'products': 89,
      'customers': 156,
    },
    {
      'id': 'amazon_001',
      'name': 'Amazon Seller Central',
      'platform': 'Amazon',
      'url': 'https://sellercentral.amazon.com',
      'status': 'active',
      'totalSales': 23450.25,
      'totalOrders': 167,
      'lastSync': '2024-01-25 16:45',
      'products': 78,
      'customers': 445,
    },
    {
      'id': 'ebay_001',
      'name': 'eBay Store',
      'platform': 'eBay',
      'url': 'https://stores.ebay.com/mystore',
      'status': 'active',
      'totalSales': 5670.80,
      'totalOrders': 34,
      'lastSync': '2024-01-25 10:20',
      'products': 45,
      'customers': 89,
    },
    {
      'id': 'etsy_001',
      'name': 'Etsy Shop',
      'platform': 'Etsy',
      'url': 'https://www.etsy.com/shop/mystore',
      'status': 'inactive',
      'totalSales': 0.0,
      'totalOrders': 0,
      'lastSync': 'Never',
      'products': 0,
      'customers': 0,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlatforms = _getFilteredPlatforms();
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header and Stats
          _buildHeader(),
          const SizedBox(height: 24),
          
          // Search and Actions
          _buildSearchAndActions(),
          const SizedBox(height: 24),
          
          // E-commerce Platforms Grid
          Expanded(
            child: _buildPlatformsGrid(filteredPlatforms),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final activePlatforms = _platforms.where((p) => p['status'] == 'active').length;
    final totalSales = _platforms.fold<double>(0, (sum, p) => sum + (p['totalSales'] as double));
    final totalOrders = _platforms.fold<int>(0, (sum, p) => sum + (p['totalOrders'] as int));
    final totalProducts = _platforms.fold<int>(0, (sum, p) => sum + (p['products'] as int));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'E-commerce Integration',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Manage online stores',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            final cards = [
              StatCard(
                title: 'Active Stores',
                value: activePlatforms.toString(),
                icon: Icons.store,
                color: AppTheme.primaryColor,
              ),
              StatCard(
                title: 'Sales',
                value: '\$${totalSales.toStringAsFixed(0)}',
                icon: Icons.trending_up,
                color: AppTheme.successColor,
              ),
              StatCard(
                title: 'Orders',
                value: totalOrders.toString(),
                icon: Icons.shopping_cart,
                color: AppTheme.infoColor,
              ),
              StatCard(
                title: 'Products',
                value: totalProducts.toString(),
                icon: Icons.inventory_2,
                color: AppTheme.warningColor,
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
        ),
      ],
    );
  }

  Widget _buildSearchAndActions() {
    return Row(
      children: [
        // Search
        Expanded(
          flex: 2,
          child: TextField(
            controller: _searchController,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search platforms...',
              prefixIcon: const Icon(Icons.search, size: 18),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.clear, size: 16),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Platform Filter
        Expanded(
          child: DropdownButtonFormField<String?>(
            value: _platformFilter,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Platform',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All'),
              ),
              const DropdownMenuItem(
                value: 'Shopify',
                child: Text('Shopify'),
              ),
              const DropdownMenuItem(
                value: 'WooCommerce',
                child: Text('WooCommerce'),
              ),
              const DropdownMenuItem(
                value: 'Amazon',
                child: Text('Amazon'),
              ),
              const DropdownMenuItem(
                value: 'eBay',
                child: Text('eBay'),
              ),
              const DropdownMenuItem(
                value: 'Etsy',
                child: Text('Etsy'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _platformFilter = value;
              });
            },
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Add Platform Button
        ElevatedButton.icon(
          onPressed: () => _showAddPlatformDialog(),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Store', style: TextStyle(fontSize: 13)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
             minimumSize: const Size(0, 48),
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformsGrid(List<Map<String, dynamic>> platforms) {
    if (platforms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No platforms found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or add a new platform',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: platforms.length,
      itemBuilder: (context, index) {
        return _buildPlatformCard(platforms[index]);
      },
    );
  }

  Widget _buildPlatformCard(Map<String, dynamic> platform) {
    final isActive = platform['status'] == 'active';
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                _buildPlatformIcon(platform['platform']),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        platform['name'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        platform['platform'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusIndicator(isActive),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // URL
            Row(
              children: [
                Icon(
                  Icons.link,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    platform['url'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Stats Grid
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Sales',
                      '\$${platform['totalSales'].toStringAsFixed(0)}',
                      Icons.trending_up,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Orders',
                      platform['totalOrders'].toString(),
                      Icons.shopping_cart,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Products',
                    platform['products'].toString(),
                    Icons.inventory_2,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Customers',
                    platform['customers'].toString(),
                    Icons.people,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Last Sync
            Row(
              children: [
                Icon(
                  Icons.sync,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Last sync: ${platform['lastSync']}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _syncPlatform(platform),
                    icon: const Icon(Icons.sync, size: 16),
                    label: const Text('Sync'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewPlatformDetails(platform),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showPlatformActions(platform),
                  icon: const Icon(Icons.more_vert, size: 18),
                  tooltip: 'More Actions',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformIcon(String platform) {
    IconData icon;
    Color color;
    
    switch (platform) {
      case 'Shopify':
        icon = Icons.shopping_bag;
        color = Colors.green;
        break;
      case 'WooCommerce':
        icon = Icons.wordpress;
        color = Colors.blue;
        break;
      case 'Amazon':
        icon = Icons.shopping_cart;
        color = Colors.orange;
        break;
      case 'eBay':
        icon = Icons.store;
        color = Colors.red;
        break;
             case 'Etsy':
         icon = Icons.brush;
         color = Colors.purple;
         break;
      default:
        icon = Icons.store;
        color = AppTheme.textSecondary;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildStatusIndicator(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.successColor : AppTheme.textSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredPlatforms() {
    List<Map<String, dynamic>> platforms = _platforms;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      platforms = platforms.where((platform) {
        final query = _searchQuery.toLowerCase();
        return platform['name'].toLowerCase().contains(query) ||
               platform['platform'].toLowerCase().contains(query) ||
               platform['url'].toLowerCase().contains(query);
      }).toList();
    }
    
    // Apply platform filter
    if (_platformFilter != null) {
      platforms = platforms.where((platform) => platform['platform'] == _platformFilter).toList();
    }
    
    return platforms;
  }

  void _syncPlatform(Map<String, dynamic> platform) {
    // TODO: Implement platform synchronization
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Synchronizing ${platform['name']}...')),
    );
  }

  void _viewPlatformDetails(Map<String, dynamic> platform) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Platform: ${platform['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Platform', platform['platform']),
            _buildDetailRow('Store Name', platform['name']),
            _buildDetailRow('URL', platform['url']),
            _buildDetailRow('Status', platform['status']),
            _buildDetailRow('Total Sales', '\$${platform['totalSales'].toStringAsFixed(2)}'),
            _buildDetailRow('Total Orders', platform['totalOrders'].toString()),
            _buildDetailRow('Products', platform['products'].toString()),
            _buildDetailRow('Customers', platform['customers'].toString()),
            _buildDetailRow('Last Sync', platform['lastSync']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _syncPlatform(platform);
            },
            child: const Text('Sync Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showPlatformActions(Map<String, dynamic> platform) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Platform Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Details'),
              onTap: () {
                Navigator.of(context).pop();
                _viewPlatformDetails(platform);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sync Now'),
              onTap: () {
                Navigator.of(context).pop();
                _syncPlatform(platform);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configure'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement configuration
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Configuring ${platform['name']}')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('View Analytics'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement analytics view
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Viewing analytics for ${platform['name']}')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Platform'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement edit functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Editing ${platform['name']}')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove Platform', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _showRemoveConfirmation(platform);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPlatformDialog() {
    // TODO: Implement add platform functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add platform feature coming soon')),
    );
  }

  void _showRemoveConfirmation(Map<String, dynamic> platform) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Platform'),
        content: Text('Are you sure you want to remove ${platform['name']}? This will disconnect the integration.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement remove functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Platform ${platform['name']} removed')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
