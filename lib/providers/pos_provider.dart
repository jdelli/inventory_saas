import 'package:flutter/foundation.dart';
import 'package:inventory_saas/models/cart_item.dart';
import 'package:inventory_saas/models/product.dart';

enum PaymentMethod { cash, card, gcash, maya }

class POSProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];
  String? _selectedCustomerId;
  String? _selectedCustomerName;
  double _globalDiscountPercent = 0;
  double _taxPercent = 12.0; // Default VAT
  String _orderNotes = '';
  
  // Held orders for later
  List<List<CartItem>> _heldOrders = [];

  // Getters
  List<CartItem> get cartItems => _cartItems;
  String? get selectedCustomerId => _selectedCustomerId;
  String? get selectedCustomerName => _selectedCustomerName;
  double get globalDiscountPercent => _globalDiscountPercent;
  double get taxPercent => _taxPercent;
  String get orderNotes => _orderNotes;
  List<List<CartItem>> get heldOrders => _heldOrders;
  
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

  // Process payment (returns transaction details)
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

    // Clear cart after successful payment
    clearCart();
    
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
