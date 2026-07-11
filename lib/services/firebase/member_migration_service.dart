import 'dart:developer' as dev;

import '../../database/app_database.dart';
import '../../models/member_model.dart';
import '../../repositories/firebase/member_repository.dart';

/// One-time utility that copies every member row from the local Drift/SQLite
/// database into the Firestore `members` collection.
///
/// **When to run:**
/// Call [migrateMembers] once — typically from a dedicated settings screen
/// button or a hidden admin screen.  Running it more than once is safe because
/// duplicate detection (§ skip logic below) prevents any document from being
/// overwritten.
///
/// **What it does NOT do:**
/// - It does not modify any Drift table or local data.
/// - It does not upload photos — [Member.photoPath] is a local device path
///   that has no meaning in Firestore.  Photo upload belongs in a separate
///   storage migration step; [MemberModel.photoUrl] is left `null` here.
/// - It does not delete anything in Firestore.
/// - It does not touch Riverpod providers, UI, or navigation.
///
/// **ID strategy:**
/// The Drift `id` is an auto-increment `int`.  Firestore IDs are `String`.
/// This service converts Drift IDs with `.toString()` (e.g. Drift id `42`
/// becomes Firestore document ID `'42'`).  This preserves the relationship
/// between local rows and remote documents and makes the migration
/// re-runnable: if document `'42'` already exists in Firestore the row is
/// skipped without any write.
class MemberMigrationService {
  // ── Dependencies ──────────────────────────────────────────────────────────

  final AppDatabase _db;
  final MemberRepository _repo;

  /// Creates a [MemberMigrationService].
  ///
  /// Both parameters are required so callers always pass explicit instances.
  /// This matches how the service would be constructed in a settings screen or
  /// an admin utility — both objects are already available there via Riverpod
  /// providers or direct instantiation.
  MemberMigrationService({
    required AppDatabase db,
    required MemberRepository repo,
  })  : _db = db,
        _repo = repo;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Migrates all members from the local Drift database to Firestore.
  ///
  /// ### Steps
  /// 1. Fetch every [Member] row from Drift via [AppDatabase.getMembers].
  /// 2. For each row, check whether a Firestore document with the same ID
  ///    already exists ([MemberRepository.getMember]).
  /// 3. If the document **exists** → log a skip message and continue.
  /// 4. If the document **does not exist** → convert the row to a
  ///    [MemberModel] and upload it with [MemberRepository.addMember].
  /// 5. If any single member fails to upload, log the error and continue so
  ///    the remaining members are not blocked by one bad record.
  /// 6. Log a final summary (total / uploaded / skipped / failed counts).
  ///
  /// The method completes when every row has been processed.  It never throws;
  /// all errors are captured per-member so a single failure does not abort the
  /// entire migration.
  Future<void> migrateMembers() async {
    dev.log('▶ MemberMigration: starting…', name: 'MemberMigration');

    // ── Step 1: read all local members ──────────────────────────────────────
    late final List<Member> localMembers;
    try {
      localMembers = await _db.getMembers();
    } catch (e) {
      dev.log(
        '✗ MemberMigration: failed to read Drift members — $e',
        name: 'MemberMigration',
        error: e,
      );
      return; // Nothing to migrate; exit cleanly.
    }

    if (localMembers.isEmpty) {
      dev.log(
        '✓ MemberMigration: no local members found — nothing to migrate.',
        name: 'MemberMigration',
      );
      return;
    }

    dev.log(
      '  MemberMigration: ${localMembers.length} local member(s) found.',
      name: 'MemberMigration',
    );

    // ── Step 2-5: process each row ───────────────────────────────────────────
    int uploaded = 0;
    int skipped = 0;
    int failed = 0;

    for (final member in localMembers) {
      final firestoreId = member.id.toString();

      try {
        // ── Step 2: duplicate check ──────────────────────────────────────────
        final existing = await _repo.getMember(firestoreId);

        if (existing != null) {
          // ── Step 3: skip ───────────────────────────────────────────────────
          dev.log(
            '  [skip]   id=$firestoreId  "${member.name}" already in Firestore.',
            name: 'MemberMigration',
          );
          skipped++;
          continue;
        }

        // ── Step 4: convert and upload ───────────────────────────────────────
        final model = _toModel(member);
        await _repo.addMember(model);

        dev.log(
          '  [upload] id=$firestoreId  "${member.name}" → uploaded.',
          name: 'MemberMigration',
        );
        uploaded++;
      } catch (e) {
        // ── Step 5: per-member error ─────────────────────────────────────────
        dev.log(
          '  [error]  id=$firestoreId  "${member.name}" failed — $e',
          name: 'MemberMigration',
          error: e,
        );
        failed++;
        // Continue — do not rethrow; remaining members must still be processed.
      }
    }

    // ── Step 6: summary ──────────────────────────────────────────────────────
    dev.log(
      '✓ MemberMigration: complete. '
      'total=${localMembers.length}  '
      'uploaded=$uploaded  '
      'skipped=$skipped  '
      'failed=$failed',
      name: 'MemberMigration',
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Converts a Drift [Member] row to a [MemberModel] suitable for Firestore.
  ///
  /// Field mapping:
  /// | Drift field       | MemberModel field  | Notes                              |
  /// |-------------------|--------------------|------------------------------------|
  /// | `id` (int)        | `id` (String)      | `.toString()` conversion           |
  /// | `name`            | `name`             | direct copy                        |
  /// | `mobile`          | `mobile`           | direct copy                        |
  /// | `email`           | `email`            | nullable, direct copy              |
  /// | `address`         | `address`          | nullable, direct copy              |
  /// | `dateOfBirth`     | `dateOfBirth`      | nullable DateTime, direct copy     |
  /// | `bloodGroup`      | `bloodGroup`       | nullable, direct copy              |
  /// | `photoPath`       | `photoUrl`         | set to `null` — local path has no  |
  /// |                   |                    | meaning in Firestore; photo upload |
  /// |                   |                    | is a separate step                 |
  /// | `status`          | `status`           | direct copy                        |
  /// | `additionalInfo`  | `additionalInfo`   | nullable, direct copy              |
  /// | `createdAt`       | `createdAt`        | direct copy                        |
  /// | `updatedAt`       | `updatedAt`        | direct copy                        |
  MemberModel _toModel(Member m) {
    return MemberModel(
      // Drift id is int; Firestore id is String.
      // Using toString() preserves the numeric identity so re-runs can detect
      // duplicates reliably without a secondary lookup by mobile number.
      id: m.id.toString(),

      name: m.name,
      mobile: m.mobile,
      email: m.email,
      address: m.address,
      dateOfBirth: m.dateOfBirth,
      bloodGroup: m.bloodGroup,

      // photoPath is a local file-system path on the device; it cannot be
      // stored in Firestore as-is and the file is not uploaded here.
      // A dedicated storage migration step should upload the file to Firebase
      // Storage and then update this field with the resulting download URL.
      photoUrl: null,

      status: m.status,
      additionalInfo: m.additionalInfo,
      createdAt: m.createdAt,
      updatedAt: m.updatedAt,
    );
  }
}
