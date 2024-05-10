import 'dart:async';
import 'package:anime_list_app/models/api/api_response_model.dart';
import 'package:anime_list_app/models/character/character_data_class.dart';
import 'package:anime_list_app/repository/character_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterDetailsController {
  final BuildContext context;
  final int characterID;
  late AutoDisposeAsyncNotifierProvider<CharacterDetailsNotifier, CharacterDataClass> characterDataNotifier;

  CharacterDetailsController (
    this.context,
    this.characterID
  );
  
  bool get mounted => context.mounted;

  void initializeController() {
    characterDataNotifier = AsyncNotifierProvider.autoDispose<CharacterDetailsNotifier, CharacterDataClass>(
      () => CharacterDetailsNotifier(context, characterID)
    );
  }

  void dispose(){
  }  
}

class CharacterDetailsNotifier extends AutoDisposeAsyncNotifier<CharacterDataClass>{
  final BuildContext context;
  final int characterID;
  late CharacterRepository characterRepository;
  CharacterDataClass characterData = CharacterDataClass.fetchNewInstance(-1);

  CharacterDetailsNotifier(this.context, this.characterID);

  @override
  FutureOr<CharacterDataClass> build() async {
    state = const AsyncLoading();
    characterRepository = CharacterRepository(context);
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