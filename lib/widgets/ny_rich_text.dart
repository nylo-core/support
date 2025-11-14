import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// NyRichText allows you to display rich text with different styles.
///
/// Example using children:
/// ```dart
/// NyRichText(
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
/// NyRichText.template(
///   text: "Hello {{name}}, welcome to {{app}}!",
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
/// NyRichText.template(
///   text: "Learn {{Korean}}, {{Japanese}} and {{English}}!",
///   styles: {
///     "Korean|Japanese|Thai|English": TextStyle(
///       color: Colors.blue,
///       fontWeight: FontWeight.bold
///     ),
///   },
///   onTap: {
///     "Korean|Japanese": () => print("Asian language tapped"),
///     "English": () => print("Other language tapped"),
///   }
/// )
/// ```
class NyRichText extends StatelessWidget {
  const NyRichText({
    super.key,
    required this.children,
    this.style = const TextStyle(color: Colors.black),
    this.onEnter,
    this.onExit,
    this.spellOut,
    this.softWrap = true,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  })  : text = null,
        styles = null,
        onTap = null;

  const NyRichText.template({
    super.key,
    required this.text,
    this.styles,
    this.onTap,
    this.style = const TextStyle(color: Colors.black),
    this.spellOut,
    this.softWrap = true,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  })  : children = null,
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
  final void Function(Text text, PointerEnterEvent event)? onEnter;
  final void Function(Text text, PointerExitEvent event)? onExit;

  @override
  Widget build(BuildContext context) {
    return RichText(
      softWrap: softWrap,
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow,
      text: TextSpan(text: "", style: style, children: textSpans),
    );
  }

  /// Returns a list of [TextSpan] from the [children] provided or from template text.
  List<TextSpan> get textSpans {
    if (text != null) {
      return _parseTemplateText();
    }

    if (children != null) {
      return _parseChildrenText();
    }

    return [];
  }

  /// Parses template text with placeholders like "Hello {{name}}"
  List<TextSpan> _parseTemplateText() {
    List<TextSpan> spans = [];
    String currentText = text!;

    // Regular expression to match {{placeholder}} patterns
    RegExp regExp = RegExp(r'\{\{([^}]+)\}\}');
    int lastEnd = 0;

    for (Match match in regExp.allMatches(currentText)) {
      // Add text before the placeholder
      if (match.start > lastEnd) {
        String beforeText = currentText.substring(lastEnd, match.start);
        spans.add(TextSpan(
          text: beforeText,
          style: style,
          spellOut: spellOut,
        ));
      }

      // Add the placeholder text with custom style and tap handler
      String placeholder = match.group(1)!;
      TextStyle? placeholderStyle = _getStyleForPlaceholder(placeholder);
      VoidCallback? tapCallback = _getTapCallbackForPlaceholder(placeholder);

      spans.add(TextSpan(
        text: placeholder,
        style: placeholderStyle,
        spellOut: spellOut,
        recognizer: tapCallback != null
            ? (TapGestureRecognizer()..onTap = tapCallback)
            : null,
      ));

      lastEnd = match.end;
    }

    // Add remaining text after the last placeholder
    if (lastEnd < currentText.length) {
      String remainingText = currentText.substring(lastEnd);
      spans.add(TextSpan(
        text: remainingText,
        style: style,
        spellOut: spellOut,
      ));
    }

    return spans;
  }

  /// Gets the style for a placeholder, supporting pipe-separated keys
  TextStyle? _getStyleForPlaceholder(String placeholder) {
    if (styles == null) return style;

    // First check for exact match
    if (styles!.containsKey(placeholder)) {
      return styles![placeholder];
    }

    // Then check for pipe-separated keys
    for (String key in styles!.keys) {
      if (key.contains('|')) {
        List<String> keyParts = key.split('|').map((e) => e.trim()).toList();
        if (keyParts.contains(placeholder)) {
          return styles![key];
        }
      }
    }

    return style;
  }

  /// Gets the tap callback for a placeholder, supporting pipe-separated keys
  VoidCallback? _getTapCallbackForPlaceholder(String placeholder) {
    if (onTap == null) return null;

    // First check for exact match
    if (onTap!.containsKey(placeholder)) {
      return onTap![placeholder];
    }

    // Then check for pipe-separated keys
    for (String key in onTap!.keys) {
      if (key.contains('|')) {
        List<String> keyParts = key.split('|').map((e) => e.trim()).toList();
        if (keyParts.contains(placeholder)) {
          return onTap![key];
        }
      }
    }

    return null;
  }

  /// Parses children text widgets
  List<TextSpan> _parseChildrenText() {
    List<TextSpan> textSpans = [];
    for (Text child in children!) {
      textSpans.add(TextSpan(
        text: child.data,
        style: child.style ?? style,
        spellOut: spellOut,
        onEnter: (event) {
          if (onEnter == null) return;
          onEnter!(child, event);
        },
        onExit: (event) {
          if (onExit == null) return;
          onExit!(child, event);
        },
      ));
    }
    return textSpans;
  }
}
