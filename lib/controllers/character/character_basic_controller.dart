import 'dart:async';
import 'package:anidb_app/global_files.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewMoreCharactersController {
  final CharacterBasicDisplayType type;
  late AutoDisposeAsyncNotifierProvider<ViewMoreCharactersNotifier, List<CharacterDataClass>> characterDataNotifier;

  ViewMoreCharactersController(
    this.type
  );


  void initialize() {
    characterDataNotifier = AsyncNotifierProvider.autoDispose<ViewMoreCharactersNotifier, List<CharacterDataClass>>(
      () => ViewMoreCharactersNotifier(type)
    );
  }

  void dispose(){}
}

class ViewMoreCharactersNotifier extends AutoDisposeAsyncNotifier<List<CharacterDataClass>>{
  final CharacterBasicDisplayType type;
  List<CharacterDataClass> charactersList = [];

  ViewMoreCharactersNotifier(this.type);

  @override
  FutureOr<List<CharacterDataClass>> build() async {
    state = const AsyncLoading();
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