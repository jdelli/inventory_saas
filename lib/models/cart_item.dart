import 'package:inventory_saas/models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  double discountPercent;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.discountPercent = 0,
  });

  double get unitPrice => product.sellingPrice;
  
  double get discountAmount => (unitPrice * quantity) * (discountPercent / 100);
  
  double get lineTotal => (unitPrice * quantity) - discountAmount;

  CartItem copyWith({
    Product? product,
    int? quantity,
    double? discountPercent,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      discountPercent: discountPercent ?? this.discountPercent,
    );
  }
}
