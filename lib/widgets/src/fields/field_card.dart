import 'package:flutter/material.dart';

/// A field's card: [decoration]'s fill and rounded corners behind [child],
/// its border drawn over [child].
///
/// Drawing the border last keeps it on the card's curve when a row inside
/// is tinted, like a selected radio option or a pressed switch row.
class FieldCard extends StatelessWidget {
  /// Draws [decoration] around [child].
  const FieldCard({super.key, required this.decoration, required this.child});

  /// The card's fill, corners and border.
  final BoxDecoration decoration;

  /// The rows inside the card.
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: decoration.color,
      borderRadius: decoration.borderRadius,
    ),
    foregroundDecoration: decoration.border == null
        ? null
        : BoxDecoration(
            border: decoration.border,
            borderRadius: decoration.borderRadius,
          ),
    child: Material(type: MaterialType.transparency, child: child),
  );
}
