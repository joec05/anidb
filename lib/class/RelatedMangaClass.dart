import 'package:anime_list_app/class/MangaImageClass.dart';

class RelatedMangaClass {
  int id;
  String title;
  MangaImageClass cover;
  String relationType;
  
  RelatedMangaClass(
    this.id,
    this.title,
    this.cover,
    this.relationType
  );
}