import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('NavigationTab', () {
    nyGroup('default constructor', () {
      nyTest('should create with required fields', () async {
        final tab = NavigationTab(title: 'Home', page: SizedBox.shrink());
        expect(tab.title, 'Home');
        expect(tab.page, isNotNull);
        expect(tab.kind, 'default');
        expect(tab.meta, isEmpty);
      });

      nyTest('should accept optional fields', () async {
        final icon = Icon(CupertinoIcons.home);
        final tab = NavigationTab(
          title: 'Home',
          page: SizedBox.shrink(),
          icon: icon,
          tooltip: 'Home Page',
        );
        expect(tab.icon, icon);
        expect(tab.tooltip, 'Home Page');
      });
    });

    nyGroup('tab constructor', () {
      nyTest('should set kind to tab', () async {
        final tab = NavigationTab.tab(title: 'Search', page: SizedBox.shrink());
        expect(tab.kind, 'tab');
      });

      nyTest('should default meta to empty map', () async {
        final tab = NavigationTab.tab(title: 'Search', page: SizedBox.shrink());
        expect(tab.meta, isEmpty);
      });
    });

    nyGroup('badge constructor', () {
      nyTest('should set kind to badge', () async {
        final tab = NavigationTab.badge(title: 'Cart', page: SizedBox.shrink());
        expect(tab.kind, 'badge');
      });

      nyTest('should store initialCount in meta', () async {
        final tab = NavigationTab.badge(
          title: 'Cart',
          page: SizedBox.shrink(),
          initialCount: 5,
        );
        expect(tab.meta['initialCount'], 5);
      });

      nyTest('should default rememberCount to true', () async {
        final tab = NavigationTab.badge(title: 'Cart', page: SizedBox.shrink());
        expect(tab.meta['rememberCount'], isTrue);
      });
    });

    nyGroup('alert constructor', () {
      nyTest('should set kind to alert', () async {
        final tab = NavigationTab.alert(
          title: 'Notifications',
          page: SizedBox.shrink(),
        );
        expect(tab.kind, 'alert');
      });

      nyTest('should store alertEnabled in meta', () async {
        final tab = NavigationTab.alert(
          title: 'Notifications',
          page: SizedBox.shrink(),
          alertEnabled: true,
        );
        expect(tab.meta['alertEnabled'], isTrue);
      });

      nyTest('should default rememberAlert to true', () async {
        final tab = NavigationTab.alert(
          title: 'Notifications',
          page: SizedBox.shrink(),
        );
        expect(tab.meta['rememberAlert'], isTrue);
      });
    });

    nyGroup('journey constructor', () {
      nyTest('should set kind to journey', () async {
        final tab = NavigationTab.journey(page: SizedBox.shrink());
        expect(tab.kind, 'journey');
      });

      nyTest('should have null title', () async {
        final tab = NavigationTab.journey(page: SizedBox.shrink());
        expect(tab.title, isNull);
      });

      nyTest('should have empty meta', () async {
        final tab = NavigationTab.journey(page: SizedBox.shrink());
        expect(tab.meta, isEmpty);
      });
    });

    nyGroup('update methods', () {
      late NavigationTab tab;

      setUp(() {
        tab = NavigationTab(title: 'Original', page: SizedBox.shrink());
      });

      nyTest('updatePage should update page', () async {
        final newPage = Text('New');
        tab.updatePage(newPage);
        expect(tab.page, newPage);
      });

      nyTest('updateTitle should update title', () async {
        tab.updateTitle('New Title');
        expect(tab.title, 'New Title');
      });

      nyTest('updateIcon should update icon', () async {
        final newIcon = Icon(CupertinoIcons.search);
        tab.updateIcon(newIcon);
        expect(tab.icon, newIcon);
      });

      nyTest('updateActiveIcon should update active icon', () async {
        final newActiveIcon = Icon(CupertinoIcons.search_circle_fill);
        tab.updateActiveIcon(newActiveIcon);
        expect(tab.activeIcon, newActiveIcon);
      });

      nyTest('updateBackgroundColor should update color', () async {
        tab.updateBackgroundColor(Color(0xFFFF0000));
        expect(tab.backgroundColor, Color(0xFFFF0000));
      });

      nyTest('updateTooltip should update tooltip', () async {
        tab.updateTooltip('New tooltip');
        expect(tab.tooltip, 'New tooltip');
      });
    });
  });
}
