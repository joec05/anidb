import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreController {
  final BuildContext context;
  late AutoDisposeAsyncNotifierProvider<ExploreNotifier, List<AnimeDataClass>> exploreNotifier;

  ExploreController (
    this.context
  );

  bool get mounted => context.mounted;

  void initializeController() {
    exploreNotifier = AsyncNotifierProvider.autoDispose<ExploreNotifier, List<AnimeDataClass>>(
      () => ExploreNotifier(context)
    );
  }

  void dispose(){
  }
}

class ExploreNotifier extends AutoDisposeAsyncNotifier<List<AnimeDataClass>> {
  final BuildContext context;
  late AnimeRepository animeRepository;
  List<AnimeDataClass> animeList = [];

  ExploreNotifier(this.context);

  @override
  FutureOr<List<AnimeDataClass>> build() async {
    state = const AsyncLoading();
    animeRepository = AnimeRepository(context);
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