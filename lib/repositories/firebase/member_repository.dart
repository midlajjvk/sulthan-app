import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/member_model.dart';
import '../../services/firebase/firebase_service.dart';

/// Repository that owns all Firestore reads and writes for the `members`
/// collection.  This is now the ONLY data layer for members — Drift has been
/// removed.
class MemberRepository {
  final FirebaseService _service;

  MemberRepository({FirebaseService? service})
      : _service = service ?? FirebaseService();

  CollectionReference<Map<String, dynamic>> get _col =>
      _service.firestore.collection('members');

  // ── Write operations ───────────────────────────────────────────────────────

  Future<void> addMember(MemberModel member) async {
    try {
      if (member.id.isEmpty) {
        await _col.add(member.toFirestore());
      } else {
        await _col.doc(member.id).set(member.toFirestore());
      }
    } on FirebaseException catch (e) {
      throw Exception('addMember failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('addMember failed: $e');
    }
  }

  Future<void> updateMember(MemberModel member) async {
    try {
      await _col.doc(member.id).update(member.toFirestore());
    } on FirebaseException catch (e) {
      throw Exception('updateMember failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('updateMember failed: $e');
    }
  }

  Future<void> deleteMember(String id) async {
    try {
      await _col.doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception('deleteMember failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('deleteMember failed: $e');
    }
  }

  // ── Read operations ────────────────────────────────────────────────────────

  Future<MemberModel?> getMember(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists) return null;
      return MemberModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception('getMember failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getMember failed: $e');
    }
  }

  Future<List<MemberModel>> getMembers() async {
    try {
      final snapshot = await _col.orderBy('name').get();
      return snapshot.docs
          .map((doc) => MemberModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('getMembers failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getMembers failed: $e');
    }
  }

  Future<List<MemberModel>> getActiveMembers() async {
    try {
      final snapshot = await _col
          .where('status', isEqualTo: 'Active')
          .orderBy('name')
          .get();
      return snapshot.docs
          .map((doc) => MemberModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('getActiveMembers failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getActiveMembers failed: $e');
    }
  }

  Future<MemberModel?> getMemberById(String id) async {
    return getMember(id);
  }

  Future<MemberModel?> getMemberByMobile(String mobile) async {
    try {
      final snapshot = await _col
          .where('mobile', isEqualTo: mobile)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      return MemberModel.fromFirestore(snapshot.docs.first);
    } on FirebaseException catch (e) {
      throw Exception('getMemberByMobile failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getMemberByMobile failed: $e');
    }
  }

  Future<bool> mobileExists(String mobile) async {
    try {
      final snapshot = await _col
          .where('mobile', isEqualTo: mobile)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      throw Exception('mobileExists failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('mobileExists failed: $e');
    }
  }

  Stream<List<MemberModel>> watchMembers() {
    try {
      return _col
          .orderBy('name')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => MemberModel.fromFirestore(doc))
              .toList())
          .handleError((Object error) {
        if (error is FirebaseException) {
          throw Exception(
              'watchMembers stream error [${error.code}]: ${error.message}');
        }
        throw Exception('watchMembers stream error: $error');
      });
    } on FirebaseException catch (e) {
      throw Exception('watchMembers setup failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('watchMembers setup failed: $e');
    }
  }

  Future<int> getMemberCount() async {
    try {
      final snapshot = await _col.count().get();
      return snapshot.count ?? 0;
    } on FirebaseException catch (e) {
      throw Exception('getMemberCount failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getMemberCount failed: $e');
    }
  }
}
