import 'package:anidb/models/anime/anime_data_class.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final animeModelProvider = Provider<AnimeDataClass>((ref) {
  return AnimeDataClass.fetchNewInstance(-1);
});