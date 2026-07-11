import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../core/constants/app_constants.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Members, Collections, Payments, Expenses])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(members, members.additionalInfo);
          }
          if (from < 3) {
            await m.addColumn(payments, payments.advanceStartMonth);
            await m.addColumn(payments, payments.advanceStartYear);
            await m.addColumn(payments, payments.advanceEndMonth);
            await m.addColumn(payments, payments.advanceEndYear);
          }
          if (from < 4) {
            await m.addColumn(payments, payments.fineAmount);
          }
        },
      );

  static QueryExecutor _openConnection() =>
      driftDatabase(name: AppConstants.dbName);

  // ── Members ───────────────────────────────────────────────────────────────
  Stream<List<Member>> watchMembers() =>
      (select(members)..orderBy([(m) => OrderingTerm.asc(m.name)])).watch();

  Future<List<Member>> getMembers() =>
      (select(members)..orderBy([(m) => OrderingTerm.asc(m.name)])).get();

  Future<List<Member>> getActiveMembers() =>
      (select(members)
            ..where((m) => m.status.equals('Active'))
            ..orderBy([(m) => OrderingTerm.asc(m.name)]))
          .get();

  Future<Member?> getMemberById(int id) =>
      (select(members)..where((m) => m.id.equals(id))).getSingleOrNull();

  Future<Member?> getMemberByMobile(String mobile) =>
      (select(members)..where((m) => m.mobile.equals(mobile))).getSingleOrNull();

  Future<int> insertMember(MembersCompanion data) => into(members).insert(data);

  Future<bool> updateMember(MembersCompanion data) =>
      update(members).replace(data);

  Future<int> deleteMember(int id) =>
      (delete(members)..where((m) => m.id.equals(id))).go();

  // ── Collections ───────────────────────────────────────────────────────────
  Stream<List<Collection>> watchCollections() =>
      (select(collections)
            ..orderBy([(c) => OrderingTerm.desc(c.dateCreated)]))
          .watch();

  Future<List<Collection>> getCollections() =>
      (select(collections)
            ..orderBy([(c) => OrderingTerm.desc(c.dateCreated)]))
          .get();

  Future<Collection?> getCollectionById(int id) =>
      (select(collections)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<Collection?> getMonthlyCollection(int month, int year) =>
      (select(collections)
            ..where((c) =>
                c.type.equals(AppConstants.typeMonthly) &
                c.month.equals(month) &
                c.year.equals(year)))
          .getSingleOrNull();

  Future<int> insertCollection(CollectionsCompanion data) =>
      into(collections).insert(data);

  Future<bool> updateCollection(CollectionsCompanion data) =>
      update(collections).replace(data);

  Future<int> deleteCollection(int id) =>
      (delete(collections)..where((c) => c.id.equals(id))).go();

  // ── Payments ──────────────────────────────────────────────────────────────
  Stream<List<Payment>> watchPaymentsForCollection(int collectionId) =>
      (select(payments)
            ..where((p) => p.collectionId.equals(collectionId))
            ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]))
          .watch();

  Future<List<Payment>> getPaymentsForCollection(int collectionId) =>
      (select(payments)
            ..where((p) => p.collectionId.equals(collectionId)))
          .get();

  Future<List<Payment>> getPaymentsForMember(int memberId) =>
      (select(payments)
            ..where((p) => p.memberId.equals(memberId))
            ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]))
          .get();

  Future<Payment?> getPaymentForMemberCollection(
          int memberId, int collectionId) =>
      (select(payments)
            ..where((p) =>
                p.memberId.equals(memberId) &
                p.collectionId.equals(collectionId)))
          .getSingleOrNull();

  /// Returns all advance payment records for a member (those with a range set).
  Future<List<Payment>> getAdvancePaymentsForMember(int memberId) =>
      (select(payments)
            ..where((p) =>
                p.memberId.equals(memberId) &
                p.advanceStartMonth.isNotNull()))
          .get();

  /// Checks if a member has an advance payment that covers (month, year).
  /// Returns the covering payment or null.
  Future<Payment?> findAdvanceCovering(
      int memberId, int month, int year) async {
    final advances = await getAdvancePaymentsForMember(memberId);
    for (final adv in advances) {
      if (adv.advanceStartMonth == null) continue;
      final startVal =
          adv.advanceStartYear! * 12 + adv.advanceStartMonth!;
      final endVal =
          adv.advanceEndYear! * 12 + adv.advanceEndMonth!;
      final checkVal = year * 12 + month;
      if (checkVal >= startVal && checkVal <= endVal) return adv;
    }
    return null;
  }

  Future<int> insertPayment(PaymentsCompanion data) =>
      into(payments).insert(data);

  /// Ensures every active member has a payment row for the given collection.
  /// For monthly collections, checks advance payments to auto-mark covered
  /// members as Paid instead of Pending.
  Future<void> ensurePaymentsForCollection(int collectionId) async {
    final col = await getCollectionById(collectionId);
    final allMembers = await getActiveMembers();
    final existing = await getPaymentsForCollection(collectionId);
    final existingMemberIds = existing.map((p) => p.memberId).toSet();

    for (final member in allMembers) {
      if (existingMemberIds.contains(member.id)) continue;

      // For monthly collections check advance coverage
      if (col != null &&
          col.type == AppConstants.typeMonthly &&
          col.month != null &&
          col.year != null) {
        final advance =
            await findAdvanceCovering(member.id, col.month!, col.year!);
        if (advance != null) {
          // Covered by advance — insert as Paid with indicator note
          final endLabel =
              '${monthName(advance.advanceEndMonth!)} ${advance.advanceEndYear}';
          await into(payments).insert(PaymentsCompanion.insert(
            memberId: member.id,
            collectionId: collectionId,
            status: const Value(AppConstants.statusPaid),
            paidAmount: Value(col.amountPerMember),
            paymentDate: Value(advance.paymentDate ?? DateTime.now()),
            notes: Value('Advance payment (Paid until $endLabel)'),
          ));
          continue;
        }
      }

      // Default → Pending
      await into(payments).insert(PaymentsCompanion.insert(
        memberId: member.id,
        collectionId: collectionId,
        status: const Value(AppConstants.statusPending),
        paidAmount: const Value(0.0),
      ));
    }
  }

  Future<bool> updatePayment(PaymentsCompanion data) async {
    final rowsAffected = await (update(payments)
          ..where((p) => p.id.equals(data.id.value)))
        .write(data);
    return rowsAffected > 0;
  }

  /// Saves an advance payment record.
  /// Calculates end month from paidAmount / amountPerMonth.
  /// Stores the range on the payment row of the current collection month.
  /// Does NOT create future collections.
  Future<void> saveAdvancePayment({
    required int paymentId,       // existing payment row id for this month
    required int memberId,
    required int startMonth,
    required int startYear,
    required double paidAmount,
    required double amountPerMonth,
    required DateTime paymentDate,
  }) async {
    final monthsCovered =
        (paidAmount / amountPerMonth).floor().clamp(1, 999);

    // Calculate end month/year
    int endMonth = startMonth + monthsCovered - 1;
    int endYear = startYear;
    while (endMonth > 12) {
      endMonth -= 12;
      endYear++;
    }

    final endLabel = '${monthName(endMonth)} $endYear';

    await (update(payments)..where((p) => p.id.equals(paymentId))).write(
      PaymentsCompanion(
        status: const Value(AppConstants.statusPaid),
        paidAmount: Value(paidAmount),
        paymentDate: Value(paymentDate),
        advanceStartMonth: Value(startMonth),
        advanceStartYear: Value(startYear),
        advanceEndMonth: Value(endMonth),
        advanceEndYear: Value(endYear),
        notes: Value('Advance payment (Paid until $endLabel)'),
      ),
    );
  }

  Future<int> deletePayment(int id) =>
      (delete(payments)..where((p) => p.id.equals(id))).go();

  Future<int> deletePaymentsForCollection(int collectionId) =>
      (delete(payments)..where((p) => p.collectionId.equals(collectionId)))
          .go();

  Future<List<Payment>> getAllPayments() =>
      (select(payments)
            ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]))
          .get();

  Future<List<Payment>> getRecentPayments({int limit = 20}) =>
      (select(payments)
            ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
            ..limit(limit))
          .get();

  // ── Expenses ──────────────────────────────────────────────────────────────
  Stream<List<Expense>> watchExpenses() =>
      (select(expenses)
            ..orderBy([(e) => OrderingTerm.desc(e.date)]))
          .watch();

  Future<List<Expense>> getExpenses() =>
      (select(expenses)..orderBy([(e) => OrderingTerm.desc(e.date)])).get();

  Future<int> insertExpense(ExpensesCompanion data) =>
      into(expenses).insert(data);

  Future<bool> updateExpense(ExpensesCompanion data) =>
      update(expenses).replace(data);

  Future<int> deleteExpense(int id) =>
      (delete(expenses)..where((e) => e.id.equals(id))).go();

  // ── Aggregates ────────────────────────────────────────────────────────────
  Future<double> getTotalIncome() async {
    final allPaid = await (select(payments)
          ..where((p) =>
              p.status.equals(AppConstants.statusPaid) |
              p.status.equals(AppConstants.statusPartial)))
        .get();
    return allPaid.fold<double>(
        0.0, (s, p) => s + p.paidAmount + (p.fineAmount ?? 0));
  }

  Future<double> getTotalExpenses() async {
    final result = await (selectOnly(expenses)
          ..addColumns([expenses.amount.sum()]))
        .getSingleOrNull();
    return result?.read(expenses.amount.sum()) ?? 0.0;
  }

  Future<double> getMonthlyCollectionTotal() async {
    final monthlyCols = await (select(collections)
          ..where((c) => c.type.equals(AppConstants.typeMonthly)))
        .get();
    if (monthlyCols.isEmpty) return 0.0;
    final ids = monthlyCols.map((c) => c.id).toSet();
    final paid = await (select(payments)
          ..where((p) =>
              p.collectionId.isIn(ids) &
              (p.status.equals(AppConstants.statusPaid) |
                  p.status.equals(AppConstants.statusPartial))))
        .get();
    return paid.fold<double>(0.0, (s, p) => s + p.paidAmount + (p.fineAmount ?? 0));
  }

  Future<double> getEventCollectionTotal() async {
    final eventCols = await (select(collections)
          ..where((c) => c.type.equals(AppConstants.typeEvent)))
        .get();
    if (eventCols.isEmpty) return 0.0;
    final ids = eventCols.map((c) => c.id).toSet();
    final paid = await (select(payments)
          ..where((p) =>
              p.collectionId.isIn(ids) &
              (p.status.equals(AppConstants.statusPaid) |
                  p.status.equals(AppConstants.statusPartial))))
        .get();
    return paid.fold<double>(0.0, (s, p) => s + p.paidAmount + (p.fineAmount ?? 0));
  }

  Future<int> getMemberCount() async {
    final result = await (selectOnly(members)
          ..addColumns([members.id.count()]))
        .getSingleOrNull();
    return result?.read(members.id.count()) ?? 0;
  }

  Future<int> getPendingMonthlyCount() async {
    final monthlyCols = await (select(collections)
          ..where((c) => c.type.equals(AppConstants.typeMonthly)))
        .get();
    if (monthlyCols.isEmpty) return 0;
    final ids = monthlyCols.map((c) => c.id).toList();
    final result = await (selectOnly(payments)
          ..addColumns([payments.id.count()])
          ..where(payments.collectionId.isIn(ids) &
              payments.status.equals(AppConstants.statusPending)))
        .getSingleOrNull();
    return result?.read(payments.id.count()) ?? 0;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  static String monthName(int month) {
    const names = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return names[month];
  }

  /// Calculates how many months paidAmount covers and returns end (month, year).
  static ({int months, int endMonth, int endYear}) calcAdvanceRange({
    required int startMonth,
    required int startYear,
    required double paidAmount,
    required double amountPerMonth,
  }) {
    final months = (paidAmount / amountPerMonth).floor().clamp(1, 999);
    int endMonth = startMonth + months - 1;
    int endYear = startYear;
    while (endMonth > 12) {
      endMonth -= 12;
      endYear++;
    }
    return (months: months, endMonth: endMonth, endYear: endYear);
  }
}
