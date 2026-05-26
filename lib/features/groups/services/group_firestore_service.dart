import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/group.dart';

/// Habla con Firestore para guardar y leer grupos.
/// El provider usa este servicio para no mezclar UI con base de datos.
class GroupFirestoreService {
  GroupFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _groupsCollection {
    return _firestore.collection('groups');
  }

  CollectionReference<Map<String, dynamic>> get _usersCollection {
    return _firestore.collection('users');
  }

  /// Escucha en tiempo real los grupos del usuario actual.
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

  /// Crea un documento nuevo para el grupo.
  Future<void> createGroup({
    required String userId,
    required Group group,
  }) async {
    final docRef = _groupsCollection.doc(group.id);

    await docRef.set(group.toMap(userId: userId));
  }

  /// Reemplaza los datos guardados de un grupo existente.
  Future<void> updateGroup({
    required String userId,
    required Group group,
  }) async {
    final docRef = _groupsCollection.doc(group.id);

    await docRef.update(group.toMap(userId: userId));
  }

  /// Borra el grupo indicado.
  Future<void> deleteGroup(String groupId) async {
    await _groupsCollection.doc(groupId).delete();
  }

  /// Guarda mezclando datos nuevos con los existentes.
  Future<void> saveGroup({required String userId, required Group group}) async {
    final docRef = _groupsCollection.doc(group.id);

    await docRef.set(group.toMap(userId: userId), SetOptions(merge: true));
  }

  /// Lee nombre/correo del usuario si Auth no los trae completos.
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _usersCollection.doc(userId).get();

    return doc.data();
  }
}
