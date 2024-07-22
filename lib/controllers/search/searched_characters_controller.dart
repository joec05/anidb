import 'dart:async';
import 'package:anidb/global_files.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchedCharactersController {
  final String searchedText;
  late AutoDisposeAsyncNotifierProvider<SearchedCharactersNotifier, List<CharacterDataClass>> searchedCharactersNotifier;

  SearchedCharactersController(
    this.searchedText
  );


  void initialize() {
    searchedCharactersNotifier = AsyncNotifierProvider.autoDispose<SearchedCharactersNotifier, List<CharacterDataClass>>(
      () => SearchedCharactersNotifier(searchedText)
    );
  }

  void dispose() {
  } 
}

class SearchedCharactersNotifier extends AutoDisposeAsyncNotifier<List<CharacterDataClass>>{
  final String searchedText;
  List<CharacterDataClass> characterList = [];

  SearchedCharactersNotifier(this.searchedText);

  @override
  FutureOr<List<CharacterDataClass>> build() async {
    state = const AsyncLoading();
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