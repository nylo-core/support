import 'dart:math';

import 'package:flutter/material.dart';
import '../ny_logger.dart';

/// Extensions for `List<Widget>`
extension NyListWidgetExt on List<Widget> {
  /// Add a gap between each child.
  List<Widget> withGap(double space) {
    assert(space >= 0, 'Space should be a non-negative value.');

    List<Widget> newChildren = [];
    for (int i = 0; i < length; i++) {
      newChildren.add(this[i]);
      if (i < length - 1) {
        newChildren.add(SizedBox(height: space));
      }
    }

    return newChildren;
  }
}

/// Extensions for [Map]
extension NyMapExt on Map? {
  /// dump the value to the console. [tag] is optional.
  void dump({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
  }

  /// dump the value to the console and exit the app. [tag] is optional.
  /// On web the exit step is skipped (`dart:io`'s `exit()` is unavailable).
  void dd({String? tag}) {
    NyLogger.dd((this ?? "").toString(), tag);
  }
}

/// Extensions for [List]
extension NyListExt on List? {
  /// dump the value to the console. [tag] is optional.
  void dump({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
  }

  /// dump the value to the console and exit the app. [tag] is optional.
  /// On web the exit step is skipped (`dart:io`'s `exit()` is unavailable).
  void dd({String? tag}) {
    NyLogger.dd((this ?? "").toString(), tag);
  }

  /// Convert a list to [Row]
  Row row({
    Key? key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
  }) {
    return Row(
      key: key,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: this as List<Widget>,
    );
  }

  /// Find a random item in a list.
  dynamic randomItem() {
    if (this == null || this!.isEmpty) return null;
    return this![Random().nextInt(this!.length)];
  }
}

/// Extensions for [List]
extension ListUpdateExtensionExt<T> on List<T> {
  /// Update a list of items based on a condition.
  List<T> update(bool Function(T) condition, T Function(T) updater) {
    return map((item) {
      if (condition(item)) {
        return updater(item);
      }
      return item;
    }).toList();
  }
}

/// Extensions for [List]
extension NyListGenericExt<T> on List<T> {
  /// Toggle a value in list
  /// if [value] exists, remove it
  /// if [value] does not exist, add it
  void toggleValue(T value) {
    if (contains(value)) {
      remove(value);
      return;
    }
    add(value);
  }
}

/// Extension on the `List<T>` class that adds a `paginate` method for easy
/// pagination of list elements.
extension PaginateExt<T> on List<T> {
  /// Paginates the elements of the list based on the given parameters.
  ///
  /// The `paginate` method allows you to split a list of elements into
  /// multiple pages, with each page containing a specified number of items.
  /// This can be useful for implementing paginated UIs, such as displaying
  /// a limited number of items per page in a list view.
  ///
  /// The [itemsPerPage] parameter specifies the maximum number of items
  /// to include on each page. The [page] parameter specifies the page
  /// number (1-based) for which you want to retrieve the items.
  ///
  /// The method returns an `Iterable<T>` that represents the elements on the
  /// specified page. Note that the iterable is lazily evaluated, meaning that
  /// elements are computed on-demand as you iterate over it.
  ///
  /// If the calculated start index for the page exceeds the length of the list,
  /// or if the list is empty, the returned iterable will be empty.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// final List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  /// final int itemsPerPage = 3;
  ///
  /// final Iterable<int> firstPage = numbers.paginate(itemsPerPage: itemsPerPage, page: 1);
  /// print(firstPage.toList()); // Output: [1, 2, 3]
  ///
  /// final Iterable<int> secondPage = numbers.paginate(itemsPerPage: itemsPerPage, page: 2);
  /// print(secondPage.toList()); // Output: [4, 5, 6]
  /// ```
  Iterable<T> paginate({required int itemsPerPage, required int page}) sync* {
    final startIndex = (page - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;

    for (int i = startIndex; i < endIndex && i < length; i++) {
      yield this[i];
    }
  }
}

extension NyMapEntryExt on Iterable<MapEntry<String, dynamic>> {
  /// Convert an `Iterable<MapEntry<String, dynamic>>` to a `Map<String, dynamic>`
  Map<String, dynamic> toMap() {
    return Map.fromEntries(this);
  }
}
