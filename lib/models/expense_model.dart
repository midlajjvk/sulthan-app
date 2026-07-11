import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String purpose;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;
  final DateTime? createdAt;

  const ExpenseModel({
    required this.id,
    required this.purpose,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
    this.createdAt,
  });

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ExpenseModel(
      id: doc.id,
      purpose: d['purpose'] as String? ?? '',
      amount: (d['amount'] as num?)?.toDouble() ?? 0.0,
      category: d['category'] as String? ?? '',
      date: _ts(d['date']) ?? DateTime.now(),
      notes: d['notes'] as String?,
      createdAt: _ts(d['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'purpose': purpose,
        'amount': amount,
        'category': category,
        'date': Timestamp.fromDate(date),
        'notes': notes,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : null,
      };

  static DateTime? _ts(dynamic v) =>
      v is Timestamp ? v.toDate() : null;
}
