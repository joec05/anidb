import 'package:anime_list_app/class/AnimeImageClass.dart';

class RelatedAnimeClass {
  int id;
  String title;
  AnimeImageClass cover;
  String relationType;
  
  RelatedAnimeClass(
    this.id,
    this.title,
    this.cover,
    this.relationType
  );
}