class OutboxItem {
  String id;
  String tableName;
  String recordId;
  String action; // CREATE, UPDATE, DELETE
  String data; // JSON string
  DateTime createdAt;
  bool synced;
  int retryCount;

  OutboxItem({
    required this.id,
    required this.tableName,
    required this.recordId,
    required this.action,
    required this.data,
    DateTime? createdAt,
    this.synced = false,
    this.retryCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'table_name': tableName,
      'record_id': recordId,
      'action': action,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'synced': synced ? 1 : 0,
      'retry_count': retryCount,
    };
  }

  factory OutboxItem.fromMap(Map<String, dynamic> map) {
    return OutboxItem(
      id: map['id'],
      tableName: map['table_name'],
      recordId: map['record_id'],
      action: map['action'],
      data: map['data'],
      createdAt: DateTime.parse(map['created_at']),
      synced: map['synced'] == 1,
      retryCount: map['retry_count'] ?? 0,
    );
  }
}