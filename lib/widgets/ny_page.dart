import 'package:skeletonizer/skeletonizer.dart';

import '/helpers/loading_style.dart';
import '/event_bus/res/history_entry.dart';
import '/nylo.dart';
import '/widgets/ny_base_state.dart';
import '/router/models/nyrouter_route_guard.dart';
import '/router/models/ny_argument.dart';
import 'package:flutter/material.dart';
import '/widgets/ny_stateful_widget.dart';
import 'event_bus/update_state.dart';

abstract class NyPage<T extends StatefulWidget> extends NyBaseState<T>
    with WidgetsBindingObserver {
  /// Base NyPage
  NyPage({super.path});

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

    if (stateManaged) {
      /// Set the state name if the widget is a NyStatefulWidget
      if (widget is NyStatefulWidget) {
        stateName = (widget as NyStatefulWidget).child.runtimeType.toString();
        if (!(stateName?.contains("Closure:") ?? false)) {
          stateName = "Closure: $stateName";
        }
        if (stateName?.contains("Closure: _") ?? false) {
          stateName = stateName?.replaceAll("Closure: _", "Closure: () => _");
        }
      }

      if (allowStateUpdates) {
        List<EventBusHistoryEntry> eventHistory = eventBus!.history
            .where((element) =>
                element.event.runtimeType.toString() == 'UpdateState')
            .toList();
        if (eventHistory.isNotEmpty) {
          stateData = eventHistory.last.event.props[1];
        }

        eventSubscription = eventBus!.on<UpdateState>().listen((event) async {
          if (event.stateName != stateName) return;

          await stateUpdated(event.data);
          await _whenStateAction(event.data);
          setState(() {});
        });
      }
    }

    if (widget is! NyStatefulWidget) {
      if (!shouldLoadView) {
        init();
        hasInitComplete = true;
        return;
      }
      awaitData(perform: () async {
        await init();
      });
      hasInitComplete = true;
      return;
    }

    awaitData(
      perform: () async {
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
          PageRequest? pageRequestFromRouteGuard =
              await routeGuard.onRequest(pageRequest);
          if (pageRequestFromRouteGuard?.isRedirect == true) {
            routeGuardsPassed = false;
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            pageRequestFromRouteGuard?.routeData?.routeToPage();
          });
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
      return view(context);
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
              return Skeletonizer(
                enabled: true,
                child: loadingStyle.child!,
              );
            }
            return Skeletonizer(
              enabled: true,
              child: view(context),
            );
          }
        case LoadingStyleType.none:
          return view(context);
      }
    }
    return view(context);
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
      bool hasParameters = functionString.contains("(dynamic)") ||
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
}
