import 'package:cloud_firestore/cloud_firestore.dart';

class CollectionModel {
  final String id;
  final String title;
  final String type;
  final double amountPerMember;
  final String? description;
  final int? month;
  final int? year;
  final DateTime? dateCreated;

  const CollectionModel({
    required this.id,
    required this.title,
    required this.type,
    required this.amountPerMember,
    this.description,
    this.month,
    this.year,
    this.dateCreated,
  });

  factory CollectionModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CollectionModel(
      id: doc.id,
      title: d['title'] as String? ?? '',
      type: d['type'] as String? ?? '',
      amountPerMember: (d['amountPerMember'] as num?)?.toDouble() ?? 0.0,
      description: d['description'] as String?,
      month: d['month'] as int?,
      year: d['year'] as int?,
      dateCreated: _ts(d['dateCreated']),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'type': type,
        'amountPerMember': amountPerMember,
        'description': description,
        'month': month,
        'year': year,
        'dateCreated': dateCreated != null
            ? Timestamp.fromDate(dateCreated!)
            : null,
      };

  static DateTime? _ts(dynamic v) =>
      v is Timestamp ? v.toDate() : null;
}
