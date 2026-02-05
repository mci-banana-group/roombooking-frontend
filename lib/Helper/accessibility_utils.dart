import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Helper class for accessibility features and screen reader support
class AccessibilityAnnouncer {
  /// Announces a message to screen readers
  static void announce(String message) {
    // ignore: deprecated_member_use
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Announces a message with a delay (useful for after navigation)
  static void announceDelayed(String message, {Duration delay = const Duration(milliseconds: 500)}) {
    Future.delayed(delay, () {
      announce(message);
    });
  }
}

/// Extension methods for BuildContext to easily announce messages
extension AccessibilityContextExtension on BuildContext {
  /// Announces a message to screen readers
  void announce(String message) {
    AccessibilityAnnouncer.announce(message);
  }
}

/// Widget that wraps content with proper semantics for screen readers
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  const AccessibleCard({super.key, required this.child, required this.label, this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: label,
      value: value,
      button: onTap != null,
      onTap: onTap,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              child: Card(child: child),
            )
          : Card(child: child),
    );
  }
}

/// Widget that wraps a button with proper semantics
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final String label;
  final String? hint;
  final VoidCallback? onPressed;
  final bool isSelected;

  const AccessibleButton({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    this.onPressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      hint: hint,
      enabled: onPressed != null,
      selected: isSelected,
      child: child,
    );
  }
}

/// Widget that wraps an icon button with tooltip and semantic label
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.tooltip,
    this.onPressed,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, semanticLabel: semanticLabel, color: color, size: size),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}

/// Widget that provides a live region for dynamic content updates
class LiveRegion extends StatelessWidget {
  final Widget child;
  final bool assertive;

  const LiveRegion({super.key, required this.child, this.assertive = false});

  @override
  Widget build(BuildContext context) {
    return Semantics(liveRegion: true, child: child);
  }
}

/// Widget that wraps form fields with proper accessibility
class AccessibleFormField extends StatelessWidget {
  final Widget child;
  final String label;
  final String? value;
  final String? hint;
  final bool isRequired;
  final String? error;

  const AccessibleFormField({
    super.key,
    required this.child,
    required this.label,
    this.value,
    this.hint,
    this.isRequired = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final fullLabel = isRequired ? '$label (required)' : label;
    final fullValue = error != null ? '$value, Error: $error' : value;

    return Semantics(textField: true, label: fullLabel, value: fullValue, hint: hint, child: child);
  }
}

/// Widget that provides a header semantics for page sections
class AccessibleHeader extends StatelessWidget {
  final Widget child;
  final String label;

  const AccessibleHeader({super.key, required this.child, required this.label});

  @override
  Widget build(BuildContext context) {
    return Semantics(header: true, label: label, child: child);
  }
}

/// Widget that wraps an image with proper semantic labeling
class AccessibleImage extends StatelessWidget {
  final Widget child;
  final String label;

  const AccessibleImage({super.key, required this.child, required this.label});

  @override
  Widget build(BuildContext context) {
    return Semantics(image: true, label: label, child: child);
  }
}
