import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchedAnimeController {
  final BuildContext context;
  final String searchedText;
  late AutoDisposeAsyncNotifierProvider<SearchedAnimeNotifier, List<AnimeDataClass>> searchedAnimeNotifier;

  SearchedAnimeController(
    this.context,
    this.searchedText
  );

  bool get mounted => context.mounted;

  void initializeController() {
    searchedAnimeNotifier = AsyncNotifierProvider.autoDispose<SearchedAnimeNotifier, List<AnimeDataClass>>(
      () => SearchedAnimeNotifier(context, searchedText)
    );
  }
}

class SearchedAnimeNotifier extends AutoDisposeAsyncNotifier<List<AnimeDataClass>>{
  final BuildContext context;
  final String searchedText;
  late AnimeRepository animeRepository;
  List<AnimeDataClass> animeList = [];

  SearchedAnimeNotifier(this.context, this.searchedText);

  @override
  FutureOr<List<AnimeDataClass>> build() async {
    state = const AsyncLoading();
    animeRepository = AnimeRepository(context);
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