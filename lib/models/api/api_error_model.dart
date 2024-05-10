class APIErrorModel {
  final Object object;
  final StackTrace stackTrace;

  APIErrorModel(
    this.object,
    this.stackTrace
  );
}