import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/expense_model.dart';
import '../../services/firebase/firebase_service.dart';

/// Repository for the `expenses` Firestore collection.
/// This is now the ONLY data layer for expenses — Drift has been removed.
class ExpenseRepository {
  final FirebaseService _service;

  ExpenseRepository({FirebaseService? service})
      : _service = service ?? FirebaseService();

  CollectionReference<Map<String, dynamic>> get _col =>
      _service.firestore.collection('expenses');

  // ── Write operations ───────────────────────────────────────────────────────

  Future<String> addExpense(ExpenseModel expense) async {
    try {
      if (expense.id.isEmpty) {
        final ref = await _col.add(expense.toFirestore());
        return ref.id;
      } else {
        await _col.doc(expense.id).set(expense.toFirestore());
        return expense.id;
      }
    } on FirebaseException catch (e) {
      throw Exception('addExpense failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('addExpense failed: $e');
    }
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await _col.doc(expense.id).set(expense.toFirestore());
    } on FirebaseException catch (e) {
      throw Exception('updateExpense failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('updateExpense failed: $e');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _col.doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception('deleteExpense failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('deleteExpense failed: $e');
    }
  }

  // ── Read operations ────────────────────────────────────────────────────────

  Future<ExpenseModel?> getExpenseById(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists) return null;
      return ExpenseModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception('getExpenseById failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getExpenseById failed: $e');
    }
  }

  Future<List<ExpenseModel>> getExpenses() async {
    try {
      final snapshot = await _col.orderBy('date', descending: true).get();
      return snapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('getExpenses failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getExpenses failed: $e');
    }
  }

  Stream<List<ExpenseModel>> watchExpenses() {
    try {
      return _col
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ExpenseModel.fromFirestore(doc))
              .toList())
          .handleError((Object error) {
        if (error is FirebaseException) {
          throw Exception(
              'watchExpenses stream error [${error.code}]: ${error.message}');
        }
        throw Exception('watchExpenses stream error: $error');
      });
    } on FirebaseException catch (e) {
      throw Exception('watchExpenses setup failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('watchExpenses setup failed: $e');
    }
  }

  // ── Aggregate ──────────────────────────────────────────────────────────────

  Future<double> getTotalExpenses() async {
    try {
      final snapshot = await _col.get();
      return snapshot.docs.fold<double>(0.0, (s, doc) {
        final amount = (doc.data()['amount'] as num?)?.toDouble() ?? 0.0;
        return s + amount;
      });
    } on FirebaseException catch (e) {
      throw Exception('getTotalExpenses failed [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('getTotalExpenses failed: $e');
    }
  }
}
