import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimeDetailsController {
  final BuildContext context;
  final int animeID;
  late AutoDisposeAsyncNotifierProvider<AnimeDetailsNotifier, AnimeDataClass> animeDataNotifier;

  AnimeDetailsController (
    this.context,
    this.animeID
  );

  bool get mounted => context.mounted;

  void initializeController() async {
    animeDataNotifier = AsyncNotifierProvider.autoDispose<AnimeDetailsNotifier, AnimeDataClass>(
      () => AnimeDetailsNotifier(context, animeID)
    );
  }

  void dispose(){
  }
}

class AnimeDetailsNotifier extends AutoDisposeAsyncNotifier<AnimeDataClass>{
  final BuildContext context;
  final int animeID;
  late AnimeRepository animeRepository;
  AnimeDataClass animeData = AnimeDataClass.fetchNewInstance(-1);

  AnimeDetailsNotifier(this.context, this.animeID);

  @override
  FutureOr<AnimeDataClass> build() async {
    state = const AsyncLoading();
    animeRepository = AnimeRepository(context);
    APIResponseModel response = await animeRepository.fetchAnimeDetails(animeID);
    if(response.error != null) {
      state = AsyncError(response.error!.object, response.error!.stackTrace);
      throw Exception(response.error!.object);
    } else {
      animeData = response.data;
      APIResponseModel response2 = await animeRepository.fetchAnimeCharacters(animeID);
      if(response2.error != null) {
        state = AsyncError(response2.error!.object, response2.error!.stackTrace);
        throw Exception(response.error!.object);
      } else {
        animeData.characters = response2.data;
        state = AsyncData(animeData);
      }
    }
    return animeData;
  }

  Future<void> refresh() async => await build();
}