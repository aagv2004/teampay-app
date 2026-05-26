import 'package:cloud_firestore/cloud_firestore.dart';

import 'member.dart';
import 'expense.dart';
import 'debt.dart';

/// Grupo de gastos creado por el usuario autenticado.
/// Guarda integrantes, gastos, deudas y datos visibles del organizador.
class Group {
  final String id;
  final String name;

  /// ID del integrante que representa al organizador dentro del grupo.
  final String organizerMemberId;

  /// UID real de Firebase Auth del usuario que organiza el grupo.
  final String organizerUserId;

  /// Datos visibles del organizador para mostrar sin consultar Auth siempre.
  final String organizerName;
  final String organizerEmail;
  final List<Member> members;
  final List<Expense> expenses;
  final List<Debt> debts;
  final DateTime createdAt;

  const Group({
    required this.id,
    required this.name,
    required this.organizerMemberId,
    required this.organizerUserId,
    required this.organizerName,
    required this.organizerEmail,
    required this.members,
    required this.expenses,
    required this.debts,
    required this.createdAt,
  });

  Group copyWith({
    String? id,
    String? name,
    String? organizerMemberId,
    String? organizerUserId,
    String? organizerName,
    String? organizerEmail,
    List<Member>? members,
    List<Expense>? expenses,
    List<Debt>? debts,
    DateTime? createdAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      organizerMemberId: organizerMemberId ?? this.organizerMemberId,
      organizerUserId: organizerUserId ?? this.organizerUserId,
      organizerName: organizerName ?? this.organizerName,
      organizerEmail: organizerEmail ?? this.organizerEmail,
      members: members ?? this.members,
      expenses: expenses ?? this.expenses,
      debts: debts ?? this.debts,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap({required String userId}) {
    return {
      'id': id,
      'name': name,
      'organizerMemberId': organizerMemberId,
      'organizerUserId': organizerUserId,
      'organizerName': organizerName,
      'organizerEmail': organizerEmail,
      'members': members.map((member) => member.toMap()).toList(),
      'expenses': expenses.map((expense) => expense.toMap()).toList(),
      'debts': debts.map((debt) => debt.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      // Permite abrir grupos guardados antes del renombrado.
      organizerMemberId: map['organizerMemberId'] ?? map['ownerMemberId'] ?? '',
      organizerUserId: map['organizerUserId'] ?? map['userId'] ?? '',
      organizerName: map['organizerName'] ?? '',
      organizerEmail: map['organizerEmail'] ?? '',
      members: (map['members'] as List<dynamic>? ?? [])
          .map((member) => Member.fromMap(Map<String, dynamic>.from(member)))
          .toList(),
      expenses: (map['expenses'] as List<dynamic>? ?? [])
          .map((expense) => Expense.fromMap(Map<String, dynamic>.from(expense)))
          .toList(),
      debts: (map['debts'] as List<dynamic>? ?? [])
          .map((debt) => Debt.fromMap(Map<String, dynamic>.from(debt)))
          .toList(),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
