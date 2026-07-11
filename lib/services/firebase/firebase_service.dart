import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// A thin wrapper that exposes the three core Firebase singletons.
///
/// Responsibilities:
///   • Hold references to [FirebaseFirestore], [FirebaseAuth], and
///     [FirebaseStorage] so every repository receives them through
///     dependency injection instead of calling `.instance` directly.
///   • Contain NO business logic, no collection references, and no
///     data-access code — those concerns belong in the repository layer.
///
/// Usage (plain Dart / Riverpod):
/// ```dart
/// final service = FirebaseService();
/// // or inject a pre-constructed instance in tests:
/// final service = FirebaseService(
///   firestore: mockFirestore,
///   auth:      mockAuth,
///   storage:   mockStorage,
/// );
/// ```
class FirebaseService {
  /// Firestore database instance used for all collection reads/writes.
  final FirebaseFirestore firestore;

  /// Authentication instance used for sign-in, sign-out, and user state.
  final FirebaseAuth auth;

  /// Storage instance used for uploading and downloading files (e.g. photos).
  final FirebaseStorage storage;

  /// Creates a [FirebaseService].
  ///
  /// Each parameter defaults to the SDK singleton so normal app code never
  /// needs to pass arguments.  Tests can substitute fakes/mocks via the
  /// named parameters.
  FirebaseService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance,
        storage = storage ?? FirebaseStorage.instance;
}
