import 'package:flutter/material.dart';

import '../theme.dart';

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final subtitleWidget = subtitle == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(height: 1.4),
            ),
          );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 17, 20, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(eyebrow),
                const SizedBox(height: 7),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                ?subtitleWidget,
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color = ReflexColors.orange});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: color,
        fontSize: 10,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
    this.height = 54,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          boxShadow: onPressed == null
              ? null
              : [
                  BoxShadow(
                    color: ReflexColors.orange.withValues(alpha: 0.24),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: ReflexColors.orange,
            foregroundColor: const Color(0xFF17120E),
            disabledBackgroundColor: ReflexColors.orange.withValues(
              alpha: 0.35,
            ),
            disabledForegroundColor: ReflexColors.text.withValues(alpha: 0.55),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.65,
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, size: 19),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor = ReflexColors.line,
    this.radius = 22,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: ReflexColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: child,
    );
  }
}

class PhotoCover extends StatelessWidget {
  const PhotoCover({
    required this.url,
    required this.height,
    this.borderRadius = 18,
    this.overlay,
    super.key,
  });

  final String url;
  final double height;
  final double borderRadius;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    final overlayWidget = overlay;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: ReflexColors.surfaceRaised,
                alignment: Alignment.center,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      color: ReflexColors.muted,
                      size: 25,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Imagen no disponible',
                      style: TextStyle(color: ReflexColors.muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
            ?overlayWidget,
          ],
        ),
      ),
    );
  }
}

class PriceLabel extends StatelessWidget {
  const PriceLabel({required this.price, super.key});

  final String price;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: 'Desde ',
            style: TextStyle(
              color: ReflexColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: price,
            style: const TextStyle(
              color: ReflexColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class TagPill extends StatelessWidget {
  const TagPill(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3028),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: ReflexColors.orangeLight,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
