class Expense {
  final String id;
  final String groupId;
  final String title;
  final double amount;
  final String paidByMemberId;
  final List<String> splitBetweenMemberIds;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.groupId,
    required this.title,
    required this.amount,
    required this.paidByMemberId,
    required this.splitBetweenMemberIds,
    required this.createdAt,
  });
}
