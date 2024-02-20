import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class AnimeDetailsController {
  final BuildContext context;
  final int animeID;
  ValueNotifier<bool> isLoading = ValueNotifier(true);

  AnimeDetailsController (
    this.context,
    this.animeID
  );

  bool get mounted => context.mounted;

  void initializeController(){
    fetchAnimeDetails();
    fetchAnimeCharacters();
  }

  void dispose(){
    isLoading.dispose();
  }

  void fetchAnimeDetails() async{
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/anime/$animeID?$fetchAllAnimeFieldsStr',
      {}
    );
    if(res != null) {
      updateAnimeData(res);
    }
  }

  void fetchAnimeCharacters() async{
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      jikanApiUrl,
      '$jikanApiUrl/anime/$animeID/characters',
      {}
    );
    if(res != null) {
      var data = res['data'];
      AnimeDataClass animeData = appStateRepo.globalAnimeData[animeID]!.notifier.value;
      AnimeDataClass newAnimeData = AnimeDataClass.generateNewCopy(animeData);
      newAnimeData.characters = List.generate(data.length, (i){
        CharacterDataClass newCharacterData = CharacterDataClass.fetchNewInstance(data[i]['character']['mal_id']);
        newCharacterData.name = data[i]['character']['name'];
        newCharacterData.cover = CharacterImageClass(
          data[i]['character']['images']['jpg']['small_image_url'],
          data[i]['character']['images']['jpg']['image_url']
        );
        return newCharacterData;
      });
      appStateRepo.globalAnimeData[animeID]!.notifier.value = newAnimeData;
      if(mounted) {
        isLoading.value = false;
      }
    }
  }
}