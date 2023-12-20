
import 'package:anime_list_app/class/person_image_class.dart';

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