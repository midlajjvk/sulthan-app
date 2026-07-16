import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Opens a full-screen Hero-animated circular photo viewer.
///
/// Does nothing when [photoBytes] is null or empty — no viewer is shown.
///
/// [heroTag] must match the tag used in the originating [Hero] widget so
/// Flutter can animate between the two positions automatically.
void showMemberPhotoViewer(
  BuildContext context,
  Uint8List? photoBytes,
  String heroTag,
) {
  if (photoBytes == null || photoBytes.isEmpty) return;

  Navigator.of(context).push(
    _FadePageRoute(
      child: _MemberPhotoViewer(
        photoBytes: photoBytes,
        heroTag: heroTag,
      ),
    ),
  );
}

// ── Custom page route ─────────────────────────────────────────────────────────

/// A [PageRoute] whose barrier fades to black while the Hero flies in.
/// No default slide transition — the Hero animation dominates.
class _FadePageRoute extends PageRoute<void> {
  _FadePageRoute({required this.child});

  final Widget child;

  @override
  Color get barrierColor => Colors.black;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 280);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: child,
    );
  }
}

// ── Full-screen circular viewer ───────────────────────────────────────────────

/// Diameter of the circular frame shown in the viewer.
const double _kCircleDiameter = 340.0;

class _MemberPhotoViewer extends StatefulWidget {
  final Uint8List photoBytes;
  final String heroTag;

  const _MemberPhotoViewer({
    required this.photoBytes,
    required this.heroTag,
  });

  @override
  State<_MemberPhotoViewer> createState() => _MemberPhotoViewerState();
}

class _MemberPhotoViewerState extends State<_MemberPhotoViewer>
    with SingleTickerProviderStateMixin {
  late final TransformationController _transformCtrl;
  late final AnimationController _doubleTapAnimCtrl;
  Animation<Matrix4>? _doubleTapAnimation;

  TapDownDetails? _lastDoubleTapDetails;
  bool _isZoomed = false;

  static const double _minScale = 1.0;
  static const double _maxScale = 4.0;
  static const double _doubleTapScale = 2.5;

  @override
  void initState() {
    super.initState();
    _transformCtrl = TransformationController();
    _doubleTapAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        if (_doubleTapAnimation != null) {
          _transformCtrl.value = _doubleTapAnimation!.value;
        }
      });
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    _doubleTapAnimCtrl.dispose();
    super.dispose();
  }

  void _dismiss() => Navigator.of(context).pop();

  void _onDoubleTap() {
    final Matrix4 end;

    if (_isZoomed) {
      end = Matrix4.identity();
    } else {
      final Offset tapPos =
          _lastDoubleTapDetails?.localPosition ?? Offset.zero;
      final double dx = -tapPos.dx * (_doubleTapScale - 1);
      final double dy = -tapPos.dy * (_doubleTapScale - 1);
      end = Matrix4.identity()
        ..setEntry(0, 0, _doubleTapScale)
        ..setEntry(1, 1, _doubleTapScale)
        ..setEntry(0, 3, dx)
        ..setEntry(1, 3, dy);
    }

    _doubleTapAnimation = Matrix4Tween(
      begin: _transformCtrl.value,
      end: end,
    ).animate(CurvedAnimation(
      parent: _doubleTapAnimCtrl,
      curve: Curves.easeInOut,
    ));

    _doubleTapAnimCtrl.forward(from: 0);
    setState(() => _isZoomed = !_isZoomed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        // Tapping the black area outside the circle closes the viewer.
        onTap: _dismiss,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Hero(
            tag: widget.heroTag,
            // The shuttle stays a perfect circle throughout the whole flight
            // (both push and pop), matching the CircleAvatar source.
            flightShuttleBuilder: (
              flightContext,
              animation,
              flightDirection,
              fromHeroContext,
              toHeroContext,
            ) {
              return ClipOval(
                child: Image.memory(
                  widget.photoBytes,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              );
            },
            child: _CircularViewer(
              photoBytes: widget.photoBytes,
              transformCtrl: _transformCtrl,
              minScale: _minScale,
              maxScale: _maxScale,
              onDoubleTapDown: (d) => _lastDoubleTapDetails = d,
              onDoubleTap: _onDoubleTap,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Circular frame with InteractiveViewer ─────────────────────────────────────

class _CircularViewer extends StatelessWidget {
  final Uint8List photoBytes;
  final TransformationController transformCtrl;
  final double minScale;
  final double maxScale;
  final ValueChanged<TapDownDetails> onDoubleTapDown;
  final VoidCallback onDoubleTap;

  const _CircularViewer({
    required this.photoBytes,
    required this.transformCtrl,
    required this.minScale,
    required this.maxScale,
    required this.onDoubleTapDown,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Absorb taps on the circle so they do NOT propagate to the outer
      // dismiss handler — only the black area outside should close the viewer.
      onTap: () {},
      onDoubleTapDown: onDoubleTapDown,
      onDoubleTap: onDoubleTap,
      child: Container(
        width: _kCircleDiameter,
        height: _kCircleDiameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Subtle white semi-transparent border.
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.35),
            width: 2.5,
          ),
          // Soft shadow around the circle.
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 32,
              spreadRadius: 4,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.06),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipOval(
          child: InteractiveViewer(
            transformationController: transformCtrl,
            minScale: minScale,
            maxScale: maxScale,
            // Clip to the circle boundary — do not let zoomed content
            // bleed outside the circular frame.
            clipBehavior: Clip.hardEdge,
            child: Image.memory(
              photoBytes,
              width: _kCircleDiameter,
              height: _kCircleDiameter,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
        ),
      ),
    );
  }
}

// Inline lerp helper — kept for any future callers in this file.
double _lerpDouble(num a, num b, double t) => a + (b - a) * t;
// ignore: unused_element
double? lerpDouble(num a, num b, double t) => _lerpDouble(a, b, t);
