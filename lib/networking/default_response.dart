/// Base class used to handle networking responses
class DefaultResponse<T> {
  DefaultResponse({
    required this.data,
  });

  late final T data;

  DefaultResponse.fromJson(json, decoders, {required Type type}) {
    data = decoders[type]!(json) as T;
  }
}
