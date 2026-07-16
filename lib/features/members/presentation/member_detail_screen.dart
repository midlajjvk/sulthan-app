import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/member_model.dart';
import '../../../models/payment_model.dart';
import '../../../models/collection_model.dart';
import '../../../shared/providers/core_providers.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/member_pdf.dart';
import '../../../core/constants/app_constants.dart';

class MemberDetailScreen extends ConsumerWidget {
  final String id;
  const MemberDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<MemberModel?>(
      future: ref.read(memberRepositoryProvider).getMemberById(id),
      builder: (ctx, snap) {
        if (!snap.hasData) return const Scaffold(body: LoadingView());
        final m = snap.data;
        if (m == null) {
          return const Scaffold(
              body: Center(child: Text('Member not found')));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(m.name),
            actions: [
              _DetailDownloadButton(member: m),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.go('/members/$id/edit'),
              ),
            ],
          ),
          body: FutureBuilder<List<PaymentModel>>(
            future:
                ref.read(paymentRepositoryProvider).getPaymentsForMember(id),
            builder: (ctx, pSnap) {
              final payments = pSnap.data ?? [];
              final totalPaid = payments
                  .where((p) => p.status != AppConstants.statusPending)
                  .fold(
                      0.0,
                      (s, p) =>
                          s + p.paidAmount + (p.fineAmount ?? 0));

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Profile card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(children: [
                        MemberAvatar(
                          photoBytes: m.photo,
                          name: m.name,
                          radius: 36,
                          fontSize: 28,
                          heroTag: 'member-photo-${m.id}',
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(m.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              _InfoRow(Icons.phone_outlined, m.mobile),
                              if (m.email != null)
                                _InfoRow(Icons.email_outlined, m.email!),
                              if (m.dateOfBirth != null)
                                _InfoRow(
                                    Icons.cake_outlined,
                                    '${Fmt.date(m.dateOfBirth!)} (Age ${Fmt.age(m.dateOfBirth!)})'),
                              if (m.bloodGroup != null)
                                _InfoRow(Icons.bloodtype_outlined,
                                    m.bloodGroup!),
                              if (m.address != null)
                                _InfoRow(Icons.location_on_outlined,
                                    m.address!),
                              if (m.additionalInfo != null)
                                _InfoRow(Icons.info_outline,
                                    m.additionalInfo!),
                              const SizedBox(height: 6),
                              StatusBadge(m.status),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Total paid summary
                  Card(
                    color: Colors.green.withValues(alpha: 0.08),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(children: [
                        const Icon(Icons.payments_outlined,
                            color: Colors.green),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Fmt.money(totalPaid),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    fontSize: 20)),
                            Text('Total Paid',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                          ],
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SectionHeader('Payment History'),
                  if (payments.isEmpty)
                    const EmptyView(
                        icon: Icons.receipt_long_outlined,
                        title: 'No payment history')
                  else
                    ...payments.map(
                        (p) => _PaymentTile(payment: p, ref: ref)),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(children: [
          Icon(icon,
              size: 13,
              color:
                  Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant),
                overflow: TextOverflow.ellipsis),
          ),
        ]),
      );
}

class _PaymentTile extends StatelessWidget {
  final PaymentModel payment;
  final WidgetRef ref;
  const _PaymentTile({required this.payment, required this.ref});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FutureBuilder<CollectionModel?>(
      future: ref
          .read(collectionRepositoryProvider)
          .getCollectionById(payment.collectionId),
      builder: (ctx, snap) {
        final col = snap.data;
        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            dense: true,
            title: Text(col?.title ?? 'Collection',
                style:
                    const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(
              payment.paymentDate != null
                  ? Fmt.date(payment.paymentDate!)
                  : 'No date',
              style: TextStyle(
                  fontSize: 11, color: cs.onSurfaceVariant),
            ),
            trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(Fmt.money(payment.paidAmount),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                      if (payment.fineAmount != null &&
                          payment.fineAmount! > 0)
                        Text(
                          'Fine: ${Fmt.money(payment.fineAmount!)}',
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                              fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(payment.status),
                ]),
          ),
        );
      },
    );
  }
}

// ── Download button for detail screen ────────────────────────────────────────

class _DetailDownloadButton extends StatefulWidget {
  final MemberModel member;
  const _DetailDownloadButton({required this.member});

  @override
  State<_DetailDownloadButton> createState() =>
      _DetailDownloadButtonState();
}

class _DetailDownloadButtonState extends State<_DetailDownloadButton> {
  bool _loading = false;

  Future<void> _download() async {
    setState(() => _loading = true);
    try {
      await downloadSingleMemberPdf(widget.member);
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
    return _loading
        ? const Padding(
            padding: EdgeInsets.all(14),
            child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2)))
        : IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Download member PDF',
            onPressed: _download,
          );
  }
}
