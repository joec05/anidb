import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class ExploreController {
  final BuildContext context;
  ValueNotifier<List<int>> animesList = ValueNotifier([]);
  ValueNotifier<bool> isLoading = ValueNotifier(true);

  ExploreController (
    this.context
  );

  bool get mounted => context.mounted;

  void initializeController() {
    fetchAnimesList();
  }

  void dispose(){
    isLoading.dispose();
    animesList.dispose();
  }

  Future<void> fetchAnimesList() async{
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/anime/suggestions?$fetchAllAnimeFieldsStr&limit=${getAnimeBasicDisplayTotalFetchCount()}',
      {}
    );
    if(res != null) {
      var data = res['data'];
      if(mounted) {
        for(int i = 0; i < data.length; i++){
          updateAnimeData(data[i]['node']);
          animesList.value.add(data[i]['node']['id']);
        }
        animesList.value = [...animesList.value];
        isLoading.value = false;
      }
    }
  }
}