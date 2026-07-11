import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/core_providers.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/report_pdf.dart';
import '../../../core/constants/app_constants.dart';

final _reportsProvider = FutureProvider.autoDispose<ReportData>((ref) async {
  final db = ref.read(dbProvider);
  final income = await db.getTotalIncome();
  final expenses = await db.getTotalExpenses();
  final monthly = await db.getMonthlyCollectionTotal();
  final event = await db.getEventCollectionTotal();
  final members = await db.getMemberCount();
  final pending = await db.getPendingMonthlyCount();
  final allExpenses = await db.getExpenses();
  final allPayments = await db.getAllPayments();
  final collections = await db.getCollections();

  final catMap = <String, double>{};
  for (final e in allExpenses) {
    catMap[e.category] = (catMap[e.category] ?? 0) + e.amount;
  }

  return ReportData(
    totalIncome: income,
    totalExpenses: expenses,
    balance: income - expenses,
    monthlyTotal: monthly,
    eventTotal: event,
    memberCount: members,
    pendingCount: pending,
    expenseByCategory: catMap,
    totalCollections: collections.length,
    paidPayments: allPayments.where((p) => p.status == AppConstants.statusPaid).length,
    partialPayments: allPayments.where((p) => p.status == AppConstants.statusPartial).length,
    pendingPayments: allPayments.where((p) => p.status == AppConstants.statusPending).length,
  );
});

class ReportData {
  final double totalIncome, totalExpenses, balance, monthlyTotal, eventTotal;
  final int memberCount, pendingCount, totalCollections;
  final int paidPayments, partialPayments, pendingPayments;
  final Map<String, double> expenseByCategory;
  const ReportData({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.monthlyTotal,
    required this.eventTotal,
    required this.memberCount,
    required this.pendingCount,
    required this.expenseByCategory,
    required this.totalCollections,
    required this.paidPayments,
    required this.partialPayments,
    required this.pendingPayments,
  });
}

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_reportsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          // ── Download PDF ───────────────────────────────────────────────
          async.when(
            data: (d) => _DownloadButton(reportData: d),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(_reportsProvider),
          ),
        ],
      ),
      body: async.when(
        data: (d) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // Balance overview
            Container(
              padding: const EdgeInsets.all(20),
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
                  Text('Net Balance',
                      style: TextStyle(color: cs.onPrimary.withValues(alpha: 0.8), fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(Fmt.money(d.balance),
                      style: TextStyle(
                          color: cs.onPrimary, fontSize: 30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                      child: _BalanceStat(
                          label: 'Income', value: Fmt.money(d.totalIncome), color: cs.onPrimary),
                    ),
                    Container(width: 1, height: 32, color: cs.onPrimary.withValues(alpha: 0.3)),
                    Expanded(
                      child: _BalanceStat(
                          label: 'Expenses',
                          value: Fmt.money(d.totalExpenses),
                          color: cs.onPrimary),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Collection breakdown
            const SectionHeader('Collections'),
            _ReportCard(children: [
              _Row('Monthly Collections', Fmt.money(d.monthlyTotal), cs.primary),
              _Row('Event Collections', Fmt.money(d.eventTotal), Colors.purple),
              _Row('Total Collections', '${d.totalCollections}', cs.onSurface),
            ]),
            const SizedBox(height: 12),

            // Payment status
            const SectionHeader('Payment Status'),
            _ReportCard(children: [
              _Row('Paid', '${d.paidPayments}', Colors.green),
              _Row('Partial', '${d.partialPayments}', Colors.orange),
              _Row('Pending', '${d.pendingPayments}', cs.error),
            ]),
            const SizedBox(height: 12),

            // Members
            const SectionHeader('Members'),
            _ReportCard(children: [
              _Row('Total Members', '${d.memberCount}', cs.onSurface),
              _Row('Pending Monthly Dues', '${d.pendingCount}', cs.error),
            ]),
            const SizedBox(height: 12),

            // Expense by category
            if (d.expenseByCategory.isNotEmpty) ...[
              const SectionHeader('Expenses by Category'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: d.expenseByCategory.entries
                        .toList()
                        .sorted((a, b) => b.value.compareTo(a.value))
                        .map((entry) => _CategoryBar(
                              label: entry.key,
                              amount: entry.value,
                              total: d.totalExpenses,
                              cs: cs,
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(_reportsProvider)),
      ),
    );
  }
}

extension _ListSort<T> on List<T> {
  List<T> sorted(int Function(T, T) compare) => [...this]..sort(compare);
}

class _BalanceStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _BalanceStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      );
}

class _ReportCard extends StatelessWidget {
  final List<Widget> children;
  const _ReportCard({required this.children});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: children),
        ),
      );
}

class _Row extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Row(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(
            child: Text(label,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ]),
      );
}

class _CategoryBar extends StatelessWidget {
  final String label;
  final double amount, total;
  final ColorScheme cs;
  const _CategoryBar(
      {required this.label, required this.amount, required this.total, required this.cs});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? amount / total : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
            Text(Fmt.money(amount),
                style: TextStyle(fontWeight: FontWeight.bold, color: cs.error, fontSize: 13)),
          ]),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: pct,
            borderRadius: BorderRadius.circular(4),
            color: cs.error,
            backgroundColor: cs.errorContainer.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

// ── PDF download button ───────────────────────────────────────────────────────

class _DownloadButton extends StatefulWidget {
  final ReportData reportData;
  const _DownloadButton({required this.reportData});

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  bool _loading = false;

  Future<void> _download() async {
    setState(() => _loading = true);
    try {
      await downloadReportPdf(widget.reportData);
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
            tooltip: 'Download Report PDF',
            onPressed: _download,
          );
  }
}
