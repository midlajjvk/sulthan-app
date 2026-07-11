import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/app_database.dart';
import '../../shared/providers/core_providers.dart';

final membersStreamProvider = StreamProvider.autoDispose<List<Member>>((ref) =>
    ref.read(dbProvider).watchMembers());

final memberSearchProvider = StateProvider.autoDispose<String>((_) => '');
final memberFilterStatusProvider = StateProvider.autoDispose<String?>((_) => null);
final memberFilterBloodProvider = StateProvider.autoDispose<String?>((_) => null);

final filteredMembersProvider =
    Provider.autoDispose<AsyncValue<List<Member>>>((ref) {
  final all = ref.watch(membersStreamProvider);
  final q = ref.watch(memberSearchProvider).toLowerCase();
  final status = ref.watch(memberFilterStatusProvider);
  final blood = ref.watch(memberFilterBloodProvider);

  return all.whenData((list) => list.where((m) {
        if (q.isNotEmpty &&
            !m.name.toLowerCase().contains(q) &&
            !m.mobile.contains(q)) return false;
        if (status != null && m.status != status) return false;
        if (blood != null && m.bloodGroup != blood) return false;
        return true;
      }).toList());
});
