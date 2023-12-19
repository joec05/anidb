import 'package:anime_list_app/appdata/AppStateActions.dart';
import 'package:anime_list_app/appdata/GlobalLibrary.dart';
import 'package:anime_list_app/custom/CustomHomeFrontDisplay.dart';
import 'package:anime_list_app/styles/AppStyles.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomePageStateful();
  }
}

class _HomePageStateful extends StatefulWidget {
  const _HomePageStateful();

  @override
  State<_HomePageStateful> createState() => _HomePageStatefulState();
}

class _HomePageStatefulState extends State<_HomePageStateful> with AutomaticKeepAliveClientMixin{
  List<int> seasonAnimeList = [];
  List<int> topAnimeList = [];
  List<int> topAiringAnimeList = [];
  List<int> topUpcomingAnimeList = [];
  List<int> mostPopularAnimeList = [];
  List<int> topFavouritedAnimeList = [];
  List<int> topMangaList = [];
  List<int> mostPopularMangaList = [];
  List<int> topFavouritedMangaList = [];
  List<int> topCharactersList = [];

  @override void initState(){
    super.initState();
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

  @override void dispose(){
    super.dispose();
  }

  void fetchSeasonAnime() async{
    var res = await dio.get(
      '$malApiUrl/anime/season/${DateTime.now().year}/${getCurrentSeason()}?fields=$fetchAllAnimeFieldsStr&limit=${getAnimeBasicDisplayFetchCount()}',
      options: Options(
        headers: {
          'Authorization': await generateAuthHeader()
        },
      )
    );
    var data = res.data['data'];
    for(int i = 0; i < data.length; i++){
      updateAnimeData(data[i]['node']);
      seasonAnimeList.add(data[i]['node']['id']);
    }
    if(mounted){
      setState((){});
    }
  }

  void fetchTopAnime() async{
    var res = await dio.get(
      '$malApiUrl/anime/ranking?$fetchAllAnimeFieldsStr&$fetchAllAnimeFieldsStr&ranking_type=all&limit=${getAnimeBasicDisplayFetchCount()}',
      options: Options(
        headers: {
          'Authorization': await generateAuthHeader()
        },
      )
    );
    var data = res.data['data'];
    for(int i = 0; i < data.length; i++){
      updateAnimeData(data[i]['node']);
      topAnimeList.add(data[i]['node']['id']);
    }
    if(mounted){
      setState((){});
    }
  }

  void fetchTopAiringAnime() async{
    var res = await dio.get(
      '$malApiUrl/anime/ranking?$fetchAllAnimeFieldsStr&ranking_type=airing&limit=${getAnimeBasicDisplayFetchCount()}',
      options: Options(
        headers: {
          'Authorization': await generateAuthHeader()
        },
      )
    );
    var data = res.data['data'];
    for(int i = 0; i < data.length; i++){
      updateAnimeData(data[i]['node']);
      topAiringAnimeList.add(data[i]['node']['id']);
    }

    if(mounted){
      setState((){});
    }
  }

  void fetchTopUpcomingAnime() async{
    var res = await dio.get(
      '$malApiUrl/anime/ranking?$fetchAllAnimeFieldsStr&ranking_type=upcoming&limit=${getAnimeBasicDisplayFetchCount()}',
      options: Options(
        headers: {
          'Authorization': await generateAuthHeader()
        },
      )
    );
    var data = res.data['data'];
    for(int i = 0; i < data.length; i++){
      updateAnimeData(data[i]['node']);
      topUpcomingAnimeList.add(data[i]['node']['id']);
    }
    if(mounted){
      setState((){});
    }
  }

  void fetchMostPopularAnime() async{
    var res = await dio.get(
      '$malApiUrl/anime/ranking?$fetchAllAnimeFieldsStr&ranking_type=bypopularity&limit=${getAnimeBasicDisplayFetchCount()}',
      options: Options(
        headers: {
          'Authorization': await generateAuthHeader()
        },
      )
    );
    var data = res.data['data'];
    for(int i = 0; i < data.length; i++){
      updateAnimeData(data[i]['node']);
      mostPopularAnimeList.add(data[i]['node']['id']);
    }
    if(mounted){
      setState((){});
    }
  }

  void fetchTopFavouritedAnime() async{
    var res = await dio.get(
      '$malApiUrl/anime/ranking?$fetchAllAnimeFieldsStr&ranking_type=favorite&limit=${getAnimeBasicDisplayFetchCount()}',
      options: Options(
        headers: {
          'Authorization': await generateAuthHeader()
        },
      )
    );
    var data = res.data['data'];
    for(int i = 0; i < data.length; i++){
      updateAnimeData(data[i]['node']);
      topFavouritedAnimeList.add(data[i]['node']['id']);
    }
    if(mounted){
      setState((){});
    }
  }

  void fetchTopManga() async{
    var res = await dio.get(
      '$malApiUrl/manga/ranking?$fetchAllMangaFieldsStr&ranking_type=manga&limit=${getAnimeBasicDisplayFetchCount()}',
      options: Options(
        headers: {
          'Authorization': await generateAuthHeader()
        },
      )
    );
    var data = res.data['data'];
    for(int i = 0; i < data.length; i++){
      updateMangaData(data[i]['node']);
      topMangaList.add(data[i]['node']['id']);
    }
    if(mounted){
      setState((){});
    }
  }

  void fetchTopFavouritedManga() async{
    var res = await dio.get(
      '$malApiUrl/manga/ranking?$fetchAllMangaFieldsStr&ranking_type=favorite&limit=${getAnimeBasicDisplayFetchCount()}',
      options: Options(
        headers: {
          'Authorization': await generateAuthHeader()
        },
      )
    );
    var data = res.data['data'];
    for(int i = 0; i < data.length; i++){
      updateMangaData(data[i]['node']);
      topFavouritedMangaList.add(data[i]['node']['id']);
    }
    if(mounted){
      setState((){});
    }
  }

  void fetchMostPopularManga() async{
    var res = await dio.get(
      '$malApiUrl/manga/ranking?$fetchAllMangaFieldsStr&ranking_type=bypopularity&limit=${getAnimeBasicDisplayFetchCount()}',
      options: Options(
        headers: {
          'Authorization': await generateAuthHeader()
        },
      )
    );
    var data = res.data['data'];
    for(int i = 0; i < data.length; i++){
      updateMangaData(data[i]['node']);
      mostPopularMangaList.add(data[i]['node']['id']);
    }
    if(mounted){
      setState((){});
    }
  }

  void fetchTopCharacters() async{
    var res = await dio.get(
      '$jikanApiUrl/top/characters?limit=${getAnimeBasicDisplayFetchCount()}'
    );
    var data = res.data['data'];
    for(int i = 0; i < data.length; i++){
      updateBasicCharacterData(data[i]);
      topCharactersList.add(data[i]['mal_id']);
    }
    if(mounted){
      setState((){});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView(
      children: [
        CustomHomeFrontDisplay(
          label: 'Animes this season',
          displayType: AnimeBasicDisplayType.season, 
          dataList: seasonAnimeList,
          isLoading: seasonAnimeList.isEmpty,
          key: UniqueKey(),
        ),
        CustomHomeFrontDisplay(
          label: 'Airing now',
          displayType: AnimeBasicDisplayType.airing, 
          dataList: topAiringAnimeList,
          isLoading: topAiringAnimeList.isEmpty,
          key: UniqueKey(),
        ),
        CustomHomeFrontDisplay(
          label: 'Upcoming animes',
          displayType: AnimeBasicDisplayType.upcoming, 
          dataList: topUpcomingAnimeList,
          isLoading: topUpcomingAnimeList.isEmpty,
          key: UniqueKey(),
        ),
        CustomHomeFrontDisplay(
          label: 'Top scoring animes',
          displayType: AnimeBasicDisplayType.top, 
          isLoading: topAnimeList.isEmpty,
          dataList: topAnimeList,
          key: UniqueKey(),
        ),
        CustomHomeFrontDisplay(
          label: 'Popular animes',
          displayType: AnimeBasicDisplayType.mostPopular, 
          dataList: mostPopularAnimeList,
          isLoading: mostPopularAnimeList.isEmpty,
          key: UniqueKey(),
        ),
        CustomHomeFrontDisplay(
          label: 'Top favorited animes',
          displayType: AnimeBasicDisplayType.favourites, 
          dataList: topFavouritedAnimeList,
          isLoading: topFavouritedAnimeList.isEmpty,
          key: UniqueKey(),
        ),
        CustomHomeFrontDisplay(
          label: 'Top scoring mangas',
          displayType: MangaBasicDisplayType.top, 
          dataList: topMangaList,
          isLoading: topMangaList.isEmpty,
          key: UniqueKey(),
        ),
        CustomHomeFrontDisplay(
          label: 'Popular mangas',
          displayType: MangaBasicDisplayType.mostPopular, 
          dataList: mostPopularMangaList,
          isLoading: mostPopularMangaList.isEmpty,
          key: UniqueKey(),
        ),
        CustomHomeFrontDisplay(
          label: 'Top favorited mangas',
          displayType: MangaBasicDisplayType.favourites, 
          dataList: topFavouritedMangaList,
          isLoading: topFavouritedMangaList.isEmpty,
          key: UniqueKey(),
        ),
        CustomHomeFrontDisplay(
          label: 'Top characters',
          displayType: CharacterBasicDisplayType.top, 
          dataList: topCharactersList,
          isLoading: topCharactersList.isEmpty,
          key: UniqueKey(),
        ),
        SizedBox(
          height: defaultVerticalPadding * 2
        ),
      ]
    );
  }
  
  @override
  bool get wantKeepAlive => true;

}