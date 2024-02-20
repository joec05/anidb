import 'package:anime_list_app/global_files.dart';
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
  late HomeController controller;

  @override void initState(){
    super.initState();
    controller = HomeController(context);
    controller.initializeController();
  }

  @override void dispose(){
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListenableBuilder(
      listenable: Listenable.merge([
        controller.seasonAnimeList,
        controller.topAnimeList,
        controller.topAiringAnimeList,
        controller.topUpcomingAnimeList,
        controller.mostPopularAnimeList,
        controller.topFavouritedAnimeList,
        controller.topMangaList,
        controller.mostPopularMangaList,
        controller.topFavouritedMangaList,
        controller.topCharactersList
      ]),
      builder: (context, child) {
        List<int> seasonAnimeList = controller.seasonAnimeList.value;
        List<int> topAnimeList = controller.topAnimeList.value;
        List<int> topAiringAnimeList = controller.topAiringAnimeList.value;
        List<int> topUpcomingAnimeList = controller.topUpcomingAnimeList.value;
        List<int> mostPopularAnimeList = controller.mostPopularAnimeList.value;
        List<int> topFavouritedAnimeList = controller.topFavouritedAnimeList.value;
        List<int> topMangaList = controller.topMangaList.value;
        List<int> mostPopularMangaList = controller.mostPopularMangaList.value;
        List<int> topFavouritedMangaList = controller.topFavouritedMangaList.value;
        List<int> topCharactersList = controller.topCharactersList.value;
        
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
    );
  }
  
  @override
  bool get wantKeepAlive => true;

}