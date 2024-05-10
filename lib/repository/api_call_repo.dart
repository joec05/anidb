import 'package:anime_list_app/global_files.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class APICallRepository {

  var dio = Dio();
  
  Future<dynamic> runAPICall(
    BuildContext context,
    APICallType type,
    String baseUrl,
    String url,
    Map data,
  ) async{
    try {
      late Response res;
      if(type == APICallType.get) {
        res = await dio.get(
          url,
          options: Options(
            headers: baseUrl == jikanApiUrl ? {} : {
              'Authorization': await authRepo.generateAuthHeader(context)
            },
          ),
          data: data.isEmpty ? null : data
        );
      }else if(type == APICallType.patch) {
        res = await dio.patch(
          url,
          options: Options(
            headers: baseUrl == jikanApiUrl ? {} : {
              "Content-Type": "application/x-www-form-urlencoded",
              'Authorization': await authRepo.generateAuthHeader(context)
            },
          ),
          data: data.isEmpty ? null : data
        );
      }else if(type == APICallType.post){
        res = await dio.post(
          url,
          options: Options(
            headers: baseUrl == jikanApiUrl ? {} : {
              "Content-Type": "application/x-www-form-urlencoded",
            },
          ),
          data: {
            'client_id': data['client_id'],
            'code': data['code'],
            'code_verifier': data['code_verifier'],
            'grant_type': data['grant_type'],
            'refresh_token': data['refresh_token'],
          }
        );
      }else if(type == APICallType.delete){
        res = await dio.delete(
          url,
          options: Options(
            headers: baseUrl == jikanApiUrl ? {} : {
              "Content-Type": "application/x-www-form-urlencoded",
              'Authorization': await authRepo.generateAuthHeader(context)
            },
          ),
          data: data.isEmpty ? null : data
        );
      }
      
      return APIResponseModel(
        res.data,
        null
      );
    } on Exception catch (obj, stackTrace) {
      return APIResponseModel(
        null, 
        APIErrorModel(obj, stackTrace)
      );
    }
  }
}

final APICallRepository apiCallRepo = APICallRepository();