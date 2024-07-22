import 'dart:async';
import 'package:anidb_app/global_files.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimeDetailsController {
  final int animeID;
  late AutoDisposeAsyncNotifierProvider<AnimeDetailsNotifier, AnimeDataClass> animeDataNotifier;

  AnimeDetailsController (
    this.animeID
  );

  void initialize() async {
    animeDataNotifier = AsyncNotifierProvider.autoDispose<AnimeDetailsNotifier, AnimeDataClass>(
      () => AnimeDetailsNotifier(animeID)
    );
  }

  void dispose(){
  }
}

class AnimeDetailsNotifier extends AutoDisposeAsyncNotifier<AnimeDataClass>{
  final int animeID;
  AnimeDataClass animeData = AnimeDataClass.fetchNewInstance(-1);

  AnimeDetailsNotifier(this.animeID);

  @override
  FutureOr<AnimeDataClass> build() async {
    state = const AsyncLoading();
    APIResponseModel response = await animeRepository.fetchAnimeDetails(animeID);
    if(response.error != null) {
      state = AsyncError(response.error!.object, response.error!.stackTrace);
      throw Exception(response.error!.object);
    } else {
      animeData = response.data;
      state = AsyncData(animeData);
    }
    APIResponseModel response2 = await animeRepository.fetchAnimeCharacters(animeID);
    if(response2.error != null) {
      state = AsyncError(response2.error!.object, response2.error!.stackTrace);
      throw Exception(response.error!.object);
    } else {
      animeData.characters = response2.data;
      state = AsyncData(animeData);
    }
    return animeData;
  }

  Future<void> refresh() async => await build();
}