import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        AssetImage,
        BorderRadius,
        BoxDecoration,
        BoxScrollView,
        BoxShadow,
        Brightness,
        BuildContext,
        CircleAvatar,
        Color,
        Colors,
        Column,
        Container,
        EdgeInsets,
        Expanded,
        FlexFit,
        Flexible,
        FontWeight,
        Image,
        ImageErrorListener,
        InkWell,
        Key,
        ListView,
        Locale,
        MediaQuery,
        MediaQueryData,
        Navigator,
        Offset,
        Padding,
        Route,
        Row,
        SingleChildRenderObjectWidget,
        StatelessWidget,
        StrutStyle,
        Text,
        TextAlign,
        TextDirection,
        TextOverflow,
        TextScaler,
        TextStyle,
        TextTheme,
        TextWidthBasis,
        Theme,
        VerticalDivider;
import 'package:intl/intl.dart' as intl;
import 'package:nylo_support/helpers/backpack.dart';
import 'package:nylo_support/helpers/helper.dart';
import 'package:nylo_support/router/router.dart';
import 'package:nylo_support/widgets/ny_fader.dart';
import 'package:page_transition/page_transition.dart';
import '/router/models/ny_page_transition_settings.dart';

/// Extensions for [String]
extension NyStr on String? {
  Color toHexColor() => nyHexColor(this ?? "");

  /// dump the value to the console. [tag] is optional.
  dump({String? tag}) {
    NyLogger.dump(this ?? "", tag);
  }

  /// dump the value to the console and exit the app. [tag] is optional.
  dd({String? tag}) {
    NyLogger.dump(this ?? "", tag);
    exit(0);
  }
}

/// Extensions for [int]
extension NyInt on int? {
  /// dump the value to the console. [tag] is optional.
  dump({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
  }

  /// dump the value to the console and exit the app. [tag] is optional.
  dd({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
    exit(0);
  }
}

/// Extensions for [Map]
extension NyMap on Map? {
  /// dump the value to the console. [tag] is optional.
  dump({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
  }

  /// dump the value to the console and exit the app. [tag] is optional.
  dd({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
    exit(0);
  }
}

/// Extensions for [double]
extension NyDouble on double? {
  /// dump the value to the console. [tag] is optional.
  dump({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
  }

  /// dump the value to the console and exit the app. [tag] is optional.
  dd({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
    exit(0);
  }
}

/// Extensions for [bool]
extension NyBool on bool? {
  /// dump the value to the console. [tag] is optional.
  dump({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
  }

  /// dump the value to the console and exit the app. [tag] is optional.
  dd({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
    exit(0);
  }
}

/// Extensions for [DateTime]
extension NyDateTime on DateTime? {
  /// Check if the date is still valid.
  bool hasExpired() {
    if (this == null) return true;
    return this.isInPast();
  }

  /// Format [DateTime] to DateTimeString - yyyy-MM-dd HH:mm:ss
  String? toDateTimeString() {
    if (this == null) return null;
    return intl.DateFormat("yyyy-MM-dd HH:mm:ss").format(this!);
  }

  /// Format [DateTime] to toDateString - yyyy-MM-dd
  String? toDateString() {
    if (this == null) return null;
    return intl.DateFormat("yyyy-MM-dd").format(this!);
  }

  /// Format [DateTime] to toTimeString - HH:mm:ss
  String? toTimeString() {
    if (this == null) return null;
    return intl.DateFormat("HH:mm:ss").format(this!);
  }

  /// Format [DateTime] to an age
  int? toAge() {
    if (this == null) return null;
    return DateTime.now().difference(this!).inDays ~/ 365;
  }

  /// Check if [DateTime] is in the past
  bool isInPast() {
    if (this == null) return false;
    return this!.isBefore(DateTime.now());
  }

  /// Check if [DateTime] is in the future
  bool isInFuture() {
    if (this == null) return false;
    return this!.isAfter(DateTime.now());
  }

  /// Check if [DateTime] is today
  bool isToday() {
    if (this == null) return false;
    DateTime dateTime = DateTime.now();
    return this!.day == dateTime.day &&
        this!.month == dateTime.month &&
        this!.year == dateTime.year;
  }

  /// Check if [DateTime] is tomorrow
  bool isTomorrow() {
    if (this == null) return false;
    DateTime dateTime = DateTime.now().add(Duration(days: 1));
    return this!.day == dateTime.day &&
        this!.month == dateTime.month &&
        this!.year == dateTime.year;
  }

  /// Check if [DateTime] is yesterday
  bool isYesterday() {
    if (this == null) return false;
    DateTime dateTime = DateTime.now().subtract(Duration(days: 1));
    return this!.day == dateTime.day &&
        this!.month == dateTime.month &&
        this!.year == dateTime.year;
  }

  /// Get ordinal of the day.
  String _addOrdinal(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  /// Format [DateTime] to a short date
  String toShortDate(DateTime dateTime) {
    return '${intl.DateFormat('E').format(dateTime)} ${_addOrdinal(dateTime.day)} ${intl.DateFormat('MMM').format(dateTime)}';
  }

  /// Format [DateTime]
  String? toFormat(String format) {
    if (this == null) return null;
    return intl.DateFormat(format).format(this!);
  }

  /// dump the value to the console. [tag] is optional.
  dump({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
  }

  /// dump the value to the console and exit the app. [tag] is optional.
  dd({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
    exit(0);
  }
}

/// Extensions for [List]
extension NyList on List? {
  /// dump the value to the console. [tag] is optional.
  dump({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
  }

  /// dump the value to the console and exit the app. [tag] is optional.
  dd({String? tag}) {
    NyLogger.dump((this ?? "").toString(), tag);
    exit(0);
  }
}

/// Extensions for [Column]
extension NyColumn on Column {
  /// Add padding to the column.
  Padding paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return Padding(
      padding:
          EdgeInsets.only(top: top, left: left, right: right, bottom: bottom),
      child: this,
    );
  }

  /// Add symmetric padding to the column.
  Padding paddingSymmetric({
    double horizontal = 0.0,
    double vertical = 0.0,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
      child: this,
    );
  }

  /// Adds a gap between each child.
  Column withGap(double space) {
    assert(space >= 0, 'Space should be a non-negative value.');

    List<Widget> newChildren = [];
    for (int i = 0; i < children.length; i++) {
      newChildren.add(children[i]);
      if (i < children.length - 1) {
        newChildren.add(SizedBox(width: space));
      }
    }

    return Column(
      key: this.key,
      mainAxisAlignment: this.mainAxisAlignment,
      mainAxisSize: this.mainAxisSize,
      crossAxisAlignment: this.crossAxisAlignment,
      textDirection: this.textDirection,
      verticalDirection: this.verticalDirection,
      textBaseline: this.textBaseline,
      children: newChildren,
    );
  }

  /// Make a Column [Flexible].
  /// Example:
  /// ```
  /// Column(
  ///  children: [
  ///  MaterialButton(child: Text('Button 1'), onPressed: () {}).flexible(),
  ///  MaterialButton(child: Text('Button 2'), onPressed: () {}).flexible(),
  ///  ],
  ///  ),
  ///  ```
  Flexible flexible({Key? key, int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Flexible(
      child: this,
      key: key,
      flex: flex,
      fit: fit,
    );
  }

  /// Make a Column [Expanded].
  /// Example:
  /// ```
  /// Column(
  ///  children: [
  ///  MaterialButton(child: Text('Button 1'), onPressed: () {}).expanded(),
  ///  Text("Hello world"),
  ///  ],
  ///  ),
  ///  ```
  Expanded expanded({Key? key, int flex = 1}) {
    return Expanded(
      child: this,
      key: key,
      flex: flex,
    );
  }
}

/// Extensions for [Image]
extension NyImage on Image {
  /// Get the image from public/assets/images
  Image localAsset() {
    assert(this.image is AssetImage, "Image must be an AssetImage");
    if (this.image is AssetImage) {
      AssetImage assetImage = (this.image as AssetImage);
      return Image.asset(
        getImageAsset(assetImage.assetName),
        fit: this.fit,
        width: this.width,
        height: this.height,
        alignment: this.alignment,
        centerSlice: this.centerSlice,
        color: this.color,
        colorBlendMode: this.colorBlendMode,
        excludeFromSemantics: this.excludeFromSemantics,
        filterQuality: this.filterQuality,
        frameBuilder: this.frameBuilder,
        gaplessPlayback: this.gaplessPlayback,
        matchTextDirection: this.matchTextDirection,
        repeat: this.repeat,
        semanticLabel: this.semanticLabel,
        errorBuilder: this.errorBuilder,
        isAntiAlias: this.isAntiAlias,
        package: assetImage.package,
      );
    }
    return this;
  }

  /// Create a circle avatar.
  CircleAvatar circleAvatar({
    Color? backgroundColor = Colors.transparent,
    double radius = 30.0,
    ImageErrorListener? onBackgroundImageError,
    ImageErrorListener? onForegroundImageError,
    Color? foregroundColor,
    double? minRadius,
    double? maxRadius,
  }) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: this.image,
      backgroundColor: Colors.transparent,
      onBackgroundImageError: onBackgroundImageError,
      onForegroundImageError: onForegroundImageError,
      foregroundColor: foregroundColor,
      minRadius: minRadius,
      maxRadius: maxRadius,
    );
  }
}

/// Extensions for [SingleChildRenderObjectWidget]
extension NySingleChildRenderObjectWidget on SingleChildRenderObjectWidget {
  /// Route to a new page.
  InkWell onTapRoute(String routeName,
      {dynamic data,
      NavigationType navigationType = NavigationType.push,
      dynamic result,
      bool Function(Route<dynamic> route)? removeUntilPredicate,
      PageTransitionSettings? pageTransitionSettings,
      PageTransitionType? pageTransition,
      Function(dynamic value)? onPop}) {
    return InkWell(
      onTap: () async {
        await routeTo(routeName,
            data: data,
            navigationType: navigationType,
            result: result,
            removeUntilPredicate: removeUntilPredicate,
            pageTransitionSettings: pageTransitionSettings,
            pageTransition: pageTransition,
            onPop: onPop);
      },
      child: this,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
    );
  }

  /// On tap run a action.
  InkWell onTap(Function() action) {
    return InkWell(
      onTap: () async {
        await action();
      },
      child: this,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
    );
  }

  /// Add padding to the widget.
  Padding paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return Padding(
      padding:
          EdgeInsets.only(top: top, left: left, right: right, bottom: bottom),
      child: this,
    );
  }

  /// Add symmetric padding to the widget.
  Padding paddingSymmetric({
    double horizontal = 0.0,
    double vertical = 0.0,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
      child: this,
    );
  }
}

extension NyStatelessWidget on StatelessWidget {
  /// Route to a new page.
  InkWell onTapRoute(String routeName,
      {dynamic data,
      NavigationType navigationType = NavigationType.push,
      dynamic result,
      bool Function(Route<dynamic> route)? removeUntilPredicate,
      PageTransitionSettings? pageTransitionSettings,
      PageTransitionType? pageTransition,
      Function(dynamic value)? onPop}) {
    return InkWell(
      onTap: () async {
        await routeTo(routeName,
            data: data,
            navigationType: navigationType,
            result: result,
            removeUntilPredicate: removeUntilPredicate,
            pageTransitionSettings: pageTransitionSettings,
            pageTransition: pageTransition,
            onPop: onPop);
      },
      child: this,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
    );
  }

  /// On tap run a action.
  InkWell onTap(Function() action) {
    return InkWell(
      onTap: () async {
        await action();
      },
      child: this,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
    );
  }

  /// Add padding to the widget.
  Padding paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return Padding(
      padding:
          EdgeInsets.only(top: top, left: left, right: right, bottom: bottom),
      child: this,
    );
  }

  /// Add symmetric padding to the widget.
  Padding paddingSymmetric({
    double horizontal = 0.0,
    double vertical = 0.0,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
      child: this,
    );
  }

  /// Add a shadow to the container.
  Container shadow(int strength,
      {Color? color,
      double? blurRadius,
      double? spreadRadius,
      Offset? offset,
      double? rounded}) {
    assert(strength >= 1 && strength <= 4, 'strength must be between 1 and 4');

    switch (strength) {
      case 1:
        return _setShadow(color ?? Colors.grey.withOpacity(0.4), 1.5, 0,
            offset ?? const Offset(0.0, 0.1), rounded ?? 0);
      case 2:
        return _setShadow(color ?? Colors.grey.withOpacity(0.6), 2, 0,
            offset ?? const Offset(0.0, 0.1), rounded ?? 0);
      case 3:
        return _setShadow(color ?? Colors.black38.withOpacity(0.25), 5.5, 0,
            offset ?? const Offset(0.0, 0.1), rounded ?? 0);
      case 4:
        return _setShadow(color ?? Colors.black38.withOpacity(0.3), 10, 1,
            offset ?? const Offset(0.0, 0.1), rounded ?? 0);
      default:
        return _setShadow(color ?? Colors.grey.withOpacity(0.4), 1.5, 0,
            offset ?? const Offset(0.0, 0.1), rounded ?? 0);
    }
  }

  /// Create a shadow on the container.
  Container _setShadow(Color color, double blurRadius, double spreadRadius,
      Offset offset, double rounded) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(rounded),
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
            offset: offset,
          ),
        ],
      ),
      child: this,
    );
  }

  /// Make a StatelessWidget [Flexible].
  /// Example:
  /// ```
  /// Column(
  ///  children: [
  ///  MaterialButton(child: Text('Button 1'), onPressed: () {}).flexible(),
  ///  MaterialButton(child: Text('Button 2'), onPressed: () {}).flexible(),
  ///  ],
  ///  ),
  ///  ```
  Flexible flexible({Key? key, int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Flexible(
      child: this,
      key: key,
      flex: flex,
      fit: fit,
    );
  }

  /// Make gradient background for the widget.
  NyFader faderBottom(int strength, {Color color = Colors.black}) {
    return NyFader.bottom(
      child: this,
      strength: strength,
      color: color,
    );
  }

  /// Make gradient background for the widget.
  NyFader faderTop(int strength, {Color color = Colors.black}) {
    return NyFader.top(
      child: this,
      strength: strength,
      color: color,
    );
  }

  /// Make gradient background for the widget.
  NyFader faderLeft(int strength, {Color color = Colors.black}) {
    return NyFader.left(
      child: this,
      strength: strength,
      color: color,
    );
  }

  /// Make gradient background for the widget.
  NyFader faderRight(int strength, {Color color = Colors.black}) {
    return NyFader.right(
      child: this,
      strength: strength,
      color: color,
    );
  }

  /// faderFrom
  NyFader faderFrom(int strength,
      {Color color = Colors.black,
      required List<AlignmentGeometry> alignment}) {
    return NyFader(
      child: this,
      strength: strength,
      color: color,
      alignment: alignment,
    );
  }
}

extension NyStateful on StatefulWidget {
  /// Make a StatefulWidget [Flexible].
  /// Example:
  /// ```
  /// Row(
  ///  children: [
  ///   TextField(controller: TextEditingController()).flexible(),
  ///   TextField(controller: TextEditingController()).flexible(),
  ///  ],
  ///  ),
  ///  ```
  Flexible flexible({Key? key, int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Flexible(
      child: this,
      key: key,
      flex: flex,
      fit: fit,
    );
  }

  /// Make gradient fader from the bottom of the widget.
  NyFader faderBottom(int strength, {Color color = Colors.black}) {
    return NyFader.bottom(
      child: this,
      strength: strength,
      color: color,
    );
  }

  /// Make gradient fader from the top of the widget.
  NyFader faderTop(int strength, {Color color = Colors.black}) {
    return NyFader.top(
      child: this,
      strength: strength,
      color: color,
    );
  }

  /// Make gradient fader from the left of the widget.
  NyFader faderLeft(int strength, {Color color = Colors.black}) {
    return NyFader.left(
      child: this,
      strength: strength,
      color: color,
    );
  }

  /// Make gradient fader from the right of the widget.
  NyFader faderRight(int strength, {Color color = Colors.black}) {
    return NyFader.right(
      child: this,
      strength: strength,
      color: color,
    );
  }

  /// fader from bottom
  NyFader faderFrom(int strength,
      {Color color = Colors.black,
      List<AlignmentGeometry> alignment = const [
        Alignment.topCenter,
        Alignment.bottomCenter
      ]}) {
    return NyFader(
      child: this,
      strength: strength,
      color: color,
      alignment: alignment,
    );
  }
}

/// Extensions for [ListView]
extension NyBoxScrollView on BoxScrollView {
  /// expand the list view.
  Column expanded() {
    return Column(
      children: [
        Expanded(
          child: this,
        ),
      ],
    );
  }

  /// Add padding to the list view.
  Padding paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return Padding(
      padding:
          EdgeInsets.only(top: top, left: left, right: right, bottom: bottom),
      child: this,
    );
  }

  /// Add symmetric padding to the list view.
  Padding paddingSymmetric({
    double horizontal = 0.0,
    double vertical = 0.0,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
      child: this,
    );
  }
}

/// Extensions for [Row]
extension NyRow on Row {
  /// Add padding to the row.
  Padding paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return Padding(
      padding:
          EdgeInsets.only(top: top, left: left, right: right, bottom: bottom),
      child: this,
    );
  }

  /// Add symmetric padding to the row.
  Padding paddingSymmetric({
    double horizontal = 0.0,
    double vertical = 0.0,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
      child: this,
    );
  }

  /// Adds a gap between each child.
  Row withGap(double space) {
    assert(space >= 0, 'Space should be a non-negative value.');

    List<Widget> newChildren = [];
    for (int i = 0; i < children.length; i++) {
      newChildren.add(children[i]);
      if (i < children.length - 1) {
        newChildren.add(SizedBox(width: space));
      }
    }

    return Row(
      key: this.key,
      mainAxisAlignment: this.mainAxisAlignment,
      mainAxisSize: this.mainAxisSize,
      crossAxisAlignment: this.crossAxisAlignment,
      textDirection: this.textDirection,
      verticalDirection: this.verticalDirection,
      textBaseline: this.textBaseline,
      children: newChildren,
    );
  }

  /// Add a divider between each child.
  /// [width] is the width of the divider.
  /// [color] is the color of the divider.
  /// [thickness] is the thickness of the divider.
  /// [indent] is the indent of the divider.
  /// [endIndent] is the endIndent of the divider.
  /// Example:
  /// ```
  /// Row(
  /// children: [
  ///  Text("Hello"),
  ///  Text("World"),
  /// ]).withDivider(),
  IntrinsicHeight withDivider(
      {double width = 1,
      Color? color,
      double thickness = 1,
      double indent = 0,
      double endIndent = 0}) {
    List<Widget> newChildren = [];
    for (int i = 0; i < children.length; i++) {
      newChildren.add(children[i]);
      if (i < children.length - 1) {
        newChildren.add(VerticalDivider(
          width: width,
          color: color ?? Colors.grey.shade300,
          thickness: thickness,
          indent: indent,
          endIndent: endIndent,
        ));
      }
    }

    return IntrinsicHeight(
      child: Row(
        key: this.key,
        mainAxisAlignment: this.mainAxisAlignment,
        mainAxisSize: this.mainAxisSize,
        crossAxisAlignment: this.crossAxisAlignment,
        textDirection: this.textDirection,
        verticalDirection: this.verticalDirection,
        textBaseline: this.textBaseline,
        children: newChildren,
      ),
    );
  }
}

/// Extensions for [Text]
extension NyText on Text {
  /// Set the Style to use [displayLarge].
  Text displayLarge(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.displayLarge);
    }
    return this.setStyle(Theme.of(context).textTheme.displayLarge);
  }

  /// Set the Style to use [displayMedium].
  Text displayMedium(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.displayMedium);
    }
    return this.setStyle(Theme.of(context).textTheme.displayMedium);
  }

  /// Set the Style to use [displaySmall].
  Text displaySmall(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.displaySmall);
    }
    return this.setStyle(Theme.of(context).textTheme.displaySmall);
  }

  /// Set the Style to use [headlineLarge].
  Text headingLarge(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.headlineLarge);
    }
    return this.setStyle(Theme.of(context).textTheme.headlineLarge);
  }

  /// Set the Style to use [headlineMedium].
  Text headingMedium(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.headlineMedium);
    }
    return this.setStyle(Theme.of(context).textTheme.headlineMedium);
  }

  /// Set the Style to use [headlineSmall].
  Text headingSmall(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.headlineSmall);
    }
    return this.setStyle(Theme.of(context).textTheme.headlineSmall);
  }

  /// Set the Style to use [titleLarge].
  Text titleLarge(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.titleLarge);
    }
    return this.setStyle(Theme.of(context).textTheme.titleLarge);
  }

  /// Set the Style to use [titleMedium].
  Text titleMedium(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.titleMedium);
    }
    return this.setStyle(Theme.of(context).textTheme.titleMedium);
  }

  /// Set the Style to use [titleSmall].
  Text titleSmall(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.titleSmall);
    }
    return this.setStyle(Theme.of(context).textTheme.titleSmall);
  }

  /// Set the Style to use [bodyLarge].
  Text bodyLarge(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.bodyLarge);
    }
    return this.setStyle(Theme.of(context).textTheme.bodyLarge);
  }

  /// Set the Style to use [bodyMedium].
  Text bodyMedium(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.bodyMedium);
    }
    return this.setStyle(Theme.of(context).textTheme.bodyMedium);
  }

  /// Set the Style to use [bodySmall].
  Text bodySmall(BuildContext context) {
    if (style == null) {
      return copyWith(style: Theme.of(context).textTheme.bodySmall);
    }
    return this.setStyle(Theme.of(context).textTheme.bodySmall);
  }

  /// Make the font bold.
  Text fontWeightBold() {
    return copyWith(style: TextStyle(fontWeight: FontWeight.bold));
  }

  /// Make the font light.
  Text fontWeightLight() {
    return copyWith(style: TextStyle(fontWeight: FontWeight.w300));
  }

  /// Change the [style].
  Text setStyle(TextStyle? style) => copyWith(style: style);

  /// Aligns text to the left.
  Text alignLeft() {
    return copyWith(textAlign: TextAlign.left);
  }

  /// Aligns text to the right.
  Text alignRight() {
    return copyWith(textAlign: TextAlign.right);
  }

  /// Aligns text to the center.
  Text alignCenter() {
    return copyWith(textAlign: TextAlign.center);
  }

  /// Aligns text to the center.
  Text setMaxLines(int maxLines) {
    return copyWith(maxLines: maxLines);
  }

  /// Add padding to the text.
  Padding paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return Padding(
      padding:
          EdgeInsets.only(top: top, left: left, right: right, bottom: bottom),
      child: this,
    );
  }

  /// Change the [fontFamily].
  Text setFontFamily(String fontFamily) =>
      copyWith(style: TextStyle(fontFamily: fontFamily));

  /// Change the [fontSize].
  Text setFontSize(double fontSize) {
    if (style == null) {
      return copyWith(style: TextStyle(fontSize: fontSize));
    }
    return this.setStyle(TextStyle(fontSize: fontSize));
  }

  /// Helper to apply changes.
  Text copyWith(
      {Key? key,
      StrutStyle? strutStyle,
      TextAlign? textAlign,
      TextDirection? textDirection = TextDirection.ltr,
      Locale? locale,
      bool? softWrap,
      TextOverflow? overflow,
      TextScaler? textScaler,
      int? maxLines,
      String? semanticsLabel,
      TextWidthBasis? textWidthBasis,
      TextStyle? style}) {
    return Text(this.data ?? "",
        key: key ?? this.key,
        strutStyle: strutStyle ?? this.strutStyle,
        textAlign: textAlign ?? this.textAlign,
        textDirection: textDirection ?? this.textDirection,
        locale: locale ?? this.locale,
        softWrap: softWrap ?? this.softWrap,
        overflow: overflow ?? this.overflow,
        textScaler: textScaler ?? this.textScaler,
        maxLines: maxLines ?? this.maxLines,
        semanticsLabel: semanticsLabel ?? this.semanticsLabel,
        textWidthBasis: textWidthBasis ?? this.textWidthBasis,
        style: style != null ? this.style?.merge(style) ?? style : this.style);
  }
}

extension NyBackpack<T> on String {
  /// Read a value from the Backpack instance.
  T? fromBackpack<T>({dynamic defaultValue}) {
    return Backpack.instance.read<T>(this, defaultValue: defaultValue);
  }

  /// Read a StorageKey value from NyStorage
  Future<T?> fromStorage<T>({dynamic defaultValue}) async {
    return await NyStorage.read<T>(this, defaultValue: defaultValue);
  }

  /// Read a StorageKey value from NyStorage
  Future<T?> read<T>({dynamic defaultValue}) async {
    return await fromStorage(defaultValue: defaultValue);
  }

  /// Store a value in NyStorage
  /// You can also store a value in the backpack by setting [inBackpack] to true
  store(dynamic value, {bool inBackpack = false}) async {
    return await NyStorage.store(this, value, inBackpack: inBackpack);
  }

  /// Add a value to a collection in NyStorage
  /// You can also set [allowDuplicates] to false to prevent duplicates
  addToCollection(dynamic value, {bool allowDuplicates = true}) async {
    return await NyStorage.addToCollection<T>(this,
        item: value, allowDuplicates: allowDuplicates);
  }

  /// Read a collection from NyStorage
  Future<List<T>> readCollection<T>() async {
    return await NyStorage.readCollection(this);
  }

  /// Delete a StorageKey value from NyStorage
  deleteFromStorage({bool andFromBackpack = false}) async {
    return await NyStorage.delete(this, andFromBackpack: andFromBackpack);
  }
}

/// Extension on the `List<T>` class that adds a `paginate` method for easy
/// pagination of list elements.
extension Paginate<T> on List<T> {
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

/// Check if the device is in Dark Mode
extension DarkMode on BuildContext {
  /// Example
  /// if (context.isDarkMode) {
  ///   do something here...
  /// }
  bool get isDarkMode {
    final brightness = MediaQuery.of(this).platformBrightness;
    return brightness == Brightness.dark;
  }
}

extension NyContext on BuildContext {
  /// Get the TextTheme
  TextTheme textTheme() {
    return Theme.of(this).textTheme;
  }

  /// Get the MediaQueryData
  MediaQueryData mediaQuery() {
    return MediaQuery.of(this);
  }

  /// Pop the current page
  pop<T extends Object?>({T? result}) {
    Navigator.of(this).pop(result);
  }

  /// Get the width of the screen
  double widgetWidth() {
    return mediaQuery().size.width;
  }

  /// Get the height of the screen
  double widgetHeight() {
    return mediaQuery().size.height;
  }
}

extension NyMapEntry on Iterable<MapEntry<String, dynamic>> {
  /// Convert an Iterable<MapEntry<String, dynamic>> to a Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return Map.fromEntries(this);
  }
}
