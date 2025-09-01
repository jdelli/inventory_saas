import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:inventory_saas/models/sales_order.dart';

class SalesProvider with ChangeNotifier {
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
    _loadDummyData();
  }

  void _loadDummyData() {
    _salesOrders = [
      SalesOrder(
        id: 'order_001',
        orderNumber: 'SO-2024-001',
        customerId: 'cust_001',
        customerName: 'John Doe',
        customerEmail: 'john.doe@email.com',
        customerPhone: '+1-555-0101',
        customerAddress: '123 Main St, New York, NY 10001',
        status: SalesOrderStatus.confirmed,
        paymentStatus: PaymentStatus.paid,
        orderDate: DateTime.now().subtract(const Duration(days: 5)),
        shipDate: DateTime.now().subtract(const Duration(days: 3)),
        deliveryDate: DateTime.now().subtract(const Duration(days: 1)),
        items: [
          SalesOrderItem(
            id: 'item_001',
            productId: 'prod_001',
            productName: 'iPhone 15 Pro',
            sku: 'IPH15PRO-256-BLK',
            quantity: 1,
            unitPrice: 1199.99,
            totalPrice: 1199.99,
            discount: 0.0,
            notes: '',
          ),
        ],
        subtotal: 1199.99,
        taxAmount: 95.99,
        shippingCost: 0.0,
        discountAmount: 0.0,
        totalAmount: 1295.98,
        paidAmount: 1295.98,
        shippingMethod: 'Free Shipping',
        trackingNumber: 'TRK123456789',
        notes: 'Customer requested signature delivery',
        createdBy: 'admin',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      SalesOrder(
        id: 'order_002',
        orderNumber: 'SO-2024-002',
        customerId: 'cust_002',
        customerName: 'Jane Smith',
        customerEmail: 'jane.smith@email.com',
        customerPhone: '+1-555-0102',
        customerAddress: '456 Oak Ave, Los Angeles, CA 90210',
        status: SalesOrderStatus.processing,
        paymentStatus: PaymentStatus.partial,
        orderDate: DateTime.now().subtract(const Duration(days: 3)),
        shipDate: null,
        deliveryDate: null,
        items: [
          SalesOrderItem(
            id: 'item_002',
            productId: 'prod_003',
            productName: 'MacBook Pro 14"',
            sku: 'MBP14-512-SLV',
            quantity: 1,
            unitPrice: 2499.99,
            totalPrice: 2499.99,
            discount: 100.0,
            notes: 'Student discount applied',
          ),
          SalesOrderItem(
            id: 'item_003',
            productId: 'prod_005',
            productName: 'AirPods Pro',
            sku: 'AIRPODS-PRO-WHT',
            quantity: 1,
            unitPrice: 249.99,
            totalPrice: 249.99,
            discount: 0.0,
            notes: '',
          ),
        ],
        subtotal: 2749.98,
        taxAmount: 219.99,
        shippingCost: 25.0,
        discountAmount: 100.0,
        totalAmount: 2894.97,
        paidAmount: 1500.0,
        shippingMethod: 'Express Shipping',
        trackingNumber: '',
        notes: 'Customer will pay remaining balance on delivery',
        createdBy: 'admin',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now(),
      ),
      SalesOrder(
        id: 'order_003',
        orderNumber: 'SO-2024-003',
        customerId: 'cust_003',
        customerName: 'Mike Johnson',
        customerEmail: 'mike.johnson@email.com',
        customerPhone: '+1-555-0103',
        customerAddress: '789 Pine St, Chicago, IL 60601',
        status: SalesOrderStatus.pending,
        paymentStatus: PaymentStatus.pending,
        orderDate: DateTime.now().subtract(const Duration(days: 1)),
        shipDate: null,
        deliveryDate: null,
        items: [
          SalesOrderItem(
            id: 'item_004',
            productId: 'prod_002',
            productName: 'Samsung Galaxy S24',
            sku: 'SAMS24-128-BLK',
            quantity: 2,
            unitPrice: 899.99,
            totalPrice: 1799.98,
            discount: 0.0,
            notes: 'Bulk order for business',
          ),
        ],
        subtotal: 1799.98,
        taxAmount: 143.99,
        shippingCost: 15.0,
        discountAmount: 0.0,
        totalAmount: 1958.97,
        paidAmount: 0.0,
        shippingMethod: 'Standard Shipping',
        trackingNumber: '',
        notes: 'Awaiting payment confirmation',
        createdBy: 'admin',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      ),
      SalesOrder(
        id: 'order_004',
        orderNumber: 'SO-2024-004',
        customerId: 'cust_004',
        customerName: 'Sarah Wilson',
        customerEmail: 'sarah.wilson@email.com',
        customerPhone: '+1-555-0104',
        customerAddress: '321 Elm St, Miami, FL 33101',
        status: SalesOrderStatus.shipped,
        paymentStatus: PaymentStatus.paid,
        orderDate: DateTime.now().subtract(const Duration(days: 10)),
        shipDate: DateTime.now().subtract(const Duration(days: 8)),
        deliveryDate: null,
        items: [
          SalesOrderItem(
            id: 'item_005',
            productId: 'prod_004',
            productName: 'Dell XPS 13',
            sku: 'DLLXPS13-256-BLK',
            quantity: 1,
            unitPrice: 1299.99,
            totalPrice: 1299.99,
            discount: 50.0,
            notes: 'Loyalty discount',
          ),
        ],
        subtotal: 1299.99,
        taxAmount: 103.99,
        shippingCost: 0.0,
        discountAmount: 50.0,
        totalAmount: 1353.98,
        paidAmount: 1353.98,
        shippingMethod: 'Free Shipping',
        trackingNumber: 'TRK987654321',
        notes: 'In transit',
        createdBy: 'admin',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
    ];
    notifyListeners();
  }

  Future<void> loadSalesOrders() async {
    _isLoading = true;
    _error = null;
    // Don't call notifyListeners() here to avoid setState during build

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      _loadDummyData();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      // Call notifyListeners after the async operation is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
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
             order.customerName.toLowerCase().contains(query.toLowerCase()) ||
             order.customerEmail.toLowerCase().contains(query.toLowerCase()) ||
             order.trackingNumber.contains(query);
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
