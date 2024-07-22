import 'package:anidb_app/global_files.dart';

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