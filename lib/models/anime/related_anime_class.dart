import 'package:anidb/global_files.dart';

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