import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../collections_provider.dart';
import '../../../models/collection_model.dart';
import '../../../models/payment_model.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/app_constants.dart';

class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});
  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(collectionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Monthly'),
            Tab(text: 'Events'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/collections/add'),
        icon: const Icon(Icons.add),
        label: const Text('New Collection'),
      ),
      body: allAsync.when(
        data: (all) {
          final monthly =
              all.where((c) => c.type == AppConstants.typeMonthly).toList();
          final events =
              all.where((c) => c.type == AppConstants.typeEvent).toList();
          return TabBarView(
            controller: _tab,
            children: [
              _CollectionList(
                  collections: monthly, type: AppConstants.typeMonthly),
              _CollectionList(
                  collections: events, type: AppConstants.typeEvent),
            ],
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(message: e.toString()),
      ),
    );
  }
}

class _CollectionList extends ConsumerWidget {
  final List<CollectionModel> collections;
  final String type;
  const _CollectionList({required this.collections, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (collections.isEmpty) {
      return EmptyView(
        icon: Icons.account_balance_wallet_outlined,
        title: type == AppConstants.typeMonthly
            ? 'No monthly collections'
            : 'No event collections',
        subtitle: 'Tap + to create one',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: collections.length,
      itemBuilder: (ctx, i) =>
          _CollectionCard(collection: collections[i], ref: ref),
    );
  }
}

// ── Collection card with live payment summary ─────────────────────────────────

class _CollectionCard extends ConsumerWidget {
  final CollectionModel collection;
  final WidgetRef ref;
  const _CollectionCard({required this.collection, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final cs = Theme.of(context).colorScheme;
    final isMonthly = collection.type == AppConstants.typeMonthly;

    // Watch the live payment stream for this collection
    final paymentsAsync =
        widgetRef.watch(collectionPaymentsProvider(collection.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go('/collections/${collection.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: paymentsAsync.when(
            loading: () => _CardContent(
              collection: collection,
              isMonthly: isMonthly,
              payments: const [],
              cs: cs,
            ),
            error: (_, __) => _CardContent(
              collection: collection,
              isMonthly: isMonthly,
              payments: const [],
              cs: cs,
            ),
            data: (payments) => _CardContent(
              collection: collection,
              isMonthly: isMonthly,
              payments: payments,
              cs: cs,
            ),
          ),
        ),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final CollectionModel collection;
  final bool isMonthly;
  final List<PaymentModel> payments;
  final ColorScheme cs;

  const _CardContent({
    required this.collection,
    required this.isMonthly,
    required this.payments,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final paid =
        payments.where((p) => p.status == AppConstants.statusPaid).length;
    final total = payments.length;
    final collected = payments
        .where((p) => p.status != AppConstants.statusPending)
        .fold(0.0, (s, p) => s + p.paidAmount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color:
                  (isMonthly ? cs.primary : Colors.purple).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isMonthly ? Icons.calendar_month : Icons.celebration_outlined,
              color: isMonthly ? cs.primary : Colors.purple,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(collection.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                Text(
                  isMonthly && collection.month != null
                      ? Fmt.monthYearOf(collection.month!, collection.year!)
                      : Fmt.date(collection.dateCreated ?? DateTime.now()),
                  style:
                      TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(Fmt.money(collection.amountPerMember),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                  fontSize: 15)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _Pill('$paid/$total Paid', Colors.green),
          const SizedBox(width: 8),
          _Pill('Collected ${Fmt.money(collected)}', cs.primary),
          const Spacer(),
          Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
        ]),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6)),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w500)),
      );
}
