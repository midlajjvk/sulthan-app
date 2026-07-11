import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/collection_model.dart';
import '../../services/firebase/firebase_service.dart';

class CollectionRepository {
  final FirebaseService _service;

  CollectionRepository({FirebaseService? service})
      : _service = service ?? FirebaseService();

  CollectionReference<Map<String, dynamic>> get _col =>
      _service.firestore.collection('collections');

  Future<void> addCollection(CollectionModel col) async {
    try {
      if (col.id.isEmpty) {
        await _col.add(col.toFirestore());
      } else {
        await _col.doc(col.id).set(col.toFirestore());
      }
    } on FirebaseException catch (e) {
      throw Exception('addCollection failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('addCollection failed: $e');
    }
  }

  Future<void> updateCollection(CollectionModel col) async {
    try {
      await _col.doc(col.id).update(col.toFirestore());
    } on FirebaseException catch (e) {
      throw Exception('updateCollection failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('updateCollection failed: $e');
    }
  }

  Future<void> deleteCollection(String id) async {
    try {
      await _col.doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception('deleteCollection failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('deleteCollection failed: $e');
    }
  }
}
