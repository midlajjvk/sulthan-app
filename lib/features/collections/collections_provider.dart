import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/collection_model.dart';
import '../../models/payment_model.dart';
import '../../shared/providers/core_providers.dart';

final collectionsStreamProvider =
    StreamProvider.autoDispose<List<CollectionModel>>((ref) =>
        ref.watch(collectionRepositoryProvider).watchCollections());

final collectionPaymentsProvider =
    StreamProvider.autoDispose.family<List<PaymentModel>, String>(
        (ref, colId) =>
            ref.watch(paymentRepositoryProvider).watchPaymentsForCollection(colId));

/// Ensures all active members have a payment row for the given collection,
/// then signals completion so the UI can proceed.
final collectionMembersInitProvider =
    FutureProvider.autoDispose.family<void, String>((ref, colId) async {
  final colRepo = ref.watch(collectionRepositoryProvider);
  final payRepo = ref.watch(paymentRepositoryProvider);
  final memberRepo = ref.watch(memberRepositoryProvider);

  final col = await colRepo.getCollectionById(colId);
  final activeMembers = await memberRepo.getActiveMembers();
  await payRepo.ensurePaymentsForCollection(colId, col, activeMembers);
});
