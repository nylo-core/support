/// Used for creating files.
class NyTemplate {
  String name;
  String saveTo;
  List<String> pluginsRequired = [];
  String stub;

  NyTemplate(
      {required this.name,
      required this.saveTo,
      required this.pluginsRequired,
      required this.stub});
}
