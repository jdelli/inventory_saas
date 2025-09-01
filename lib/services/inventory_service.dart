import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../config/supabase_config.dart';

class InventoryService {
  SupabaseClient? get _supabase {
    try {
      return SupabaseConfig.client;
    } catch (e) {
      print('⚠️ InventoryService: Supabase not initialized - running in offline mode');
      return null;
    }
  }

  // Test database connection
  Future<void> testConnection() async {
    final supabase = _supabase;
    if (supabase == null) {
      print('⚠️ InventoryService: Supabase not available - skipping connection test');
      throw Exception('Supabase not initialized - running in offline mode');
    }
    
    try {
      print('🧪 InventoryService: Testing database connection...');
      final response = await supabase.rpc('products_list', params: {'p_limit': 1});
      print('✅ InventoryService: Database connection successful!');
      print('🧪 InventoryService: Test response: $response');
    } catch (e) {
      print('❌ InventoryService: Database connection failed: $e');
      print('🔍 InventoryService: Error details: ${e.toString()}');
      rethrow;
    }
  }

  // Get all products
  Future<List<Product>> getAllProducts() async {
    final supabase = _supabase;
    if (supabase == null) {
      print('⚠️ InventoryService: Supabase not available - cannot fetch products');
      throw Exception('Supabase not initialized - running in offline mode');
    }
    
    try {
      print('🔍 InventoryService: Fetching all products...');
      final response = await supabase.rpc('products_list');
      print('✅ InventoryService: Successfully fetched ${(response as List).length} products');
      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print('❌ InventoryService: Failed to fetch products: $e');
      throw Exception('Failed to fetch products: $e');
    }
  }

  // Get product by ID
  Future<Product?> getProductById(String id) async {
    final supabase = _supabase;
    if (supabase == null) {
      print('⚠️ InventoryService: Supabase not available - cannot fetch product');
      throw Exception('Supabase not initialized - running in offline mode');
    }
    
    try {
      final response = await supabase.rpc('products_get', params: {'p_id': id});
      if (response != null) {
        return Product.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  // Create new product
  Future<Product> createProduct(Product product) async {
    final supabase = _supabase;
    if (supabase == null) {
      print('⚠️ InventoryService: Supabase not available - cannot create product');
      throw Exception('Supabase not initialized - running in offline mode');
    }
    
    try {
      print('🚀 InventoryService: Creating product "${product.name}"...');
      print('📋 InventoryService: Product data: ${product.toJson()}');
      
      final params = {
        'p_name': product.name,
        'p_sku': product.sku,
        'p_category': product.category,
        'p_brand': product.brand,
        'p_cost_price': product.costPrice,
        'p_selling_price': product.sellingPrice,
        'p_warehouse': product.warehouse,
        'p_supplier_id': product.supplierId,
        'p_description': product.description,
        'p_barcode': product.barcode,
        'p_current_stock': product.currentStock,
        'p_min_stock_level': product.minStockLevel,
        'p_max_stock_level': product.maxStockLevel,
        'p_unit': product.unit,
        'p_location': product.location,
        'p_image_url': product.imageUrl,
        'p_is_active': product.isActive,
      };
      
      print('📤 InventoryService: Calling products_create with params: $params');
      final response = await supabase.rpc('products_create', params: params);
      print('✅ InventoryService: Successfully created product: $response');
      return Product.fromJson(response);
    } catch (e) {
      print('❌ InventoryService: Failed to create product: $e');
      print('🔍 InventoryService: Error type: ${e.runtimeType}');
      if (e.toString().contains('PostgrestException')) {
        print('🔍 InventoryService: This is a PostgrestException - check database connection and RPC function');
      }
      throw Exception('Failed to create product: $e');
    }
  }

  // Update product
  Future<Product> updateProduct(Product product) async {
    final supabase = _supabase;
    if (supabase == null) {
      print('⚠️ InventoryService: Supabase not available - cannot update product');
      throw Exception('Supabase not initialized - running in offline mode');
    }
    
    try {
      final patch = {
        'name': product.name,
        'description': product.description,
        'sku': product.sku,
        'barcode': product.barcode,
        'category': product.category,
        'brand': product.brand,
        'cost_price': product.costPrice,
        'selling_price': product.sellingPrice,
        'current_stock': product.currentStock,
        'min_stock_level': product.minStockLevel,
        'max_stock_level': product.maxStockLevel,
        'unit': product.unit,
        'warehouse': product.warehouse,
        'location': product.location,
        'supplier_id': product.supplierId,
        'image_url': product.imageUrl,
        'is_active': product.isActive,
      };

      final response = await supabase.rpc('products_update', params: {
        'p_id': product.id,
        'p_patch': patch,
      });
      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete product
  Future<bool> deleteProduct(String productId) async {
    final supabase = _supabase;
    if (supabase == null) {
      print('⚠️ InventoryService: Supabase not available - cannot delete product');
      throw Exception('Supabase not initialized - running in offline mode');
    }
    
    try {
      final response = await supabase.rpc('products_delete', params: {'p_id': productId});
      return response as bool;
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Search products
  Future<List<Product>> searchProducts(String query) async {
    final supabase = _supabase;
    if (supabase == null) {
      print('⚠️ InventoryService: Supabase not available - cannot search products');
      throw Exception('Supabase not initialized - running in offline mode');
    }
    
    try {
      final response = await supabase.rpc('products_list', params: {
        'p_search': query,
        'p_limit': 100,
      });
      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    final supabase = _supabase;
    if (supabase == null) {
      print('⚠️ InventoryService: Supabase not available - cannot fetch products by category');
      throw Exception('Supabase not initialized - running in offline mode');
    }
    
    try {
      final response = await supabase.rpc('products_list', params: {
        'p_category': category,
        'p_limit': 100,
      });
      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  // Get products by supplier
  Future<List<Product>> getProductsBySupplier(String supplierId) async {
    final supabase = _supabase;
    if (supabase == null) {
      print('⚠️ InventoryService: Supabase not available - cannot fetch products by supplier');
      throw Exception('Supabase not initialized - running in offline mode');
    }
    
    try {
      final response = await supabase.rpc('products_list', params: {
        'p_supplier_id': supplierId,
        'p_limit': 100,
      });
      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch products by supplier: $e');
    }
  }

  // Update stock
  Future<Product> updateStock(String productId, int newQuantity) async {
    try {
      final product = await getProductById(productId);
      if (product == null) {
        throw Exception('Product not found');
      }

      final updatedProduct = product.copyWith(
        currentStock: newQuantity,
        updatedAt: DateTime.now(),
      );

      return await updateProduct(updatedProduct);
    } catch (e) {
      throw Exception('Failed to update stock: $e');
    }
  }

  // Get low stock products
  Future<List<Product>> getLowStockProducts() async {
    try {
      final allProducts = await getAllProducts();
      return allProducts.where((p) => p.isLowStock).toList();
    } catch (e) {
      throw Exception('Failed to fetch low stock products: $e');
    }
  }

  // Get out of stock products
  Future<List<Product>> getOutOfStockProducts() async {
    try {
      final allProducts = await getAllProducts();
      return allProducts.where((p) => p.isOutOfStock).toList();
    } catch (e) {
      throw Exception('Failed to fetch out of stock products: $e');
    }
  }
}
