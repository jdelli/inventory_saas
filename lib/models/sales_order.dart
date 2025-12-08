enum SalesOrderStatus {
  draft,
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  completed
}

enum PaymentStatus {
  pending,
  partial,
  paid,
  overdue,
  refunded
}

class SalesOrderItem {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double discount;
  // Notes removed as per schema, or can be kept if added to schema later.
  // Schema has: id, order_id, product_id, product_name, quantity, unit_price, total_price, discount

  SalesOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.discount,
  });

  factory SalesOrderItem.fromJson(Map<String, dynamic> json) {
    return SalesOrderItem(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      quantity: json['quantity'],
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'discount': discount,
    };
  }
}

class SalesOrder {
  final String id;
  final String orderNumber;
  final String customerId;
  final String? customerName;
  final String? customerEmail;
  final String? trackingNumber;
  final SalesOrderStatus status;
  final PaymentStatus paymentStatus;
  final DateTime orderDate;
  final List<SalesOrderItem> items;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final double paidAmount;
  final double changeAmount; // Added
  final String? paymentMethod;
  final String? notes;
  final DateTime createdAt;
  final DateTime? shipDate; // Added as it was referenced in errors

  SalesOrder({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    this.customerName,
    this.customerEmail,
    this.trackingNumber,
    required this.status,
    required this.paymentStatus,
    required this.orderDate,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paidAmount,
    this.changeAmount = 0.0,
    this.paymentMethod,
    this.notes,
    required this.createdAt,
    this.shipDate,
  });

  bool get isOverdue {
    if (paymentStatus == PaymentStatus.paid || paymentStatus == PaymentStatus.refunded) return false;
    // Assuming 30 days terms if no due date
    return DateTime.now().difference(orderDate).inDays > 30;
  }

  double get outstandingAmount => totalAmount - paidAmount;

  factory SalesOrder.fromJson(Map<String, dynamic> json) {
    var itemsList = <SalesOrderItem>[];
    if (json['items'] != null) {
      itemsList = (json['items'] as List)
          .map((item) => SalesOrderItem.fromJson(item))
          .toList();
    }

    return SalesOrder(
      id: json['id'],
      orderNumber: json['order_number'],
      customerId: json['customer_id'] ?? '',
      customerName: json['customer_name'],
      customerEmail: json['customer_email'],
      trackingNumber: json['tracking_number'],
      status: _parseStatus(json['status']),
      paymentStatus: _parsePaymentStatus(json['payment_status']),
      orderDate: DateTime.parse(json['order_date'] ?? json['created_at']),
      items: itemsList,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num).toDouble(),
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      changeAmount: (json['change_amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      shipDate: json['ship_date'] != null ? DateTime.parse(json['ship_date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_id': customerId,
      'status': status.name,
      'payment_status': paymentStatus.name,
      'order_date': orderDate.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'change_amount': changeAmount,
      'payment_method': paymentMethod,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'ship_date': shipDate?.toIso8601String(),
      'customer_email': customerEmail,
      'tracking_number': trackingNumber,
    };
  }

  SalesOrder copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? trackingNumber,
    SalesOrderStatus? status,
    PaymentStatus? paymentStatus,
    DateTime? orderDate,
    List<SalesOrderItem>? items,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    double? paidAmount,
    double? changeAmount,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt, // Ignored in constructor but useful for pattern
    DateTime? shipDate,
  }) {
    return SalesOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderDate: orderDate ?? this.orderDate,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      changeAmount: changeAmount ?? this.changeAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      shipDate: shipDate ?? this.shipDate,
    );
  }

  static SalesOrderStatus _parseStatus(String? status) {
    if (status == null) return SalesOrderStatus.pending;
    try {
      return SalesOrderStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == status.toLowerCase(),
        orElse: () => SalesOrderStatus.pending,
      );
    } catch (_) {
      return SalesOrderStatus.pending;
    }
  }

  static PaymentStatus _parsePaymentStatus(String? status) {
    if (status == null) return PaymentStatus.pending;
    try {
      return PaymentStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == status.toLowerCase(),
        orElse: () => PaymentStatus.pending,
      );
    } catch (_) {
      return PaymentStatus.pending;
    }
  }
}
