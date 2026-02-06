import 'package:flutter/material.dart';
import 'toast_meta.dart';
import '/localization/ny_localization.dart';

/// [DefaultToastNotification] a simple toast notification.
/// This is the fallback widget used when no custom toast styles are registered.
class DefaultToastNotification extends StatelessWidget {
  const DefaultToastNotification(ToastMeta toastMeta, {super.key})
    : _toastMeta = toastMeta;

  final ToastMeta _toastMeta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Apply default styling for success if not set
    final icon =
        _toastMeta.icon ??
        const Icon(Icons.check, color: Colors.green, size: 20);
    final iconBackgroundColor = _toastMeta.color ?? Colors.green.shade50;
    final title = _toastMeta.title.isEmpty ? 'Success' : _toastMeta.title;

    // Theme-derived colors
    final backgroundColor = isDark ? colorScheme.surface : Colors.white;
    final titleColor = isDark
        ? Colors.white.withAlpha(204)
        : colorScheme.onSurface;
    final descriptionColor = isDark
        ? Colors.white70
        : colorScheme.onSurface.withAlpha(153);
    final dismissButtonBackground = isDark
        ? Colors.white30
        : colorScheme.surfaceContainerHighest;
    final dismissIconColor = isDark
        ? Colors.white
        : colorScheme.onSurface.withAlpha(140);
    final shadowColor = isDark ? Colors.black12 : Colors.grey.withAlpha(25);

    return Semantics(
      label: '$title: ${_toastMeta.description}',
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          constraints: const BoxConstraints(minHeight: 80, maxHeight: 120),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _toastMeta.action,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon section
                  ExcludeSemantics(
                    child: Container(
                      width: 50,
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          topLeft: Radius.circular(8),
                        ),
                      ),
                      child: Center(child: icon),
                    ),
                  ),
                  // Content section
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title.tr(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: titleColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_toastMeta.description.isNotEmpty)
                            Flexible(
                              child: Text(
                                _toastMeta.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: descriptionColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Dismiss button
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: dismissButtonBackground,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          tooltip: 'Dismiss notification',
                          onPressed: _toastMeta.dismiss,
                          icon: Icon(
                            Icons.close,
                            color: dismissIconColor,
                            size: 18,
                          ),
                        ),
                      ),
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
