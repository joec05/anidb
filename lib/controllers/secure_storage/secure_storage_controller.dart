import 'dart:convert';
import 'package:anidb/global_files.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageController {

  final storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    )
  );

  String userTokenClassDataKey = 'user-token-data';

  void updateUserToken() async{
    storage.write(key: userTokenClassDataKey, value: authRepo.userTokenData == null ? null : jsonEncode(authRepo.userTokenData!.convertToMap()));
  }

  void resetUserToken() async{
    storage.write(key: userTokenClassDataKey, value: '');
  }

  Future<Map?> fetchUserToken() async{
    String? currentTokenData = (await storage.readAll())[userTokenClassDataKey]; 
    if(currentTokenData == null || currentTokenData == ''){
      return null;
    }else{
      return jsonDecode(currentTokenData); 
    }
  }
}

final SecureStorageController secureStorageController = SecureStorageController();
