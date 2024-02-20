import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class AnimeBasicController {
  final BuildContext context;
  AnimeBasicDisplayType type;
  ValueNotifier<List<int>> animesList = ValueNotifier([]);
  ValueNotifier<bool> isLoading = ValueNotifier(true);

  AnimeBasicController(
    this.context,
    this.type
  );

  bool get mounted => context.mounted;

  void initializeController(){
    fetchAnimesList();
  }

  void dispose(){
    animesList.dispose();
  }

  String generateAPIRequestPath(){
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

  Future<void> fetchAnimesList() async{
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
            updateAnimeData(data[i]['node']);
            animesList.value.add(data[i]['node']['id']);
          }
          animesList.value = [...animesList.value];
          isLoading.value = false;
        }
      }
    }
  }
}