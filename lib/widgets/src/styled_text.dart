import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// StyledText allows you to display rich text with different styles.
///
/// Example using children:
/// ```dart
/// StyledText(
///  children: [
///   Text("Hello", style: TextStyle(color: Colors.red)),
///   Text("World", style: TextStyle(color: Colors.blue)),
///   Text("!")
///   ]
/// )
/// ```
///
/// Example using template text:
/// ```dart
/// StyledText.template(
///   "Hello {{name}}, welcome to {{app}}!",
///   styles: {
///     "name": TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
///     "app": TextStyle(color: Colors.green),
///   },
///   onTap: {
///     "name": () => print("Name tapped"),
///     "app": () => print("App tapped"),
///   }
/// )
/// ```
///
/// Example using template text with pipe-separated styles:
/// ```dart
/// StyledText.template(
///   text: "Learn {{Korean}}, {{Japanese}}, {{Thai}} and {{English}}!",
///   styles: {
///     "Korean|Japanese|Thai|English": TextStyle(
///       color: Colors.blue,
///       fontWeight: FontWeight.bold
///     ),
///   },
///   onTap: {
///     "Korean|Japanese": () => print("Asian language tapped"),
///     "Thai|English": () => print("Other language tapped"),
///   }
/// )
/// ```
///
/// Example using wildcard `*` to style all placeholders:
/// ```dart
/// StyledText.template(
///   "Hello {{name}}, welcome to {{app}}!",
///   styles: {
///     "*": TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
///   },
/// )
/// ```
///
/// Example using template text with localization (`{{key:text}}` syntax):
/// ```dart
/// StyledText.template(
///   "learn_skills".tr(),
///   // en: "Learn {{lang:Languages}}, {{read:Reading}} and {{speak:Speaking}} in {{app:AppName}}"
///   // es: "Aprende {{lang:Idiomas}}, {{read:Lectura}} y {{speak:Habla}} en {{app:AppName}}"
///   styles: {
///     "lang|read|speak": TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
///     "app": TextStyle(color: Colors.green),
///   },
/// )
/// ```
class StyledText extends StatefulWidget {
  const StyledText({
    super.key,
    required this.children,
    this.style,
    this.onEnter,
    this.onExit,
    this.spellOut,
    this.softWrap = true,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.locale,
    this.strutStyle,
    this.textScaler,
    this.selectionColor,
  }) : text = null,
       styles = null,
       onTap = null;

  const StyledText.template(
    this.text, {
    super.key,
    this.styles,
    this.onTap,
    this.style,
    this.spellOut,
    this.softWrap = true,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.locale,
    this.strutStyle,
    this.textScaler,
    this.selectionColor,
  }) : children = null,
       onEnter = null,
       onExit = null;

  final bool? spellOut;
  final TextStyle? style;
  final List<Text>? children;
  final String? text;
  final Map<String, TextStyle>? styles;
  final Map<String, VoidCallback>? onTap;
  final bool softWrap;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final int? maxLines;
  final TextOverflow overflow;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextScaler? textScaler;
  final Color? selectionColor;
  final void Function(Text text, PointerEnterEvent event)? onEnter;
  final void Function(Text text, PointerExitEvent event)? onExit;

  @override
  State<StyledText> createState() => _StyledTextState();
}

class _StyledTextState extends State<StyledText> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(StyledText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.onTap != widget.onTap) {
      for (final recognizer in _recognizers) {
        recognizer.dispose();
      }
      _recognizers.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      softWrap: widget.softWrap,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      locale: widget.locale,
      strutStyle: widget.strutStyle,
      textScaler: widget.textScaler ?? MediaQuery.textScalerOf(context),
      selectionColor: widget.selectionColor,
      text: TextSpan(text: "", style: widget.style, children: _textSpans),
    );
  }

  List<TextSpan> get _textSpans {
    if (widget.text != null) {
      return _parseTemplateText();
    }

    if (widget.children != null) {
      return _parseChildrenText();
    }

    return [];
  }

  /// Looks up a value from a map supporting pipe-separated keys.
  T? _lookupWithPipeKeys<T>(Map<String, T>? map, String placeholder) {
    if (map == null) return null;

    // First check for exact match
    if (map.containsKey(placeholder)) {
      return map[placeholder];
    }

    // Then check for pipe-separated keys
    for (final entry in map.entries) {
      if (entry.key.contains('|')) {
        final keyParts = entry.key.split('|').map((e) => e.trim()).toList();
        if (keyParts.contains(placeholder)) {
          return entry.value;
        }
      }
    }

    // Wildcard fallback
    if (map.containsKey('*')) {
      return map['*'];
    }

    return null;
  }

  List<TextSpan> _parseTemplateText() {
    final spans = <TextSpan>[];
    final currentText = widget.text!;
    final regExp = RegExp(r'\{\{([^}]+)\}\}');
    int lastEnd = 0;

    for (final match in regExp.allMatches(currentText)) {
      // Add text before the placeholder
      if (match.start > lastEnd) {
        final beforeText = currentText.substring(lastEnd, match.start);
        spans.add(
          TextSpan(
            text: beforeText,
            style: widget.style,
            spellOut: widget.spellOut,
          ),
        );
      }

      // Add the placeholder text with custom style and tap handler
      final raw = match.group(1)!;
      final colonIndex = raw.indexOf(':');
      final String key;
      final String displayText;
      if (colonIndex != -1) {
        key = raw.substring(0, colonIndex);
        displayText = raw.substring(colonIndex + 1);
      } else {
        key = raw;
        displayText = raw;
      }
      final placeholderStyle =
          _lookupWithPipeKeys(widget.styles, key) ?? widget.style;
      final tapCallback = _lookupWithPipeKeys(widget.onTap, key);

      TapGestureRecognizer? recognizer;
      if (tapCallback != null) {
        recognizer = TapGestureRecognizer()..onTap = tapCallback;
        _recognizers.add(recognizer);
      }

      spans.add(
        TextSpan(
          text: displayText,
          style: placeholderStyle,
          spellOut: widget.spellOut,
          recognizer: recognizer,
        ),
      );

      lastEnd = match.end;
    }

    // Add remaining text after the last placeholder
    if (lastEnd < currentText.length) {
      final remainingText = currentText.substring(lastEnd);
      spans.add(
        TextSpan(
          text: remainingText,
          style: widget.style,
          spellOut: widget.spellOut,
        ),
      );
    }

    return spans;
  }

  List<TextSpan> _parseChildrenText() {
    final textSpans = <TextSpan>[];
    for (final child in widget.children!) {
      textSpans.add(
        TextSpan(
          text: child.data,
          style: child.style ?? widget.style,
          spellOut: widget.spellOut,
          onEnter: widget.onEnter != null
              ? (event) => widget.onEnter!(child, event)
              : null,
          onExit: widget.onExit != null
              ? (event) => widget.onExit!(child, event)
              : null,
        ),
      );
    }
    return textSpans;
  }
}
