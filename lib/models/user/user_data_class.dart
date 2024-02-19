class UserDataClass{
  int id;
  String username;
  String? profilePic;
  String? gender;
  String? birthday;
  String? location;
  String joinedTime;

  UserDataClass(
    this.id,
    this.username,
    this.profilePic,
    this.gender,
    this.birthday,
    this.location,
    this.joinedTime
  );

  factory UserDataClass.fromMap(Map map){
    return UserDataClass(
      map['id'], 
      map['name'], 
      map['picture'],
      map['gender'], 
      map['birthday'], 
      map['location'], 
      map['joined_at']
    );
  }

  factory UserDataClass.fetchNewInstance(int id){
    return UserDataClass(
      id, '', '', '', '', '', ''
    );
  }
}