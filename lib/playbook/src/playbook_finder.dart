import 'dart:ui' show FlutterView;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:recase/recase.dart';

/// Precise targets for playbook steps, for when a plain string is ambiguous.
///
/// ```dart
/// tap(Find.icon(Icons.add)),
/// tap(Find.text('Delete').inside(Find.type<Card>()).at(1)),
/// type(Find.field('email'), 'demo@nylo.dev'),
/// ```
abstract final class Find {
  /// A widget showing exactly [text]: a `Text`, a standalone `RichText`, or
  /// the contents of a text field.
  static PlaybookFinder text(String text) => _TextFinder(text);

  /// A widget whose text contains [text].
  static PlaybookFinder textContaining(String text) =>
      _TextFinder(text, contains: true);

  /// The widget with [key].
  static PlaybookFinder key(Key key) => _KeyFinder(key);

  /// Widgets of type [T] (exactly, not subclasses).
  static PlaybookFinder type<T extends Widget>() => _TypeFinder(T);

  /// Widgets whose runtime type is [type].
  static PlaybookFinder byType(Type type) => _TypeFinder(type);

  /// An `Icon` showing [icon].
  ///
  /// Give it a [label] to name it in captions and reports:
  /// `Find.icon(Icons.shopping_bag_outlined, label: 'bag')` reads
  /// `Tap the bag icon` instead of `Tap icon f37d`.
  static PlaybookFinder icon(IconData icon, {String? label}) =>
      _IconFinder(icon, label: label);

  /// The widget a `Tooltip` with [message] wraps, like an `IconButton`.
  static PlaybookFinder tooltip(String message) => _TooltipFinder(message);

  /// A `Semantics` widget labelled [label].
  static PlaybookFinder semantics(String label) => _SemanticsFinder(label);

  /// The [NyForm] field called [name], e.g. `Find.field('email')`.
  static PlaybookFinder field(String name) => _KeyFinder(
    ValueKey<String>('form_field_${ReCase(name).snakeCase}'),
    label: 'field "$name"',
  );

  /// A text field with the hint, label or placeholder [text].
  static PlaybookFinder input(String text) => _InputFinder(text);

  /// Widgets that pass [test].
  static PlaybookFinder where(
    bool Function(Widget widget) test, {
    String description = 'matching widget',
  }) => _WhereFinder(test, description);

  /// The finder for a loose step [target]: a [String], [Key], [Type],
  /// [IconData] or [PlaybookFinder].
  ///
  /// A [String] is resolved the way a person reads the screen; see
  /// [PlaybookFinder.target]. Throws an [ArgumentError] for anything else.
  static PlaybookFinder target(Object target) => switch (target) {
    final PlaybookFinder finder => finder,
    final String text => _ReadingFinder(text),
    final Key key => _KeyFinder(key),
    final Type type => _TypeFinder(type),
    final IconData icon => _IconFinder(icon),
    _ => throw ArgumentError.value(
      target,
      'target',
      'must be a String, Key, Type, IconData or PlaybookFinder',
    ),
  };
}

/// Finds widgets on screen for a playbook step.
///
/// Make one with [Find], or pass a plain target to a step and let
/// [Find.target] make it.
abstract class PlaybookFinder {
  /// Creates a [PlaybookFinder].
  const PlaybookFinder();

  /// A short description used in step titles and errors, e.g. `"Log out"`.
  String get description;

  /// The matching elements in [tree], in the order they appear on screen.
  List<Element> find(PlaybookTree tree);

  /// The matches that are, or are inside, a text field, best first.
  ///
  /// `type()` uses this, so `type('Email', ...)` reaches the field whose
  /// hint is "Email" rather than the hint's own `Text`.
  List<Element> findFields(PlaybookTree tree) => find(tree);

  /// Only the matches inside something [ancestor] finds.
  PlaybookFinder inside(PlaybookFinder ancestor) =>
      _InsideFinder(this, ancestor);

  /// Only the match at [index], counting from 0.
  PlaybookFinder at(int index) => _AtFinder(this, index);

  /// Only the first match.
  PlaybookFinder get first => at(0);

  /// Only the last match.
  PlaybookFinder get last => _AtFinder(this, -1);

  @override
  String toString() => description;
}

/// A snapshot of the elements on screen, taken once per lookup.
///
/// Offstage widgets, like pages under the current one, are left out, and so
/// is the playbook's own overlay.
class PlaybookTree {
  /// Collects the onstage elements under [root].
  PlaybookTree(Element? root) {
    if (root != null) _collect(root);
  }

  /// Every onstage element, in tree order.
  final List<Element> elements = [];

  void _collect(Element element) {
    if (element.widget is PlaybookOverlayScope) return;
    elements.add(element);
    element.debugVisitOnstageChildren(_collect);
  }

  /// The text a person reads on screen, top to bottom and left to right,
  /// for error messages.
  List<String> visibleText({int max = 15}) {
    final List<({String text, Rect rect})> shown = [];
    for (final Element element in elements) {
      final String? text = _readableText(element);
      if (text == null || text.trim().isEmpty) continue;
      final Rect? rect = playbookVisibleRect(element);
      if (rect == null) continue;
      shown.add((text: text.replaceAll('\n', ' ').trim(), rect: rect));
    }
    shown.sort((a, b) {
      final int row = (a.rect.top - b.rect.top).abs() < 4
          ? 0
          : a.rect.top.compareTo(b.rect.top);
      return row != 0 ? row : a.rect.left.compareTo(b.rect.left);
    });
    final List<String> texts = [];
    for (final ({String text, Rect rect}) entry in shown) {
      if (!texts.contains(entry.text)) texts.add(entry.text);
      if (texts.length >= max) break;
    }
    return texts;
  }
}

/// Marks the playbook overlay, so finders never match its caption.
class PlaybookOverlayScope extends StatelessWidget {
  /// Wraps [child].
  const PlaybookOverlayScope({super.key, required this.child});

  /// The overlay's content.
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// The part of [element] that is on screen, in global coordinates, or null
/// when none of it is.
///
/// The box is clipped to the screen and to every scrollable it sits in.
Rect? playbookVisibleRect(Element element) {
  if (!element.mounted) return null;
  final RenderObject? object = element.renderObject;
  if (object is! RenderBox || !object.attached || !object.hasSize) {
    return null;
  }
  Rect rect;
  try {
    rect = MatrixUtils.transformRect(
      object.getTransformTo(null),
      Offset.zero & object.size,
    );
  } catch (_) {
    return null;
  }

  final FlutterView? view = View.maybeOf(element);
  if (view != null) {
    rect = rect.intersect(
      Offset.zero & (view.physicalSize / view.devicePixelRatio),
    );
  }
  element.visitAncestorElements((Element ancestor) {
    final RenderObject? render = ancestor is RenderObjectElement
        ? ancestor.renderObject
        : null;
    if (render is RenderViewportBase && render.attached && render.hasSize) {
      rect = rect.intersect(
        MatrixUtils.transformRect(
          render.getTransformTo(null),
          Offset.zero & render.size,
        ),
      );
    }
    return true;
  });
  if (rect.width < 1 || rect.height < 1) return null;
  return rect;
}

/// The text [element]'s widget shows, when it shows text.
String? _readableText(Element element) {
  final Widget widget = element.widget;
  if (widget is Text) return widget.data ?? widget.textSpan?.toPlainText();
  if (widget is RichText) {
    return _builtByText(element) ? null : widget.text.toPlainText();
  }
  if (widget is EditableText) {
    return widget.obscureText ? null : widget.controller.text;
  }
  return null;
}

/// Whether the `RichText` [element] was built by a `Text` just above it.
bool _builtByText(Element element) {
  bool found = false;
  int depth = 0;
  element.visitAncestorElements((Element ancestor) {
    if (ancestor.widget is Text) {
      found = true;
      return false;
    }
    return ++depth < 4;
  });
  return found;
}

String _quote(String text) => '"$text"';

class _TextFinder extends PlaybookFinder {
  const _TextFinder(this.text, {this.contains = false});

  final String text;
  final bool contains;

  @override
  String get description =>
      contains ? 'text containing ${_quote(text)}' : _quote(text);

  @override
  List<Element> find(PlaybookTree tree) => [
    for (final Element element in tree.elements)
      if (_readableText(element) case final String shown?)
        if (contains ? shown.contains(text) : shown.trim() == text.trim())
          element,
  ];
}

class _InputFinder extends PlaybookFinder {
  const _InputFinder(this.text);

  final String text;

  @override
  String get description => 'field ${_quote(text)}';

  @override
  List<Element> find(PlaybookTree tree) => [
    for (final Element element in tree.elements)
      if (_inputLabels(element.widget).contains(text.trim())) element,
  ];

  static List<String> _inputLabels(Widget widget) {
    if (widget is InputDecorator) {
      final InputDecoration decoration = widget.decoration;
      return [?decoration.hintText?.trim(), ?decoration.labelText?.trim()];
    }
    if (widget is CupertinoTextField) {
      return [?widget.placeholder?.trim()];
    }
    return const [];
  }
}

class _TooltipFinder extends PlaybookFinder {
  const _TooltipFinder(this.message);

  final String message;

  @override
  String get description => 'tooltip ${_quote(message)}';

  @override
  List<Element> find(PlaybookTree tree) => [
    for (final Element element in tree.elements)
      if (element.widget case Tooltip(message: final String? shown))
        if (shown?.trim() == message.trim()) element,
  ];
}

class _SemanticsFinder extends PlaybookFinder {
  const _SemanticsFinder(this.label);

  final String label;

  @override
  String get description => 'semantics ${_quote(label)}';

  @override
  List<Element> find(PlaybookTree tree) => [
    for (final Element element in tree.elements)
      if (element.widget case final Semantics semantics)
        if (semantics.properties.label?.trim() == label.trim()) element,
  ];
}

class _KeyFinder extends PlaybookFinder {
  const _KeyFinder(this.key, {this.label});

  final Key key;
  final String? label;

  @override
  String get description => label ?? 'key $key';

  @override
  List<Element> find(PlaybookTree tree) => [
    for (final Element element in tree.elements)
      if (element.widget.key == key) element,
  ];
}

class _TypeFinder extends PlaybookFinder {
  const _TypeFinder(this.type);

  final Type type;

  @override
  String get description => '$type';

  @override
  List<Element> find(PlaybookTree tree) => [
    for (final Element element in tree.elements)
      if (element.widget.runtimeType == type) element,
  ];
}

class _IconFinder extends PlaybookFinder {
  const _IconFinder(this.icon, {this.label});

  final IconData icon;
  final String? label;

  @override
  String get description => label == null
      ? 'icon ${icon.codePoint.toRadixString(16)}'
      : 'the $label icon';

  @override
  List<Element> find(PlaybookTree tree) => [
    for (final Element element in tree.elements)
      if (element.widget case Icon(icon: final IconData? shown))
        if (shown == icon) element,
  ];
}

class _WhereFinder extends PlaybookFinder {
  const _WhereFinder(this.test, this.description);

  final bool Function(Widget widget) test;

  @override
  final String description;

  @override
  List<Element> find(PlaybookTree tree) => [
    for (final Element element in tree.elements)
      if (test(element.widget)) element,
  ];
}

/// A plain string target, matched the way a person reads the screen: the
/// first kind of match that finds anything wins.
class _ReadingFinder extends PlaybookFinder {
  _ReadingFinder(this.text)
    : _text = _TextFinder(text),
      _input = _InputFinder(text),
      _tooltip = _TooltipFinder(text),
      _semantics = _SemanticsFinder(text),
      _key = _KeyFinder(ValueKey<String>(text)),
      _containing = _TextFinder(text, contains: true);

  final String text;
  final PlaybookFinder _text;
  final PlaybookFinder _input;
  final PlaybookFinder _tooltip;
  final PlaybookFinder _semantics;
  final PlaybookFinder _key;
  final PlaybookFinder _containing;

  @override
  String get description => _quote(text);

  @override
  List<Element> find(PlaybookTree tree) => _firstFound(tree, [
    _text,
    _input,
    _tooltip,
    _semantics,
    _key,
    _containing,
  ]);

  @override
  List<Element> findFields(PlaybookTree tree) => _firstFound(tree, [
    _input,
    _key,
    _semantics,
    _text,
    _tooltip,
    _containing,
  ]);

  static List<Element> _firstFound(
    PlaybookTree tree,
    List<PlaybookFinder> finders,
  ) {
    for (final PlaybookFinder finder in finders) {
      final List<Element> found = finder.find(tree);
      if (found.isNotEmpty) return found;
    }
    return const [];
  }
}

class _InsideFinder extends PlaybookFinder {
  const _InsideFinder(this.finder, this.ancestor);

  final PlaybookFinder finder;
  final PlaybookFinder ancestor;

  @override
  String get description =>
      '${finder.description} inside ${ancestor.description}';

  @override
  List<Element> find(PlaybookTree tree) => _within(tree, finder.find(tree));

  @override
  List<Element> findFields(PlaybookTree tree) =>
      _within(tree, finder.findFields(tree));

  List<Element> _within(PlaybookTree tree, List<Element> matches) {
    final Set<Element> containers = ancestor.find(tree).toSet();
    if (containers.isEmpty) return const [];
    return [
      for (final Element element in matches)
        if (_hasAncestorIn(element, containers)) element,
    ];
  }

  static bool _hasAncestorIn(Element element, Set<Element> containers) {
    bool found = false;
    element.visitAncestorElements((Element parent) {
      found = containers.contains(parent);
      return !found;
    });
    return found;
  }
}

class _AtFinder extends PlaybookFinder {
  const _AtFinder(this.finder, this.index);

  final PlaybookFinder finder;

  /// The position, or -1 for the last match.
  final int index;

  @override
  String get description => index == -1
      ? '${finder.description} (last)'
      : '${finder.description} (#${index + 1})';

  @override
  List<Element> find(PlaybookTree tree) => _pick(finder.find(tree));

  @override
  List<Element> findFields(PlaybookTree tree) => _pick(finder.findFields(tree));

  List<Element> _pick(List<Element> matches) {
    if (matches.isEmpty) return const [];
    if (index == -1) return [matches.last];
    return index < matches.length ? [matches[index]] : const [];
  }
}
