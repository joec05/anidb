import 'package:anime_list_app/global_files.dart'; 
import 'package:flutter/material.dart';

class SearchedCharactersController {
  final BuildContext context;
  final String searchedText;
  ValueNotifier<List<int>> charactersList = ValueNotifier([]);
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  SearchedCharactersController(
    this.context,
    this.searchedText
  );

  bool get mounted => context.mounted;

  void initializeController() {
    if(mounted){
      fetchSearchedCharactersList();
    }
  }

  void dispose() {
    charactersList.dispose();
    isLoading.dispose();
  }

  void fetchSearchedCharactersList() async{
    if(searchedText.isNotEmpty){
      isLoading.value = true;
      var res = await apiCallRepo.runAPICall(
        context,
        APICallType.get,
        jikanApiUrl,
        '$jikanApiUrl/characters?q=$searchedText',
        {}
      );
      if(res != null) {
        var data = res['data'];
        if(mounted) {
          for(int i = 0; i < data.length; i++){
            updateBasicCharacterData(data[i]);
            int id = data[i]['mal_id'];
            if(appStateRepo.globalCharacterData[id] != null){
              charactersList.value.add(id);
            }
          }
          charactersList.value = [...charactersList.value];
          isLoading.value = false;
        }
      }
    }
  }

  
}