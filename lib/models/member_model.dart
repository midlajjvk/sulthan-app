import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Immutable representation of a member document stored in Firestore.
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
///   "photo":          Blob,                     // nullable — compressed JPEG bytes
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

  /// Firestore document ID.
  final String id;

  /// Full name of the member.
  final String name;

  /// Mobile number — required and unique.
  final String mobile;

  /// Optional email address.
  final String? email;

  /// Optional postal / home address.
  final String? address;

  /// Optional date of birth.
  final DateTime? dateOfBirth;

  /// Optional blood group, e.g. `'O+'`.
  final String? bloodGroup;

  /// Optional profile picture stored as compressed JPEG bytes.
  ///
  /// In Firestore this is persisted as a [Blob] so the bytes are stored
  /// natively (no Base64 overhead).  In Dart the value is a plain [Uint8List].
  /// Typically 30–80 KB after 256×256 resize at 80 % JPEG quality.
  final Uint8List? photo;

  /// Membership status — `'Active'` or `'Inactive'`.
  final String status;

  /// Any extra free-form information about the member.
  final String? additionalInfo;

  /// When this document was first written to Firestore.
  final DateTime? createdAt;

  /// When this document was last updated in Firestore.
  final DateTime? updatedAt;

  // ── Constructor ─────────────────────────────────────────────────────────

  const MemberModel({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    this.address,
    this.dateOfBirth,
    this.bloodGroup,
    this.photo,
    this.status = 'Active',
    this.additionalInfo,
    this.createdAt,
    this.updatedAt,
  });

  // ── Factories ────────────────────────────────────────────────────────────

  /// Creates a [MemberModel] from a Firestore [DocumentSnapshot].
  factory MemberModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MemberModel._fromMap(doc.id, data);
  }

  /// Creates a [MemberModel] from a plain [Map] with an explicit [id].
  factory MemberModel.fromMap(String id, Map<String, dynamic> map) {
    return MemberModel._fromMap(id, map);
  }

  /// Private shared parsing logic.
  ///
  /// The `photo` field is stored as a Firestore [Blob].  We read it back
  /// with `.bytes` to get the raw [Uint8List].  If the field is absent or
  /// has an unexpected type the member simply has no photo.
  factory MemberModel._fromMap(String id, Map<String, dynamic> map) {
    Uint8List? photoBytes;
    final rawPhoto = map['photo'];
    if (rawPhoto is Blob) {
      photoBytes = rawPhoto.bytes;
    }

    return MemberModel(
      id: id,
      name: map['name'] as String? ?? '',
      mobile: map['mobile'] as String? ?? '',
      email: map['email'] as String?,
      address: map['address'] as String?,
      dateOfBirth: _tsToDateTime(map['dateOfBirth']),
      bloodGroup: map['bloodGroup'] as String?,
      photo: photoBytes,
      status: map['status'] as String? ?? 'Active',
      additionalInfo: map['additionalInfo'] as String?,
      createdAt: _tsToDateTime(map['createdAt']),
      updatedAt: _tsToDateTime(map['updatedAt']),
    );
  }

  // ── Serialisers ──────────────────────────────────────────────────────────

  /// Serialises the model for writing to Firestore.
  ///
  /// [photo] bytes are wrapped in a Firestore [Blob] so they are stored as
  /// native binary data — smaller and faster than Base64 strings.
  Map<String, dynamic> toFirestore() => {
        'name': name,
        'mobile': mobile,
        'email': email,
        'address': address,
        'dateOfBirth': _dateTimeToTs(dateOfBirth),
        'bloodGroup': bloodGroup,
        'photo': photo != null ? Blob(photo!) : null,
        'status': status,
        'additionalInfo': additionalInfo,
        'createdAt': _dateTimeToTs(createdAt),
        'updatedAt': _dateTimeToTs(updatedAt),
      };

  /// Serialises to a plain [Map] **including [id]**.
  ///
  /// [photo] bytes are kept as [Uint8List] — suitable for local processing
  /// or unit tests that should not depend on the Firestore SDK.
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'mobile': mobile,
        'email': email,
        'address': address,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'bloodGroup': bloodGroup,
        'photo': photo,
        'status': status,
        'additionalInfo': additionalInfo,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  // ── copyWith ─────────────────────────────────────────────────────────────

  MemberModel copyWith({
    String? id,
    String? name,
    String? mobile,
    Object? email = _sentinel,
    Object? address = _sentinel,
    Object? dateOfBirth = _sentinel,
    Object? bloodGroup = _sentinel,
    Object? photo = _sentinel,
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
      photo: photo == _sentinel ? this.photo : photo as Uint8List?,
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
          // Byte-level equality: compare lengths first as a fast path.
          // Deep equality is intentionally skipped here to keep hashCode
          // consistent (two models with same id/name/mobile are "equal enough"
          // for provider deduplication; UI always re-renders on stream events).
          photo?.length == other.photo?.length &&
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
        photo?.length,
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
      'status: $status, '
      'hasPhoto: ${photo != null}'
      ')';

  // ── Private helpers ──────────────────────────────────────────────────────

  static DateTime? _tsToDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }

  static Timestamp? _dateTimeToTs(DateTime? value) {
    if (value == null) return null;
    return Timestamp.fromDate(value);
  }
}

/// Sentinel used by [MemberModel.copyWith] to distinguish between
/// "caller passed null explicitly" and "caller omitted the argument".
const Object _sentinel = Object();
