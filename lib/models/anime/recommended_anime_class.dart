import 'package:anidb/global_files.dart';

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