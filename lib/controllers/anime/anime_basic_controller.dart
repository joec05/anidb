import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewMoreAnimeController {
  AnimeBasicDisplayType type;
  late AutoDisposeAsyncNotifierProvider<ViewMoreAnimeNotifier, List<AnimeDataClass>> animeDataNotifier;

  ViewMoreAnimeController(
    this.type
  );

  void initialize() async {
    animeDataNotifier = AsyncNotifierProvider.autoDispose<ViewMoreAnimeNotifier, List<AnimeDataClass>>(
      () => ViewMoreAnimeNotifier(type)
    );
  }

  void dispose() {}
}

class ViewMoreAnimeNotifier extends AutoDisposeAsyncNotifier<List<AnimeDataClass>>{
  final AnimeBasicDisplayType type;
  late AnimeRepository animeRepository;
  List<AnimeDataClass> animeList = [];

  ViewMoreAnimeNotifier(this.type);

  @override
  FutureOr<List<AnimeDataClass>> build() async {
    state = const AsyncLoading();
    animeRepository = AnimeRepository();
    APIResponseModel response = await animeRepository.fetchAnimeListFromType(type);
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