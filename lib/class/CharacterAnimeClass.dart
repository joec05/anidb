import 'package:anime_list_app/class/AnimeImageClass.dart';

class CharacterAnimeClass{
  String role;
  int animeID;
  AnimeImageClass animeCover;
  String animeTitle;

  CharacterAnimeClass(
    this.role,
    this.animeID,
    this.animeCover,
    this.animeTitle
  );
}