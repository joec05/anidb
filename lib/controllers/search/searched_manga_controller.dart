import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchedMangaController {
  final BuildContext context;
  final String searchedText;
  late AutoDisposeAsyncNotifierProvider<SearchedMangaNotifier, List<MangaDataClass>> searchedMangaNotifier;

  SearchedMangaController(
    this.context,
    this.searchedText
  );

  bool get mounted => context.mounted;

  void initializeController() {
    searchedMangaNotifier = AsyncNotifierProvider.autoDispose<SearchedMangaNotifier, List<MangaDataClass>>(
      () => SearchedMangaNotifier(context, searchedText)
    );
  }

  void dispose() {
  }
}

class SearchedMangaNotifier extends AutoDisposeAsyncNotifier<List<MangaDataClass>>{
  final BuildContext context;
  final String searchedText;
  late MangaRepository mangaRepository;
  List<MangaDataClass> mangaList = [];

  SearchedMangaNotifier(this.context, this.searchedText);

  @override
  FutureOr<List<MangaDataClass>> build() async {
    state = const AsyncLoading();
    mangaRepository = MangaRepository(context);
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