import 'package:anime_list_app/constants/anime/enums.dart';
import 'package:anime_list_app/constants/anime/functions.dart';
import 'package:anime_list_app/constants/api/enums.dart';
import 'package:anime_list_app/constants/api/variables.dart';
import 'package:anime_list_app/constants/limit/variables.dart';
import 'package:anime_list_app/models/anime/anime_data_class.dart';
import 'package:anime_list_app/models/api/api_response_model.dart';
import 'package:anime_list_app/models/character/character_data_class.dart';
import 'package:anime_list_app/models/character/character_image_class.dart';
import 'package:anime_list_app/models/user/user_anime_list_status_class.dart';
import 'package:anime_list_app/repository/api_call_repo.dart';
import 'package:anime_list_app/repository/update_state_repo.dart';
import 'package:flutter/material.dart';

class AnimeRepository {
  final BuildContext context;

  AnimeRepository(this.context);
  
  Future<APIResponseModel> fetchAnimeDetails(int animeID) async{
    APIResponseModel res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/anime/$animeID?$fetchAllAnimeFieldsStr',
      {}
    );
    if(res.error == null) {
      AnimeDataClass animeDataModel = AnimeDataClass.fetchNewInstance(-1).fromMapUpdateAll(res.data);
      if(context.mounted) {
        updateAnimeStatusFromMap(context, animeDataModel.id, res.data['my_list_status']);
      }
      return APIResponseModel(animeDataModel, null);
    } else {
      return res;
    }
  }

  Future<APIResponseModel> fetchAnimeCharacters(int animeID) async{
    APIResponseModel res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      jikanApiUrl,
      '$jikanApiUrl/anime/$animeID/characters',
      {}
    );
    if(res.error == null) {
      var data = res.data['data'];
      List<CharacterDataClass> characters = List<CharacterDataClass>.generate(data.length, (i){
        CharacterDataClass newCharacterData = CharacterDataClass.fetchNewInstance(data[i]['character']['mal_id']);
        newCharacterData.name = data[i]['character']['name'];
        newCharacterData.cover = CharacterImageClass(
          data[i]['character']['images']['jpg']['small_image_url'],
          data[i]['character']['images']['jpg']['image_url']
        );
        return newCharacterData;
      });
      return APIResponseModel(characters, null);
    } else {
      return res;
    }
  }

  Future<APIResponseModel> fetchSeasonAnime() async{
    List<AnimeDataClass> animeList = [];
    APIResponseModel res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/anime/season/${DateTime.now().year}/${getCurrentSeason()}?fields=$fetchAllAnimeFieldsStr&limit=${getAnimeBasicDisplayFetchCount()}',
      {}
    );
    if(res.error == null) {
      var data = res.data['data'];
      for(int i = 0; i < data.length; i++){
        if(context.mounted) {
          AnimeDataClass animeDataModel = AnimeDataClass.fetchNewInstance(-1).fromMapUpdateAll(data[i]['node']);
          updateAnimeStatusFromMap(context, animeDataModel.id, data[i]['node']['my_list_status']);
          animeList.add(animeDataModel);
        }
      }
      return APIResponseModel(animeList, null);
    } else {
      return res;
    }
  }

  Future<APIResponseModel> fetchTopAnime() async{
    List<AnimeDataClass> animeList = [];
    APIResponseModel res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/anime/ranking?$fetchAllAnimeFieldsStr&$fetchAllAnimeFieldsStr&ranking_type=all&limit=${getAnimeBasicDisplayFetchCount()}',
      {}
    );
    if(res.error == null) {
      var data = res.data['data'];
      for(int i = 0; i < data.length; i++){
        if(context.mounted) {
          AnimeDataClass animeDataModel = AnimeDataClass.fetchNewInstance(-1).fromMapUpdateAll(data[i]['node']);
          updateAnimeStatusFromMap(context, animeDataModel.id, data[i]['node']['my_list_status']);
          animeList.add(animeDataModel);
        }
      }
      return APIResponseModel(animeList, null);
    } else {
      return res;
    }
  }

  Future<APIResponseModel> fetchTopAiringAnime() async{
    List<AnimeDataClass> animeList = [];
    APIResponseModel res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/anime/ranking?$fetchAllAnimeFieldsStr&ranking_type=airing&limit=${getAnimeBasicDisplayFetchCount()}',
      {}
    );
    if(res.error == null) {
      var data = res.data['data'];
      for(int i = 0; i < data.length; i++){
        if(context.mounted) {
          AnimeDataClass animeDataModel = AnimeDataClass.fetchNewInstance(-1).fromMapUpdateAll(data[i]['node']);
          updateAnimeStatusFromMap(context, animeDataModel.id, data[i]['node']['my_list_status']);
          animeList.add(animeDataModel);
        }
      }
      return APIResponseModel(animeList, null);
    } else {
      return res;
    }
  }

  Future<APIResponseModel> fetchTopUpcomingAnime() async{
    List<AnimeDataClass> animeList = [];
    APIResponseModel res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/anime/ranking?$fetchAllAnimeFieldsStr&ranking_type=upcoming&limit=${getAnimeBasicDisplayFetchCount()}',
      {}
    );
    if(res.error == null) {
      var data = res.data['data'];
      for(int i = 0; i < data.length; i++){
        if(context.mounted) {
          AnimeDataClass animeDataModel = AnimeDataClass.fetchNewInstance(-1).fromMapUpdateAll(data[i]['node']);
          updateAnimeStatusFromMap(context, animeDataModel.id, data[i]['node']['my_list_status']);
          animeList.add(animeDataModel);
        }
      }
      return APIResponseModel(animeList, null);
    } else {
      return res;
    }
  }

  Future<APIResponseModel> fetchMostPopularAnime() async{
    List<AnimeDataClass> animeList = [];
    APIResponseModel res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/anime/ranking?$fetchAllAnimeFieldsStr&ranking_type=bypopularity&limit=${getAnimeBasicDisplayFetchCount()}',
      {}
    );
    if(res.error == null) {
      var data = res.data['data'];
      for(int i = 0; i < data.length; i++){
        if(context.mounted) {
          AnimeDataClass animeDataModel = AnimeDataClass.fetchNewInstance(-1).fromMapUpdateAll(data[i]['node']);
          updateAnimeStatusFromMap(context, animeDataModel.id, data[i]['node']['my_list_status']);
          animeList.add(animeDataModel);
        }
      }
      return APIResponseModel(animeList, null);
    } else {
      return res;
    }
  }

  Future<APIResponseModel> fetchTopFavouritedAnime() async{
    List<AnimeDataClass> animeList = [];
    APIResponseModel res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/anime/ranking?$fetchAllAnimeFieldsStr&ranking_type=favorite&limit=${getAnimeBasicDisplayFetchCount()}',
      {}
    );
    if(res.error == null) {
      var data = res.data['data'];
      for(int i = 0; i < data.length; i++){
        if(context.mounted) {
          AnimeDataClass animeDataModel = AnimeDataClass.fetchNewInstance(-1).fromMapUpdateAll(data[i]['node']);
          updateAnimeStatusFromMap(context, animeDataModel.id, data[i]['node']['my_list_status']);
          animeList.add(animeDataModel);
        }
      }
      return APIResponseModel(animeList, null);
    } else {
      return res;
    }
  }

  Future<APIResponseModel> fetchSuggestedAnime() async{
    List<AnimeDataClass> animeList = [];
    APIResponseModel res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/anime/suggestions?$fetchAllAnimeFieldsStr&limit=${getAnimeBasicDisplayTotalFetchCount()}',
      {}
    );
    if(res.error == null) {
      var data = res.data['data'];
      if(context.mounted) {
        for(int i = 0; i < data.length; i++){
          if(context.mounted) {
            AnimeDataClass animeDataModel = AnimeDataClass.fetchNewInstance(-1).fromMapUpdateAll(data[i]['node']);
            updateAnimeStatusFromMap(context, animeDataModel.id, data[i]['node']['my_list_status']);
            animeList.add(animeDataModel);
          }
        }
      }
      return APIResponseModel(animeList, null);
    } else {
      return res;
    }
  }

  Future<APIResponseModel> fetchMyAnimesList(UserAnimeListStatusClass statusClass) async{
    APIResponseModel res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/users/@me/animelist?status=${statusClass.status}&offset=${statusClass.animeList.length}&limit=$userDisplayFetchLimit&$fetchAllAnimeFieldsStr',
      {}
    );
    if(res.error == null) {
      statusClass = statusClass.updateCanPaginate((res.data['paging']['next'] != null));
      var data = res.data['data'];
      for(int i = 0; i < data.length; i++){
        AnimeDataClass animeData = AnimeDataClass.fetchNewInstance(-1).fromMapUpdateAll(data[i]['node']);
        int id = animeData.id;
        if(context.mounted) {
          updateAnimeStatusFromMap(context, id, data[i]['node']['my_list_status']);
        }
        statusClass.animeList.add(animeData);
      }
      return APIResponseModel(statusClass, null); 
    } else {
      return res;
    }
  }

  Future<APIResponseModel> searchAnime(String searchedText) async{
    List<AnimeDataClass> animeList = [];
    APIResponseModel res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/anime?$fetchAllAnimeFieldsStr&q=$searchedText&limit=$searchFetchLimit',
      {}
    );
    if(res.error == null) {
      var data = res.data['data'];
      for(int i = 0; i < data.length; i++){
        AnimeDataClass animeDataModel = AnimeDataClass.fetchNewInstance(-1).fromMapUpdateAll(data[i]['node']);
        if(context.mounted) {
          updateAnimeStatusFromMap(context, animeDataModel.id, data[i]['node']['my_list_status']);
        }
        animeList.add(animeDataModel);
      }
      return APIResponseModel(animeList, null);
    } else {
      return res;
    }
  }

  Future<APIResponseModel> fetchAnimeListFromType(AnimeBasicDisplayType type) async{
    String generateAPIRequestPath() {
      if(type == AnimeBasicDisplayType.season){
        return '$malApiUrl/anime/season/${DateTime.now().year}/${getCurrentSeason()}?$fetchAllAnimeFieldsStr&limit=${getAnimeBasicDisplayTotalFetchCount()}';
      }else if(type == AnimeBasicDisplayType.top){
        return '$malApiUrl/anime/ranking?$fetchAllAnimeFieldsStr&ranking_type=all&limit=${getAnimeBasicDisplayTotalFetchCount()}';
      }else if(type == AnimeBasicDisplayType.airing){
        return '$malApiUrl/anime/ranking?$fetchAllAnimeFieldsStr&ranking_type=airing&limit=${getAnimeBasicDisplayTotalFetchCount()}';
      }else if(type == AnimeBasicDisplayType.upcoming){
        return '$malApiUrl/anime/ranking?$fetchAllAnimeFieldsStr&ranking_type=upcoming&limit=${getAnimeBasicDisplayTotalFetchCount()}';
      }else if(type == AnimeBasicDisplayType.mostPopular){
        return '$malApiUrl/anime/ranking?$fetchAllAnimeFieldsStr&ranking_type=bypopularity&limit=${getAnimeBasicDisplayTotalFetchCount()}';
      }else if(type == AnimeBasicDisplayType.favourites){
        return '$malApiUrl/anime/ranking?$fetchAllAnimeFieldsStr&ranking_type=favorite&limit=${getAnimeBasicDisplayTotalFetchCount()}';
      }
      return '';
    }

    List<AnimeDataClass> animeList = [];

    APIResponseModel res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      generateAPIRequestPath(),
      {}
    );
    if(res.error == null) {
      var data = res.data['data'];
      for(int i = 0; i < data.length; i++){
        AnimeDataClass animeDataModel = AnimeDataClass.fetchNewInstance(-1).fromMapUpdateAll(data[i]['node']);
        if(context.mounted) {
          updateAnimeStatusFromMap(context, animeDataModel.id, data[i]['node']['my_list_status']);
        }
        animeList.add(animeDataModel);
      }
      return APIResponseModel(animeList, null);
    } else {
      return res;
    }
  }
  
}