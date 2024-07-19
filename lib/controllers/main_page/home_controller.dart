import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeController {
  late AutoDisposeAsyncNotifierProvider<HomeNotifier, List<HomeFrontDisplayModel>> homeNotifier;

  void initialize(){
    homeNotifier = AsyncNotifierProvider.autoDispose<HomeNotifier, List<HomeFrontDisplayModel>>(
      () => HomeNotifier()
    );
  }

  void dispose(){
  }
}

class HomeNotifier extends AutoDisposeAsyncNotifier<List<HomeFrontDisplayModel>> {
  late AnimeRepository animeRepository;
  late MangaRepository mangaRepository;
  late CharacterRepository characterRepository;
  List<HomeFrontDisplayModel> displayed = [
    HomeFrontDisplayModel(
      'Animes this season', 
      AnimeBasicDisplayType.season, 
      []
    ),
    HomeFrontDisplayModel(
      'Airing now', 
      AnimeBasicDisplayType.airing, 
      []
    ),
    HomeFrontDisplayModel(
      'Upcoming anime', 
      AnimeBasicDisplayType.upcoming, 
      []
    ),
    /*
    HomeFrontDisplayModel(
      'Top scoring anime', 
      AnimeBasicDisplayType.top, 
      []
    ),
    HomeFrontDisplayModel(
      'Popular anime', 
      AnimeBasicDisplayType.mostPopular, 
      []
    ),
    HomeFrontDisplayModel(
      'Top favourited anime', 
      AnimeBasicDisplayType.favourites, 
      []
    ),
    HomeFrontDisplayModel(
      'Top scoring mangas',
      MangaBasicDisplayType.top, 
      []
    ),
    HomeFrontDisplayModel(
      'Popular mangas',
      MangaBasicDisplayType.mostPopular, 
      [],
    ),
    HomeFrontDisplayModel(
      'Top favorited mangas',
      MangaBasicDisplayType.favourites, 
      []
    ),
    HomeFrontDisplayModel(
      'Top characters',
      CharacterBasicDisplayType.top, 
      []
    ),
    */
  ];

  @override
  FutureOr<List<HomeFrontDisplayModel>> build() async {
    state = const AsyncLoading();
    animeRepository = AnimeRepository();
    mangaRepository = MangaRepository();
    characterRepository = CharacterRepository();
    APIResponseModel response = await animeRepository.fetchSeasonAnime();
    if(response.error != null) {
      state = AsyncError(response.error!.object, response.error!.stackTrace);
      throw Exception(response.error!.object);
    } else {
      displayed[0].dataList = response.data;
      APIResponseModel response2 = await animeRepository.fetchTopAiringAnime();
      if(response2.error != null) {
        state = AsyncError(response2.error!.object, response2.error!.stackTrace);
        throw Exception(response.error!.object);
      } else {
        displayed[1].dataList = response2.data;
        APIResponseModel response3 = await animeRepository.fetchTopUpcomingAnime();
        if(response3.error != null) {
          state = AsyncError(response3.error!.object, response3.error!.stackTrace);
          throw Exception(response.error!.object);
        } else {
          displayed[2].dataList = response3.data;
          state = AsyncData(displayed);
          /*
          APIResponseModel response4 = await animeRepository.fetchTopAnime();
          if(response4.error != null) {
            state = AsyncError(response4.error!.object, response4.error!.stackTrace);
            throw Exception(response.error!.object);
          } else {
            displayed[3].dataList = response4.data;
            APIResponseModel response5 = await animeRepository.fetchMostPopularAnime();
            if(response5.error != null) {
              state = AsyncError(response5.error!.object, response5.error!.stackTrace);
              throw Exception(response.error!.object);
            } else {
              displayed[4].dataList = response5.data;
              APIResponseModel response6 = await animeRepository.fetchTopFavouritedAnime();
              if(response6.error != null) {
                state = AsyncError(response6.error!.object, response6.error!.stackTrace);
                throw Exception(response.error!.object);
              } else {
                displayed[5].dataList = response6.data;
                APIResponseModel response7 = await mangaRepository.fetchTopManga();
                if(response7.error != null) {
                  state = AsyncError(response7.error!.object, response7.error!.stackTrace);
                  throw Exception(response.error!.object);
                } else {
                  displayed[6].dataList = response7.data;
                  APIResponseModel response8 = await mangaRepository.fetchMostPopularManga();
                  if(response8.error != null) {
                    state = AsyncError(response8.error!.object, response8.error!.stackTrace);
                    throw Exception(response.error!.object);
                  } else {
                    displayed[7].dataList = response8.data;
                    APIResponseModel response9 = await mangaRepository.fetchTopFavouritedManga();
                    if(response9.error != null) {
                      state = AsyncError(response9.error!.object, response9.error!.stackTrace);
                      throw Exception(response.error!.object);
                    } else {
                      displayed[8].dataList = response9.data;
                      APIResponseModel response10 = await characterRepository.fetchTopCharacters();
                      if(response10.error != null) {
                        state = AsyncError(response10.error!.object, response10.error!.stackTrace);
                        throw Exception(response.error!.object);
                      } else {
                        displayed[9].dataList = response10.data;
                        
                      }
                    }
                  }
                }
              }
            }
          }
          */
        }
      }
    }
    return displayed;
  }

  Future<void> refresh() async => await build();
}