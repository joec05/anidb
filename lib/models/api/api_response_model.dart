import 'package:anidb_app/models/api/api_error_model.dart';

class APIResponseModel {
  final dynamic data;
  final dynamic data2;
  final APIErrorModel? error;

  APIResponseModel(
    this.data,
    this.error,
    {this.data2}
  );
}