import 'package:flutter/material.dart';
import 'package:inventory_saas/models/sales_order.dart';
import 'package:inventory_saas/services/sales_service.dart';

class SalesProvider with ChangeNotifier {
  final SalesService _salesService = SalesService();
  List<SalesOrder> _salesOrders = [];
  bool _isLoading = false;
  String? _error;

  List<SalesOrder> get salesOrders => _salesOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed properties
  List<SalesOrder> get pendingOrders => _salesOrders.where((o) => o.status == SalesOrderStatus.pending).toList();
  List<SalesOrder> get processingOrders => _salesOrders.where((o) => o.status == SalesOrderStatus.processing).toList();
  List<SalesOrder> get overdueOrders => _salesOrders.where((o) => o.isOverdue).toList();
  
  double get totalSales => _salesOrders.fold(0, (sum, o) => sum + o.totalAmount);
  double get totalPaid => _salesOrders.fold(0, (sum, o) => sum + o.paidAmount);
  double get totalOutstanding => totalSales - totalPaid;

  SalesProvider() {
    // _loadDummyData(); // Removed dummy data
  }

  Future<void> loadSalesOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _salesOrders = await _salesService.getAllOrders();
    } catch (e) {
      _error = e.toString();
      print('SalesProvider Error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createOrder(SalesOrder order) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _salesService.createOrder(order);
      await loadSalesOrders(); // Refresh list
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> addSalesOrder(SalesOrder order) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      _salesOrders.add(order);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSalesOrder(SalesOrder order) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _salesOrders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        _salesOrders[index] = order;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, SalesOrderStatus status) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _salesOrders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _salesOrders[index] = _salesOrders[index].copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePaymentStatus(String orderId, PaymentStatus status, double paidAmount) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _salesOrders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _salesOrders[index] = _salesOrders[index].copyWith(
          paymentStatus: status,
          paidAmount: paidAmount,
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  SalesOrder? getSalesOrderById(String id) {
    try {
      return _salesOrders.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  List<SalesOrder> searchSalesOrders(String query) {
    if (query.isEmpty) return _salesOrders;
    
    return _salesOrders.where((order) {
      return order.orderNumber.toLowerCase().contains(query.toLowerCase()) ||
             (order.customerName?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
             (order.customerEmail?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
             (order.trackingNumber?.contains(query) ?? false);
    }).toList();
  }

  List<SalesOrder> getOrdersByStatus(SalesOrderStatus status) {
    return _salesOrders.where((o) => o.status == status).toList();
  }

  List<SalesOrder> getOrdersByPaymentStatus(PaymentStatus status) {
    return _salesOrders.where((o) => o.paymentStatus == status).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
