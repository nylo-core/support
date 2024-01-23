import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nylo_support/alerts/toast_enums.dart';
import 'package:nylo_support/alerts/toast_notification.dart';
import 'package:nylo_support/helpers/helper.dart';
import 'package:nylo_support/networking/dio_api_service.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class NyApiService extends DioApiService {
  NyApiService(BuildContext? context,
      {this.decoders = const {},
      BaseOptions Function(BaseOptions baseOptions)? baseOptions})
      : super(context, baseOptions: baseOptions);

  /// Map decoders to modelDecoders
  @override
  final Map<Type, dynamic> decoders;

  /// Default interceptors
  @override
  final interceptors = {
    if (getEnv('APP_DEBUG', defaultValue: false) == true)
      PrettyDioLogger: PrettyDioLogger()
  };

  /// Make a GET request
  Future<T?> get<T>(
    String url, {
    Object? data,
    Map<String, String>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    Uri uri = Uri.parse(url);
    if (queryParameters != null) {
      uri = uri.replace(queryParameters: queryParameters);
    }
    if (T.toString() == 'dynamic') {
      return await network(
        request: (request) => request.getUri(uri,
            data: data,
            options: options,
            cancelToken: cancelToken,
            onReceiveProgress: onReceiveProgress),
      );
    }
    return await network<T>(
      request: (request) => request.getUri(uri,
          data: data,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress),
    );
  }

  /// Make a POST request
  Future<T?> post<T>(
    String url, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (T.toString() == 'dynamic') {
      return await network(
        request: (request) => request.postUri(Uri.parse(url),
            data: data,
            options: options,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress),
      );
    }
    return await network<T>(
      request: (request) => request.postUri(Uri.parse(url),
          data: data,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress),
    );
  }

  /// Make a PUT request
  Future<T?> put<T>(
    String url, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (T.toString() == 'dynamic') {
      return await network(
        request: (request) => request.postUri(Uri.parse(url),
            data: data,
            options: options,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress),
      );
    }
    return await network<T>(
      request: (request) => request.putUri(Uri.parse(url),
          data: data,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress),
    );
  }

  /// Make a DELETE request
  Future<T?> delete<T>(String url, Object? data, Options? options,
      CancelToken? cancelToken) async {
    if (T.toString() == 'dynamic') {
      return await network(
        request: (request) => request.deleteUri(Uri.parse(url),
            data: data, options: options, cancelToken: cancelToken),
      );
    }
    return await network<T>(
      request: (request) => request.deleteUri(Uri.parse(url),
          data: data, options: options, cancelToken: cancelToken),
    );
  }

  @override
  displayError(DioException dioException, BuildContext context) {
    NyLogger.error(dioException.message ?? "");
    showToastNotification(context,
        title: "Oops!",
        description: "Something went wrong",
        style: ToastNotificationStyleType.DANGER);
  }
}
