import 'package:anidb/global_files.dart';

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