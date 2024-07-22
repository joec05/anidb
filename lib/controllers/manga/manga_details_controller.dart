import 'dart:async';
import 'package:anidb/models/api/api_response_model.dart';
import 'package:anidb/models/manga/manga_data_class.dart';
import 'package:anidb/repository/manga_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MangaDetailsController {
  final int mangaID;
  late AutoDisposeAsyncNotifierProvider<MangaDetailsNotifier, MangaDataClass> mangaDataNotifier;

  MangaDetailsController(
    this.mangaID
  );

  void initialize() async {
    mangaDataNotifier = AsyncNotifierProvider.autoDispose<MangaDetailsNotifier, MangaDataClass>(
      () => MangaDetailsNotifier(mangaID)
    );
  }

  void dispose(){
  }  
}

class MangaDetailsNotifier extends AutoDisposeAsyncNotifier<MangaDataClass>{
  final int mangaID;
  MangaDataClass mangaData = MangaDataClass.fetchNewInstance(-1);

  MangaDetailsNotifier(this.mangaID);

  @override
  FutureOr<MangaDataClass> build() async {
    state = const AsyncLoading();
    APIResponseModel response = await mangaRepository.fetchMangaDetails(mangaID);
    if(response.error != null) {
      state = AsyncError(response.error!.object, response.error!.stackTrace);
      throw Exception(response.error!.object);
    } else {
      mangaData = response.data;
      APIResponseModel response2 = await mangaRepository.fetchMangaCharacters(mangaID);
      if(response2.error != null) {
        state = AsyncError(response2.error!.object, response2.error!.stackTrace);
        throw Exception(response.error!.object);
      } else {
        mangaData.characters = response2.data;
        APIResponseModel response3 = await mangaRepository.fetchMangaStatistics(mangaID);
        if(response3.error != null) {
          state = AsyncError(response3.error!.object, response3.error!.stackTrace);
          throw Exception(response.error!.object);
        } else {
          mangaData.statistics = response3.data;
          state = AsyncData(mangaData);
        }
      }
    }
    return mangaData;
  }

  Future<void> refresh() async => await build();
}