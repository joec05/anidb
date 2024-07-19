import 'dart:math';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:vertical_barchart/vertical-barchartmodel.dart';
import 'package:vertical_barchart/vertical-legend.dart';

class ProfileRepository {
  UserDataClass? userData;

  Future<APIResponseModel> fetchMyProfileData() async{
    APIResponseModel res = await apiCallRepo.runAPICall(
      APICallType.get,
      malApiUrl,
      '$malApiUrl/users/@me',
      {}
    );
    talker.debug(res.data);
    if(res.error == null) {
      userData = UserDataClass.fromMap(res.data);
      return APIResponseModel(userData, null);
    } else {
      userData = null;
      return res;
    }
  }

  Future<APIResponseModel> fetchMyAnimeStatistics() async {
    UserAnimeStatisticsClass userAnimeStatistics = UserAnimeStatisticsClass.generateNewInstance();
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
    List<BarChartClass> animeBarChartData = [];
    bool canPaginateNext = true;
    APIResponseModel res = APIResponseModel(null, null);

    Future<void> fetchAndCalculateAnimeStatistics() async {
      res = await apiCallRepo.runAPICall(
        APICallType.get,
        malApiUrl,
        '$malApiUrl/users/@me/animelist?offset=${userAnimeStatistics.total}&limit=$statsFetchLimit&fields=my_list_status',
        {}
      );
      if(res.error == null) {
        var data = List.from(res.data['data']).map((e) => e['node']['my_list_status']).toList();
        List<AnimeMyListStatusClass> animeDataList = [];
        for(int i = 0; i < data.length; i++){
          animeDataList.add(AnimeMyListStatusClass.fromMap(data[i]));
          animeScoreCount[animeDataList[i].score] = animeScoreCount[animeDataList[i].score]! + 1;
        }
        
        userAnimeStatistics = UserAnimeStatisticsClass(
          userAnimeStatistics.watching + animeDataList.where((e) => e.status == 'watching').length,
          userAnimeStatistics.completed + animeDataList.where((e) => e.status == 'completed').length,
          userAnimeStatistics.onHold + animeDataList.where((e) => e.status == 'on_hold').length,
          userAnimeStatistics.dropped + animeDataList.where((e) => e.status == 'dropped').length,
          userAnimeStatistics.planToWatch + animeDataList.where((e) => e.status == 'plan_to_watch').length, 
          userAnimeStatistics.total + data.length, 
          0.0,
          userAnimeStatistics.totalEpisodes + animeDataList.map((e) => e.episodesWatched).reduce((a, b) => a + b), 
          0, 
          userAnimeStatistics.totalScore + animeDataList.map((e) => e.score).reduce((a, b) => a + b),
          userAnimeStatistics.ratedCount + animeDataList.where((e) => e.score > 0).length,
          0
        );
        canPaginateNext = res.data['paging']?['next'] ?? false;
      }
    }

    while(canPaginateNext) {
      await fetchAndCalculateAnimeStatistics();
      if(!canPaginateNext || res.error != null) {
        break;
      }
    }

    if(res.error != null) {
      return res;
    }

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

    animeBarChartData.addAll([
      BarChartClass(
        'Status', statusBarModel, statusBarLegend, statusValue.reduce((a, b) => a + b).toDouble()
      ),
      BarChartClass(
        'Scores', scoreBarModel, scoreBarLegend, ((animeScoreCount.values.reduce((a, b) => a + b).toInt()) - animeScoreCount[0]!).toDouble()
      )
    ]);

    return APIResponseModel(userAnimeStatistics, data2: animeBarChartData, null);
  }

  Future<APIResponseModel> fetchMyMangaStatistics() async {
    UserMangaStatisticsClass userMangaStatistics = UserMangaStatisticsClass.generateNewInstance();
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
    List<BarChartClass> mangaBarChartData = [];
    bool canPaginateNext = true;
    APIResponseModel res = APIResponseModel(null, null);

    Future<void> fetchAndCalculateMangaStatistics() async {
      res = await apiCallRepo.runAPICall(
        APICallType.get,
        malApiUrl,
        '$malApiUrl/users/@me/mangalist?offset=${userMangaStatistics.total}limit=$statsFetchLimit&fields=my_list_status',
        {}
      );
      if(res.error == null) {
        var data = List.from(res.data['data']).map((e) => e['node']['my_list_status']).toList();
        List<MangaMyListStatusClass> mangaDataList = [];
        for(int i = 0; i < data.length; i++){
          mangaDataList.add(MangaMyListStatusClass.fromMap(data[i]));
          mangaScoreCount[mangaDataList[i].score] = mangaScoreCount[mangaDataList[i].score]! + 1;
        }
        
        userMangaStatistics = UserMangaStatisticsClass(
          userMangaStatistics.reading + mangaDataList.where((e) => e.status == 'reading').length,
          userMangaStatistics.completed + mangaDataList.where((e) => e.status == 'completed').length,
          userMangaStatistics.onHold + mangaDataList.where((e) => e.status == 'on_hold').length,
          userMangaStatistics.dropped + mangaDataList.where((e) => e.status == 'dropped').length,
          userMangaStatistics.planToRead + mangaDataList.where((e) => e.status == 'plan_to_read').length, 
          userMangaStatistics.total + data.length, 
          0.0,
          userMangaStatistics.totalVolumes + mangaDataList.map((e) => e.volumesRead).reduce((a, b) => a + b), 
          userMangaStatistics.totalChapters + mangaDataList.map((e) => e.chaptersRead).reduce((a, b) => a + b), 
          0, 
          userMangaStatistics.totalScore + mangaDataList.map((e) => e.score).reduce((a, b) => a + b),
          userMangaStatistics.ratedCount + mangaDataList.where((e) => e.score > 0).length,
          0
        );
        canPaginateNext = res.data['paging']?['next'] ?? false;
      }
    }

    while(canPaginateNext) {
      await fetchAndCalculateMangaStatistics();
      if(!canPaginateNext || res.error != null) {
        break;
      }
    }

    if(res.error != null) {
      return res;
    }

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

    mangaBarChartData.addAll([
      BarChartClass(
        'Status', statusBarModel, statusBarLegend, statusValue.reduce((a, b) => a + b).toDouble()
      ),
      BarChartClass(
        'Scores', scoreBarModel, scoreBarLegend, ((mangaScoreCount.values.reduce((a, b) => a + b).toInt()) - mangaScoreCount[0]!).toDouble()
      )
    ]);

    return APIResponseModel(userMangaStatistics, data2: mangaBarChartData, null);
  }
}

final ProfileRepository profileRepository = ProfileRepository();