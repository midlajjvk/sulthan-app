import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/core_providers.dart';
import '../../../core/constants/app_constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionTitle('Appearance'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('System Default'),
                  secondary: const Icon(Icons.brightness_auto_outlined),
                  value: ThemeMode.system,
                  groupValue: themeMode,
                  onChanged: (v) => ref.read(themeModeProvider.notifier).set(v!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Light'),
                  secondary: const Icon(Icons.light_mode_outlined),
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  onChanged: (v) => ref.read(themeModeProvider.notifier).set(v!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark'),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  onChanged: (v) => ref.read(themeModeProvider.notifier).set(v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const _SectionTitle('About'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.account_balance, color: cs.primary),
                  title: const Text(AppConstants.appName),
                  subtitle: const Text('Community Treasury & Member Management'),
                ),
                const Divider(indent: 16, endIndent: 16, height: 1),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  trailing: Text('1.0.0'),
                ),
                const ListTile(
                  leading: Icon(Icons.currency_rupee),
                  title: Text('Monthly Collection Amount'),
                  trailing: Text('₹100'),
                ),
              ],
            ),
          ),
          // ── TEMPORARY: remove after migration ──────────────────────────
          const SizedBox(height: 8),
          const _SectionTitle('Migration (Temporary)'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: Icon(Icons.cloud_upload_outlined,
                  color: Theme.of(context).colorScheme.error),
              title: const Text('Migrate to Firestore'),
              subtitle: const Text('One-time data migration tool'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/migrate'),
            ),
          ),
          const SizedBox(height: 16),
          // ── END TEMPORARY ───────────────────────────────────────────────
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 16, 6),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
      );
}
