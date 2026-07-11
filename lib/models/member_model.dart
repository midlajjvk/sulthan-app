import 'package:cloud_firestore/cloud_firestore.dart';

/// Immutable representation of a member document stored in Firestore.
///
/// The class is intentionally decoupled from Drift — it has no dependency on
/// any local-database type.  The only external import is [cloud_firestore],
/// which is needed for [Timestamp] ↔ [DateTime] conversion and the
/// [DocumentSnapshot] factory.
///
/// Firestore document layout (collection: `members`):
/// ```
/// {
///   "name":           "Ali Hassan",
///   "mobile":         "9876543210",
///   "email":          "ali@example.com",       // nullable
///   "address":        "123 Main St",            // nullable
///   "dateOfBirth":    Timestamp,                // nullable
///   "bloodGroup":     "O+",                     // nullable
///   "photoUrl":       "https://...",            // nullable
///   "status":         "Active",                 // default "Active"
///   "additionalInfo": "...",                    // nullable
///   "createdAt":      Timestamp,                // nullable
///   "updatedAt":      Timestamp                 // nullable
/// }
/// ```
/// The document **id** is the Firestore document ID and is stored on the
/// model but never written back into the document body.
class MemberModel {
  // ── Fields ──────────────────────────────────────────────────────────────

  /// Firestore document ID.  Set from [DocumentSnapshot.id]; never persisted
  /// inside the document body (no `id` key in [toFirestore] / [toMap]).
  final String id;

  /// Full name of the member.  Required — must not be empty.
  final String name;

  /// Mobile number.  Required and unique across members.
  final String mobile;

  /// Optional email address.
  final String? email;

  /// Optional postal / home address.
  final String? address;

  /// Optional date of birth.
  final DateTime? dateOfBirth;

  /// Optional blood group, e.g. `'O+'`.  Valid values are defined in
  /// [AppConstants.bloodGroups].
  final String? bloodGroup;

  /// Optional URL of the member's profile photo stored in Firebase Storage.
  /// Note: the local-database layer uses `photoPath` (a device file path);
  /// this field stores a remote HTTPS URL.
  final String? photoUrl;

  /// Membership status.  Typically `'Active'` or `'Inactive'`.
  /// Defaults to `'Active'` when constructing a new member.
  final String status;

  /// Any extra free-form information about the member.
  final String? additionalInfo;

  /// When this document was first written to Firestore.
  final DateTime? createdAt;

  /// When this document was last updated in Firestore.
  final DateTime? updatedAt;

  // ── Constructor ─────────────────────────────────────────────────────────

  /// Creates an immutable [MemberModel].
  ///
  /// [status] defaults to `'Active'` so callers creating a new member only
  /// need to supply the required fields.
  const MemberModel({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    this.address,
    this.dateOfBirth,
    this.bloodGroup,
    this.photoUrl,
    this.status = 'Active',
    this.additionalInfo,
    this.createdAt,
    this.updatedAt,
  });

  // ── Factories ────────────────────────────────────────────────────────────

  /// Creates a [MemberModel] from a Firestore [DocumentSnapshot].
  ///
  /// Uses [DocumentSnapshot.id] as the model's [id] so the document ID is
  /// always in sync with the Firestore record.
  ///
  /// Timestamps stored in Firestore are converted to [DateTime] via
  /// [Timestamp.toDate].  The cast `as Map<String, dynamic>` is safe because
  /// Firestore always deserialises documents as that type.
  factory MemberModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MemberModel._fromMap(doc.id, data);
  }

  /// Creates a [MemberModel] from a plain [Map], with an explicit [id].
  ///
  /// Useful when:
  /// - the document data already arrived as a map (e.g. from a transaction),
  /// - writing unit tests without a real [DocumentSnapshot].
  ///
  /// [id] is passed separately because plain maps do not carry a document ID.
  factory MemberModel.fromMap(String id, Map<String, dynamic> map) {
    return MemberModel._fromMap(id, map);
  }

  /// Private shared parsing logic used by both public factories.
  ///
  /// All nullable fields use `as String?` / `as int?` casts (never `!`) so
  /// a missing key returns `null` rather than throwing.
  ///
  /// [Timestamp] fields are converted with [_tsToDateTime]; the helper
  /// returns `null` for any value that is not a [Timestamp], guarding against
  /// documents written with wrong types.
  factory MemberModel._fromMap(String id, Map<String, dynamic> map) {
    return MemberModel(
      id: id,
      name: map['name'] as String? ?? '',
      mobile: map['mobile'] as String? ?? '',
      email: map['email'] as String?,
      address: map['address'] as String?,
      dateOfBirth: _tsToDateTime(map['dateOfBirth']),
      bloodGroup: map['bloodGroup'] as String?,
      photoUrl: map['photoUrl'] as String?,
      status: map['status'] as String? ?? 'Active',
      additionalInfo: map['additionalInfo'] as String?,
      createdAt: _tsToDateTime(map['createdAt']),
      updatedAt: _tsToDateTime(map['updatedAt']),
    );
  }

  // ── Serialisers ──────────────────────────────────────────────────────────

  /// Serialises the model for writing to Firestore.
  ///
  /// Rules applied:
  /// - The document [id] is **omitted** — Firestore manages the ID separately.
  /// - `null` fields are written explicitly as `null` so Firestore clears the
  ///   field on updates (rather than leaving a stale value).
  /// - [DateTime] fields are converted to [Timestamp] via [_dateTimeToTs]
  ///   because Firestore's native timestamp type preserves timezone info and
  ///   enables server-side range queries.
  Map<String, dynamic> toFirestore() => {
        'name': name,
        'mobile': mobile,
        'email': email,
        'address': address,
        'dateOfBirth': _dateTimeToTs(dateOfBirth),
        'bloodGroup': bloodGroup,
        'photoUrl': photoUrl,
        'status': status,
        'additionalInfo': additionalInfo,
        'createdAt': _dateTimeToTs(createdAt),
        'updatedAt': _dateTimeToTs(updatedAt),
      };

  /// Serialises the model to a plain [Map], **including [id]**.
  ///
  /// Differs from [toFirestore] in two ways:
  /// 1. `id` is included because a plain map has no separate ID slot.
  /// 2. [DateTime] values are kept as [DateTime] (not [Timestamp]), making
  ///    this map suitable for local processing, caching, or unit tests that
  ///    should not depend on the Firestore SDK.
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'mobile': mobile,
        'email': email,
        'address': address,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'bloodGroup': bloodGroup,
        'photoUrl': photoUrl,
        'status': status,
        'additionalInfo': additionalInfo,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  // ── copyWith ─────────────────────────────────────────────────────────────

  /// Returns a new [MemberModel] with selected fields replaced.
  ///
  /// Because all fields are nullable in the orignal model, a sentinel object
  /// pattern is used for fields that are *themselves* nullable
  /// (e.g. [email], [photoUrl]).  Passing `email: null` explicitly clears the
  /// field; omitting `email` preserves the existing value.
  ///
  /// Non-nullable fields ([id], [name], [mobile], [status]) use the standard
  /// `?? this.field` fallback — omitting them keeps the current value.
  MemberModel copyWith({
    String? id,
    String? name,
    String? mobile,
    Object? email = _sentinel,
    Object? address = _sentinel,
    Object? dateOfBirth = _sentinel,
    Object? bloodGroup = _sentinel,
    Object? photoUrl = _sentinel,
    String? status,
    Object? additionalInfo = _sentinel,
    Object? createdAt = _sentinel,
    Object? updatedAt = _sentinel,
  }) {
    return MemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email == _sentinel ? this.email : email as String?,
      address: address == _sentinel ? this.address : address as String?,
      dateOfBirth: dateOfBirth == _sentinel
          ? this.dateOfBirth
          : dateOfBirth as DateTime?,
      bloodGroup:
          bloodGroup == _sentinel ? this.bloodGroup : bloodGroup as String?,
      photoUrl: photoUrl == _sentinel ? this.photoUrl : photoUrl as String?,
      status: status ?? this.status,
      additionalInfo: additionalInfo == _sentinel
          ? this.additionalInfo
          : additionalInfo as String?,
      createdAt:
          createdAt == _sentinel ? this.createdAt : createdAt as DateTime?,
      updatedAt:
          updatedAt == _sentinel ? this.updatedAt : updatedAt as DateTime?,
    );
  }

  // ── Equality & toString ──────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          mobile == other.mobile &&
          email == other.email &&
          address == other.address &&
          dateOfBirth == other.dateOfBirth &&
          bloodGroup == other.bloodGroup &&
          photoUrl == other.photoUrl &&
          status == other.status &&
          additionalInfo == other.additionalInfo &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        mobile,
        email,
        address,
        dateOfBirth,
        bloodGroup,
        photoUrl,
        status,
        additionalInfo,
        createdAt,
        updatedAt,
      );

  @override
  String toString() => 'MemberModel('
      'id: $id, '
      'name: $name, '
      'mobile: $mobile, '
      'status: $status'
      ')';

  // ── Private helpers ──────────────────────────────────────────────────────

  /// Converts a Firestore [Timestamp] to a [DateTime].
  ///
  /// Returns `null` for any value that is not a [Timestamp] (including `null`
  /// itself), so callers never need to guard against wrong types in older
  /// documents.
  static DateTime? _tsToDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }

  /// Converts a [DateTime] to a Firestore [Timestamp].
  ///
  /// Returns `null` when [value] is `null`, which tells Firestore to store
  /// the field as `null` rather than omitting it entirely.
  static Timestamp? _dateTimeToTs(DateTime? value) {
    if (value == null) return null;
    return Timestamp.fromDate(value);
  }
}

/// Private sentinel used by [MemberModel.copyWith] to distinguish between
/// "caller passed null explicitly" and "caller omitted the argument".
///
/// This is a compile-time constant object that cannot be equal to any real
/// field value, so `field == _sentinel` is an unambiguous "not provided" check.
const Object _sentinel = Object();
