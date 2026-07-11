import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/member_model.dart';
import '../../services/firebase/firebase_service.dart';

/// Repository that owns all Firestore reads and writes for the `members`
/// collection.
///
/// Design rules enforced here:
/// - [FirebaseService] is injected; `FirebaseFirestore.instance` is never
///   called directly inside this file.
/// - All Firestore SDK types ([DocumentSnapshot], [QuerySnapshot], etc.) are
///   confined to this class — callers only see [MemberModel] and Dart
///   primitives.
/// - No Riverpod, no UI, no Drift references.
/// - Every public method wraps its Firestore call in a try/catch and rethrows
///   a descriptive [Exception] so callers receive a clear message instead of a
///   raw [FirebaseException].
class MemberRepository {
  // ── Dependencies ──────────────────────────────────────────────────────────

  final FirebaseService _service;

  /// Creates a [MemberRepository].
  ///
  /// [service] defaults to a fresh [FirebaseService] (which itself defaults to
  /// the SDK singletons), so production code can call
  /// `MemberRepository()` with no arguments.  Tests inject a fake service.
  MemberRepository({FirebaseService? service})
      : _service = service ?? FirebaseService();

  // ── Collection reference ──────────────────────────────────────────────────

  /// Typed reference to the `members` Firestore collection.
  ///
  /// Kept as a private getter so the collection name is defined exactly once.
  /// Using a getter (rather than a `late final` field) means the reference is
  /// re-derived from `_service.firestore` each call, which is harmless because
  /// [CollectionReference] is a lightweight value object.
  CollectionReference<Map<String, dynamic>> get _col =>
      _service.firestore.collection('members');

  // ── Write operations ──────────────────────────────────────────────────────

  /// Adds [member] as a new document in the `members` collection.
  ///
  /// Behaviour:
  /// - If [member.id] is empty, Firestore auto-generates a document ID.
  /// - If [member.id] is non-empty, the document is written at that exact ID
  ///   using [DocumentReference.set].  This is useful when the caller wants to
  ///   control the ID (e.g. mirroring a local SQLite row ID).
  ///
  /// In both cases [toFirestore] is called so the `id` field is never stored
  /// inside the document body.
  ///
  /// Throws an [Exception] on any Firestore error.
  Future<void> addMember(MemberModel member) async {
    try {
      if (member.id.isEmpty) {
        // Let Firestore create the document ID.
        await _col.add(member.toFirestore());
      } else {
        // Write at the caller-supplied ID; SetOptions.merge: false (default)
        // means the document is fully replaced if it already exists.
        await _col.doc(member.id).set(member.toFirestore());
      }
    } on FirebaseException catch (e) {
      throw Exception('addMember failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('addMember failed: $e');
    }
  }

  /// Replaces the Firestore document identified by [member.id] with the
  /// current field values.
  ///
  /// Uses [DocumentReference.update] rather than `set` so Firestore returns
  /// a `not-found` error if the document does not exist — callers can detect
  /// accidental updates to missing records.
  ///
  /// Only the fields returned by [MemberModel.toFirestore] are sent over the
  /// wire.  The document ID is never overwritten.
  ///
  /// Throws an [Exception] if the document is missing or on any Firestore
  /// error.
  Future<void> updateMember(MemberModel member) async {
    try {
      await _col.doc(member.id).update(member.toFirestore());
    } on FirebaseException catch (e) {
      throw Exception('updateMember failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('updateMember failed: $e');
    }
  }

  /// Permanently deletes the member document with the given [id].
  ///
  /// Firestore's `delete` is a no-op if the document does not exist, so this
  /// method succeeds silently for an unknown [id] — consistent with how other
  /// data stores handle idempotent deletes.
  ///
  /// Throws an [Exception] on any Firestore error.
  Future<void> deleteMember(String id) async {
    try {
      await _col.doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception('deleteMember failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('deleteMember failed: $e');
    }
  }

  // ── Read operations ───────────────────────────────────────────────────────

  /// Returns the member with the given [id], or `null` if no such document
  /// exists.
  ///
  /// A non-existent document does not throw; the caller decides how to handle
  /// the `null` result (show a "not found" message, redirect, etc.).
  ///
  /// Throws an [Exception] on network or permission errors.
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

  /// Returns a one-time snapshot of all members, ordered by name ascending.
  ///
  /// Use this when a live stream is not needed (e.g. building a PDF, running
  /// a migration, or populating a dropdown in a form).
  ///
  /// Throws an [Exception] on any Firestore error.
  Future<List<MemberModel>> getMembers() async {
    try {
      final snapshot =
          await _col.orderBy('name').get();
      return snapshot.docs
          .map((doc) => MemberModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('getMembers failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getMembers failed: $e');
    }
  }

  /// Returns a continuous [Stream] of all members, ordered by name ascending.
  ///
  /// The stream emits a fresh [List<MemberModel>] whenever any document in
  /// the collection is added, updated, or deleted — Firestore handles the
  /// diffing internally.
  ///
  /// Error handling:
  /// - [FirebaseException]s that occur *while setting up* the query (before
  ///   the first snapshot arrives) are caught and rethrown as [Exception].
  /// - Errors that arrive *on the stream* itself (e.g. a permission change
  ///   mid-session) are converted to stream error events via
  ///   `Stream.handleError` so the subscriber can react without crashing.
  ///
  /// The stream is not a broadcast stream — each new listener triggers its own
  /// Firestore listener and should be `.cancel()`-ed when no longer needed
  /// (Riverpod and StreamBuilder do this automatically).
  Stream<List<MemberModel>> watchMembers() {
    try {
      return _col
          .orderBy('name')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => MemberModel.fromFirestore(doc))
                .toList(),
          )
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

  // ── Business-rule helpers ─────────────────────────────────────────────────

  /// Returns `true` if a document with the given [mobile] number already
  /// exists in the collection.
  ///
  /// Used for uniqueness validation before inserting a new member.
  ///
  /// Implementation note: `limit(1)` is applied so Firestore reads at most
  /// one document even if duplicates somehow exist — this keeps the cost to a
  /// single document read regardless of collection size.
  ///
  /// Throws an [Exception] on any Firestore error.
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
}
