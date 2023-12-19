class UserTokenClass {
  String tokenType;
  String accessToken;
  String refreshToken;
  String expiryTime;
  
  UserTokenClass(
    this.tokenType,
    this.accessToken,
    this.refreshToken,
    this.expiryTime
  );

  factory UserTokenClass.fromMapUpdate(Map map){
    return UserTokenClass(
      map['token_type'],
      map['access_token'],
      map['refresh_token'],
      DateTime.now().add(Duration(seconds: map['expires_in'])).toIso8601String()
    );
  }

  factory UserTokenClass.fromMapRetrieve(Map map){
    return UserTokenClass(
      map['token_type'],
      map['access_token'],
      map['refresh_token'],
      map['expiry_time']
    );
  }

  Map<String, dynamic> convertToMap(){
    return {
      'token_type': tokenType,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expiry_time': expiryTime
    };
  }
}