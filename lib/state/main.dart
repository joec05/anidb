import 'package:anime_list_app/class/anime_data_notifier.dart';
import 'package:anime_list_app/class/character_data_notifier.dart';
import 'package:anime_list_app/class/manga_data_notifier.dart';
import 'package:anime_list_app/class/app_storage_class.dart';
import 'package:anime_list_app/class/user_data_notifier.dart';
import 'package:anime_list_app/class/user_token_class.dart';

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
