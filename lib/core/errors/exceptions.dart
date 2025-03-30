class ServerException implements Exception {
  final String message;
  final int statusCode;

  ServerException({required this.message, required this.statusCode});

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}
