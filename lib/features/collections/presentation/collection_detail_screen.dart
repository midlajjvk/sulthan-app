import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../collections_provider.dart';
import '../../../models/collection_model.dart';
import '../../../models/member_model.dart';
import '../../../models/payment_model.dart';
import '../../../repositories/firebase/payment_repository.dart';
import '../../../shared/providers/core_providers.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/collection_pdf.dart';
import '../../../core/constants/app_constants.dart';

class CollectionDetailScreen extends ConsumerWidget {
  final String id;
  const CollectionDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initAsync = ref.watch(collectionMembersInitProvider(id));
    final paymentsAsync = ref.watch(collectionPaymentsProvider(id));

    return FutureBuilder<CollectionModel?>(
      future: ref
          .read(collectionRepositoryProvider)
          .getCollectionById(id),
      builder: (ctx, snap) {
        if (!snap.hasData) return const Scaffold(body: LoadingView());
        final col = snap.data;
        if (col == null) {
          return const Scaffold(
              body: Center(child: Text('Collection not found')));
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(col.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () =>
                    context.push('/collections/$id/edit'),
              ),
            ],
          ),
          body: initAsync.when(
            loading: () => const LoadingView(),
            error: (e, _) => ErrorView(message: e.toString()),
            data: (_) => paymentsAsync.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(message: e.toString()),
              data: (payments) => _CollectionBody(
                collectionId: id,
                collection: col,
                payments: payments,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _CollectionBody extends ConsumerWidget {
  final String collectionId;
  final CollectionModel collection;
  final List<PaymentModel> payments;

  const _CollectionBody({
    required this.collectionId,
    required this.collection,
    required this.payments,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    final paid = payments
        .where((p) => p.status == AppConstants.statusPaid)
        .length;
    final partial = payments
        .where((p) => p.status == AppConstants.statusPartial)
        .length;
    final pending = payments
        .where((p) => p.status == AppConstants.statusPending)
        .length;
    final collected = payments
        .where((p) => p.status != AppConstants.statusPending)
        .fold(0.0, (s, p) => s + p.paidAmount + (p.fineAmount ?? 0));
    final totalFines =
        payments.fold(0.0, (s, p) => s + (p.fineAmount ?? 0));
    final target = collection.amountPerMember * payments.length;

    return FutureBuilder<List<MemberModel>>(
      future: ref.read(memberRepositoryProvider).getMembers(),
      builder: (ctx, mSnap) {
        final members = mSnap.data ?? [];
        final memberMap = {for (final m in members) m.id: m};

        return Column(
          children: [
            // Summary card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        collection.type ==
                                    AppConstants.typeMonthly &&
                                collection.month != null
                            ? Fmt.monthYearOf(collection.month!,
                                collection.year!)
                            : Fmt.date(collection.dateCreated ??
                                DateTime.now()),
                        style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(Fmt.money(collected),
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: cs.primary)),
                      Text(
                          'Collected of ${Fmt.money(target)} target',
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant)),
                      const SizedBox(height: 10),
                      if (payments.isNotEmpty && target > 0)
                        LinearProgressIndicator(
                          value: (collected / target)
                              .clamp(0.0, 1.0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      const SizedBox(height: 10),
                      Row(children: [
                        _Stat('Paid', '$paid', Colors.green),
                        const SizedBox(width: 12),
                        _Stat('Partial', '$partial',
                            Colors.orange),
                        const SizedBox(width: 12),
                        _Stat('Pending', '$pending', cs.error),
                        if (totalFines > 0) ...[
                          const SizedBox(width: 12),
                          _Stat('Fines',
                              Fmt.money(totalFines), Colors.red),
                        ],
                      ]),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _MemberSearchList(
                payments: payments,
                collection: collection,
                memberMap: memberMap,
                ref: ref,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Member search + filter list ───────────────────────────────────────────────

class _MemberSearchList extends StatefulWidget {
  final List<PaymentModel> payments;
  final CollectionModel collection;
  final Map<String, MemberModel> memberMap;
  final WidgetRef ref;

  const _MemberSearchList({
    required this.payments,
    required this.collection,
    required this.memberMap,
    required this.ref,
  });

  @override
  State<_MemberSearchList> createState() => _MemberSearchListState();
}

class _MemberSearchListState extends State<_MemberSearchList> {
  String _query = '';
  String _filter = 'All';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<PaymentModel> get _visible {
    return widget.payments.where((p) {
      if (_filter != 'All' && p.status != _filter) return false;
      if (_query.isNotEmpty) {
        final member = widget.memberMap[p.memberId];
        final name = member?.name.toLowerCase() ?? '';
        final mobile = member?.mobile ?? '';
        if (!name.contains(_query.toLowerCase()) &&
            !mobile.contains(_query)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final allCount = widget.payments.length;
    final paidCount = widget.payments
        .where((p) => p.status == AppConstants.statusPaid)
        .length;
    final partialCount = widget.payments
        .where((p) => p.status == AppConstants.statusPartial)
        .length;
    final pendingCount = widget.payments
        .where((p) => p.status == AppConstants.statusPending)
        .length;

    final visible = _visible;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search member by name or mobile...',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All ($allCount)',
                        selected: _filter == 'All',
                        color: cs.primary,
                        onTap: () =>
                            setState(() => _filter = 'All'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Paid ($paidCount)',
                        selected:
                            _filter == AppConstants.statusPaid,
                        color: Colors.green,
                        onTap: () => setState(() =>
                            _filter = AppConstants.statusPaid),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Partial ($partialCount)',
                        selected: _filter ==
                            AppConstants.statusPartial,
                        color: Colors.orange,
                        onTap: () => setState(() => _filter =
                            AppConstants.statusPartial),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Pending ($pendingCount)',
                        selected: _filter ==
                            AppConstants.statusPending,
                        color: Colors.red,
                        onTap: () => setState(() => _filter =
                            AppConstants.statusPending),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _CollectionDownloadButton(
                collection: widget.collection,
                payments: widget.payments,
                memberMap: widget.memberMap,
                filterStatus:
                    _filter == 'All' ? null : _filter,
              ),
            ],
          ),
        ),
        if (_query.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${visible.length} result${visible.length == 1 ? '' : 's'} for "$_query"',
                style: TextStyle(
                    fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ),
          ),
        Expanded(
          child: visible.isEmpty
              ? EmptyView(
                  icon: Icons.people_outlined,
                  title: _query.isNotEmpty
                      ? 'No members match "$_query"'
                      : 'No members found',
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: visible.length,
                  itemBuilder: (ctx, i) => _PaymentRow(
                    payment: visible[i],
                    member: widget.memberMap[visible[i].memberId],
                    collection: widget.collection,
                    ref: widget.ref,
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? color
              : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected
                  ? color
                  : color.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

// ── Stat widget ───────────────────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 18)),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant)),
        ],
      );
}

// ── Payment row ───────────────────────────────────────────────────────────────

class _PaymentRow extends StatelessWidget {
  final PaymentModel payment;
  final MemberModel? member;
  final CollectionModel collection;
  final WidgetRef ref;

  const _PaymentRow({
    required this.payment,
    required this.member,
    required this.collection,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isPending = payment.status == AppConstants.statusPending;
    final statusColor =
        payment.status == AppConstants.statusPaid
            ? Colors.green
            : payment.status == AppConstants.statusPartial
                ? Colors.orange
                : cs.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              statusColor.withValues(alpha: 0.15),
          child: Text(
            member?.name[0].toUpperCase() ?? '?',
            style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          member?.name ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isPending
                  ? 'Not paid'
                  : payment.paymentDate != null
                      ? Fmt.date(payment.paymentDate!)
                      : 'No date',
              style: TextStyle(
                  fontSize: 11, color: cs.onSurfaceVariant),
            ),
            if (payment.advanceEndMonth != null)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color:
                          Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Paid until ${CollectionUtils.monthName(payment.advanceEndMonth!)} ${payment.advanceEndYear}',
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (!isPending) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(Fmt.money(payment.paidAmount),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
                if (payment.fineAmount != null &&
                    payment.fineAmount! > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color:
                          Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Fine: ${Fmt.money(payment.fineAmount!)}',
                      style: const TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(width: 8),
          StatusBadge(payment.status),
          const SizedBox(width: 4),
          Icon(Icons.edit_outlined,
              size: 16, color: cs.onSurfaceVariant),
        ]),
        onTap: () => _editPayment(context, ref),
      ),
    );
  }

  void _editPayment(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _EditPaymentSheet(
        payment: payment,
        member: member,
        collection: collection,
        ref: ref,
      ),
    );
  }
}

// ── Edit payment bottom sheet ─────────────────────────────────────────────────

class _EditPaymentSheet extends StatefulWidget {
  final PaymentModel payment;
  final MemberModel? member;
  final CollectionModel collection;
  final WidgetRef ref;

  const _EditPaymentSheet({
    required this.payment,
    required this.member,
    required this.collection,
    required this.ref,
  });

  @override
  State<_EditPaymentSheet> createState() => _EditPaymentSheetState();
}

class _EditPaymentSheetState extends State<_EditPaymentSheet> {
  late String _status;
  late TextEditingController _amountCtrl;
  late TextEditingController _fineCtrl;
  late DateTime _paymentDate;
  bool _isAdvance = false;
  bool _showFine = false;

  bool get _isMonthly =>
      widget.collection.type == AppConstants.typeMonthly &&
      widget.collection.month != null;

  ({int months, int endMonth, int endYear})? get _advanceRange {
    if (!_isMonthly) return null;
    final amt = double.tryParse(_amountCtrl.text);
    if (amt == null || amt <= 0) return null;
    return CollectionUtils.calcAdvanceRange(
      startMonth: widget.collection.month!,
      startYear: widget.collection.year!,
      paidAmount: amt,
      amountPerMonth: widget.collection.amountPerMember,
    );
  }

  @override
  void initState() {
    super.initState();
    _status = widget.payment.status;
    final existingAmount = widget.payment.paidAmount > 0
        ? widget.payment.paidAmount.toStringAsFixed(0)
        : '';
    _amountCtrl = TextEditingController(text: existingAmount);
    _amountCtrl.addListener(() => setState(() {}));
    _paymentDate = widget.payment.paymentDate ?? DateTime.now();
    _isAdvance = widget.payment.advanceStartMonth != null;
    final existingFine = widget.payment.fineAmount;
    _fineCtrl = TextEditingController(
        text: existingFine != null && existingFine > 0
            ? existingFine.toStringAsFixed(0)
            : '');
    _showFine = existingFine != null && existingFine > 0;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _fineCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final payRepo = widget.ref.read(paymentRepositoryProvider);

    try {
      if (_isAdvance && _isMonthly) {
        final amt = double.tryParse(_amountCtrl.text) ?? 0.0;
        if (amt <= 0) {
          messenger.showSnackBar(
              const SnackBar(content: Text('Enter a valid amount')));
          return;
        }
        await payRepo.saveAdvancePayment(
          paymentId: widget.payment.id,
          memberId: widget.payment.memberId,
          collectionId: widget.payment.collectionId,
          startMonth: widget.collection.month!,
          startYear: widget.collection.year!,
          paidAmount: amt,
          amountPerMonth: widget.collection.amountPerMember,
          paymentDate: _paymentDate,
        );
        final range = _advanceRange!;
        nav.pop();
        messenger.showSnackBar(SnackBar(
          content: Text(
            'Advance saved: ${range.months} month${range.months == 1 ? '' : 's'}'
            ' — Paid until ${CollectionUtils.monthName(range.endMonth)} ${range.endYear}',
          ),
          backgroundColor: Colors.green,
        ));
      } else {
        final amt = _status == AppConstants.statusPending
            ? 0.0
            : double.tryParse(_amountCtrl.text) ?? 0.0;
        final fine =
            _showFine && _status != AppConstants.statusPending
                ? (double.tryParse(_fineCtrl.text) ?? 0.0)
                : 0.0;

        final updated = PaymentModel(
          id: widget.payment.id,
          memberId: widget.payment.memberId,
          collectionId: widget.payment.collectionId,
          paidAmount: amt,
          status: _status,
          paymentDate: _status != AppConstants.statusPending
              ? _paymentDate
              : null,
          fineAmount: fine > 0 ? fine : null,
          advanceStartMonth: null,
          advanceStartYear: null,
          advanceEndMonth: null,
          advanceEndYear: null,
          notes: null,
          createdAt: widget.payment.createdAt,
        );
        await payRepo.updatePayment(updated);
        nav.pop();
      }
    } catch (e) {
      dev.log('updatePayment failed: $e', name: 'EditPaymentSheet', error: e);
      if (mounted) {
        messenger.showSnackBar(
            SnackBar(content: Text('Failed to save: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final name = widget.member?.name;
    final range = _advanceRange;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(children: [
              if (name != null) ...[
                CircleAvatar(
                  radius: 18,
                  backgroundColor: cs.primaryContainer,
                  child: Text(name[0].toUpperCase(),
                      style: TextStyle(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Update Payment',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  if (name != null)
                    Text(name,
                        style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 13)),
                ],
              ),
            ]),
            const SizedBox(height: 16),

            // Advance toggle (monthly only)
            if (_isMonthly) ...[
              Container(
                decoration: BoxDecoration(
                  color: _isAdvance
                      ? cs.primaryContainer.withValues(alpha: 0.4)
                      : cs.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _isAdvance
                          ? cs.primary.withValues(alpha: 0.5)
                          : cs.outline.withValues(alpha: 0.2)),
                ),
                child: SwitchListTile(
                  dense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14),
                  title: Text('Advance Payment',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _isAdvance ? cs.primary : null,
                          fontSize: 14)),
                  subtitle: const Text(
                      'Auto-calculates months from amount paid',
                      style: TextStyle(fontSize: 11)),
                  secondary: Icon(Icons.fast_forward_rounded,
                      color: _isAdvance
                          ? cs.primary
                          : cs.onSurfaceVariant),
                  value: _isAdvance,
                  onChanged: (v) => setState(() {
                    _isAdvance = v;
                    if (v) {
                      _status = AppConstants.statusPaid;
                      if (_amountCtrl.text.isEmpty) {
                        _amountCtrl.text = widget.collection
                            .amountPerMember
                            .toStringAsFixed(0);
                      }
                    }
                  }),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Status selector (hidden when advance is on)
            if (!_isAdvance) ...[
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: AppConstants.statusPending,
                      label: Text('Pending')),
                  ButtonSegment(
                      value: AppConstants.statusPartial,
                      label: Text('Partial')),
                  ButtonSegment(
                      value: AppConstants.statusPaid,
                      label: Text('Paid')),
                ],
                selected: {_status},
                onSelectionChanged: (s) {
                  setState(() {
                    _status = s.first;
                    if (_status == AppConstants.statusPaid) {
                      _amountCtrl.text = widget.collection
                          .amountPerMember
                          .toStringAsFixed(0);
                    } else if (_status ==
                        AppConstants.statusPending) {
                      _amountCtrl.text = '';
                    }
                  });
                },
              ),
              const SizedBox(height: 14),
            ],

            // Amount + date (shown when paid/partial or advance)
            if (_isAdvance ||
                _status != AppConstants.statusPending) ...[
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _paymentDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _paymentDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Payment Date',
                    prefixIcon:
                        Icon(Icons.calendar_today_outlined),
                    isDense: true,
                  ),
                  child: Text(Fmt.date(_paymentDate),
                      style: const TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountCtrl,
                decoration: InputDecoration(
                  labelText: _isAdvance
                      ? 'Total Amount Paid'
                      : 'Amount Paid',
                  prefixText: '${AppConstants.currency} ',
                  helperText: _isAdvance
                      ? 'e.g. ${AppConstants.currency}${(widget.collection.amountPerMember * 3).toStringAsFixed(0)} = 3 months'
                      : null,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
              ),
              const SizedBox(height: 12),
            ],

            // Advance preview banner
            if (_isAdvance && _isMonthly)
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: range != null
                    ? Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.green
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                  size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '${range.months} month${range.months == 1 ? '' : 's'} covered',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green,
                                    fontSize: 13),
                              ),
                            ]),
                            const SizedBox(height: 3),
                            Text(
                              '${CollectionUtils.monthName(widget.collection.month!)} ${widget.collection.year}'
                              ' → ${CollectionUtils.monthName(range.endMonth)} ${range.endYear}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurfaceVariant),
                            ),
                            Text(
                              'Paid until ${CollectionUtils.monthName(range.endMonth)} ${range.endYear}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

            // Fine section (monthly only, when paid/partial, not advance)
            if (_isMonthly &&
                !_isAdvance &&
                _status != AppConstants.statusPending) ...[
              const Divider(height: 20),
              Row(
                children: [
                  Icon(Icons.gavel_outlined,
                      size: 16, color: Colors.red.shade400),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Late Fine',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color:
                                _showFine ? Colors.red : null)),
                  ),
                  Switch(
                    value: _showFine,
                    activeThumbColor: Colors.red,
                    onChanged: (v) => setState(() {
                      _showFine = v;
                      if (!v) _fineCtrl.clear();
                    }),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                child: _showFine
                    ? Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 8),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Text('Days late:  ',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors
                                              .red.shade300)),
                                  ...[
                                    1, 2, 3, 4, 5,
                                    6, 7, 10, 15, 30
                                  ].map((days) {
                                    final fine = (days *
                                            AppConstants.finePerDay)
                                        .toStringAsFixed(0);
                                    return Padding(
                                      padding: const EdgeInsets
                                          .only(right: 6),
                                      child: GestureDetector(
                                        onTap: () => setState(
                                            () => _fineCtrl
                                                .text = fine),
                                        child: Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 10,
                                              vertical: 5),
                                          decoration: BoxDecoration(
                                            color:
                                                _fineCtrl.text ==
                                                        fine
                                                    ? Colors.red
                                                    : Colors.red
                                                        .withValues(
                                                            alpha:
                                                                0.1),
                                            borderRadius:
                                                BorderRadius
                                                    .circular(16),
                                            border: Border.all(
                                                color: Colors.red
                                                    .withValues(
                                                        alpha: 0.4)),
                                          ),
                                          child: Text(
                                            '$days d  (${AppConstants.currency}$fine)',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight.w600,
                                                color:
                                                    _fineCtrl.text ==
                                                            fine
                                                        ? Colors.white
                                                        : Colors.red),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                          TextField(
                            controller: _fineCtrl,
                            decoration: InputDecoration(
                              labelText: 'Fine Amount',
                              prefixText:
                                  '${AppConstants.currency} ',
                              prefixIcon: const Icon(
                                  Icons.warning_amber_outlined,
                                  color: Colors.red),
                              helperText:
                                  '${AppConstants.currency}${AppConstants.finePerDay.toStringAsFixed(0)} per day after 5th',
                              helperStyle: TextStyle(
                                  color: Colors.red.shade300),
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            onChanged: (_) => setState(() {}),
                          ),
                          if (_fineCtrl.text.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.red
                                    .withValues(alpha: 0.06),
                                borderRadius:
                                    BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.red
                                        .withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Monthly + Fine',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              Colors.red.shade700)),
                                  Text(
                                    '${AppConstants.currency}${(double.tryParse(_amountCtrl.text) ?? 0) + (double.tryParse(_fineCtrl.text) ?? 0)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],

            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _save(context),
                child: Text(_isAdvance
                    ? 'Save Advance Payment'
                    : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Collection PDF download button ────────────────────────────────────────────

class _CollectionDownloadButton extends StatefulWidget {
  final CollectionModel collection;
  final List<PaymentModel> payments;
  final Map<String, MemberModel> memberMap;
  final String? filterStatus;

  const _CollectionDownloadButton({
    required this.collection,
    required this.payments,
    required this.memberMap,
    required this.filterStatus,
  });

  @override
  State<_CollectionDownloadButton> createState() =>
      _CollectionDownloadButtonState();
}

class _CollectionDownloadButtonState
    extends State<_CollectionDownloadButton> {
  bool _loading = false;

  Future<void> _download() async {
    setState(() => _loading = true);
    try {
      await downloadCollectionPaymentsPdf(
        collection: widget.collection,
        payments: widget.payments,
        memberMap: widget.memberMap,
        filterStatus: widget.filterStatus,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = widget.filterStatus ?? 'All';

    return _loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2))
        : Tooltip(
            message: 'Download $label as PDF',
            child: InkWell(
              onTap: _download,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: cs.primaryContainer
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: cs.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.picture_as_pdf_outlined,
                        size: 16, color: cs.primary),
                    const SizedBox(width: 4),
                    Text('PDF',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: cs.primary)),
                  ],
                ),
              ),
            ),
          );
  }
}
