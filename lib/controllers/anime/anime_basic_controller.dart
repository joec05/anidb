import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewMoreAnimeController {
  final BuildContext context;
  AnimeBasicDisplayType type;
  late AutoDisposeAsyncNotifierProvider<ViewMoreAnimeNotifier, List<AnimeDataClass>> animeDataNotifier;

  ViewMoreAnimeController(
    this.context,
    this.type
  );

  bool get mounted => context.mounted;

  void initializeController() async {
    animeDataNotifier = AsyncNotifierProvider.autoDispose<ViewMoreAnimeNotifier, List<AnimeDataClass>>(
      () => ViewMoreAnimeNotifier(context, type)
    );
  }

  void dispose() {}
}

class ViewMoreAnimeNotifier extends AutoDisposeAsyncNotifier<List<AnimeDataClass>>{
  final BuildContext context;
  final AnimeBasicDisplayType type;
  late AnimeRepository animeRepository;
  List<AnimeDataClass> animeList = [];

  ViewMoreAnimeNotifier(this.context, this.type);

  @override
  FutureOr<List<AnimeDataClass>> build() async {
    state = const AsyncLoading();
    animeRepository = AnimeRepository(context);
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