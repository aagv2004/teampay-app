import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'title': title,
      'amount': amount,
      'paidByMemberId': paidByMemberId,
      'splitBetweenMemberIds': splitBetweenMemberIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] ?? '',
      groupId: map['groupId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      paidByMemberId: map['paidByMemberId'] ?? '',
      splitBetweenMemberIds: List<String>.from(
        map['splitBetweenMemberIds'] ?? [],
      ),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
