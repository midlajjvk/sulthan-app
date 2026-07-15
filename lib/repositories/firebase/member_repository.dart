import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../models/member_model.dart';
import '../../services/firebase/firebase_service.dart';

/// Repository that owns all Firestore reads and writes for the `members`
/// collection.
///
/// Image processing is performed here (not in the UI layer):
///   1. Resize to at most 256 × 256 px (aspect-preserving downscale).
///   2. Compress to JPEG at 80 % quality.
///   3. Resulting [Uint8List] is stored as a Firestore [Blob] inside the
///      member document — no Firebase Storage is used.
class MemberRepository {
  final FirebaseService _service;

  MemberRepository({FirebaseService? service})
      : _service = service ?? FirebaseService();

  CollectionReference<Map<String, dynamic>> get _col =>
      _service.firestore.collection('members');

  // ── Image processing ───────────────────────────────────────────────────────

  /// Resizes and compresses raw image bytes to a profile-picture-sized JPEG.
  ///
  /// ### How minWidth / minHeight work in flutter_image_compress
  /// Despite the parameter names, these are **maximum output dimensions**:
  /// the plugin scales the image down so that the longer side fits within the
  /// given box while preserving the aspect ratio.  It never upscales.
  /// Passing 256 × 256 means the output will be at most 256 px on either side.
  ///
  /// Target: ≤ 256 × 256 px, JPEG quality 80 → roughly 10–50 KB.
  /// Well within Firestore's 1 MiB document limit.
  Future<Uint8List> processImage(Uint8List rawBytes) async {
    developer.log(
      '[processImage] entered — rawBytes.length = ${rawBytes.length} bytes '
      '(${(rawBytes.length / 1024).toStringAsFixed(1)} KB)',
      name: 'MemberRepository',
    );

    try {
      developer.log(
        '[processImage] calling FlutterImageCompress.compressWithList …',
        name: 'MemberRepository',
      );

      final compressed = await FlutterImageCompress.compressWithList(
        rawBytes,
        minWidth: 256,
        minHeight: 256,
        quality: 80,
        format: CompressFormat.jpeg,
      );

      developer.log(
        '[processImage] compressWithList returned — '
        'compressed.length = ${compressed.length} bytes '
        '(${(compressed.length / 1024).toStringAsFixed(1)} KB)',
        name: 'MemberRepository',
      );

      if (compressed.isEmpty) {
        throw Exception(
          'compressWithList returned an empty list. '
          'rawBytes.length was ${rawBytes.length}.',
        );
      }

      return compressed;
    } catch (e, st) {
      developer.log(
        '[processImage] EXCEPTION: $e',
        name: 'MemberRepository',
        error: e,
        stackTrace: st,
      );
      // Re-throw the original exception with full detail so callers can
      // surface the real message instead of a generic fallback.
      rethrow;
    }
  }

  // ── Write operations ───────────────────────────────────────────────────────

  /// Saves a new member document to Firestore.
  ///
  /// If [member.id] is empty Firestore auto-generates the document ID.
  /// The [member.photo] bytes (if any) are already processed before this call
  /// and are written as a [Blob] by [MemberModel.toFirestore].
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

  /// Updates an existing member document in Firestore.
  ///
  /// All fields including [member.photo] (Blob) are overwritten.
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
