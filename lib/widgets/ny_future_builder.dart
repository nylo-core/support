import 'package:flutter/material.dart';
import 'package:nylo_support/helpers/backpack.dart';
import 'package:nylo_support/widgets/ny_state.dart';

class NyFutureBuilder<T> extends StatefulWidget {
  NyFutureBuilder(
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
  _NyFutureBuilderState createState() =>
      _NyFutureBuilderState<T>(future: future, child: child, hasError: onError);
}

class _NyFutureBuilderState<T> extends NyState<NyFutureBuilder> {
  _NyFutureBuilderState({this.future, this.child, this.hasError});

  final Future<T>? future;
  final Widget Function(BuildContext context, T data)? child;
  final Widget Function(AsyncSnapshot snapshot)? hasError;

  @override
  init() async {
    super.init();
  }

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
              if (widget.loading != null) {
                return widget.loading!;
              }
              ;
              return Backpack.instance.nylo().appLoader;
            }
          case ConnectionState.active:
            {
              return const SizedBox.shrink();
            }
          case ConnectionState.done:
            {
              if (snapshot.hasError) {
                if (hasError != null) {
                  return hasError!(snapshot);
                }
                return const SizedBox.shrink();
              }
              if (snapshot.hasData) {
                return child!(context, snapshot.data!);
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
