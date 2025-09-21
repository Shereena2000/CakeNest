class Sale {
  String id;
  String customerId;
  String customerName;
  double totalAmount;
  DateTime saleDate;
  DateTime createdAt;
  DateTime updatedAt;
  bool isDeleted;
  bool synced;

  Sale({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.totalAmount,
    DateTime? saleDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isDeleted = false,
    this.synced = false,
  }) : saleDate = saleDate ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'total_amount': totalAmount,
      'sale_date': saleDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
      'synced': synced ? 1 : 0,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      customerId: map['customer_id'],
      customerName: map['customer_name'],
      totalAmount: map['total_amount'],
      saleDate: DateTime.parse(map['sale_date']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isDeleted: map['is_deleted'] == 1,
      synced: map['synced'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'total_amount': totalAmount,
      'sale_date': saleDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_deleted': isDeleted,
    };
  }

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      totalAmount: json['total_amount'].toDouble(),
      saleDate: DateTime.parse(json['sale_date']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isDeleted: json['is_deleted'] ?? false,
      synced: true,
    );
  }
}