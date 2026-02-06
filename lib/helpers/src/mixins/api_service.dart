import 'package:dio/dio.dart';

import '/networking/src/ny_api_service.dart';
import '/nylo.dart';

/// HasApiService mixin for classes that need access to an API service.
mixin HasApiService<T extends NyApiService> {
  T? _apiService;

  /// Set the onSuccess callback for API responses.
  void onApiSuccess(Function(Response response, dynamic data) onSuccess) {
    _apiService ??= apiService;
    _apiService!.onSuccess(onSuccess);
  }

  /// Set the onError callback for API errors.
  void onApiError(Function(dynamic error) onError) {
    _apiService ??= apiService;
    _apiService!.onError(onError);
  }

  /// Get the API service instance.
  T get apiService => _apiService ??= Nylo.apiDecoder<T>() as T;
}
