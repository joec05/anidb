// ignore_for_file: use_build_context_synchronously, must_be_immutable
import 'dart:async';
import 'package:anime_list_app/appdata/AppStateActions.dart';
import 'package:anime_list_app/appdata/GlobalLibrary.dart';
import 'package:anime_list_app/class/MangaDataClass.dart';
import 'package:anime_list_app/custom/CustomBasicMangaDisplay.dart';
import 'package:anime_list_app/state/main.dart';
import 'package:anime_list_app/styles/AppStyles.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ViewMangaBasicDisplay extends StatelessWidget {
  String label;
  MangaBasicDisplayType displayType;

  ViewMangaBasicDisplay({
    super.key,
    required this.label,
    required this.displayType
  });

  @override
  Widget build(BuildContext context) {
    return _ViewMangaBasicDisplayStateful(
      label: label,
      displayType: displayType
    );
  }
}

class _ViewMangaBasicDisplayStateful extends StatefulWidget {
  String label;
  MangaBasicDisplayType displayType;

  _ViewMangaBasicDisplayStateful({
    required this.label,
    required this.displayType
  });

  @override
  State<_ViewMangaBasicDisplayStateful> createState() => _ViewMangaBasicDisplayStatefulState();
}

class _ViewMangaBasicDisplayStatefulState extends State<_ViewMangaBasicDisplayStateful>{
  List<int> mangasList = [];
  bool isLoading = true;

  @override void initState(){
    super.initState();
    fetchMangasList();
  }

  @override void dispose(){
    super.dispose();
  }

  String generateAPIRequestPath(){
    MangaBasicDisplayType type = widget.displayType;
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
          updateMangaData(data[i]['node']);
          mangasList.add(data[i]['node']['id']);
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
          itemCount: mangasList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: getAnimeBasicDisplayCrossAxis(),    
            childAspectRatio: 0.675
          ),
          itemBuilder: (context, index){
            return ValueListenableBuilder(
              valueListenable: appStateClass.globalMangaData[mangasList[index]]!.notifier, 
              builder: (context, mangaData, child){
                return CustomBasicMangaDisplay(
                  mangaData: mangaData, 
                  showStats: true,
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
              CustomBasicMangaDisplay(
                mangaData: MangaDataClass.fetchNewInstance(-1), 
                showStats: false,
                skeletonMode: true,
                key: UniqueKey()
              )
            );
          },
        )
    );
  }
}