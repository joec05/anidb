import 'package:anime_list_app/global_files.dart';

class AppStateRepo {
  Map<int, AnimeDataNotifier> globalAnimeData = {};
  Map<int, MangaDataNotifier> globalMangaData = {};
  Map<int, CharacterDataNotifier> globalCharacterData = {};
}

final appStateRepo = AppStateRepo();
