import 'dart:async';
import 'package:anime_list_app/models/api/api_response_model.dart';
import 'package:anime_list_app/models/character/character_data_class.dart';
import 'package:anime_list_app/repository/character_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterDetailsController {
  final int characterID;
  late AutoDisposeAsyncNotifierProvider<CharacterDetailsNotifier, CharacterDataClass> characterDataNotifier;

  CharacterDetailsController (
    this.characterID
  );
  

  void initialize() {
    characterDataNotifier = AsyncNotifierProvider.autoDispose<CharacterDetailsNotifier, CharacterDataClass>(
      () => CharacterDetailsNotifier(characterID)
    );
  }

  void dispose(){
  }  
}

class CharacterDetailsNotifier extends AutoDisposeAsyncNotifier<CharacterDataClass>{
  final int characterID;
  CharacterDataClass characterData = CharacterDataClass.fetchNewInstance(-1);

  CharacterDetailsNotifier(this.characterID);

  @override
  FutureOr<CharacterDataClass> build() async {
    state = const AsyncLoading();
    APIResponseModel response = await characterRepository.fetchCharacterDetails(characterID);
    if(response.error != null) {
      state = AsyncError(response.error!.object, response.error!.stackTrace);
      throw Exception(response.error!.object);
    } else {
      characterData = response.data;
      state = AsyncData(characterData);
    }
    return characterData;
  }

  Future<void> refresh() async => await build();
}