import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimeRankingController {
  late AutoDisposeAsyncNotifierProvider<AnimeRankingNotifier, List<HomeFrontDisplayModel>> animeDataNotifier;

  void initialize() async {
    animeDataNotifier = AsyncNotifierProvider.autoDispose<AnimeRankingNotifier, List<HomeFrontDisplayModel>>(
      () => AnimeRankingNotifier()
    );
  }

  void dispose(){
  }
}

class AnimeRankingNotifier extends AutoDisposeAsyncNotifier<List<HomeFrontDisplayModel>>{
  late AnimeRepository animeRepository;
  List<HomeFrontDisplayModel> displayed = [
    HomeFrontDisplayModel(
      'Score', 
      AnimeBasicDisplayType.top, 
      []
    ),
    HomeFrontDisplayModel(
      'Popularity', 
      AnimeBasicDisplayType.mostPopular, 
      []
    ),
    HomeFrontDisplayModel(
      'Favourites', 
      AnimeBasicDisplayType.favourites, 
      []
    ),
  ];

  @override
  FutureOr<List<HomeFrontDisplayModel>> build() async {
    state = const AsyncLoading();
    animeRepository = AnimeRepository();
    APIResponseModel response1 = await animeRepository.fetchTopAnime();
    if(response1.error != null) {
      state = AsyncError(response1.error!.object, response1.error!.stackTrace);
      throw Exception(response1.error!.object);
    } else {
      displayed[0].dataList = response1.data;
      APIResponseModel response2 = await animeRepository.fetchMostPopularAnime();
      if(response2.error != null) {
        state = AsyncError(response2.error!.object, response2.error!.stackTrace);
        throw Exception(response2.error!.object);
      } else {
        displayed[1].dataList = response2.data;
        APIResponseModel response3 = await animeRepository.fetchTopFavouritedAnime();
        if(response3.error != null) {
          state = AsyncError(response3.error!.object, response3.error!.stackTrace);
          throw Exception(response3.error!.object);
        } else {
          displayed[2].dataList = response3.data;
          state = AsyncData(displayed);
        }
      }
    }
    return displayed;
  }

  Future<void> refresh() async => await build();
}