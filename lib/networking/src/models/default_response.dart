import '/networking/src/models/ny_decoder.dart';
import '/networking/src/models/ny_response.dart';

/// Base class used to handle networking responses
class DefaultResponse<T> {
  DefaultResponse({required this.data});

  late final T? data;

  /// Decodes [json] with the decoder for [type] in [decoders].
  ///
  /// [response] is passed to decoders that read it, such as [OneOf].
  DefaultResponse.fromJson(
    dynamic json,
    Map<Type, dynamic> decoders, {
    required Type type,
    NyResponse? response,
  }) {
    dynamic jsonResponse = decodeWithDecoders(
      json,
      decoders,
      type: type,
      response: response,
    );
    if (jsonResponse == null) {
      data = null;
      return;
    }
    data = jsonResponse as T;
  }
}
