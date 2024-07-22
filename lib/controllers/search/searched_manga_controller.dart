import 'dart:async';
import 'package:anidb/global_files.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchedMangaController {
  final String searchedText;
  late AutoDisposeAsyncNotifierProvider<SearchedMangaNotifier, List<MangaDataClass>> searchedMangaNotifier;

  SearchedMangaController(
    this.searchedText
  );

  void initialize() {
    searchedMangaNotifier = AsyncNotifierProvider.autoDispose<SearchedMangaNotifier, List<MangaDataClass>>(
      () => SearchedMangaNotifier(searchedText)
    );
  }

  void dispose() {
  }
}

class SearchedMangaNotifier extends AutoDisposeAsyncNotifier<List<MangaDataClass>>{
  final String searchedText;
  List<MangaDataClass> mangaList = [];

  SearchedMangaNotifier(this.searchedText);

  @override
  FutureOr<List<MangaDataClass>> build() async {
    state = const AsyncLoading();
    APIResponseModel response = await mangaRepository.searchManga(searchedText);
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