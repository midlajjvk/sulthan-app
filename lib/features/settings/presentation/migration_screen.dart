// TEMPORARY — delete this file and its route/tile after migration is complete.
// See also:
//   lib/routes/app_router.dart          → '/settings/migrate' route
//   lib/features/settings/presentation/settings_screen.dart → 'Migration' tile

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../database/app_database.dart';
import '../../../repositories/firebase/member_repository.dart';
import '../../../services/firebase/member_migration_service.dart';
import '../../../shared/providers/core_providers.dart';

/// Temporary one-time screen for migrating local Drift data to Firestore.
///
/// Delete this screen (and its GoRoute + settings ListTile) once migration has
/// been run successfully on the production device.
class MigrationScreen extends ConsumerStatefulWidget {
  const MigrationScreen({super.key});

  @override
  ConsumerState<MigrationScreen> createState() => _MigrationScreenState();
}

class _MigrationScreenState extends ConsumerState<MigrationScreen> {
  // ── State ──────────────────────────────────────────────────────────────────

  /// `true` while [_runMigration] is executing.
  bool _isMigrating = false;

  // ── Migration logic ────────────────────────────────────────────────────────

  /// Runs the member migration and shows a SnackBar with the result.
  ///
  /// Guards against double-taps with the [_isMigrating] flag — the button is
  /// disabled and the indicator is shown while this method runs.
  Future<void> _runMigration() async {
    // Prevent concurrent invocations.
    if (_isMigrating) return;
    setState(() => _isMigrating = true);

    try {
      // Read the Drift database from the existing Riverpod provider so we
      // reuse the same AppDatabase instance the rest of the app uses.
      final AppDatabase db = ref.read(dbProvider);

      // MemberRepository constructs itself with the Firebase SDK singletons.
      // No Riverpod provider exists for it yet — constructing it directly is
      // intentional for a temporary migration utility.
      final repo = MemberRepository();

      final service = MemberMigrationService(db: db, repo: repo);
      await service.migrateMembers();

      // Guard: check the widget is still mounted before using BuildContext.
      if (!mounted) return;
      _showSnackBar('Migration completed ✓', isError: false);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Migration failed: $e', isError: true);
    } finally {
      // Always reset the loading state, even if an error occurred.
      if (mounted) setState(() => _isMigrating = false);
    }
  }

  /// Shows a [SnackBar] with [message].
  ///
  /// Error snackbars use the error colour and stay on screen for 6 seconds so
  /// the full message can be read.  Success snackbars use the primary colour
  /// and dismiss after 3 seconds.
  void _showSnackBar(String message, {required bool isError}) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? cs.error : cs.primary,
          duration: Duration(seconds: isError ? 6 : 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Migration')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Warning banner ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: cs.onErrorContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Temporary screen — delete after migration.\n'
                      'Run this once on the production device only.',
                      style: textTheme.bodyMedium
                          ?.copyWith(color: cs.onErrorContainer),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Description ──────────────────────────────────────────────────
            Text('Members Migration', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Copies every member from the local SQLite database to '
              'Firestore. Existing documents are skipped — safe to run '
              'more than once.',
              style: textTheme.bodyMedium
                  ?.copyWith(color: cs.onSurface.withValues(alpha: 0.7)),
            ),

            const SizedBox(height: 32),

            // ── Button / indicator ───────────────────────────────────────────
            if (_isMigrating)
              // Show a centred progress indicator while migration runs.
              // The button is replaced (not overlaid) to prevent taps.
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Migrating members…'),
                ],
              )
            else
              FilledButton.icon(
                onPressed: _runMigration,
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('Migrate Members to Firestore'),
              ),
          ],
        ),
      ),
    );
  }
}
