import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firestoreUserServiceProvider = Provider<FirestoreUserService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirestoreUserService(firestore);
});

class FirestoreUserService {
  FirestoreUserService(this._firestore);

  final FirebaseFirestore _firestore;

  Future<bool> userHasPin(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return false;
    final data = doc.data();
    if (data == null) return false;
    return (data['hasPin'] as bool?) ?? false;
  }
}

