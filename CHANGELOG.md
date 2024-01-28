## [5.38.1] - 2024-01-28

* Change `sleep` to use seconds instead of milliseconds
* Rename `toJson` to `parseJson` on String extension

## [5.38.0] - 2024-01-28

* New `showInitialLoader` property added to `NyState` class

## [5.37.0] - 2024-01-27

* Add new `toDateTime` extension for Strings
* Update pubspec.yaml

## [5.36.0] - 2024-01-26

* Add new `toJson` extension for Strings
* Add `useSkeletonizer` to `NyPullToRefresh` widget
* Add `useSkeletonizer` to `NyListView` widget
* Add `useSkeletonizer` to NyFutureBuilder widget
* Update pubspec.yaml

## [5.35.1] - 2024-01-24

* Small refactor to `NyRouteGuard` class

## [5.35.0] - 2024-01-23

* Add new `sleep` helper
* Add `connectionTimeout` to network helper
* Add `receiveTimeout` to network helper
* Add `sendTimeout` to network helper
* New parameter `baseOptions` added to `NyApiService` constructor
 
## [5.34.1] - 2024-01-23

* Set `Intl.defaultLocale` in Nylo class
 
## [5.34.0] - 2024-01-22

* Add `setRetryIf` to DioApiService
* Add `retryIf` to `api` helper

## [5.33.0] - 2024-01-21

* Update `build` method in `NyState` to Skeletonize the `loading(BuildContext context)` widget
 
## [5.32.0] - 2024-01-17

* Add `queryParameters` to `routeTo` helper
* Add `queryParameters` to `NyState` helper
* Add `queryParameters` to `NyRequest` class
* Add `queryParameters` to `onTapRoute` helper
* Add `bottomNavFlag` to Strings

## [5.31.0] - 2024-01-15

* You can now set an API service as a singleton in your project. 
* Add `setRetry` to `api` helper
* Add `setRetryDelay` to `api` helper
* Add `setShouldSetAuthHeaders` to `api` helper
* Change `immortal` to `singleton` in `NyController`
* Add new validation helpers:
* date_age_is_younger - usage e.g. `date_age_is_younger:18` - This will check if the date is younger than the given age.
* date_age_is_older - usage e.g. `date_age_is_older:30` - This will check if the date is older than the given age.
* date_in_past - usage e.g. `date_in_past` - This will check if the date is in the past.
* date_in_future - usage e.g. `date_in_future` - This will check if the date is in the future.
* Refactor `apiDecoders` and `apiControllers` in `Nylo` class to support singletons.
* Tweaks to `MetroService` to support singletons.
* Add `skeletonizer` package to pubspec.yaml
* New `view(BuildContext context)` method added to `NyState` class - This can be used to create the view for your widget.
* New `loading(BuildContext context)` method added to `NyState` class - This can be used to create the loading widget for your widget.
* Update `max` and `min` validation rules to now validate Strings, Numbers, Lists and Maps.
* Added more docs to NyApiService
* `isDebuggingEnabled` added to `Nylo` class - This will check if the app is running in debug mode.
* `isEnvProduction` added to `Nylo` class - This will check if the app is running in production mode.
* `isEnvDeveloping` added to `Nylo` class - This will check if the app is running in development mode.

## [5.30.1] - 2024-01-13

* Patch for `_loggerPrint` function to resolve https://github.com/nylo-core/nylo/issues/96

## [5.30.0] - 2024-01-13

* New `dump` function added for printing out data in a readable format.
 
## [5.29.0] - 2024-01-11

* Add `skipIfExist` to **makeModel** method in `MetroService`

## [5.28.0] - 2024-01-06

* Change `languageCode` to use `locale` in `Nylo` class
* Add metaData to `ToastMeta`
* Update pubspec.yaml

## [5.27.0] - 2024-01-03

* Fix `NyPullToRefresh` widget not using the `padding` parameter
* Add new `locale` variable to `Nylo` class - Use `Nylo.locale` to get the current locale.

## [5.26.0] - 2024-01-03

* Add `isAgeYounger(int age)` helper to DateTime extension - This will check if the DateTime is younger than the given age.
* Add `isAgeOlder(int age)` helper to DateTime extension - This will check if the DateTime is older than the given age.
* Add `isAgeBetween(int min, int max)` helper to DateTime extension - This will check if the DateTime is between the given ages.
* Add `isAgeEqualTo(int age)` helper to DateTime extension - This will check if the DateTime is equal to the given age.
* Add locale to intl.DateFormat methods to allow you to set the locale of the date.

## [5.25.1] - 2024-01-02

* Change `toTimeString` to accept a `withSeconds` parameter

## [5.25.0] - 2024-01-01

* Fix `toShortDate` method
* New parameter added to `network` called `shouldSetAuthHeaders` - This will tell the network method if it should set the auth headers or not. You can also override `shouldSetAuthHeaders` in your `DioApiService` class.

## [5.24.0] - 2024-01-01

* Big updates to `DioApiService`
  * `network` method now accepts a `retry` parameter - Set how many times you want to retry the request if it fails.
  * `network` method now accepts a `retryIf` parameter - A function to check if the request should be retried.
  * `network` method now accepts a `retryDelay` parameter - Set how long you want to wait before retrying the request. 
  * Three new methods added to `DioApiService`:
    * `refreshToken` - Override this method to refresh your token.
    * `shouldRefreshToken` - Override this method to check if you should refresh the token.
    * `setAuthHeaders` - Override this method to set your own auth headers.
* Big updates to `MetroService` to allow you to create files in sub folders.
* Update **import paths** to support a `creationPath` when creating files in the project.
* Update `validate` method inside NyPage to support the latest way of validating data.
* Add more docs to library
* New extension `hasExpired` on DateTime object - This will check if the DateTime has expired. It's usage is for checking if a token has expired.
* Add queryParameters to `get` method inside API Service
* Add intl package to pubspec.yaml
* Remove dead code in Router

## [5.23.0] - 2023-12-25

* New `flexible` helper added for Stateless and Stateful widgets, e.g. `TextField().flexible()`
* Add `showToastSorry` method to `NyState` class
* Fix `addRouteGuard` helper for routes
* Add `pop` helper to controller
* New `is_type`, `is_true` and `is_false` validation rules
* Implement Pull to refresh for empty data
* Introducing a new flag you can set in your controllers `bool immortal = true;` this will allow your controller to live forever and not be disposed when the widget is removed from the tree.
* New `NyFader` widget added, this widget allows you to add a gradient fade from the bottom/top/right/left of a widget.
* You can also use the `faderBottom`, `faderTop`, `faderLeft` and `faderRight` helpers on a widget to add a gradient fade to the bottom/top/left/right of a widget.
* New `withGap` extension added to `Row` and `Column` widgets to add a gap between children.
* NyState new helper method added `confirmAction`, this will show a dialog to confirm an action.

## [5.22.0] - 2023-12-09

* Breaking changes
* You can no longer set `appLoader` as a variable in your `Nylo` class. You must now use the `addLoader(widget)` helper method.
* You can no longer set `appLogo` as a variable in your `Nylo` class. You must now use the `addLogo(widget)` helper method.
* Use `Nylo.appLoader()` to get the loading widget
* Use `Nylo.appLogo()` to get the app logo
* Use `Nylo.isCurrentRoute(MyHomePage.path)` to check if the current route matches the given route
* Set `apiDecoders` using `Nylo.addApiDecoders(apiDecoders)`
* Navigator observers added to Nylo
  * Get the observers using `Nylo.getNavigatorObservers()`
  * Add an observer using `Nylo.addNavigatorObserver()`
  * Remove an observer using `Nylo.removeNavigatorObserver(observer)`
* Upgrade router
  * Get the route history using `Nylo.getRouteHistory()`
    * Get the current route using `Nylo.getCurrentRoute()`
    * Get the previous route using `Nylo.getPreviousRoute()`
    * Get the current route name using `Nylo.getCurrentRouteName()`
    * Get the previous route name using `Nylo.getPreviousRouteName()`
    * Get the current route arguments using `Nylo.getCurrentRouteArguments()`
    * Get the previous route arguments using `Nylo.getPreviousRouteArguments()`
* Add `loading` parameter to `NyPullToRefresh` widget
* Add `loading` parameter to `NyListView` widget
* New `NyThemeOptions` added to store theme colors
* New `NyRouteHistoryObserver` class for handling route history
* Ability to chain a `transition` on a route e.g. `router.route(DashboardPage.path, (_) => DashboardPage()).transition(PageTransitionType.bottomToTop)`
* Ability to chain a `transitionSettings` on a route e.g. `router.route(DashboardPage.path, (_) => DashboardPage()).transitionSettings(PageTransitionSettings(duration: Duration(milliseconds: 500)))`
* Ability to chain a `addRouteGuard` on a route e.g. `router.route(DashboardPage.path, (_) => DashboardPage()).addRouteGuard(MyRouteGuard())`
* Ability to chain a `addRouteGuards` on a route e.g. `router.route(DashboardPage.path, (_) => DashboardPage()).addRouteGuards([MyRouteGuard(), MyRouteGuardTwo()])`
* Ability to chain a `authRoute` on a route e.g. `router.route(DashboardPage.path, (_) => DashboardPage()).authRoute() // new auth route`
* Ability to chain a `initialRoute` on a route e.g. `router.route(DashboardPage.path, (_) => DashboardPage()).initialRoute() // new initial route`

## [5.21.0] - 2023-12-03

* New `store()` method added to String extension. E.g. `await StorageKey.userToken.store("123");`
* New `read` method added to String extension. E.g. `await StorageKey.userToken.read()`
* New `addToCollection` method added to String extension. E.g. `await StorageKey.userToken.addToCollection("10");`
* New `readCollection` method added to String extension. E.g. `await StorageKey.userToken.readCollection()`
* Update `fromStorage` and `fromBackpack` method to accept a default value. E.g. `await StorageKey.userToken.fromStorage(defaultValue: "123");`

## [5.20.0] - 2023-12-02

* Add new `jsonFlag` to metro constants

## [5.19.0] - 2023-12-02

* New helper in `NyState` called `data()` to get data from the state.
* A lot of new Extensions added to the package.
  * `paddingOnly` and `paddingSymmetric` added to the following widgets:
    * `Text`
    * `Row`
    * `Column`
    * `Container`
    * `SingleChildRenderObjectWidget`
    * `StatelessWidget`
  * New `Image` extensions added:
    * `localAsset()` can be used to load an image from your assets folder. e.g. `Image.asset('my-image.png').localAsset() // load from assets folder`
    * `circleAvatar` can be used to load an image as a circle avatar. e.g. `Image.asset('my-image.png').circleAvatar()`
  * New `shadow` extension added to `Container` widget. e.g. `Container().shadow()` or `Container().shadowLg()`
* New `onTap` helper added to `StatelessWidget` e.g. `Text('Hello').onTap(() => print('Hello'))`
* New `onTapRoute` helper added to `StatelessWidget` e.g. `Text('Home Page').onTapRoute(HomePage.path)`

## [5.18.1] - 2023-12-01

* Update the pubspec.yaml

## [5.18.0] - 2023-11-27

* New extension `toMap` on `Iterable<MapEntry<String, dynamic>>` to convert a list of MapEntry's to a Map.

## [5.17.0] - 2023-11-25

* `NyStatefulWidget` controller is now not nullable. You can call the controller like this `widget.controller.myMethod()`.
* Add a mounted check in `NyState`'s validate helper.
* Slight change to the `network` helper to now always accept new bearerToken passed into the method.
* Update the `data()` method to accept a new `key` parameter. Now you can check for a key using `widget.controller.data('my_key')`.

## [5.16.0] - 2023-11-23

* Ability to set routes as the initial page and auth route in `MetroService`
* `NyTemplate` now contains a new **options** variable to set more meta data about the template
* Fix `MetroService` not adding api services to the config file

## [5.15.0] - 2023-11-22

* New `makeInterceptor` helper added to MetroService.
* New NyPage helpers added to `NyController`.
* Small refactor to NyPage class.
* Add `DioApiService` class to the package.
* Add `state` to Controller.
* Add more docs to methods/classes.
* Add dio and pretty_dio_logger to pubspec.yaml

## [5.14.0] - 2023-11-04

* New `runProcess` helper added to MetroService.

## [5.13.0] - 2023-10-23

* New `addToTheme` helper added to MetroService.

## [5.12.0] - 2023-10-19

* Update the look for Toast Notifications
* Add new parameter **setState** on `refreshPage` to set the state of the Widget. 
* New helpers added to `NyPage`
  * context
  * textTheme
  * mediaQuery

## [5.11.0] - 2023-10-17

* Improve regex to auto add classes and routes
* New `NyPage` widget - Learn more [here](https://nylo.dev/docs/5.x/ny-page)
* New helper for the Nylo class - `addControllers`
* Improve Metro to auto add controllers when created
* Add more docs
* New extensions added to BuildContext:
  * textTheme
  * mediaQuery
  * pop
  * widgetWidth
  * widgetHeight

## [5.10.1] - 2023-10-08

* Fix typo in log
* update validator & updateState docs

## [5.10.0] - 2023-10-01

* Ability to create config files
* Add `event_bus_plus` to the library
* Update pubspec.yaml

## [5.9.1] - 2023-09-22

* Update pubspec.yaml

## [5.9.0] - 2023-09-15

* Add optional **builder** callback to the `route.generator()` method. This can be used to override the default Widget returned.
* Update pubspec.yaml

## [5.8.2] - 2023-08-31

* Fix nyColorStyle to use the correct theme color

## [5.8.1] - 2023-08-31

* New helper to check if the device is in dark mode.

## [5.8.0] - 2023-08-31

* Ability to set a default value on NyStorage
* Fix https://github.com/nylo-core/framework/issues/35
* Ability to set a default value on `NyStorage.read`
* Update pubspec.yaml

## [5.7.0] - 2023-08-26

* Add new toast notification helpers to `NyState`
  * showToastWarning
  * showToastInfo
  * showToastDanger
* Fix toast_meta.dart style types

## [5.6.0] - 2023-08-25

* New feature - `paginate` through your `List`'s, you can now call `[1,2,3,4,5].paginate(itemsPerPage: 2, page: iteration).toList();`
* New Widget - `NySwitch` this widget allows you to provide a `List` of widgets and `index` for which should be the **child** widget.
* New paginate feature for the `nyApi` helper. Now you can pass in a page like `api<ApiService>((request) => request.listOfDataExample(), page: 1);`. This will add a query parameter on your url like "my-example-site.com/todos?page=1".
* Remove `color` helper from NyState
* Remove `stateInit` from NyState
* Add `stateData` to NyState
* Change afterLoad, afterNotNull and afterNotLocked to use `loading` as the new parameter when you need to override the Loading widget.
* Ability to set custom toast notifications
* Refactor toast notifications
* Refactor addToCollection() method `newItem` to `item`

## [5.5.1] - 2023-08-21

* Update pubspec.yaml

## [5.5.0] - 2023-08-21

* Add event_bus_plus to pubspec.yaml
* Add pull_to_refresh_flutter3 to pubspec.yaml
* Add new method `addEventBus` to Nylo class
* Ability to use `lockRelease` on the validate helper
* New widget - `NyPullToRefresh` this new widget provides a simple way to implement pull to refresh on your list views.
* New widget - `NyListView` this new widget provides a simple way to implement a list view.
* Change NyFutureBuilder to accept null in the `child` callback
* New `updateState` helper to allow your to update the state of a NyState from anywhere in your project
* Fix `syncToBackpack` method
* New extension `fromBackpack` on Strings - Allows you to read a model from your Backpack instance. E.g. `User user = StorageKey.authUser.fromBackpack()`.
* Fix validation rule `numeric`
* Improve `NyFutureBuilder` to allow null types to be returned in the `child(context, data)` callback
* New `reboot` method added to NyState, it will re-run your `boot()` method
* New route helpers `routeToAuth()` & `routeToInitial()`
* New `afterNotLocked()` method added to NyState.

## [5.4.0] - 2023-07-13

* New helper added to `Nylo` class `initRoutes()`

## [5.3.1] - 2023-07-03

* Add generic type to `saveCollection()` helper.

## [5.3.0] - 2023-06-17

* Fix validator

## [5.2.2] - 2023-06-14

* add lang folder to constants

## [5.2.1] - 2023-06-13

* fix issues from dart analyze

## [5.2.0] - 2023-06-13

* Add new constants
* Fix Slate's when using `MetroService`
* update git actions

## [5.1.3] - 2023-06-08

* Add new method to MetroService `runCommand` to replace `command` method in metro.
* Small refactor to **extensions.dart** file.

## [5.1.2] - 2023-05-28

* Add new extensions for bool types

## [5.1.1] - 2023-05-24

* Add generic type to `SyncAuthToBackpackEvent`.
* Fix `NyLogger.json` helper not formatting the output to JSON
* Add **key** parameter to `auth` 

## [5.1.0] - 2023-05-23

* New parameter added to `NyTextField` widget called `handleValidationError` - This new helper is a callback that can be used to handle any validation errors thrown
* New String extension `toHexColor()` - This will convert your strings into a `Color`. Try it "DB768E".toHexColor()
* Fix `api` helper not returning request data
* Added new extensions for `Text` 

## [5.0.0] - 2023-05-16

* Router
  * `authRoute` added to redirect to a certain route when a user is authenticated
  * `initialRoute` added to set an initial route in your project
  * `routeGuards` added to 'guard' a route
* Add new NyTextField widget.
* New `Model` class replaces `Storable`
* Auth
  * `Auth.user()` to find the authenticated user
  * `Auth.set( User() )` to set an authenticated user
  * `Auth.remove()` to remove an authenticated user
  * `Auth.loggedIn()` to check if a user is logged in
* Change `validator` in NyState to `validate`.
* Allow Nylo to accept custom validation rules from a project.
* Add to the `Backpack` class new methods:
  * **auth** to return the authenticated user
  * **isNyloInitialized** to check if Nylo is initialized
* Backpack `read` method will now accept a **defaultValue** parameter to be returned if no data is found.
* New helper methods:
  * **match** - Matches
  * **nyHexColor**
  * **nyColorStyle**
* `nyApi` will now accept `NyEvent`s so the data returned from your API requests will be passed to the events. 
* The `NyLogger` class will now only log if the project's **APP_DEBUG** is set to true.
* `NyProvider` class now has an `afterBoot` method which will be called after Nylo has finished 'booting'.
* Remove `Storable` class
* New helper in MetroService `makeRouteGuard`
* New Extensions added for objects
* `showNextLog()` added to force a log to show when the APP_DEBUG var is set to false
* Remove `logger` package
* DocBlocks added to some methods
* Pubspec.yaml dependency updates
* Version bump

## [4.4.0] - 2023-05-16

* Flutter v3.10.0 fixes:
  * Update: theme_provider package

## [4.3.1] - 2023-03-03

* Change `NyFutureBuilder` to a Stateless widget to fix refreshing data.

## [4.3.0] - 2023-02-22

* Allow the `BaseThemeConfig` class to accept generics.
* **--dart-define** variable change - `ENV_FILE_PATH` is now `ENV_FILE`.

## [4.2.0] - 2023-02-20

* Allow passing custom env file path 

## [4.1.1] - 2023-02-14

* Add logo to package
* Fix `syncToBackpack` method
* Pubspec.yaml dependency updates
* Version bump

## [4.1.0] - 2023-01-30

* Ability to set a baseUrl to a ApiService from the `nyApi` helper.
* Fix `Nylo.init` to call `setupFinished` if setup is null.
* New `NyFutureBuilder` widget which is a wrapper around FutureBuilder. Docs coming soon.
* You can now pass a **key** into the `data` variable.
* Update TextTheme styles for the `getAppTextTheme` method.
* New `syncToBackpack()` helper in the `NyStorage` class.
* Metro: Fix add page method
* NyStorage: New helpers to deleteAll from the `Backpack` class.
* Backpack: New `delete` & `deleteAll` methods.
* Version bump

## [4.0.0] - 2023-01-01

* MetroService - new `addToRouter` & `addToConfig` methods to allow you to manipulate config files.
* `NyTemplate` class added for building pre-made templates.
* Helper added for the Backpack class to return an instance of `Nylo` easier.
* `initialRoute` added to Nylo class.
* New `boot() async {}` added to NyState widget. If you override this method and call an async method, it will allow you to use the `afterLoad(child: () => MyWidget())` helper to display a loader until the async method completes.
* Pubspec.yaml dependency updates
* Version bump

## [3.5.0] - 2022-09-19

* Move `routeTo` helper from NyState to Router.
* New `PageTransitionSettings` class to pass transition settings such as Duration when using routeTo and the router.
* Version bump

## [3.4.0] - 2022-08-27

* Add base theme config for theme management in Nylo
* Add theme colors for color management in Nylo
* New helper for NyState class to fetch colors easier
* Ability to add a duration for page transitions
* Pubspec.yaml dependency updates
* Version bump

## [3.3.0] - 2022-07-27

* Merge PR from [youssefKadaouiAbbassi](https://github.com/youssefKadaouiAbbassi) that adds query parameters to the router e.g. "/my-page?hello=world" = {"hello": "world"}

## [3.2.0] - 2022-06-28

* New optional parameter `inBackpack` added to the `store` when using NyStorage class to also save to your Backpack instance
* Merge pull request [#17](https://github.com/nylo-core/support/pull/17) from @lpdevit to fix router navigation when using `transitionDuration`
* Pubspec.yaml dependency updates
* Version bump

## [3.1.0] - 2022-05-19

* New helpers added to NyState: `awaitData` and `lockRelease`.
* Version bump

## [3.0.1] - 2022-05-04

* Fix `nyApi` helper not returning a value
* Remove resource flag

## [3.0.0] - 2022-04-29

* New arguments for Nylo's `init` method: setup, setupFinished
* Add init method for NyState class
* New helpers: nyEvent, nyApi and Backpack
* assert condition added to DefaultResponse class

## [2.8.0] - 2022-04-21

* Revert new init method in Nylo

## [2.7.0] - 2022-04-21

* Version bump

## [2.6.1] - 2022-04-21

* Fix Nylo init method with router param

## [2.6.0] - 2022-04-21

* Revert init change in NyState.
* New Metro command to create events in Nylo.
* bootApplication helper added.
* Small refactor to folder names

## [2.5.0] - 2022-04-19

* New Metro command to create Providers in Nylo.
* New Metro command to create API Services in Nylo.
* NyProvider added as a base class for Providers.

## [2.4.0] - 2022-03-29

* New helper method added to NyState `whenEnv`
* Fix translations when supplying more than 1 argument
* Generic class for networking requests added
* Pubspec.yaml dependency updates

## [2.3.1] - 2021-12-17

* Add @mustCallSuper for construct method

## [2.3.0] - 2021-12-12

* Fix [BaseController] construct method
* override setState in NyState

## [2.2.1] - 2021-12-10

* Upgrade to Dart 2.15
* Update toast notifications
* Refactor methods in localization

## [2.2.0] - 2021-12-07

* New validator added to NyState. Allows you to validate data in widgets.
* Added toast notification helper
* Refactored localization class
* Ability to create themes and theme colors from Metro Cli
* Pubspec.yaml dependency updates
* Bug fixes

## [2.1.0] - 2021-09-21

* Fix `updateLocale` method
* Ability to add additional Router's to Nylo

## [2.0.1] - 2021-09-18

* Upgrade Dart (v2.14.0)

## 2.0.0 - 2021-09-10

* Add routes from NyPlugin
* NyState has new 'get' helpers for TextTheme and MediaQuery
* NyStorage 'read' method now returns more accurate data types if a type is not specified
* New template for NyPlugin's
* Added a MetroService and MetroConsole class for cli operations
* Pubspec.yaml dependency updates

## 1.0.0 - 2021-07-07

* Initial release.
