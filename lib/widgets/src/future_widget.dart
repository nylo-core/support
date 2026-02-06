import 'package:flutter/material.dart';
import '/helpers/ny_helpers.dart';
import '/nylo.dart';

/// Simple way to render Future's in your project.
///
/// Example
/// FutureWidget(future: myFuture(), child: (context, data) {
///   return Text(data);
/// }),
///
/// Creates a widget that builds itself from a [Future] snapshot.
class FutureWidget<T> extends StatelessWidget {
  const FutureWidget({
    super.key,
    required this.future,
    required this.child,
    this.loadingStyle,
    this.onError,
  });

  final Future<T>? future;
  final Widget Function(BuildContext context, T? data) child;
  final Widget Function(AsyncSnapshot snapshot)? onError;
  final LoadingStyle? loadingStyle;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            {
              if (loadingStyle == null) {
                return Nylo.appLoader();
              }
              return loadingStyle!.render();
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
