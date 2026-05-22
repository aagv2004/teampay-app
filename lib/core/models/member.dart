class Member {
  final String id;
  final String name;

  const Member({required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(id: map['id'] ?? '', name: map['name'] ?? '');
  }
}
