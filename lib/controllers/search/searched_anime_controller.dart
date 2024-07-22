import 'dart:async';
import 'package:anidb_app/global_files.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchedAnimeController {
  final String searchedText;
  late AutoDisposeAsyncNotifierProvider<SearchedAnimeNotifier, List<AnimeDataClass>> searchedAnimeNotifier;

  SearchedAnimeController(
    this.searchedText
  );

  void initialize() {
    searchedAnimeNotifier = AsyncNotifierProvider.autoDispose<SearchedAnimeNotifier, List<AnimeDataClass>>(
      () => SearchedAnimeNotifier(searchedText)
    );
  }
}

class SearchedAnimeNotifier extends AutoDisposeAsyncNotifier<List<AnimeDataClass>>{
  final String searchedText;
  List<AnimeDataClass> animeList = [];

  SearchedAnimeNotifier(this.searchedText);

  @override
  FutureOr<List<AnimeDataClass>> build() async {
    state = const AsyncLoading();
    APIResponseModel response = await animeRepository.searchAnime(searchedText);
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