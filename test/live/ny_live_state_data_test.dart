import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/event_bus/ny_event_bus.dart';
import 'package:nylo_support/helpers/ny_helpers.dart';
import 'package:nylo_support/live/ny_live.dart';
import 'package:nylo_support/live/src/live_state_inspector.dart';
import 'package:nylo_support/nylo.dart';
import 'package:nylo_support/router/ny_router.dart';
import 'package:nylo_support/testing/ny_testing.dart';
import 'package:nylo_support/widgets/ny_widgets.dart';

class Conversation extends Model {
  Conversation(this.id, this.title);

  final int id;
  final String title;

  @override
  Map<String, dynamic> toJson() => {'id': id, 'title': title};
}

/// A page with a controller, route data, state actions and fields of its own.
class ConversationDetailPage extends NyStatefulWidget {
  static RouteView path = (
    '/conversation-detail',
    (_) => ConversationDetailPage(),
  );

  ConversationDetailPage({super.key})
    : super(child: () => _ConversationDetailPageState());
}

class _ConversationDetailPageState extends NyPage<ConversationDetailPage> {
  Conversation? conversation = Conversation(42, 'Team standup');
  List<Conversation> messages = [Conversation(1, 'hi'), Conversation(2, 'yo')];
  bool isTyping = false;

  @override
  Map<Object, Function> get stateActions => {
    'refresh': () {},
    #markRead: () {},
  };

  @override
  Widget view(BuildContext context) =>
      Scaffold(body: MessageListWidget(key: const Key('messages')));
}

/// A NyState nested inside the page.
class MessageListWidget extends StatefulWidget {
  const MessageListWidget({super.key});

  @override
  createState() => _MessageListWidgetState();
}

class _MessageListWidgetState extends NyState<MessageListWidget> {
  _MessageListWidgetState() : super(name: 'message-list');

  @override
  Widget view(BuildContext context) => const Text('messages');
}

/// A page that isn't a NyPage or NyState at all.
class PlainPage extends StatelessWidget {
  const PlainPage({super.key});

  @override
  Widget build(BuildContext context) => const Text('plain');
}

void main() {
  NyTest.init();

  late NyRouter router;

  setUp(() {
    NyEnvRegistry.register(
      getter: (String key, {dynamic defaultValue}) => defaultValue,
      containsKey: (String key) => false,
    );
    Backpack.instance.save('nylo', Nylo());
    Backpack.instance.save('event_bus', EventBus(maxHistoryLength: 10));
    nyLiveInspectedState = null;
    router = NyRouter();
    NyNavigator.instance.router = router;
    NyNavigator.instance.prefixRoutes.clear();
    router.route('/home', (context) => const Text('Home')).initialRoute();
    router.route('/conversation-detail', (context) => ConversationDetailPage());
    router.route('/plain', (context) => const PlainPage());
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: router.navigatorKey,
        onGenerateRoute: router.generator(),
        initialRoute: '/home',
        navigatorObservers: [NyRouteHistoryObserver()],
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Runs a live command while pumping frames so navigation can finish.
  Future<Object?> run(
    WidgetTester tester,
    String command, [
    Map<String, dynamic> args = const {},
  ]) async {
    Object? result;
    Object? error;
    bool done = false;
    NyLive.dispatch(command, args).then(
      (value) {
        result = value;
        done = true;
      },
      onError: (Object e) {
        error = e;
        done = true;
      },
    );
    for (int i = 0; i < 400 && !done; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();
    if (error != null) throw error!;
    return result;
  }

  Future<LiveException> runError(
    WidgetTester tester,
    String command, [
    Map<String, dynamic> args = const {},
  ]) async {
    try {
      await run(tester, command, args);
    } on LiveException catch (e) {
      return e;
    }
    fail('Expected "$command" to fail');
  }

  /// Opens the conversation page with [data] and returns the `state.data` reply.
  Future<Map<String, Object?>> openDetail(
    WidgetTester tester, {
    Object? data = const {'id': 42, 'title': 'Team standup'},
    Map<String, dynamic> args = const {},
  }) async {
    await pumpApp(tester);
    await run(tester, 'route.push', {
      'path': '/conversation-detail',
      'data': data,
    });
    return Map<String, Object?>.from(
      await run(tester, 'state.data', args) as Map,
    );
  }

  nyWidgetTest('state.data describes the page on screen', (tester) async {
    final Map<String, Object?> payload = await openDetail(tester);

    expect(payload['route'], '/conversation-detail');
    final Map<String, Object?> state = Map<String, Object?>.from(
      payload['state'] as Map,
    );
    expect(state['widget'], 'ConversationDetailPage');
    expect(state['state'], '_ConversationDetailPageState');
    expect(state['kind'], 'NyPage');
    expect(state['name'], 'Closure: () => _ConversationDetailPageState');
    expect(state['controller'], 'NyController');
    expect(state['data'], {'id': 42, 'title': 'Team standup'});
    expect(state['actions'], ['refresh', '#markRead']);
  });

  nyWidgetTest('state.data lists the nested states, page first', (
    tester,
  ) async {
    final Map<String, Object?> payload = await openDetail(tester);

    expect(
      (payload['states'] as List).map((s) => (s as Map)['state']).toList(),
      ['_ConversationDetailPageState', '_MessageListWidgetState'],
    );
    expect((payload['states'] as List).last, containsPair('kind', 'NyState'));
    expect(
      (payload['states'] as List).last,
      containsPair('name', 'message-list'),
    );
  });

  nyWidgetTest('state.data reports the route data a page was opened with', (
    tester,
  ) async {
    final Map<String, Object?> payload = await openDetail(
      tester,
      data: [1, 2, 3],
    );

    expect((payload['state'] as Map)['data'], [1, 2, 3]);
  });

  nyWidgetTest('state.data captures the state for Metro to read fields from', (
    tester,
  ) async {
    await openDetail(tester);

    expect(nyLiveInspectedState, isA<_ConversationDetailPageState>());
    final Map<String, Object?> inspect = Map<String, Object?>.from(
      (await run(tester, 'state.data') as Map)['inspect'] as Map,
    );
    expect(inspect['variable'], 'nyLiveInspectedState');
    expect(inspect['encoder'], 'nyLiveInspectJson');
    expect(inspect['library'], LiveStateInspector.libraryUri);
    expect(inspect['skip'], LiveStateInspector.frameworkStateClasses);
  });

  nyWidgetTest('a target picks a nested state by name, class or widget', (
    tester,
  ) async {
    await openDetail(tester);

    for (final String target in [
      'message-list',
      'MessageListWidget',
      '_MessageListWidgetState',
      'messagelist',
    ]) {
      final Map<String, Object?> payload = Map<String, Object?>.from(
        await run(tester, 'state.data', {'target': target}) as Map,
      );
      expect(
        (payload['state'] as Map)['state'],
        '_MessageListWidgetState',
        reason: 'target "$target"',
      );
      expect(nyLiveInspectedState, isA<_MessageListWidgetState>());
    }
  });

  nyWidgetTest('an exact target wins over one that only contains it', (
    tester,
  ) async {
    await openDetail(tester);

    final Map<String, Object?> payload = Map<String, Object?>.from(
      await run(tester, 'state.data', {'target': 'ConversationDetailPage'})
          as Map,
    );

    expect((payload['state'] as Map)['widget'], 'ConversationDetailPage');
  });

  nyWidgetTest('an unknown target says what is on screen', (tester) async {
    await openDetail(tester);

    final LiveException error = await runError(tester, 'state.data', {
      'target': 'CartPage',
    });

    expect(error.message, contains('No state on screen is called "CartPage"'));
    expect(error.message, contains('ConversationDetailPage'));
    expect(error.message, contains('MessageListWidget'));
  });

  nyWidgetTest('a page that is not a NyPage or NyState says so', (
    tester,
  ) async {
    await pumpApp(tester);
    await run(tester, 'route.push', {'path': '/plain'});

    final LiveException error = await runError(tester, 'state.data');

    expect(error.message, contains('/plain'));
    expect(error.message, contains('isn\'t a NyPage or NyState'));
    expect(nyLiveInspectedState, isNull);
  });

  nyWidgetTest('state.data is allowed in profile builds', (tester) async {
    await openDetail(tester);
    NyLive.debugBuildOverride = false;
    addTearDown(() => NyLive.debugBuildOverride = null);

    final Map<String, Object?> payload = Map<String, Object?>.from(
      await run(tester, 'state.data') as Map,
    );

    expect((payload['state'] as Map)['widget'], 'ConversationDetailPage');
  });

  group('nyLiveInspectJson', () {
    List<Map<String, Object?>> decode(List<Object?> values) =>
        (jsonDecode(nyLiveInspectJson(values)) as List)
            .map((e) => Map<String, Object?>.from(e as Map))
            .toList();

    test('encodes a value with its type', () {
      expect(decode([true]).single, {'type': 'bool', 'value': true});
      expect(decode([null]).single, {'type': 'Null', 'value': null});
      expect(decode(['hi']).single, {'type': 'String', 'value': 'hi'});
    });

    test('encodes models through toJson', () {
      expect(decode([Conversation(7, 'Standup')]).single, {
        'type': 'Conversation',
        'value': {'id': 7, 'title': 'Standup'},
      });
    });

    test('counts collections', () {
      expect(
        decode([
          <int>[1, 2, 3],
        ]).single,
        {
          'type': 'List<int>',
          'count': 3,
          'value': [1, 2, 3],
        },
      );
      expect(
        decode([
          {'a': 1},
        ]).single,
        {
          'type': '_Map<String, int>',
          'count': 1,
          'value': {'a': 1},
        },
      );
      expect(
        decode([
          <int>{4, 5},
        ]).single,
        {
          'type': '_Set<int>',
          'count': 2,
          'value': [4, 5],
        },
      );
    });

    test('truncates a long collection and says so', () {
      final Map<String, Object?> described = decode([
        List<int>.generate(nyLiveInspectItemLimit + 10, (i) => i),
      ]).single;

      expect(described['count'], nyLiveInspectItemLimit + 10);
      expect(described['truncated'], true);
      expect((described['value'] as List).length, nyLiveInspectItemLimit);
    });

    test('falls back to toString for a value that is not JSON', () {
      final Map<String, Object?> described = decode([
        ScrollController(),
      ]).single;

      expect(described['type'], 'ScrollController');
      expect('${described['value']}', contains('ScrollController'));
    });

    test('encodes every value in one call, in order', () {
      expect(decode([1, 'two', false]).map((e) => e['value']).toList(), [
        1,
        'two',
        false,
      ]);
    });
  });
}
