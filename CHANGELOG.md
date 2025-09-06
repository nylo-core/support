## [6.35.1] - 2025-09-06

* Update pubspec.yaml

## [6.35.0] - 2025-07-18

* Fix stateData in `NyState` to return the correct data type

## [6.34.0] - 2025-07-17

* Added `lifecycleActions` to `Nylo.init`. This will allow you to global handle your app's lifecycle.
* Add missing annotations
* Update pubspec.yaml

## [6.33.0] - 2025-07-14

* Added `lifecycleActions` to `NyPage`. This will allow you to handle lifecycle events in your pages.
* Update pubspec.yaml

## [6.32.0] - 2025-07-02

* Added `excludeKeys` to `NyStorage.deleteAll`. This will allow you to exclude certain keys from being deleted when calling `deleteAll`.
* Added `hasExecutedTaskOnce` in NyScheduler. This will allow you to check if a task has been executed.
* Update pubspec.yaml
 
## [6.31.0] - 2025-06-23

* Added `set` to NySession class. This will allow you to set a value in the session.
* Added `onFailure` parameter to isSuccessful method in `NyValidator`.
* Fix `getInitialRouteName` to return the correct initial route name when, `when` is used.

## [6.30.0] - 2025-06-23

* Added `PullableConfig` to pullable widget.
* Update pubspec.yaml

## [6.29.0] - 2025-06-20

* Added new `visibleWhen` extension to `Widget` class. This will allow you to show or hide a widget based on a condition.
* Added `onPop` to the `pushTo` method. This will allow you to receive a callback when the page is popped.
* Added `removeFromIndex` to NyPullToRefresh. This will allow you to remove an item from the list at a specific index.
* Bug fix for `NyTextField` onChanged method.
* Fix analysis_options.yaml
* Update pubspec.yaml

## [6.28.5] - 2025-05-23

* Fix: `getEnv` helper to return an empty string if a variable is set like this `APP_WEBSITE=""`
* Add Dart Console to project
* Update pubspec.yaml

## [6.28.4] - 2025-05-13

* Update pubspec.yaml 

## [6.28.3] - 2025-05-08

* Fix: `Field.date` not using the correct display format

## [6.28.2] - 2025-05-02

* Add: export 'form_chips and form_radio' to ny_widgets.dart
* Add: `prefixIcon` to Field.password

## [6.28.1] - 2025-04-30

* Fix: `_whenStateAction` method in `NyState`

## [6.28.0] - 2025-04-24

* Added: `nylo.broadcastEvents()`to broadcast events to all listeners.
* Added: `listenOn` to listen to events in your app. E.g. `listenOn<MyEvent>((event) {  });`
* Added: `listen` helper in NyPage and NyState to listen to events in your app. E.g. `listen<MyEvent>((event) {  });`
* Updated: `event` helper to support new `broadcast` parameter. E.g. `event<MyEvent>(data: {...}, broadcast: true);`

## [6.27.0] - 2025-04-19

* Small breaking change to `stateActions`: 
  * Was: `Map<String, Function()> get stateActions`
  * Now: `Map<String, Function> get stateActions`
* Added: `JourneyProgressStyle? progressStyle;` to journey widget
* Added: `JourneyButtonStyle? buttonStyle;` to journey widget
* Added: `backgroundGradient` to bottomNav, topNav and journey widget
* Updated: `stateAction` to support new `data` parameter
* New progress styles added to `JourneyProgressStyle` - `linear`, `dots`, `numbered`, `segments`, `circular`, `timeline`, `custom`
* New `JourneyButtonStyle` added to `JourneyState` - `default`, `primary`, `secondary`, `tertiary`
* New `JourneyButtonStyle` added to `JourneyState` - `standard`, `minimal`, `outlined`, `contained`, `custom`

## [6.26.0] - 2025-04-16

* Added: `JourneyState` class to help manage `NavigationHubLayout.journey`
* Added: `JourneyHelper` class to help manage JourneyState's
* Added: `makeJourneyWidget` method to `MetroService` class
* Added: `parentOption` to constants
* Added: `syncToStorage` method to NySession class. This will sync the session data to storage
* Added: `syncFromStorage` method to NySession class. This will sync the session data from storage

## [6.25.1] - 2025-04-09

* Fix `NyStorage.read` method

## [6.25.0] - 2025-04-08

* Added: `makeCommand` to MetroService class. This will allow you to create a custom command in your project.
* Added: `addPackages` method to MetroService
* Added: `dev` parameter to `addPackages` and `addPackage` methods
* Added: `withQueryParams` to RouteView class
* Added: `hasQueryParameter(String key)` to NyState class. This will allow you to check if a query parameter exists in the current route.
* Update: `runProcess` to connect all streams to the process

## [6.24.0] - 2025-04-02

* Merge PR contribution from [voytech-net](https://github.com/voytech-net) #37 

## [6.23.0] - 2025-04-01

* Added: `toTimestamp()` helper for `DateTime` to convert to a timestamp
* Tidy: `NyTextField` class
* Fix: `NyPage` stateName if not given correct closure name
 
## [6.22.1] - 2025-03-31

* Fix: `Auth.authenticate` method not setting the correct object data for the `Backpack` class

## [6.22.0] - 2025-03-27

* Update: `session` helper to support 'items'. E.g. `session('onboarding', {"first_name": "john"})`, now session will contain `{"first_name": "john"}`
* Update: `session` helper 'data' method to support `data([String? key])` to get the session data. E.g. `session('onboarding').data('first_name')`
* Fix: Cannot add new events after calling close in NyForm [231](https://github.com/nylo-core/nylo/issues/231)
* Update pubspec.yaml

## [6.21.0] - 2025-03-21

* Small fix for `BadgeTab`
* Refactor imports to not include `package:nylo_support`
* New PageTransitionTypes: scale, rotate, size, rightToLeftWithFade, leftToRightWithFade, leftToRightJoined, rightToLeftJoined, topToBottomJoined, bottomToTopJoined, leftToRightPop, rightToLeftPop, topToBottomPop, bottomToTopPop, sharedAxisHorizontal, sharedAxisVertical, sharedAxisScale
* New `TransitionType` added for route transitions. E.g. `routeTo(HomePage.path, transitionType: TransitionType.fade())`
* Ability to `setBadgeNumber` of app icon
* Update pubspec.yaml

## [6.20.1] - 2025-02-28

* Add `ny_future_builder.dart` to `ny_widgets` library

## [6.20.0] - 2025-02-27

* Added `label` to Forms. E.g. `Field.email('Email', label: 'Email Address')`
* Added `Radio` to Forms. E.g. `Field.radio("Favourite Color", options: ["Red", "Blue", "Green"])`
* Added `Widget` to Forms. E.g. `Field.widget(child: MyWidget())`
* Add `submitButton` to `NyFormData` Read more [here](https://nylo.dev/docs/6.x/forms#submit-button)
* Add ny_networking.dart, ny_router.dart, ny_alerts.dart, ny_helpers.dart to make it easier to import the different parts of the library
* Update sleep method to support micro seconds. E.g. `sleep(0, 500)` will sleep for 500 microseconds
* Small bug fix for `NavigationTab.alerts`
* Merge PR from [israelins85](https://github.com/nylo-core/support/pull/35)
* Update pubspec.yaml

## [6.19.4] - 2025-02-26

* Update pubspec.yaml

## [6.19.3] - 2025-02-23

* Fix issue when resetting the `NyPullToRefresh` widget
* Added new `stateAction()` helper to allow you to send state actions to the `NyState` or `NyPage` class
* New `whenStateAction(Map<String, Function()> actions)` method added to `NyState` and `NyPage` classes to handle state actions
  * E.g. `whenStateAction({"showDialog": () => showDialog()})`
* New `Map<String, Function()> get stateActions => {}` getter added to `NyState` and `NyPage` classes to handle state actions
  * E.g. `Map<String, Function()> get stateActions => {"showDialog": () => showDialog()};` 
* Update pubspec.yaml

## [6.19.2] - 2025-02-10

* Fix issue with Forms setting dummyData even if app env is not dev
* Update pubspec.yaml

## [6.19.1] - 2025-02-05

* Update pubspec.yaml

## [6.19.0] - 2025-02-04

* Forms - Ability to set fields as `readOnly`
  * Fix issue "stream has already been listened to" #215 
* Fixes for NavigationHub
* Small refactor to `Pullable` widget
* Update pubspec.yaml

## [6.18.0] - 2025-02-02

* Add new `NavigationTab.alert` widget for supporting alerts in the NavigationTab
* New extension `toBool` and `tryParseBool` added to `String` class
* New StateActions added to `NavigationHubStateActions`
  * `alertEnableTab` - Enable the alert for a specific tab
  * `alertDisableTab` - Disable the alert for a specific tab
* Update pubspec.yaml

## [6.17.1] - 2025-01-29

* Fix small issue with `NavigationHub` not using the correct `icon` when active
* Update pubspec.yaml

## [6.17.0] - 2025-01-26

* Added comprehensive DateTime manipulation methods:
  * Year operations: `addYears()` and `subtractYears()`
  * Month operations: `addMonths()` and `subtractMonths()`
  * Day operations: `addDays()` and `subtractDays()`
  * Hour operations: `addHours()` and `subtractHours()`
  * Minute operations: `addMinutes()` and `subtractMinutes()`
  * Second operations: `addSeconds()` and `subtractSeconds()`
* Update NavigationHub to support the following:
  * Set a default current tab index: Override `currentIndex` in your `NavigationHub` class
  * New `bottomNavBuilder` method to build the bottom navigation bar
* DateTime extension: 
  * Allow `toDateString` to accept a `String` format
  * Add `toDateStringUK` to format the date in UK format
  * Add `toDateStringUS` to format the date in US format
* New `localAsset` method added to `AssetImage`
* Update pubspec.yaml

## [6.16.1] - 2025-01-16

* Small change to `getPublicAsset` to remove first slash if it exists

## [6.16.0] - 2025-01-16

* Add `Field.capitalizeSentences` and `Field.capitalizeWords`

## [6.15.0] - 2025-01-12

* Make `updatePageState` public
* Ensure `handleSuccess` handles responses within the correct status code range. Fixes [207](https://github.com/nylo-core/nylo/issues/207)
* Fix `header` parameter in NyPullToRefresh and NyListView
* Small fix for NyForm
* Improvements to NavigationHub to support Text tabs and Icons
* Updates to `NavigationTab` to support updating the Page, Title, Icon, Background Color and Tooltip
* Update pubspec.yaml

## [6.14.4] - 2025-01-06

* Fix issue with `NyState`

## [6.14.3] - 2025-01-04

* Update pubspec.yaml

## [6.14.2] - 2025-01-04

* Fix updateState method when using NyPage.path
* Small fix for route guards when using redirect
* Make `updatePageState` private
* Update pubspec.yaml

## [6.14.1] - 2024-12-31

* Small fix for `NyLanguageSwitcher` to support dark mode

## [6.14.0] - 2024-12-31

* Update copyright year
* New `currentTabIndex` method added to `NavigationHubStateActions` to set the current tab index

## [6.13.1] - 2024-12-29

* Fix form.dart

## [6.13.0] - 2024-12-29

* Fix validation max and min rules
* New `init` method added to Forms
* Small refactor to `NyForm` class
* Update loadingStyle `render` method

## [6.12.2] - 2024-12-22

* Fix stateName in NyState
* Slight refactor to `NyBaseState`

## [6.12.1] - 2024-12-19

* Fix `useLocalNotifications` in `Nylo` class
* Add `kIsWeb` check to `clearBadgeNumber`
* Update `date_field` to ^6.0.0

## [6.12.0] - 2024-12-18

* Add `headerSpacing` and `footerSpacing` to `NyForm`

## [6.11.0] - 2024-12-18

* Fix stops in `NyFader`
* Merge PR from [ruwiss](https://github.com/nylo-core/support/pull/32)

## [6.10.0] - 2024-12-16

* New `NyTextStyle` class
* New `NyColor` class
* Update form picker, form chips and checkbox to support light and dark colors better
* New `NyColor.resolveColor` method
* Remove `Nylo.package` method
* New `getAuthKey()` method

## [6.9.1] - 2024-12-13

* Update `delete` request to support optional parameters
 
## [6.9.0] - 2024-12-12

* Add `LoadingStyle` to helpers/loading_style.dart
* New `loadingStyle: loadingStyle` parameter added to `ButtonState` class
* Fix https://github.com/nylo-core/nylo/discussions/187

## [6.8.1] - 2024-12-08

* Fix `saveRemember` and `saveForever` in NyCache
* Update pubspec.yaml

## [6.8.0] - 2024-12-06

* New `Field.switchBox` added to `NyForm` to create a switch box field
* Localization support for picker and datetime fields
* `currency.toLowerCase()` in Field.currency()
* Update pubspec.yaml

## [6.7.1] - 2024-11-29

* Fix BadgeTab

## [6.7.0] - 2024-11-27

* Add `NyLocaleHelper`
* New `Nylo.package` helper for initializing packages
* Fix `NyStoreage.read` helper

## [6.6.0] - 2024-11-25

* New `nyPageName` extension helper added to `RouteView`
* Update `StateAction` to support `RouteView` paths

## [6.5.0] - 2024-11-23

* Dark mode support for Form fields: picker, date picker, checkbox and chips
* New helper `color({light, dark})` to get the color based on the theme
* New helper `whenTheme({light, dark})` to handle widgets based on the theme
* Add `NyThemeType` to BaseThemeConfig. This will allow you to set if a theme is light or dark
* Contribution from [stensonb](https://github.com/stensonb) to update the documentation for the sleep method
* Update pubspec.yaml

## [6.4.1] - 2024-11-22

* Update pubspec.yaml

## [6.4.0] - 2024-11-15

* New `initDio(Dio dio)` method added to `DioApiService`

## [6.3.0] - 2024-11-13

* Update `updateState` to support RouteView paths
* Allow `NyPage` to support stateManaged methods using `bool get stateManaged => true;`
* Update pubspec.yaml
 
## [6.2.0] - 2024-11-10

* Override `build` in NyPage to support loading using a Scaffold
* Rename `Session` to `NySession`
* Fix typo with skeletonizer
* Update pubspec.yaml

## [6.1.1] - 2024-11-08

* Update local push notifications
 
## [6.1.0] - 2024-11-04

* Add local push notifications

## [6.0.0] - 2024-11-02

* New version of Nylo - read more about the changes [here](https://nylo.dev/)

## [5.82.0] - 2024-07-18

* New `create` method added to `NyFormData` class. This will allow you to create the form from the instance.
* Add `FormStyle` to NyForm. This will allow you to set a global style for the form. It currently only supports `TextField` and `NyFormCheckbox` widgets.
* Ability to create custom validation rules in `NyForm`'s
* Added `refreshState` to `NyForm` class. This will refresh the state of the form.
* Added new typedefs `FormStyleTextField` and `FormStyleCheckbox` for handling custom styles in `NyForm`
* Added `clear` method to `NyForm` class. This will clear the form.
* Added `clearField` method to `NyForm` class. This will clear a specific field in the form.
* Update `setField` and `setData` methods in `NyForm` class. This will now update the state of the form after setting the field.
* Small refactor to the `NyTextField` class
* Refactor `NyFormCheckbox` class to support global styles
* `FormStyle` added to Nylo class
* Update pubspec.yaml

## [5.81.2] - 2024-07-09

* Update default toast widget text style

## [5.81.1] - 2024-07-09

* Remove default validation rule from `NyLoginForm`

## [5.81.0] - 2024-07-08

* Refactor `FormValidator` class.
  * To set a validation rule, you must now use `FormValidator.rule("email")` instead of `FormValidator("email")`
  * You can now join multiple validation rules. E.g. `FormValidator().minLength(5).uppercase()` will check if the value is at least 5 characters long and has an uppercase letter.
* Fix autofocus on `Field`'s in `NyForm`

## [5.80.0] - 2024-07-07

* Ability to create forms using slate packages

## [5.79.1] - 2024-07-06

* Fix slight issue with NyForm when handling validation rules
* Update `validate` helper in NyState to skip null values

## [5.79.0] - 2024-07-06

* Add new Forms
  * `NyFormCheckbox` - This will create a checkbox form field
  * `NyFormDateTimePicker` - This will create a date time picker form field
* Refactor `NyFormData` class
* pubspec.yaml dependency updates

## [5.78.1] - 2024-07-05

* Fix `deleteAll()` method in Backpack to not remove the `nylo` key

## [5.78.0] - 2024-07-03

* Remove `deepLink` required parameter for deep linking

## [5.77.0] - 2024-07-02

* New `NyForm` widget! Designed to help you create forms easier in your app.
* Fix password_v1 & password_v2 validation rule not working in all cases
* Update NyTextField to support different types of text fields
* Add `makeForm` to `MetroService` class to create a form
* Update `EmailRule`, `URLRule` to support `null` values
* Rename `PhoneNumberUsaRule` to `PhoneNumberUsRule`
* Update `textFieldMessage` on some validation rules
* Small refactor of `NyTextField` widget. The `copyWith` contains new parameters.
  * New `passwordViewable` parameter added to `NyTextField` widget
  * New `validateOnFocusChange` parameter added to `NyTextField` widget
* Update `NyState` to check when post frame is complete for a better user experience
* New `NyFormPicker` Widget added to the library - This will create a bottom modal with a picker. It can be used in NyForm's and as a standalone widget.
* New `NyForm.login` method added to `NyForm` class - This will create a login form
* Ability to add custom form casts to `NyForm` class via Nylo. E.g. `Nylo.addFormCasts({"my_cast": (value) => value.toString()});`
* Update docs
* Update pubspec.yaml

## [5.76.0] - 2024-06-16

* Add support for the `child` parameter in NyStatefulWidget to be a Function that returns a State.
* Update pubspec.yaml

## [5.75.3] - 2024-06-14

* Add await to `ErrorStack.init`

## [5.75.2] - 2024-06-14

* Update Error Stack to use `ErrorStackLogLevel.verbose` (default)
* Update pubspec.yaml

## [5.75.1] - 2024-06-14

* Update pubspec.yaml

## [5.75.0] - 2024-06-13

* Add new extensions `labelSmall`, `labelMedium` and `labelLarge` to `Text` widget

## [5.74.0] - 2024-06-12

* Small refactor to `NyRichText` widget
* Add `_errorStackErrorWidget` to `Nylo` class
* Update pubspec.yaml

## [5.73.1] - 2024-06-11

* Fix `MetroService` not properly suffixing the file names

## [5.73.0] - 2024-06-11

* Added `StorageConfig` class to the library. This will allow you to set the storage configuration for your app.
``` dart
StorageConfig.init(
   androidOptions: AndroidOptions(
      resetOnError: true,
      encryptedSharedPreferences: false
   )
);
```
* Set `NyRichText` style color to `Colors.black` by default

## [5.72.1] - 2024-06-11

* Update pubspec.yaml

## [5.72.0] - 2024-06-08

* Added `loadJson` method to helpers to load a json file

## [5.71.0] - 2024-06-06

* Added `containsRoutes` method to `Nylo` class. Now you can check if a route exists in your app. E.g. `Nylo.containsRoutes(["/home", "/settings"])`
* Fix `MetroService` duplicating slate file names

## [5.70.0] - 2024-06-05

* Update `NotEmptyRule` Validation rules to include `null`, `Map` and `List` types
* Update pubspec.yaml

## [5.69.5] - 2024-05-22

* Update pubspec.yaml

## [5.69.4] - 2024-05-17

* Update pubspec.yaml

## [5.69.3] - 2024-05-14

* Update pubspec.yaml

## [5.69.2] - 2024-05-12

* Update pubspec.yaml

## [5.69.1] - 2024-05-12

* Downgrade `flutter_secure_storage` to 9.0.0

## [5.69.0] - 2024-05-11

* Fix `NyState` not receiving state updates
* New `stateReset` method added to `NyListView` and `NyPullToRefresh`
* Add `StateAction.setState` method
* Update `flutter_secure_storage`
* Update pubspec.yaml

## [5.68.1] - 2024-05-05

* Update pubspec.yaml

## [5.68.0] - 2024-05-01

* Add `ErrorStack` to the library
* New `useErrorStack` helper added to Nylo. This will enable [ErrorStack](https://github.com/nylo-core/error-stack) in your application.
* Update pubspec.yaml

## [5.67.1] - 2024-04-29

* Update pubspec.yaml

## [5.67.0] - 2024-04-28

* Update `confirmAction` method in `NyState` to support more options

## [5.66.0] - 2024-04-25

* Add `updateRouteStack` to Nylo. This method will update the route stack with a new routes.
``` dart
  Nylo.updateRouteStack([
    HomePage.path,
    SettingPage.path
    ], dataForRoute: {
    SettingPage.path: {"name": "John Doe"}
    });
```
* Add `nylo.onDeepLink` to listen for deep link events in your app.
``` dart
  nylo.onDeepLink((String route, dynamic data) {
    print(data);
  });
```

## [5.65.2] - 2024-04-25

* Update `NyState` to check that `data` is of Type Map before calling `data[key]`

## [5.65.1] - 2024-04-20

* Fix `web` builds - https://github.com/nylo-core/nylo/discussions/122

## [5.65.0] - 2024-04-20

* Update `NyPullToRefresh` validate that the `data` is a List
* Update `NyListView` validate that the `data` is a List

## [5.64.0] - 2024-04-17

* Add the ability to set a custom transition to a `route.group` e.g. `router.group(() => {'transition': PageTransitionType.fade}, (router) { ... })`
* Add the ability to set a transition_settings to a `route.group` e.g. `router.group(() => {'transition_settings': PageTransitionSettings(duration: Duration(milliseconds: 500)}, (router) { ... })`
* Update `_getPageTransitionIsIos` to detect if the platform is iOS to use the CupertinoPageRoute for the transition
* Small refactor to `_getPageTransition.*` methods in router.dart
* Update pubspec.yaml

## [5.63.0] - 2024-04-08

* New `NyAction` class added to the library
  * `limitPerDay` method added to `NyAction` class - This will limit the number of times an action can be performed in a day.
  * `authorized` method added to `NyAction` class - This will check if the user is authorized to perform an action.

## [5.62.0] - 2024-04-01

* Add extra parameters to `ListView` for `NyListView.grid`

## [5.61.0] - 2024-03-29

* Added `updateCollectionWhere` to `NyStorage` class

## [5.60.1] - 2024-03-28

* Update pubspec.yaml

## [5.60.0] - 2024-03-26

* Added `footerLoadingIcon` to `NyPullToRefresh` widget

## [5.59.0] - 2024-03-26

* Remove `initializeDateFormatting` call in Nylo and app_localization.dart
* Update `_loggerPrint` not to print `Exception` if the message is empty
* Update `NyPullToRefresh`
* Update pubspec.yaml

## [5.58.0] - 2024-03-24

* Refactor app_localization.dart file. Breaking changes to the way you set up your app localization.
  * Removed `languagesList` parameter
  * Removed `valuesAsMap` parameter

## [5.57.0] - 2024-03-21

* Update `NyListView` to use default state management
* Added `router.add` so you can create routes easier
* Change `NyApiService` to use getter on `interceptors`
* Fix `MetroService` not automatically adding routes to router
* Update pubspec.yaml

## [5.56.1] - 2024-03-18

* Remove `Equatable` from `Model` class

## [5.56.0] - 2024-03-18

* Add `Equatable` to `Model` class
* Fix `modelDecoders` on NyStorage.addToCollection

## [5.55.0] - 2024-03-17

* Added `sort` method to `NyPullToRefresh` widget
* Added `sort` method to `NyListView` widget
* New parameter `modelDecoders` on `NyStorage.read` to define the model decoders when reading from storage
* New parameter `modelDecoders` on `NyStorage.readCollection` to define the model decoders when reading from storage
* New parameter `modelDecoders` on `dataToModel` to define the model decoders when reading from storage
* Remove `async` from `addModelDecoders` method

## [5.54.0] - 2024-03-10

* Added `router.group` method

## [5.53.0] - 2024-03-07

* Added `Future<void> wipeAllStorageData()` to `Nylo` class. Usage `Nylo.wipeAllStorageData()`
* Added `scheduleOnceAfterDate(String name, Function() callback, {required DateTime date})` to `Nylo` class. Usage `Nylo.scheduleOnceAfterDate('my_task', () => print('Hello'), date: DateTime.now().add(Duration(days: 1)))`
* Added `scheduleOnceDaily(String name, Function() callback, {DateTime? endAt})` to `Nylo` class. Usage `Nylo.scheduleDaily('my_task', () => print('Hello'), endAt: DateTime.now().add(Duration(days: 2)))`
* Added `scheduleOnce(String name, Function() callback)` to `Nylo` class. Usage `Nylo.scheduleOnce('my_task', () => print('Run once'))`
* Added `Future<DateTime?> appFirstLaunchDate()` to `Nylo` class. Usage `DateTime? dateTime = Nylo.appFirstLaunchDate()`
* Added `Future<int> appTotalDaysSinceFirstLaunch()` to `Nylo` class. Usage `int days = Nylo.appTotalDaysSinceFirstLaunch()`
* Added `Future<int?> appLaunchCount()` to `Nylo` class. Usage `int? count = Nylo.appLaunchCount()`
* Added `Future<void> appLaunched()` to `Nylo` class. Usage `Nylo.appLaunched()`
* Added `isSameDay(DateTime date)` to DateTime extension
* Added new `NyAppUsage` class to the library
* Added `monitorAppUsage()` to `Nylo` class. Usage `Nylo.monitorAppUsage()` - This will start monitoring the app usage like the first launch date, total days since first launch, launch count and more.
* Added `showDateTimeInLogs()` to optional show the date and time in logs
* Updated log method to add a ":" in-between log messages
* Fix `withGap` extension for `Column` widgets

## [5.52.0] - 2024-03-05

* Add new `toggleValue` method for `List`'s. This will toggle a value in a list. E.g. `myList.toggleValue(10);`

## [5.51.0] - 2024-03-03

* Add new `toSkeleton()` extension for `Widget`'s
* New `NyScheduler` class added to the library

## [5.50.0] - 2024-02-28

* Add new `NyRichText` widget

## [5.49.1] - 2024-02-28

* Remove debug print statement

## [5.49.0] - 2024-02-26

* New method `setSendTimeout` added to NyApiService
* New method `setReceiveTimeout` added to NyApiService
* New method `setConnectTimeout` added to NyApiService
* New method `setMethod` added to NyApiService
* New method `setContentType` added to NyApiService

## [5.48.1] - 2024-02-24

* Fix `NyTextField` to use `validationRules`
* Update `Dio` to 5.4.1

## [5.48.0] - 2024-02-16

* Add `toTimeAgoString` extension to DateTime
* Fix `onLanguageChange` method in `NyLanguageSwitcher`

## [5.47.0] - 2024-02-14

* Add `deleteFromCollectionWhere` for NyStorage. E.g. `NyStorage.deleteFromCollectionWhere((value) => value == 1, key: "myKey");`

## [5.46.0] - 2024-02-14

* Add `defaultValue` on the `match` function

## [5.45.0] - 2024-02-12

* New `StateAction` class for handling state actions

## [5.44.0] - 2024-02-08

* Add `NyTextField.emailAddress()` widget - This will create an email address text field
* Add `NyTextField.password()` widget - This will create a password text field
* Ability to set `passwordVisible` on `NyTextField` widget
* Add `NyTextField.compact()` widget - This will create a compact text field
* Add `password_v1` validation rule for checking if a password is valid
* Add `password_v2` validation rule for checking if a password is valid

## [5.43.1] - 2024-02-07

* Fix `NyListView.grid` Widget

## [5.43.0] - 2024-02-07

* Ability to set a Grid view in `NyListView` e.g. `NyListView.grid()`
* Ability to set a Grid view in `NyPullToRefresh` e.g. `NyPullToRefresh.grid()`
* Change `getRouteHistory` to return a `list` of the route history
* Change `getCurrentRouteArguments` to return a `map` of the current route arguments
* Change `getPreviousRouteArguments` to return a `map` of the previous route arguments
* Add `flutter_staggered_grid_view` to pubspec.yaml

## [5.42.1] - 2024-02-04

* Fix `_initLanguage` method in `app_localization.dart`

## [5.42.0] - 2024-02-04

* Add `NyLanguageSwitcher` widget
* Add check in app_localization.dart to see if an existing language is set

## [5.41.0] - 2024-02-02

* New `beforeRefresh` method added to NyPullToRefresh widget
* New `afterRefresh(dynamic data)` method added to NyListView widget

## [5.40.1] - 2024-02-02

* Update pubspec.yaml

## [5.40.0] - 2024-02-01

* Add `isMorning` extension to DateTime
* Add `isAfternoon` extension to DateTime
* Add `isEvening` extension to DateTime
* Add `isNight` extension to DateTime
* Update pubspec.yaml

## [5.39.0] - 2024-01-29

* Add new `updateCollectionByIndex` method in `NyStorage` class
* Add new `readJson` method in `NyStorage` class
* Add new `storeJson` method in `NyStorage` class

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
* New `NyPage` widget - Learn more [here](https://nylo.dev/docs/6.x/ny-page)
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
