import 'package:anime_list_app/class/anime_image_class.dart';

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