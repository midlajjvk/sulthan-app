import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../expenses_provider.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/expense_pdf.dart';
import '../../../core/constants/app_constants.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredExpensesProvider);
    final cs = Theme.of(context).colorScheme;
    final selectedCat = ref.watch(expenseCategoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (v) =>
                  ref.read(expenseSearchProvider.notifier).state = v,
            ),
          ),
        ),
        actions: [
          // ── PDF download ───────────────────────────────────────────────
          filtered.when(
            data: (expenses) => IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              tooltip: 'Download PDF',
              onPressed: expenses.isEmpty
                  ? null
                  : () => _downloadPdf(context, expenses),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // ── Category filter ────────────────────────────────────────────
          PopupMenuButton<String?>(
            icon: Icon(
              Icons.filter_list,
              color: selectedCat != null ? cs.primary : null,
            ),
            tooltip: 'Filter by category',
            onSelected: (v) =>
                ref.read(expenseCategoryFilterProvider.notifier).state = v,
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                  value: null, child: Text('All Categories')),
              ...AppConstants.expenseCategories.map(
                (c) => PopupMenuItem(value: c, child: Text(c)),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/expenses/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
      body: filtered.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return EmptyView(
              icon: Icons.receipt_long_outlined,
              title: 'No expenses found',
              subtitle: 'Tap + to record an expense',
              action: FilledButton.icon(
                onPressed: () => context.go('/expenses/add'),
                icon: const Icon(Icons.add),
                label: const Text('Add Expense'),
              ),
            );
          }

          final total = expenses.fold(0.0, (s, e) => s + e.amount);

          return Column(
            children: [
              // ── Total banner ─────────────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: cs.errorContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  Icon(Icons.summarize_outlined,
                      color: cs.error, size: 20),
                  const SizedBox(width: 8),
                  Text('Total: ',
                      style:
                          TextStyle(color: cs.onSurfaceVariant)),
                  Text(Fmt.money(total),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: cs.error,
                          fontSize: 16)),
                  const Spacer(),
                  // Inline download button in the banner too
                  _PdfButton(expenses: expenses),
                ]),
              ),
              // ── List ──────────────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: expenses.length,
                  itemBuilder: (ctx, i) {
                    final e = expenses[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cs.errorContainer
                                .withValues(alpha: 0.5),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.arrow_upward,
                              color: cs.error, size: 18),
                        ),
                        title: Text(e.purpose,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                        subtitle: Text(
                          '${e.category} • ${Fmt.date(e.date)}',
                          style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurfaceVariant),
                        ),
                        trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(Fmt.money(e.amount),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: cs.error,
                                      fontSize: 14)),
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right,
                                  color: cs.onSurfaceVariant),
                            ]),
                        onTap: () =>
                            context.push('/expenses/${e.id}/edit'),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(message: e.toString()),
      ),
    );
  }

  Future<void> _downloadPdf(
      BuildContext context, List expenses) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await downloadExpensesPdf(
          expenses.cast());
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to generate PDF: $e')),
      );
    }
  }
}

// ── Small inline PDF button ───────────────────────────────────────────────────

class _PdfButton extends StatefulWidget {
  final List expenses;
  const _PdfButton({required this.expenses});

  @override
  State<_PdfButton> createState() => _PdfButtonState();
}

class _PdfButtonState extends State<_PdfButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2))
        : TextButton.icon(
            onPressed: () => _generate(),
            icon: const Icon(Icons.download_outlined, size: 16),
            label: const Text('PDF', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
  }

  Future<void> _generate() async {
    setState(() => _loading = true);
    try {
      await downloadExpensesPdf(widget.expenses.cast());
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
}
