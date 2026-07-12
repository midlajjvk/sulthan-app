import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/collection_model.dart';
import '../../services/firebase/firebase_service.dart';

/// Repository for the `collections` Firestore collection.
/// This is now the ONLY data layer for collections — Drift has been removed.
class CollectionRepository {
  final FirebaseService _service;

  CollectionRepository({FirebaseService? service})
      : _service = service ?? FirebaseService();

  CollectionReference<Map<String, dynamic>> get _col =>
      _service.firestore.collection('collections');

  // ── Write operations ───────────────────────────────────────────────────────

  Future<String> addCollection(CollectionModel col) async {
    try {
      if (col.id.isEmpty) {
        final ref = await _col.add(col.toFirestore());
        return ref.id;
      } else {
        await _col.doc(col.id).set(col.toFirestore());
        return col.id;
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

  // ── Read operations ────────────────────────────────────────────────────────

  Future<CollectionModel?> getCollectionById(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists) return null;
      return CollectionModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception('getCollectionById failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getCollectionById failed: $e');
    }
  }

  Future<List<CollectionModel>> getCollections() async {
    try {
      final snapshot =
          await _col.orderBy('dateCreated', descending: true).get();
      return snapshot.docs
          .map((doc) => CollectionModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('getCollections failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getCollections failed: $e');
    }
  }

  Future<CollectionModel?> getMonthlyCollection(int month, int year) async {
    try {
      final snapshot = await _col
          .where('type', isEqualTo: 'MONTHLY')
          .where('month', isEqualTo: month)
          .where('year', isEqualTo: year)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      return CollectionModel.fromFirestore(snapshot.docs.first);
    } on FirebaseException catch (e) {
      throw Exception(
          'getMonthlyCollection failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getMonthlyCollection failed: $e');
    }
  }

  Stream<List<CollectionModel>> watchCollections() {
    try {
      return _col
          .orderBy('dateCreated', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => CollectionModel.fromFirestore(doc))
              .toList())
          .handleError((Object error) {
        if (error is FirebaseException) {
          throw Exception(
              'watchCollections stream error [${error.code}]: ${error.message}');
        }
        throw Exception('watchCollections stream error: $error');
      });
    } on FirebaseException catch (e) {
      throw Exception(
          'watchCollections setup failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('watchCollections setup failed: $e');
    }
  }
}
