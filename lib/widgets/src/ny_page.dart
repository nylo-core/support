import 'package:error_stack/error_stack.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '/nylo.dart';
import '/router/ny_router.dart';
import 'package:flutter/material.dart';

abstract class NyPage<T extends StatefulWidget> extends NyBaseState<T>
    with WidgetsBindingObserver {
  /// Base NyPage
  NyPage({super.name, super.path});

  /// Check if the widget should be loaded.
  @override
  bool get shouldLoadView {
    if (widget is NyStatefulWidget &&
        (widget as NyStatefulWidget).controller.routeGuards.isNotEmpty) {
      return (widget as NyStatefulWidget).controller.routeGuards.isNotEmpty;
    }
    return init is Future Function();
  }

  /// enable or disable if the [NyPage] should be state managed
  bool get stateManaged => false;

  /// Map of lifecycle actions
  Map<AppLifecycleState, Function()> get lifecycleActions => {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    /// Set the state name if the widget is a NyStatefulWidget
    if (widget is NyStatefulWidget) {
      /// Take the name from the widget, so this page listens on the name its
      /// senders use: a `stateName` passed to [NyStatefulWidget] when the
      /// developer gave one, otherwise the name derived from the widget class.
      /// A `name` or `path` given to this state wins over both.
      stateName ??= (widget as NyStatefulWidget).state;
      (widget as NyStatefulWidget).controller.state = stateName;
    }

    if (stateManaged && allowStateUpdates) {
      _restoreStateFromHistory();

      eventSubscription = eventBus!.on<UpdateState>().listen((event) async {
        if (event.stateName != stateName) return;

        await stateUpdated(event.data);
        await _whenStateAction(event.data);
        if (mounted) setState(() {});
      });
    }

    if (widget is! NyStatefulWidget) {
      if (!shouldLoadView) {
        init();
        hasInitComplete = true;
        return;
      }
      awaitData(
        perform: () async {
          await init();
        },
      );
      hasInitComplete = true;
      return;
    }

    awaitData(
      perform: () async {
        final _controller = (widget as NyStatefulWidget).controller;
        if (_controller.context == null) {
          await _controller.construct(context);
        }

        NyArgument? nyArgument = NyArgument(data());
        PageRequest pageRequest = PageRequest(
          context: context,
          nyArgument: nyArgument,
          queryParameters: queryParameters(),
        );
        bool routeGuardsPassed = true;
        for (RouteGuard routeGuard
            in (widget as NyStatefulWidget).controller.routeGuards) {
          routeGuard.pageRequest = pageRequest;
          PageRequest? pageRequestFromRouteGuard = await routeGuard.onRequest(
            pageRequest,
          );
          if (pageRequestFromRouteGuard?.isRedirect == true) {
            routeGuardsPassed = false;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              pageRequestFromRouteGuard?.routeData?.routeToPage();
            });
          }
        }
        if (!routeGuardsPassed) {
          return;
        }
        await init();
        hasInitComplete = true;
      },
      shouldSetStateBefore: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!shouldLoadView && overrideLoading == false) {
      return _buildWidget(context);
    }

    if (hasInitComplete == false || isLoading()) {
      switch (loadingStyle.type) {
        case LoadingStyleType.normal:
          {
            if (loadingStyle.child != null) {
              return loadingStyle.child!;
            }
            return Scaffold(body: Nylo.appLoader());
          }
        case LoadingStyleType.skeletonizer:
          {
            if (loadingStyle.child != null) {
              return Skeletonizer(enabled: true, child: loadingStyle.child!);
            }
            return Skeletonizer(enabled: true, child: view(context));
          }
        case LoadingStyleType.none:
          return view(context);
      }
    }
    return _buildWidget(context);
  }

  /// Restores state data from the event bus history.
  void _restoreStateFromHistory() {
    final lastEvent = eventBus!.history
        .where((entry) => entry.event is UpdateState)
        .map((entry) => entry.event as UpdateState)
        .where((event) => event.stateName == stateName)
        .lastOrNull;

    if (lastEvent != null) {
      stateData = lastEvent.data;
    }
  }

  /// Handle a state action for the current state
  Future _whenStateAction(dynamic data) async {
    if (data is! Map) {
      return;
    }

    if (!(data.containsKey('action'))) {
      return;
    }

    String action = data['action'];
    dynamic actionData = data.containsKey('data') ? data['data'] : null;

    if (stateActions.containsKey(action)) {
      final function = stateActions[action]!;

      String functionString = function.runtimeType.toString();

      // Determine if the function takes parameters based on its toString representation
      bool hasParameters =
          functionString.contains("(dynamic)") ||
          functionString.contains("(Object?)") ||
          !functionString.contains("()");

      if (hasParameters) {
        await Function.apply(function, [actionData]);
        return;
      }

      await Function.apply(function, []);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (lifecycleActions.isEmpty) {
      return;
    }
    if (lifecycleActions.containsKey(state)) {
      lifecycleActions[state]!();
    }
  }

  Widget debugInfo({required Widget child}) {
    return UIDebugOverlay(child: ErrorStackDevPanel(child: child));
  }

  /// Build the widget.
  Widget _buildWidget(BuildContext context) {
    if (useDevPanel) {
      return debugInfo(child: view(context));
    }

    return view(context);
  }

  bool get useDevPanel => getEnv('USE_DEV_PANEL', defaultValue: false);
}
