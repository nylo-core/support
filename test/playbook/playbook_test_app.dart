import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nylo_support/playbook/ny_playbook.dart';

/// Records what the test app's widgets saw, so tests can check that a
/// playbook's touches and typing went through the real callbacks.
class AppLog {
  static final List<String> changes = [];
  static bool agreed = false;

  static void reset() {
    changes.clear();
    agreed = false;
  }
}

/// A small app with the parts a journey touches: a button, two text fields
/// (one with an input formatter), a checkbox, a dialog, a lazy list, an
/// icon button with a tooltip, and a FAB.
class PlaybookTestApp extends StatelessWidget {
  const PlaybookTestApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (_) => const WelcomePage(),
      '/sign-up': (_) => const SignUpPage(),
      '/dashboard': (_) => const DashboardPage(),
      '/covered': (_) => const CoveredPage(),
    },
  );
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nylo')),
    body: Center(
      child: FilledButton(
        onPressed: () => Navigator.of(context).pushNamed('/sign-up'),
        child: const Text('Get started'),
      ),
    ),
  );
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _agreed = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _email,
          decoration: const InputDecoration(hintText: 'Email'),
          inputFormatters: [_LowerCase()],
          onChanged: (String value) => AppLog.changes.add(value),
        ),
        TextField(
          controller: _password,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        CheckboxListTile(
          value: _agreed,
          title: const Text('I agree to the terms'),
          onChanged: (bool? value) {
            setState(() => _agreed = value ?? false);
            AppLog.agreed = _agreed;
          },
        ),
        FilledButton(
          onPressed: _agreed
              ? () => Navigator.of(
                  context,
                ).pushReplacementNamed('/dashboard', arguments: _email.text)
              : null,
          child: const Text('Create account'),
        ),
      ],
    ),
  );
}

class _LowerCase extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toLowerCase());
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? _message;

  @override
  Widget build(BuildContext context) {
    final Object? email = ModalRoute.of(context)?.settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${email ?? 'guest'}'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (BuildContext dialog) => AlertDialog(
                title: const Text('Log out?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialog).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(
                      dialog,
                    ).pushNamedAndRemoveUntil('/', (_) => false),
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _message = 'Added'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (_message != null) Text(_message!),
          Expanded(
            child: ListView.builder(
              itemCount: 60,
              itemBuilder: (BuildContext context, int index) => ListTile(
                title: Text('Item $index'),
                onTap: () {},
                onLongPress: () =>
                    setState(() => _message = 'Long pressed $index'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A button with a modal barrier over it.
class CoveredPage extends StatelessWidget {
  const CoveredPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        Center(
          child: FilledButton(
            onPressed: () => AppLog.changes.add('covered tapped'),
            child: const Text('Hidden action'),
          ),
        ),
        const ModalBarrier(color: Color(0x33000000), dismissible: false),
      ],
    ),
  );
}

class SignUpToDashboardPlaybook extends Playbook {
  @override
  String get description => 'New user signs up and lands on the dashboard';

  @override
  Map<String, dynamic> get defaults => {
    'email': 'Demo@Nylo.dev',
    'password': 'secret123',
  };

  @override
  List<PlaybookStep> get steps => [
    see('Get started'),
    tap('Get started'),
    waitForPage('/sign-up'),
    type('Email', data['email']),
    type('Password', data['password'], secret: true),
    tap('I agree to the terms'),
    tap('Create account'),
    waitForPage('/dashboard'),
    see('Welcome, ${'${data['email']}'.toLowerCase()}'),
    tap(Icons.add),
    see('Added'),
    scrollTo('Item 45'),
    longPress('Item 45'),
    see('Long pressed 45'),
    tap('Log out'),
    see('Log out?'),
    tap('Cancel'),
    dontSee('Log out?'),
    step('Custom logic', (PlaybookActor actor) async {
      if (await actor.exists('Not now')) await actor.tap('Not now');
    }),
  ];
}

class LogOutPlaybook extends Playbook {
  @override
  PlaybookSpeed get speed => PlaybookSpeed.fast;

  @override
  List<PlaybookStep> get steps => [
    tap('Log out'),
    tap('Confirm'),
    waitForPage('/'),
    see('Get started'),
  ];
}

class BrokenPlaybook extends Playbook {
  @override
  List<PlaybookStep> get steps => [tap('Does not exist'), tap('Get started')];
}

class JourneyPlaybook extends Playbook {
  @override
  Map<String, dynamic> get defaults => {'email': 'chain@nylo.dev'};

  @override
  List<PlaybookStep> get steps => [
    play(SignUpToDashboardPlaybook()),
    play(LogOutPlaybook()),
    see('Get started'),
  ];
}
