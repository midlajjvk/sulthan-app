import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String memberId;
  final String collectionId;
  final double paidAmount;
  final DateTime? paymentDate;
  final String status;
  final String? notes;
  final int? advanceStartMonth;
  final int? advanceStartYear;
  final int? advanceEndMonth;
  final int? advanceEndYear;
  final double? fineAmount;
  final DateTime? createdAt;

  const PaymentModel({
    required this.id,
    required this.memberId,
    required this.collectionId,
    required this.paidAmount,
    required this.status,
    this.paymentDate,
    this.notes,
    this.advanceStartMonth,
    this.advanceStartYear,
    this.advanceEndMonth,
    this.advanceEndYear,
    this.fineAmount,
    this.createdAt,
  });

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PaymentModel(
      id: doc.id,
      memberId: d['memberId'] as String? ?? '',
      collectionId: d['collectionId'] as String? ?? '',
      paidAmount: (d['paidAmount'] as num?)?.toDouble() ?? 0.0,
      status: d['status'] as String? ?? 'Pending',
      paymentDate: _ts(d['paymentDate']),
      notes: d['notes'] as String?,
      advanceStartMonth: d['advanceStartMonth'] as int?,
      advanceStartYear: d['advanceStartYear'] as int?,
      advanceEndMonth: d['advanceEndMonth'] as int?,
      advanceEndYear: d['advanceEndYear'] as int?,
      fineAmount: (d['fineAmount'] as num?)?.toDouble(),
      createdAt: _ts(d['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'memberId': memberId,
        'collectionId': collectionId,
        'paidAmount': paidAmount,
        'status': status,
        'paymentDate': paymentDate != null
            ? Timestamp.fromDate(paymentDate!)
            : null,
        'notes': notes,
        'advanceStartMonth': advanceStartMonth,
        'advanceStartYear': advanceStartYear,
        'advanceEndMonth': advanceEndMonth,
        'advanceEndYear': advanceEndYear,
        'fineAmount': fineAmount,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : null,
      };

  static DateTime? _ts(dynamic v) =>
      v is Timestamp ? v.toDate() : null;
}
