import 'package:anime_list_app/global_files.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppStateRepo {
  Map<int, NotifierProvider<AnimeStatusNotifier, AnimeMyListStatusClass>?> globalAnimeData = {};
  Map<int, NotifierProvider<MangaStatusNotifier, MangaMyListStatusClass>?> globalMangaData = {};
}

final appStateRepo = AppStateRepo();
