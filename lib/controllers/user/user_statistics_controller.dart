import 'dart:math';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:vertical_barchart/vertical-barchartmodel.dart';
import 'package:vertical_barchart/vertical-legend.dart';

class UserStatisticsController {
  BuildContext context;
  ValueNotifier<UserAnimeStatisticsClass> userAnimeStatistics = ValueNotifier(UserAnimeStatisticsClass.generateNewInstance());
  ValueNotifier<UserMangaStatisticsClass> userMangaStatistics = ValueNotifier(UserMangaStatisticsClass.generateNewInstance());
  ValueNotifier<List<BarChartClass>> animeBarChartData = ValueNotifier([]);
  ValueNotifier<List<BarChartClass>> mangaBarChartData = ValueNotifier([]);
  ValueNotifier<bool> isLoading = ValueNotifier(true);
  ValueNotifier<bool> isLoading2 = ValueNotifier(true);
  ValueNotifier<Map<int, int>> animeScoreCount = ValueNotifier({
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
  });
  ValueNotifier<Map<int, int>> mangaScoreCount = ValueNotifier({
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
  });

  UserStatisticsController(
    this.context
  );

  bool get mounted => context.mounted;

  void initializeController() {
    fetchUserAnimesList();
    fetchUserMangasList();
  }

  void dispose() {
    userAnimeStatistics.dispose();
    userMangaStatistics.dispose();
    animeBarChartData.dispose();
    mangaBarChartData.dispose();
    isLoading.dispose();
    isLoading2.dispose();
    animeScoreCount.dispose();
    mangaScoreCount.dispose();
  }

  void fetchUserAnimesList() async{
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/users/@me/animelist?offset=${userAnimeStatistics.value.total}limit=$statsFetchLimit&$fetchAllAnimeFieldsStr',
      {}
    );
    if(res != null) {
      var data = res['data'];
      if(mounted) {
        List<AnimeDataClass> animeDataList = [];
        for(int i = 0; i < data.length; i++){
          updateAnimeData(data[i]['node']);
          animeDataList.add(appStateRepo.globalAnimeData[data[i]['node']['id']]!.notifier.value);
          animeScoreCount.value[animeDataList[i].myListStatus!.score] = animeScoreCount.value[animeDataList[i].myListStatus!.score]! + 1;
        }
        
        userAnimeStatistics.value = UserAnimeStatisticsClass(
          userAnimeStatistics.value.watching + animeDataList.where((e) => e.myListStatus!.status == 'watching').length,
          userAnimeStatistics.value.completed + animeDataList.where((e) => e.myListStatus!.status == 'completed').length,
          userAnimeStatistics.value.onHold + animeDataList.where((e) => e.myListStatus!.status == 'on_hold').length,
          userAnimeStatistics.value.dropped + animeDataList.where((e) => e.myListStatus!.status == 'dropped').length,
          userAnimeStatistics.value.planToWatch + animeDataList.where((e) => e.myListStatus!.status == 'plan_to_watch').length, 
          userAnimeStatistics.value.total + data.length as int, 
          0.0,
          userAnimeStatistics.value.totalEpisodes + animeDataList.map((e) => e.myListStatus!.episodesWatched).reduce((a, b) => a + b), 
          0, 
          userAnimeStatistics.value.totalScore + animeDataList.map((e) => e.myListStatus!.score).reduce((a, b) => a + b),
          userAnimeStatistics.value.ratedCount + animeDataList.where((e) => e.myListStatus!.score > 0).length,
          0
        );
        if(res['paging']['next'] != null){
          fetchUserAnimesList();
        }else{
          userAnimeStatistics.value.meanScore = userAnimeStatistics.value.totalScore / userAnimeStatistics.value.ratedCount;
          userAnimeStatistics.value = userAnimeStatistics.value.copy();

          List<String> statusList = [...animeStatusMap.values];
          List<int> statusValue = [
            userAnimeStatistics.value.watching,
            userAnimeStatistics.value.planToWatch,
            userAnimeStatistics.value.completed,
            userAnimeStatistics.value.onHold,
            userAnimeStatistics.value.dropped
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
            double count = animeScoreCount.value[i + 1]!.toDouble();
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

          animeBarChartData.value.addAll([
            BarChartClass(
              'Status', statusBarModel, statusBarLegend, statusValue.reduce((a, b) => a + b).toDouble()
            ),
            BarChartClass(
              'Scores', scoreBarModel, scoreBarLegend, ((animeScoreCount.value.values.reduce((a, b) => a + b).toInt()) - animeScoreCount.value[0]!).toDouble()
            )
          ]);
          animeBarChartData.value = [...animeBarChartData.value];
          isLoading.value = false;
        }
      }
    }
  }

  void fetchUserMangasList() async{
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/users/@me/mangalist?offset=${userMangaStatistics.value.total}limit=$statsFetchLimit&$fetchAllMangaFieldsStr',
      {}
    );
    if(res != null) {
      var data = res['data'];
      List<MangaDataClass> mangaDataList = [];
      for(int i = 0; i < data.length; i++){
        updateMangaData(data[i]['node']);
        mangaDataList.add(appStateRepo.globalMangaData[data[i]['node']['id']]!.notifier.value);
        mangaScoreCount.value[mangaDataList[i].myListStatus!.score] = mangaScoreCount.value[mangaDataList[i].myListStatus!.score]! + 1;
      }
      
      userMangaStatistics.value = UserMangaStatisticsClass(
        userMangaStatistics.value.reading + mangaDataList.where((e) => e.myListStatus!.status == 'reading').length,
        userMangaStatistics.value.completed + mangaDataList.where((e) => e.myListStatus!.status == 'completed').length,
        userMangaStatistics.value.onHold + mangaDataList.where((e) => e.myListStatus!.status == 'on_hold').length,
        userMangaStatistics.value.dropped + mangaDataList.where((e) => e.myListStatus!.status == 'dropped').length,
        userMangaStatistics.value.planToRead + mangaDataList.where((e) => e.myListStatus!.status == 'plan_to_read').length, 
        userMangaStatistics.value.total + data.length as int, 
        0.0,
        userMangaStatistics.value.totalVolumes + mangaDataList.map((e) => e.myListStatus!.volumesRead).reduce((a, b) => a + b), 
        userMangaStatistics.value.totalChapters + mangaDataList.map((e) => e.myListStatus!.chaptersRead).reduce((a, b) => a + b), 
        0, 
        userMangaStatistics.value.totalScore + mangaDataList.map((e) => e.myListStatus!.score).reduce((a, b) => a + b),
        userMangaStatistics.value.ratedCount + mangaDataList.where((e) => e.myListStatus!.score > 0).length,
        0
      );
      
      if(res['paging']['next'] != null){
        fetchUserMangasList();
      }else{
        userMangaStatistics.value.meanScore = userMangaStatistics.value.totalScore / userMangaStatistics.value.ratedCount;
        userMangaStatistics.value = userMangaStatistics.value.copy();

        List<String> statusList = [...mangaStatusMap.values];
        List<int> statusValue = [
          userMangaStatistics.value.reading,
          userMangaStatistics.value.planToRead,
          userMangaStatistics.value.completed,
          userMangaStatistics.value.onHold,
          userMangaStatistics.value.dropped
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
          double count = mangaScoreCount.value[i + 1]!.toDouble();
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

        mangaBarChartData.value.addAll([
          BarChartClass(
            'Status', statusBarModel, statusBarLegend, statusValue.reduce((a, b) => a + b).toDouble()
          ),
          BarChartClass(
            'Scores', scoreBarModel, scoreBarLegend, ((mangaScoreCount.value.values.reduce((a, b) => a + b).toInt()) - mangaScoreCount.value[0]!).toDouble()
          )
        ]);
        mangaBarChartData.value = [...mangaBarChartData.value];

        isLoading2.value = false;
      }
    }
  }
}