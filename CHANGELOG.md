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
