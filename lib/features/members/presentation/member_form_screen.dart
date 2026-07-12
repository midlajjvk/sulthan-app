import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/member_model.dart';
import '../../../shared/providers/core_providers.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';

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
  String? _photoPath;
  bool _loading = false;
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
        _photoPath = m.photoUrl;
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

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final img =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (img != null) setState(() => _photoPath = img.path);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final repo = ref.read(memberRepositoryProvider);

    try {
      // Uniqueness check — mobile must not belong to a different member
      final existing = await repo.getMemberByMobile(_mobile.text.trim());
      if (existing != null && existing.id != widget.id) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Mobile number already registered')),
          );
        }
        return;
      }

      final now = DateTime.now();

      if (_existing == null) {
        // INSERT
        final model = MemberModel(
          id: '', // Firestore generates the ID
          name: _name.text.trim(),
          mobile: _mobile.text.trim(),
          email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          address:
              _address.text.trim().isEmpty ? null : _address.text.trim(),
          dateOfBirth: _dob,
          bloodGroup: _bloodGroup,
          photoUrl: null, // local path has no meaning in Firestore
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
          address:
              _address.text.trim().isEmpty ? null : _address.text.trim(),
          dateOfBirth: _dob,
          bloodGroup: _bloodGroup,
          photoUrl: _existing!.photoUrl, // preserve existing remote URL
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save member: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    final ok = await confirmDelete(context,
        message:
            'Delete ${_existing?.name}? Payment history will be kept.');
    if (ok == true && mounted) {
      setState(() => _loading = true);
      try {
        await ref
            .read(memberRepositoryProvider)
            .deleteMember(_existing!.id);
        if (mounted) context.go('/members');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete member: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

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
            // Photo picker
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: cs.primaryContainer,
                  backgroundImage:
                      _photoPath != null ? AssetImage(_photoPath!) : null,
                  child: _photoPath == null
                      ? Icon(Icons.add_a_photo_outlined,
                          size: 28, color: cs.onPrimaryContainer)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Icons.person_outline)),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _mobile,
              decoration: const InputDecoration(
                  labelText: 'Mobile Number *',
                  prefixIcon: Icon(Icons.phone_outlined)),
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  prefixIcon: Icon(Icons.email_outlined)),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _address,
              decoration: const InputDecoration(
                  labelText: 'Address (optional)',
                  prefixIcon: Icon(Icons.location_on_outlined)),
              maxLines: 2,
            ),
            const SizedBox(height: 14),
            // Date of Birth
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
                    prefixIcon: Icon(Icons.cake_outlined)),
                child: Text(
                  _dob != null
                      ? '${Fmt.date(_dob!)}  (Age: ${Fmt.age(_dob!)})'
                      : 'Select date',
                  style: TextStyle(
                      color: _dob != null
                          ? null
                          : Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _bloodGroup,
              decoration: const InputDecoration(
                  labelText: 'Blood Group',
                  prefixIcon: Icon(Icons.bloodtype_outlined)),
              items: AppConstants.bloodGroups
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (v) => setState(() => _bloodGroup = v),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.toggle_on_outlined)),
              items: ['Active', 'Inactive']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _additionalInfo,
              decoration: const InputDecoration(
                  labelText: 'Additional Information (optional)',
                  prefixIcon: Icon(Icons.info_outline),
                  alignLabelWithHint: true),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child:
                          CircularProgressIndicator(strokeWidth: 2))
                  : Text(isEdit ? 'Save Changes' : 'Add Member'),
            ),
          ],
        ),
      ),
    );
  }
}
