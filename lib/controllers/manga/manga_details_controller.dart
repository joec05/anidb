import 'dart:async';
import 'package:anime_list_app/models/api/api_response_model.dart';
import 'package:anime_list_app/models/manga/manga_data_class.dart';
import 'package:anime_list_app/repository/manga_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MangaDetailsController {
  final BuildContext context;
  final int mangaID;
  late AutoDisposeAsyncNotifierProvider<MangaDetailsNotifier, MangaDataClass> mangaDataNotifier;

  MangaDetailsController(
    this.context,
    this.mangaID
  );

  bool get mounted => context.mounted;

  void initializeController() async {
    mangaDataNotifier = AsyncNotifierProvider.autoDispose<MangaDetailsNotifier, MangaDataClass>(
      () => MangaDetailsNotifier(context, mangaID)
    );
  }

  void dispose(){
  }  
}

class MangaDetailsNotifier extends AutoDisposeAsyncNotifier<MangaDataClass>{
  final BuildContext context;
  final int mangaID;
  late MangaRepository mangaRepository;
  MangaDataClass mangaData = MangaDataClass.fetchNewInstance(-1);

  MangaDetailsNotifier(this.context, this.mangaID);

  @override
  FutureOr<MangaDataClass> build() async {
    state = const AsyncLoading();
    mangaRepository = MangaRepository(context);
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