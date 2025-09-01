import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory_saas/providers/auth_provider.dart';
import 'package:inventory_saas/providers/inventory_provider.dart';
import 'package:inventory_saas/providers/sales_provider.dart';
import 'package:inventory_saas/providers/supplier_provider.dart';
import 'package:inventory_saas/providers/hr_provider.dart';
import 'package:inventory_saas/screens/auth/login_screen.dart';
import 'package:inventory_saas/screens/dashboard/dashboard_screen.dart';
import 'package:inventory_saas/screens/inventory/inventory_screen.dart';
import 'package:inventory_saas/utils/theme.dart';
import 'package:inventory_saas/config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  runApp(const InventorySaaSApp());
}

class InventorySaaSApp extends StatelessWidget {
  const InventorySaaSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
        ChangeNotifierProvider(create: (_) => HRProvider()),
      ],
      child: MaterialApp(
        title: 'Inventory SaaS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return authProvider.isAuthenticated 
                ? const DashboardScreen() 
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}
