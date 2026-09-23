/// A live command failed in a way Metro should show to the developer.
///
/// [code] follows JSON-RPC: [invalidParamsCode] when the call's arguments are
/// wrong, [failedCode] when the command couldn't do its job.
class LiveException implements Exception {
  /// JSON-RPC error code for missing or malformed arguments.
  static const int invalidParamsCode = -32602;

  /// JSON-RPC error code for a command that couldn't complete.
  static const int failedCode = -32000;

  /// What went wrong, written for the developer at the terminal.
  final String message;

  /// The JSON-RPC error code sent back to Metro.
  final int code;

  /// Creates an exception for a command that couldn't complete.
  const LiveException(this.message) : code = failedCode;

  /// Creates an exception for missing or malformed arguments.
  const LiveException.invalidParams(this.message) : code = invalidParamsCode;

  @override
  String toString() => 'LiveException($code): $message';
}
