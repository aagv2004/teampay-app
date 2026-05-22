enum PaymentMethod { cash, transfer }

class Debt {
  final String id;
  final String expenseId;
  final String groupId;
  final String fromMemberId;
  final String toMemberId;
  final double amount;
  final double paidAmount;
  final PaymentMethod? paymentMethod;

  const Debt({
    required this.id,
    required this.expenseId,
    required this.groupId,
    required this.fromMemberId,
    required this.toMemberId,
    required this.amount,
    this.paidAmount = 0,
    this.paymentMethod,
  });

  Debt copyWith({
    String? id,
    String? expenseId,
    String? groupId,
    String? fromMemberId,
    String? toMemberId,
    double? amount,
    double? paidAmount,
    PaymentMethod? paymentMethod,
  }) {
    return Debt(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      groupId: groupId ?? this.groupId,
      fromMemberId: fromMemberId ?? this.fromMemberId,
      toMemberId: toMemberId ?? this.toMemberId,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expenseId': expenseId,
      'groupId': groupId,
      'fromMemberId': fromMemberId,
      'toMemberId': toMemberId,
      'amount': amount,
      'paidAmount': paidAmount,
      'paymentMethod': paymentMethod?.name,
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'] ?? '',
      expenseId: map['expenseId'] ?? '',
      groupId: map['groupId'] ?? '',
      fromMemberId: map['fromMemberId'] ?? '',
      toMemberId: map['toMemberId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      paidAmount: (map['paidAmount'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] == null
          ? null
          : PaymentMethod.values.firstWhere(
              (method) => method.name == map['paymentMethod'],
              orElse: () => PaymentMethod.cash,
            ),
    );
  }

  double get remainingAmount {
    final remaining = amount - paidAmount;
    return remaining < 0 ? 0 : remaining;
  }

  bool get isPaid => remainingAmount == 0;

  bool get isPartiallyPaid => paidAmount > 0 && !isPaid;

  String get statusLabel {
    if (isPaid) return 'Pagado';
    if (isPartiallyPaid) return 'Parcial';
    return 'Pendiente';
  }

  String get paymentMethodLabel {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'Efectivo';
      case PaymentMethod.transfer:
        return 'Transferencia';
      case null:
        return 'Aún no paga';
    }
  }
}
