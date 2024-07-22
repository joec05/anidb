import 'dart:async';
import 'package:anidb_app/global_files.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewMoreMangaController {
  final MangaBasicDisplayType type;
  late AutoDisposeAsyncNotifierProvider<ViewMoreMangaNotifier, List<MangaDataClass>> mangaDataNotifier;

  ViewMoreMangaController (
    this.type
  );

  void initialize() {
    mangaDataNotifier = AsyncNotifierProvider.autoDispose<ViewMoreMangaNotifier, List<MangaDataClass>>(
      () => ViewMoreMangaNotifier(type)
    );
  }

  void dispose() {}
}

class ViewMoreMangaNotifier extends AutoDisposeAsyncNotifier<List<MangaDataClass>>{
  final MangaBasicDisplayType type;
  List<MangaDataClass> mangaList = [];

  ViewMoreMangaNotifier(this.type);

  @override
  FutureOr<List<MangaDataClass>> build() async {
    state = const AsyncLoading();
    APIResponseModel response = await mangaRepository.fetchMangaListFromType(type);
    if(response.error != null) {
      state = AsyncError(response.error!.object, response.error!.stackTrace);
      throw Exception(response.error!.object);
    } else {
      mangaList = response.data;
      state = AsyncData(mangaList);
    }
    return mangaList;
  }

  Future<void> refresh() async => await build();
}