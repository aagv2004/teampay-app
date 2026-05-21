import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/models/group.dart';
import '../../../core/models/member.dart';

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
}
