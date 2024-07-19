import 'package:anime_list_app/constants/anime/functions.dart';
import 'package:anime_list_app/constants/api/enums.dart';
import 'package:anime_list_app/constants/api/variables.dart';
import 'package:anime_list_app/constants/limit/variables.dart';
import 'package:anime_list_app/constants/manga/enums.dart';
import 'package:anime_list_app/models/api/api_response_model.dart';
import 'package:anime_list_app/models/character/character_data_class.dart';
import 'package:anime_list_app/models/character/character_image_class.dart';
import 'package:anime_list_app/models/manga/manga_data_class.dart';
import 'package:anime_list_app/models/manga/manga_statistics_class.dart';
import 'package:anime_list_app/models/user/user_manga_list_status_class.dart';
import 'package:anime_list_app/repository/api_call_repo.dart';
import 'package:anime_list_app/repository/update_state_repo.dart';

class MangaRepository {
  Future<APIResponseModel> fetchTopManga() async{
    List<MangaDataClass> topMangaList = [];
    APIResponseModel res = await apiCallRepo.runAPICall(
      APICallType.get,
      malApiUrl,
      '$malApiUrl/manga/ranking?$fetchAllMangaFieldsStr&ranking_type=manga&limit=50}',
      {}
    );
    if(res.error == null) {
      var data = res.data['data'];
      for(int i = 0; i < data.length; i++){
        MangaDataClass mangaDataModel = MangaDataClass.fetchNewInstance(-1).fromMapUpdateAll(data[i]['node']);
        updateMangaStatusFromMap(mangaDataModel.id, data[i]['node']['my_list_status']);
        topMangaList.add(mangaDataModel);
      }  
      return APIResponseModel(topMangaList, null);
    } else {
      return res;
    }
  }

  Future<APIResponseModel> fetchTopFavouritedManga() async{
    List<MangaDataClass> topMangaList = [];
    APIResponseModel res = await apiCallRepo.runAPICall(
      APICallType.get,
      malApiUrl,
      '$malApiUrl/manga/ranking?$fetchAllMangaFieldsStr&ranking_type=favorite&limit=50}',
      {}
    );
    if(res.error == null) {
      var data = res.data['data'];
      for(int i = 0; i < data.length; i++){
        MangaDataClass mangaDataModel = MangaDataClass.fetchNewInstance(-1).fromMapUpdateAll(data[i]['node']);
        updateMangaStatusFromMap(mangaDataModel.id, data[i]['node']['my_list_status']);
        topMangaList.add(mangaDataModel);
      }  
      return APIResponseModel(topMangaList, null);
    } else {
      return res;
    }
  } 

  Future<APIResponseModel> fetchMostPopularManga() async{
    List<MangaDataClass> mostPopularMangaList = [];
    APIResponseModel res = await apiCallRepo.runAPICall(
      APICallType.get,
      malApiUrl,
      '$malApiUrl/manga/ranking?$fetchAllMangaFieldsStr&ranking_type=bypopularity&limit=50}',
      {}
    );
    if(res.error == null) {
      var data = res.data['data'];
      for(int i = 0; i < data.length; i++){
        MangaDataClass mangaDataModel = MangaDataClass.fetchNewInstance(-1).fromMapUpdateAll(data[i]['node']);
        updateMangaStatusFromMap(mangaDataModel.id, data[i]['node']['my_list_status']);
        mostPopularMangaList.add(mangaDataModel);
      }  
      return APIResponseModel(mostPopularMangaList, null);
    } else {
      return res;
    }
  }

  Future<APIResponseModel> fetchMangaDetails(int mangaID) async{
    APIResponseModel res = await apiCallRepo.runAPICall(
      APICallType.get,
      malApiUrl,
      '$malApiUrl/manga/$mangaID?$fetchAllMangaFieldsStr',
      {}
    );
    if(res.error == null) {
      MangaDataClass mangaDataModel = MangaDataClass.fetchNewInstance(-1).fromMapUpdateAll(res.data);
      updateMangaStatusFromMap(mangaDataModel.id, res.data['my_list_status']);
      return APIResponseModel(mangaDataModel, null);
    } else {
      return res;
    }
  }

  Future<APIResponseModel> fetchMangaStatistics(int mangaID) async{
    APIResponseModel res = await apiCallRepo.runAPICall(
      APICallType.get,
      jikanApiUrl,
      '$jikanApiUrl/manga/$mangaID/statistics',
      {}
    );
    if(res.error == null) {
      var data = res.data['data'];
      MangaStatisticsClass statistics = MangaStatisticsClass(
        data['reading'], 
        data['completed'], 
        data['on_hold'], 
        data['dropped'], 
        data['plan_to_read']
      );
      return APIResponseModel(statistics, null);
    } else {
      return res;
    }
  }
  
  Future<APIResponseModel> fetchMangaCharacters(int mangaID) async{
    APIResponseModel res = await apiCallRepo.runAPICall(
      APICallType.get,
      jikanApiUrl,
      '$jikanApiUrl/manga/$mangaID/characters',
      {}
    );
    if(res.error == null) {
      var data = res.data['data'];
      List<CharacterDataClass> characters = List.generate(data.length, (i){
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

  Future<APIResponseModel> fetchMyMangasList(UserMangaListStatusClass statusClass) async{
    APIResponseModel res = await apiCallRepo.runAPICall(
      APICallType.get,
      malApiUrl,
      '$malApiUrl/users/@me/mangalist?status=${statusClass.status}&offset=${statusClass.mangaList.length}&limit=$userDisplayFetchLimit&$fetchAllMangaFieldsStr',
      {}
    );
    if(res.error == null) {
      statusClass = statusClass.updateCanPaginate((res.data['paging']['next'] != null));
      var data = res.data['data'];
      for(int i = 0; i < data.length; i++){
        MangaDataClass mangaData = MangaDataClass.fetchNewInstance(-1).fromMapUpdateAll(data[i]['node']);
        int id = data[i]['node']['id'];
        updateMangaStatusFromMap(id, data[i]['node']['my_list_status']);
        statusClass.mangaList.add(mangaData);
      }
      return APIResponseModel(statusClass, null); 
    } else {
      return res;
    }
  }

  Future<APIResponseModel> searchManga(String searchedText) async{
    List<MangaDataClass> mangaList = [];
    APIResponseModel res = await apiCallRepo.runAPICall(
      APICallType.get,
      malApiUrl,
      '$malApiUrl/manga?$fetchAllMangaFieldsStr&q=$searchedText&limit=$searchFetchLimit',
      {}
    );
    if(res.error == null) {
      var data = res.data['data'];
      for(int i = 0; i < data.length; i++){
        MangaDataClass mangaDataModel = MangaDataClass.fetchNewInstance(-1).fromMapUpdateAll(data[i]['node']);
        updateMangaStatusFromMap(mangaDataModel.id, data[i]['node']['my_list_status']);
        mangaList.add(mangaDataModel);
      }
      return APIResponseModel(mangaList, null);
    } else {
      return res;
    }
  }

  Future<APIResponseModel> fetchMangaListFromType(MangaBasicDisplayType type) async{
    String generateAPIRequestPath(){
      if(type == MangaBasicDisplayType.top){
        return '$malApiUrl/manga/ranking?$fetchAllMangaFieldsStr&ranking_type=manga&limit=${getAnimeBasicDisplayTotalFetchCount()}';
      }else if(type == MangaBasicDisplayType.favourites){
        return '$malApiUrl/manga/ranking?$fetchAllMangaFieldsStr&ranking_type=favorite&limit=${getAnimeBasicDisplayTotalFetchCount()}';
      }else if(type == MangaBasicDisplayType.mostPopular){
        return '$malApiUrl/manga/ranking?$fetchAllMangaFieldsStr&ranking_type=bypopularity&limit=${getAnimeBasicDisplayTotalFetchCount()}';
      }
      return '';
    }

    List<MangaDataClass> mangaList = [];
    
    APIResponseModel res = await apiCallRepo.runAPICall(
      APICallType.get,
      malApiUrl,
      generateAPIRequestPath(),
      {}
    );
    if(res.error == null) {
      var data = res.data['data'];
      for(int i = 0; i < data.length; i++){
        MangaDataClass mangaDataModel = MangaDataClass.fetchNewInstance(-1).fromMapUpdateAll(data[i]['node']);
        updateMangaStatusFromMap(mangaDataModel.id, data[i]['node']['my_list_status']);
        mangaList.add(mangaDataModel);
      }
      return APIResponseModel(mangaList, null);
    } else {
      return res;
    }
  }
}
