import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MangaRankingController {
  late AutoDisposeAsyncNotifierProvider<MangaRankingNotifier, List<HomeFrontDisplayModel>> mangaDataNotifier;

  void initialize() async {
    mangaDataNotifier = AsyncNotifierProvider.autoDispose<MangaRankingNotifier, List<HomeFrontDisplayModel>>(
      () => MangaRankingNotifier()
    );
  }

  void dispose(){
  }
}

class MangaRankingNotifier extends AutoDisposeAsyncNotifier<List<HomeFrontDisplayModel>>{
  late MangaRepository mangaRepository;
  List<HomeFrontDisplayModel> displayed = [
    HomeFrontDisplayModel(
      'Score', 
      MangaBasicDisplayType.top, 
      []
    ),
    HomeFrontDisplayModel(
      'Popularity', 
      MangaBasicDisplayType.mostPopular, 
      []
    ),
    HomeFrontDisplayModel(
      'Favourites', 
      MangaBasicDisplayType.favourites, 
      []
    ),
  ];

  @override
  FutureOr<List<HomeFrontDisplayModel>> build() async {
    state = const AsyncLoading();
    mangaRepository = MangaRepository();
    APIResponseModel response1 = await mangaRepository.fetchTopManga();
    if(response1.error != null) {
      state = AsyncError(response1.error!.object, response1.error!.stackTrace);
      throw Exception(response1.error!.object);
    } else {
      displayed[0].dataList = response1.data;
      APIResponseModel response2 = await mangaRepository.fetchMostPopularManga();
      if(response2.error != null) {
        state = AsyncError(response2.error!.object, response2.error!.stackTrace);
        throw Exception(response2.error!.object);
      } else {
        displayed[1].dataList = response2.data;
        APIResponseModel response3 = await mangaRepository.fetchTopFavouritedManga();
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