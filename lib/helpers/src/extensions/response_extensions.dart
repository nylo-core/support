import 'package:dio/dio.dart';

import '../helper.dart';

/// Extensions for [Response]
extension NyResponseExt on Response {
  /// Get the path of the request.
  String get path => requestOptions.path;

  /// Get the data as a model.
  T toModel<T>() {
    return dataToModel<T>(data: data);
  }

  /// Get the cache key for the request.
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'requestOptions': {
        'path': path,
        'method': requestOptions.method,
        'baseUrl': requestOptions.baseUrl,
        'queryParameters': requestOptions.queryParameters,
      },
      'statusCode': statusCode,
      'statusMessage': statusMessage,
    };
  }
}
