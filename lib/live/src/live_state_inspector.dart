import 'dart:convert';

import 'package:flutter/widgets.dart';

import '/nylo.dart';
import '/router/ny_router.dart';
import '/widgets/ny_widgets.dart';
import 'live_exception.dart';
import 'ny_live_json.dart';

/// The state object `metro live:run data` last described.
///
/// Metro reads this variable's fields over the VM service. That is the only
/// way to reach the fields a developer declared on their own state class: a
/// Flutter app has no reflection, so nothing inside the app can enumerate
/// them. [LiveStateInspector.data] sets it; nothing in the framework reads it.
Object? nyLiveInspectedState;

/// Encodes the field [values] Metro read from [nyLiveInspectedState].
///
/// Metro calls this with the VM service's `evaluate`, passing each field's
/// object as a variable in the expression's scope, and decodes the JSON it
/// returns. Values Metro couldn't pass - an uninitialized `late` field, a
/// value the garbage collector took - arrive as null.
///
/// Each value becomes `{type, value}`, plus `count` for a collection and
/// `truncated` when only the first [nyLiveInspectItemLimit] items were
/// encoded. A value that can't be turned into JSON - a controller, a
/// listener - falls back to its `toString()`, so a field always describes
/// itself somehow.
String nyLiveInspectJson(List<Object?> values) =>
    jsonEncode([for (final Object? value in values) _describeValue(value)]);

/// How many items of a collection field are encoded.
const int nyLiveInspectItemLimit = 100;

Map<String, Object?> _describeValue(Object? value) {
  final Map<String, Object?> described = {
    'type': value == null ? 'Null' : value.runtimeType.toString(),
  };

  Object? encoding = value;
  if (value is List || value is Set) {
    final List<Object?> items = (value as Iterable<Object?>).toList();
    described['count'] = items.length;
    if (items.length > nyLiveInspectItemLimit) {
      described['truncated'] = true;
      encoding = items.sublist(0, nyLiveInspectItemLimit);
    }
  } else if (value is Map) {
    described['count'] = value.length;
  }

  try {
    final Object? encoded = NyLiveJson.encodable(encoding);
    // Prove it survives the round trip here, where the fallback still works.
    jsonEncode(encoded);
    described['value'] = encoded;
  } catch (_) {
    described['value'] = value.toString();
  }
  return described;
}

/// Describes the Nylo states on screen for `metro live:run data`.
///
/// Walks the element tree under the page on top of the navigation stack and
/// reports every [NyPage] and [NyState] it finds, outermost first, with the
/// data Nylo holds for each: the route data passed to it, its query
/// parameters and its state actions.
class LiveStateInspector {
  LiveStateInspector._();

  /// Classes whose fields belong to Nylo rather than to the developer.
  ///
  /// Metro filters the state object's fields by the class that declares them,
  /// so `data` shows the fields written on the page and not Nylo's own
  /// bookkeeping. Add a class here when it gains fields of its own.
  static const List<String> frameworkStateClasses = [
    'State',
    'NyBaseState',
    'NyPage',
    'NyState',
  ];

  /// The library Metro finds [nyLiveInspectedState] and [nyLiveInspectJson] in.
  ///
  /// Sent to Metro with every reply rather than hardcoded there, so moving
  /// this file only breaks `data` for apps on an older Metro. Keep it
  /// pointing at this file.
  static const String libraryUri =
      'package:nylo_support/live/src/live_state_inspector.dart';

  /// The most states one reply describes.
  static const int stateLimit = 50;

  /// The `state.data` reply: the state [target] names, or the page on screen.
  ///
  /// Throws a [LiveException] when nothing on screen is a [NyPage] or
  /// [NyState], or when [target] names no state that is.
  static Map<String, Object?> data({String? target}) {
    final String? route = Nylo.getCurrentRouteName();
    final List<NyBaseState> states = statesOnScreen();
    if (states.isEmpty) {
      nyLiveInspectedState = null;
      throw LiveException(
        route == null
            ? 'Nothing on screen is a NyPage or NyState yet. Wait for the app '
                  'to load, then try again.'
            : 'The page on "$route" isn\'t a NyPage or NyState, so it holds '
                  'no Nylo state to show.',
      );
    }

    final NyBaseState state = target == null
        ? states.first
        : _match(states, target);
    nyLiveInspectedState = state;

    return {
      'route': route,
      'state': describe(state),
      'states': [
        for (final NyBaseState found in states.take(stateLimit)) summary(found),
      ],
      'inspect': {
        'library': libraryUri,
        'variable': 'nyLiveInspectedState',
        'encoder': 'nyLiveInspectJson',
        'skip': frameworkStateClasses,
      },
    };
  }

  /// Every Nylo state under the page on top of the navigation stack, in the
  /// order they nest: the page itself, then the states it builds.
  static List<NyBaseState> statesOnScreen() {
    final BuildContext? context = _pageContext();
    if (context == null) return const [];

    final List<NyBaseState> found = [];
    void visit(Element element) {
      if (element is StatefulElement) {
        final State<StatefulWidget> state = element.state;
        if (state is NyBaseState && state.mounted) found.add(state);
      }
      element.visitChildren(visit);
    }

    try {
      context.visitChildElements(visit);
    } catch (_) {
      // The tree is locked (a build is in flight); report what was reached.
    }
    return found;
  }

  /// The full description of [state] shown by `data`.
  static Map<String, Object?> describe(NyBaseState state) {
    final StatefulWidget widget = state.widget;
    return {
      ...summary(state),
      'controller': widget is NyStatefulWidget
          ? widget.controller.runtimeType.toString()
          : null,
      'data': state.data(),
      'queryParameters': state.queryParameters(),
      'actions': [
        for (final Object action in state.stateActions.keys)
          _actionName(action),
      ],
    };
  }

  /// The one-line description of [state] used to list the states on screen.
  static Map<String, Object?> summary(NyBaseState state) => {
    'name': state.stateName,
    'state': state.runtimeType.toString(),
    'widget': state.widget.runtimeType.toString(),
    'kind': state is NyPage
        ? 'NyPage'
        : state is NyState
        ? 'NyState'
        : 'NyBaseState',
  };

  /// The state in [states] that [target] names.
  ///
  /// [target] matches a state name, a state class or a widget class, first
  /// exactly and then as part of one, ignoring case.
  static NyBaseState _match(List<NyBaseState> states, String target) {
    final String wanted = target.toLowerCase();
    List<String> namesOf(NyBaseState state) => [
      if (state.stateName != null) state.stateName!.toLowerCase(),
      state.runtimeType.toString().toLowerCase(),
      state.widget.runtimeType.toString().toLowerCase(),
    ];

    for (final NyBaseState state in states) {
      if (namesOf(state).contains(wanted)) return state;
    }
    for (final NyBaseState state in states) {
      if (namesOf(state).any((String name) => name.contains(wanted))) {
        return state;
      }
    }
    throw LiveException(
      'No state on screen is called "$target". On screen: '
      '${states.map((NyBaseState state) => state.widget.runtimeType).join(', ')}.',
    );
  }

  /// A state action key as it's written in `stateActions`: `refresh` for a
  /// string, `#markRead` for the symbol of a typed action.
  static String _actionName(Object action) {
    if (action is! Symbol) return '$action';
    final Match? match = RegExp(
      r'^Symbol\("(.*)"\)$',
    ).firstMatch(action.toString());
    return match == null ? '$action' : '#${match.group(1)}';
  }

  /// The context of the page on top of the navigation stack.
  static BuildContext? _pageContext() {
    final List<Route<dynamic>> history = NyNavigator.instance.router
        .getRouteHistory();
    final Route<dynamic>? route = history.isEmpty ? null : history.last;
    if (route is ModalRoute<dynamic>) {
      final BuildContext? context = route.subtreeContext;
      if (context != null && context.mounted) return context;
    }
    final BuildContext? navigator =
        NyNavigator.instance.router.navigatorKey?.currentContext;
    return navigator != null && navigator.mounted ? navigator : null;
  }
}
