import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: _buildAppBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickActions(context),
        child: const Icon(Icons.add),
      ),
      body: async.when(
        data: (d) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              _BalanceHeroCard(balance: d.balance),
              const SizedBox(height: 20),
              _SummaryGrid(data: d),
              const SizedBox(height: 20),
              _PendingPaymentsCard(data: d),
              const SizedBox(height: 16),
            ],
          ),
        ),
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(dashboardProvider),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Image.asset(
            'assets/images/appbarimg.png',
            height: 70,
            fit: BoxFit.contain,
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Community Treasury &',
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.w400)),
                Text('Member Management',
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.w400)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push('/settings'),
        ),
      ],
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.person_add_outlined),
              title: const Text('Add Member'),
              onTap: () { Navigator.pop(ctx); ctx.go('/members/add'); },
            ),
            ListTile(
              leading: const Icon(Icons.add_card_outlined),
              title: const Text('New Collection'),
              onTap: () { Navigator.pop(ctx); ctx.go('/collections/add'); },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Add Expense'),
              onTap: () { Navigator.pop(ctx); ctx.go('/expenses/add'); },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Balance Hero Card ─────────────────────────────────────────────────────────

class _BalanceHeroCard extends StatelessWidget {
  final double balance;
  const _BalanceHeroCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: isPositive
              ? const [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)]
              : const [Color(0xFF7F0000), Color(0xFFC62828), Color(0xFFD32F2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isPositive ? const Color(0xFF2E7D32) : const Color(0xFFC62828))
                .withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background circles — right side
          Positioned(
            right: -30,
            top: -30,
            child: const _DecorativeCircle(size: 160, opacity: 0.12),
          ),
          Positioned(
            right: 40,
            bottom: -40,
            child: const _DecorativeCircle(size: 120, opacity: 0.08),
          ),
          Positioned(
            right: -10,
            top: 60,
            child: const _DecorativeCircle(size: 80, opacity: 0.10),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: glass wallet icon + safe badge
                Row(
                  children: [
                    _GlassIconContainer(
                      child: const Icon(Icons.account_balance_wallet_outlined,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text('Current Balance',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    const Spacer(),
                    _SafeBadge(),
                  ],
                ),
                const Spacer(),
                // Balance amount
                Text(
                  Fmt.money(balance.abs()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                // Status row
                Row(
                  children: [
                    Text(
                      isPositive ? 'Funds Available' : 'Deficit',
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 13),
                    ),
                    const SizedBox(width: 10),
                    if (isPositive) _StatusPill(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.08, duration: 500.ms, curve: Curves.easeOut);
  }
}

// ── Hero card sub-widgets ─────────────────────────────────────────────────────

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _DecorativeCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: opacity), width: 1.5),
        color: Colors.white.withValues(alpha: opacity * 0.3),
      ),
    );
  }
}

class _GlassIconContainer extends StatelessWidget {
  final Widget child;
  const _GlassIconContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
      ),
      child: Center(child: child),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 12),
          SizedBox(width: 4),
          Text('Up to date',
              style: TextStyle(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SafeBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, color: Colors.white60, size: 11),
          SizedBox(width: 4),
          Text('Safe & Secure',
              style: TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }
}

// ── Summary Grid ──────────────────────────────────────────────────────────────

/// 5-card grid:
///   Row 1: Income | Expenses | Balance
///   Row 2 (centred): Monthly Collections | Total Members
class _SummaryGrid extends StatelessWidget {
  final DashboardData data;
  const _SummaryGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final row1 = [
      _SummaryTile(
        label: 'Income',
        value: Fmt.money(data.totalIncome),
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF2E7D32),
        delay: 0,
      ),
      _SummaryTile(
        label: 'Expenses',
        value: Fmt.money(data.totalExpenses),
        icon: Icons.trending_down_rounded,
        color: cs.error,
        delay: 80,
      ),
      _SummaryTile(
        label: 'Balance',
        value: Fmt.money(data.balance),
        icon: Icons.account_balance_rounded,
        color: cs.primary,
        delay: 160,
      ),
    ];

    final row2 = [
      _SummaryTile(
        label: 'Monthly',
        value: Fmt.money(data.monthlyTotal),
        icon: Icons.calendar_month_rounded,
        color: const Color(0xFF6A1B9A),
        delay: 240,
      ),
      _SummaryTile(
        label: 'Members',
        value: '${data.memberCount}',
        icon: Icons.people_rounded,
        color: const Color(0xFF00695C),
        delay: 320,
      ),
    ];

    return Column(
      children: [
        // Row 1 — three equal cards
        IntrinsicHeight(
          child: Row(
            children: row1
                .map((t) => Expanded(child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: t,
                    )))
                .toList(),
          ),
        ),
        const SizedBox(height: 10),
        // Row 2 — two centred cards, each ~40% width
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row2
              .map((t) => SizedBox(
                    width: (MediaQuery.of(context).size.width - 32) * 0.40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: t,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final int delay;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: delay.ms, duration: 400.ms)
        .slideY(begin: 0.12, delay: delay.ms, duration: 400.ms, curve: Curves.easeOut);
  }
}

// ── Pending Payments Card ─────────────────────────────────────────────────────

class _PendingPaymentsCard extends StatelessWidget {
  final DashboardData data;
  const _PendingPaymentsCard({required this.data});

  static const int _previewCount = 4;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pending = data.pendingMembers;
    final hasMore = pending.length > _previewCount;
    final preview = pending.take(_previewCount).toList();
    final overflow = pending.skip(_previewCount).toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.withValues(alpha: 0.14),
                  ),
                  child: const Icon(Icons.pending_actions_rounded,
                      color: Colors.orange, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Monthly Payment Pending',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (pending.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${pending.length}',
                      style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Body
            if (pending.isEmpty)
              _PendingEmptyState(monthLabel: data.activeMonthLabel)
            else ...[
              ...preview.asMap().entries.map((e) => _PendingMemberRow(
                    info: e.value,
                    delay: e.key * 60,
                  )),
              if (hasMore) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor:
                          cs.primary.withValues(alpha: 0.08),
                      foregroundColor: cs.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    icon: const Icon(Icons.expand_more, size: 18),
                    label: Text('+${overflow.length} More'),
                    onPressed: () => _showAllPendingSheet(
                        context, pending),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 500.ms)
        .slideY(begin: 0.1, delay: 400.ms, duration: 500.ms, curve: Curves.easeOut);
  }

  void _showAllPendingSheet(
      BuildContext context, List<PendingMemberInfo> all) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _PendingBottomSheet(members: all),
    );
  }
}

// ── Pending card sub-widgets ──────────────────────────────────────────────────

class _PendingEmptyState extends StatelessWidget {
  final String monthLabel;
  const _PendingEmptyState({required this.monthLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF2E7D32), size: 36),
          const SizedBox(height: 10),
          Text(
            'Everyone has completed the\n$monthLabel monthly payment.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.w600,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingMemberRow extends StatelessWidget {
  final PendingMemberInfo info;
  final int delay;
  const _PendingMemberRow({required this.info, required this.delay});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          MemberAvatar(
            photoBytes: info.member.photo,
            name: info.member.name,
            radius: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info.member.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(
                  info.pendingMonths.join(', '),
                  style: TextStyle(
                      fontSize: 11, color: cs.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${info.pendingMonths.length} pending',
              style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 10,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delay.ms, duration: 350.ms)
        .slideX(begin: 0.05, delay: delay.ms, duration: 350.ms, curve: Curves.easeOut);
  }
}

// ── Pending bottom sheet ──────────────────────────────────────────────────────

class _PendingBottomSheet extends StatelessWidget {
  final List<PendingMemberInfo> members;
  const _PendingBottomSheet({required this.members});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          // Handle + title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange.withValues(alpha: 0.14),
                      ),
                      child: const Icon(Icons.pending_actions_rounded,
                          color: Colors.orange, size: 17),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'All Pending Members',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${members.length} members',
                        style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
              ],
            ),
          ),
          // Scrollable list
          Expanded(
            child: ListView.separated(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: members.length,
              separatorBuilder: (_, __) => Divider(
                color: cs.outlineVariant.withValues(alpha: 0.4),
                height: 1,
              ),
              itemBuilder: (ctx, i) {
                final info = members[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MemberAvatar(
                        photoBytes: info.member.photo,
                        name: info.member.name,
                        radius: 22,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              info.member.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pending:',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: info.pendingMonths
                                  .map((m) => Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: Colors.orange
                                                .withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Text(
                                          m,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.orange,
                                              fontWeight:
                                                  FontWeight.w600),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
