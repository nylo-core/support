import 'package:flutter/material.dart';
import 'package:nylo_support/helpers/backpack.dart';

/// Simple way to render Future's in your project.
///
/// Example
/// NyFutureBuilder(future: myFuture(), child: (context, data) {
///   return Text(data);
/// }),
///
/// Creates a widget that builds itself based on the latest snapshot of
/// interaction with a [Future].
class NyFutureBuilder<T> extends StatelessWidget {
  const NyFutureBuilder(
      {Key? key,
      required this.future,
      required this.child,
      this.loading,
      this.onError})
      : super(key: key);

  final Future<T>? future;
  final Widget Function(BuildContext context, T data) child;
  final Widget Function(AsyncSnapshot snapshot)? onError;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (
        BuildContext context,
        AsyncSnapshot<T> snapshot,
      ) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            {
              if (loading != null) {
                return loading!;
              }
              return Backpack.instance.nylo().appLoader;
            }
          case ConnectionState.active:
            {
              return const SizedBox.shrink();
            }
          case ConnectionState.done:
            {
              if (snapshot.hasError) {
                if (onError != null) {
                  return onError!(snapshot);
                }
                return const SizedBox.shrink();
              }
              if (snapshot.hasData) {
                return child(context, snapshot.data!);
              }
              return const SizedBox.shrink();
            }
          case ConnectionState.none:
            {
              return const SizedBox.shrink();
            }
        }
      },
    );
  }
}
