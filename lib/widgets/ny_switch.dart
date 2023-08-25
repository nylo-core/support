import 'package:flutter/cupertino.dart';

/// NySwitch allows you to switch between the [widgets] provided by passing in
/// a [indexSelected].
class NySwitch extends StatelessWidget {
  NySwitch({Key? key, this.indexSelected = 0, required this.widgets})
      : super(key: key);

  final int indexSelected;
  final List<Widget> widgets;

  @override
  Widget build(BuildContext context) {
    return widgets[indexSelected];
  }
}
