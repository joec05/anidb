import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewMoreMangaController {
  final BuildContext context;
  final MangaBasicDisplayType type;
  late AutoDisposeAsyncNotifierProvider<ViewMoreMangaNotifier, List<MangaDataClass>> mangaDataNotifier;

  ViewMoreMangaController (
    this.context,
    this.type
  );

  bool get mounted => context.mounted;

  void initializeController() {
    mangaDataNotifier = AsyncNotifierProvider.autoDispose<ViewMoreMangaNotifier, List<MangaDataClass>>(
      () => ViewMoreMangaNotifier(context, type)
    );
  }

  void dispose() {}
}

class ViewMoreMangaNotifier extends AutoDisposeAsyncNotifier<List<MangaDataClass>>{
  final BuildContext context;
  final MangaBasicDisplayType type;
  late MangaRepository mangaRepository;
  List<MangaDataClass> mangaList = [];

  ViewMoreMangaNotifier(this.context, this.type);

  @override
  FutureOr<List<MangaDataClass>> build() async {
    state = const AsyncLoading();
    mangaRepository = MangaRepository(context);
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