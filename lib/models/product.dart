class Product {
  final String id;
  final String name;
  final String description;
  final String sku;
  final String barcode;
  final String category;
  final String brand;
  final double costPrice;
  final double sellingPrice;
  final int currentStock;
  final int minStockLevel;
  final int maxStockLevel;
  final String unit;
  final String warehouse;
  final String location;
  final String supplierId;
  final String imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.sku,
    required this.barcode,
    required this.category,
    required this.brand,
    required this.costPrice,
    required this.sellingPrice,
    required this.currentStock,
    required this.minStockLevel,
    required this.maxStockLevel,
    required this.unit,
    required this.warehouse,
    required this.location,
    required this.supplierId,
    required this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      sku: json['sku'],
      barcode: json['barcode'],
      category: json['category'],
      brand: json['brand'],
      costPrice: (json['cost_price'] ?? json['costPrice']).toDouble(),
      sellingPrice: (json['selling_price'] ?? json['sellingPrice']).toDouble(),
      currentStock: json['current_stock'] ?? json['currentStock'],
      minStockLevel: json['min_stock_level'] ?? json['minStockLevel'],
      maxStockLevel: json['max_stock_level'] ?? json['maxStockLevel'],
      unit: json['unit'],
      warehouse: json['warehouse'],
      location: json['location'],
      supplierId: json['supplier_id'] ?? json['supplierId'],
      imageUrl: json['image_url'] ?? json['imageUrl'],
      isActive: json['is_active'] ?? json['isActive'],
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sku': sku,
      'barcode': barcode,
      'category': category,
      'brand': brand,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'current_stock': currentStock,
      'min_stock_level': minStockLevel,
      'max_stock_level': maxStockLevel,
      'unit': unit,
      'warehouse': warehouse,
      'location': location,
      'supplier_id': supplierId,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? sku,
    String? barcode,
    String? category,
    String? brand,
    double? costPrice,
    double? sellingPrice,
    int? currentStock,
    int? minStockLevel,
    int? maxStockLevel,
    String? unit,
    String? warehouse,
    String? location,
    String? supplierId,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      currentStock: currentStock ?? this.currentStock,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      maxStockLevel: maxStockLevel ?? this.maxStockLevel,
      unit: unit ?? this.unit,
      warehouse: warehouse ?? this.warehouse,
      location: location ?? this.location,
      supplierId: supplierId ?? this.supplierId,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isLowStock => currentStock <= minStockLevel;
  bool get isOutOfStock => currentStock == 0;
  double get stockValue => currentStock * costPrice;
  double get profitMargin => sellingPrice - costPrice;
  double get profitMarginPercentage => ((sellingPrice - costPrice) / costPrice) * 100;
}
