// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:anime_list_app/appdata/AppStateActions.dart';
import 'package:anime_list_app/appdata/GlobalLibrary.dart';
import 'package:anime_list_app/class/AnimeDataClass.dart';
import 'package:anime_list_app/custom/CustomBasicAnimeDisplay.dart';
import 'package:anime_list_app/state/main.dart';
import 'package:anime_list_app/styles/AppStyles.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ExplorePageStateful();
  }
}

class _ExplorePageStateful extends StatefulWidget {
  const _ExplorePageStateful();

  @override
  State<_ExplorePageStateful> createState() => _ExplorePageStatefulState();
}

class _ExplorePageStatefulState extends State<_ExplorePageStateful> with AutomaticKeepAliveClientMixin{
  List<int> animesList = [];
  bool isLoading = true;

  @override void initState(){
    super.initState();
    fetchAnimesList();
  }

  @override void dispose(){
    super.dispose();
  }

  Future<void> fetchAnimesList() async{
    var res = await dio.get(
      '$malApiUrl/anime/suggestions?$fetchAllAnimeFieldsStr&limit=${getAnimeBasicDisplayTotalFetchCount()}',
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if(!isLoading){
      return GridView.builder(
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
                animeData: animeData, 
                showStats: true,
                skeletonMode: false,
                key: UniqueKey()
              );
            }
          );
        }
      );
    }else{
      return GridView.builder(
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
      );
    }
  }
  
  @override
  bool get wantKeepAlive => true;

}