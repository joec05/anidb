import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class SearchedAnimeController {
  final BuildContext context;
  final String searchedText;
  ValueNotifier<List<int>> animesList = ValueNotifier([]);
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  SearchedAnimeController(
    this.context,
    this.searchedText
  );

  bool get mounted => context.mounted;

  void initializeController() {
    if(mounted){
      fetchUserAnimesList();
    }
  }
  
  void fetchUserAnimesList() async{
    if(searchedText.isNotEmpty){
      isLoading.value = true;
      var res = await apiCallRepo.runAPICall(
        context,
        APICallType.get,
        malApiUrl,
        '$malApiUrl/anime?$fetchAllAnimeFieldsStr&q=$searchedText&limit=$searchFetchLimit',
        {}
      );
      if(res != null) {
        var data = res['data'];
        if(mounted) {
          for(int i = 0; i < data.length; i++){
            updateAnimeData(data[i]['node']);
            int id = data[i]['node']['id'];
            if(appStateRepo.globalAnimeData[id] != null){
              animesList.value.add(id);
            }
          }
          animesList.value = [...animesList.value];
          isLoading.value = false;
        }
      }
    }
  }
}