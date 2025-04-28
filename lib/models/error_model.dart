class MeanderingException implements Exception {
  final String message;
  final int errorCode;

  MeanderingException({
    required this.message,
    required this.errorCode,
  });
}