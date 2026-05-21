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
}
