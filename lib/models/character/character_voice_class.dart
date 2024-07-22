import 'package:anidb_app/global_files.dart';

class CharacterVoiceClass{
  String language;
  int personID;
  PersonImageClass personCover;
  String personTitle;

  CharacterVoiceClass(
    this.language,
    this.personID,
    this.personCover,
    this.personTitle
  );
}