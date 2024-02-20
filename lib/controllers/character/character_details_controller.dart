import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class CharacterDetailsController {
  final BuildContext context;
  final int characterID;
  ValueNotifier<bool> isLoading = ValueNotifier(true);

  CharacterDetailsController (
    this.context,
    this.characterID
  );
  
  bool get mounted => context.mounted;

  void initializeController(){
    fetchCharacterDetails();
  }

  void dispose(){
    isLoading.dispose();
  }

  void fetchCharacterDetails() async{
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      jikanApiUrl,
      '$jikanApiUrl/characters/$characterID/full',
      {}
    );
    if(res != null) {
      var data = res['data'];
      updateCharacterData(data);
      if(mounted) {
        isLoading.value = false;
      }
    }
  }
}