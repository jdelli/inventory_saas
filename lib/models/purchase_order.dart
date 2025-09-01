enum PurchaseOrderStatus {
  draft,
  pending,
  approved,
  ordered,
  received,
  cancelled,
  completed
}

class PurchaseOrderItem {
  final String id;
  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final double unitCost;
  final double totalCost;
  final int receivedQuantity;
  final String notes;

  PurchaseOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitCost,
    required this.totalCost,
    required this.receivedQuantity,
    required this.notes,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      sku: json['sku'],
      quantity: json['quantity'],
      unitCost: json['unitCost'].toDouble(),
      totalCost: json['totalCost'].toDouble(),
      receivedQuantity: json['receivedQuantity'],
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
      'unitCost': unitCost,
      'totalCost': totalCost,
      'receivedQuantity': receivedQuantity,
      'notes': notes,
    };
  }

  int get remainingQuantity => quantity - receivedQuantity;
  bool get isFullyReceived => receivedQuantity >= quantity;
}

class PurchaseOrder {
  final String id;
  final String poNumber;
  final String supplierId;
  final String supplierName;
  final PurchaseOrderStatus status;
  final DateTime orderDate;
  final DateTime expectedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final List<PurchaseOrderItem> items;
  final double subtotal;
  final double taxAmount;
  final double shippingCost;
  final double totalAmount;
  final String notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  PurchaseOrder({
    required this.id,
    required this.poNumber,
    required this.supplierId,
    required this.supplierName,
    required this.status,
    required this.orderDate,
    required this.expectedDeliveryDate,
    this.actualDeliveryDate,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.shippingCost,
    required this.totalAmount,
    required this.notes,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'],
      poNumber: json['poNumber'],
      supplierId: json['supplierId'],
      supplierName: json['supplierName'],
      status: PurchaseOrderStatus.values.firstWhere(
        (e) => e.toString() == 'PurchaseOrderStatus.${json['status']}',
      ),
      orderDate: DateTime.parse(json['orderDate']),
      expectedDeliveryDate: DateTime.parse(json['expectedDeliveryDate']),
      actualDeliveryDate: json['actualDeliveryDate'] != null
          ? DateTime.parse(json['actualDeliveryDate'])
          : null,
      items: (json['items'] as List)
          .map((item) => PurchaseOrderItem.fromJson(item))
          .toList(),
      subtotal: json['subtotal'].toDouble(),
      taxAmount: json['taxAmount'].toDouble(),
      shippingCost: json['shippingCost'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      notes: json['notes'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'poNumber': poNumber,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'status': status.toString().split('.').last,
      'orderDate': orderDate.toIso8601String(),
      'expectedDeliveryDate': expectedDeliveryDate.toIso8601String(),
      'actualDeliveryDate': actualDeliveryDate?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'shippingCost': shippingCost,
      'totalAmount': totalAmount,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isOverdue => DateTime.now().isAfter(expectedDeliveryDate) && 
                       status != PurchaseOrderStatus.completed &&
                       status != PurchaseOrderStatus.cancelled;
  
  bool get isPartiallyReceived => items.any((item) => item.receivedQuantity > 0 && !item.isFullyReceived);
  
  bool get isFullyReceived => items.every((item) => item.isFullyReceived);
  
  int get totalItems => items.length;
  
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
  
  int get receivedQuantity => items.fold(0, (sum, item) => sum + item.receivedQuantity);
}
