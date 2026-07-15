import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/member_model.dart';
import '../../../shared/providers/core_providers.dart';
import '../../../shared/widgets/common_widgets.dart';

class MemberFormScreen extends ConsumerStatefulWidget {
  final String? id;
  const MemberFormScreen({super.key, this.id});

  @override
  ConsumerState<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends ConsumerState<MemberFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _additionalInfo = TextEditingController();

  DateTime? _dob;
  String? _bloodGroup;
  String _status = 'Active';

  /// Processed image bytes ready to be stored in Firestore.
  /// - null  → no photo selected yet (new member) or not changed (edit).
  /// - non-null → user picked a new image; these bytes will be saved.
  Uint8List? _photoBytes;

  /// Whether the user explicitly removed the existing photo.
  bool _photoRemoved = false;

  /// True while the form is saving or an image is being processed.
  bool _loading = false;

  /// True while image processing (resize/compress) is running.
  bool _processingImage = false;

  MemberModel? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) _load();
  }

  Future<void> _load() async {
    final repo = ref.read(memberRepositoryProvider);
    final m = await repo.getMemberById(widget.id!);
    if (m != null && mounted) {
      setState(() {
        _existing = m;
        _name.text = m.name;
        _mobile.text = m.mobile;
        _email.text = m.email ?? '';
        _address.text = m.address ?? '';
        _dob = m.dateOfBirth;
        _bloodGroup = m.bloodGroup;
        _status = m.status;
        _photoBytes = m.photo; // pre-load existing bytes for preview
        _additionalInfo.text = m.additionalInfo ?? '';
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _email.dispose();
    _address.dispose();
    _additionalInfo.dispose();
    super.dispose();
  }

  // ── Image picking ──────────────────────────────────────────────────────────

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    XFile? img;
    try {
      img = await picker.pickImage(source: ImageSource.gallery);
    } catch (e, st) {
      developer.log('[_pickPhoto] picker threw: $e', name: 'MemberFormScreen', error: e, stackTrace: st);
      if (mounted) _showError('Could not open image picker: $e');
      return;
    }

    if (img == null) {
      developer.log('[_pickPhoto] user cancelled — img is null', name: 'MemberFormScreen');
      return;
    }

    developer.log('[_pickPhoto] picked file: path=${img.path}  name=${img.name}  mimeType=${img.mimeType}', name: 'MemberFormScreen');

    setState(() => _processingImage = true);
    try {
      developer.log('[_pickPhoto] calling img.readAsBytes() …', name: 'MemberFormScreen');
      final rawBytes = await img.readAsBytes();
      developer.log('[_pickPhoto] readAsBytes() OK — rawBytes.length=${rawBytes.length} (${(rawBytes.length / 1024).toStringAsFixed(1)} KB)', name: 'MemberFormScreen');

      if (rawBytes.isEmpty) {
        if (mounted) _showError('Selected image is empty or unreadable.');
        return;
      }

      developer.log('[_pickPhoto] calling repo.processImage() …', name: 'MemberFormScreen');
      final repo = ref.read(memberRepositoryProvider);
      final processed = await repo.processImage(rawBytes);
      developer.log('[_pickPhoto] processImage() OK — processed.length=${processed.length} (${(processed.length / 1024).toStringAsFixed(1)} KB)', name: 'MemberFormScreen');

      if (mounted) {
        setState(() {
          _photoBytes = processed;
          _photoRemoved = false;
        });
      }
    } catch (e, st) {
      developer.log('[_pickPhoto] EXCEPTION during processing: $e', name: 'MemberFormScreen', error: e, stackTrace: st);
      // Show the REAL exception message (not a generic fallback) so we can
      // diagnose failures during the debug phase.
      if (mounted) _showError('Image processing failed: $e');
    } finally {
      if (mounted) setState(() => _processingImage = false);
    }
  }

  void _removePhoto() {
    setState(() {
      _photoBytes = null;
      _photoRemoved = true;
    });
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final repo = ref.read(memberRepositoryProvider);

    try {
      // Uniqueness check
      final existing = await repo.getMemberByMobile(_mobile.text.trim());
      if (existing != null && existing.id != widget.id) {
        if (mounted) _showError('Mobile number already registered');
        return;
      }

      final now = DateTime.now();

      // Resolve which bytes to persist:
      //   - new member or user picked a new image → _photoBytes (may be null if nothing picked)
      //   - edit + no change → _existing!.photo
      //   - edit + removed   → null
      final Uint8List? bytesToSave = _existing == null
          ? _photoBytes
          : _photoRemoved
              ? null
              : _photoBytes; // already holds existing bytes loaded in _load()

      if (_existing == null) {
        // INSERT
        final model = MemberModel(
          id: '',
          name: _name.text.trim(),
          mobile: _mobile.text.trim(),
          email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          address: _address.text.trim().isEmpty ? null : _address.text.trim(),
          dateOfBirth: _dob,
          bloodGroup: _bloodGroup,
          photo: bytesToSave,
          status: _status,
          additionalInfo: _additionalInfo.text.trim().isEmpty
              ? null
              : _additionalInfo.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        await repo.addMember(model);
      } else {
        // UPDATE
        final model = MemberModel(
          id: _existing!.id,
          name: _name.text.trim(),
          mobile: _mobile.text.trim(),
          email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          address: _address.text.trim().isEmpty ? null : _address.text.trim(),
          dateOfBirth: _dob,
          bloodGroup: _bloodGroup,
          photo: bytesToSave,
          status: _status,
          additionalInfo: _additionalInfo.text.trim().isEmpty
              ? null
              : _additionalInfo.text.trim(),
          createdAt: _existing!.createdAt,
          updatedAt: now,
        );
        await repo.updateMember(model);
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) _showError('Failed to save member: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> _delete() async {
    final ok = await confirmDelete(context,
        message: 'Delete ${_existing?.name}? Payment history will be kept.');
    if (ok == true && mounted) {
      setState(() => _loading = true);
      try {
        await ref
            .read(memberRepositoryProvider)
            .deleteMember(_existing!.id);
        if (mounted) context.go('/members');
      } catch (e) {
        if (mounted) _showError('Failed to delete member: $e');
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.id != null;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Member' : 'Add Member'),
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
            // ── Photo picker ───────────────────────────────────────────────
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  // Avatar preview
                  _processingImage
                      ? CircleAvatar(
                          radius: 42,
                          backgroundColor: cs.primaryContainer,
                          child: const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        )
                      : GestureDetector(
                          onTap: _loading ? null : _pickPhoto,
                          child: MemberAvatar(
                            photoBytes: _photoBytes,
                            name: _name.text.isEmpty ? '?' : _name.text,
                            radius: 42,
                            fontSize: 28,
                          ),
                        ),
                  // Overlaid edit / add button
                  if (!_processingImage)
                    GestureDetector(
                      onTap: _loading ? null : _pickPhoto,
                      child: Container(
                        decoration: BoxDecoration(
                          color: cs.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: cs.surface, width: 2),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          _photoBytes != null
                              ? Icons.edit_outlined
                              : Icons.add_a_photo_outlined,
                          size: 16,
                          color: cs.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Remove photo link — only visible when a photo is loaded
            if (_photoBytes != null && !_processingImage) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _loading ? null : _removePhoto,
                  icon: Icon(Icons.delete_outline,
                      size: 16, color: cs.error),
                  label: Text('Remove photo',
                      style: TextStyle(color: cs.error, fontSize: 13)),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // ── Name ───────────────────────────────────────────────────────
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}), // refresh avatar initial
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),

            // ── Mobile ────────────────────────────────────────────────────
            TextFormField(
              controller: _mobile,
              decoration: const InputDecoration(
                labelText: 'Mobile Number *',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),

            // ── Email ─────────────────────────────────────────────────────
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(
                labelText: 'Email (optional)',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),

            // ── Address ───────────────────────────────────────────────────
            TextFormField(
              controller: _address,
              decoration: const InputDecoration(
                labelText: 'Address (optional)',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 14),

            // ── Date of birth ─────────────────────────────────────────────
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _dob ?? DateTime(2000),
                  firstDate: DateTime(1940),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _dob = d);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
                child: Text(
                  _dob != null
                      ? '${Fmt.date(_dob!)}  (Age: ${Fmt.age(_dob!)})'
                      : 'Select date',
                  style: TextStyle(
                    color: _dob != null
                        ? null
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Blood group ───────────────────────────────────────────────
            DropdownButtonFormField<String>(
              initialValue: _bloodGroup,
              decoration: const InputDecoration(
                labelText: 'Blood Group',
                prefixIcon: Icon(Icons.bloodtype_outlined),
              ),
              items: AppConstants.bloodGroups
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (v) => setState(() => _bloodGroup = v),
            ),
            const SizedBox(height: 14),

            // ── Status ────────────────────────────────────────────────────
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.toggle_on_outlined),
              ),
              items: ['Active', 'Inactive']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 14),

            // ── Additional info ───────────────────────────────────────────
            TextFormField(
              controller: _additionalInfo,
              decoration: const InputDecoration(
                labelText: 'Additional Information (optional)',
                prefixIcon: Icon(Icons.info_outline),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 28),

            // ── Save button ───────────────────────────────────────────────
            FilledButton(
              onPressed: (_loading || _processingImage) ? null : _save,
              child: (_loading || _processingImage)
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEdit ? 'Save Changes' : 'Add Member'),
            ),
          ],
        ),
      ),
    );
  }
}
