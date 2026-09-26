class TransactionModel {
  final int? id;
  final String userId;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String type;
  final String paymentMethod;
  final String? notes;
  final bool isShared;
  final String? sharedBy;
  final String? paymentSlipPath;

  TransactionModel({
    this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    required this.paymentMethod,
    this.notes,
    this.isShared = false,
    this.sharedBy,
    this.paymentSlipPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'type': type,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'isShared': isShared ? 1 : 0,
      'sharedBy': sharedBy,
      'paymentSlipPath': paymentSlipPath,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      userId: map['userId'] ?? '',
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      type: map['type'],
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      notes: map['notes'],
      isShared: map['isShared'] == 1,
      sharedBy: map['sharedBy'],
      paymentSlipPath: map['paymentSlipPath'],
    );
  }

  TransactionModel copyWith({
    int? id,
    String? userId,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    String? type,
    String? paymentMethod,
    String? notes,
    bool? isShared,
    String? sharedBy,
    String? paymentSlipPath,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      type: type ?? this.type,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      isShared: isShared ?? this.isShared,
      sharedBy: sharedBy ?? this.sharedBy,
      paymentSlipPath: paymentSlipPath ?? this.paymentSlipPath,
    );
  }
}
