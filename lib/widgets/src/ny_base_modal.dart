import 'package:flutter/material.dart';

/// Type definition for the [NyBaseModal.show] method.
/// Use this to preserve type information when creating references to the show method.
typedef ModalShowFunction =
    Future<T?> Function<T>(
      BuildContext context, {
      required Widget child,
      List<Widget> actionsRow,
      List<Widget> actionsColumn,
      double? height,
      Widget? header,
      bool useSafeArea,
      bool isScrollControlled,
      bool showCloseButton,
      EdgeInsets? headerPadding,
      Color? backgroundColor,
      bool showHandle,
      Color? closeButtonColor,
      Color? closeButtonIconColor,
      BoxDecoration? modalDecoration,
      Color? handleColor,
    });

/// NyBaseModal
///
/// A base class for creating modal bottom sheets with customizable layouts.
/// Extend this class to create your own modal implementations.
///
/// Example:
/// ```dart
/// class Modal extends NyBaseModal {
///   static Future<void> showLogout(BuildContext context) {
///     return NyBaseModal.show(
///       context,
///       child: LogoutWidget(),
///       actionsRow: [Button.primary(text: "Logout", onPressed: () {})],
///     );
///   }
/// }
/// ```
abstract class NyBaseModal {
  /// Core method to display a modal bottom sheet with full customization.
  ///
  /// [context] - BuildContext for showing the modal
  /// [child] - Main content widget to display in the modal
  /// [actionsRow] - List of action widgets displayed in a row
  /// [actionsColumn] - List of action widgets displayed in a column
  /// [height] - Optional fixed height for the modal
  /// [header] - Optional header widget positioned at the top
  /// [useSafeArea] - Whether to wrap content in SafeArea (default: true)
  /// [isScrollControlled] - Whether the modal can be scrolled (default: false)
  /// [showCloseButton] - Whether to show a close button (default: false)
  /// [headerPadding] - Padding for the main content when header is present
  /// [backgroundColor] - Background color of the modal
  /// [showHandle] - Whether to show the drag handle (default: true)
  /// [closeButtonColor] - Color of the close button background
  /// [closeButtonIconColor] - Color of the close button icon
  /// [modalDecoration] - Custom decoration for the modal container
  /// [handleColor] - Color of the drag handle
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    List<Widget> actionsRow = const [],
    List<Widget> actionsColumn = const [],
    double? height,
    Widget? header,
    bool useSafeArea = true,
    bool isScrollControlled = false,
    bool showCloseButton = false,
    EdgeInsets? headerPadding,
    Color? backgroundColor,
    bool showHandle = true,
    Color? closeButtonColor,
    Color? closeButtonIconColor,
    BoxDecoration? modalDecoration,
    Color? handleColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor:
          backgroundColor ??
          (header == null ? Colors.white : Colors.transparent),
      builder: (context) {
        Widget mainWidget = NyModalLayout(
          height: height,
          showHandle: header == null && showHandle,
          actionsRow: actionsRow,
          actionsColumn: actionsColumn,
          decoration: modalDecoration,
          handleColor: handleColor,
          child: child,
        );

        if (header != null) {
          mainWidget = Stack(
            children: [
              Padding(
                padding: headerPadding ?? const EdgeInsets.only(top: 25),
                child: mainWidget,
              ),
              Positioned(top: 0, left: 0, right: 0, child: header),
              if (showCloseButton)
                Positioned(
                  top: 20,
                  right: 25,
                  child: Container(
                    height: 35,
                    width: 35,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: closeButtonColor ?? const Color(0xFF484848),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.close,
                        color: closeButtonIconColor ?? Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
            ],
          );
        }

        return useSafeArea ? SafeArea(child: mainWidget) : mainWidget;
      },
    );
  }
}

/// NyModalLayout
///
/// The default layout widget used by [NyBaseModal.show].
/// Can be used standalone or customized via parameters.
class NyModalLayout extends StatelessWidget {
  /// The main content widget
  final Widget child;

  /// List of action widgets displayed in a row
  final List<Widget> actionsRow;

  /// List of action widgets displayed in a column
  final List<Widget> actionsColumn;

  /// Optional fixed height for the modal
  final double? height;

  /// Whether to show the drag handle
  final bool showHandle;

  /// Custom decoration for the modal container
  final BoxDecoration? decoration;

  /// Color of the drag handle
  final Color? handleColor;

  const NyModalLayout({
    super.key,
    required this.child,
    this.actionsRow = const [],
    this.actionsColumn = const [],
    this.height,
    this.showHandle = true,
    this.decoration,
    this.handleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 16),
      decoration:
          decoration ??
          const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle)
            Container(
              margin: const EdgeInsets.only(top: 16),
              width: MediaQuery.of(context).size.width / 3,
              child: Divider(
                height: 4,
                thickness: 4,
                color: handleColor ?? Colors.grey.shade300,
              ),
            ),
          const SizedBox(height: 8),
          child,
          const SizedBox(height: 16),
          if (actionsColumn.isNotEmpty)
            Column(mainAxisSize: MainAxisSize.min, children: actionsColumn),
          if (actionsRow.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: actionsRow.map((element) {
                if (element is SizedBox) return element;
                return Expanded(child: element);
              }).toList(),
            ),
        ],
      ),
    );
  }
}
