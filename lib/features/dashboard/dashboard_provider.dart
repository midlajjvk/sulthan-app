import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/app_database.dart';
import '../../shared/providers/core_providers.dart';

class DashboardData {
  final double balance;
  final double totalIncome;
  final double totalExpenses;
  final double monthlyTotal;
  final double eventTotal;
  final int pendingMonthly;
  final int memberCount;
  final List<Payment> recentPayments;
  final List<Expense> recentExpenses;

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

final dashboardProvider = FutureProvider.autoDispose<DashboardData>((ref) async {
  final db = ref.read(dbProvider);
  final income = await db.getTotalIncome();
  final expenses = await db.getTotalExpenses();
  final monthly = await db.getMonthlyCollectionTotal();
  final event = await db.getEventCollectionTotal();
  final pending = await db.getPendingMonthlyCount();
  final members = await db.getMemberCount();
  final recentPayments = await db.getRecentPayments(limit: 10);
  final recentExpenses = await db.getExpenses();

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
