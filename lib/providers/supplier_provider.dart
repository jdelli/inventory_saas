import 'package:flutter/foundation.dart';
import 'package:inventory_saas/models/supplier.dart';

class SupplierProvider with ChangeNotifier {
  List<Supplier> _suppliers = [];
  bool _isLoading = false;
  String? _error;

  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed properties
  List<Supplier> get activeSuppliers => _suppliers.where((s) => s.isActive).toList();
  List<Supplier> get overCreditLimitSuppliers => _suppliers.where((s) => s.isOverCreditLimit).toList();
  double get totalCreditLimit => _suppliers.fold(0, (sum, s) => sum + s.creditLimit);
  double get totalCurrentBalance => _suppliers.fold(0, (sum, s) => sum + s.currentBalance);

  SupplierProvider() {
    _loadDummyData();
  }

  void _loadDummyData() {
    _suppliers = [
      Supplier(
        id: 'supp_001',
        name: 'Apple Inc.',
        contactPerson: 'John Smith',
        email: 'john.smith@apple.com',
        phone: '+1-555-0123',
        address: '1 Infinite Loop',
        city: 'Cupertino',
        state: 'CA',
        country: 'USA',
        postalCode: '95014',
        website: 'https://www.apple.com',
        taxId: 'TAX123456789',
        paymentTerms: 'Net 30',
        creditLimit: 50000.0,
        currentBalance: 12500.0,
        notes: 'Primary supplier for Apple products',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now(),
      ),
      Supplier(
        id: 'supp_002',
        name: 'Samsung Electronics',
        contactPerson: 'Sarah Johnson',
        email: 'sarah.johnson@samsung.com',
        phone: '+1-555-0124',
        address: '85 Challenger Rd',
        city: 'Ridgefield Park',
        state: 'NJ',
        country: 'USA',
        postalCode: '07660',
        website: 'https://www.samsung.com',
        taxId: 'TAX987654321',
        paymentTerms: 'Net 45',
        creditLimit: 75000.0,
        currentBalance: 45000.0,
        notes: 'Supplier for Samsung mobile devices',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now(),
      ),
      Supplier(
        id: 'supp_003',
        name: 'Dell Technologies',
        contactPerson: 'Mike Davis',
        email: 'mike.davis@dell.com',
        phone: '+1-555-0125',
        address: '1 Dell Way',
        city: 'Round Rock',
        state: 'TX',
        country: 'USA',
        postalCode: '78682',
        website: 'https://www.dell.com',
        taxId: 'TAX456789123',
        paymentTerms: 'Net 30',
        creditLimit: 30000.0,
        currentBalance: 32000.0,
        notes: 'Computer hardware supplier',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      Supplier(
        id: 'supp_004',
        name: 'Logitech International',
        contactPerson: 'Emily Wilson',
        email: 'emily.wilson@logitech.com',
        phone: '+1-555-0126',
        address: '7700 Gateway Blvd',
        city: 'Newark',
        state: 'CA',
        country: 'USA',
        postalCode: '94560',
        website: 'https://www.logitech.com',
        taxId: 'TAX789123456',
        paymentTerms: 'Net 30',
        creditLimit: 25000.0,
        currentBalance: 8500.0,
        notes: 'Computer accessories supplier',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      ),
      Supplier(
        id: 'supp_005',
        name: 'Inactive Supplier Co.',
        contactPerson: 'Tom Brown',
        email: 'tom.brown@inactive.com',
        phone: '+1-555-0127',
        address: '123 Old Street',
        city: 'Old City',
        state: 'NY',
        country: 'USA',
        postalCode: '10001',
        website: 'https://www.inactive.com',
        taxId: 'TAX111222333',
        paymentTerms: 'Net 30',
        creditLimit: 10000.0,
        currentBalance: 0.0,
        notes: 'Inactive supplier - no longer used',
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now(),
      ),
    ];
    notifyListeners();
  }

  Future<void> loadSuppliers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      _loadDummyData();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSupplier(Supplier supplier) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      _suppliers.add(supplier);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSupplier(Supplier supplier) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _suppliers.indexWhere((s) => s.id == supplier.id);
      if (index != -1) {
        _suppliers[index] = supplier;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSupplier(String supplierId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      _suppliers.removeWhere((s) => s.id == supplierId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBalance(String supplierId, double newBalance) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _suppliers.indexWhere((s) => s.id == supplierId);
      if (index != -1) {
        _suppliers[index] = _suppliers[index].copyWith(
          currentBalance: newBalance,
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

  Supplier? getSupplierById(String id) {
    try {
      return _suppliers.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Supplier> searchSuppliers(String query) {
    if (query.isEmpty) return _suppliers;
    
    return _suppliers.where((supplier) {
      return supplier.name.toLowerCase().contains(query.toLowerCase()) ||
             supplier.contactPerson.toLowerCase().contains(query.toLowerCase()) ||
             supplier.email.toLowerCase().contains(query.toLowerCase()) ||
             supplier.phone.contains(query) ||
             supplier.city.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
