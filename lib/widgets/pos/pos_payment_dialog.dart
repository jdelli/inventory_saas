import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory_saas/providers/pos_provider.dart';
import 'package:inventory_saas/utils/theme.dart';

class POSPaymentDialog extends StatefulWidget {
  const POSPaymentDialog({super.key});

  @override
  State<POSPaymentDialog> createState() => _POSPaymentDialogState();
}

class _POSPaymentDialogState extends State<POSPaymentDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _amountController = TextEditingController();
  double _amountTendered = 0;
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedMethod = PaymentMethod.values[_tabController.index];
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<POSProvider>(
      builder: (context, posProvider, child) {
        final total = posProvider.total;
        final change = _amountTendered - total;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(total),
                
                // Payment Method Tabs
                _buildPaymentTabs(),
                
                // Payment Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      if (_selectedMethod == PaymentMethod.cash)
                        _buildCashPayment(total, change)
                      else if (_selectedMethod == PaymentMethod.card)
                        _buildCardPayment()
                      else
                        _buildEWalletPayment(),
                      
                      const SizedBox(height: 24),
                      
                      // Complete Button
                      _buildCompleteButton(posProvider, total),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Amount to Pay',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₱${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.textSecondary,
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 3,
        tabs: const [
          Tab(icon: Icon(Icons.payments), text: 'Cash'),
          Tab(icon: Icon(Icons.credit_card), text: 'Card'),
          Tab(icon: Icon(Icons.account_balance_wallet), text: 'GCash'),
          Tab(icon: Icon(Icons.wallet), text: 'Maya'),
        ],
      ),
    );
  }

  Widget _buildCashPayment(double total, double change) {
    return Column(
      children: [
        // Amount Tendered Input
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            labelText: 'Amount Tendered',
            prefixText: '₱ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
          onChanged: (value) {
            setState(() {
              _amountTendered = double.tryParse(value) ?? 0;
            });
          },
        ),
        const SizedBox(height: 16),
        
        // Quick Amount Buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickAmountButton(total),
            _buildQuickAmountButton(20),
            _buildQuickAmountButton(50),
            _buildQuickAmountButton(100),
            _buildQuickAmountButton(200),
            _buildQuickAmountButton(500),
            _buildQuickAmountButton(1000),
          ],
        ),
        const SizedBox(height: 24),
        
        // Change Display
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: change >= 0 
                ? AppTheme.successColor.withOpacity(0.1) 
                : AppTheme.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: change >= 0 ? AppTheme.successColor : AppTheme.errorColor,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                change >= 0 ? 'Change' : 'Remaining',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: change >= 0 ? AppTheme.successColor : AppTheme.errorColor,
                ),
              ),
              Text(
                '₱${change.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: change >= 0 ? AppTheme.successColor : AppTheme.errorColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAmountButton(double amount) {
    final isExact = amount == Provider.of<POSProvider>(context, listen: false).total;
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _amountTendered = amount;
          _amountController.text = amount.toStringAsFixed(0);
        });
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        side: BorderSide(
          color: isExact ? AppTheme.successColor : AppTheme.primaryColor,
        ),
        backgroundColor: isExact ? AppTheme.successColor.withOpacity(0.1) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        isExact ? 'Exact' : '₱${amount.toStringAsFixed(0)}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isExact ? AppTheme.successColor : AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildCardPayment() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.contactless,
            size: 64,
            color: AppTheme.primaryColor.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ready for Card Payment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap, insert, or swipe card on terminal',
            style: TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEWalletPayment() {
    final isGCash = _selectedMethod == PaymentMethod.gcash;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isGCash 
                  ? const Color(0xFF007DFE).withOpacity(0.1)
                  : const Color(0xFF00B900).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code,
              size: 48,
              color: isGCash ? const Color(0xFF007DFE) : const Color(0xFF00B900),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isGCash ? 'GCash Payment' : 'Maya Payment',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan QR code or enter reference number',
            style: TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Reference Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton(POSProvider posProvider, double total) {
    final canComplete = _selectedMethod != PaymentMethod.cash || _amountTendered >= total;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: !canComplete || _isProcessing
            ? null
            : () async {
                setState(() {
                  _isProcessing = true;
                });
                
                try {
                  // Call backend checkout
                  final orderId = await posProvider.checkout(
                    _selectedMethod,
                    _amountTendered,
                  );
                  
                  if (mounted) {
                    Navigator.pop(context);
                    _showSuccessDialog(context, orderId);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Checkout Failed: $e'), backgroundColor: Colors.red),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _isProcessing = false;
                    });
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.successColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isProcessing
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Complete Payment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Order ID: $orderId',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Print receipt
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.print),
                      label: const Text('Print'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Done'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
