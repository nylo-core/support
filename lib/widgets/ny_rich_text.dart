import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// NyRichText allows you to display rich text with different styles.
/// Example:
/// ```dart
/// NyRichText(
///  children: [
///   Text("Hello", style: TextStyle(color: Colors.red)),
///   Text("World", style: TextStyle(color: Colors.blue)),
///   Text("!")
///   ]
/// )
/// ```
class NyRichText extends StatelessWidget {
  NyRichText(
      {Key? key,
      required this.children,
      this.style,
      this.onEnter,
      this.onExit,
      this.spellOut,
      this.softWrap = true,
      this.textAlign = TextAlign.start,
      this.textDirection,
      this.maxLines,
      this.overflow = TextOverflow.clip})
      : super(key: key);

  final bool? spellOut;
  final TextStyle? style;
  final List<Text> children;
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

  /// Returns a list of [TextSpan] from the [children] provided.
  List<TextSpan> get textSpans {
    List<TextSpan> textSpans = [];
    for (Text child in children) {
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
