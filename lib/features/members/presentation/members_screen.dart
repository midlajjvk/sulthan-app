import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../members_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/member_pdf.dart';
import '../../../models/member_model.dart';
import '../../../shared/widgets/common_widgets.dart';

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final filtered = ref.watch(filteredMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name or mobile...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (v) =>
                  ref.read(memberSearchProvider.notifier).state = v,
            ),
          ),
        ),
        actions: [
          // ── Download full list as PDF ────────────────────────────────
          filtered.when(
            data: (members) =>
                _DownloadAllButton(members: members),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // ── Filter ──────────────────────────────────────────────────
          Consumer(builder: (ctx, ref, _) {
            final blood = ref.watch(memberFilterBloodProvider);
            final status = ref.watch(memberFilterStatusProvider);
            final isActive = blood != null || status != null;
            return IconButton(
              icon: Badge(
                isLabelVisible: isActive,
                child: const Icon(Icons.filter_list),
              ),
              tooltip: 'Filter',
              onPressed: () => _showFilterSheet(ctx, ref),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/members/add'),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Member'),
      ),
      body: filtered.when(
        data: (members) {
          if (members.isEmpty) {
            return EmptyView(
              icon: Icons.people_outlined,
              title: 'No members found',
              subtitle: 'Tap + to add the first member',
              action: FilledButton.icon(
                onPressed: () => context.go('/members/add'),
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Add Member'),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: members.length,
            itemBuilder: (ctx, i) {
              final m = members[i];
              return _MemberTile(
                member: m,
                isSelected: _selectedId == m.id,
                onTap: () => setState(() =>
                    _selectedId =
                        _selectedId == m.id ? null : m.id),
                onNavigate: () => context.go('/members/${m.id}'),
              );
            },
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(message: e.toString()),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _FilterSheet(ref: ref),
    );
  }
}

// ── Member tile ───────────────────────────────────────────────────────────────

class _MemberTile extends StatefulWidget {
  final MemberModel member;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onNavigate;

  const _MemberTile({
    required this.member,
    required this.isSelected,
    required this.onTap,
    required this.onNavigate,
  });

  @override
  State<_MemberTile> createState() => _MemberTileState();
}

class _MemberTileState extends State<_MemberTile> {
  bool _downloading = false;

  Future<void> _downloadSingle() async {
    setState(() => _downloading = true);
    try {
      await downloadSingleMemberPdf(widget.member);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final m = widget.member;
    final selected = widget.isSelected;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: selected
            ? Border.all(color: cs.primary, width: 1.5)
            : Border.all(color: Colors.transparent, width: 1.5),
        color: selected
            ? cs.primaryContainer.withValues(alpha: 0.3)
            : cs.surface,
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: selected ? 0.08 : 0.04),
            blurRadius: selected ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  selected ? cs.primary : cs.primaryContainer,
              child: Text(m.name[0].toUpperCase(),
                  style: TextStyle(
                      color: selected
                          ? cs.onPrimary
                          : cs.onPrimaryContainer,
                      fontWeight: FontWeight.bold)),
            ),
            title: Text(m.name,
                style:
                    const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Row(
              children: [
                Text(m.mobile,
                    style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant)),
                if (m.bloodGroup != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      m.bloodGroup!,
                      style: const TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatusBadge(m.status),
                const SizedBox(width: 4),
                Icon(
                  selected
                      ? Icons.expand_less
                      : Icons.chevron_right,
                  color: selected
                      ? cs.primary
                      : cs.onSurfaceVariant,
                ),
              ],
            ),
            onTap: widget.onTap,
          ),
          // Expanded actions row — only when selected
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: selected
                ? Padding(
                    padding:
                        const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onNavigate,
                            icon: const Icon(
                                Icons.visibility_outlined,
                                size: 16),
                            label: const Text('View Profile'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8),
                              side:
                                  BorderSide(color: cs.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _downloading
                              ? const Center(
                                  child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8),
                                  child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child:
                                          CircularProgressIndicator(
                                              strokeWidth: 2)),
                                ))
                              : FilledButton.icon(
                                  onPressed: _downloadSingle,
                                  icon: const Icon(
                                      Icons.download_outlined,
                                      size: 16),
                                  label:
                                      const Text('Download PDF'),
                                  style: FilledButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(
                                            vertical: 8),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ── Download all members button ───────────────────────────────────────────────

class _DownloadAllButton extends StatefulWidget {
  final List<MemberModel> members;
  const _DownloadAllButton({required this.members});

  @override
  State<_DownloadAllButton> createState() =>
      _DownloadAllButtonState();
}

class _DownloadAllButtonState extends State<_DownloadAllButton> {
  bool _loading = false;

  Future<void> _download() async {
    if (widget.members.isEmpty) return;
    setState(() => _loading = true);
    try {
      await downloadAllMembersPdf(widget.members);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Padding(
            padding: EdgeInsets.all(14),
            child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2)))
        : IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Download members list PDF',
            onPressed: widget.members.isEmpty ? null : _download,
          );
  }
}

// ── Filter bottom sheet ───────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final WidgetRef ref;
  const _FilterSheet({required this.ref});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _blood;
  late String? _status;

  @override
  void initState() {
    super.initState();
    _blood = widget.ref.read(memberFilterBloodProvider);
    _status = widget.ref.read(memberFilterStatusProvider);
  }

  void _apply() {
    widget.ref.read(memberFilterBloodProvider.notifier).state =
        _blood;
    widget.ref.read(memberFilterStatusProvider.notifier).state =
        _status;
    Navigator.of(context).pop();
  }

  void _clear() {
    setState(() {
      _blood = null;
      _status = null;
    });
    widget.ref.read(memberFilterBloodProvider.notifier).state = null;
    widget.ref.read(memberFilterStatusProvider.notifier).state = null;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasFilter = _blood != null || _status != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Filter Members',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
              ),
              if (hasFilter)
                TextButton(
                  onPressed: _clear,
                  child: const Text('Clear all'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Status',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Active', 'Inactive'].map((s) {
              final selected = _status == s;
              return FilterChip(
                label: Text(s),
                selected: selected,
                onSelected: (_) => setState(
                    () => _status = selected ? null : s),
                selectedColor: cs.primaryContainer,
                checkmarkColor: cs.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          Text('Blood Group',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: AppConstants.bloodGroups.map((b) {
              final selected = _blood == b;
              return FilterChip(
                label: Text(b,
                    style: TextStyle(
                        color: selected
                            ? cs.primary
                            : Colors.red.shade700,
                        fontWeight: FontWeight.w600)),
                selected: selected,
                onSelected: (_) => setState(
                    () => _blood = selected ? null : b),
                selectedColor:
                    Colors.red.withValues(alpha: 0.15),
                side: BorderSide(
                    color: selected
                        ? cs.primary
                        : Colors.red.withValues(alpha: 0.4)),
                checkmarkColor: cs.primary,
                backgroundColor:
                    Colors.red.withValues(alpha: 0.05),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _apply,
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
