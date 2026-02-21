![Nylo Banner](https://nylo.dev/images/nylo_logo_header.png)

## Nylo Support

Support library for the Flutter [Nylo Framework](https://nylo.dev).

[![pub package](https://img.shields.io/pub/v/nylo_support.svg)](https://pub.dev/packages/nylo_support)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

---

### About

This package provides the core utilities and features that power the Nylo framework. It includes routing, state management, networking, storage, widgets, testing, and more.

### Getting Started

Import everything with a single import:

```dart
import 'package:nylo_support/ny_core.dart';
```

Or import individual modules:

```dart
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/networking/ny_networking.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';
```

### Features

- **Routing** - Simple and powerful router with page transitions, route guards, and deep linking
- **Networking** - API services with Dio, `NyResponse`, `CachePolicy`, `NetworkLogger`, and authentication handling
- **State Management** - `NyState` and `NyPage` widgets with lifecycle helpers
- **Storage** - Secure local storage with `NyStorage` and `Backpack` for easy data persistence
- **Forms** - Build forms quickly with `NyForm`, built-in validation rules, and fields like `FormSlider`, `FormRangeSlider`, and `FormTextField`
- **Widgets** - Ready-to-use widgets like `CollectionView`, `InputField`, `StyledText`, `FadeOverlay`, `Connective`, and more
- **Theming** - `NyThemeManager` with reactive updates, system theme following, animated transitions, and secure persistence
- **Testing** - Built-in testing framework with `NyTest`, `NyWidgetTest`, `NyFactory`, `NyMockApi`, time manipulation, and Pest-style syntax
- **Connectivity** - `NyConnectivity` helper and `Connective` widget for reactive network state handling
- **Localization** - Multi-language support with `LanguageSwitcher` widget
- **Events** - Event bus for decoupled communication between components
- **Animations** - `ButtonAnimationStyle` (bounce, pulse, squeeze, jelly, shine) and `ButtonSplashStyle` effects
- **Helpers** - Extensions and utilities for common Flutter tasks including `openUrl`, `NyEnvRegistry`, and more

### Installation

```yaml
dependencies:
  nylo_support: ^7.5.0
```

### Documentation

- [Nylo Docs](https://nylo.dev/docs) - Full framework documentation
- [API Reference](https://pub.dev/documentation/nylo_support/latest/) - Package API docs

### Requirements

- Dart >= 3.10.7
- Flutter >= 3.24.0

### Changelog

See the [CHANGELOG](https://github.com/nylo-core/support/blob/7.x/CHANGELOG.md) for release updates.

### Licence

MIT © [Nylo](https://nylo.dev)
