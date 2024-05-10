import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthenticationRepository {
  UserTokenClass userTokenData = UserTokenClass('', '', '', '');

  void getAccessToken(
    BuildContext context,
    String authCode, 
    String codeVerifier
  ) async{
    APIResponseModel res = await apiCallRepo.runAPICall(
      context,
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
      if(context.mounted) {
        while(context.canPop()) {
          context.pop();
        }
        context.push('/main-page');
      }
    } else {
      if(context.mounted) {
        handler.displaySnackbar(context, SnackbarType.error, tErr.response);
      }
    }
  }

  Future<String> generateAuthHeader(BuildContext context) async{
    UserTokenClass tokenData = authRepo.userTokenData;
    DateTime expiryTimeParsed = DateTime.parse(tokenData.expiryTime);
    int differenceInHour = expiryTimeParsed.difference(DateTime.now()).inHours;
    debugPrint('$differenceInHour hours before refreshing token');
    if(differenceInHour <= 36) {
      APIResponseModel res = await apiCallRepo.runAPICall(
        context,
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
        if(context.mounted) {
          handler.displaySnackbar(context, SnackbarType.error, tErr.response);
        }
      }
    }
    return 'Bearer ${authRepo.userTokenData.accessToken}';
  }

}

final AuthenticationRepository authRepo = AuthenticationRepository();