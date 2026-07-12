import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../dashboard_provider.dart';
import '../../../shared/providers/core_providers.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/payment_model.dart';
import '../../../models/expense_model.dart';
import '../../../models/member_model.dart';
import '../../../models/collection_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
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
                  Text(
                    'Community Treasury &',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
                  ),
                  Text(
                    'Member Management',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
                  ),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickActions(context),
        child: const Icon(Icons.add),
      ),
      body: async.when(
        data: (d) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            children: [
              _BalanceHero(balance: d.balance, cs: cs),
              const SizedBox(height: 16),
              _StatsGrid(data: d, cs: cs),
              const SizedBox(height: 20),
              SectionHeader('Recent Transactions',
                  action: TextButton(
                    onPressed: () => context.go('/collections'),
                    child: const Text('View all'),
                  )),
              _RecentTransactions(
                  payments: d.recentPayments,
                  expenses: d.recentExpenses,
                  ref: ref),
            ],
          ),
        ),
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(dashboardProvider)),
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color:
                        Theme.of(ctx).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.person_add_outlined),
              title: const Text('Add Member'),
              onTap: () {
                Navigator.pop(ctx);
                ctx.go('/members/add');
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_card_outlined),
              title: const Text('New Collection'),
              onTap: () {
                Navigator.pop(ctx);
                ctx.go('/collections/add');
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Add Expense'),
              onTap: () {
                Navigator.pop(ctx);
                ctx.go('/expenses/add');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _BalanceHero extends StatelessWidget {
  final double balance;
  final ColorScheme cs;
  const _BalanceHero({required this.balance, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current Balance',
              style: TextStyle(
                  color: cs.onPrimary.withValues(alpha: 0.85),
                  fontSize: 14)),
          const SizedBox(height: 8),
          Text(Fmt.money(balance),
              style: TextStyle(
                  color: cs.onPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            balance >= 0 ? 'Funds available' : 'Deficit',
            style: TextStyle(
                color: cs.onPrimary.withValues(alpha: 0.7),
                fontSize: 12),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }
}

class _StatsGrid extends StatelessWidget {
  final DashboardData data;
  final ColorScheme cs;
  const _StatsGrid({required this.data, required this.cs});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cardW = (w - 32 - 12) / 2;

    final cards = [
      SummaryCard(
          label: 'Total Income',
          value: Fmt.money(data.totalIncome),
          icon: Icons.trending_up,
          color: Colors.green),
      SummaryCard(
          label: 'Total Expenses',
          value: Fmt.money(data.totalExpenses),
          icon: Icons.trending_down,
          color: cs.error),
      SummaryCard(
          label: 'Monthly Collections',
          value: Fmt.money(data.monthlyTotal),
          icon: Icons.calendar_month,
          color: cs.primary),
      SummaryCard(
          label: 'Event Collections',
          value: Fmt.money(data.eventTotal),
          icon: Icons.celebration_outlined,
          color: Colors.purple),
      SummaryCard(
          label: 'Pending Monthly',
          value: '${data.pendingMonthly}',
          icon: Icons.pending_actions,
          color: Colors.orange),
      SummaryCard(
          label: 'Total Members',
          value: '${data.memberCount}',
          icon: Icons.people,
          color: Colors.indigo),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          cards.map((c) => SizedBox(width: cardW, child: c)).toList(),
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  final List<PaymentModel> payments;
  final List<ExpenseModel> expenses;
  final WidgetRef ref;
  const _RecentTransactions(
      {required this.payments,
      required this.expenses,
      required this.ref});

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty && expenses.isEmpty) {
      return const EmptyView(
          icon: Icons.receipt_long_outlined,
          title: 'No transactions yet');
    }

    final memberRepo = ref.read(memberRepositoryProvider);
    final collectionRepo = ref.read(collectionRepositoryProvider);

    return FutureBuilder(
      future: _buildItems(memberRepo, collectionRepo),
      builder: (ctx, snap) {
        if (!snap.hasData) return const LoadingView();
        final list = snap.data!;
        return Column(
          children: list.map((item) => _TxTile(item: item)).toList(),
        );
      },
    );
  }

  Future<List<_TxItem>> _buildItems(
    dynamic memberRepo,
    dynamic collectionRepo,
  ) async {
    final items = <_TxItem>[];
    for (final p in payments) {
      if (p.status == AppConstants.statusPending) continue;
      MemberModel? member;
      CollectionModel? col;
      try {
        member = await memberRepo.getMemberById(p.memberId);
        col = await collectionRepo.getCollectionById(p.collectionId);
      } catch (_) {}
      items.add(_TxItem(
        isExpense: false,
        amount: p.paidAmount,
        label: member?.name ?? 'Member',
        sublabel: col?.title ?? 'Collection',
        date: p.paymentDate ?? p.createdAt ?? DateTime.now(),
      ));
    }
    for (final e in expenses) {
      items.add(_TxItem(
        isExpense: true,
        amount: e.amount,
        label: e.purpose,
        sublabel: e.category,
        date: e.date,
      ));
    }
    items.sort((a, b) => b.date.compareTo(a.date));
    return items.take(15).toList();
  }
}

class _TxItem {
  final bool isExpense;
  final double amount;
  final String label;
  final String sublabel;
  final DateTime date;
  const _TxItem(
      {required this.isExpense,
      required this.amount,
      required this.label,
      required this.sublabel,
      required this.date});
}

class _TxTile extends StatelessWidget {
  final _TxItem item;
  const _TxTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = item.isExpense ? cs.error : Colors.green;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
              item.isExpense
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: color,
              size: 16),
        ),
        title: Text(item.label,
            style: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Text(
            '${item.sublabel} • ${Fmt.short(item.date)}',
            style: TextStyle(
                fontSize: 11, color: cs.onSurfaceVariant)),
        trailing: Text(
          '${item.isExpense ? "-" : "+"}${Fmt.money(item.amount)}',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14),
        ),
      ),
    );
  }
}
