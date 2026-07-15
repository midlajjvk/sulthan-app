import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/member_model.dart';
import '../../shared/providers/core_providers.dart';

// ── Supporting types ───────────────────────────────────────────────────────────

/// One entry in the "Monthly Payment Pending" list.
///
/// [member] is the full member record (name, photo, etc.).
/// [pendingMonths] is the ordered list of human-readable month labels for
/// which a payment row exists with status == 'Pending', e.g.
/// ["July 2025", "August 2025"].
class PendingMemberInfo {
  final MemberModel member;
  final List<String> pendingMonths;

  const PendingMemberInfo({
    required this.member,
    required this.pendingMonths,
  });
}

// ── DashboardData ─────────────────────────────────────────────────────────────

/// All data the dashboard screen needs.  No Firestore / repository code lives
/// here — this is a pure data container.
class DashboardData {
  /// Current balance = totalIncome − totalExpenses.
  final double balance;

  /// Sum of all paid/partial payment amounts + fines.
  final double totalIncome;

  /// Sum of all expense amounts.
  final double totalExpenses;

  /// Sum of paid/partial amounts across MONTHLY collections.
  final double monthlyTotal;

  /// Total number of active members.
  final int memberCount;

  /// Members who have at least one Pending payment in a MONTHLY collection.
  /// Sorted alphabetically by member name.
  final List<PendingMemberInfo> pendingMembers;

  /// Human-readable label for the "active" month shown in the empty state,
  /// e.g. "August 2025".
  final String activeMonthLabel;

  const DashboardData({
    required this.balance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.monthlyTotal,
    required this.memberCount,
    required this.pendingMembers,
    required this.activeMonthLabel,
  });
}

// ── Active-month calculation ──────────────────────────────────────────────────

/// Determines the "active" collection month using the deadline rule:
///
///   • Day 1–4  → the current month is still open  (current month)
///   • Day 5+   → current month deadline has passed (next month is active)
///
/// Returns `(month, year)` as a record.
({int month, int year}) activeCollectionMonth([DateTime? now]) {
  final today = now ?? DateTime.now();
  if (today.day <= 4) {
    return (month: today.month, year: today.year);
  }
  // Advance to next month, rolling over December → January
  final nextMonth = today.month == 12 ? 1 : today.month + 1;
  final nextYear = today.month == 12 ? today.year + 1 : today.year;
  return (month: nextMonth, year: nextYear);
}

// ── Provider ──────────────────────────────────────────────────────────────────

final dashboardProvider =
    FutureProvider.autoDispose<DashboardData>((ref) async {
  final memberRepo = ref.watch(memberRepositoryProvider);
  final collectionRepo = ref.watch(collectionRepositoryProvider);
  final paymentRepo = ref.watch(paymentRepositoryProvider);
  final expenseRepo = ref.watch(expenseRepositoryProvider);

  // ── 1. Load all collections ──────────────────────────────────────────────
  final allCollections = await collectionRepo.getCollections();
  final monthlyCollections =
      allCollections.where((c) => c.type == 'MONTHLY').toList();
  final monthlyIds = monthlyCollections.map((c) => c.id).toList();

  // ── 2. Aggregate financials (parallel) ───────────────────────────────────
  final results = await Future.wait([
    paymentRepo.getTotalIncome(),
    expenseRepo.getTotalExpenses(),
    paymentRepo.getMonthlyCollectionTotal(monthlyIds),
    memberRepo.getMemberCount(),
  ]);

  final totalIncome = results[0] as double;
  final totalExpenses = results[1] as double;
  final monthlyTotal = results[2] as double;
  final memberCount = results[3] as int;

  // ── 3. Pending members ───────────────────────────────────────────────────
  //
  // getPendingMembersForCollections returns:
  //   memberId → ["July 2025", "August 2025", ...]
  //
  // We then fetch the MemberModel for each unique pending member ID.
  final pendingMap =
      await paymentRepo.getPendingMembersForCollections(monthlyCollections);

  final List<PendingMemberInfo> pendingMembers = [];
  for (final entry in pendingMap.entries) {
    final member = await memberRepo.getMemberById(entry.key);
    if (member == null) continue; // member may have been deleted
    // Only show active members
    if (member.status != 'Active') continue;
    pendingMembers.add(
      PendingMemberInfo(
        member: member,
        pendingMonths: List<String>.from(entry.value),
      ),
    );
  }

  // Sort alphabetically by name
  pendingMembers.sort((a, b) =>
      a.member.name.toLowerCase().compareTo(b.member.name.toLowerCase()));

  // ── 4. Active month label for empty state ────────────────────────────────
  final active = activeCollectionMonth();
  final activeMonthLabel =
      '${_monthName(active.month)} ${active.year}';

  return DashboardData(
    balance: totalIncome - totalExpenses,
    totalIncome: totalIncome,
    totalExpenses: totalExpenses,
    monthlyTotal: monthlyTotal,
    memberCount: memberCount,
    pendingMembers: pendingMembers,
    activeMonthLabel: activeMonthLabel,
  );
});

// ── Helper ────────────────────────────────────────────────────────────────────

String _monthName(int month) {
  const names = [
    '',
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return names[month.clamp(1, 12)];
}
