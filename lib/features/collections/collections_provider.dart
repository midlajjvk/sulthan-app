import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/app_database.dart';
import '../../shared/providers/core_providers.dart';

final collectionsStreamProvider =
    StreamProvider.autoDispose<List<Collection>>((ref) =>
        ref.read(dbProvider).watchCollections());

final collectionPaymentsProvider =
    StreamProvider.autoDispose.family<List<Payment>, int>((ref, colId) =>
        ref.read(dbProvider).watchPaymentsForCollection(colId));

/// Ensures all active members have a payment row, then watches the stream.
final collectionMembersInitProvider =
    FutureProvider.autoDispose.family<void, int>((ref, colId) =>
        ref.read(dbProvider).ensurePaymentsForCollection(colId));
