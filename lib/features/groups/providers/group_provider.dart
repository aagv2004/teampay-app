import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/models/group.dart';
import '../../../core/models/member.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/debt.dart';

class GroupProvider extends ChangeNotifier {
  final List<Group> _groups = List.from(mockGroups);

  List<Group> get groups => _groups;

  Group? getGroupById(String groupId) {
    try {
      return _groups.firstWhere((group) => group.id == groupId);
    } catch (_) {
      return null;
    }
  }

  void createGroup({
    required String name,
    required List<String> memberNames,
    required int ownerIndex,
  }) {
    final members = memberNames
        .where((name) => name.trim().isNotEmpty)
        .map(
          (name) => Member(
            id: DateTime.now().microsecondsSinceEpoch.toString() + name,
            name: name.trim(),
          ),
        )
        .toList();

    final group = Group(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      ownerMemberId: members[ownerIndex].id,
      members: members,
      expenses: [],
      debts: [],
      createdAt: DateTime.now(),
    );

    _groups.add(group);
    notifyListeners();
  }

  void editGroup({
    required String groupId,
    required String name,
    required List<Member> members,
    required String ownerMemberId,
  }) {
    final index = _groups.indexWhere((group) => group.id == groupId);

    if (index == -1) return;

    final currentGroup = _groups[index];

    _groups[index] = currentGroup.copyWith(
      name: name.trim(),
      members: members,
      ownerMemberId: ownerMemberId,
    );

    notifyListeners();
  }

  void deleteGroup(String groupId) {
    _groups.removeWhere((group) => group.id == groupId);
    notifyListeners();
  }

  void addExpense({
    required String groupId,
    required String title,
    required double amount,
    required String paidByMemberId,
    required List<String> splitBetweenMemberIds,
  }) {
    final groupIndex = _groups.indexWhere((group) => group.id == groupId);

    if (groupIndex == -1) return;
    if (splitBetweenMemberIds.isEmpty) return;
    if (amount <= 0) return;

    final group = _groups[groupIndex];

    final expenseId = DateTime.now().microsecondsSinceEpoch.toString();

    final expense = Expense(
      id: expenseId,
      groupId: groupId,
      title: title.trim(),
      amount: amount,
      paidByMemberId: paidByMemberId,
      splitBetweenMemberIds: splitBetweenMemberIds,
      createdAt: DateTime.now(),
    );

    final splitAmount = amount / splitBetweenMemberIds.length;

    final generatedDebts = splitBetweenMemberIds
        .where((memberId) => memberId != paidByMemberId)
        .map(
          (memberId) => Debt(
            id: '${DateTime.now().microsecondsSinceEpoch}-$memberId',
            expenseId: expenseId,
            groupId: groupId,
            fromMemberId: memberId,
            toMemberId: paidByMemberId,
            amount: splitAmount,
          ),
        )
        .toList();

    final updatedDebts = [...group.debts];

    for (final newDebt in generatedDebts) {
      final existingDebtIndex = updatedDebts.indexWhere(
        (debt) =>
            debt.groupId == groupId &&
            debt.fromMemberId == newDebt.fromMemberId &&
            debt.toMemberId == newDebt.toMemberId &&
            !debt.isPaid,
      );

      if (existingDebtIndex == -1) {
        updatedDebts.add(newDebt);
      } else {
        final existingDebt = updatedDebts[existingDebtIndex];

        updatedDebts[existingDebtIndex] = existingDebt.copyWith(
          amount: existingDebt.amount + newDebt.amount,
        );
      }
    }

    _groups[groupIndex] = group.copyWith(
      expenses: [...group.expenses, expense],
      debts: updatedDebts,
    );

    notifyListeners();
  }

  void registerDebtPayment({
    required String groupId,
    required String debtId,
    required double paymentAmount,
    required PaymentMethod paymentMethod,
  }) {
    final groupIndex = _groups.indexWhere((group) => group.id == groupId);

    if (groupIndex == -1) return;
    if (paymentAmount <= 0) return;

    final group = _groups[groupIndex];

    final updatedDebts = group.debts.map((debt) {
      if (debt.id == debtId) return debt;

      final newPaidAmount = debt.paidAmount + paymentAmount;

      return debt.copyWith(
        paidAmount: newPaidAmount > debt.amount ? debt.amount : newPaidAmount,
        paymentMethod: paymentMethod,
      );
    }).toList();

    _groups[groupIndex] = group.copyWith(debts: updatedDebts);

    notifyListeners();
  }
}
