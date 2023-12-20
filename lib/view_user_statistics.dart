import 'dart:math';
import 'package:anime_list_app/appdata/app_state_actions.dart';
import 'package:anime_list_app/appdata/global_library.dart';
import 'package:anime_list_app/class/anime_data_class.dart';
import 'package:anime_list_app/class/bar_chart_class.dart';
import 'package:anime_list_app/class/manga_data_class.dart';
import 'package:anime_list_app/class/user_anime_statistics_class.dart';
import 'package:anime_list_app/class/user_manga_statistics_class.dart';
import 'package:anime_list_app/custom/custom_user_anime_stats.dart';
import 'package:anime_list_app/custom/custom_user_manga_stats.dart';
import 'package:anime_list_app/state/main.dart';
import 'package:anime_list_app/styles/app_styles.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:vertical_barchart/vertical-barchartmodel.dart';
import 'package:vertical_barchart/vertical-legend.dart';

class ViewUserStatistics extends StatelessWidget {
  const ViewUserStatistics({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const _ViewUserStatisticsStateful();
  }
}

class _ViewUserStatisticsStateful extends StatefulWidget {

  const _ViewUserStatisticsStateful();

  @override
  State<_ViewUserStatisticsStateful> createState() => _ViewUserStatisticsStatefulState();
}

class _ViewUserStatisticsStatefulState extends State<_ViewUserStatisticsStateful> with SingleTickerProviderStateMixin{
  UserAnimeStatisticsClass userAnimeStatistics = UserAnimeStatisticsClass.generateNewInstance();
  UserMangaStatisticsClass userMangaStatistics = UserMangaStatisticsClass.generateNewInstance();
  late TabController _tabController;
  List<BarChartClass> animeBarChartData = [];
  List<BarChartClass> mangaBarChartData = [];
  bool isLoading = true;
  bool isLoading2 = true;
  Map<int, int> animeScoreCount = {
    0: 0,
    1: 0,
    2: 0,
    3: 0,
    4: 0,
    5: 0,
    6: 0,
    7: 0,
    8: 0,
    9: 0,
    10: 0
  };
  Map<String, int> animeGenreCount = {};
  Map<int, int> mangaScoreCount = {
    0: 0,
    1: 0,
    2: 0,
    3: 0,
    4: 0,
    5: 0,
    6: 0,
    7: 0,
    8: 0,
    9: 0,
    10: 0
  };
  Map<String, int> mangaGenreCount = {};

  @override void initState(){
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchUserAnimesList();
    fetchUserMangasList();
  }

  @override void dispose(){
    super.dispose();
    _tabController.dispose();
    
  }

  void fetchUserAnimesList() async{
    var res = await dio.get(
      '$malApiUrl/users/@me/animelist?offset=${userAnimeStatistics.total}limit=5&$fetchAllAnimeFieldsStr',
      options: Options(
        headers: {
          'Authorization': await generateAuthHeader()
        },
      )
    );
    var data = res.data['data'];
    List<AnimeDataClass> animeDataList = [];
    for(int i = 0; i < data.length; i++){
      updateAnimeData(data[i]['node']);
      animeDataList.add(appStateClass.globalAnimeData[data[i]['node']['id']]!.notifier.value);
      animeScoreCount[animeDataList[i].myListStatus!.score] = animeScoreCount[animeDataList[i].myListStatus!.score]! + 1;
      List<String> animeGenresList = animeDataList[i].genres.map((e) => e.name).toList();
      for(int g = 0; g < animeGenresList.length; g++){
        animeGenreCount[animeGenresList[g]] = animeGenreCount[animeGenresList[g]] ?? 0;
        animeGenreCount[animeGenresList[g]] = animeGenreCount[animeGenresList[g]]! + 1;
      }
    }
    userAnimeStatistics = UserAnimeStatisticsClass(
      userAnimeStatistics.watching + animeDataList.where((e) => e.myListStatus!.status == 'watching').length,
      userAnimeStatistics.completed + animeDataList.where((e) => e.myListStatus!.status == 'completed').length,
      userAnimeStatistics.onHold + animeDataList.where((e) => e.myListStatus!.status == 'on_hold').length,
      userAnimeStatistics.dropped + animeDataList.where((e) => e.myListStatus!.status == 'dropped').length,
      userAnimeStatistics.planToWatch + animeDataList.where((e) => e.myListStatus!.status == 'plan_to_watch').length, 
      userAnimeStatistics.total + data.length as int, 
      0.0,
      userAnimeStatistics.totalEpisodes + animeDataList.map((e) => e.myListStatus!.episodesWatched).reduce((a, b) => a + b), 
      0, 
      userAnimeStatistics.totalScore + animeDataList.map((e) => e.myListStatus!.score).reduce((a, b) => a + b),
      userAnimeStatistics.ratedCount + animeDataList.where((e) => e.myListStatus!.score > 0).length,
      0
    );
    if(res.data['paging']['next'] != null){
      fetchUserAnimesList();
    }else{
      userAnimeStatistics.meanScore = userAnimeStatistics.totalScore / userAnimeStatistics.ratedCount;

      List<String> statusList = [...animeStatusMap.values];
      List<int> statusValue = [
        userAnimeStatistics.watching,
        userAnimeStatistics.planToWatch,
        userAnimeStatistics.completed,
        userAnimeStatistics.onHold,
        userAnimeStatistics.dropped
      ];

      List<Vlegend> statusBarLegend = [];
      List<VBarChartModel> statusBarModel = List.generate(statusList.length, (i){
        Color randomColor = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
        double count = statusValue[i].toDouble();
        statusBarLegend.add(
          Vlegend(
            isSquare: false,
            color: randomColor,
            text: statusList[i]
          )
        );
        return VBarChartModel(
          index: i,
          colors: [randomColor, randomColor],
          jumlah: count,
          tooltip: '${count.toInt()}'
        );
      });
      
      List<Vlegend> scoreBarLegend = [];
      List<VBarChartModel> scoreBarModel = List.generate(10, (i){
        Color randomColor = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
        double count = animeScoreCount[i + 1]!.toDouble();
        scoreBarLegend.add(
          Vlegend(
            isSquare: false,
            color: randomColor,
            text: '${i + 1}'
          )
        );
        return VBarChartModel(
          index: i,
          colors: [randomColor, randomColor],
          jumlah: count,
          tooltip: '${count.toInt()}'
        );
      });

      List<Vlegend> genreBarLegend = [];
      List<VBarChartModel> genreBarModel = List.generate(animeGenreCount.keys.length, (i){
        Color randomColor = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
        double count = animeGenreCount.values.toList()[i].toDouble();
        genreBarLegend.add(
          Vlegend(
            isSquare: false,
            color: randomColor,
            text: animeGenreCount.keys.toList()[i]
          )
        );
        return VBarChartModel(
          index: i,
          colors: [randomColor, randomColor],
          jumlah: count,
          tooltip: '${count.toInt()}'
        );
      });

      animeBarChartData.addAll([
        BarChartClass(
          'Status', statusBarModel, statusBarLegend, statusValue.reduce((a, b) => a + b).toDouble()
        ),
        BarChartClass(
          'Scores', scoreBarModel, scoreBarLegend, ((animeScoreCount.values.reduce((a, b) => a + b).toInt()) - animeScoreCount[0]!).toDouble()
        ),
        BarChartClass(
          'Genres', genreBarModel, genreBarLegend, animeGenreCount.values.reduce((a, b) => a + b).toDouble()
        )
      ]);
      isLoading = false;
      if(mounted){
        setState((){});
      }
    }
  }

  void fetchUserMangasList() async{
    var res = await dio.get(
      '$malApiUrl/users/@me/mangalist?offset=${userMangaStatistics.total}limit=5&$fetchAllMangaFieldsStr',
      options: Options(
        headers: {
          'Authorization': await generateAuthHeader()
        },
      )
    );
    var data = res.data['data'];
    List<MangaDataClass> mangaDataList = [];
    for(int i = 0; i < data.length; i++){
      updateMangaData(data[i]['node']);
      mangaDataList.add(appStateClass.globalMangaData[data[i]['node']['id']]!.notifier.value);
      mangaScoreCount[mangaDataList[i].myListStatus!.score] = mangaScoreCount[mangaDataList[i].myListStatus!.score]! + 1;
      List<String> mangaGenresList = mangaDataList[i].genres.map((e) => e.name).toList();
      for(int g = 0; g < mangaGenresList.length; g++){
        mangaGenreCount[mangaGenresList[g]] = mangaGenreCount[mangaGenresList[g]] ?? 0;
        mangaGenreCount[mangaGenresList[g]] = mangaGenreCount[mangaGenresList[g]]! + 1;
      }
    }

    userMangaStatistics = UserMangaStatisticsClass(
      userMangaStatistics.reading + mangaDataList.where((e) => e.myListStatus!.status == 'reading').length,
      userMangaStatistics.completed + mangaDataList.where((e) => e.myListStatus!.status == 'completed').length,
      userMangaStatistics.onHold + mangaDataList.where((e) => e.myListStatus!.status == 'on_hold').length,
      userMangaStatistics.dropped + mangaDataList.where((e) => e.myListStatus!.status == 'dropped').length,
      userMangaStatistics.planToRead + mangaDataList.where((e) => e.myListStatus!.status == 'plan_to_read').length, 
      userMangaStatistics.total + data.length as int, 
      0.0,
      userMangaStatistics.totalVolumes + mangaDataList.map((e) => e.myListStatus!.volumesRead).reduce((a, b) => a + b), 
      userMangaStatistics.totalChapters + mangaDataList.map((e) => e.myListStatus!.chaptersRead).reduce((a, b) => a + b), 
      0, 
      userMangaStatistics.totalScore + mangaDataList.map((e) => e.myListStatus!.score).reduce((a, b) => a + b),
      userMangaStatistics.ratedCount + mangaDataList.where((e) => e.myListStatus!.score > 0).length,
      0
    );
    
    if(res.data['paging']['next'] != null){
      fetchUserMangasList();
    }else{
      userMangaStatistics.meanScore = userMangaStatistics.totalScore / userMangaStatistics.ratedCount;
      
      List<String> statusList = [...mangaStatusMap.values];
      List<int> statusValue = [
        userMangaStatistics.reading,
        userMangaStatistics.planToRead,
        userMangaStatistics.completed,
        userMangaStatistics.onHold,
        userMangaStatistics.dropped
      ];

      List<Vlegend> statusBarLegend = [];
      List<VBarChartModel> statusBarModel = List.generate(statusList.length, (i){
        Color randomColor = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
        double count = statusValue[i].toDouble();
        statusBarLegend.add(
          Vlegend(
            isSquare: false,
            color: randomColor,
            text: statusList[i]
          )
        );
        return VBarChartModel(
          index: i,
          colors: [randomColor, randomColor],
          jumlah: count,
          tooltip: '${count.toInt()}'
        );
      });
      
      List<Vlegend> scoreBarLegend = [];
      List<VBarChartModel> scoreBarModel = List.generate(10, (i){
        Color randomColor = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
        double count = mangaScoreCount[i + 1]!.toDouble();
        scoreBarLegend.add(
          Vlegend(
            isSquare: false,
            color: randomColor,
            text: '${i + 1}'
          )
        );
        return VBarChartModel(
          index: i,
          colors: [randomColor, randomColor],
          jumlah: count,
          tooltip: '${count.toInt()}'
        );
      });

      List<Vlegend> genreBarLegend = [];
      List<VBarChartModel> genreBarModel = List.generate(mangaGenreCount.keys.length, (i){
        Color randomColor = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
        double count = mangaGenreCount.values.toList()[i].toDouble();
        genreBarLegend.add(
          Vlegend(
            isSquare: false,
            color: randomColor,
            text: mangaGenreCount.keys.toList()[i]
          )
        );
        return VBarChartModel(
          index: i,
          colors: [randomColor, randomColor],
          jumlah: count,
          tooltip: '${count.toInt()}'
        );
      });

      mangaBarChartData.addAll([
        BarChartClass(
          'Status', statusBarModel, statusBarLegend, statusValue.reduce((a, b) => a + b).toDouble()
        ),
        BarChartClass(
          'Scores', scoreBarModel, scoreBarLegend, ((mangaScoreCount.values.reduce((a, b) => a + b).toInt()) - mangaScoreCount[0]!).toDouble()
        ),
        BarChartClass(
          'Genres', genreBarModel, genreBarLegend, mangaGenreCount.values.reduce((a, b) => a + b).toDouble()
        )
      ]);
      isLoading2 = false;
      if(mounted){
        setState((){});
      }
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        leading: defaultLeadingWidget(context),
        flexibleSpace: Container(
          decoration: defaultAppBarDecoration
        ),
        title: const Text('Statistics'), titleSpacing: defaultAppBarTitleSpacing,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, bool f) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                floating: true, 
                expandedHeight: 50,
                pinned: true,
                automaticallyImplyLeading: false,
                bottom: TabBar(
                  onTap: (selectedIndex) {
                  },
                  isScrollable: false,
                  controller: _tabController,
                  labelColor: Colors.grey,
                  indicatorColor: Colors.orange,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 3.0,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Anime'),
                    Tab(text: 'Manga'),
                  ],
                )                           
            ),
            )
          ];
        },
        body: Builder(
          builder: (context){
            return TabBarView(
              controller: _tabController,
              children: [
                !isLoading ? 
                  CustomUserAnimeStatsWidget(
                    userAnimeStats: userAnimeStatistics, 
                    barChartData: animeBarChartData, 
                    absorberContext: context,
                    skeletonMode: false,
                    key: UniqueKey()
                  )
                : 
                  shimmerSkeletonWidget(
                    CustomUserAnimeStatsWidget(
                      userAnimeStats: userAnimeStatistics, 
                      barChartData: animeBarChartData, 
                      absorberContext: context,
                      skeletonMode: true,
                      key: UniqueKey()
                    ),
                  ),
                !isLoading2 ?
                  CustomUserMangaStatsWidget(
                    userMangaStats: userMangaStatistics, 
                    barChartData: mangaBarChartData, 
                    absorberContext: context,
                    skeletonMode: false,
                    key: UniqueKey()
                  )
                :
                  shimmerSkeletonWidget(
                    CustomUserMangaStatsWidget(
                      userMangaStats: userMangaStatistics, 
                      barChartData: mangaBarChartData, 
                      absorberContext: context,
                      skeletonMode: true,
                      key: UniqueKey()
                    ),
                  )
              ]
            );
          }
        )
      )
    );
  }

}