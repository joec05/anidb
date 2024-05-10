import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class CharacterRepository {
  final BuildContext context;

  CharacterRepository(this.context);

  Future<APIResponseModel> fetchTopCharacters() async{
    List<CharacterDataClass> topCharactersList = [];
    APIResponseModel res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      jikanApiUrl,
      '$jikanApiUrl/top/characters?limit=${getAnimeBasicDisplayFetchCount()}',
      {}
    );
    if(res.error == null) {
      var data = res.data['data'];
      if(context.mounted) {
        for(int i = 0; i < data.length; i++){
          // updateBasicCharacterData(data[i]);
          topCharactersList.add(CharacterDataClass.fetchNewInstance(-1).fromMapUpdateBasic(data[i]));
        }
      }
      return APIResponseModel(topCharactersList, null);
    } else {
      return res;
    }
  }

  Future<APIResponseModel> fetchCharacterDetails(int characterID) async{
    APIResponseModel res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      jikanApiUrl,
      '$jikanApiUrl/characters/$characterID/full',
      {}
    );
    if(res.error == null) {
      var data = res.data['data'];
      CharacterDataClass characterModel = CharacterDataClass.fetchNewInstance(-1).fromMapUpdateAll(data);
      return APIResponseModel(characterModel, null);
    } else {
      return res;
    }
  }

  Future<APIResponseModel> searchCharacters(String searchedText) async{
    List<CharacterDataClass> charactersList = [];
    APIResponseModel res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      jikanApiUrl,
      '$jikanApiUrl/characters?q=$searchedText',
      {}
    );
    if(res.error == null) {
      var data = res.data['data'];
      for(int i = 0; i < data.length; i++){
        CharacterDataClass characterData = CharacterDataClass.fetchNewInstance(-1).fromMapUpdateBasic(data[i]);
        charactersList.add(characterData);
      }
      return APIResponseModel(charactersList, null);
    } else {
      return res;
    }
  } 

  Future<APIResponseModel> fetchCharactersListFromType(CharacterBasicDisplayType type) async{
    String generateAPIRequestPath(){
      if(type == CharacterBasicDisplayType.top){
        return '$jikanApiUrl/top/characters?limit=24';
      }
      return '';
    }

    List<CharacterDataClass> charactersList = [];

    APIResponseModel res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      jikanApiUrl,
      generateAPIRequestPath(),
      {}
    );
    if(res.error == null) {
      var data = res.data['data'];
      for(int i = 0; i < data.length; i++){
        CharacterDataClass characterData = CharacterDataClass.fetchNewInstance(-1).fromMapUpdateBasic(data[i]);
        charactersList.add(characterData);
      }
      return APIResponseModel(charactersList, null);
    } else {
      return res;
    }
  }
}