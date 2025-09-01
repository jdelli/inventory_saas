import 'package:flutter/foundation.dart';
import '../models/employee.dart';
import '../services/hr_service.dart';

class HRProvider with ChangeNotifier {
  final HRService _hrService = HRService();
  
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  Employee? _selectedEmployee;
  Map<String, dynamic> _statistics = {};
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';
  String _filterDepartment = '';
  String _filterStatus = '';

  // Getters
  List<Employee> get employees => _employees;
  List<Employee> get filteredEmployees => _filteredEmployees;
  Employee? get selectedEmployee => _selectedEmployee;
  Map<String, dynamic> get statistics => _statistics;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchQuery => _searchQuery;
  String get filterDepartment => _filterDepartment;
  String get filterStatus => _filterStatus;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Load all employees
  Future<void> loadEmployees() async {
    try {
      _setLoading(true);
      _setError('');
      
      _employees = await _hrService.getAllEmployees();
      _applyFilters();
      
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load employee by ID
  Future<void> loadEmployeeById(String id) async {
    try {
      _setLoading(true);
      _setError('');
      
      _selectedEmployee = await _hrService.getEmployeeById(id);
      
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load statistics
  Future<void> loadStatistics() async {
    try {
      _setLoading(true);
      _setError('');
      
      _statistics = await _hrService.getEmployeeStatistics();
      
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create employee
  Future<bool> createEmployee(Employee employee) async {
    try {
      _setLoading(true);
      _setError('');
      
      final newEmployee = await _hrService.createEmployee(employee);
      _employees.insert(0, newEmployee);
      _applyFilters();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update employee
  Future<bool> updateEmployee(Employee employee) async {
    try {
      _setLoading(true);
      _setError('');
      
      final updatedEmployee = await _hrService.updateEmployee(employee);
      
      final index = _employees.indexWhere((e) => e.id == employee.id);
      if (index != -1) {
        _employees[index] = updatedEmployee;
      }
      
      if (_selectedEmployee?.id == employee.id) {
        _selectedEmployee = updatedEmployee;
      }
      
      _applyFilters();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete employee
  Future<bool> deleteEmployee(String id) async {
    try {
      _setLoading(true);
      _setError('');
      
      await _hrService.deleteEmployee(id);
      
      _employees.removeWhere((e) => e.id == id);
      if (_selectedEmployee?.id == id) {
        _selectedEmployee = null;
      }
      
      _applyFilters();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Terminate employee
  Future<bool> terminateEmployee(String id, DateTime terminationDate) async {
    try {
      _setLoading(true);
      _setError('');
      
      final terminatedEmployee = await _hrService.terminateEmployee(id, terminationDate);
      
      final index = _employees.indexWhere((e) => e.id == id);
      if (index != -1) {
        _employees[index] = terminatedEmployee;
      }
      
      if (_selectedEmployee?.id == id) {
        _selectedEmployee = terminatedEmployee;
      }
      
      _applyFilters();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search employees
  Future<void> searchEmployees(String query) async {
    try {
      _setLoading(true);
      _setError('');
      
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredEmployees = _employees;
      } else {
        _filteredEmployees = await _hrService.searchEmployees(query);
      }
      
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Filter by department
  void filterByDepartment(String department) {
    _filterDepartment = department;
    _applyFilters();
  }

  // Filter by status
  void filterByStatus(String status) {
    _filterStatus = status;
    _applyFilters();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _filterDepartment = '';
    _filterStatus = '';
    _applyFilters();
  }

  // Apply all filters
  void _applyFilters() {
    _filteredEmployees = _employees.where((employee) {
      bool matchesDepartment = _filterDepartment.isEmpty || 
          employee.department.toLowerCase() == _filterDepartment.toLowerCase();
      
      bool matchesStatus = _filterStatus.isEmpty || 
          employee.status.toLowerCase() == _filterStatus.toLowerCase();
      
      bool matchesSearch = _searchQuery.isEmpty || 
          employee.firstName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          employee.lastName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          employee.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          employee.employeeId.toLowerCase().contains(_searchQuery.toLowerCase());
      
      return matchesDepartment && matchesStatus && matchesSearch;
    }).toList();
    
    notifyListeners();
  }

  // Get employees by department
  Future<List<Employee>> getEmployeesByDepartment(String department) async {
    try {
      return await _hrService.getEmployeesByDepartment(department);
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // Get employees by status
  Future<List<Employee>> getEmployeesByStatus(String status) async {
    try {
      return await _hrService.getEmployeesByStatus(status);
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // Get managers
  Future<List<Employee>> getManagers() async {
    try {
      return await _hrService.getManagers();
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // Get employees with managers
  Future<List<Employee>> getEmployeesWithManagers() async {
    try {
      return await _hrService.getEmployeesWithManagers();
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // Get employees by hire date range
  Future<List<Employee>> getEmployeesByHireDateRange(DateTime startDate, DateTime endDate) async {
    try {
      return await _hrService.getEmployeesByHireDateRange(startDate, endDate);
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // Bulk update employees
  Future<bool> bulkUpdateEmployees(List<Employee> employees) async {
    try {
      _setLoading(true);
      _setError('');
      
      await _hrService.bulkUpdateEmployees(employees);
      
      // Refresh the employee list
      await loadEmployees();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get unique departments
  List<String> get uniqueDepartments {
    return _employees
        .map((e) => e.department)
        .toSet()
        .toList()
      ..sort();
  }

  // Get unique positions
  List<String> get uniquePositions {
    return _employees
        .map((e) => e.position)
        .toSet()
        .toList()
      ..sort();
  }

  // Get active employees count
  int get activeEmployeesCount {
    return _employees.where((e) => e.status == 'active').length;
  }

  // Get terminated employees count
  int get terminatedEmployeesCount {
    return _employees.where((e) => e.status == 'terminated').length;
  }

  // Get total salary
  double get totalSalary {
    return _employees
        .where((e) => e.status == 'active')
        .fold(0.0, (sum, e) => sum + e.salary);
  }

  // Get average salary
  double get averageSalary {
    final activeEmployees = _employees.where((e) => e.status == 'active').toList();
    if (activeEmployees.isEmpty) return 0.0;
    
    final totalSalary = activeEmployees.fold(0.0, (sum, e) => sum + e.salary);
    return totalSalary / activeEmployees.length;
  }
}
