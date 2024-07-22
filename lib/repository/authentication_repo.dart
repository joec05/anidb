import 'package:anidb/global_files.dart';
import 'package:flutter/material.dart';

class AuthenticationRepository {
  UserTokenClass? userTokenData;

  Future<APIResponseModel> getAccessToken(
    String authCode, 
    String codeVerifier
  ) async{
    APIResponseModel res = await apiCallRepo.runAPICall(
      APICallType.post,
      malApiUrl,
      'https://myanimelist.net/v1/oauth2/token',
      {
        'client_id': clientID,
        'code': authCode,
        'code_verifier': codeVerifier,
        'grant_type': 'authorization_code',
      }
    );
    
    if(res.error == null) {
      authRepo.userTokenData = UserTokenClass.fromMapUpdate(res.data);
      secureStorageController.updateUserToken();
      router.push('/main-page');
    }

    return res;
  }

  Future<String> generateAuthHeader() async{
    UserTokenClass tokenData = authRepo.userTokenData!;
    DateTime expiryTimeParsed = DateTime.parse(tokenData.expiryTime);
    int differenceInHour = expiryTimeParsed.difference(DateTime.now()).inHours;
    debugPrint('$differenceInHour hours before refreshing token');
    if(differenceInHour <= 36) {
      APIResponseModel res = await apiCallRepo.runAPICall(
        APICallType.post,
        malApiUrl,
        'https://myanimelist.net/v1/oauth2/token',
        {
          'client_id': clientID,
          'grant_type': 'refresh_token',
          'refresh_token': tokenData.refreshToken,
        }
      );
      if(res.error == null) {
        authRepo.userTokenData = UserTokenClass.fromMapUpdate(res.data);
        secureStorageController.updateUserToken();
      } else {
        handler.displaySnackbar(SnackbarType.error, tErr.response);
      }
    }
    return 'Bearer ${authRepo.userTokenData?.accessToken}';
  }

}

final AuthenticationRepository authRepo = AuthenticationRepository();