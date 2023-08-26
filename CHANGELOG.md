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
