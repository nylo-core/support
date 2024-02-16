import 'package:flutter/material.dart';
import '/nylo.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Simple way to render Future's in your project.
///
/// Example
/// NyFutureBuilder(future: myFuture(), child: (context, data) {
///   return Text(data);
/// }),
///
/// Creates a widget that builds itself from a [Future] snapshot.
class NyFutureBuilder<T> extends StatelessWidget {
  const NyFutureBuilder(
      {Key? key,
      required this.future,
      required this.child,
      this.loading,
      this.useSkeletonizer,
      this.onError})
      : super(key: key);

  final Future<T>? future;
  final Widget Function(BuildContext context, T? data) child;
  final Widget Function(AsyncSnapshot snapshot)? onError;
  final Widget? loading;
  final bool? useSkeletonizer;

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
                if (useSkeletonizer == true) {
                  return Skeletonizer(
                    child: loading!,
                  );
                }
                return loading!;
              }
              return Nylo.appLoader();
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

              return child(context, snapshot.data);
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
