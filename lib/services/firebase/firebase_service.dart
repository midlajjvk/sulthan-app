import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A thin wrapper that exposes the two core Firebase singletons used by this
/// application: [FirebaseFirestore] and [FirebaseAuth].
///
/// Firebase Storage is intentionally excluded — all binary data (e.g. member
/// profile photos) is stored directly inside Firestore documents as [Blob]
/// values, so no Storage bucket is required.
///
/// Responsibilities:
///   • Hold references to [FirebaseFirestore] and [FirebaseAuth] so every
///     repository receives them through dependency injection instead of calling
///     `.instance` directly.
///   • Contain NO business logic, no collection references, and no
///     data-access code — those concerns belong in the repository layer.
///
/// Usage:
/// ```dart
/// final service = FirebaseService();
/// // or inject pre-constructed instances in tests:
/// final service = FirebaseService(
///   firestore: mockFirestore,
///   auth:      mockAuth,
/// );
/// ```
class FirebaseService {
  /// Firestore database instance used for all collection reads/writes.
  final FirebaseFirestore firestore;

  /// Authentication instance used for sign-in, sign-out, and user state.
  final FirebaseAuth auth;

  /// Creates a [FirebaseService].
  ///
  /// Each parameter defaults to the SDK singleton so normal app code never
  /// needs to pass arguments.  Tests can substitute fakes/mocks via the
  /// named parameters.
  FirebaseService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;
}
