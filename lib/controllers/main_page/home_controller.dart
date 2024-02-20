import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class HomeController {
  final BuildContext context;
  ValueNotifier<List<int>> seasonAnimeList = ValueNotifier([]);
  ValueNotifier<List<int>> topAnimeList = ValueNotifier([]);
  ValueNotifier<List<int>> topAiringAnimeList = ValueNotifier([]);
  ValueNotifier<List<int>> topUpcomingAnimeList = ValueNotifier([]);
  ValueNotifier<List<int>> mostPopularAnimeList = ValueNotifier([]);
  ValueNotifier<List<int>> topFavouritedAnimeList = ValueNotifier([]);
  ValueNotifier<List<int>> topMangaList = ValueNotifier([]);
  ValueNotifier<List<int>> mostPopularMangaList = ValueNotifier([]);
  ValueNotifier<List<int>> topFavouritedMangaList = ValueNotifier([]);
  ValueNotifier<List<int>> topCharactersList = ValueNotifier([]);

  HomeController (
    this.context
  );

  bool get mounted => context.mounted;

  void initializeController(){
    fetchTopAnime();
    fetchTopFavouritedAnime();
    fetchMostPopularAnime();
    fetchTopAiringAnime();
    fetchTopUpcomingAnime();
    fetchSeasonAnime();
    fetchTopManga();
    fetchTopFavouritedManga();
    fetchMostPopularManga();
    fetchTopCharacters();
  }

  void dispose(){
    seasonAnimeList.dispose();
    topAnimeList.dispose();
    topAiringAnimeList.dispose();
    topUpcomingAnimeList.dispose();
    mostPopularAnimeList.dispose();
    topFavouritedAnimeList.dispose();
    topMangaList.dispose();
    mostPopularMangaList.dispose();
    topFavouritedMangaList.dispose();
    topCharactersList.dispose();
  }

  void fetchSeasonAnime() async{
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/anime/season/${DateTime.now().year}/${getCurrentSeason()}?fields=$fetchAllAnimeFieldsStr&limit=${getAnimeBasicDisplayFetchCount()}',
      {}
    );
    if(res != null) {
      var data = res['data'];
      if(mounted) {
        for(int i = 0; i < data.length; i++){
          updateAnimeData(data[i]['node']);
          seasonAnimeList.value.add(data[i]['node']['id']);
        }
        seasonAnimeList.value = [...seasonAnimeList.value];
      }
    }
  }

  void fetchTopAnime() async{
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/anime/ranking?$fetchAllAnimeFieldsStr&$fetchAllAnimeFieldsStr&ranking_type=all&limit=${getAnimeBasicDisplayFetchCount()}',
      {}
    );
    if(res != null) {
      var data = res['data'];
      if(mounted) {
        for(int i = 0; i < data.length; i++){
          updateAnimeData(data[i]['node']);
          topAnimeList.value.add(data[i]['node']['id']);
        }
        topAnimeList.value = [...topAnimeList.value];
      }
    }
  }

  void fetchTopAiringAnime() async{
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/anime/ranking?$fetchAllAnimeFieldsStr&ranking_type=airing&limit=${getAnimeBasicDisplayFetchCount()}',
      {}
    );
    if(res != null) {
      var data = res['data'];
      if(mounted) {
        for(int i = 0; i < data.length; i++){
          updateAnimeData(data[i]['node']);
          topAiringAnimeList.value.add(data[i]['node']['id']);
        }
        topAiringAnimeList.value = [...topAiringAnimeList.value];
      }
    }
  }

  void fetchTopUpcomingAnime() async{
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/anime/ranking?$fetchAllAnimeFieldsStr&ranking_type=upcoming&limit=${getAnimeBasicDisplayFetchCount()}',
      {}
    );
    if(res != null) {
      var data = res['data'];
      if(mounted) {
        for(int i = 0; i < data.length; i++){
          updateAnimeData(data[i]['node']);
          topUpcomingAnimeList.value.add(data[i]['node']['id']);
        }
        topUpcomingAnimeList.value = [...topUpcomingAnimeList.value];
      }
    }
  }

  void fetchMostPopularAnime() async{
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/anime/ranking?$fetchAllAnimeFieldsStr&ranking_type=bypopularity&limit=${getAnimeBasicDisplayFetchCount()}',
      {}
    );
    if(res != null) {
      var data = res['data'];
      if(mounted) {
        for(int i = 0; i < data.length; i++){
          updateAnimeData(data[i]['node']);
          mostPopularAnimeList.value.add(data[i]['node']['id']);
        }
        mostPopularAnimeList.value = [...mostPopularAnimeList.value];
      }
    }
  }

  void fetchTopFavouritedAnime() async{
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/anime/ranking?$fetchAllAnimeFieldsStr&ranking_type=favorite&limit=${getAnimeBasicDisplayFetchCount()}',
      {}
    );
    if(res != null) {
      var data = res['data'];
      if(mounted) {
        for(int i = 0; i < data.length; i++){
          updateAnimeData(data[i]['node']);
          topFavouritedAnimeList.value.add(data[i]['node']['id']);
        }
        topFavouritedAnimeList.value = [...topFavouritedAnimeList.value];
      }
    }
  }

  void fetchTopManga() async{
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/manga/ranking?$fetchAllMangaFieldsStr&ranking_type=manga&limit=${getAnimeBasicDisplayFetchCount()}',
      {}
    );
    if(res != null) {
      var data = res['data'];
      if(mounted) {
        for(int i = 0; i < data.length; i++){
          updateMangaData(data[i]['node']);
          topMangaList.value.add(data[i]['node']['id']);
        }
        topMangaList.value = [...topMangaList.value];
      }  
    }
  }

  void fetchTopFavouritedManga() async{
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/manga/ranking?$fetchAllMangaFieldsStr&ranking_type=favorite&limit=${getAnimeBasicDisplayFetchCount()}',
      {}
    );
    if(res != null) {
      var data = res['data'];
      if(mounted) {
        for(int i = 0; i < data.length; i++){
          updateMangaData(data[i]['node']);
          topFavouritedMangaList.value.add(data[i]['node']['id']);
        }
        topFavouritedMangaList.value = [...topFavouritedMangaList.value];
      }
    }
  }

  void fetchMostPopularManga() async{
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/manga/ranking?$fetchAllMangaFieldsStr&ranking_type=bypopularity&limit=${getAnimeBasicDisplayFetchCount()}',
      {}
    );
    if(res != null) {
      var data = res['data'];
      if(mounted) {
        for(int i = 0; i < data.length; i++){
          updateMangaData(data[i]['node']);
          mostPopularMangaList.value.add(data[i]['node']['id']);
        }
        mostPopularMangaList.value = [...mostPopularMangaList.value];
      }
    }
  }

  void fetchTopCharacters() async{
     var res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      jikanApiUrl,
      '$jikanApiUrl/top/characters?limit=${getAnimeBasicDisplayFetchCount()}',
      {}
    );
    if(res != null) {
      var data = res['data'];
      if(mounted) {
        for(int i = 0; i < data.length; i++){
          updateBasicCharacterData(data[i]);
          topCharactersList.value.add(data[i]['mal_id']);
        }
      }
    }
  }
}