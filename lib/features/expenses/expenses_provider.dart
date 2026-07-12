import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/expense_model.dart';
import '../../shared/providers/core_providers.dart';

final expensesStreamProvider =
    StreamProvider.autoDispose<List<ExpenseModel>>((ref) =>
        ref.watch(expenseRepositoryProvider).watchExpenses());

final expenseSearchProvider =
    StateProvider.autoDispose<String>((_) => '');

final expenseCategoryFilterProvider =
    StateProvider.autoDispose<String?>((_) => null);

final filteredExpensesProvider =
    Provider.autoDispose<AsyncValue<List<ExpenseModel>>>((ref) {
  final all = ref.watch(expensesStreamProvider);
  final q = ref.watch(expenseSearchProvider).toLowerCase();
  final cat = ref.watch(expenseCategoryFilterProvider);

  return all.whenData((list) => list.where((e) {
        if (q.isNotEmpty && !e.purpose.toLowerCase().contains(q)) {
          return false;
        }
        if (cat != null && e.category != cat) return false;
        return true;
      }).toList());
});
