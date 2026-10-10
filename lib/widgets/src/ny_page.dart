import 'package:error_stack/error_stack.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '/controllers/ny_controllers.dart';
import '/nylo.dart';
import '/router/ny_router.dart';
import 'package:flutter/material.dart';

abstract class NyPage<T extends StatefulWidget> extends NyBaseState<T>
    with WidgetsBindingObserver {
  /// Base NyPage
  NyPage({super.name, super.path});

  /// The controller's guards this page still has to run for the current
  /// request. [NyRouter.navigate] runs the route's guards before pushing, so
  /// those are skipped here; guards declared on the controller, and every
  /// guard on a page reached through the raw [Navigator], run in [initState].
  List<RouteGuard> get _pendingRouteGuards {
    if (widget is! NyStatefulWidget) return const [];
    final BaseController controller = (widget as NyStatefulWidget).controller;
    final List<RouteGuard> evaluated =
        controller.request?.routerEvaluatedGuards ?? const [];
    if (evaluated.isEmpty) return controller.routeGuards;
    return controller.routeGuards
        .where((guard) => !evaluated.any((e) => identical(e, guard)))
        .toList();
  }

  /// Check if the widget should be loaded.
  @override
  bool get shouldLoadView {
    if (_pendingRouteGuards.isNotEmpty) {
      return true;
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
      listenForStateUpdates();
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
        final BaseController controller =
            (widget as NyStatefulWidget).controller;
        if (controller.context == null) {
          await controller.construct(context);
        }
        if (!mounted) return;

        // routeTo()/navigate() already ran the route's guards; this pass
        // covers the rest.
        final List<RouteGuard> pendingGuards = _pendingRouteGuards;
        if (pendingGuards.isNotEmpty) {
          NyArgument? nyArgument = NyArgument(data());
          PageRequest pageRequest = PageRequest(
            context: context,
            nyArgument: nyArgument,
            queryParameters: queryParameters(),
          );
          bool routeGuardsPassed = true;
          for (RouteGuard routeGuard in pendingGuards) {
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
