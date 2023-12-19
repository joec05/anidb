import 'package:anime_list_app/class/MangaImageClass.dart';

class RecommendedMangaClass {
  int id;
  String title;
  MangaImageClass cover;
  int recommendationsCount;
  
  RecommendedMangaClass(
    this.id,
    this.title,
    this.cover,
    this.recommendationsCount
  );
}