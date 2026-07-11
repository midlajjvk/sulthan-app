import 'dart:developer' as dev;

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../database/app_database.dart';
import '../../../models/expense_model.dart';
import '../../../shared/providers/core_providers.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  final int? id;
  const ExpenseFormScreen({super.key, this.id});

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _form = GlobalKey<FormState>();
  final _purpose = TextEditingController();
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  final _customCategory = TextEditingController();

  /// The value shown in the dropdown. If the saved category isn't one of the
  /// fixed options we treat it as "Other" and pre-fill the custom field.
  String _category = AppConstants.expenseCategories.first;
  bool get _isOther => _category == 'Other';

  DateTime _date = DateTime.now();
  bool _loading = false;
  Expense? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) _load();
  }

  Future<void> _load() async {
    final expenses = await ref.read(dbProvider).getExpenses();
    final e = expenses.where((e) => e.id == widget.id).firstOrNull;
    if (e != null && mounted) {
      final isFixed = AppConstants.expenseCategories.contains(e.category);
      setState(() {
        _existing = e;
        _purpose.text = e.purpose;
        _amount.text = e.amount.toStringAsFixed(0);
        _notes.text = e.notes ?? '';
        _date = e.date;
        if (isFixed) {
          _category = e.category;
        } else {
          // Saved value was a custom "Other" category
          _category = 'Other';
          _customCategory.text = e.category;
        }
      });
    }
  }

  @override
  void dispose() {
    _purpose.dispose();
    _amount.dispose();
    _notes.dispose();
    _customCategory.dispose();
    super.dispose();
  }

  /// Returns the final category string to save — custom text if "Other".
  String get _resolvedCategory =>
      _isOther ? _customCategory.text.trim() : _category;

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final db = ref.read(dbProvider);
    final fsRepo = ref.read(expenseRepositoryProvider);
    try {
      final amt = double.parse(_amount.text);
      if (_existing == null) {
        final newId = await db.insertExpense(ExpensesCompanion.insert(
          purpose: _purpose.text.trim(),
          amount: amt,
          category: _resolvedCategory,
          date: _date,
          notes: Value(_notes.text.trim().isEmpty ? null : _notes.text.trim()),
        ));
        final model = ExpenseModel(
          id: newId.toString(),
          purpose: _purpose.text.trim(),
          amount: amt,
          category: _resolvedCategory,
          date: _date,
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          createdAt: DateTime.now(),
        );
        try {
          await fsRepo.addExpense(model);
          dev.log('Firestore addExpense OK — id=$newId', name: 'ExpenseForm');
        } catch (e) {
          dev.log('Firestore addExpense FAILED: $e', name: 'ExpenseForm', error: e);
        }
      } else {
        await db.updateExpense(ExpensesCompanion(
          id: Value(_existing!.id),
          purpose: Value(_purpose.text.trim()),
          amount: Value(amt),
          category: Value(_resolvedCategory),
          date: Value(_date),
          notes: Value(_notes.text.trim().isEmpty ? null : _notes.text.trim()),
        ));
        final model = ExpenseModel(
          id: _existing!.id.toString(),
          purpose: _purpose.text.trim(),
          amount: amt,
          category: _resolvedCategory,
          date: _date,
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        );
        try {
          await fsRepo.updateExpense(model);
          dev.log('Firestore updateExpense OK — id=${_existing!.id}', name: 'ExpenseForm');
        } catch (e) {
          dev.log('Firestore updateExpense FAILED: $e', name: 'ExpenseForm', error: e);
        }
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    final ok = await confirmDelete(context);
    if (ok == true && mounted) {
      final fsRepo = ref.read(expenseRepositoryProvider);
      await ref.read(dbProvider).deleteExpense(_existing!.id);
      try {
        await fsRepo.deleteExpense(_existing!.id.toString());
        dev.log('Firestore deleteExpense OK — id=${_existing!.id}', name: 'ExpenseForm');
      } catch (e) {
        dev.log('Firestore deleteExpense FAILED: $e', name: 'ExpenseForm', error: e);
      }
      if (mounted) context.go('/expenses');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.id != null;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Expense' : 'Add Expense'),
        actions: [
          if (isEdit)
            IconButton(
              icon: Icon(Icons.delete_outline, color: cs.error),
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Purpose
            TextFormField(
              controller: _purpose,
              decoration: const InputDecoration(
                labelText: 'Purpose *',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),

            // Amount
            TextFormField(
              controller: _amount,
              decoration: InputDecoration(
                labelText: 'Amount *',
                prefixText: '${AppConstants.currency} ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (double.tryParse(v) == null || double.parse(v) <= 0) {
                  return 'Enter valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Category dropdown
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category *',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: AppConstants.expenseCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _category = v;
                  if (!_isOther) _customCategory.clear();
                });
              },
            ),

            // Custom category field — only visible when "Other" is selected
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _isOther
                  ? Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: TextFormField(
                        controller: _customCategory,
                        decoration: const InputDecoration(
                          labelText: 'Specify Category *',
                          prefixIcon: Icon(Icons.edit_outlined),
                          hintText: 'e.g. Fuel, Printing, Donation…',
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        autofocus: true,
                        validator: (v) {
                          if (_isOther &&
                              (v == null || v.trim().isEmpty)) {
                            return 'Please specify the category';
                          }
                          return null;
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 14),

            // Date
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _date = d);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date *',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(Fmt.date(_date)),
              ),
            ),
            const SizedBox(height: 14),

            // Notes
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 28),

            FilledButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(isEdit ? 'Save Changes' : 'Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
