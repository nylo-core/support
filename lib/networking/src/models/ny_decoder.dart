import '/networking/src/models/ny_response.dart';

/// A decoder that can see the whole response, not only its body.
///
/// Register one in your `modelDecoders` map in place of a closure when a
/// model needs the status code or headers to decode, e.g. [OneOf].
///
/// Closure decoders (`User: (data) => User.fromJson(data)`) keep working
/// as before.
abstract class NyDecoder<T> {
  const NyDecoder();

  /// Whether this decoder also runs on 4xx/5xx response bodies.
  ///
  /// Closure decoders never see error bodies, so a `User.fromJson` is not
  /// handed a validation error. Return true to receive them.
  bool get decodesErrors => false;

  /// Decodes [json] into a [T].
  ///
  /// [response] is the response being decoded and [decoders] is the map
  /// this decoder was found in, so it can hand off to other decoders.
  T? decode(dynamic json, NyResponse response, Map<Type, dynamic> decoders);

  /// The type this decoder builds, used as its key by [decoders].
  Type get type => T;

  /// The `List<T>` type this decoder also handles.
  Type get listType => _typeOf<List<T>>();

  /// Decodes a `List<T>`, item by item. Items that decode to null are left
  /// out.
  NyDecoder<List<T>> get listDecoder => _ListDecoder<T>(this);
}

/// Decodes a model with its `fromJson` constructor.
///
/// The model type comes from [build], so `Decode(User.fromJson)` decodes a
/// `User`, and a `List<User>` too, with no list entry of its own. [build]
/// can take `dynamic` or `Map<String, dynamic>`, which json_serializable
/// and freezed generate. A closure needs a typed parameter:
/// `Decode((dynamic json) => User.fromJson(json))`.
///
/// [from] reads the model from inside the body, for APIs that wrap it, e.g.
/// `{"data": {...}}`. A dotted key such as `'data.user'` reads deeper. For
/// a list, the list itself is read from [from].
///
/// ```dart
/// final Map<Type, dynamic> modelDecoders = decoders([
///   Decode(User.fromJson),
///   Decode(Order.fromJson, from: 'data'),
/// ]);
/// ```
class Decode<T> extends NyDecoder<T> {
  Decode(T Function(Never json) build, {this.from}) : _build = build;

  Decode._item(this._build) : from = null;

  final Function _build;

  /// The key the model is read from, or null to use the whole body.
  final String? from;

  @override
  T? decode(dynamic json, NyResponse response, Map<Type, dynamic> decoders) =>
      Function.apply(_build, [from == null ? json : _readKey(json, from!)])
          as T;

  @override
  NyDecoder<List<T>> get listDecoder =>
      _ListDecoder<T>(Decode<T>._item(_build), from: from);
}

/// Builds `modelDecoders` from a list of typed decoders, each keyed by the
/// type it builds. Returns the same map Nylo has always used.
///
/// ```dart
/// final Map<Type, dynamic> modelDecoders = decoders([
///   Decode(User.fromJson),
///   OneOf<LoginResult>.byKey('status', {...}),
/// ]);
/// ```
///
/// [entries] is typed `List<Object>` on purpose: as a `List<NyDecoder>`,
/// Dart would infer each `Decode` from the list's type instead of from its
/// constructor, and every entry would become `Decode<dynamic>`.
Map<Type, dynamic> decoders(List<Object> entries) {
  final Map<Type, dynamic> map = {};
  for (final Object entry in entries) {
    if (entry is! NyDecoder) {
      throw ArgumentError(
        'decoders() takes Decode(...) or OneOf(...) entries, but got ${entry.runtimeType}.',
      );
    }
    assert(
      entry.type != dynamic,
      'A decoder in decoders() builds dynamic. Give closures a typed parameter: Decode((dynamic json) => User.fromJson(json)).',
    );
    map[entry.type] = entry;
  }
  return map;
}

/// Runs [json] through the decoder registered for [type] in [decoders].
///
/// Also finds the `List<T>` decoder that every [NyDecoder] provides, and
/// the built-in decoders for plain JSON types.
/// Throws a [StateError] when no decoder exists for [type].
dynamic decodeWithDecoders(
  dynamic json,
  Map<Type, dynamic> decoders, {
  required Type type,
  NyResponse? response,
}) {
  dynamic decoder = findDecoder(type, decoders);
  if (decoder == null) {
    throw StateError(
      'Your bootstrap/decoders.dart file does not contain a decoder for the following class: ${type.toString()} in modelDecoders',
    );
  }
  if (decoder is NyDecoder) {
    return decoder.decode(
      json,
      response ?? NyResponse(response: null, data: null, rawData: json),
      decoders,
    );
  }
  return decoder(json);
}

/// Returns the decoder for [type] in [decoders], or null if there is none.
///
/// An entry for [type] wins. Otherwise a [NyDecoder] registered for `T`,
/// such as [Decode] or [OneOf], also decodes `List<T>`. Last come the
/// built-in decoders for plain JSON types such as `Map<String, dynamic>`.
dynamic findDecoder(Type type, Map<Type, dynamic> decoders) {
  if (decoders.containsKey(type)) return decoders[type];
  for (final Object? decoder in decoders.values) {
    if (decoder is NyDecoder && decoder.listType == type) {
      return decoder.listDecoder;
    }
  }
  return _jsonDecoders[type];
}

/// Decoders for plain JSON types, used when the app doesn't register its
/// own.
final Map<Type, dynamic> _jsonDecoders = {
  Map<String, dynamic>: (data) => Map<String, dynamic>.from(data as Map),
  List<dynamic>: (data) => List<dynamic>.from(data as List),
  List<Map<String, dynamic>>: (data) => [
    for (final dynamic item in data as List)
      Map<String, dynamic>.from(item as Map),
  ],
  String: (data) => data as String,
  int: (data) => (data as num).toInt(),
  double: (data) => (data as num).toDouble(),
  num: (data) => data as num,
  bool: (data) => data as bool,
};

/// Builds one shape of a [OneOf] from the response body.
///
/// A constructor tear-off such as `LoginSuccess.fromJson` works when it
/// takes `dynamic`; one that takes `Map<String, dynamic>` needs a closure:
/// `(json) => LoginSuccess.fromJson(json)`.
typedef OneOfBuilder<T> = T Function(dynamic json);

/// Decodes a response that can have more than one shape.
///
/// Register it in `bootstrap/decoders.dart` under the shared parent type.
/// Pick the shape by a field in the body, by status code, by your own
/// conditions, or with a function:
/// ```dart
/// LoginResult: OneOf<LoginResult>.byKey('status', {
///   'success': LoginSuccess.fromJson,
///   'two_factor': TwoFactorRequired.fromJson,
/// }, otherwise: (json) => LoginFailed(ApiError.fromJson(json))),
/// ```
///
/// A `OneOf` also decodes 4xx/5xx bodies, and `List<T>` item by item.
/// A shape it doesn't recognise leaves the response data null.
class OneOf<T> extends NyDecoder<T> {
  /// Decodes with [resolve], which gets the body and the whole response and
  /// returns the value, or null for a shape it doesn't recognise.
  ///
  /// ```dart
  /// OrderResult: OneOf<OrderResult>((json, response) => switch ((response.statusCode, json)) {
  ///   (200, {'status': 'placed'}) => OrderPlaced.fromJson(json),
  ///   (200, _) => OrderPending.fromJson(json),
  ///   _ => null,
  /// }),
  /// ```
  OneOf(this.resolve);

  /// Picks the shape by the value of [key] in the body.
  ///
  /// [key] can be a dotted path such as `'data.type'` to read a nested
  /// field. A field named exactly [key] wins over the path. The builder
  /// always gets the whole body. [otherwise] builds anything else.
  ///
  /// ```dart
  /// FeedItem: OneOf<FeedItem>.byKey('type', {
  ///   'post': PostItem.fromJson,
  ///   'ad': AdItem.fromJson,
  /// }),
  /// ```
  factory OneOf.byKey(
    String key,
    Map<Object?, OneOfBuilder<T>> types, {
    OneOfBuilder<T>? otherwise,
  }) => OneOf(
    (json, response) => (types[_readKey(json, key)] ?? otherwise)?.call(json),
  );

  /// Picks the shape by the response's status code.
  ///
  /// A key is a status code such as `404`, or a pattern such as `'4xx'` or
  /// `'40x'` where `x` matches any digit. An exact code wins, then the
  /// pattern with the fewest `x`s. [otherwise] builds anything else.
  ///
  /// ```dart
  /// OrderResult: OneOf<OrderResult>.byStatus({
  ///   200: OrderPlaced.fromJson,
  ///   404: OrderNotFound.fromJson,
  ///   '4xx': (json) => OrderRejected(ApiError.fromJson(json)),
  /// }),
  /// ```
  factory OneOf.byStatus(
    Map<Object, OneOfBuilder<T>> types, {
    OneOfBuilder<T>? otherwise,
  }) {
    assert(
      types.keys.every(_isStatusKey),
      'OneOf.byStatus keys must be status codes like 404 or patterns like "4xx"',
    );
    return OneOf(
      (json, response) =>
          (_forStatus(types, response.statusCode) ?? otherwise)?.call(json),
    );
  }

  /// Picks the shape with your own conditions. Each condition gets the body
  /// and the whole response, and the first that returns true wins, in the
  /// order written. [otherwise] builds anything else.
  ///
  /// ```dart
  /// SignUpResult: OneOf<SignUpResult>.byJson({
  ///   (json, response) => response.statusCode == 200 && json['status'] == 'ok': SignUpComplete.fromJson,
  ///   (json, response) => response.statusCode == 200 && json['status'] == 'verify': VerifyEmail.fromJson,
  /// }),
  /// ```
  factory OneOf.byJson(
    Map<bool Function(dynamic json, NyResponse response), OneOfBuilder<T>>
    types, {
    OneOfBuilder<T>? otherwise,
  }) => OneOf((json, response) {
    for (final MapEntry(key: matches, value: build) in types.entries) {
      if (matches(json, response)) return build(json);
    }
    return otherwise?.call(json);
  });

  /// Returns the value for the body and the response, or null.
  final T? Function(dynamic json, NyResponse response) resolve;

  /// Error bodies are decoded too, so a 409 or 422 can be one of the shapes.
  @override
  bool get decodesErrors => true;

  @override
  T? decode(dynamic json, NyResponse response, Map<Type, dynamic> decoders) =>
      resolve(json, response);
}

/// Reads [key] from [json]. A field named exactly [key] wins; otherwise a
/// dotted key such as `'data.type'` walks nested maps.
Object? _readKey(dynamic json, String key) {
  if (json is! Map) return null;
  if (json.containsKey(key)) return json[key];
  dynamic value = json;
  for (final String part in key.split('.')) {
    if (value is! Map) return null;
    value = value[part];
  }
  return value;
}

/// Whether [key] is a status code or a pattern such as `'4xx'`.
bool _isStatusKey(Object key) =>
    key is int || (key is String && RegExp(r'^[1-5][0-9x]{2}$').hasMatch(key));

/// Finds the entry for [status]: an exact code first, then the pattern with
/// the fewest wildcards, so `'40x'` beats `'4xx'`.
B? _forStatus<B>(Map<Object, B> types, int? status) {
  if (status == null) return null;
  if (types[status] case final B build) return build;

  String code = '$status';
  if (code.length != 3) return null;
  B? best;
  int fewestWildcards = 4;
  for (final MapEntry(:key, :value) in types.entries) {
    if (key is! String || key.length != 3) continue;
    bool matches = true;
    for (int i = 0; i < 3; i++) {
      if (key[i] != 'x' && key[i] != code[i]) matches = false;
    }
    int wildcards = 'x'.allMatches(key).length;
    if (matches && wildcards < fewestWildcards) {
      best = value;
      fewestWildcards = wildcards;
    }
  }
  return best;
}

/// Decodes a list by running each item through [item].
///
/// Items that decode to null are left out, so one shape a [OneOf] doesn't
/// recognise doesn't break the whole list. With [from], the list is read
/// from inside the body first.
class _ListDecoder<T> extends NyDecoder<List<T>> {
  const _ListDecoder(this.item, {this.from});

  final NyDecoder<T> item;
  final String? from;

  @override
  bool get decodesErrors => item.decodesErrors;

  @override
  List<T>? decode(
    dynamic json,
    NyResponse response,
    Map<Type, dynamic> decoders,
  ) {
    dynamic list = from == null ? json : _readKey(json, from!);
    if (list is! List) return null;
    return list
        .map((element) => item.decode(element, response, decoders))
        .whereType<T>()
        .toList();
  }
}

Type _typeOf<X>() => X;
