import 'package:flutter/material.dart';
import '/router/models/ny_argument.dart';

/// Class interface
abstract class RouteGuard {
  RouteGuard();

  /// Return true if the User can access this page and false if they can't.
  /// [canOpen] will contain the [context] and any arguments passed from the
  /// last route.
  Future<bool> canOpen(
    BuildContext? context,
    NyArgument? data,
  );

  /// This method is called after the [canOpen] returns false.
  /// Provide an action that should occur.
  /// E.g. routeTo('login');
  Future<void> redirectTo(BuildContext? context, NyArgument? data);
}

/// Base class for Nylo's [RouteGuard].
///
/// Usage:
/// 1. Create a new class that extends [RouteGuard].
/// class AuthRouteGuard extends NyRouteGuard {
///   AuthRouteGuard();
///
///   @override
///   Future<bool> canOpen(BuildContext? context, NyArgument? data) async {
///     // return true or false if a user can access the page.
///     return await Auth.loggedIn();
///   }
///
///   @override
///   redirectTo(BuildContext? context, NyArgument? data) async {
///     // routeTo a page if [canOpen] fails.
///     await routeTo(HomePage.path);
///   }
/// }
///
/// 2. Add the new [RouteGuard] to your route.
/// appRouter() => nyRoutes((router) {
///
///   router.route(ProfilePage.path, (context) => ProfilePage(), routeGuards: [
///     AuthRouteGuard() // new guard
///   ]);
///
///  });
class NyRouteGuard extends RouteGuard {
  NyRouteGuard();

  @override
  Future<bool> canOpen(
    BuildContext? context,
    NyArgument? data,
  ) async =>
      true;

  @override
  Future<void> redirectTo(BuildContext? context, NyArgument? data) async {
    return;
  }
}
