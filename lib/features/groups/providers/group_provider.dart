import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/debt.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/group.dart';
import '../../../core/models/member.dart';
import '../services/group_firestore_service.dart';

/// Maneja los grupos cargados del usuario actual.
/// Desde aqui se crean grupos, gastos y pagos de deudas.
class GroupProvider extends ChangeNotifier {
  GroupProvider({GroupFirestoreService? service})
    : _service = service ?? GroupFirestoreService();

  final GroupFirestoreService _service;

  final List<Group> _groups = [];
  StreamSubscription<List<Group>>? _groupsSubscription;

  String? _currentUserId;
  String? _currentUserName;
  String? _currentUserEmail;
  bool _isLoading = false;
  String? _errorMessage;

  List<Group> get groups => List.unmodifiable(_groups);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentUserName => _currentUserName;
  String? get currentUserMemberId {
    final userId = _currentUserId;
    if (userId == null) return null;

    return _memberIdForUser(userId);
  }

  /// Conecta el provider con el usuario logueado y empieza a escuchar grupos.
  void bindUser({required String userId, String? displayName, String? email}) {
    if (_currentUserId == userId) {
      _currentUserName = _cleanText(displayName) ?? _currentUserName;
      _currentUserEmail = _cleanText(email) ?? _currentUserEmail;
      _loadUserProfileFallback(userId);
      return;
    }

    _currentUserId = userId;
    _currentUserName = _cleanText(displayName);
    _currentUserEmail = _cleanText(email);
    _isLoading = true;
    _errorMessage = null;
    _groups.clear();
    notifyListeners();

    _groupsSubscription?.cancel();
    _loadUserProfileFallback(userId);

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

  /// Limpia datos locales cuando el usuario cierra sesion.
  void clearUser() {
    _currentUserId = null;
    _currentUserName = null;
    _currentUserEmail = null;
    _groupsSubscription?.cancel();
    _groupsSubscription = null;
    _groups.clear();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Busca un grupo ya cargado usando su ID.
  Group? getGroupById(String groupId) {
    try {
      return _groups.firstWhere((group) => group.id == groupId);
    } catch (_) {
      return null;
    }
  }

  /// Crea un grupo y agrega al usuario actual como organizador.
  Future<void> createGroup({
    required String name,
    required List<String> memberNames,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _loadUserProfileFallback(userId);

    final organizerMember = Member(
      id: _memberIdForUser(userId),
      name: _resolvedUserName(userId),
    );

    final additionalMembers = memberNames
        .where((name) => name.trim().isNotEmpty)
        .map(
          (name) => Member(
            id: '${DateTime.now().microsecondsSinceEpoch}-${name.trim()}',
            name: name.trim(),
          ),
        )
        .toList();

    final members = [organizerMember, ...additionalMembers];

    final group = Group(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      organizerMemberId: organizerMember.id,
      organizerUserId: userId,
      organizerName: organizerMember.name,
      organizerEmail: _currentUserEmail ?? '',
      members: members,
      expenses: [],
      debts: [],
      createdAt: DateTime.now(),
    );

    await _service.createGroup(userId: userId, group: group);
  }

  /// Actualiza nombre e integrantes sin cambiar el organizador.
  Future<void> editGroup({
    required String groupId,
    required String name,
    required List<Member> members,
    required String organizerMemberId,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final index = _groups.indexWhere((group) => group.id == groupId);
    if (index == -1) return;

    final currentGroup = _groups[index];

    final updatedGroup = currentGroup.copyWith(
      name: name.trim(),
      members: members,
      organizerMemberId: organizerMemberId,
    );

    await _service.updateGroup(userId: userId, group: updatedGroup);
  }

  /// Elimina el grupo completo en Firestore.
  Future<void> deleteGroup(String groupId) async {
    await _service.deleteGroup(groupId);
  }

  /// Registra un gasto y genera las deudas correspondientes.
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

  /// Marca un pago parcial o total sobre una deuda existente.
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

  Future<void> _loadUserProfileFallback(String userId) async {
    if (_currentUserName != null && _currentUserEmail != null) return;

    final profile = await _service.getUserProfile(userId);
    if (profile == null) return;
    if (_currentUserId != userId) return;

    final previousName = _currentUserName;
    final previousEmail = _currentUserEmail;

    _currentUserName ??= _cleanText(profile['name']?.toString());
    _currentUserEmail ??= _cleanText(profile['email']?.toString());

    if (previousName != _currentUserName ||
        previousEmail != _currentUserEmail) {
      notifyListeners();
    }
  }

  String _resolvedUserName(String userId) {
    final name = _currentUserName;
    if (name != null) return name;

    final email = _currentUserEmail;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'Usuario TeamPay';
  }

  static String _memberIdForUser(String userId) => 'user-$userId';

  static String? _cleanText(String? value) {
    final cleanValue = value?.trim();
    if (cleanValue == null || cleanValue.isEmpty) return null;

    return cleanValue;
  }
}
