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
