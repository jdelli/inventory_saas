import 'package:flutter/foundation.dart';
import 'package:inventory_saas/models/cart_item.dart';
import 'package:inventory_saas/models/product.dart';
import 'package:inventory_saas/models/sales_order.dart';
import 'package:inventory_saas/services/sales_service.dart';

enum PaymentMethod { cash, card, gcash, maya }

class POSProvider with ChangeNotifier {
  final SalesService _salesService = SalesService();
  List<CartItem> _cartItems = [];
  String? _selectedCustomerId;
  String? _selectedCustomerName;
  double _globalDiscountPercent = 0;
  double _taxPercent = 12.0; // Default VAT
  String _orderNotes = '';
  
  // Held orders for later
  List<List<CartItem>> _heldOrders = [];
  
  // Today's statistics
  double _todayTotalSales = 0.0;
  int _todayTotalCustomers = 0;
  int _todayOrderCount = 0;
  bool _statsLoading = false;

  // Constructor - load today's stats
  POSProvider() {
    loadTodayStats();
  }

  // Getters
  List<CartItem> get cartItems => _cartItems;
  String? get selectedCustomerId => _selectedCustomerId;
  String? get selectedCustomerName => _selectedCustomerName;
  double get globalDiscountPercent => _globalDiscountPercent;
  double get taxPercent => _taxPercent;
  String get orderNotes => _orderNotes;
  List<List<CartItem>> get heldOrders => _heldOrders;
  
  // Today's stats getters
  double get todayTotalSales => _todayTotalSales;
  int get todayTotalCustomers => _todayTotalCustomers;
  int get todayOrderCount => _todayOrderCount;
  bool get statsLoading => _statsLoading;
  
  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  double get subtotal => _cartItems.fold(0.0, (sum, item) => sum + item.lineTotal);
  
  double get globalDiscountAmount => subtotal * (_globalDiscountPercent / 100);
  
  double get taxableAmount => subtotal - globalDiscountAmount;
  
  double get taxAmount => taxableAmount * (_taxPercent / 100);
  
  double get total => taxableAmount + taxAmount;

  bool get isEmpty => _cartItems.isEmpty;

  // Add product to cart
  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  // Remove product from cart
  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  // Update quantity
  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(productId);
      return;
    }
    
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      _cartItems[index].quantity = newQuantity;
      notifyListeners();
    }
  }

  // Increment quantity
  void incrementQuantity(String productId) {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      _cartItems[index].quantity++;
      notifyListeners();
    }
  }

  // Decrement quantity
  void decrementQuantity(String productId) {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Apply discount to specific item
  void applyItemDiscount(String productId, double discountPercent) {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      _cartItems[index].discountPercent = discountPercent.clamp(0, 100);
      notifyListeners();
    }
  }

  // Apply global discount
  void applyGlobalDiscount(double discountPercent) {
    _globalDiscountPercent = discountPercent.clamp(0, 100);
    notifyListeners();
  }

  // Set tax percentage
  void setTaxPercent(double percent) {
    _taxPercent = percent.clamp(0, 100);
    notifyListeners();
  }

  // Set customer
  void setCustomer(String? customerId, String? customerName) {
    _selectedCustomerId = customerId;
    _selectedCustomerName = customerName;
    notifyListeners();
  }

  // Set order notes
  void setOrderNotes(String notes) {
    _orderNotes = notes;
    notifyListeners();
  }

  // Hold current order
  void holdOrder() {
    if (_cartItems.isNotEmpty) {
      _heldOrders.add(List.from(_cartItems));
      _cartItems = [];
      _orderNotes = '';
      notifyListeners();
    }
  }

  // Recall held order
  void recallOrder(int index) {
    if (index >= 0 && index < _heldOrders.length) {
      // If current cart has items, hold them first
      if (_cartItems.isNotEmpty) {
        _heldOrders.add(List.from(_cartItems));
      }
      _cartItems = _heldOrders.removeAt(index);
      notifyListeners();
    }
  }

  // Clear cart
  void clearCart() {
    _cartItems = [];
    _selectedCustomerId = null;
    _selectedCustomerName = null;
    _globalDiscountPercent = 0;
    _orderNotes = '';
    notifyListeners();
  }

  // Load today's sales statistics
  Future<void> loadTodayStats() async {
    _statsLoading = true;
    notifyListeners();
    
    try {
      final stats = await _salesService.getTodayStats();
      _todayTotalSales = stats['totalSales'] as double;
      _todayTotalCustomers = stats['totalCustomers'] as int;
      _todayOrderCount = stats['orderCount'] as int;
    } catch (e) {
      print('Failed to load today stats: $e');
    } finally {
      _statsLoading = false;
      notifyListeners();
    }
  }

  // Checkout (Async, creates order in DB)
  Future<String> checkout(PaymentMethod method, double amountTendered) async {
    if (_cartItems.isEmpty) {
      throw Exception('Cart is empty');
    }

    try {
      // Create SalesOrder object
      final order = SalesOrder(
        id: '', // Generated by DB
        orderNumber: '', // Generated by DB
        customerId: _selectedCustomerId ?? '',
        customerName: _selectedCustomerName,
        status: SalesOrderStatus.completed,
        paymentStatus: PaymentStatus.paid,
        orderDate: DateTime.now(),
        items: _cartItems.map((item) => SalesOrderItem(
          id: '', // Generated by DB
          productId: item.product.id,
          productName: item.product.name,
          quantity: item.quantity,
          unitPrice: item.product.sellingPrice,
          totalPrice: item.lineTotal,
          discount: item.discountPercent > 0 ? (item.quantity * item.product.sellingPrice * item.discountPercent / 100) : 0,
          // notes: '', // Removed from SalesOrderItem schema
        )).toList(),
        subtotal: subtotal,
        taxAmount: taxAmount,
        discountAmount: globalDiscountAmount, // + item discounts if needed?
        totalAmount: total,
        paidAmount: amountTendered,
        changeAmount: (amountTendered - total) > 0 ? (amountTendered - total) : 0,
        paymentMethod: method.toString().split('.').last,
        notes: _orderNotes,
        createdAt: DateTime.now(),
      );

      // Call Service
      final orderId = await _salesService.createOrder(order);
      
      // Clear cart on success
      clearCart();
      
      // Refresh today's stats after successful checkout
      loadTodayStats();
      
      return orderId;
    } catch (e) {
      print('POS Checkout Error: $e');
      rethrow;
    }
  }

  // Process payment logic (Legacy/Local wrapper)
  Map<String, dynamic> processPayment(PaymentMethod method, double amountTendered) {
    final transaction = {
      'transactionId': 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      'timestamp': DateTime.now(),
      'items': _cartItems.map((item) => {
        'productId': item.product.id,
        'productName': item.product.name,
        'quantity': item.quantity,
        'unitPrice': item.unitPrice,
        'discount': item.discountPercent,
        'lineTotal': item.lineTotal,
      }).toList(),
      'subtotal': subtotal,
      'globalDiscount': globalDiscountAmount,
      'tax': taxAmount,
      'total': total,
      'paymentMethod': method.toString().split('.').last,
      'amountTendered': amountTendered,
      'change': amountTendered - total,
      'customerId': _selectedCustomerId,
      'customerName': _selectedCustomerName,
      'notes': _orderNotes,
    };

    // We keep this for UI feedback where immediate response is needed, but we rely on checkout() for DB
    // Ideally the UI should call checkout() then use the result.
    
    return transaction;
  }

  // Get cart item by product ID
  CartItem? getCartItem(String productId) {
    try {
      return _cartItems.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }
}
