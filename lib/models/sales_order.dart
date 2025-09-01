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
  final String sku;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double discount;
  final String notes;

  SalesOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.discount,
    required this.notes,
  });

  factory SalesOrderItem.fromJson(Map<String, dynamic> json) {
    return SalesOrderItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      sku: json['sku'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'].toDouble(),
      totalPrice: json['totalPrice'].toDouble(),
      discount: json['discount'].toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'sku': sku,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'discount': discount,
      'notes': notes,
    };
  }

  double get finalPrice => totalPrice - discount;
}

class SalesOrder {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String customerAddress;
  final SalesOrderStatus status;
  final PaymentStatus paymentStatus;
  final DateTime orderDate;
  final DateTime? shipDate;
  final DateTime? deliveryDate;
  final List<SalesOrderItem> items;
  final double subtotal;
  final double taxAmount;
  final double shippingCost;
  final double discountAmount;
  final double totalAmount;
  final double paidAmount;
  final String shippingMethod;
  final String trackingNumber;
  final String notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  SalesOrder({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.customerAddress,
    required this.status,
    required this.paymentStatus,
    required this.orderDate,
    this.shipDate,
    this.deliveryDate,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.shippingCost,
    required this.discountAmount,
    required this.totalAmount,
    required this.paidAmount,
    required this.shippingMethod,
    required this.trackingNumber,
    required this.notes,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SalesOrder.fromJson(Map<String, dynamic> json) {
    return SalesOrder(
      id: json['id'],
      orderNumber: json['orderNumber'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      customerPhone: json['customerPhone'],
      customerAddress: json['customerAddress'],
      status: SalesOrderStatus.values.firstWhere(
        (e) => e.toString() == 'SalesOrderStatus.${json['status']}',
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${json['paymentStatus']}',
      ),
      orderDate: DateTime.parse(json['orderDate']),
      shipDate: json['shipDate'] != null ? DateTime.parse(json['shipDate']) : null,
      deliveryDate: json['deliveryDate'] != null ? DateTime.parse(json['deliveryDate']) : null,
      items: (json['items'] as List)
          .map((item) => SalesOrderItem.fromJson(item))
          .toList(),
      subtotal: json['subtotal'].toDouble(),
      taxAmount: json['taxAmount'].toDouble(),
      shippingCost: json['shippingCost'].toDouble(),
      discountAmount: json['discountAmount'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      paidAmount: json['paidAmount'].toDouble(),
      shippingMethod: json['shippingMethod'],
      trackingNumber: json['trackingNumber'],
      notes: json['notes'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'status': status.toString().split('.').last,
      'paymentStatus': paymentStatus.toString().split('.').last,
      'orderDate': orderDate.toIso8601String(),
      'shipDate': shipDate?.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'shippingCost': shippingCost,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'shippingMethod': shippingMethod,
      'trackingNumber': trackingNumber,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  double get outstandingAmount => totalAmount - paidAmount;
  bool get isFullyPaid => paidAmount >= totalAmount;
  bool get isOverdue => outstandingAmount > 0 && DateTime.now().isAfter(orderDate.add(const Duration(days: 30)));
  int get totalItems => items.length;
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  SalesOrder copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? customerAddress,
    SalesOrderStatus? status,
    PaymentStatus? paymentStatus,
    DateTime? orderDate,
    DateTime? shipDate,
    DateTime? deliveryDate,
    List<SalesOrderItem>? items,
    double? subtotal,
    double? taxAmount,
    double? shippingCost,
    double? discountAmount,
    double? totalAmount,
    double? paidAmount,
    String? shippingMethod,
    String? trackingNumber,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SalesOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderDate: orderDate ?? this.orderDate,
      shipDate: shipDate ?? this.shipDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      shippingCost: shippingCost ?? this.shippingCost,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
