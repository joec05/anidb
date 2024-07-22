import 'dart:async';
import 'package:anidb_app/global_files.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimeRankingController {
  AutoDisposeAsyncNotifierProvider<AnimeRankingNotifier, HomeFrontDisplayModel> animeScoreNotifier = AsyncNotifierProvider.autoDispose<AnimeRankingNotifier, HomeFrontDisplayModel>(
    () => AnimeRankingNotifier(AnimeBasicDisplayType.top)
  );
  AutoDisposeAsyncNotifierProvider<AnimeRankingNotifier, HomeFrontDisplayModel> animePopularityNotifier = AsyncNotifierProvider.autoDispose<AnimeRankingNotifier, HomeFrontDisplayModel>(
    () => AnimeRankingNotifier(AnimeBasicDisplayType.mostPopular)
  );
  AutoDisposeAsyncNotifierProvider<AnimeRankingNotifier, HomeFrontDisplayModel> animeFavouritesNotifier = AsyncNotifierProvider.autoDispose<AnimeRankingNotifier, HomeFrontDisplayModel>(
    () => AnimeRankingNotifier(AnimeBasicDisplayType.favourites)
  );
  late List<AutoDisposeAsyncNotifierProvider<AnimeRankingNotifier, HomeFrontDisplayModel>> notifiers;

  void initialize() async {
    notifiers = [animeScoreNotifier, animePopularityNotifier, animeFavouritesNotifier];
  }

  void dispose(){
  }
}

class AnimeRankingNotifier extends AutoDisposeAsyncNotifier<HomeFrontDisplayModel>{
  final AnimeBasicDisplayType type;
  late HomeFrontDisplayModel displayModel;

  AnimeRankingNotifier(this.type);

  @override
  FutureOr<HomeFrontDisplayModel> build() async {
    state = const AsyncLoading();
    if(type == AnimeBasicDisplayType.top) {
      displayModel = HomeFrontDisplayModel(
        'Score', 
        AnimeBasicDisplayType.top, 
        []
      );
    } else if(type == AnimeBasicDisplayType.mostPopular) {
      displayModel = HomeFrontDisplayModel(
        'Popularity', 
        AnimeBasicDisplayType.mostPopular, 
        []
      );
    } else if(type == AnimeBasicDisplayType.favourites) {
      displayModel = HomeFrontDisplayModel(
        'Favourites', 
        AnimeBasicDisplayType.favourites, 
        []
      );
    }

    late APIResponseModel response;

    if(type == AnimeBasicDisplayType.top) {
      response = await animeRepository.fetchTopAnime();
    } else if(type == AnimeBasicDisplayType.mostPopular) {
      response = await animeRepository.fetchMostPopularAnime();
    } else if(type == AnimeBasicDisplayType.favourites) {
      response = await animeRepository.fetchTopFavouritedAnime();
    }

    if(response.error != null) {
      state = AsyncError(response.error!.object, response.error!.stackTrace);
      throw Exception(response.error!.object);
    } else {
      displayModel.dataList = response.data;
      state = AsyncData(displayModel);
    }
    
    return displayModel;
  }

  Future<void> refresh() async => await build();
}