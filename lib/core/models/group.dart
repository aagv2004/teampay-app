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
}
