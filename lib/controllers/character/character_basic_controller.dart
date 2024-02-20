import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class CharacterBasicController {
  final BuildContext context;
  final CharacterBasicDisplayType type;
  ValueNotifier<List<int>> charactersList = ValueNotifier([]);
  ValueNotifier<bool> isLoading = ValueNotifier(true);

  CharacterBasicController(
    this.context,
    this.type
  );

  bool get mounted => context.mounted;

  void initializeController(){
    fetchCharactersList();
  }

  void dispose(){
    charactersList.dispose();
    isLoading.dispose();
  }

  String generateAPIRequestPath(){
    if(type == CharacterBasicDisplayType.top){
      return '$jikanApiUrl/top/characters?limit=24';
    }
    return '';
  }

  Future<void> fetchCharactersList() async{
    if(mounted){
      var res = await apiCallRepo.runAPICall(
        context,
        APICallType.get,
        jikanApiUrl,
        generateAPIRequestPath(),
        {}
      );
      if(res != null) {
        var data = res['data'];
        if(mounted) {
          for(int i = 0; i < data.length; i++){
            updateBasicCharacterData(data[i]);
            charactersList.value.add(data[i]['mal_id']);
          }
          charactersList.value = [...charactersList.value];
          isLoading.value = false;
        }
      }
    }
  }
}