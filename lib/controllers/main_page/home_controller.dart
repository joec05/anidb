import 'dart:async';
import 'package:anidb/global_files.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

List<String> description = [
  'This season',
  'Airing now',
  'Upcoming'
];

class HomeController {
  AutoDisposeAsyncNotifierProvider<HomeNotifier, HomeFrontDisplayModel> animeSeasonNotifier = AsyncNotifierProvider.autoDispose<HomeNotifier, HomeFrontDisplayModel>(
    () => HomeNotifier(AnimeBasicDisplayType.season)
  );
  AutoDisposeAsyncNotifierProvider<HomeNotifier, HomeFrontDisplayModel> animeAiringNotifier = AsyncNotifierProvider.autoDispose<HomeNotifier, HomeFrontDisplayModel>(
    () => HomeNotifier(AnimeBasicDisplayType.airing)
  );
  AutoDisposeAsyncNotifierProvider<HomeNotifier, HomeFrontDisplayModel> animeUpcomingNotifier = AsyncNotifierProvider.autoDispose<HomeNotifier, HomeFrontDisplayModel>(
    () => HomeNotifier(AnimeBasicDisplayType.upcoming)
  );
  late List<AutoDisposeAsyncNotifierProvider<HomeNotifier, HomeFrontDisplayModel>> notifiers;

  void initialize() async {
    notifiers = [animeSeasonNotifier, animeAiringNotifier, animeUpcomingNotifier];
  }

  void dispose(){
  }

  Future<void> refresh() async {
    for(int i = 0; i < notifiers.length; i++) {
      navigatorKey.currentContext?.read(notifiers[i].notifier).setLoading();
    }
    for(int i = 0; i < notifiers.length; i++) {
      final _ = await navigatorKey.currentContext?.read(notifiers[i].notifier).refresh();
    }
  }
}

class HomeNotifier extends AutoDisposeAsyncNotifier<HomeFrontDisplayModel> {
  final AnimeBasicDisplayType type;
  late HomeFrontDisplayModel displayModel;

  HomeNotifier(this.type);

  @override
  FutureOr<HomeFrontDisplayModel> build() async {
    state = const AsyncLoading();
    if(type == AnimeBasicDisplayType.season) {
      displayModel = HomeFrontDisplayModel(
        description[0], 
        AnimeBasicDisplayType.season, 
        []
      );
    } else if(type == AnimeBasicDisplayType.airing) {
      displayModel = HomeFrontDisplayModel(
        description[1], 
        AnimeBasicDisplayType.airing, 
        []
      );
    } else if(type == AnimeBasicDisplayType.upcoming) {
      displayModel = HomeFrontDisplayModel(
        description[2], 
        AnimeBasicDisplayType.upcoming, 
        []
      );
    }

    late APIResponseModel response;

    if(type == AnimeBasicDisplayType.season) {
      response = await animeRepository.fetchSeasonAnime();
    } else if(type == AnimeBasicDisplayType.airing) {
      response = await animeRepository.fetchTopAiringAnime();
    } else if(type == AnimeBasicDisplayType.upcoming) {
      response = await animeRepository.fetchTopUpcomingAnime();
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

  void setLoading() => state = const AsyncLoading();

  Future<void> refresh() async => await build();
}