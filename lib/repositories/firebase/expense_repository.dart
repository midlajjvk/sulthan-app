import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/expense_model.dart';
import '../../services/firebase/firebase_service.dart';

class ExpenseRepository {
  final FirebaseService _service;

  ExpenseRepository({FirebaseService? service})
      : _service = service ?? FirebaseService();

  CollectionReference<Map<String, dynamic>> get _col =>
      _service.firestore.collection('expenses');

  Future<void> addExpense(ExpenseModel expense) async {
    try {
      if (expense.id.isEmpty) {
        await _col.add(expense.toFirestore());
      } else {
        await _col.doc(expense.id).set(expense.toFirestore());
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
}
