import 'package:anime_list_app/class/MangaImageClass.dart';

class CharacterMangaClass{
  String role;
  int mangaID;
  MangaImageClass mangaCover;
  String mangaTitle;

  CharacterMangaClass(
    this.role,
    this.mangaID,
    this.mangaCover,
    this.mangaTitle
  );
}