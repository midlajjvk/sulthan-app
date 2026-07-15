import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/collection_model.dart';
import '../../models/member_model.dart';
import '../../models/payment_model.dart';
import '../../services/firebase/firebase_service.dart';

/// Repository for the `payments` Firestore collection.
/// This is now the ONLY data layer for payments — Drift has been removed.
class PaymentRepository {
  final FirebaseService _service;

  PaymentRepository({FirebaseService? service})
      : _service = service ?? FirebaseService();

  CollectionReference<Map<String, dynamic>> get _col =>
      _service.firestore.collection('payments');

  // ── Write operations ───────────────────────────────────────────────────────

  Future<String> addPayment(PaymentModel payment) async {
    try {
      if (payment.id.isEmpty) {
        final ref = await _col.add(payment.toFirestore());
        return ref.id;
      } else {
        await _col.doc(payment.id).set(payment.toFirestore());
        return payment.id;
      }
    } on FirebaseException catch (e) {
      throw Exception('addPayment failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('addPayment failed: $e');
    }
  }

  Future<void> updatePayment(PaymentModel payment) async {
    try {
      await _col.doc(payment.id).set(payment.toFirestore());
    } on FirebaseException catch (e) {
      throw Exception('updatePayment failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('updatePayment failed: $e');
    }
  }

  Future<void> deletePayment(String id) async {
    try {
      await _col.doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception('deletePayment failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('deletePayment failed: $e');
    }
  }

  Future<void> deletePaymentsForCollection(String collectionId) async {
    try {
      final snap = await _col
          .where('collectionId', isEqualTo: collectionId)
          .get();
      final batch = _service.firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception(
          'deletePaymentsForCollection failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('deletePaymentsForCollection failed: $e');
    }
  }

  // ── Read operations ────────────────────────────────────────────────────────

  Future<List<PaymentModel>> getPaymentsForCollection(
      String collectionId) async {
    try {
      final snapshot = await _col
          .where('collectionId', isEqualTo: collectionId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => PaymentModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception(
          'getPaymentsForCollection failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getPaymentsForCollection failed: $e');
    }
  }

  Future<List<PaymentModel>> getPaymentsForMember(String memberId) async {
    try {
      final snapshot = await _col
          .where('memberId', isEqualTo: memberId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => PaymentModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception(
          'getPaymentsForMember failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getPaymentsForMember failed: $e');
    }
  }

  Future<PaymentModel?> getPaymentForMemberCollection(
      String memberId, String collectionId) async {
    try {
      final snapshot = await _col
          .where('memberId', isEqualTo: memberId)
          .where('collectionId', isEqualTo: collectionId)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      return PaymentModel.fromFirestore(snapshot.docs.first);
    } on FirebaseException catch (e) {
      throw Exception(
          'getPaymentForMemberCollection failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getPaymentForMemberCollection failed: $e');
    }
  }

  Future<List<PaymentModel>> getAdvancePaymentsForMember(
      String memberId) async {
    try {
      final snapshot = await _col
          .where('memberId', isEqualTo: memberId)
          .where('advanceStartMonth', isNull: false)
          .get();
      return snapshot.docs
          .map((doc) => PaymentModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception(
          'getAdvancePaymentsForMember failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getAdvancePaymentsForMember failed: $e');
    }
  }

  Future<PaymentModel?> findAdvanceCovering(
      String memberId, int month, int year) async {
    final advances = await getAdvancePaymentsForMember(memberId);
    final checkVal = year * 12 + month;
    for (final adv in advances) {
      if (adv.advanceStartMonth == null) continue;
      final startVal = adv.advanceStartYear! * 12 + adv.advanceStartMonth!;
      final endVal = adv.advanceEndYear! * 12 + adv.advanceEndMonth!;
      if (checkVal >= startVal && checkVal <= endVal) return adv;
    }
    return null;
  }

  Future<List<PaymentModel>> getAllPayments() async {
    try {
      final snapshot =
          await _col.orderBy('createdAt', descending: true).get();
      return snapshot.docs
          .map((doc) => PaymentModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('getAllPayments failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getAllPayments failed: $e');
    }
  }

  Future<List<PaymentModel>> getRecentPayments({int limit = 20}) async {
    try {
      final snapshot = await _col
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => PaymentModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('getRecentPayments failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getRecentPayments failed: $e');
    }
  }

  Stream<List<PaymentModel>> watchPaymentsForCollection(String collectionId) {
    try {
      return _col
          .where('collectionId', isEqualTo: collectionId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => PaymentModel.fromFirestore(doc))
              .toList())
          .handleError((Object error) {
        if (error is FirebaseException) {
          throw Exception(
              'watchPaymentsForCollection stream error [${error.code}]: ${error.message}');
        }
        throw Exception('watchPaymentsForCollection stream error: $error');
      });
    } on FirebaseException catch (e) {
      throw Exception(
          'watchPaymentsForCollection setup failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('watchPaymentsForCollection setup failed: $e');
    }
  }

  /// Ensures every active member has a payment row for the given collection.
  /// For monthly collections checks advance payments and auto-marks covered
  /// members as Paid instead of Pending.
  Future<void> ensurePaymentsForCollection(
    String collectionId,
    CollectionModel? col,
    List<MemberModel> activeMembers,
  ) async {
    final existing = await getPaymentsForCollection(collectionId);
    final existingMemberIds = existing.map((p) => p.memberId).toSet();
    final now = DateTime.now();

    for (final member in activeMembers) {
      if (existingMemberIds.contains(member.id)) continue;

      // For monthly collections check advance coverage
      if (col != null &&
          col.type == 'MONTHLY' &&
          col.month != null &&
          col.year != null) {
        final advance =
            await findAdvanceCovering(member.id, col.month!, col.year!);
        if (advance != null) {
          final endLabel =
              '${CollectionUtils.monthName(advance.advanceEndMonth!)} ${advance.advanceEndYear}';
          await addPayment(PaymentModel(
            id: '',
            memberId: member.id,
            collectionId: collectionId,
            paidAmount: col.amountPerMember,
            status: 'Paid',
            paymentDate: advance.paymentDate ?? now,
            notes: 'Advance payment (Paid until $endLabel)',
            createdAt: now,
          ));
          continue;
        }
      }

      // Default → Pending
      await addPayment(PaymentModel(
        id: '',
        memberId: member.id,
        collectionId: collectionId,
        paidAmount: 0.0,
        status: 'Pending',
        createdAt: now,
      ));
    }
  }

  // ── Aggregates ─────────────────────────────────────────────────────────────

  Future<double> getTotalIncome() async {
    try {
      final allPaid = await _col
          .where('status', whereIn: ['Paid', 'Partial']).get();
      return allPaid.docs.fold<double>(0.0, (s, doc) {
        final d = doc.data();
        final paid = (d['paidAmount'] as num?)?.toDouble() ?? 0.0;
        final fine = (d['fineAmount'] as num?)?.toDouble() ?? 0.0;
        return s + paid + fine;
      });
    } on FirebaseException catch (e) {
      throw Exception('getTotalIncome failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getTotalIncome failed: $e');
    }
  }

  Future<double> getMonthlyCollectionTotal(
      List<String> monthlyCollectionIds) async {
    if (monthlyCollectionIds.isEmpty) return 0.0;
    try {
      double total = 0.0;
      // Firestore whereIn supports max 30 items; chunk if needed
      for (var i = 0; i < monthlyCollectionIds.length; i += 30) {
        final chunk = monthlyCollectionIds.sublist(
            i,
            i + 30 > monthlyCollectionIds.length
                ? monthlyCollectionIds.length
                : i + 30);
        final snap = await _col
            .where('collectionId', whereIn: chunk)
            .where('status', whereIn: ['Paid', 'Partial']).get();
        total += snap.docs.fold<double>(0.0, (s, doc) {
          final d = doc.data();
          return s +
              ((d['paidAmount'] as num?)?.toDouble() ?? 0.0) +
              ((d['fineAmount'] as num?)?.toDouble() ?? 0.0);
        });
      }
      return total;
    } on FirebaseException catch (e) {
      throw Exception(
          'getMonthlyCollectionTotal failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getMonthlyCollectionTotal failed: $e');
    }
  }

  Future<double> getEventCollectionTotal(
      List<String> eventCollectionIds) async {
    if (eventCollectionIds.isEmpty) return 0.0;
    try {
      double total = 0.0;
      for (var i = 0; i < eventCollectionIds.length; i += 30) {
        final chunk = eventCollectionIds.sublist(
            i,
            i + 30 > eventCollectionIds.length
                ? eventCollectionIds.length
                : i + 30);
        final snap = await _col
            .where('collectionId', whereIn: chunk)
            .where('status', whereIn: ['Paid', 'Partial']).get();
        total += snap.docs.fold<double>(0.0, (s, doc) {
          final d = doc.data();
          return s +
              ((d['paidAmount'] as num?)?.toDouble() ?? 0.0) +
              ((d['fineAmount'] as num?)?.toDouble() ?? 0.0);
        });
      }
      return total;
    } on FirebaseException catch (e) {
      throw Exception(
          'getEventCollectionTotal failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getEventCollectionTotal failed: $e');
    }
  }

  Future<int> getPendingMonthlyCount(
      List<String> monthlyCollectionIds) async {
    if (monthlyCollectionIds.isEmpty) return 0;
    try {
      int count = 0;
      for (var i = 0; i < monthlyCollectionIds.length; i += 30) {
        final chunk = monthlyCollectionIds.sublist(
            i,
            i + 30 > monthlyCollectionIds.length
                ? monthlyCollectionIds.length
                : i + 30);
        final snap = await _col
            .where('collectionId', whereIn: chunk)
            .where('status', isEqualTo: 'Pending')
            .count()
            .get();
        count += snap.count ?? 0;
      }
      return count;
    } on FirebaseException catch (e) {
      throw Exception(
          'getPendingMonthlyCount failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getPendingMonthlyCount failed: $e');
    }
  }

  /// Returns a map of **memberId → list of pending month labels** for all
  /// MONTHLY collections.
  ///
  /// Only payments with `status == 'Pending'` are included.  Each label is
  /// the human-readable month+year string of the collection (e.g. "July 2025").
  ///
  /// The [monthlyCollections] list must contain the full [CollectionModel]
  /// objects (not just IDs) so that month/year labels can be resolved without
  /// additional Firestore reads.
  Future<Map<String, List<String>>> getPendingMembersForCollections(
    List<CollectionModel> monthlyCollections,
  ) async {
    if (monthlyCollections.isEmpty) return {};

    // Build a quick id→collection lookup for label resolution
    final colById = {for (final c in monthlyCollections) c.id: c};
    final allIds = colById.keys.toList();

    final result = <String, List<String>>{};

    try {
      // Firestore whereIn supports max 30 items; chunk if needed
      for (var i = 0; i < allIds.length; i += 30) {
        final chunk = allIds.sublist(
          i,
          (i + 30) > allIds.length ? allIds.length : i + 30,
        );
        final snap = await _col
            .where('collectionId', whereIn: chunk)
            .where('status', isEqualTo: 'Pending')
            .get();

        for (final doc in snap.docs) {
          final d = doc.data();
          final memberId = d['memberId'] as String? ?? '';
          final collectionId = d['collectionId'] as String? ?? '';
          if (memberId.isEmpty) continue;

          final col = colById[collectionId];
          final label = (col?.month != null && col?.year != null)
              ? '${CollectionUtils.monthName(col!.month!)} ${col.year}'
              : 'Unknown';

          result.putIfAbsent(memberId, () => []).add(label);
        }
      }
      return result;
    } on FirebaseException catch (e) {
      throw Exception(
          'getPendingMembersForCollections failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getPendingMembersForCollections failed: $e');
    }
  }

  /// Saves an advance payment.
  /// [paymentId] is the existing Firestore document ID to update.
  Future<void> saveAdvancePayment({
    required String paymentId,
    required String memberId,
    required String collectionId,
    required int startMonth,
    required int startYear,
    required double paidAmount,
    required double amountPerMonth,
    required DateTime paymentDate,
  }) async {
    final range = CollectionUtils.calcAdvanceRange(
      startMonth: startMonth,
      startYear: startYear,
      paidAmount: paidAmount,
      amountPerMonth: amountPerMonth,
    );

    final endLabel =
        '${CollectionUtils.monthName(range.endMonth)} ${range.endYear}';

    final model = PaymentModel(
      id: paymentId,
      memberId: memberId,
      collectionId: collectionId,
      paidAmount: paidAmount,
      status: 'Paid',
      paymentDate: paymentDate,
      advanceStartMonth: startMonth,
      advanceStartYear: startYear,
      advanceEndMonth: range.endMonth,
      advanceEndYear: range.endYear,
      notes: 'Advance payment (Paid until $endLabel)',
    );
    await updatePayment(model);
  }
}

// ── Shared utility methods (previously on AppDatabase) ────────────────────────

/// Static utilities previously hosted on AppDatabase, moved here so the rest
/// of the app (screens, PDF utils) can access them without importing Drift.
class CollectionUtils {
  CollectionUtils._();

  static String monthName(int month) {
    const names = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month];
  }

  /// Calculates how many months [paidAmount] covers starting from
  /// ([startMonth], [startYear]) given [amountPerMonth].
  static ({int months, int endMonth, int endYear}) calcAdvanceRange({
    required int startMonth,
    required int startYear,
    required double paidAmount,
    required double amountPerMonth,
  }) {
    final months =
        (paidAmount / amountPerMonth).floor().clamp(1, 999);
    int endMonth = startMonth + months - 1;
    int endYear = startYear;
    while (endMonth > 12) {
      endMonth -= 12;
      endYear++;
    }
    return (months: months, endMonth: endMonth, endYear: endYear);
  }
}
