// ignore_for_file: use_build_context_synchronously, must_be_immutable
import 'package:anime_list_app/appdata/AppStateActions.dart';
import 'package:anime_list_app/appdata/GlobalLibrary.dart';
import 'package:anime_list_app/class/AnimeDataClass.dart';
import 'package:anime_list_app/custom/CustomUserListAnimeDisplay.dart';
import 'package:anime_list_app/state/main.dart';
import 'package:anime_list_app/styles/AppStyles.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SearchedAnimesWidget extends StatelessWidget {
  String searchedText;
  BuildContext absorberContext;

  SearchedAnimesWidget({
    super.key,
    required this.searchedText,
    required this.absorberContext
  });

  @override
  Widget build(BuildContext context) {
    return _SearchedAnimesWidgetStateful(
      searchedText: searchedText,
      absorberContext: absorberContext
    );
  }
}

class _SearchedAnimesWidgetStateful extends StatefulWidget {
  String searchedText;
  BuildContext absorberContext;
  
  _SearchedAnimesWidgetStateful({
    required this.searchedText,
    required this.absorberContext
  });

  @override
  State<_SearchedAnimesWidgetStateful> createState() => _SearchedAnimesWidgetStatefulState();
}

class _SearchedAnimesWidgetStatefulState extends State<_SearchedAnimesWidgetStateful> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin{
  List<int> animesList = [];
  bool isLoading = false;

  @override void initState(){
    super.initState();
    if(mounted){
      fetchUserAnimesList();
    }
  }
  
  void fetchUserAnimesList() async{
    if(widget.searchedText.isNotEmpty){
      isLoading = true;
      var res = await dio.get(
        '$malApiUrl/anime?$fetchAllAnimeFieldsStr&q=${widget.searchedText}&limit=$searchFetchLimit',
        options: Options(
          headers: {
            'Authorization': await generateAuthHeader()
          },
        )
      );
      List data = res.data['data'];
      for(int i = 0; i < data.length; i++){
        updateAnimeData(data[i]['node']);
        int id = data[i]['node']['id'];
        if(appStateClass.globalAnimeData[id] != null){
          animesList.add(id);
        }
      }
      isLoading = false;
      if(mounted){
        setState((){}); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(widget.absorberContext)
        ),
        isLoading == true ?
          SliverList(delegate: SliverChildBuilderDelegate(
            childCount: skeletonLoadingDefaultLimit, 
            (c, i) {
              return shimmerSkeletonWidget(
                CustomUserListAnimeDisplay(
                  animeData: AnimeDataClass.fetchNewInstance(-1),
                  displayType: AnimeRowDisplayType.search,
                  skeletonMode: true,
                  key: UniqueKey()
                )
              );
            }
          ))
        :
          SliverList(delegate: SliverChildBuilderDelegate(
            childCount: animesList.length, 
            (c, i) {
              if(appStateClass.globalAnimeData[animesList[i]] != null){
                return ValueListenableBuilder(
                  valueListenable: appStateClass.globalAnimeData[animesList[i]]!.notifier, 
                  builder: (context, animeData, child){
                    return CustomUserListAnimeDisplay(
                      animeData: animeData,
                      displayType: AnimeRowDisplayType.search,
                      skeletonMode: false,
                      key: UniqueKey()
                    );
                  }
                );
              }
              return Text('${animesList[i]}');
            }
          ))
      ]
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}