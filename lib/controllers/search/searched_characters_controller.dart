import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchedCharactersController {
  final BuildContext context;
  final String searchedText;
  late AutoDisposeAsyncNotifierProvider<SearchedCharactersNotifier, List<CharacterDataClass>> searchedCharactersNotifier;

  SearchedCharactersController(
    this.context,
    this.searchedText
  );

  bool get mounted => context.mounted;

  void initializeController() {
    searchedCharactersNotifier = AsyncNotifierProvider.autoDispose<SearchedCharactersNotifier, List<CharacterDataClass>>(
      () => SearchedCharactersNotifier(context, searchedText)
    );
  }

  void dispose() {
  } 
}

class SearchedCharactersNotifier extends AutoDisposeAsyncNotifier<List<CharacterDataClass>>{
  final BuildContext context;
  final String searchedText;
  late CharacterRepository characterRepository;
  List<CharacterDataClass> characterList = [];

  SearchedCharactersNotifier(this.context, this.searchedText);

  @override
  FutureOr<List<CharacterDataClass>> build() async {
    state = const AsyncLoading();
    characterRepository = CharacterRepository(context);
    APIResponseModel response = await characterRepository.searchCharacters(searchedText);
    if(response.error != null) {
      state = AsyncError(response.error!.object, response.error!.stackTrace);
      throw Exception(response.error!.object);
    } else {
      characterList = response.data;
      state = AsyncData(characterList);
    }
    return characterList;
  }

  Future<void> refresh() async => await build();
}