import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee.dart';

class HRService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all employees (via RPC list)
  Future<List<Employee>> getAllEmployees() async {
    try {
      final response = await _supabase.rpc('employees_list', params: {
        'p_search': null,
        'p_department': null,
        'p_status': null,
        'p_limit': 200,
        'p_offset': 0,
      });

      return (response as List)
          .map((json) => Employee.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch employees: $e');
    }
  }

  // Get employee by ID
  Future<Employee?> getEmployeeById(String id) async {
    try {
      final response = await _supabase.rpc('employees_get', params: {
        'p_id': id,
      });

      return Employee.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (e.toString().contains('No rows found')) {
        return null;
      }
      throw Exception('Failed to fetch employee: $e');
    }
  }

  // Get employees by department
  Future<List<Employee>> getEmployeesByDepartment(String department) async {
    try {
      final response = await _supabase.rpc('employees_list', params: {
        'p_search': null,
        'p_department': department,
        'p_status': null,
        'p_limit': 200,
        'p_offset': 0,
      });

      return (response as List)
          .map((json) => Employee.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch employees by department: $e');
    }
  }

  // Get employees by status
  Future<List<Employee>> getEmployeesByStatus(String status) async {
    try {
      final response = await _supabase.rpc('employees_list', params: {
        'p_search': null,
        'p_department': null,
        'p_status': status,
        'p_limit': 200,
        'p_offset': 0,
      });

      return (response as List)
          .map((json) => Employee.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch employees by status: $e');
    }
  }

  // Search employees
  Future<List<Employee>> searchEmployees(String query) async {
    try {
      final response = await _supabase.rpc('employees_list', params: {
        'p_search': query,
        'p_department': null,
        'p_status': null,
        'p_limit': 200,
        'p_offset': 0,
      });

      return (response as List)
          .map((json) => Employee.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search employees: $e');
    }
  }

  // Create new employee
  Future<Employee> createEmployee(Employee employee) async {
    try {
      final response = await _supabase.rpc('employees_create', params: {
        'p_first_name': employee.firstName,
        'p_last_name': employee.lastName,
        'p_email': employee.email,
        'p_phone': employee.phone,
        'p_department': employee.department,
        'p_position': employee.position,
        'p_employee_id': employee.employeeId,
        'p_hire_date': employee.hireDate.toIso8601String(),
        'p_salary': employee.salary,
        'p_status': employee.status,
        'p_manager_id': employee.managerId,
        'p_address': employee.address,
        'p_emergency_contact': employee.emergencyContact,
        'p_emergency_phone': employee.emergencyPhone,
      });

      return Employee.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create employee: $e');
    }
  }

  // Update employee
  Future<Employee> updateEmployee(Employee employee) async {
    try {
      final patch = employee.toJson();
      final response = await _supabase.rpc('employees_update', params: {
        'p_id': employee.id,
        'p_patch': patch,
      });

      return Employee.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update employee: $e');
    }
  }

  // Delete employee
  Future<void> deleteEmployee(String id) async {
    try {
      await _supabase.rpc('employees_delete', params: {
        'p_id': id,
      });
    } catch (e) {
      throw Exception('Failed to delete employee: $e');
    }
  }

  // Terminate employee
  Future<Employee> terminateEmployee(String id, DateTime terminationDate) async {
    try {
      final response = await _supabase.rpc('employees_update', params: {
        'p_id': id,
        'p_patch': {
          'status': 'terminated',
          'termination_date': terminationDate.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }
      });

      return Employee.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to terminate employee: $e');
    }
  }

  // Get employee statistics
  Future<Map<String, dynamic>> getEmployeeStatistics() async {
    try {
      // Counts via RPC list lengths (fallback without count option)
      final totalList = await _supabase.rpc('employees_list', params: {
        'p_search': null,
        'p_department': null,
        'p_status': null,
        'p_limit': 10000,
        'p_offset': 0,
      }) as List;

      final activeList = await _supabase.rpc('employees_list', params: {
        'p_search': null,
        'p_department': null,
        'p_status': 'active',
        'p_limit': 10000,
        'p_offset': 0,
      }) as List;

      // Get employees by department
      final departmentResponse = await _supabase
          .from('employees')
          .select('department')
          .eq('status', 'active') as List;

      // Get average salary
      final salaryResponse = await _supabase
          .from('employees')
          .select('salary')
          .eq('status', 'active') as List;

      final totalEmployees = totalList.length;
      final activeEmployees = activeList.length;
      final terminatedEmployees = totalEmployees - activeEmployees;

      // Calculate department distribution
      final departments = <String, int>{};
      for (final row in departmentResponse) {
        final dept = row['department'] as String;
        departments[dept] = (departments[dept] ?? 0) + 1;
      }

      // Calculate average salary
      double averageSalary = 0;
      if (salaryResponse.isNotEmpty) {
        final salaries = salaryResponse
            .map((row) => (row['salary'] as num).toDouble())
            .toList();
        averageSalary = salaries.reduce((a, b) => a + b) / salaries.length;
      }

      return {
        'total_employees': totalEmployees,
        'active_employees': activeEmployees,
        'terminated_employees': terminatedEmployees,
        'departments': departments,
        'average_salary': averageSalary,
      };
    } catch (e) {
      throw Exception('Failed to get employee statistics: $e');
    }
  }

  // Get employees with managers
  Future<List<Employee>> getEmployeesWithManagers() async {
    try {
      final response = await _supabase
          .from('employees')
          .select('*, managers:employees!employees_manager_id_fkey(*)')
          .not('manager_id', 'is', null)
          .order('first_name', ascending: true);

      return (response as List)
          .map((json) => Employee.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch employees with managers: $e');
    }
  }

  // Get managers
  Future<List<Employee>> getManagers() async {
    try {
      // Fetch via list and filter client-side due to SDK API differences
      final response = await _supabase.rpc('employees_list', params: {
        'p_search': null,
        'p_department': null,
        'p_status': 'active',
        'p_limit': 10000,
        'p_offset': 0,
      }) as List;

      final managers = response.where((row) {
        final pos = (row['position'] as String?)?.toLowerCase() ?? '';
        return pos.contains('manager') || pos.contains('director') || pos == 'vp' || pos == 'ceo';
      }).toList();

      return managers.map((json) => Employee.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch managers: $e');
    }
  }

  // Get employees by hire date range
  Future<List<Employee>> getEmployeesByHireDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final response = await _supabase
          .from('employees')
          .select()
          .gte('hire_date', startDate.toIso8601String())
          .lte('hire_date', endDate.toIso8601String())
          .order('hire_date', ascending: false);

      return (response as List)
          .map((json) => Employee.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch employees by hire date range: $e');
    }
  }

  // Bulk update employees
  Future<void> bulkUpdateEmployees(List<Employee> employees) async {
    try {
      final data = employees.map((emp) {
        final json = emp.toJson();
        json.remove('created_at');
        json['updated_at'] = DateTime.now().toIso8601String();
        return json;
      }).toList();

      await _supabase
          .from('employees')
          .upsert(data);
    } catch (e) {
      throw Exception('Failed to bulk update employees: $e');
    }
  }
}
