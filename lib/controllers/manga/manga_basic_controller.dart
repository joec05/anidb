import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class MangaBasicController {
  final BuildContext context;
  final MangaBasicDisplayType type;
  ValueNotifier<List<int>> mangasList = ValueNotifier([]);
  ValueNotifier<bool> isLoading = ValueNotifier(true);

  MangaBasicController (
    this.context,
    this.type
  );

  bool get mounted => context.mounted;

  void initializeController() {
    fetchMangasList();
  }

  void dispose() {
    mangasList.dispose();
    isLoading.dispose();
  }
  

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

  Future<void> fetchMangasList() async{
    if(mounted){
      var res = await apiCallRepo.runAPICall(
        context,
        APICallType.get,
        malApiUrl,
        generateAPIRequestPath(),
        {}
      );
      if(res != null) {
        var data = res['data'];
        if(mounted) {
          for(int i = 0; i < data.length; i++){
            updateMangaData(data[i]['node']);
            mangasList.value.add(data[i]['node']['id']);
          }
          isLoading.value = false;
        }
      }
    }
  }
}