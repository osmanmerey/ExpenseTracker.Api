import 'package:flutter/material.dart';

/// Shared metrics so type / currency / sort / date-range controls stay aligned
/// in TR and EN, selected or not.
abstract final class AppFilterMetrics {
  static const double height = 44;
  static const double iconSize = 18;
  static const double iconGap = 8;
  static const double groupGap = 8;
  static const double radius = 20;
  static const double borderWidth = 1.5;
  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 12);
}

/// Selectable filter / sort control with a reserved check slot so selection
/// never changes the chip size. Color, border, and icon are the only deltas.
class AppFilterChip extends StatefulWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.leadingIcon,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final IconData? leadingIcon;
  final bool enabled;

  @override
  State<AppFilterChip> createState() => _AppFilterChipState();
}

class _AppFilterChipState extends State<AppFilterChip> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _interactive => widget.enabled && widget.onSelected != null;

  void _activate() {
    if (!_interactive) return;
    widget.onSelected!(!widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selected = widget.selected;
    final disabled = !_interactive;

    final borderColor = disabled
        ? colors.outline.withValues(alpha: 0.4)
        : selected
            ? colors.primary
            : _focused
                ? colors.primary
                : colors.outline;
    final fill = disabled
        ? colors.surfaceContainerHighest.withValues(alpha: 0.4)
        : selected
            ? colors.primaryContainer
            : _hovered || _pressed
                ? colors.surfaceContainerHighest
                : colors.surfaceContainerHigh;
    final foreground = disabled
        ? colors.onSurface.withValues(alpha: 0.38)
        : selected
            ? colors.onPrimaryContainer
            : colors.onSurface;

    final icon = widget.leadingIcon ?? (selected ? Icons.check : null);

    return Semantics(
      button: true,
      enabled: _interactive,
      selected: selected,
      toggled: selected,
      label: widget.label,
      onTap: _interactive ? _activate : null,
      child: FocusableActionDetector(
        enabled: _interactive,
        mouseCursor: _interactive
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowHoverHighlight: (hovered) => setState(() => _hovered = hovered),
        onShowFocusHighlight: (focused) => setState(() => _focused = focused),
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
          ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        child: GestureDetector(
          onTapDown: _interactive ? (_) => setState(() => _pressed = true) : null,
          onTapUp: _interactive ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: _interactive ? () => setState(() => _pressed = false) : null,
          onTap: _interactive ? _activate : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            constraints: BoxConstraints(
              minHeight: AppFilterMetrics.height,
              maxHeight: AppFilterMetrics.height,
              maxWidth: MediaQuery.sizeOf(context).width - 32,
            ),
            padding: AppFilterMetrics.padding,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(AppFilterMetrics.radius),
              border: Border.all(
                color: _focused && !disabled
                    ? colors.primary
                    : borderColor,
                width: AppFilterMetrics.borderWidth,
              ),
            ),
            child: ExcludeSemantics(
              child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: AppFilterMetrics.iconSize,
                  height: AppFilterMetrics.iconSize,
                  child: icon == null
                      ? null
                      : Icon(
                          icon,
                          size: AppFilterMetrics.iconSize,
                          color: foreground,
                        ),
                ),
                const SizedBox(width: AppFilterMetrics.iconGap),
                Text(
                  widget.label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: foreground,
                        height: 1.2,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Same chrome as [AppFilterChip] for one-shot actions (date range).
class AppFilterActionButton extends StatefulWidget {
  const AppFilterActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.date_range_outlined,
    this.selected = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool selected;
  final bool enabled;

  @override
  State<AppFilterActionButton> createState() => _AppFilterActionButtonState();
}

class _AppFilterActionButtonState extends State<AppFilterActionButton> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _interactive => widget.enabled && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selected = widget.selected;
    final disabled = !_interactive;
    final foreground = disabled
        ? colors.onSurface.withValues(alpha: 0.38)
        : selected
            ? colors.onPrimaryContainer
            : colors.onSurface;
    final fill = disabled
        ? colors.surfaceContainerHighest.withValues(alpha: 0.4)
        : selected
            ? colors.primaryContainer
            : _hovered || _pressed
                ? colors.surfaceContainerHighest
                : colors.surfaceContainerHigh;

    return Semantics(
      button: true,
      enabled: _interactive,
      selected: selected,
      label: widget.label,
      onTap: _interactive ? widget.onPressed : null,
      child: FocusableActionDetector(
        enabled: _interactive,
        mouseCursor: _interactive
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowHoverHighlight: (hovered) => setState(() => _hovered = hovered),
        onShowFocusHighlight: (focused) => setState(() => _focused = focused),
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          onTapDown: _interactive ? (_) => setState(() => _pressed = true) : null,
          onTapUp: _interactive ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: _interactive ? () => setState(() => _pressed = false) : null,
          onTap: _interactive ? widget.onPressed : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            constraints: const BoxConstraints(
              minHeight: AppFilterMetrics.height,
              maxHeight: AppFilterMetrics.height,
            ),
            padding: AppFilterMetrics.padding,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(AppFilterMetrics.radius),
              border: Border.all(
                color: _focused && !disabled
                    ? colors.primary
                    : selected
                        ? colors.primary
                        : colors.outline,
                width: AppFilterMetrics.borderWidth,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: AppFilterMetrics.iconSize,
                  height: AppFilterMetrics.iconSize,
                  child: Icon(
                    widget.icon,
                    size: AppFilterMetrics.iconSize,
                    color: foreground,
                  ),
                ),
                const SizedBox(width: AppFilterMetrics.iconGap),
                Flexible(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: foreground,
                          height: 1.2,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
