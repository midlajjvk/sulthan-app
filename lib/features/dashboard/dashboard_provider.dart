import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/payment_model.dart';
import '../../models/expense_model.dart';
import '../../shared/providers/core_providers.dart';

class DashboardData {
  final double balance;
  final double totalIncome;
  final double totalExpenses;
  final double monthlyTotal;
  final double eventTotal;
  final int pendingMonthly;
  final int memberCount;
  final List<PaymentModel> recentPayments;
  final List<ExpenseModel> recentExpenses;

  const DashboardData({
    required this.balance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.monthlyTotal,
    required this.eventTotal,
    required this.pendingMonthly,
    required this.memberCount,
    required this.recentPayments,
    required this.recentExpenses,
  });
}

final dashboardProvider =
    FutureProvider.autoDispose<DashboardData>((ref) async {
  final memberRepo = ref.watch(memberRepositoryProvider);
  final collectionRepo = ref.watch(collectionRepositoryProvider);
  final paymentRepo = ref.watch(paymentRepositoryProvider);
  final expenseRepo = ref.watch(expenseRepositoryProvider);

  // Load collections to split into monthly / event buckets
  final allCollections = await collectionRepo.getCollections();
  final monthlyIds = allCollections
      .where((c) => c.type == 'MONTHLY')
      .map((c) => c.id)
      .toList();
  final eventIds = allCollections
      .where((c) => c.type == 'EVENT')
      .map((c) => c.id)
      .toList();

  final income = await paymentRepo.getTotalIncome();
  final expenses = await expenseRepo.getTotalExpenses();
  final monthly = await paymentRepo.getMonthlyCollectionTotal(monthlyIds);
  final event = await paymentRepo.getEventCollectionTotal(eventIds);
  final pending = await paymentRepo.getPendingMonthlyCount(monthlyIds);
  final members = await memberRepo.getMemberCount();
  final recentPayments = await paymentRepo.getRecentPayments(limit: 10);
  final recentExpenses = await expenseRepo.getExpenses();

  return DashboardData(
    balance: income - expenses,
    totalIncome: income,
    totalExpenses: expenses,
    monthlyTotal: monthly,
    eventTotal: event,
    pendingMonthly: pending,
    memberCount: members,
    recentPayments: recentPayments,
    recentExpenses: recentExpenses.take(5).toList(),
  );
});
