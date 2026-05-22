import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/group.dart';

class GroupFirestoreService {
  GroupFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _groupsCollection {
    return _firestore.collection('groups');
  }

  Stream<List<Group>> watchUserGroups(String userId) {
    return _groupsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();

            return Group.fromMap({...data, 'id': data['id'] ?? doc.id});
          }).toList();
        });
  }

  Future<void> createGroup({
    required String userId,
    required Group group,
  }) async {
    final docRef = _groupsCollection.doc(group.id);

    await docRef.set(group.toMap(userId: userId));
  }

  Future<void> updateGroup({
    required String userId,
    required Group group,
  }) async {
    final docRef = _groupsCollection.doc(group.id);

    await docRef.update(group.toMap(userId: userId));
  }

  Future<void> deleteGroup(String groupId) async {
    await _groupsCollection.doc(groupId).delete();
  }

  Future<void> saveGroup({required String userId, required Group group}) async {
    final docRef = _groupsCollection.doc(group.id);

    await docRef.set(group.toMap(userId: userId), SetOptions(merge: true));
  }
}
