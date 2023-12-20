import 'package:anime_list_app/class/manga_image_class.dart';

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