import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class MangaDetailsController {
  final BuildContext context;
  final int mangaID;
  ValueNotifier<bool> isLoading = ValueNotifier(true);

  MangaDetailsController(
    this.context,
    this.mangaID
  );

  bool get mounted => context.mounted;

  void initializeController() {
    fetchMangaDetails();
    fetchMangaStatistics();
    fetchMangaCharacters();
  }

  void dispose(){
    isLoading.dispose();
  }

  void fetchMangaDetails() async{
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/manga/$mangaID?$fetchAllMangaFieldsStr',
      {}
    );
    if(res != null) {
      updateMangaData(res);
    }
  }

  void fetchMangaStatistics() async{
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      jikanApiUrl,
      '$jikanApiUrl/manga/$mangaID/statistics',
      {}
    );
    if(res != null) {
      var data = res['data'];
      MangaDataClass mangaData = appStateRepo.globalMangaData[mangaID]!.notifier.value;
      MangaDataClass newMangaData = MangaDataClass.generateNewCopy(mangaData);
      newMangaData.statistics = MangaStatisticsClass(
        data['reading'], 
        data['completed'], 
        data['on_hold'], 
        data['dropped'], 
        data['plan_to_read']
      );
      appStateRepo.globalMangaData[mangaID]!.notifier.value = newMangaData;
      if(mounted){
        isLoading.value = false;
      }
    }
  }
  
  void fetchMangaCharacters() async{
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      jikanApiUrl,
      '$jikanApiUrl/manga/$mangaID/characters',
      {}
    );
    if(res != null) {
      var data = res['data'];
      MangaDataClass mangaData = appStateRepo.globalMangaData[mangaID]!.notifier.value;
      MangaDataClass newMangaData = MangaDataClass.generateNewCopy(mangaData);
      newMangaData.characters = List.generate(data.length, (i){
        CharacterDataClass newCharacterData = CharacterDataClass.fetchNewInstance(data[i]['character']['mal_id']);
        newCharacterData.name = data[i]['character']['name'];
        newCharacterData.cover = CharacterImageClass(
          data[i]['character']['images']['jpg']['small_image_url'],
          data[i]['character']['images']['jpg']['image_url']
        );
        return newCharacterData;
      });
      appStateRepo.globalMangaData[mangaID]!.notifier.value = newMangaData;
    }
  }
}