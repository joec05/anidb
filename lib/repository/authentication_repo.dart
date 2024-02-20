import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class AuthenticationRepository {
  UserTokenClass userTokenData = UserTokenClass('', '', '', '');
  UserDataNotifier? currentUserData;

  void getAccessToken(
    BuildContext context,
    String authCode, 
    String codeVerifier
  ) async{
    var res = await apiCallRepo.runAPICall(
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
    
    if(res != null) {
      authRepo.userTokenData = UserTokenClass.fromMapUpdate(res);
      secureStorageController.updateUserToken();
      runDelay(() => Navigator.pushAndRemoveUntil(
        context,
        NavigationTransition(
          page: const MainPageWidget()
        ),
        (Route<dynamic> route) => false
      ), navigatorDelayTime);
    }
  }

  Future<String> generateAuthHeader(BuildContext context) async{
    UserTokenClass tokenData = authRepo.userTokenData;
    DateTime expiryTimeParsed = DateTime.parse(tokenData.expiryTime);
    int differenceInHour = expiryTimeParsed.difference(DateTime.now()).inHours;
    debugPrint('$differenceInHour hours before refreshing token');
    if(differenceInHour <= 36){
      var res = await apiCallRepo.runAPICall(
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
      if(res != null) {
        authRepo.userTokenData = UserTokenClass.fromMapUpdate(res);
        secureStorageController.updateUserToken();
      }
    }
    return 'Bearer ${authRepo.userTokenData.accessToken}';
  }

}

final AuthenticationRepository authRepo = AuthenticationRepository();