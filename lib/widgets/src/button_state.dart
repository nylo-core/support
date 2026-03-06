import 'package:flutter/cupertino.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '/helpers/ny_helpers.dart';
import '/nylo.dart';
import 'form/form.dart';
import 'ny_state.dart';

/// ButtonState is a stateful widget that manages the state of a button.
class ButtonState extends StatefulWidget {
  ButtonState({
    super.key,
    required this.child,
    this.onSubmit,
    this.loadingStyle,
    this.onFailure,
    this.showToastError,
  });

  final Widget Function(VoidCallback? onPressed) child;
  final (Function()? onPressed, (dynamic, Function(dynamic data))?)? onSubmit;
  final Function(List<FormValidationError>)? onFailure;
  final bool? showToastError;
  final LoadingStyle? loadingStyle;

  @override
  createState() => _ButtonStateState();
}

class _ButtonStateState extends NyState<ButtonState> {
  /// Check if the form is loading
  bool formLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.onSubmit?.$2?.$1 is NyFormData &&
        (widget.onSubmit?.$2?.$1 as NyFormData).getLoadData
            is Future Function()) {
      formLoading = true;

      (widget.onSubmit!.$2!.$1 as NyFormData).isReady.listen((ready) {
        if (ready) {
          setState(() {
            formLoading = false;
          });
        }
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLocked(widget.child.toString()) || formLoading) {
      if (widget.loadingStyle?.type == LoadingStyleType.skeletonizer) {
        if (widget.loadingStyle?.child != null) {
          return SizedBox(
            height: 50,
            width: double.infinity,
            child: widget.loadingStyle!.child!.toSkeleton(),
          );
        }
        return Skeleton.leaf(child: widget.child(null)).toSkeleton();
      }
      if (widget.loadingStyle?.type == LoadingStyleType.normal) {
        if (widget.loadingStyle?.child != null) {
          return widget.loadingStyle?.child ??
              SizedBox(height: 50, child: Nylo.appLoader());
        }
        return SizedBox(height: 50, child: Nylo.appLoader());
      }
      if (widget.loadingStyle?.type == LoadingStyleType.none) {
        return widget.child(null);
      }
      return widget.child(null).toSkeleton();
    }
    return widget.child(() {
      if (widget.onSubmit == null) return;
      if (widget.onSubmit!.$2 != null) {
        assert(
          widget.onSubmit!.$2!.$1 != null,
          "Form ID is required for form submission",
        );
        assert(
          widget.onSubmit!.$2!.$1 is String ||
              widget.onSubmit!.$2!.$1 is NyFormData,
          "Form ID must be a String or NyFormData",
        );
        late String formId;
        if (widget.onSubmit!.$2!.$1 is NyFormData) {
          formId = (widget.onSubmit!.$2!.$1 as NyFormData).name!;
        } else {
          formId = widget.onSubmit!.$2!.$1 as String;
        }

        NyFormWidget.submit(
          formId,
          onSuccess: (data) {
            if (widget.onSubmit!.$2!.$2 is Future Function(dynamic data)) {
              lockRelease(
                widget.child.toString(),
                perform: () async {
                  await widget.onSubmit!.$2!.$2(data);
                },
              );
            } else {
              widget.onSubmit!.$2!.$2(data);
            }
          },
          onFailure: widget.onFailure,
          showToastError: widget.showToastError ?? true,
        );
      }

      try {
        if (widget.onSubmit!.$1 is Future Function()) {
          lockRelease(
            widget.child.toString(),
            perform: () async {
              await widget.onSubmit!.$1!();
            },
          );
        } else {
          if (widget.onSubmit!.$1 != null) widget.onSubmit!.$1!();
        }
      } catch (e) {
        printError(e.toString());
      }
    });
  }
}
