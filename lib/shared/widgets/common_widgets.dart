import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'photo_viewer.dart';

// ── Loading ───────────────────────────────────────────────────────────────────
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

// ── Empty state ───────────────────────────────────────────────────────────────
class EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  const EmptyView(
      {super.key,
      required this.icon,
      required this.title,
      this.subtitle,
      this.action});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: cs.onSurfaceVariant)),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: cs.onSurfaceVariant.withValues(alpha: 0.7))),
            ],
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ]
          ],
        ),
      );
}

// ── Confirm delete dialog ─────────────────────────────────────────────────────
Future<bool?> confirmDelete(BuildContext context, {String? message}) =>
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(message ?? 'This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

// ── Status badge ──────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Paid' => Colors.green,
      'Partial' => Colors.orange,
      _ => Theme.of(context).colorScheme.error,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6)),
      child: Text(status,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────
class SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                            fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(label,
                        style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;
  const SectionHeader(this.title, {super.key, this.action});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Expanded(
            child: Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          if (action != null) action!,
        ]),
      );
}

// ── Member avatar ─────────────────────────────────────────────────────────────

/// A circular avatar that displays the member's profile photo when available,
/// falling back to the member's initial on a coloured background.
///
/// [photoBytes] — compressed JPEG bytes loaded from the Firestore Blob field.
/// [name]       — member name; first character is used as the fallback initial.
/// [radius]     — avatar radius (default 20, suitable for list tiles).
/// [fontSize]   — font size of the fallback initial (default scales with radius).
/// [heroTag]    — when provided, wraps the avatar in a [Hero] and tapping a
///               photo opens the full-screen viewer via [showMemberPhotoViewer].
///               Use a unique value per member, e.g. `'member-photo-\${id}'`.
///               If null, no Hero is applied and tapping does nothing.
class MemberAvatar extends StatelessWidget {
  final Uint8List? photoBytes;
  final String name;
  final double radius;
  final double? fontSize;
  final bool selected;
  final String? heroTag;

  const MemberAvatar({
    super.key,
    required this.photoBytes,
    required this.name,
    this.radius = 20,
    this.fontSize,
    this.selected = false,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final effectiveFontSize = fontSize ?? (radius * 0.7);

    final Widget avatar;

    if (photoBytes != null && photoBytes!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(photoBytes!),
        backgroundColor: selected ? cs.primary : cs.primaryContainer,
      );
    } else {
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: selected ? cs.primary : cs.primaryContainer,
        child: Text(
          initial,
          style: TextStyle(
            color: selected ? cs.onPrimary : cs.onPrimaryContainer,
            fontWeight: FontWeight.bold,
            fontSize: effectiveFontSize,
          ),
        ),
      );
    }

    // No heroTag — return the plain avatar (no tap behaviour).
    if (heroTag == null) return avatar;

    // Has a heroTag — wrap in Hero and make the photo tappable.
    final heroAvatar = Hero(tag: heroTag!, child: avatar);

    // Only wire up the tap when there is actually a photo to show.
    if (photoBytes == null || photoBytes!.isEmpty) return heroAvatar;

    return GestureDetector(
      onTap: () => showMemberPhotoViewer(context, photoBytes, heroTag!),
      child: heroAvatar,
    );
  }
}
