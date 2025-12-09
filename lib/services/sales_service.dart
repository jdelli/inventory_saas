import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/sales_order.dart';
import '../models/customer.dart';

class SalesService {
  SupabaseClient? get _supabase {
    try {
      return SupabaseConfig.client;
    } catch (e) {
      print('⚠️ SalesService: Supabase not initialized - running in offline mode');
      return null;
    }
  }

  // Create new order (Transactional)
  Future<String> createOrder(SalesOrder order) async {
    final supabase = _supabase;
    if (supabase == null) throw Exception('Supabase not initialized');

    try {
      print('🚀 SalesService: Creating order...');
      
      final itemsJson = order.items.map((item) => {
        'product_id': item.productId,
        'quantity': item.quantity,
        'unit_price': item.unitPrice,
        'discount': item.discount,
      }).toList();

      final params = {
        'p_customer_id': order.customerId.isNotEmpty ? order.customerId : null,
        'p_payment_method': order.paymentMethod,
        'p_subtotal': order.subtotal,
        'p_tax_amount': order.taxAmount,
        'p_discount_amount': order.discountAmount,
        'p_total_amount': order.totalAmount,
        'p_paid_amount': order.paidAmount,
        'p_change_amount': order.changeAmount,
        'p_notes': order.notes,
        'p_items': itemsJson,
      };

      final response = await supabase.rpc('sales_create', params: params);
      print('✅ SalesService: Order created successfully with ID: $response');
      return response as String;
    } catch (e) {
      print('❌ SalesService: Failed to create order: $e');
      throw Exception('Failed to create order: $e');
    }
  }

  // Get all orders
  Future<List<SalesOrder>> getAllOrders({String? search, DateTime? startDate, DateTime? endDate}) async {
    final supabase = _supabase;
    if (supabase == null) return [];

    try {
      final params = {
        'p_search': search,
        'p_start_date': startDate?.toIso8601String(),
        'p_end_date': endDate?.toIso8601String(),
      };

      final response = await supabase.rpc('sales_list', params: params);
      return (response as List).map((json) => SalesOrder.fromJson(json)).toList();
    } catch (e) {
      print('❌ SalesService: Failed to fetch orders: $e');
      throw Exception('Failed to fetch orders: $e');
    }
  }

  // Get order details
  Future<SalesOrder?> getOrderDetails(String orderId) async {
    final supabase = _supabase;
    if (supabase == null) return null;

    try {
      final response = await supabase.rpc('sales_get_details', params: {'p_order_id': orderId});
      if (response == null) return null;
      
      // The RPC returns a composite JSON object {order: ..., customer: ..., items: ...}
      // We might need to flatten it or adjust FromJson to handle this structure if we want full details
      // For now, let's assume we map the 'order' part and merge items.
      
      final data = response as Map<String, dynamic>;
      final orderJson = data['order'] as Map<String, dynamic>;
      orderJson['items'] = data['items']; // Inject items into order JSON
      if (data['customer'] != null) {
        orderJson['customer_name'] = data['customer']['first_name'] + ' ' + data['customer']['last_name'];
      }
      
      return SalesOrder.fromJson(orderJson);
    } catch (e) {
      print('❌ SalesService: Failed to fetch order details: $e');
      throw Exception('Failed to fetch order details: $e');
    }
  }

  // --- Customers ---

  Future<String> createCustomer(Customer customer) async {
    final supabase = _supabase;
    if (supabase == null) throw Exception('Supabase not initialized');

    try {
      final params = {
        'p_first_name': customer.firstName,
        'p_last_name': customer.lastName,
        'p_email': customer.email,
        'p_phone': customer.phone,
        'p_address': customer.address,
        'p_city': customer.city,
        'p_zip': customer.zipCode,
      };

      final response = await supabase.rpc('customers_create', params: params);
      return response as String;
    } catch (e) {
      throw Exception('Failed to create customer: $e');
    }
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final supabase = _supabase;
    if (supabase == null) return [];

    try {
      final response = await supabase.rpc('customers_search', params: {'p_query': query});
      return (response as List).map((json) => Customer.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search customers: $e');
    }
  }

  // Get today's sales statistics
  Future<Map<String, dynamic>> getTodayStats() async {
    final supabase = _supabase;
    if (supabase == null) {
      return {'totalSales': 0.0, 'totalCustomers': 0, 'orderCount': 0};
    }

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Fetch today's orders
      final response = await supabase
          .from('sales_orders')
          .select('total_amount, customer_id')
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String())
          .eq('payment_status', 'paid');

      final orders = response as List;
      
      double totalSales = 0.0;
      final Set<String> uniqueCustomers = {};
      
      for (final order in orders) {
        totalSales += (order['total_amount'] as num?)?.toDouble() ?? 0.0;
        final customerId = order['customer_id'] as String?;
        if (customerId != null && customerId.isNotEmpty) {
          uniqueCustomers.add(customerId);
        }
      }

      return {
        'totalSales': totalSales,
        'totalCustomers': uniqueCustomers.length,
        'orderCount': orders.length,
      };
    } catch (e) {
      print('❌ SalesService: Failed to fetch today stats: $e');
      return {'totalSales': 0.0, 'totalCustomers': 0, 'orderCount': 0};
    }
  }
}
