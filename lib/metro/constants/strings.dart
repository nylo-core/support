// argument flags
const String fileOption = 'file';
const String helpFlag = 'help';
const String forceFlag = 'force';
const String themeDarkFlag = 'dark';
const String controllerFlag = 'controller';
const String modelFlag = 'model';
const String jsonFlag = 'json';
const String urlFlag = 'url';
const String authPageFlag = 'auth';
const String initialPageFlag = 'initial';

// options
const String postmanCollectionOption = 'postman';

// folders
const String yamlPath = 'pubspec.yaml';
const String controllersFolder = 'lib/app/controllers';
const String widgetsFolder = 'lib/resources/widgets';
const String pagesFolder = 'lib/resources/pages';
const String modelsFolder = 'lib/app/models';
const String themesFolder = 'lib/resources/themes';
const String providerFolder = 'lib/app/providers';
const String eventsFolder = 'lib/app/events';
const String networkingFolder = 'lib/app/networking';
const String networkingInterceptorsFolder =
    'lib/app/networking/dio/interceptors';
const String bootstrapFolder = 'lib/bootstrap';
const String configFolder = 'lib/config';
const String themeColorsFolder = 'lib/resources/themes/styles';
const String routeGuardsFolder = 'lib/routes/guards';
const String publicAssetsImagesFolder = 'public/assets/images';
const String langFolder = 'lang';

// import paths
String makeImportPathModel(String name, {String creationPath = ""}) =>
    "import '/app/models/${creationPath != "" ? creationPath + "/" : ""}$name.dart';";
String makeImportPathApiService(String name, {String creationPath = ""}) =>
    "import '/app/networking/${creationPath != "" ? creationPath + "/" : ""}${name}_api_service.dart';";
String makeImportPathEvent(String name, {String creationPath = ""}) =>
    "import '/app/events/${creationPath != "" ? creationPath + "/" : ""}${name}_event.dart';";
String makeImportPathProviders(String name, {String creationPath = ""}) =>
    "import '/app/providers/${creationPath != "" ? creationPath + "/" : ""}${name}_provider.dart';";
String makeImportPathConfigs(String name, {String creationPath = ""}) =>
    "import '/config/${creationPath != "" ? creationPath + "/" : ""}$name.dart';";
String makeImportPathBootstrap(String name) =>
    "import '/bootstrap/$name.dart';";
String makeImportPathInterceptor(String name) =>
    "import '/app/networking/dio/interceptors/$name.dart';";
