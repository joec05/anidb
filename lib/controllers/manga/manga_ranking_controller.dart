import 'dart:async';
import 'package:anidb/global_files.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MangaRankingController {
  AutoDisposeAsyncNotifierProvider<MangaRankingNotifier, HomeFrontDisplayModel> mangaScoreNotifier = AsyncNotifierProvider.autoDispose<MangaRankingNotifier, HomeFrontDisplayModel>(
    () => MangaRankingNotifier(MangaBasicDisplayType.top)
  );
  AutoDisposeAsyncNotifierProvider<MangaRankingNotifier, HomeFrontDisplayModel> mangaPopularityNotifier = AsyncNotifierProvider.autoDispose<MangaRankingNotifier, HomeFrontDisplayModel>(
    () => MangaRankingNotifier(MangaBasicDisplayType.mostPopular)
  );
  AutoDisposeAsyncNotifierProvider<MangaRankingNotifier, HomeFrontDisplayModel> mangaFavouritesNotifier = AsyncNotifierProvider.autoDispose<MangaRankingNotifier, HomeFrontDisplayModel>(
    () => MangaRankingNotifier(MangaBasicDisplayType.favourites)
  );
  late List<AutoDisposeAsyncNotifierProvider<MangaRankingNotifier, HomeFrontDisplayModel>> notifiers;

  void initialize() async {
    notifiers = [mangaScoreNotifier, mangaPopularityNotifier, mangaFavouritesNotifier];
  }

  void dispose(){
  }
}

class MangaRankingNotifier extends AutoDisposeAsyncNotifier<HomeFrontDisplayModel>{
  final MangaBasicDisplayType type;
  late HomeFrontDisplayModel displayModel;

  MangaRankingNotifier(this.type);

  @override
  FutureOr<HomeFrontDisplayModel> build() async {
    state = const AsyncLoading();
    if(type == MangaBasicDisplayType.top) {
      displayModel = HomeFrontDisplayModel(
        'Score', 
        MangaBasicDisplayType.top, 
        []
      );
    } else if(type == MangaBasicDisplayType.mostPopular) {
      displayModel = HomeFrontDisplayModel(
        'Popularity', 
        MangaBasicDisplayType.mostPopular, 
        []
      );
    } else if(type == MangaBasicDisplayType.favourites) {
      displayModel = HomeFrontDisplayModel(
        'Favourites', 
        MangaBasicDisplayType.favourites, 
        []
      );
    }

    late APIResponseModel response;

    if(type == MangaBasicDisplayType.top) {
      response = await mangaRepository.fetchTopManga();
    } else if(type == MangaBasicDisplayType.mostPopular) {
      response = await mangaRepository.fetchMostPopularManga();
    } else if(type == MangaBasicDisplayType.favourites) {
      response = await mangaRepository.fetchTopFavouritedManga();
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