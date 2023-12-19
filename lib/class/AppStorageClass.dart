import 'dart:convert';
import 'package:anime_list_app/appdata/GlobalVariables.dart';
import 'package:anime_list_app/class/UserTokenClass.dart';
import 'package:anime_list_app/state/main.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppStorageClass{
  final storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    )
  );

  void updateUserToken() async{
    storage.write(key: userTokenClassDataKey, value: jsonEncode(appStateClass.userTokenData.convertToMap()));
  }

  void resetUserToken() async{
    storage.write(key: userTokenClassDataKey, value: '');
  }

  Future<Map> fetchUserToken() async{
    String? currentTokenData = await storage.read(key: userTokenClassDataKey); 
    if(currentTokenData == null || currentTokenData == ''){
      return UserTokenClass('', '', '', '').convertToMap();
    }else{
      return jsonDecode(currentTokenData); 
    }
  }
}
