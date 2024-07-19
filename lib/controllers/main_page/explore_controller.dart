import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreController {
  late AutoDisposeAsyncNotifierProvider<ExploreNotifier, List<AnimeDataClass>> exploreNotifier;

  void initialize() {
    exploreNotifier = AsyncNotifierProvider.autoDispose<ExploreNotifier, List<AnimeDataClass>>(
      () => ExploreNotifier()
    );
  }

  void dispose(){
  }
}

class ExploreNotifier extends AutoDisposeAsyncNotifier<List<AnimeDataClass>> {
  late AnimeRepository animeRepository;
  List<AnimeDataClass> animeList = [];

  @override
  FutureOr<List<AnimeDataClass>> build() async {
    state = const AsyncLoading();
    animeRepository = AnimeRepository();
    APIResponseModel response = await animeRepository.fetchSuggestedAnime();
    if(response.error != null) {
      state = AsyncError(response.error!.object, response.error!.stackTrace);
      throw Exception(response.error!.object);
    } else {
      animeList = response.data;
      state = AsyncData(animeList);
    }
    return animeList;
  }

  Future<void> refresh() async => await build();
}