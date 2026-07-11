import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/payment_model.dart';
import '../../services/firebase/firebase_service.dart';

class PaymentRepository {
  final FirebaseService _service;

  PaymentRepository({FirebaseService? service})
      : _service = service ?? FirebaseService();

  CollectionReference<Map<String, dynamic>> get _col =>
      _service.firestore.collection('payments');

  Future<void> addPayment(PaymentModel payment) async {
    try {
      if (payment.id.isEmpty) {
        await _col.add(payment.toFirestore());
      } else {
        await _col.doc(payment.id).set(payment.toFirestore());
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
}
