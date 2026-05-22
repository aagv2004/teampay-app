import 'package:cloud_firestore/cloud_firestore.dart';

import 'member.dart';
import 'expense.dart';
import 'debt.dart';

class Group {
  final String id;
  final String name;
  final String ownerMemberId;
  final List<Member> members;
  final List<Expense> expenses;
  final List<Debt> debts;
  final DateTime createdAt;

  const Group({
    required this.id,
    required this.name,
    required this.ownerMemberId,
    required this.members,
    required this.expenses,
    required this.debts,
    required this.createdAt,
  });

  Group copyWith({
    String? id,
    String? name,
    String? ownerMemberId,
    List<Member>? members,
    List<Expense>? expenses,
    List<Debt>? debts,
    DateTime? createdAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerMemberId: ownerMemberId ?? this.ownerMemberId,
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
      'ownerMemberId': ownerMemberId,
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
      ownerMemberId: map['ownerMemberId'] ?? '',
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
