import 'package:anime_list_app/class/AnimeImageClass.dart';

class RecommendedAnimeClass {
  int id;
  String title;
  AnimeImageClass cover;
  int recommendationsCount;
  
  RecommendedAnimeClass(
    this.id,
    this.title,
    this.cover,
    this.recommendationsCount
  );
}