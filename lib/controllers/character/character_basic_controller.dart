import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewMoreCharactersController {
  final BuildContext context;
  final CharacterBasicDisplayType type;
  late AutoDisposeAsyncNotifierProvider<ViewMoreCharactersNotifier, List<CharacterDataClass>> characterDataNotifier;

  ViewMoreCharactersController(
    this.context,
    this.type
  );

  bool get mounted => context.mounted;

  void initializeController() {
    characterDataNotifier = AsyncNotifierProvider.autoDispose<ViewMoreCharactersNotifier, List<CharacterDataClass>>(
      () => ViewMoreCharactersNotifier(context, type)
    );
  }

  void dispose(){}
}

class ViewMoreCharactersNotifier extends AutoDisposeAsyncNotifier<List<CharacterDataClass>>{
  final BuildContext context;
  final CharacterBasicDisplayType type;
  late CharacterRepository characterRepository;
  List<CharacterDataClass> charactersList = [];

  ViewMoreCharactersNotifier(this.context, this.type);

  @override
  FutureOr<List<CharacterDataClass>> build() async {
    state = const AsyncLoading();
    characterRepository = CharacterRepository(context);
    APIResponseModel response = await characterRepository.fetchCharactersListFromType(type);
    if(response.error != null) {
      state = AsyncError(response.error!.object, response.error!.stackTrace);
      throw Exception(response.error!.object);
    } else {
      charactersList = response.data;
      state = AsyncData(charactersList);
    }
    return charactersList;
  }

  Future<void> refresh() async => await build();
}