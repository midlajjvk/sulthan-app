import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/collection_model.dart';
import '../../../models/payment_model.dart';
import '../../../shared/providers/core_providers.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';

class CollectionFormScreen extends ConsumerStatefulWidget {
  final String? id;
  const CollectionFormScreen({super.key, this.id});

  @override
  ConsumerState<CollectionFormScreen> createState() =>
      _CollectionFormScreenState();
}

class _CollectionFormScreenState
    extends ConsumerState<CollectionFormScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController(text: '100');
  final _description = TextEditingController();
  String _type = AppConstants.typeMonthly;
  DateTime _date = DateTime.now();
  bool _loading = false;
  CollectionModel? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) _load();
  }

  Future<void> _load() async {
    final c = await ref
        .read(collectionRepositoryProvider)
        .getCollectionById(widget.id!);
    if (c != null && mounted) {
      setState(() {
        _existing = c;
        _title.text = c.title;
        _amount.text = c.amountPerMember.toStringAsFixed(0);
        _description.text = c.description ?? '';
        _type = c.type;
        _date = c.dateCreated ?? DateTime.now();
      });
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final colRepo = ref.read(collectionRepositoryProvider);
    final payRepo = ref.read(paymentRepositoryProvider);
    final memberRepo = ref.read(memberRepositoryProvider);

    try {
      final amt = double.parse(_amount.text);

      if (_existing == null) {
        // Duplicate monthly check
        if (_type == AppConstants.typeMonthly) {
          final exists = await colRepo.getMonthlyCollection(
              _date.month, _date.year);
          if (exists != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'Monthly collection for ${Fmt.monthYear(_date)} already exists')));
            return;
          }
        }

        // Insert collection — let Firestore generate the ID
        final colModel = CollectionModel(
          id: '',
          title: _title.text.trim(),
          type: _type,
          amountPerMember: amt,
          description: _description.text.trim().isEmpty
              ? null
              : _description.text.trim(),
          month: _type == AppConstants.typeMonthly
              ? _date.month
              : null,
          year: _type == AppConstants.typeMonthly
              ? _date.year
              : null,
          dateCreated: _date,
        );
        final colId = await colRepo.addCollection(colModel);

        // Auto-generate payment records for all active members
        final activeMembers = await memberRepo.getActiveMembers();
        final now = DateTime.now();
        int created = 0;
        for (final m in activeMembers) {
          final pm = PaymentModel(
            id: '',
            memberId: m.id,
            collectionId: colId,
            paidAmount: 0.0,
            status: AppConstants.statusPending,
            createdAt: now,
          );
          await payRepo.addPayment(pm);
          created++;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Collection created with $created payment records')));
        }
      } else {
        // UPDATE — only title, amount, description are editable
        final updated = CollectionModel(
          id: _existing!.id,
          title: _title.text.trim(),
          type: _existing!.type,
          amountPerMember: amt,
          description: _description.text.trim().isEmpty
              ? null
              : _description.text.trim(),
          month: _existing!.month,
          year: _existing!.year,
          dateCreated: _existing!.dateCreated,
        );
        await colRepo.updateCollection(updated);
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save collection: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    final ok = await confirmDelete(context,
        message:
            'Delete this collection? All payment records will also be deleted.');
    if (ok == true && mounted) {
      setState(() => _loading = true);
      try {
        final colRepo = ref.read(collectionRepositoryProvider);
        final payRepo = ref.read(paymentRepositoryProvider);
        await payRepo
            .deletePaymentsForCollection(_existing!.id);
        await colRepo.deleteCollection(_existing!.id);
        if (mounted) context.go('/collections');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to delete collection: $e')),
          );
          setState(() => _loading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.id != null;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(isEdit ? 'Edit Collection' : 'New Collection'),
        actions: [
          if (isEdit)
            IconButton(
              icon: Icon(Icons.delete_outline, color: cs.error),
              onPressed: _loading ? null : _delete,
            ),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (!isEdit) ...[
              Text('Collection Type',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: AppConstants.typeMonthly,
                      label: Text('Monthly ₹100'),
                      icon: Icon(Icons.calendar_month,
                          size: 16)),
                  ButtonSegment(
                      value: AppConstants.typeEvent,
                      label: Text('Event'),
                      icon: Icon(
                          Icons.celebration_outlined,
                          size: 16)),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() {
                  _type = s.first;
                  if (_type == AppConstants.typeMonthly) {
                    _amount.text = '100';
                    _title.text =
                        'Monthly Collection - ${Fmt.monthYear(_date)}';
                  } else {
                    _title.text = '';
                  }
                }),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                  labelText: 'Collection Name *',
                  prefixIcon: Icon(Icons.label_outline)),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _amount,
              decoration: InputDecoration(
                  labelText: 'Amount Per Member *',
                  prefixText: '${AppConstants.currency} '),
              keyboardType: TextInputType.number,
              readOnly:
                  _type == AppConstants.typeMonthly && !isEdit,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (double.tryParse(v) == null ||
                    double.parse(v) <= 0) {
                  return 'Enter valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            // Date / Month picker
            InkWell(
              onTap: isEdit
                  ? null
                  : () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (d != null) {
                        setState(() {
                          _date = d;
                          if (_type ==
                              AppConstants.typeMonthly) {
                            _title.text =
                                'Monthly Collection - ${Fmt.monthYear(_date)}';
                          }
                        });
                      }
                    },
              child: InputDecorator(
                decoration: InputDecoration(
                    labelText:
                        _type == AppConstants.typeMonthly
                            ? 'Month *'
                            : 'Date *',
                    prefixIcon: const Icon(
                        Icons.calendar_today_outlined)),
                child: Text(
                  _type == AppConstants.typeMonthly
                      ? Fmt.monthYear(_date)
                      : Fmt.date(_date),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  prefixIcon: Icon(Icons.notes_outlined)),
              maxLines: 2,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2))
                  : Text(isEdit
                      ? 'Save Changes'
                      : 'Create Collection'),
            ),
          ],
        ),
      ),
    );
  }
}
