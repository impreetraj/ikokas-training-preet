import 'dart:convert';

class TransactionLogModel {
  final int? id;
  final int transactionId;
  final String action; 
  final String? previousData; 
  final String? newData; 
  final DateTime timestamp;
  final String logStatus; 

  TransactionLogModel({
    this.id,
    required this.transactionId,
    required this.action,
    this.previousData,
    this.newData,
    required this.timestamp,
    required this.logStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionId': transactionId,
      'action': action,
      'previousData': previousData,
      'newData': newData,
      'timestamp': timestamp.toIso8601String(),
      'logStatus': logStatus,
    };
  }

  factory TransactionLogModel.fromMap(Map<String, dynamic> map) {
    return TransactionLogModel(
      id: map['id'] as int?,
      transactionId: map['transactionId'] as int? ?? 0,
      action: map['action'] as String? ?? 'unknown',
      previousData: map['previousData'] as String?,
      newData: map['newData'] as String?,
      timestamp: map['timestamp'] != null ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now() : DateTime.now(),
      logStatus: map['logStatus'] as String? ?? 'unknown',
    );
  }

  TransactionLogModel copyWith({
    int? id,
    int? transactionId,
    String? action,
    String? previousData,
    String? newData,
    DateTime? timestamp,
    String? logStatus,
  }) {
    return TransactionLogModel(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      action: action ?? this.action,
      previousData: previousData ?? this.previousData,
      newData: newData ?? this.newData,
      timestamp: timestamp ?? this.timestamp,
      logStatus: logStatus ?? this.logStatus,
    );
  }
}
