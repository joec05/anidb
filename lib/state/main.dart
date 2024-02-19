import 'package:anime_list_app/global_files.dart';

class AppStateClass{
  UserTokenClass userTokenData;
  UserDataNotifier? currentUserData;
  AppStorageClass appStorage;
  Map<int, AnimeDataNotifier> globalAnimeData;
  Map<int, MangaDataNotifier> globalMangaData;
  Map<int, CharacterDataNotifier> globalCharacterData;

  AppStateClass({
    required this.userTokenData,
    required this.currentUserData,
    required this.appStorage,
    required this.globalAnimeData,
    required this.globalMangaData,
    required this.globalCharacterData
  });
}

final appStateClass = AppStateClass(
  userTokenData: UserTokenClass('', '', '', ''),
  currentUserData: null,
  appStorage: AppStorageClass(),
  globalAnimeData: {},
  globalMangaData: {},
  globalCharacterData: {}
);
