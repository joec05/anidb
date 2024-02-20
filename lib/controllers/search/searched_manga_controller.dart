import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class SearchedMangaController {
  final BuildContext context;
  final String searchedText;
  ValueNotifier<List<int>> mangasList = ValueNotifier([]);
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  SearchedMangaController(
    this.context,
    this.searchedText
  );

  bool get mounted => context.mounted;

  void initializeController() {
    if(mounted){
      fetchUserMangasList();
    }
  }

  void dispose() {
    mangasList.dispose();
    isLoading.dispose();
  }
  
  void fetchUserMangasList() async{
    if(searchedText.isNotEmpty){
      isLoading.value = true;
      var res = await apiCallRepo.runAPICall(
        context,
        APICallType.get,
        malApiUrl,
        '$malApiUrl/manga?$fetchAllMangaFieldsStr&q=$searchedText&limit=$searchFetchLimit',
        {}
      );
      if(res != null) {
        var data = res['data'];
        if(mounted) {
          for(int i = 0; i < data.length; i++){
            updateMangaData(data[i]['node']);
            int id = data[i]['node']['id'];
            if(appStateRepo.globalMangaData[id] != null){
              mangasList.value.add(id);
            }
          }
          mangasList.value = [...mangasList.value];
          isLoading.value = false;
        }
      }
    }
  }
}