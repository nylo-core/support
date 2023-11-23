/// Used for creating files.
class NyTemplate {
  String name;
  String saveTo;
  List<String> pluginsRequired = [];
  String stub;
  Map<String, dynamic> options = {};

  NyTemplate(
      {required this.name,
      required this.saveTo,
      required this.pluginsRequired,
      required this.stub,
      this.options = const {}});
}
