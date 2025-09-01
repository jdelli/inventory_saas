import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:inventory_saas/models/product.dart';
import 'package:inventory_saas/services/inventory_service.dart';

class InventoryProvider with ChangeNotifier {
  final InventoryService _inventoryService = InventoryService();
  
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed properties
  List<Product> get lowStockProducts => _products.where((p) => p.isLowStock).toList();
  List<Product> get outOfStockProducts => _products.where((p) => p.isOutOfStock).toList();
  double get totalStockValue => _products.fold(0, (sum, p) => sum + p.stockValue);
  int get totalProducts => _products.length;

  void _loadDummyData() {
    _products = [
      Product(
        id: 'prod_001',
        name: 'iPhone 15 Pro',
        description: 'Latest iPhone with advanced features, A17 Pro chip, and titanium design',
        sku: 'IPH15PRO-256-BLK',
        barcode: '1234567890123',
        category: 'Electronics',
        brand: 'Apple',
        costPrice: 899.99,
        sellingPrice: 1199.99,
        currentStock: 15,
        minStockLevel: 10,
        maxStockLevel: 50,
        unit: 'pcs',
        warehouse: 'Main Warehouse',
        location: 'A1-B2-C3',
        supplierId: 'supp_001',
        imageUrl: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'prod_002',
        name: 'Samsung Galaxy S24',
        description: 'Premium Android smartphone with AI features',
        sku: 'SAMS24-128-BLK',
        barcode: '1234567890124',
        category: 'Electronics',
        brand: 'Samsung',
        costPrice: 699.99,
        sellingPrice: 899.99,
        currentStock: 8,
        minStockLevel: 10,
        maxStockLevel: 40,
        unit: 'pcs',
        warehouse: 'Main Warehouse',
        location: 'A1-B2-C4',
        supplierId: 'supp_002',
        imageUrl: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'prod_003',
        name: 'MacBook Pro 14"',
        description: 'Professional laptop for developers with M3 chip',
        sku: 'MBP14-512-SLV',
        barcode: '1234567890125',
        category: 'Computers',
        brand: 'Apple',
        costPrice: 1899.99,
        sellingPrice: 2499.99,
        currentStock: 5,
        minStockLevel: 5,
        maxStockLevel: 20,
        unit: 'pcs',
        warehouse: 'Main Warehouse',
        location: 'A2-B1-C1',
        supplierId: 'supp_001',
        imageUrl: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'prod_004',
        name: 'Dell XPS 13',
        description: 'Ultrabook for business users with 13th gen Intel',
        sku: 'DLLXPS13-256-BLK',
        barcode: '1234567890126',
        category: 'Computers',
        brand: 'Dell',
        costPrice: 999.99,
        sellingPrice: 1299.99,
        currentStock: 0,
        minStockLevel: 3,
        maxStockLevel: 15,
        unit: 'pcs',
        warehouse: 'Main Warehouse',
        location: 'A2-B1-C2',
        supplierId: 'supp_003',
        imageUrl: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'prod_005',
        name: 'AirPods Pro',
        description: 'Wireless earbuds with active noise cancellation',
        sku: 'AIRPODS-PRO-WHT',
        barcode: '1234567890127',
        category: 'Audio',
        brand: 'Apple',
        costPrice: 199.99,
        sellingPrice: 249.99,
        currentStock: 25,
        minStockLevel: 20,
        maxStockLevel: 100,
        unit: 'pcs',
        warehouse: 'Main Warehouse',
        location: 'A3-B1-C1',
        supplierId: 'supp_001',
        imageUrl: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'prod_006',
        name: 'Sony WH-1000XM5',
        description: 'Premium wireless headphones with industry-leading noise cancellation',
        sku: 'SONY-WH1000XM5-BLK',
        barcode: '1234567890128',
        category: 'Audio',
        brand: 'Sony',
        costPrice: 299.99,
        sellingPrice: 399.99,
        currentStock: 12,
        minStockLevel: 8,
        maxStockLevel: 30,
        unit: 'pcs',
        warehouse: 'Main Warehouse',
        location: 'A3-B1-C2',
        supplierId: 'supp_004',
        imageUrl: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'prod_007',
        name: 'Microsoft Surface Pro 9',
        description: '2-in-1 laptop and tablet with detachable keyboard',
        sku: 'MS-SURFACE-PRO9-256',
        barcode: '1234567890129',
        category: 'Computers',
        brand: 'Microsoft',
        costPrice: 1099.99,
        sellingPrice: 1399.99,
        currentStock: 7,
        minStockLevel: 5,
        maxStockLevel: 20,
        unit: 'pcs',
        warehouse: 'Main Warehouse',
        location: 'A2-B1-C3',
        supplierId: 'supp_005',
        imageUrl: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'prod_008',
        name: 'Logitech MX Master 3S',
        description: 'Wireless mouse with precision scrolling and ergonomic design',
        sku: 'LOG-MX-MASTER3S',
        barcode: '1234567890130',
        category: 'Accessories',
        brand: 'Logitech',
        costPrice: 79.99,
        sellingPrice: 99.99,
        currentStock: 45,
        minStockLevel: 30,
        maxStockLevel: 100,
        unit: 'pcs',
        warehouse: 'Main Warehouse',
        location: 'A4-B1-C1',
        supplierId: 'supp_006',
        imageUrl: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'prod_009',
        name: 'Samsung 49" Odyssey G9',
        description: 'Ultra-wide gaming monitor with 240Hz refresh rate',
        sku: 'SAMS-ODYSSEY-G9-49',
        barcode: '1234567890131',
        category: 'Electronics',
        brand: 'Samsung',
        costPrice: 899.99,
        sellingPrice: 1199.99,
        currentStock: 3,
        minStockLevel: 2,
        maxStockLevel: 10,
        unit: 'pcs',
        warehouse: 'Main Warehouse',
        location: 'A1-B3-C1',
        supplierId: 'supp_002',
        imageUrl: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'prod_010',
        name: 'Adobe Creative Suite',
        description: 'Complete creative software suite including Photoshop, Illustrator, and more',
        sku: 'ADOBE-CS-2024-LIC',
        barcode: '1234567890132',
        category: 'Software',
        brand: 'Adobe',
        costPrice: 399.99,
        sellingPrice: 599.99,
        currentStock: 100,
        minStockLevel: 50,
        maxStockLevel: 200,
        unit: 'licenses',
        warehouse: 'Main Warehouse',
        location: 'A5-B1-C1',
        supplierId: 'supp_007',
        imageUrl: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'prod_011',
        name: 'Cisco Catalyst 9300',
        description: 'Enterprise-grade network switch with PoE+ support',
        sku: 'CISCO-CAT9300-48P',
        barcode: '1234567890133',
        category: 'Networking',
        brand: 'Cisco',
        costPrice: 2499.99,
        sellingPrice: 3499.99,
        currentStock: 2,
        minStockLevel: 1,
        maxStockLevel: 5,
        unit: 'pcs',
        warehouse: 'Main Warehouse',
        location: 'A6-B1-C1',
        supplierId: 'supp_008',
        imageUrl: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 22)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'prod_012',
        name: 'PlayStation 5',
        description: 'Next-generation gaming console with DualSense controller',
        sku: 'SONY-PS5-DISC',
        barcode: '1234567890134',
        category: 'Gaming',
        brand: 'Sony',
        costPrice: 399.99,
        sellingPrice: 499.99,
        currentStock: 0,
        minStockLevel: 5,
        maxStockLevel: 25,
        unit: 'pcs',
        warehouse: 'Main Warehouse',
        location: 'A7-B1-C1',
        supplierId: 'supp_004',
        imageUrl: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'prod_013',
        name: 'Apple Watch Series 9',
        description: 'Smartwatch with health monitoring and fitness tracking',
        sku: 'APPLE-WATCH-S9-45MM',
        barcode: '1234567890135',
        category: 'Electronics',
        brand: 'Apple',
        costPrice: 299.99,
        sellingPrice: 399.99,
        currentStock: 18,
        minStockLevel: 15,
        maxStockLevel: 50,
        unit: 'pcs',
        warehouse: 'Main Warehouse',
        location: 'A1-B2-C5',
        supplierId: 'supp_001',
        imageUrl: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'prod_014',
        name: 'HP LaserJet Pro M404n',
        description: 'Monochrome laser printer for small office use',
        sku: 'HP-LASERJET-M404N',
        barcode: '1234567890136',
        category: 'Office Supplies',
        brand: 'HP',
        costPrice: 199.99,
        sellingPrice: 299.99,
        currentStock: 8,
        minStockLevel: 5,
        maxStockLevel: 20,
        unit: 'pcs',
        warehouse: 'Main Warehouse',
        location: 'A8-B1-C1',
        supplierId: 'supp_009',
        imageUrl: '',
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'prod_015',
        name: 'DJI Mini 3 Pro',
        description: 'Compact drone with 4K camera and obstacle avoidance',
        sku: 'DJI-MINI3-PRO',
        barcode: '1234567890137',
        category: 'Electronics',
        brand: 'DJI',
        costPrice: 599.99,
        sellingPrice: 799.99,
        currentStock: 4,
        minStockLevel: 3,
        maxStockLevel: 15,
        unit: 'pcs',
        warehouse: 'Main Warehouse',
        location: 'A1-B3-C2',
        supplierId: 'supp_010',
        imageUrl: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        updatedAt: DateTime.now(),
      ),
    ];
    notifyListeners();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    // Don't call notifyListeners() here to avoid setState during build

    try {
      print('🔄 InventoryProvider: Testing database connection first...');
      await _inventoryService.testConnection();
      
      print('🔄 InventoryProvider: Loading products from database...');
      _products = await _inventoryService.getAllProducts();
      print('✅ InventoryProvider: Successfully loaded ${_products.length} products from database');
    } catch (e) {
      print('❌ InventoryProvider: Database load failed: $e');
      _error = e.toString();
      // Fallback to dummy data if database fails
      print('🔄 InventoryProvider: Falling back to dummy data...');
      _loadDummyData();
    } finally {
      _isLoading = false;
      // Call notifyListeners after the async operation is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('🔄 InventoryProvider: Adding product "${product.name}" to database...');
      final createdProduct = await _inventoryService.createProduct(product);
      _products.add(createdProduct);
      print('✅ InventoryProvider: Successfully added product to database and local list');
    } catch (e) {
      print('❌ InventoryProvider: Database add failed: $e');
      _error = e.toString();
      // Fallback: add to local list if database fails
      print('🔄 InventoryProvider: Falling back to local storage only...');
      _products.add(product);
      print('⚠️ InventoryProvider: Product added locally but NOT to database!');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedProduct = await _inventoryService.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
    } catch (e) {
      _error = e.toString();
      // Fallback: update local list if database fails
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _inventoryService.deleteProduct(productId);
      if (success) {
        _products.removeWhere((p) => p.id == productId);
      }
    } catch (e) {
      _error = e.toString();
      // Fallback: remove from local list if database fails
      _products.removeWhere((p) => p.id == productId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStock(String productId, int newQuantity) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedProduct = await _inventoryService.updateStock(productId, newQuantity);
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
    } catch (e) {
      _error = e.toString();
      // Fallback: update local list if database fails
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = _products[index].copyWith(
          currentStock: newQuantity,
          updatedAt: DateTime.now(),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) return _products;
    
    try {
      return await _inventoryService.searchProducts(query);
    } catch (e) {
      _error = e.toString();
      // Fallback: local search if database fails
      return _products.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase()) ||
               product.sku.toLowerCase().contains(query.toLowerCase()) ||
               product.barcode.contains(query) ||
               product.category.toLowerCase().contains(query.toLowerCase()) ||
               product.brand.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      return await _inventoryService.getProductsByCategory(category);
    } catch (e) {
      _error = e.toString();
      // Fallback: local filter if database fails
      return _products.where((p) => p.category == category).toList();
    }
  }

  Future<List<Product>> getProductsBySupplier(String supplierId) async {
    try {
      return await _inventoryService.getProductsBySupplier(supplierId);
    } catch (e) {
      _error = e.toString();
      // Fallback: local filter if database fails
      return _products.where((p) => p.supplierId == supplierId).toList();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

}
