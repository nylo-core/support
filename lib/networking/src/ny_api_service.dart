import 'package:dio/dio.dart';
import 'package:error_stack/error_stack.dart';
import 'package:error_stack/error_stack_dio.dart';
import '/helpers/ny_helpers.dart';
import '/networking/ny_networking.dart';

class NyApiService extends DioApiService {
  NyApiService({
    this.decoders = const {},
    super.baseOptions,
    super.initDio,
    this.networkLogger,
    this.useNetworkLogger,
  });

  /// Map decoders to modelDecoders
  @override
  final Map<Type, dynamic>? decoders;

  /// Network logger instance
  NetworkLogger? networkLogger;

  /// Whether to use the network logger interceptor
  bool? useNetworkLogger;

  /// Default interceptors
  @override
  Map<Type, Interceptor> get interceptors => {
    if (useNetworkLogger ?? getEnv('APP_DEBUG', defaultValue: false) == true)
      NetworkLogger: networkLogger ?? NetworkLogger(),
    if (ErrorStack.isInitialized)
      ErrorStackDioInterceptor: ErrorStackDioInterceptor(),
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
    return await network<T>(
      request: (request) => request.getUri(
        uri,
        data: data,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      ),
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
    return await network<T>(
      request: (request) => request.postUri(
        Uri.parse(url),
        data: data,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
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
    return await network<T>(
      request: (request) => request.putUri(
        Uri.parse(url),
        data: data,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  /// Make a DELETE request
  Future<T?> delete<T>(
    String url, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await network<T>(
      request: (request) => request.deleteUri(
        Uri.parse(url),
        data: data,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// Make a PATCH request
  Future<T?> patch<T>(
    String url, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await network<T>(
      request: (request) => request.patchUri(
        Uri.parse(url),
        data: data,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  /// Make a HEAD request to check resource existence or get headers
  Future<Response> head(
    String url, {
    Object? data,
    Map<String, String>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    Uri uri = Uri.parse(url);
    if (queryParameters != null) {
      uri = uri.replace(queryParameters: queryParameters);
    }
    return await dio.headUri(
      uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Upload a file using multipart/form-data.
  ///
  /// [url] - The endpoint to upload the file to.
  /// [filePath] - The path to the file to upload.
  /// [fieldName] - The form field name for the file (default: 'file').
  /// [additionalFields] - Optional additional form fields to include.
  /// [onProgress] - Optional callback for upload progress.
  /// [fileName] - Optional custom file name to use.
  /// [contentType] - Optional content type for the file.
  ///
  /// Example:
  /// ```dart
  /// final result = await api.upload<UploadResponse>(
  ///   '/upload',
  ///   filePath: '/path/to/image.jpg',
  ///   fieldName: 'avatar',
  ///   additionalFields: {'userId': '123'},
  ///   onProgress: (sent, total) {
  ///     print('Progress: ${(sent / total * 100).toStringAsFixed(0)}%');
  ///   },
  /// );
  /// ```
  Future<T?> upload<T>(
    String url, {
    required String filePath,
    String fieldName = 'file',
    Map<String, dynamic>? additionalFields,
    ProgressCallback? onProgress,
    String? fileName,
    String? contentType,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType: contentType != null
            ? DioMediaType.parse(contentType)
            : null,
      ),
      ...?additionalFields,
    });

    return await network<T>(
      request: (request) => request.postUri(
        Uri.parse(url),
        data: formData,
        cancelToken: cancelToken,
        onSendProgress: onProgress,
      ),
    );
  }

  /// Upload multiple files using multipart/form-data.
  ///
  /// [url] - The endpoint to upload files to.
  /// [files] - Map of field names to file paths.
  /// [additionalFields] - Optional additional form fields to include.
  /// [onProgress] - Optional callback for upload progress.
  ///
  /// Example:
  /// ```dart
  /// final result = await api.uploadMultiple<UploadResponse>(
  ///   '/upload',
  ///   files: {
  ///     'avatar': '/path/to/avatar.jpg',
  ///     'document': '/path/to/doc.pdf',
  ///   },
  ///   additionalFields: {'userId': '123'},
  /// );
  /// ```
  Future<T?> uploadMultiple<T>(
    String url, {
    required Map<String, String> files,
    Map<String, dynamic>? additionalFields,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    final Map<String, dynamic> formMap = {...?additionalFields};

    for (final entry in files.entries) {
      formMap[entry.key] = await MultipartFile.fromFile(entry.value);
    }

    final formData = FormData.fromMap(formMap);

    return await network<T>(
      request: (request) => request.postUri(
        Uri.parse(url),
        data: formData,
        cancelToken: cancelToken,
        onSendProgress: onProgress,
      ),
    );
  }

  /// Download a file from the given URL to a local path.
  ///
  /// [url] - The URL to download from.
  /// [savePath] - The local path to save the file to.
  /// [onProgress] - Optional callback for download progress.
  /// [deleteOnError] - Whether to delete the file if download fails (default: true).
  ///
  /// Example:
  /// ```dart
  /// await api.download(
  ///   'https://example.com/file.pdf',
  ///   savePath: '/path/to/save/file.pdf',
  ///   onProgress: (received, total) {
  ///     if (total != -1) {
  ///       print('Progress: ${(received / total * 100).toStringAsFixed(0)}%');
  ///     }
  ///   },
  /// );
  /// ```
  Future<Response> download(
    String url, {
    required String savePath,
    ProgressCallback? onProgress,
    bool deleteOnError = true,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.download(
      url,
      savePath,
      onReceiveProgress: onProgress,
      deleteOnError: deleteOnError,
      cancelToken: cancelToken,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
