import 'package:flutter/material.dart';
import 'controller.dart';

/// Base NyController
class NyController extends BaseController {
  BuildContext? context;
  NyRequest? request;
  NyController({this.context, this.request}) : super(context: context);
}
