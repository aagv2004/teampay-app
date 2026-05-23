import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/debt.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/group.dart';
import '../../../core/models/member.dart';
import '../services/group_firestore_service.dart';

class GroupProvider extends ChangeNotifier {
  GroupProvider({GroupFirestoreService? service})
    : _service = service ?? GroupFirestoreService();

  final GroupFirestoreService _service;

  final List<Group> _groups = [];
  StreamSubscription<List<Group>>? _groupsSubscription;

  String? _currentUserId;
  bool _isLoading = false;
  String? _errorMessage;

  List<Group> get groups => List.unmodifiable(_groups);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void bindUser(String userId) {
    if (_currentUserId == userId) return;

    _currentUserId = userId;
    _isLoading = true;
    _errorMessage = null;
    _groups.clear();
    notifyListeners();

    _groupsSubscription?.cancel();

    _groupsSubscription = _service
        .watchUserGroups(userId)
        .listen(
          (groups) {
            _groups
              ..clear()
              ..addAll(groups);

            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _isLoading = false;
            _errorMessage = 'No se pudieron cargar los grupos:';
            notifyListeners();
          },
        );
  }

  void clearUser() {
    _currentUserId = null;
    _groupsSubscription?.cancel();
    _groupsSubscription = null;
    _groups.clear();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Group? getGroupById(String groupId) {
    try {
      return _groups.firstWhere((group) => group.id == groupId);
    } catch (_) {
      return null;
    }
  }

  Future<void> createGroup({
    required String name,
    required List<String> memberNames,
    required int ownerIndex,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final members = memberNames
        .where((name) => name.trim().isNotEmpty)
        .map(
          (name) => Member(
            id: '${DateTime.now().microsecondsSinceEpoch}-${name.trim()}',
            name: name.trim(),
          ),
        )
        .toList();

    if (members.isEmpty) return;
    if (ownerIndex < 0 || ownerIndex >= members.length) return;

    final group = Group(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      ownerMemberId: members[ownerIndex].id,
      members: members,
      expenses: [],
      debts: [],
      createdAt: DateTime.now(),
    );

    await _service.createGroup(userId: userId, group: group);
  }

  Future<void> editGroup({
    required String groupId,
    required String name,
    required List<Member> members,
    required String ownerMemberId,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final index = _groups.indexWhere((group) => group.id == groupId);
    if (index == -1) return;

    final currentGroup = _groups[index];

    final updatedGroup = currentGroup.copyWith(
      name: name.trim(),
      members: members,
      ownerMemberId: ownerMemberId,
    );

    await _service.updateGroup(userId: userId, group: updatedGroup);
  }

  Future<void> deleteGroup(String groupId) async {
    await _service.deleteGroup(groupId);
  }

  Future<void> addExpense({
    required String groupId,
    required String title,
    required double amount,
    required String paidByMemberId,
    required List<String> splitBetweenMemberIds,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return;

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

    final updatedGroup = group.copyWith(
      expenses: [...group.expenses, expense],
      debts: updatedDebts,
    );

    await _service.updateGroup(userId: userId, group: updatedGroup);
  }

  Future<void> registerDebtPayment({
    required String groupId,
    required String debtId,
    required double paymentAmount,
    required PaymentMethod paymentMethod,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final groupIndex = _groups.indexWhere((group) => group.id == groupId);
    if (groupIndex == -1) return;
    if (paymentAmount <= 0) return;

    final group = _groups[groupIndex];

    final updatedDebts = group.debts.map((debt) {
      if (debt.id != debtId) return debt;

      final newPaidAmount = debt.paidAmount + paymentAmount;

      return debt.copyWith(
        paidAmount: newPaidAmount > debt.amount ? debt.amount : newPaidAmount,
        paymentMethod: paymentMethod,
      );
    }).toList();

    final updatedGroup = group.copyWith(debts: updatedDebts);

    await _service.updateGroup(userId: userId, group: updatedGroup);
  }

  @override
  void dispose() {
    _groupsSubscription?.cancel();
    super.dispose();
  }
}
