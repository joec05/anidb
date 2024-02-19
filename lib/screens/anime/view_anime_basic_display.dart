import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ViewAnimeBasicDisplay extends StatelessWidget {
  final String label;
  final AnimeBasicDisplayType displayType;

  const ViewAnimeBasicDisplay({
    super.key,
    required this.label,
    required this.displayType
  });

  @override
  Widget build(BuildContext context) {
    return _ViewAnimeBasicDisplayStateful(
      label: label,
      displayType: displayType
    );
  }
}

class _ViewAnimeBasicDisplayStateful extends StatefulWidget {
  final String label;
  final AnimeBasicDisplayType displayType;

  const _ViewAnimeBasicDisplayStateful({
    required this.label,
    required this.displayType
  });

  @override
  State<_ViewAnimeBasicDisplayStateful> createState() => _ViewAnimeBasicDisplayStatefulState();
}

class _ViewAnimeBasicDisplayStatefulState extends State<_ViewAnimeBasicDisplayStateful>{
  List<int> animesList = [];
  bool isLoading = true;

  @override void initState(){
    super.initState();
    fetchAnimesList();
  }

  @override void dispose(){
    super.dispose();
  }

  String generateAPIRequestPath(){
    AnimeBasicDisplayType type = widget.displayType;
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
    try {
      if(mounted){
        var res = await dio.get(
          generateAPIRequestPath(),
          options: Options(
            headers: {
              'Authorization': await generateAuthHeader()
            },
          )
        );
        var data = res.data['data'];
        for(int i = 0; i < data.length; i++){
          updateAnimeData(data[i]['node']);
          animesList.add(data[i]['node']['id']);
        }
        isLoading = false;
        if(mounted){
          setState((){});
        }
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
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
        title: Text(widget.label), titleSpacing: defaultAppBarTitleSpacing,
      ),
      body: !isLoading ?
        GridView.builder(
          itemCount: animesList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: getAnimeBasicDisplayCrossAxis(),    
            childAspectRatio: 0.675
          ),
          itemBuilder: (context, index){
            return ValueListenableBuilder(
              valueListenable: appStateClass.globalAnimeData[animesList[index]]!.notifier, 
              builder: (context, animeData, child){
                return CustomBasicAnimeDisplay(
                  showStats: true,
                  animeData: animeData,
                  skeletonMode: false, 
                  key: UniqueKey()
                );
              }
            );
          },
        )
      :
        GridView.builder(
          itemCount: getAnimeBasicDisplayTotalFetchCount(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: getAnimeBasicDisplayCrossAxis(),    
            childAspectRatio: 0.675
          ),
          itemBuilder: (context, index){
            return shimmerSkeletonWidget(
              CustomBasicAnimeDisplay(
                animeData: AnimeDataClass.fetchNewInstance(-1), 
                skeletonMode: true,
                showStats: false,
                key: UniqueKey()
              )
            );
          }
        )
    );
  }
}